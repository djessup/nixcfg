# GitHub Self-Hosted Runners Setup Guide

This guide will help you complete the setup of self-hosted GitHub runners using `github-nix-ci` on your Darwin system.

## Overview

The `github-nix-ci` module has been integrated into your nix-darwin configuration and is ready to be configured with your specific repositories and organizations.

## Current Status

✅ **Completed:**
- github-nix-ci flake input added
- Module imported in flake.nix
- Configuration structure created in `darwin/settings/github-runners.nix`
- SOPS secrets structure prepared

🔄 **Remaining Steps:**

### 1. Create GitHub Personal Access Tokens (PATs)

You need to create fine-grained Personal Access Tokens for each user/organization you want to run CI for.

#### For Personal Repositories:
1. Go to https://github.com/settings/personal-access-tokens/new
2. Create a fine-grained PAT with:
   - **Resource owner**: Your username (djessup)
   - **Repository access**: Choose repositories you want CI for
   - **Permissions -> Repository permissions**: Set "Administration" to "Read and write"

#### For Organization Repositories:
1. Go to https://github.com/settings/personal-access-tokens/new
2. Create a fine-grained PAT with:
   - **Resource owner**: The organization name
   - **Repository access**: All repositories (or specific ones)
   - **Permissions -> Organization permissions**: Set "Self-hosted runners" to "Read and write"

### 2. Add Tokens to SOPS Secrets

Once you have your PATs, add them to your `nix-secrets` repository:

1. For each token, create a secret in your `secrets.yaml` file:
   ```yaml
   # Personal repository token
   github-runner-djessup-token: ENC[AES256_GCM,data:...,type:str]
   
   # Organization token (example)
   github-runner-myorg-token: ENC[AES256_GCM,data:...,type:str]
   ```

2. Use `sops` to encrypt the tokens:
   ```bash
   # Edit your secrets file
   sops secrets.yaml
   
   # Add the tokens in plain text, sops will encrypt them when you save
   ```

### 3. Update Secrets Configuration

Add the token secrets to your `darwin/settings/secrets.nix`:

```nix
secrets = {
  nixAccessTokens = {
    mode = "0400";
    owner = config.users.users.${user}.name;
  };
  
  # Add your GitHub runner tokens
  github-runner-djessup-token = {
    mode = "0400";
    owner = config.users.users.${user}.name;
  };
  
  # Add organization tokens as needed
  # github-runner-myorg-token = {
  #   mode = "0400";
  #   owner = config.users.users.${user}.name;
  # };
};
```

### 4. Configure Your Repositories

Edit `darwin/settings/github-runners.nix` to specify your repositories:

```nix
services.github-nix-ci = {
  enable = true;
  
  personalRunners = {
    "djessup/my-nix-project".num = 1;
    "djessup/another-project".num = 2;
  };
  
  orgRunners = {
    "my-company".num = 3;
  };
};
```

### 5. Deploy the Configuration

After completing the above steps:

```bash
# Build and switch to the new configuration
nixswitch

# Check that runners are starting
sudo launchctl list | grep github-runner

# Check logs if needed
sudo launchctl log show --predicate 'subsystem == "github-runner"'
```

## Verification

1. **Check Runner Status**: Go to your repository/organization Settings → Actions → Runners
2. **Verify Labels**: Runners should appear with labels like `self-hosted`, `macOS`, `aarch64-darwin`
3. **Test Workflow**: Create a simple workflow to test the runners

## Example Workflow

Create `.github/workflows/nix-ci.yaml` in your repositories:

```yaml
name: "Nix CI"
on:
  push:
    branches: [ main ]
  pull_request:

jobs:
  nix:
    runs-on: aarch64-darwin  # Use your self-hosted runner
    steps:
      - uses: actions/checkout@v4
      - name: Build with nixci
        run: nixci build --systems "aarch64-darwin"
```

## Troubleshooting

### Common Issues:

1. **Runner not appearing**: Check SOPS secrets are properly decrypted
2. **Permission errors**: Ensure PAT has correct permissions
3. **Service not starting**: Check system logs with `sudo launchctl log`

### Useful Commands:

```bash
# Check runner services
sudo launchctl list | grep github-runner

# View runner logs
sudo launchctl log show --predicate 'subsystem == "github-runner"' --last 1h

# Restart runner services
sudo launchctl kickstart system/github-runner-*
```

## Security Notes

- Use fine-grained PATs instead of classic tokens
- Limit repository access to only what's needed
- Consider using organization-level tokens for better management
- Regularly rotate your tokens
- Monitor runner usage in GitHub's Actions tab

## Next Steps

After completing this setup, you can:
- Add more repositories/organizations as needed
- Scale runner counts based on CI load
- Set up matrix builds for multiple architectures
- Integrate with nixci for advanced Nix project CI
