{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    concatMapStringsSep
    escapeShellArg
    filterAttrs
    flatten
    mapAttrs
    mapAttrs'
    mapAttrsToList
    mkEnableOption
    mkIf
    mkOption
    nameValuePair
    optionalString
    types
    ;
  inherit (lib.strings) toIntBase10;

  cfg = config.services.awsKeyRotation;
  stateRoot = "${config.home.homeDirectory}/.local/state/aws-key-rotation";

  calendarIntervalEntryType = types.submodule {
    options = {
      Minute = mkOption {
        type = types.nullOr (types.ints.between 0 59);
        default = null;
        description = "Minute (0-59). Null means wildcard.";
      };

      Hour = mkOption {
        type = types.nullOr (types.ints.between 0 23);
        default = null;
        description = "Hour (0-23). Null means wildcard.";
      };

      Day = mkOption {
        type = types.nullOr (types.ints.between 1 31);
        default = null;
        description = "Day of month (1-31). Null means wildcard.";
      };

      Weekday = mkOption {
        type = types.nullOr (types.ints.between 0 7);
        default = null;
        description = "Weekday (0-7, where 0 and 7 are Sunday). Null means wildcard.";
      };

      Month = mkOption {
        type = types.nullOr (types.ints.between 1 12);
        default = null;
        description = "Month (1-12). Null means wildcard.";
      };
    };
  };

  parseTimeOrNull =
    value:
    let
      match = builtins.match "^([01][0-9]|2[0-3]):([0-5][0-9])$" value;
    in
    if match == null then
      null
    else
      {
        hour = toIntBase10 (builtins.elemAt match 0);
        minute = toIntBase10 (builtins.elemAt match 1);
      };

  mkDailyCalendar =
    value:
    let
      parsed = parseTimeOrNull value;
    in
    if parsed == null then
      [
        {
          Hour = 0;
          Minute = 0;
        }
      ]
    else
      [
        {
          Hour = parsed.hour;
          Minute = parsed.minute;
        }
      ];

  enabledJobs = filterAttrs (_: job: job.enable) cfg.jobs;

  mkJobScript =
    name: job:
    let
      cadenceUnit = if job.rotation.every.days != null then "days" else "months";
      cadenceValue =
        if job.rotation.every.days != null then job.rotation.every.days else job.rotation.every.months;
    in
    pkgs.writeShellApplication {
      name = "aws-key-rotation-${name}";
      runtimeInputs = with pkgs; [
        aws-rotate-key
        awscli2
        coreutils
        findutils
        gnused
        jq
        python3
      ];
      text = ''
                set -euo pipefail

                JOB_NAME=${escapeShellArg name}
                PROFILE=${escapeShellArg job.profile}
                LOG_ROOT=${escapeShellArg cfg.auditLogPath}
                STATE_ROOT=${escapeShellArg stateRoot}
                RETENTION_DAYS=${toString cfg.logRetentionDays}
                ANCHOR_DATE=${escapeShellArg job.rotation.anchorDate}
                CADENCE_UNIT=${escapeShellArg cadenceUnit}
                CADENCE_VALUE=${toString cadenceValue}

                JOB_LOG_DIR="$LOG_ROOT/$JOB_NAME"
                JOB_STATE_DIR="$STATE_ROOT/jobs"
                LOCK_ROOT="$STATE_ROOT/locks"
                LOCK_DIR="$LOCK_ROOT/$JOB_NAME.lock"
                STATE_FILE="$JOB_STATE_DIR/$JOB_NAME.json"
                AUDIT_FILE="$JOB_LOG_DIR/audit.jsonl"

                mkdir -p "$JOB_LOG_DIR" "$JOB_STATE_DIR" "$LOCK_ROOT"
                chmod 700 "$LOG_ROOT" "$JOB_LOG_DIR" "$STATE_ROOT" "$JOB_STATE_DIR" "$LOCK_ROOT" 2>/dev/null || true

                RUN_STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
                RUN_LOG="$JOB_LOG_DIR/run-$RUN_STAMP.log"
                : >"$RUN_LOG"

                sanitize_stream() {
                  sed -E \
                    -e 's/(aws_secret_access_key[[:space:]]*=[[:space:]]*).*/\1[REDACTED]/I' \
                    -e 's/(AWS_SECRET_ACCESS_KEY[[:space:]]*=[[:space:]]*).*/\1[REDACTED]/I' \
                    -e 's/(SecretAccessKey[[:space:]]*[:=][[:space:]]*).*/\1[REDACTED]/I'
                }

                audit() {
                  local event="$1"
                  local status="$2"
                  local message="$3"
                  local data="''${4:-{}}"

                  jq -nc \
                    --arg timestamp "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
                    --arg job "$JOB_NAME" \
                    --arg profile "$PROFILE" \
                    --arg event "$event" \
                    --arg status "$status" \
                    --arg message "$message" \
                    --arg dataRaw "$data" \
                    '{
                      timestamp: $timestamp,
                      job: $job,
                      profile: $profile,
                      event: $event,
                      status: $status,
                      message: $message,
                      data: (
                        ($dataRaw | fromjson?)
                        // (
                          if ($dataRaw | length) == 0
                          then {}
                          else { raw: $dataRaw, encoding: "raw-string" }
                          end
                        )
                      )
                    }' >>"$AUDIT_FILE"
                }

                prune_old_logs() {
                  if [[ "$RETENTION_DAYS" -lt 1 ]]; then
                    return
                  fi
                  find "$JOB_LOG_DIR" -type f -name 'run-*.log' -mtime +"$RETENTION_DAYS" -delete || true
                }

                if ! mkdir "$LOCK_DIR" 2>/dev/null; then
                  audit "skipped_locked" "info" "A previous invocation is still running."
                  exit 0
                fi

                TMP_DIR="$(mktemp -d "$JOB_STATE_DIR/tmp.$JOB_NAME.XXXXXX")"
                cleanup() {
                  rm -rf "$LOCK_DIR" "$TMP_DIR"
                }
                trap cleanup EXIT

                DUE_INFO_FILE="$TMP_DIR/due-info.json"
                if ! python3 - "$STATE_FILE" "$ANCHOR_DATE" "$CADENCE_UNIT" "$CADENCE_VALUE" >"$DUE_INFO_FILE" <<'PY'
        import calendar
        import datetime
        import json
        import os
        import sys

        state_file, anchor_date, cadence_unit, cadence_value = sys.argv[1:]
        cadence_value = int(cadence_value)
        today = datetime.date.today()

        def add_months(date_obj, months):
            month_index = date_obj.month - 1 + months
            year = date_obj.year + (month_index // 12)
            month = month_index % 12 + 1
            day = min(date_obj.day, calendar.monthrange(year, month)[1])
            return datetime.date(year, month, day)

        base_source = "anchor"
        base_date_str = anchor_date

        if os.path.exists(state_file):
            try:
                with open(state_file, "r", encoding="utf-8") as fp:
                    state = json.load(fp)
                previous = state.get("lastSuccessfulRotationDate")
                if previous:
                    base_date_str = previous
                    base_source = "state"
            except Exception:
                pass

        base_date = datetime.date.fromisoformat(base_date_str)
        if cadence_unit == "days":
            next_due = base_date + datetime.timedelta(days=cadence_value)
        else:
            next_due = add_months(base_date, cadence_value)

        result = {
            "today": today.isoformat(),
            "baseDate": base_date.isoformat(),
            "baseSource": base_source,
            "cadenceUnit": cadence_unit,
            "cadenceValue": cadence_value,
            "nextDueDate": next_due.isoformat(),
            "due": today >= next_due,
        }
        print(json.dumps(result))
        PY
                then
                  audit "schedule_error" "error" "Failed to evaluate rotation cadence."
                  printf '%s\n' "Failed to evaluate rotation cadence for $PROFILE." >>"$RUN_LOG"
                  exit 1
                fi

                audit "run_invoked" "info" "Rotation check started." "$(cat "$DUE_INFO_FILE")"

                if [[ "$(jq -r '.due' "$DUE_INFO_FILE")" != "true" ]]; then
                  next_due="$(jq -r '.nextDueDate' "$DUE_INFO_FILE")"
                  printf '%s\n' "Not due. Next due date: $next_due" >>"$RUN_LOG"
                  audit "skipped_not_due" "info" "Rotation skipped because cadence is not yet due." "$(cat "$DUE_INFO_FILE")"
                  prune_old_logs
                  exit 0
                fi

                audit "run_started" "info" "Rotation is due and execution is starting." "$(cat "$DUE_INFO_FILE")"

                PRE_KEYS_FILE="$TMP_DIR/pre-keys.json"
                if aws --profile "$PROFILE" iam list-access-keys --output json >"$PRE_KEYS_FILE" 2>>"$RUN_LOG"; then
                  audit "pre_snapshot_captured" "info" "Captured pre-rotation key snapshot."
                else
                  printf '{}' >"$PRE_KEYS_FILE"
                  audit "pre_snapshot_failed" "warning" "Failed to capture pre-rotation key snapshot."
                fi

                ROTATE_OUTPUT_FILE="$TMP_DIR/rotate-output.log"
                set +e
                aws-rotate-key -profile "$PROFILE" -y 2>&1 | sanitize_stream | tee -a "$RUN_LOG" >"$ROTATE_OUTPUT_FILE"
                rotate_exit=''${PIPESTATUS[0]}
                set -e

                while IFS= read -r line; do
                  if [[ "$line" =~ ^Created[[:space:]]access[[:space:]]key:[[:space:]]([A-Z0-9]+)$ ]]; then
                    access_key_id="''${BASH_REMATCH[1]}"
                    audit "key_created" "info" "Access key created." "$(jq -nc --arg accessKeyId "$access_key_id" '{accessKeyId: $accessKeyId}')"
                  elif [[ "$line" =~ ^Deleted[[:space:]]old[[:space:]]access[[:space:]]key:[[:space:]]([A-Z0-9]+)$ ]]; then
                    access_key_id="''${BASH_REMATCH[1]}"
                    audit "key_deleted" "info" "Old access key deleted." "$(jq -nc --arg accessKeyId "$access_key_id" '{accessKeyId: $accessKeyId}')"
                  elif [[ "$line" =~ ^Deleted[[:space:]]access[[:space:]]key:[[:space:]]([A-Z0-9]+)$ ]]; then
                    access_key_id="''${BASH_REMATCH[1]}"
                    audit "key_deleted" "info" "Access key deleted." "$(jq -nc --arg accessKeyId "$access_key_id" '{accessKeyId: $accessKeyId}')"
                  elif [[ "$line" =~ ^Deactivated[[:space:]]old[[:space:]]access[[:space:]]key:[[:space:]]([A-Z0-9]+)$ ]]; then
                    access_key_id="''${BASH_REMATCH[1]}"
                    audit "key_deactivated" "info" "Old access key deactivated." "$(jq -nc --arg accessKeyId "$access_key_id" '{accessKeyId: $accessKeyId}')"
                  fi
                done <"$ROTATE_OUTPUT_FILE"

                if [[ "$rotate_exit" -ne 0 ]]; then
                  audit "run_failed" "error" "aws-rotate-key exited with an error." "$(jq -nc --arg exitCode "$rotate_exit" '{exitCode: (($exitCode | tonumber?) // $exitCode)}')"
                  prune_old_logs
                  exit "$rotate_exit"
                fi

                POST_KEYS_FILE="$TMP_DIR/post-keys.json"
                if aws --profile "$PROFILE" iam list-access-keys --output json >"$POST_KEYS_FILE" 2>>"$RUN_LOG"; then
                  audit "post_snapshot_captured" "info" "Captured post-rotation key snapshot."
                else
                  printf '{}' >"$POST_KEYS_FILE"
                  audit "post_snapshot_failed" "warning" "Failed to capture post-rotation key snapshot."
                fi

                SNAPSHOT_EVENTS_FILE="$TMP_DIR/snapshot-events.jsonl"
                python3 - "$PRE_KEYS_FILE" "$POST_KEYS_FILE" >"$SNAPSHOT_EVENTS_FILE" <<'PY'
        import json
        import sys

        pre_path, post_path = sys.argv[1:]

        def load(path):
            try:
                with open(path, "r", encoding="utf-8") as fp:
                    payload = json.load(fp)
                return {entry["AccessKeyId"]: entry for entry in payload.get("AccessKeyMetadata", [])}
            except Exception:
                return {}

        pre = load(pre_path)
        post = load(post_path)

        for key_id, key_data in post.items():
            if key_id not in pre:
                print(json.dumps({
                    "event": "key_created_snapshot",
                    "accessKeyId": key_id,
                    "status": key_data.get("Status"),
                    "createDate": key_data.get("CreateDate"),
                }))

        for key_id in pre:
            if key_id not in post:
                print(json.dumps({
                    "event": "key_deleted_snapshot",
                    "accessKeyId": key_id,
                }))

        for key_id, key_data in post.items():
            if key_id in pre:
                previous_status = pre[key_id].get("Status")
                current_status = key_data.get("Status")
                if previous_status != current_status:
                    print(json.dumps({
                        "event": "key_status_changed_snapshot",
                        "accessKeyId": key_id,
                        "oldStatus": previous_status,
                        "newStatus": current_status,
                    }))
        PY

                while IFS= read -r event_json; do
                  [[ -z "$event_json" ]] && continue
                  event_name="$(jq -r '.event' <<<"$event_json")"
                  audit "$event_name" "info" "Snapshot-derived key lifecycle event." "$event_json"
                done <"$SNAPSHOT_EVENTS_FILE"

                last_success_date="$(date +%Y-%m-%d)"
                last_success_timestamp="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
                state_tmp="$TMP_DIR/state.json"
                jq -nc \
                  --arg job "$JOB_NAME" \
                  --arg profile "$PROFILE" \
                  --arg lastSuccessfulRotationDate "$last_success_date" \
                  --arg lastSuccessfulRotationAt "$last_success_timestamp" \
                  --arg cadenceUnit "$CADENCE_UNIT" \
                  --arg cadenceValue "$CADENCE_VALUE" \
                  '{
                    job: $job,
                    profile: $profile,
                    lastSuccessfulRotationDate: $lastSuccessfulRotationDate,
                    lastSuccessfulRotationAt: $lastSuccessfulRotationAt,
                    cadence: {
                      unit: $cadenceUnit,
                      value: (($cadenceValue | tonumber?) // $cadenceValue)
                    }
                  }' >"$state_tmp"
                mv "$state_tmp" "$STATE_FILE"

                audit "run_finished" "info" "Rotation completed successfully." "$(jq -nc --arg stateFile "$STATE_FILE" '{stateFile: $stateFile}')"
                prune_old_logs
      '';
    };

  scripts = mapAttrs mkJobScript enabledJobs;

  mkLaunchdAgent =
    name: job:
    let
      schedule =
        if job.launchd.startCalendarInterval != null then
          job.launchd.startCalendarInterval
        else
          mkDailyCalendar job.trigger.time;
    in
    nameValuePair "aws-key-rotation-${name}" {
      enable = true;
      config = {
        Label = "com.${config.home.username}.aws-key-rotation.${name}";
        ProgramArguments = [ "${scripts.${name}}/bin/aws-key-rotation-${name}" ];
        ProcessType = "Background";
        RunAtLoad = job.trigger.runAtLoad;
        StartCalendarInterval = schedule;
        StandardOutPath = "${cfg.auditLogPath}/${name}/launchd-stdout.log";
        StandardErrorPath = "${cfg.auditLogPath}/${name}/launchd-stderr.log";
      };
    };

  jobAssertions = flatten (
    mapAttrsToList (
      name: job:
      let
        cadenceCount =
          (if job.rotation.every.days != null then 1 else 0)
          + (if job.rotation.every.months != null then 1 else 0);
      in
      [
        {
          assertion = !(cfg.enable && job.enable) || cadenceCount == 1;
          message = "services.awsKeyRotation.jobs.${name}: set exactly one of rotation.every.days or rotation.every.months.";
        }
        {
          assertion =
            !(cfg.enable && job.enable)
            || (builtins.match "^[0-9]{4}-[0-9]{2}-[0-9]{2}$" job.rotation.anchorDate != null);
          message = "services.awsKeyRotation.jobs.${name}.rotation.anchorDate must be in YYYY-MM-DD format.";
        }
        {
          assertion =
            !(cfg.enable && job.enable) || job.rotation.every.days == null || job.rotation.every.days > 0;
          message = "services.awsKeyRotation.jobs.${name}.rotation.every.days must be greater than zero when set.";
        }
        {
          assertion =
            !(cfg.enable && job.enable) || job.rotation.every.months == null || job.rotation.every.months > 0;
          message = "services.awsKeyRotation.jobs.${name}.rotation.every.months must be greater than zero when set.";
        }
        {
          assertion =
            !(cfg.enable && job.enable)
            || job.launchd.startCalendarInterval != null
            || builtins.match "^([01][0-9]|2[0-3]):([0-5][0-9])$" job.trigger.time != null;
          message = "services.awsKeyRotation.jobs.${name}.trigger.time must be HH:MM (24-hour clock), or set launchd.startCalendarInterval.";
        }
      ]
    ) cfg.jobs
  );
in
{
  options.services.awsKeyRotation = {
    enable = mkEnableOption "declarative per-profile AWS key rotation jobs";

    logRetentionDays = mkOption {
      type = types.ints.positive;
      default = 90;
      description = "How many days to keep per-run logs before pruning.";
    };

    auditLogPath = mkOption {
      type = types.str;
      default = "${config.home.homeDirectory}/Library/Logs/aws-key-rotation";
      defaultText = ''"''${config.home.homeDirectory}/Library/Logs/aws-key-rotation"'';
      description = "Base directory for job logs and audit files.";
    };

    jobs = mkOption {
      default = { };
      type = types.attrsOf (
        types.submodule {
          options = {
            enable = mkEnableOption "AWS key rotation job" // {
              default = true;
            };

            profile = mkOption {
              type = types.str;
              description = "AWS profile passed to `aws-rotate-key -profile`.";
            };

            rotation = {
              every = {
                days = mkOption {
                  type = types.nullOr types.int;
                  default = null;
                  example = 90;
                  description = "Rotate every N days.";
                };

                months = mkOption {
                  type = types.nullOr types.int;
                  default = null;
                  example = 3;
                  description = "Rotate every N months.";
                };
              };

              anchorDate = mkOption {
                type = types.str;
                example = "2026-01-12";
                description = ''
                  Date of the last known successful rotation in `YYYY-MM-DD` format.
                  When no runtime state exists yet, cadence is computed from this date.
                '';
              };
            };

            trigger = {
              time = mkOption {
                type = types.strMatching "^([01][0-9]|2[0-3]):([0-5][0-9])$";
                default = "03:00";
                example = "01:30";
                description = "Daily local-time trigger in `HH:MM` format.";
              };

              runAtLoad = mkOption {
                type = types.bool;
                default = true;
                description = "Run once when the launchd agent is loaded (safe because due-check guards execution).";
              };
            };

            launchd.startCalendarInterval = mkOption {
              type = types.nullOr (
                types.either calendarIntervalEntryType (types.nonEmptyListOf calendarIntervalEntryType)
              );
              default = null;
              description = ''
                Expert override for launchd `StartCalendarInterval`. When set, this is used instead
                of deriving a daily trigger from `trigger.time`.
              '';
            };
          };
        }
      );
      description = "Per-profile AWS key rotation jobs.";
    };
  };

  config = mkIf cfg.enable {
    assertions = jobAssertions;

    home.packages = with pkgs; [
      aws-rotate-key
      awscli2
      jq
      python3
    ];

    launchd.agents = mapAttrs' mkLaunchdAgent enabledJobs;

    home.activation.awsKeyRotationDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] (
      ''
        $DRY_RUN_CMD mkdir -p ${escapeShellArg cfg.auditLogPath}
        $DRY_RUN_CMD mkdir -p ${escapeShellArg stateRoot}
      ''
      + optionalString (enabledJobs != { }) (
        "\n"
        + concatMapStringsSep "\n" (
          name: "$DRY_RUN_CMD mkdir -p ${escapeShellArg "${cfg.auditLogPath}/${name}"}"
        ) (builtins.attrNames enabledJobs)
      )
      + "\n"
    );
  };
}
