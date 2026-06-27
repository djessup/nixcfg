---
name: nix-darwin-sops-env
description: 'Diagnose and fix sops-nix secrets not loading into shell environment variables on nix-darwin. Use when: secrets are mounted by sops-nix but env vars are unset, environment.shellInit not working for secrets, SOPS secrets loaded but not exported, env vars missing after nixswitch, secrets in /run/secrets not exported to shell.'
argument-hint: 'Describe which secrets/env vars are not loading'
---

# nix-darwin: Wire sops-nix Secrets into Shell Env Vars

## Root Cause (Know This First)

`environment.shellInit` in nix-darwin **does not support dynamic shell logic**. It is written into the `set-environment` script in the Nix store, which only handles static `export KEY=value` assignments. Shell logic like `if [ -r ... ]; then ... fi` is silently ignored — no error, no warning.

The correct place for dynamic secret-reading is **`programs.zsh.initContent`** (or `initExtra` in older home-manager), which injects directly into `~/.zshrc`.

---

## Step 1 — Verify Secrets Are Actually Mounted

```bash
ls -la /run/secrets/          # Should be a symlink → /run/secrets.d/<n>
ls -la /run/secrets.d/        # Should have a numbered dir
cat /run/secrets/<secret-name>  # Should print the secret value
```

If `/run/secrets` doesn't exist or files aren't readable, the problem is in sops-nix configuration or activation — not in the shell init. Check `secrets.nix` for correct `owner` and `mode`.

## Step 2 — Confirm shellInit Is the Problem

```bash
# Check if your secret-reading code made it into the generated shell files
grep -r "if \[ -r.*secrets\|YOUR_VAR" /etc/zshrc /etc/bashrc /etc/zshenv /etc/zprofile

# Check the set-environment script (will only have static exports)
grep "YOUR_VAR\|secrets" /nix/store/*-set-environment 2>/dev/null
```

If your code doesn't appear in `/etc/zshrc` but secrets are readable, the fix is Step 3.

## Step 3 — Move Secret Reads to `programs.zsh.initContent`

In your `zsh.nix` (or `home.nix`), use `initContent` with the stable `/run/secrets/` symlink:

```nix
programs.zsh.initContent = ''
  # Load secrets from SOPS-mounted runtime files
  if [[ -r /run/secrets/my-secret-name ]]; then
    export MY_ENV_VAR="$(</run/secrets/my-secret-name)"
  fi
'';
```

**Key points:**
- Use `/run/secrets/<name>` (the symlink), not `/run/secrets.d/<n>/<name>` (the versioned path)
- Use `[[ -r ... ]]` not `[ -r ... ]` in zsh context
- Use `$(</path/to/file)` (faster than `$(cat ...)`) for reading file contents
- The secret name matches the key in `sops.secrets` in your `secrets.nix`

## Step 4 — Clean Up Dead Code

Remove the non-working code from `environment.shellInit`:

```nix
# REMOVE this pattern from environment.nix — it does nothing:
shellInit = ''
  if [ -r "${config.sops.secrets."my-secret".path}" ]; then
    export MY_VAR="$(cat "${config.sops.secrets."my-secret".path}")"
  fi
'';
```

Also check `sessionVariables` for any hardcoded plaintext secrets that should come from SOPS:

```nix
# REMOVE hardcoded secrets like this:
sessionVariables = {
  MY_TOKEN = "hardcoded-value";  # ← replace with initContent file read
};
```

Remove `config` from the function args if it's no longer used:
```nix
# Before: { pkgs, user, config, ... }:
# After:  { pkgs, user, ... }:
```

## Step 5 — Rebuild and Verify

```bash
nixswitch   # or: sudo darwin-rebuild switch --flake /etc/nix-darwin/.#

# In a NEW shell session:
echo "MY_VAR=${MY_VAR:-UNSET}"
```

---

## Reference: Secret Path Conventions

| Path | Notes |
|------|-------|
| `/run/secrets/<name>` | **Use this.** Stable symlink, always points to current generation |
| `/run/secrets.d/<n>/<name>` | Versioned path. Avoid — breaks across switches |
| `config.sops.secrets."<name>".path` | Nix-evaluated path. Valid in `.nix` files at build time, resolves to `/run/secrets/<name>` |

## Reference: Where Shell Init Goes in nix-darwin

| Option | Where it lands | Supports dynamic logic? |
|--------|---------------|------------------------|
| `environment.shellInit` | Nix store `set-environment` script | ❌ Static exports only |
| `environment.variables` | Same `set-environment` script | ❌ Static values only |
| `programs.zsh.initContent` | `~/.zshrc` | ✅ Full shell logic |
| `programs.zsh.sessionVariables` | `~/.zshrc` | ❌ Static values only |
| `programs.bash.initExtra` | `~/.bashrc` | ✅ Full shell logic |

## Common Mistakes

- **Wrong path tier**: Using `/run/secrets.d/` directly instead of `/run/secrets/`
- **Wrong file**: Putting dynamic logic in `environment.shellInit` (nix-darwin system module) vs `programs.zsh.initContent` (home-manager user module)
- **Missing owner**: Secret file is `mode = "0400"` with `owner = root` — user shell can't read it. Set `owner = config.users.users.${user}.name`
- **Stale shell**: Testing in a shell that predates the `nixswitch` — open a new terminal
