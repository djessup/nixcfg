#!/usr/bin/env bash

# Nix Files Catalog Script for nix-darwin Configuration
# This script scans the entire nix-darwin repository and catalogs all .nix files
# Author: Generated for nix-darwin configuration management

set -euo pipefail

# Default configuration
REPO_ROOT="/private/etc/nix-darwin"
DEFAULT_OUTPUT_FILE="$REPO_ROOT/nix-files-catalog.txt"
OUTPUT_FILE="$DEFAULT_OUTPUT_FILE"

# Function to show usage
show_usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Nix Files Catalog Script for nix-darwin Configuration
Scans the entire nix-darwin repository and catalogs all .nix files.

OPTIONS:
    -o, --output FILE    Specify output file path (default: $DEFAULT_OUTPUT_FILE)
    -h, --help          Show this help message

EXAMPLES:
    $0                                    # Use default output file
    $0 -o /tmp/nix-catalog.txt           # Save to custom location
    $0 --output ~/Documents/catalog.md   # Save to home directory

EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -o|--output)
            if [[ -n "${2:-}" ]]; then
                OUTPUT_FILE="$2"
                shift 2
            else
                echo "Error: --output requires a file path argument" >&2
                exit 1
            fi
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            echo "Error: Unknown option '$1'" >&2
            echo "Use '$0 --help' for usage information." >&2
            exit 1
            ;;
    esac
done

# Convert relative path to absolute path
if [[ "$OUTPUT_FILE" != /* ]]; then
    OUTPUT_FILE="$(pwd)/$OUTPUT_FILE"
fi

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print colored output
print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

print_color $BLUE "🔍 Scanning nix-darwin repository for .nix files..."
print_color $CYAN "Repository: $REPO_ROOT"
print_color $CYAN "Output file: $OUTPUT_FILE"
echo

# Check if repository directory exists
if [[ ! -d "$REPO_ROOT" ]]; then
    print_color $RED "❌ Error: Repository directory not found: $REPO_ROOT"
    exit 1
fi

cd "$REPO_ROOT"

print_color $YELLOW "📁 Discovering .nix files..."

# Check if any .nix files exist
if ! find . -name "*.nix" -type f -print -quit | grep -q .; then
    print_color $YELLOW "⚠️  No .nix files found in the repository"
    echo "No .nix files found in the repository." > "$OUTPUT_FILE"
    exit 0
fi

print_color $GREEN "📋 Processing files and generating catalog..."

# Collect categories that will be present
declare -A categories_found
categories_found["MAIN"]=0
categories_found["DARWIN"]=0
categories_found["USER"]=0
categories_found["NEOVIM"]=0
categories_found["SCRIPTS"]=0
categories_found["CI_CD"]=0
categories_found["OTHER"]=0

# Pre-scan to determine which categories exist
while IFS= read -r filepath; do
    if [[ -f "$filepath" ]]; then
        rel_path=${filepath#./}
        case "$rel_path" in
            flake.nix) categories_found["MAIN"]=1 ;;
            darwin/*) categories_found["DARWIN"]=1 ;;
            user/settings/neovim/*) categories_found["NEOVIM"]=1 ;;
            user/*) categories_found["USER"]=1 ;;
            scripts/*) categories_found["SCRIPTS"]=1 ;;
            github-nix-ci/*) categories_found["CI_CD"]=1 ;;
            *) categories_found["OTHER"]=1 ;;
        esac
    fi
done < <(find . -name "*.nix" -type f | sort)

# Create output file with Table of Contents
cat > "$OUTPUT_FILE" << EOF
# Nix Files Catalog for nix-darwin Configuration
# Generated on: $(date)
# Repository: $REPO_ROOT

## Table of Contents

EOF

# Generate TOC based on found categories
if [[ ${categories_found["MAIN"]} -eq 1 ]]; then
    echo "- [🏠 Main Configuration](#-main-configuration)" >> "$OUTPUT_FILE"
fi
if [[ ${categories_found["DARWIN"]} -eq 1 ]]; then
    echo "- [🖥️ Darwin System Configuration](#️-darwin-system-configuration)" >> "$OUTPUT_FILE"
fi
if [[ ${categories_found["USER"]} -eq 1 ]]; then
    echo "- [👤 User Configuration](#-user-configuration)" >> "$OUTPUT_FILE"
fi
if [[ ${categories_found["NEOVIM"]} -eq 1 ]]; then
    echo "- [📝 Neovim Configuration](#-neovim-configuration)" >> "$OUTPUT_FILE"
fi
if [[ ${categories_found["SCRIPTS"]} -eq 1 ]]; then
    echo "- [📜 Scripts and Utilities](#-scripts-and-utilities)" >> "$OUTPUT_FILE"
fi
if [[ ${categories_found["CI_CD"]} -eq 1 ]]; then
    echo "- [🔄 CI/CD Configuration](#-cicd-configuration)" >> "$OUTPUT_FILE"
fi
if [[ ${categories_found["OTHER"]} -eq 1 ]]; then
    echo "- [📁 Other Files](#-other-files)" >> "$OUTPUT_FILE"
fi

echo "- [📊 Summary Statistics](#-summary-statistics)" >> "$OUTPUT_FILE"
echo >> "$OUTPUT_FILE"

echo "## File Catalog by Category" >> "$OUTPUT_FILE"
echo >> "$OUTPUT_FILE"

# Initialize variables for categorization
current_category=""

# Find and process files
find . -name "*.nix" -type f | sort | while read -r filepath; do
    if [[ -f "$filepath" ]]; then
        rel_path=${filepath#./}

        # Get file size
        if size_bytes=$(stat -c "%s" "$filepath" 2>/dev/null); then
            :
        elif size_bytes=$(/usr/bin/stat -f "%z" "$filepath" 2>/dev/null); then
            :
        else
            size_bytes=0
        fi

        # Convert to human readable
        if [[ $size_bytes -lt 1024 ]]; then
            size_human="$size_bytes B"
        elif [[ $size_bytes -lt 1048576 ]]; then
            size_human="$(( size_bytes / 1024 )) KB"
        else
            size_human="$(( size_bytes / 1048576 )) MB"
        fi

        # Get modification date
        if mod_date=$(stat -c "%y" "$filepath" 2>/dev/null | cut -d'.' -f1); then
            :
        elif mod_date=$(/usr/bin/stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$filepath" 2>/dev/null); then
            :
        else
            mod_date="Unknown"
        fi

        # Determine purpose and category
        filename=$(basename "$filepath")
        case "$rel_path" in
            flake.nix)
                purpose="Main Nix flake configuration"
                category="MAIN"
                ;;
            */default.nix)
                case "$(dirname "$rel_path")" in
                    darwin)
                        purpose="Darwin system configuration entry point"
                        category="DARWIN"
                        ;;
                    user)
                        purpose="User configuration entry point"
                        category="USER"
                        ;;
                    scripts)
                        purpose="Scripts module configuration"
                        category="SCRIPTS"
                        ;;
                    user/dock)
                        purpose="Dock configuration module"
                        category="USER"
                        ;;
                    user/settings/neovim/plugins)
                        purpose="Neovim plugins configuration"
                        category="NEOVIM"
                        ;;
                    user/settings/neovim)
                        purpose="Neovim configuration module"
                        category="NEOVIM"
                        ;;
                    *)
                        purpose="Module entry point"
                        category="OTHER"
                        ;;
                esac
                ;;
            darwin/settings/*)
                case "$filename" in
                    devenv.nix) purpose="Development environment settings" ;;
                    environment.nix) purpose="System environment configuration" ;;
                    flox.nix) purpose="Flox package manager configuration" ;;
                    homebrew.nix) purpose="Homebrew package management" ;;
                    login.nix) purpose="Login and session configuration" ;;
                    network.nix) purpose="Network settings configuration" ;;
                    secrets.nix) purpose="Secrets management configuration" ;;
                    security.nix) purpose="Security settings configuration" ;;
                    system.nix) purpose="Core system configuration" ;;
                    *) purpose="Darwin system setting: ${filename%.nix}" ;;
                esac
                category="DARWIN"
                ;;
            user/settings/neovim/plugins/*)
                purpose="Neovim plugin: ${filename%.nix}"
                category="NEOVIM"
                ;;
            user/settings/neovim/*)
                case "$filename" in
                    autocommands.nix) purpose="Neovim autocommands configuration" ;;
                    completion.nix) purpose="Neovim completion configuration" ;;
                    keymappings.nix) purpose="Neovim key mappings configuration" ;;
                    options.nix) purpose="Neovim options configuration" ;;
                    *) purpose="Neovim configuration: ${filename%.nix}" ;;
                esac
                category="NEOVIM"
                ;;
            user/settings/*)
                case "$filename" in
                    dock.nix) purpose="User dock configuration" ;;
                    git.nix) purpose="Git configuration and settings" ;;
                    packages.nix) purpose="User package installations" ;;
                    programs.nix) purpose="User program configurations" ;;
                    ssh.nix) purpose="SSH client configuration" ;;
                    zsh.nix) purpose="Zsh shell configuration" ;;
                    *) purpose="User setting: ${filename%.nix}" ;;
                esac
                category="USER"
                ;;
            user/_tbc/*)
                purpose="Configuration to be completed: ${filename%.nix}"
                category="USER"
                ;;
            github-nix-ci/*)
                purpose="GitHub CI/CD Nix configuration"
                category="CI_CD"
                ;;
            scripts/*)
                purpose="Script configuration: ${filename%.nix}"
                category="SCRIPTS"
                ;;
            *)
                purpose="Nix configuration file"
                category="OTHER"
                ;;
        esac

        # Print category header if changed
        if [[ "$category" != "$current_category" ]]; then
            current_category="$category"
            case "$category" in
                MAIN) echo "### 🏠 Main Configuration" >> "$OUTPUT_FILE" ;;
                DARWIN) echo "### 🖥️ Darwin System Configuration" >> "$OUTPUT_FILE" ;;
                USER) echo "### 👤 User Configuration" >> "$OUTPUT_FILE" ;;
                NEOVIM) echo "### 📝 Neovim Configuration" >> "$OUTPUT_FILE" ;;
                SCRIPTS) echo "### 📜 Scripts and Utilities" >> "$OUTPUT_FILE" ;;
                CI_CD) echo "### 🔄 CI/CD Configuration" >> "$OUTPUT_FILE" ;;
                OTHER) echo "### 📁 Other Files" >> "$OUTPUT_FILE" ;;
            esac
            echo >> "$OUTPUT_FILE"
        fi

        # Write to output
        {
            echo "**$rel_path**"
            echo "- Size: $size_human"
            echo "- Modified: $mod_date"
            echo "- Purpose: $purpose"
            echo
        } >> "$OUTPUT_FILE"
    fi
done

# Add comprehensive summary
{
    echo "## 📊 Summary Statistics"
    echo
    total_files=$(find . -name "*.nix" -type f | wc -l)
    echo "- **Total .nix files found:** $total_files"

    # Calculate total size
    total_size=$(find . -name "*.nix" -type f -exec stat -c "%s" {} + 2>/dev/null | awk '{sum+=$1} END {print sum+0}')
    if [[ $total_size -lt 1024 ]]; then
        total_size_human="$total_size B"
    elif [[ $total_size -lt 1048576 ]]; then
        total_size_human="$(( total_size / 1024 )) KB"
    else
        total_size_human="$(( total_size / 1048576 )) MB"
    fi
    echo "- **Total size of all .nix files:** $total_size_human"
    echo

    # Count files by category
    main_count=$(find . -name "flake.nix" -type f | wc -l)
    darwin_count=$(find . -path "./darwin/*" -name "*.nix" -type f | wc -l)
    neovim_count=$(find . -path "./user/settings/neovim/*" -name "*.nix" -type f | wc -l)
    user_count=$(find . -path "./user/*" -name "*.nix" -type f | wc -l)
    scripts_count=$(find . -path "./scripts/*" -name "*.nix" -type f | wc -l)
    ci_count=$(find . -path "./github-nix-ci/*" -name "*.nix" -type f | wc -l)

    # Adjust user count to exclude neovim files
    user_count=$((user_count - neovim_count))

    echo "### Files by Category:"
    [[ $main_count -gt 0 ]] && echo "- Main Configuration: $main_count files"
    [[ $darwin_count -gt 0 ]] && echo "- Darwin System: $darwin_count files"
    [[ $user_count -gt 0 ]] && echo "- User Configuration: $user_count files"
    [[ $neovim_count -gt 0 ]] && echo "- Neovim Configuration: $neovim_count files"
    [[ $scripts_count -gt 0 ]] && echo "- Scripts: $scripts_count files"
    [[ $ci_count -gt 0 ]] && echo "- CI/CD: $ci_count files"
    echo

    # Find directory with most files
    max_dir=$(find . -name "*.nix" -type f | sed 's|/[^/]*$||' | sort | uniq -c | sort -nr | head -1 | awk '{print $2}')
    max_count=$(find . -name "*.nix" -type f | sed 's|/[^/]*$||' | sort | uniq -c | sort -nr | head -1 | awk '{print $1}')

    if [[ -n "$max_dir" && $max_count -gt 1 ]]; then
        echo "- **Directory with most .nix files:** ${max_dir#./} ($max_count files)"
    fi
    echo

    echo "---"
    echo "*Catalog generated by catalog-nix-files.sh on $(date)*"
} >> "$OUTPUT_FILE"

print_color $GREEN "✅ Catalog completed successfully!"
print_color $CYAN "📄 Results saved to: $OUTPUT_FILE"
total_files=$(find . -name "*.nix" -type f | wc -l)
total_size=$(find . -name "*.nix" -type f -exec stat -c "%s" {} + 2>/dev/null | awk '{sum+=$1} END {print sum+0}')
if [[ $total_size -lt 1024 ]]; then
    total_size_human="$total_size B"
elif [[ $total_size -lt 1048576 ]]; then
    total_size_human="$(( total_size / 1024 )) KB"
else
    total_size_human="$(( total_size / 1048576 )) MB"
fi
print_color $YELLOW "📈 Found $total_files .nix files totaling $total_size_human"

echo
print_color $PURPLE "📖 Preview of catalog:"
head -20 "$OUTPUT_FILE"
echo "..."
print_color $CYAN "(Full catalog saved to $OUTPUT_FILE)"
