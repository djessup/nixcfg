# Declarative Per-Profile AWS Key Rotation Jobs with Audit Logging

This ExecPlan is a living document. The sections `Progress`, `Surprises & Discoveries`, `Decision Log`, and `Outcomes & Retrospective` must be kept up to date as work proceeds.

This plan must be maintained in accordance with `/Users/jessup/.codex/PLANS.md`, which defines the execution-plan format and update rules for this environment.

## Purpose / Big Picture

After this change, a user will declare one or more AWS profiles in Nix, and each profile will get its own launchd job that checks whether rotation is due and runs `aws-rotate-key -profile <profile> -y` only when due. The wrapper will not manage `~/.aws/credentials`; it will rely on `aws-rotate-key` for all key lifecycle and credentials-file updates. The system will produce detailed audit logs with full access key ids and explicit lifecycle events while guaranteeing that no secret keys are logged.

The user-visible outcome is a reproducible home-manager configuration where each profile has an independent rotation cadence (`every N days` or `every N months`) and start alignment, missed runs are caught via `RunAtLoad = true` plus due checks, and operators can inspect logs/state to prove exactly when keys were created, deactivated, deleted, or failed.

## Progress

- [x] (2026-03-03 11:16Z) Confirmed upstream `aws-rotate-key` behavior from source and README, including credentials-file writes and IAM key lifecycle operations.
- [x] (2026-03-03 11:16Z) Confirmed nixpkgs package source and version (`Fullscreen/aws-rotate-key` `1.2.0`), and gathered existing repository patterns for home-manager `launchd.agents`.
- [x] (2026-03-03 11:16Z) Captured product decisions with stakeholder: one job per profile, default tool behavior (no `-d` override), no MFA scope, `RunAtLoad = true` with strict due guard, full key ids allowed in logs, secret keys forbidden in logs.
- [x] (2026-03-03 11:35Z) Extended schedule design to support `every N days` in addition to `every N months`, based on prevailing Nix module idioms for frequency + timer/launchd triggers.
- [x] (2026-03-03 11:52Z) Implemented reusable Home Manager module at `user/settings/aws-key-rotation.nix` with options, due-check logic, lock handling, launchd generation, log retention, and structured audit events.
- [x] (2026-03-03 12:10Z) Reworked `trigger.time` parsing to use nixpkgs-preferred decimal conversion (`lib.strings.toIntBase10`) and strict `HH:MM` option typing to avoid leading-zero parse ambiguity.
- [ ] (2026-03-03 11:52Z) Import module from `user/default.nix` and add concrete job declarations in active user config (completed: module imported; remaining: choose and set real profile anchors/cadence in enabled config).
- [x] (2026-03-03 11:52Z) Added operational documentation in `docs/aws-key-rotation.md` and linked it from `README.md`.
- [ ] (2026-03-03 11:53Z) Validate with `darwin-rebuild` and manual `launchctl kickstart` checks for due and not-due paths (completed: `darwin-rebuild build --flake path:/private/etc/nix-darwin#jessup-m3`; remaining: `darwin-rebuild switch` and manual kickstart validation).

## Surprises & Discoveries

- Observation: The packaged upstream in nixpkgs is `Fullscreen/aws-rotate-key`, not the older `stefansundin/aws-rotate-key` namespace, and the current packaged version is `1.2.0`.
  Evidence: `pkgs/by-name/aw/aws-rotate-key/package.nix` in nixpkgs sets `owner = "Fullscreen"` and `version = "1.2.0"`.

- Observation: `aws-rotate-key` already performs the critical logic this feature initially proposed to duplicate, including rewriting credentials, handling the two-key IAM limit, and deactivating/deleting old keys.
  Evidence: In upstream `main.go`, the tool calls `CreateAccessKey`, replaces keys in the credentials file, writes file mode `0600`, and then calls `UpdateAccessKey` (inactive) or `DeleteAccessKey`.

- Observation: `RunAtLoad` launches on agent load events, not only on missed calendar windows.
  Evidence: `launchd.plist(5)` documents `RunAtLoad` as a load-time launch, so an internal due check is required to avoid premature rotations.

- Observation: Home Manager's Darwin interval helper is intentionally coarse (`hourly`, `daily`, `weekly`, `monthly`, `semiannually`, `annually`), so a requirement like "every 17 days" cannot be represented directly with only `mkCalendarInterval`.
  Evidence: `home-manager/modules/lib/darwin.nix` defines a fixed interval set in `assertInterval` and `mkCalendarInterval`.

- Observation: `darwin-rebuild ... --flake .#...` in this workspace evaluates through a git flake input and ignores untracked files, which initially failed evaluation for the new module file.
  Evidence: Build failed with `No such file or directory` for `user/settings/aws-key-rotation.nix` until the flake reference switched to `path:/private/etc/nix-darwin#jessup-m3`.

- Observation: `lib.toInt` is intentionally ambiguous for zero-padded numeric strings, while `lib.strings.toIntBase10` explicitly supports zero-padded decimal parsing.
  Evidence: `nixpkgs/lib/strings.nix` documents the ambiguity in `toInt` and recommends `toIntBase10`; local eval confirmed `toInt "03"` fails while `toIntBase10 "03"` returns `3`.

## Decision Log

- Decision: Model rotation as one launchd job per profile, each with independent schedule and state.
  Rationale: The user explicitly wants per-profile control and independent schedules; isolating jobs reduces blast radius and simplifies operations.
  Date/Author: 2026-03-03 / Codex + user

- Decision: The wrapper must never edit `~/.aws/credentials` directly.
  Rationale: `aws-rotate-key` already owns credentials mutation and rollback-like cleanup behavior; duplicating this logic increases risk.
  Date/Author: 2026-03-03 / Codex + user

- Decision: Keep `aws-rotate-key` default cleanup behavior and do not pass `-d` globally.
  Rationale: User requirement is to let the tool decide and not second-guess key handling.
  Date/Author: 2026-03-03 / Codex + user

- Decision: Use `RunAtLoad = true` and enforce due-guard in wrapper.
  Rationale: This catches missed windows while remaining safe and idempotent.
  Date/Author: 2026-03-03 / Codex + user

- Decision: Audit logs include full access key ids but must never include secret keys.
  Rationale: Full key ids are required for traceability; secret material must never appear in logs.
  Date/Author: 2026-03-03 / Codex + user

- Decision: Replace `periodMonths` with a cadence schema supporting exactly one of `rotation.every.days` or `rotation.every.months`, plus `rotation.anchorDate`.
  Rationale: The feature must support day-level granularity while preserving intuitive month-based recurrence aligned to a known start date.
  Date/Author: 2026-03-03 / Codex + user

- Decision: Keep launchd as a trigger mechanism (daily by default), with cadence due-check logic as the source of truth.
  Rationale: launchd alone cannot express all anchored interval semantics (for example every N days from a date); wrapper logic can.
  Date/Author: 2026-03-03 / Codex + user

- Decision: Parse `HH:MM` values with strict regex plus `lib.strings.toIntBase10`, and type `trigger.time` as a `strMatching` clock value.
  Rationale: This follows nixpkgs idioms and avoids fragile ad-hoc conversion behavior around leading zeros.
  Date/Author: 2026-03-03 / Codex

## Outcomes & Retrospective

Implementation now exists for the reusable module, launchd job generation, due-check cadence engine, and audit logging/documentation. A `darwin-rebuild build` evaluation has passed against the path-based flake reference. Remaining work is rollout wiring of real profile values (anchor/cadence) in active config and runtime validation via `darwin-rebuild switch` plus manual `launchctl kickstart` checks for both due and not-due paths. The biggest ongoing correctness risk remains cadence alignment mistakes from incorrect anchor inputs; recovery is documented through explicit state reset and re-anchoring behavior.

## Context and Orientation

This repository is a nix-darwin flake with home-manager modules imported through `user/default.nix`. Existing launchd agent configuration patterns are in `user/settings/ssh.nix` under `launchd.agents.<name>.config`. User package installation already includes both `aws-rotate-key` and `awscli2` in `user/settings/packages.nix`, so runtime dependencies exist today.

The new module will live at `user/settings/aws-key-rotation.nix` and then be imported from `user/default.nix`. It will expose a reusable option surface under `services.awsKeyRotation` so jobs can be declared once in Nix rather than hand-writing scripts/plists.

Each job will own:

- One generated wrapper executable in the Nix store.
- One generated launchd agent (`launchd.agents.<label>`).
- One state file in the user state directory (for due alignment).
- One log directory in `~/Library/Logs/aws-key-rotation/<job>`.

The wrapper is responsible for due checks, lock management, running `aws-rotate-key`, collecting IAM snapshots for audit diffs, writing structured audit events, and pruning retention.

## Plan of Work

Milestone 1 creates a reusable module and option schema. Implement `user/settings/aws-key-rotation.nix` with `services.awsKeyRotation.enable`, shared logging controls, and per-job declarations. Per-job configuration includes `enable`, `profile`, cadence (`rotation.every.days` or `rotation.every.months`), `rotation.anchorDate`, `trigger.time`, and `trigger.runAtLoad`. `rotation.anchorDate` is a local calendar date (`YYYY-MM-DD`) representing when the current key was last rotated; the first due date is computed by applying cadence to this anchor when no success state exists.

Milestone 2 implements wrapper generation. For each enabled job, create a shell application that runs in strict mode, uses a lock directory to prevent overlap, evaluates due status, and exits successfully when not due. On due runs, capture pre/post IAM key metadata snapshots using `aws iam list-access-keys` under that profile, execute `aws-rotate-key -profile <profile> -y`, and parse both snapshots plus tool output into audit events. The wrapper never reads or writes credentials directly.

Milestone 3 wires launchd scheduling and retention. Use `StartCalendarInterval` to run daily at `trigger.time` local time by default (with optional expert override for `launchd.startCalendarInterval`); this keeps the scheduler simple while due logic enforces the actual cadence. Set `RunAtLoad` from `trigger.runAtLoad` (default true). Add retention pruning for run logs and optional compaction boundaries for audit files without deleting current state.

Milestone 4 adds documentation and operational verification. Document how to set anchor dates, interpret due calculations for day-based and month-based cadence, manually trigger jobs, inspect status/logs, and recover from incorrect anchor/state by editing/removing state files. Include examples for two profiles with different cadence values and anchors.

## Concrete Steps

1. Create `user/settings/aws-key-rotation.nix` with module options and generated jobs.
   Run from `/private/etc/nix-darwin`:
     `nixfmt user/settings/aws-key-rotation.nix`
   Expected result:
     Formatting succeeds without syntax errors.

2. Import the module in `user/default.nix` and add job definitions in a user settings module.
   Run from `/private/etc/nix-darwin`:
     `rg -n "aws-key-rotation|services.awsKeyRotation|launchd.agents" user`
   Expected result:
     New option wiring and per-job declarations are discoverable in repository search.

3. Build the darwin configuration to validate module evaluation.
   Run from `/private/etc/nix-darwin`:
     `darwin-rebuild build --flake .#jessup-m3`
   Expected result:
     Build succeeds and outputs a new system derivation without module evaluation errors.

4. Apply config and verify launchd registration.
   Run from `/private/etc/nix-darwin`:
     `darwin-rebuild switch --flake .#jessup-m3`
     `launchctl print gui/$(id -u) | rg "aws-key-rotation|com\\.jessup\\.aws-key-rotation"`
   Expected result:
     Each configured profile has a loaded launchd agent label and a resolved program path.

5. Validate not-due behavior and due behavior.
   Run from `/private/etc/nix-darwin`:
     `launchctl kickstart -k gui/$(id -u)/com.jessup.aws-key-rotation.<job-name>`
     `tail -n 50 ~/Library/Logs/aws-key-rotation/<job-name>/audit.jsonl`
   Expected result:
     Not-due runs log `skipped_not_due`; due runs log `run_started`, lifecycle events (`created`, `deleted`, `status_changed`), and `run_finished` with success.

## Validation and Acceptance

The feature is accepted when a profile job can be declared with either `rotation.every.months = 3` or `rotation.every.days = N` plus `rotation.anchorDate`, such that the first due run is aligned to the desired date and subsequent runs follow configured cadence from the last successful rotation date. Manual kickstart on a non-due day must not rotate and must log a skip event. Manual kickstart on or after due must execute `aws-rotate-key` once and record key lifecycle events with full key ids.

A failed `aws-rotate-key` execution must return non-zero, emit an error audit event containing diagnostics, and avoid updating last-success state. Logs must show no secret key material. The credentials file must only be modified by `aws-rotate-key`, never by wrapper logic.

## Idempotence and Recovery

Idempotence is enforced by the due-check plus lock. Re-running `launchctl kickstart` multiple times on the same day when not due remains a no-op with a logged skip. Concurrent invocations are prevented by a lock directory; a second invocation logs `skipped_locked` and exits cleanly.

Recovery from misconfiguration is safe and explicit. If an anchor date or cadence is wrong, the operator updates job configuration and rebuilds. If runtime state needs reset, remove the job state file and rerun; the wrapper will re-anchor from `rotation.anchorDate`. If a rotation attempt fails, state is unchanged so the next run can retry naturally.

## Artifacts and Notes

Reference findings that shaped this plan:

  `aws-rotate-key` lifecycle sequence from upstream source:
  - Create access key.
  - Rewrite credentials file.
  - Deactivate old key by default (or delete with `-d`).

  launchd scheduling behavior from local man page:
  - `RunAtLoad` launches when the agent is loaded.
  - `StartCalendarInterval` missed while asleep is coalesced on wake.

These findings justify due-guard logic and avoiding duplicate credentials management.

## Interfaces and Dependencies

In `user/settings/aws-key-rotation.nix`, define module options under `services.awsKeyRotation`:

  `enable` (bool, default false) enables the subsystem.
  `logRetentionDays` (int, default 90) controls pruning for run logs.
  `auditLogPath` (string, default `~/Library/Logs/aws-key-rotation`) sets base log directory.
  `jobs` (attrs of submodule) defines per-profile jobs.

Each `jobs.<name>` submodule must define:

  `enable` (bool, default true).
  `profile` (string, required), passed to `aws-rotate-key -profile`.
  `rotation.every.days` (null or int > 0, default null), day-based recurrence cadence.
  `rotation.every.months` (null or int > 0, default null), month-based recurrence cadence.
  `rotation.anchorDate` (string `YYYY-MM-DD`, required), initial anchor when no success state exists.
  `trigger.time` (string `HH:MM`, default `"03:00"`), daily local-time check.
  `trigger.runAtLoad` (bool, default true), passed to launchd.
  `launchd.startCalendarInterval` (null or launchd calendar attrset/list, default null), expert override for trigger schedule.

Validation rules:

  Exactly one of `rotation.every.days` and `rotation.every.months` must be set.
  `rotation.anchorDate` must parse as a valid local calendar date.

Example configuration (showing conventional `enable` flags):

  services.awsKeyRotation = {
    enable = true;
    jobs.ausgovstg = {
      enable = true;
      profile = "ausgovstg";
      rotation = {
        every.months = 3;
        anchorDate = "2026-01-12";
      };
      trigger = {
        time = "03:00";
        runAtLoad = true;
      };
    };
  };

Runtime dependencies for wrapper scripts:

  `aws-rotate-key`, `awscli2`, `jq`, and `python3` from nixpkgs. Python is used only for robust calendar-month arithmetic and due-check evaluation; IAM mutation remains exclusively in `aws-rotate-key`.

Wrapper outputs per job:

  `~/Library/Logs/aws-key-rotation/<job>/run-<timestamp>.log` for sanitized command output.
  `~/Library/Logs/aws-key-rotation/<job>/audit.jsonl` append-only structured events.
  `~/.local/state/aws-key-rotation/<job>.json` containing `lastSuccessfulRotationOn` and last-run metadata.

Revision note (2026-03-03): Replaced an earlier draft specification with this ExecPlan because stakeholder direction changed to wrapper-orchestration around `aws-rotate-key` rather than reimplementing credential rotation mechanics.
Revision note (2026-03-03): Updated schedule input model to support both day-based and month-based cadence, and made `enable` flag usage explicit at module and per-job levels following common Nix idiom.
Revision note (2026-03-03): Implemented module and docs in repository, validated with `darwin-rebuild build --flake path:/private/etc/nix-darwin#jessup-m3`, and updated progress to reflect remaining rollout/runtime validation steps.
Revision note (2026-03-03): Updated time parsing to use `lib.strings.toIntBase10` and strict `HH:MM` option typing after validation against upstream nixpkgs/home-manager parsing patterns.
