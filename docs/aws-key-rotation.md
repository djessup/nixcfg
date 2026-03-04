# AWS Key Rotation Jobs

This repository includes a Home Manager module for declarative AWS access key
rotation using `aws-rotate-key`.

The module intentionally delegates key lifecycle and credentials-file handling
to `aws-rotate-key`. Wrapper logic only handles scheduling, due checks, lock
protection, and audit logging.

## Configuration

Add or edit jobs under `services.awsKeyRotation` in your Home Manager config.

```nix
services.awsKeyRotation = {
  enable = true;
  logRetentionDays = 90;

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

  jobs.ausgovprd = {
    enable = true;
    profile = "ausgovprd";
    rotation = {
      every.days = 60;
      anchorDate = "2026-01-20";
    };
    trigger = {
      time = "04:00";
      runAtLoad = true;
    };
  };
};
```

## Scheduling Model

- Launchd triggers the wrapper (daily by default at `trigger.time`).
- The wrapper evaluates whether rotation is due.
- Rotation runs only when due.
- If not due, it logs a skip event and exits successfully.

The first due run is computed from `rotation.anchorDate`. After a successful
rotation, the next due run is computed from that success date.

## Logs and State

Per job files:

- Audit events:
  - `~/Library/Logs/aws-key-rotation/<job>/audit.jsonl`
- Run logs:
  - `~/Library/Logs/aws-key-rotation/<job>/run-<timestamp>.log`
- launchd stdio:
  - `~/Library/Logs/aws-key-rotation/<job>/launchd-stdout.log`
  - `~/Library/Logs/aws-key-rotation/<job>/launchd-stderr.log`
- Runtime state:
  - `~/.local/state/aws-key-rotation/jobs/<job>.json`

The audit log includes full access key ids by design. Secret keys are never
logged.

## Manual Trigger

After `darwin-rebuild switch --flake .#jessup-m3`, use:

```sh
launchctl kickstart -k gui/$(id -u)/com.$USER.aws-key-rotation.<job>
```

Example:

```sh
launchctl kickstart -k gui/$(id -u)/com.$USER.aws-key-rotation.ausgovstg
```

Inspect recent audit events:

```sh
tail -n 50 ~/Library/Logs/aws-key-rotation/ausgovstg/audit.jsonl
```

## Recovery

- Wrong anchor date or cadence:
  - Update configuration and rebuild.
- Need to reset scheduling state:
  - Remove `~/.local/state/aws-key-rotation/jobs/<job>.json`.
  - Trigger job again; wrapper re-anchors from `rotation.anchorDate`.
