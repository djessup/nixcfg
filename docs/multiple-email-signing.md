# Using One Signing Key with Multiple Email Addresses

## Quick Answer

**No, you don't need different signing keys for different Git email addresses.** One SSH signing key can sign commits for multiple email addresses.

## How It Works

When you sign a Git commit:

1. **Git creates the commit** with your configured email (from `user.email`)
2. **The signing key creates a signature** of the commit data
3. **The signature is attached** to the commit
4. **GitHub/GitLab verifies** the signature using your uploaded public key
5. **The platform checks** if the commit email matches one of your verified emails

**Key insight**: The signing key is **not tied to a specific email**. The email comes from your Git configuration, not from the key itself.

## Your Configuration

This nix-darwin setup is configured to use **one signing key** (`~/.ssh/id_ed25519_signing`) for **multiple email addresses**:

- **Work email**: `jessup@adobe.com`
- **Personal email**: `djessup@users.noreply.github.com`

### Automatic Email Selection

The configuration uses Git's `includeIf` directive to automatically select the correct email based on repository location:

```
~/code/work/       → jessup@adobe.com
~/code/personal/   → djessup@users.noreply.github.com
Other locations    → jessup@adobe.com (default)
```

## Setup Instructions

### 1. Create Directory Structure

```bash
mkdir -p ~/code/work ~/code/personal
```

### 2. Clone Repositories to Appropriate Locations

```bash
# Work repositories
cd ~/code/work
git clone git@github.com:jessup_adobe/project.git

# Personal repositories  
cd ~/code/personal
git clone git@github.com:djessup/project.git
```

### 3. Verify Email Configuration

```bash
# Check work repository
cd ~/code/work/project
git config user.email
# Output: jessup@adobe.com

# Check personal repository
cd ~/code/personal/project
git config user.email
# Output: djessup@users.noreply.github.com
```

### 4. Update Allowed Signers File

Add both email addresses to `~/.ssh/allowed_signers`:

```bash
cat > ~/.ssh/allowed_signers << EOF
jessup@adobe.com $(cat ~/.ssh/id_ed25519_signing.pub)
djessup@users.noreply.github.com $(cat ~/.ssh/id_ed25519_signing.pub)
EOF
```

### 5. Verify Emails on GitHub

**Critical**: Both email addresses must be verified on GitHub:

1. Go to https://github.com/settings/emails
2. Add both emails if not already present:
   - `jessup@adobe.com`
   - `djessup@users.noreply.github.com`
3. Verify both emails (check your inbox for verification emails)

### 6. Add Signing Key to GitHub

You only need to add the public key **once**:

1. Copy the public key: `cat ~/.ssh/id_ed25519_signing.pub`
2. Go to https://github.com/settings/keys
3. Click "New SSH key"
4. Select **"Signing Key"** (not Authentication Key)
5. Paste the key
6. Give it a descriptive title (e.g., "MacBook Pro M3 - Commit Signing")

This **one key** will verify commits from **all your verified email addresses**.

## How the Configuration Works

### Git Configuration (`user/settings/git.nix`)

```nix
programs.git = {
  # Default email (used for repos outside specific directories)
  userEmail = "jessup@adobe.com";
  
  # Single signing key for all emails
  signing = {
    key = "~/.ssh/id_ed25519_signing.pub";
    signByDefault = true;
  };
  
  extraConfig = {
    # Conditional includes for different directories
    includeIf."gitdir:~/code/personal/".path = "~/.config/git/config-personal";
    includeIf."gitdir:~/code/work/".path = "~/.config/git/config-work";
  };
};
```

### Conditional Configs (`user/settings/git-configs.nix`)

**Personal repos** (`~/.config/git/config-personal`):
```
[user]
  email = djessup@users.noreply.github.com
  name = David Jessup
```

**Work repos** (`~/.config/git/config-work`):
```
[user]
  email = jessup@adobe.com
  name = David Jessup
```

## Testing

### Test Work Email

```bash
cd ~/code/work
mkdir test-work && cd test-work
git init
echo "test" > test.txt
git add test.txt
git commit -m "test: work commit"

# Verify email and signature
git log --format="%ae" -1  # Should show: jessup@adobe.com
git log --show-signature -1  # Should show: Good "git" signature
```

### Test Personal Email

```bash
cd ~/code/personal
mkdir test-personal && cd test-personal
git init
echo "test" > test.txt
git add test.txt
git commit -m "test: personal commit"

# Verify email and signature
git log --format="%ae" -1  # Should show: djessup@users.noreply.github.com
git log --show-signature -1  # Should show: Good "git" signature
```

## Alternative: Per-Repository Configuration

If you don't want directory-based configuration, you can set the email per repository:

```bash
cd /path/to/repo
git config user.email "your-email@example.com"
```

The signing key remains the same; only the commit email changes.

## When You WOULD Need Separate Keys

You might want separate signing keys if:

### 1. Security Policy Requires It
Some organizations require separate keys for work and personal use.

**Setup:**
```bash
# Generate separate keys
ssh-keygen -t ed25519 -C "jessup@adobe.com" -f ~/.ssh/id_ed25519_work
ssh-keygen -t ed25519 -C "personal@example.com" -f ~/.ssh/id_ed25519_personal

# Configure per repository
cd ~/code/work/project
git config user.signingkey ~/.ssh/id_ed25519_work.pub

cd ~/code/personal/project
git config user.signingkey ~/.ssh/id_ed25519_personal.pub
```

### 2. Different Key Types Needed
Legacy systems might require RSA keys while modern systems use Ed25519.

### 3. Different Key Rotation Schedules
Work keys might need annual rotation while personal keys are kept longer.

## Troubleshooting

### Commits Show "Unverified" on GitHub

**Cause**: Email not verified on GitHub or doesn't match commit email.

**Fix**:
1. Check commit email: `git log --format="%ae" -1`
2. Verify this email on GitHub: https://github.com/settings/emails
3. Ensure signing key is added: https://github.com/settings/keys

### Wrong Email in Commits

**Cause**: Repository not in the correct directory.

**Fix**:
```bash
# Check current email
git config user.email

# Move repository to correct location
mv /path/to/repo ~/code/work/  # or ~/code/personal/

# Or set email manually for this repo
git config user.email "correct@email.com"
```

### Signature Verification Fails Locally

**Cause**: Email not in allowed signers file.

**Fix**:
```bash
# Add missing email to allowed signers
echo "missing@email.com $(cat ~/.ssh/id_ed25519_signing.pub)" >> ~/.ssh/allowed_signers
```

## Summary

- **One signing key** can sign commits for **multiple email addresses**  
- **Directory-based configuration** automatically selects the correct email  
- **All emails must be verified** on GitHub/GitLab  
- **One public key upload** on GitHub works for all verified emails  
- **Simpler management** than maintaining multiple signing keys  

The key insight is that **signing keys verify identity**, while **email addresses identify the author**. These are separate concerns that don't need to be coupled.

