# Git Commit Signing Setup Guide

This guide explains how to set up SSH-based commit signing for Git in your nix-darwin configuration.

## Overview

This configuration uses **SSH keys** for commit signing instead of GPG keys, providing:
- Simpler key management (no GPG agent complexity)
- Native macOS integration with Apple Keychain
- Automatic key loading at login
- Keys persist across nix-darwin rebuilds
- Full GitHub/GitLab support for signature verification

## Architecture

```
Git Commit → SSH Signing Key → SSH Agent → Apple Keychain
                                              ↓
                                    Persists across reboots
```

**Key Points:**
- The signing key is **user-managed** (not in Nix store)
- Stored in `~/.ssh/` with proper permissions
- Automatically loaded into Apple Keychain
- Referenced by path in Git config (never copied to Nix store)
- Remains consistent across nix-darwin rebuilds

## Setup Instructions

### Step 1: Generate SSH Signing Keys

This configuration uses **separate signing keys** for work and personal GitHub accounts (required because GitHub doesn't allow the same signing key on multiple accounts):

```bash
# Generate work account signing key
ssh-keygen -t ed25519 -C "jessup@adobe.com" -f ~/.ssh/id_ed25519_adobe_signing

# Generate personal account signing key
ssh-keygen -t ed25519 -C "djessup@users.noreply.github.com" -f ~/.ssh/id_ed25519_djessup_signing

# Set proper permissions
chmod 600 ~/.ssh/id_ed25519_adobe_signing ~/.ssh/id_ed25519_djessup_signing
chmod 644 ~/.ssh/id_ed25519_adobe_signing.pub ~/.ssh/id_ed25519_djessup_signing.pub
```

**Important:**
- Use a **strong passphrase** to protect each private key
- These keys are separate from your authentication SSH keys
- The passphrases will be stored in Apple Keychain after first use

### Step 2: Add Keys to Apple Keychain

Load both keys into the SSH agent and Apple Keychain:

```bash
# Add work key to keychain (will prompt for passphrase once)
ssh-add --apple-use-keychain ~/.ssh/id_ed25519_adobe_signing

# Add personal key to keychain (will prompt for passphrase once)
ssh-add --apple-use-keychain ~/.ssh/id_ed25519_djessup_signing

# Verify both are loaded
ssh-add -l
```

Both keys will now be automatically loaded on every login via the launchd agent configured in `user/settings/ssh.nix`.

### Step 3: Create Allowed Signers File (Optional)

This allows you to verify commits locally without GitHub:

```bash
# Create the allowed signers file with both keys
# IMPORTANT: Use the exact email addresses from your Git config
cat > ~/.ssh/allowed_signers << EOF
jessup@adobe.com $(cat ~/.ssh/id_ed25519_adobe_signing.pub)
866649+djessup@users.noreply.github.com $(cat ~/.ssh/id_ed25519_djessup_signing.pub)
EOF

# Set proper permissions
chmod 644 ~/.ssh/allowed_signers
```

**Note**: Each email must **exactly match** the email used in commits for local verification to work.

### Step 4: Add Public Keys to GitHub Accounts

**Important**: GitHub doesn't allow the same signing key on multiple accounts, so you must add each key to its corresponding account.

#### Work Account (jessup_adobe)

1. Copy your work public key:
   ```bash
   cat ~/.ssh/id_ed25519_adobe_signing.pub
   ```

2. Log in to your **work GitHub account** (jessup_adobe)
3. Go to Settings → SSH and GPG keys → New SSH key
4. Select **Key type: Signing Key** (not Authentication Key)
5. Paste the public key
6. Give it a descriptive title (e.g., "MacBook Pro M3 - Work Signing")
7. Click "Add SSH key"

#### Personal Account (djessup)

1. Copy your personal public key:
   ```bash
   cat ~/.ssh/id_ed25519_djessup_signing.pub
   ```

2. Log in to your **personal GitHub account** (djessup)
3. Go to Settings → SSH and GPG keys → New SSH key
4. Select **Key type: Signing Key** (not Authentication Key)
5. Paste the public key
6. Give it a descriptive title (e.g., "MacBook Pro M3 - Personal Signing")
7. Click "Add SSH key"

### Step 5: Rebuild nix-darwin

Apply the configuration changes:

```bash
nixswitch
```

This will configure Git to:
- Use SSH for signing (not GPG)
- Sign all commits by default
- Use work signing key by default (`~/.ssh/id_ed25519_adobe_signing.pub`)
- Automatically switch to personal signing key for repos under `~/Documents/Github/personal/`

### Step 6: Test Commit Signing

Create a test commit to verify signing works:

```bash
# Create a test repository
mkdir /tmp/test-signing && cd /tmp/test-signing
git init

# Make a test commit
echo "test" > test.txt
git add test.txt
git commit -m "test: verify commit signing"

# Verify the commit is signed
git log --show-signature -1
```

You should see output like:
```
Good "git" signature for jessup@adobe.com with ED25519 key SHA256:...
```

## Backup and Recovery

### Backup Your Signing Keys

**Critical:** Back up both signing keys to prevent loss!

1. **Bitwarden (Recommended):**
   ```bash
   # Display the work private key
   cat ~/.ssh/id_ed25519_adobe_signing

   # Display the personal private key
   cat ~/.ssh/id_ed25519_djessup_signing
   ```
   - Create separate Secure Notes in Bitwarden for each key
   - Work key title: "SSH Commit Signing Key - Work (Adobe)"
   - Personal key title: "SSH Commit Signing Key - Personal (djessup)"
   - Store both the private key and public key for each
   - Include the passphrase in a separate field

2. **Encrypted Backup:**
   ```bash
   # Create encrypted backup of both keys
   tar czf - ~/.ssh/id_ed25519_*_signing* | \
     age -r age1frpdm7hsq3r23cz3u8ua6p289pcxd05lwjhw0ejs4dk6a9ez337sx7tz7k \
     > ~/signing-keys-backup.tar.gz.age
   ```

### Recovery on New Machine

1. Restore both keys from Bitwarden or encrypted backup
2. Place in `~/.ssh/`:
   - Work key: `~/.ssh/id_ed25519_adobe_signing`
   - Personal key: `~/.ssh/id_ed25519_djessup_signing`
3. Set permissions:
   ```bash
   chmod 600 ~/.ssh/id_ed25519_adobe_signing ~/.ssh/id_ed25519_djessup_signing
   ```
4. Add to keychain:
   ```bash
   ssh-add --apple-use-keychain ~/.ssh/id_ed25519_adobe_signing
   ssh-add --apple-use-keychain ~/.ssh/id_ed25519_djessup_signing
   ```
5. Run `nixswitch` to apply Git configuration

## Configuration Details

### Git Configuration (user/settings/git.nix)

The following settings are configured:

```nix
programs.git = {
  # Default to work email and signing key
  userEmail = "jessup@adobe.com";

  signing = {
    key = "~/.ssh/id_ed25519_adobe_signing.pub";
    signByDefault = true;  # Sign all commits automatically
  };

  extraConfig = {
    gpg.format = "ssh";  # Use SSH instead of GPG
    gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";  # For local verification

    # Personal repos automatically use personal email and signing key
    includeIf."gitdir:~/Documents/Github/personal/".path = "~/.config/git/config-personal";
  };
};
```

### SSH Configuration (user/settings/ssh.nix)

The signing key is automatically loaded via:

1. **launchd agent** - Loads key at login
2. **Home activation script** - Loads key during nix-darwin rebuild

Both methods ensure the key is always available in the SSH agent.

## Troubleshooting

### Commits Not Being Signed

Check if both keys are loaded:
```bash
ssh-add -l | grep signing
```

If not loaded, manually add them:
```bash
ssh-add --apple-use-keychain ~/.ssh/id_ed25519_adobe_signing
ssh-add --apple-use-keychain ~/.ssh/id_ed25519_djessup_signing
```

### "No Secret Key" Error

This usually means:
1. The private key is not in the expected location
2. The key is not loaded in the SSH agent
3. Permissions are incorrect (should be 600)

Fix:
```bash
# Check which key should be used for current repo
git config user.signingkey

# Fix permissions
chmod 600 ~/.ssh/id_ed25519_adobe_signing ~/.ssh/id_ed25519_djessup_signing

# Add keys to keychain
ssh-add --apple-use-keychain ~/.ssh/id_ed25519_adobe_signing
ssh-add --apple-use-keychain ~/.ssh/id_ed25519_djessup_signing
```

### GitHub Shows "Unverified" Commits

1. Verify the correct public key is added to the correct GitHub account:
   - Work commits (jessup@adobe.com) → Work key on jessup_adobe account
   - Personal commits (djessup@...) → Personal key on djessup account
2. Ensure the key is added as a **Signing Key** (not Authentication Key)
3. Ensure the email in the commit matches a verified email on that GitHub account
4. Check that the commit is actually signed: `git log --show-signature -1`

### Key Not Persisting After Reboot

The launchd agent should handle this automatically. If it's not working:

```bash
# Check if the agent is running
launchctl list | grep ssh-add-keychain

# Manually restart the agent
launchctl unload ~/Library/LaunchAgents/id.jessup.ssh-add-keychain.plist
launchctl load ~/Library/LaunchAgents/id.jessup.ssh-add-keychain.plist
```

## Using Multiple GitHub Accounts

### Separate Keys for Multiple Accounts (Required)

This configuration uses **separate signing keys** for work and personal GitHub accounts because:
- GitHub doesn't allow the same signing key to be added to multiple accounts
- Each account needs its own unique signing key

**How it works:**
1. Work repos use the work signing key (`id_ed25519_adobe_signing`)
2. Personal repos use the personal signing key (`id_ed25519_djessup_signing`)
3. Git automatically selects the correct key based on repository location
4. Each key is uploaded to its corresponding GitHub account

**Configuration:**

This setup uses Git's `includeIf` directive to automatically use different emails and signing keys based on repository location:

```bash
# Organize your repositories by context
~/Documents/Github/personal/    # Uses djessup email + personal signing key
~/code/work/                     # Uses jessup@adobe.com + work signing key
All other locations              # Uses jessup@adobe.com + work signing key (default)
```

The configuration in `user/settings/git.nix` and `user/settings/git-configs.nix` automatically applies:
- Personal repos under `~/Documents/Github/personal/` → `866649+djessup@users.noreply.github.com` + personal key
- All other repos → `jessup@adobe.com` + work key (default)

**Setup:**

1. Create directory structure:
   ```bash
   mkdir -p ~/Documents/Github/personal
   ```

2. Clone repositories to appropriate directories:
   ```bash
   # Personal repositories (djessup account)
   cd ~/Documents/Github/personal
   git clone git@github.com:djessup/project.git

   # Work repositories (jessup_adobe account) - anywhere else
   cd ~/code/work  # or any other location
   git clone git@github.com:jessup_adobe/project.git
   ```

3. Verify email and signing key configuration:
   ```bash
   # Check personal repository
   cd ~/Documents/Github/personal/project
   git config user.email       # Should show: 866649+djessup@users.noreply.github.com
   git config user.signingkey  # Should show: ~/.ssh/id_ed25519_djessup_signing.pub

   # Check work repository
   cd ~/code/work/project
   git config user.email       # Should show: jessup@adobe.com
   git config user.signingkey  # Should show: ~/.ssh/id_ed25519_adobe_signing.pub
   ```

**Important:**
1. Add work email to **work GitHub account** verified emails
2. Add personal email to **personal GitHub account** verified emails
3. Add work signing key to **work GitHub account**
4. Add personal signing key to **personal GitHub account**

### Alternative: Per-Repository Configuration

If you don't want directory-based configuration, set email per repository:

```bash
cd /path/to/repo
git config user.email "your-email@example.com"
```

The signing key remains the same; only the email in commits changes.

### Why Separate Signing Keys?

This configuration uses separate signing keys because:
- **GitHub limitation**: The same signing key cannot be added to multiple GitHub accounts
- **Account isolation**: Each GitHub account (work/personal) requires its own unique signing key
- **Automatic selection**: Git automatically uses the correct key based on repository location

The configuration handles this automatically - you don't need to manually configure keys per repository.

## Security Best Practices

1. **Use a Strong Passphrase:** Protect your signing key with a strong passphrase
2. **Separate Keys:** Use different keys for authentication and signing
3. **Regular Backups:** Keep encrypted backups in Bitwarden
4. **Key Rotation:** Consider rotating signing keys annually
5. **Revoke Compromised Keys:** If compromised, immediately remove from GitHub/GitLab
6. **Verify Emails:** Ensure all emails you use are verified on GitHub/GitLab

## Alternative: GPG-based Signing

If you prefer GPG over SSH, you can use this configuration instead:

```nix
programs.git = {
  signing = {
    key = "YOUR_GPG_KEY_ID";
    signByDefault = true;
  };
  # No need to set gpg.format (defaults to "openpgp")
};

# Also enable GPG agent in darwin/default.nix
programs.gnupg.agent = {
  enable = true;
  enableSSHSupport = false;  # Don't interfere with SSH agent
};
```

However, SSH signing is recommended for macOS due to better integration.

## References

- [GitHub: SSH Commit Signature Verification](https://docs.github.com/en/authentication/managing-commit-signature-verification/about-commit-signature-verification#ssh-commit-signature-verification)
- [Git Documentation: Signing Commits](https://git-scm.com/book/en/v2/Git-Tools-Signing-Your-Work)
- [nix-darwin Git Options](https://daiderd.com/nix-darwin/manual/index.html#opt-programs.git.signing.key)

