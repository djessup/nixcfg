#!/usr/bin/env bash
#
# Git Commit Signing Setup Script
#
# This script helps you set up SSH-based commit signing for Git.
# It will guide you through generating a signing key, adding it to the keychain,
# and configuring GitHub.
#
# Usage: ./scripts/setup-git-signing.sh

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SIGNING_KEY_PATH="$HOME/.ssh/id_ed25519_signing"
ALLOWED_SIGNERS_FILE="$HOME/.ssh/allowed_signers"
PRIMARY_EMAIL="jessup@adobe.com"
PERSONAL_EMAIL="djessup@users.noreply.github.com"

# Helper functions
print_header() {
    echo -e "\n${BLUE}==>${NC} ${1}"
}

print_success() {
    echo -e "${GREEN}✓${NC} ${1}"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} ${1}"
}

print_error() {
    echo -e "${RED}✗${NC} ${1}"
}

print_info() {
    echo -e "  ${1}"
}

# Check if key already exists
check_existing_key() {
    if [[ -f "$SIGNING_KEY_PATH" ]]; then
        print_warning "Signing key already exists at $SIGNING_KEY_PATH"
        read -p "Do you want to use the existing key? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            return 0
        else
            print_error "Aborting. Please manually remove or backup the existing key first."
            exit 1
        fi
    fi
    return 1
}

# Generate signing key
generate_key() {
    print_header "Generating SSH signing key..."

    if check_existing_key; then
        print_success "Using existing key"
        return 0
    fi

    print_info "Generating Ed25519 key for $PRIMARY_EMAIL"
    print_warning "You will be prompted to enter a passphrase. Use a strong passphrase!"

    ssh-keygen -t ed25519 -C "$PRIMARY_EMAIL" -f "$SIGNING_KEY_PATH"

    # Set proper permissions
    chmod 600 "$SIGNING_KEY_PATH"
    chmod 644 "${SIGNING_KEY_PATH}.pub"

    print_success "Key generated successfully"
}

# Add key to keychain
add_to_keychain() {
    print_header "Adding key to Apple Keychain..."

    if ssh-add -l 2>/dev/null | grep -q "$SIGNING_KEY_PATH"; then
        print_success "Key already loaded in SSH agent"
        return 0
    fi

    print_info "Adding key to keychain (you'll be prompted for the passphrase)"
    ssh-add --apple-use-keychain "$SIGNING_KEY_PATH"

    print_success "Key added to keychain"
}

# Create allowed signers file
create_allowed_signers() {
    print_header "Creating allowed signers file..."

    local pubkey=$(cat ${SIGNING_KEY_PATH}.pub)
    local needs_update=false

    if [[ -f "$ALLOWED_SIGNERS_FILE" ]]; then
        if ! grep -q "$PRIMARY_EMAIL" "$ALLOWED_SIGNERS_FILE"; then
            needs_update=true
        fi
        if ! grep -q "$PERSONAL_EMAIL" "$ALLOWED_SIGNERS_FILE"; then
            needs_update=true
        fi
    else
        needs_update=true
    fi

    if [[ "$needs_update" == "true" ]]; then
        # Add both email addresses to allowed signers
        echo "$PRIMARY_EMAIL $pubkey" >> "$ALLOWED_SIGNERS_FILE"
        echo "$PERSONAL_EMAIL $pubkey" >> "$ALLOWED_SIGNERS_FILE"
        chmod 644 "$ALLOWED_SIGNERS_FILE"
        print_success "Allowed signers file created with both email addresses"
    else
        print_success "Allowed signers file already configured"
    fi
}

# Display public key for GitHub
show_github_instructions() {
    print_header "GitHub Setup Instructions"

    echo -e "\n${YELLOW}Your public signing key:${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    cat "${SIGNING_KEY_PATH}.pub"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    echo -e "\n${BLUE}To add this key to GitHub:${NC}"
    print_info "1. Copy the key above (it's also in your clipboard)"
    print_info "2. Go to: https://github.com/settings/keys"
    print_info "3. Click 'New SSH key'"
    print_info "4. Select 'Key type: Signing Key'"
    print_info "5. Paste the key and give it a title"
    print_info "6. Click 'Add SSH key'"

    # Copy to clipboard if pbcopy is available
    if command -v pbcopy &> /dev/null; then
        cat "${SIGNING_KEY_PATH}.pub" | pbcopy
        print_success "Public key copied to clipboard!"
    fi

    echo -e "\n${YELLOW}Important: Verify ALL your email addresses on GitHub${NC}"
    print_info "This key will sign commits for multiple emails:"
    print_info "  - $PRIMARY_EMAIL (work)"
    print_info "  - $PERSONAL_EMAIL (personal)"
    print_info ""
    print_info "Go to https://github.com/settings/emails and verify both addresses"

    echo -e "\n${BLUE}For GitLab:${NC}"
    print_info "1. Go to: https://gitlab.com/-/profile/keys"
    print_info "2. Paste the key"
    print_info "3. Select 'Usage type: Signing'"
    print_info "4. Click 'Add key'"
    print_info "5. Verify your emails at: https://gitlab.com/-/profile/emails"
}

# Test signing
test_signing() {
    print_header "Testing commit signing..."

    # Create a temporary test repository
    TEST_DIR=$(mktemp -d)
    cd "$TEST_DIR"

    git init -q
    git config user.name "David Jessup"
    git config user.email "$PRIMARY_EMAIL"

    echo "test" > test.txt
    git add test.txt
    git commit -q -m "test: verify commit signing"

    # Check if commit is signed
    if git log --show-signature -1 2>&1 | grep -q "Good \"git\" signature"; then
        print_success "Commit signing is working!"
        git log --show-signature -1 | head -n 3
    else
        print_error "Commit signing test failed"
        print_info "Run 'git log --show-signature -1' in a repository to debug"
    fi

    # Cleanup
    cd - > /dev/null
    rm -rf "$TEST_DIR"
}

# Backup instructions
show_backup_instructions() {
    print_header "Backup Your Signing Key"

    print_warning "IMPORTANT: Back up your signing key to prevent loss!"

    echo -e "\n${BLUE}Recommended: Store in Bitwarden${NC}"
    print_info "1. Create a new Secure Note in Bitwarden"
    print_info "2. Title: 'SSH Commit Signing Key - MacBook Pro M3'"
    print_info "3. Add the private key content:"
    echo -e "\n${YELLOW}Private key:${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    cat "$SIGNING_KEY_PATH"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    print_info "4. Also store the passphrase in a separate field"

    echo -e "\n${BLUE}Alternative: Encrypted backup${NC}"
    print_info "Run this command to create an encrypted backup:"
    echo -e "  ${YELLOW}tar czf - ~/.ssh/id_ed25519_signing* | age -r age1frpdm7hsq3r23cz3u8ua6p289pcxd05lwjhw0ejs4dk6a9ez337sx7tz7k > ~/signing-key-backup.tar.gz.age${NC}"
}

# Main execution
main() {
    echo -e "${BLUE}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║         Git Commit Signing Setup (SSH-based)                  ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"

    # Check prerequisites
    if ! command -v ssh-keygen &> /dev/null; then
        print_error "ssh-keygen not found. Please install OpenSSH."
        exit 1
    fi

    if ! command -v git &> /dev/null; then
        print_error "git not found. Please install Git."
        exit 1
    fi

    # Run setup steps
    generate_key
    add_to_keychain
    create_allowed_signers
    show_github_instructions

    echo -e "\n${YELLOW}Press Enter to continue with testing...${NC}"
    read

    test_signing
    show_backup_instructions

    # Final instructions
    print_header "Next Steps"
    print_info "1. Add the public key to GitHub/GitLab (see instructions above)"
    print_info "2. Back up your private key to Bitwarden"
    print_info "3. Run 'nixswitch' to apply the Git configuration"
    print_info "4. Test signing in a real repository"

    echo -e "\n${GREEN}Setup complete!${NC} 🎉"
    echo -e "For more information, see: ${BLUE}docs/git-commit-signing-setup.md${NC}\n"
}

# Run main function
main

