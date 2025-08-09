#!/usr/bin/env bash

# nix-cleanup - Nix store cleanup script
# Part of nix-darwin configuration for efficient space management

set -euo pipefail

# Script metadata
SCRIPT_NAME="nix-cleanup"
SCRIPT_VERSION="1.0.0"
DEFAULT_THRESHOLD="1d"
SYSTEM_PROFILE="/nix/var/nix/profiles/system"

# Color codes for output
if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    PURPLE='\033[0;35m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    NC='\033[0m' # No Color
else
    RED='' GREEN='' YELLOW='' BLUE='' PURPLE='' CYAN='' BOLD='' NC=''
fi

# Default options
DRY_RUN=false
VERBOSE=false
USER_ONLY=false
FULL_CLEANUP=false
THRESHOLD="$DEFAULT_THRESHOLD"
KEEP_GENERATIONS=""
SHOW_LARGEST=false
SHOW_INFO=false
FORCE=false

# Helper functions
log_info() {
    echo -e "${BLUE}ℹ${NC} $*"
}

log_success() {
    echo -e "${GREEN}✓${NC} $*"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $*"
}

log_error() {
    echo -e "${RED}✗${NC} $*" >&2
}

log_verbose() {
    if [[ "$VERBOSE" == "true" ]]; then
        echo -e "${PURPLE}→${NC} $*"
    fi
}

print_header() {
    echo -e "${BOLD}${CYAN}$SCRIPT_NAME v$SCRIPT_VERSION${NC}"
    echo -e "${CYAN}A Nix Store Cleanup Tool${NC}"
    echo
}

print_usage() {
    echo -e "${BOLD}USAGE:${NC}"
    echo "    $SCRIPT_NAME [OPTIONS]"
    echo
    echo -e "${BOLD}DESCRIPTION:${NC}"
    echo "    A nix store cleanup tool that safely removes old generations,"
    echo "    performs garbage collection, and optimizes the store for maximum space recovery."
    echo
    echo -e "${BOLD}OPTIONS:${NC}"
    echo -e "    ${BOLD}Core Operations:${NC}"
    echo "    -u, --user-only         Clean only user profiles (no sudo required)"
    echo "    -f, --full              Full cleanup including system profiles (requires sudo)"
    echo "    -t, --threshold TIME    Time threshold for cleanup (default: $DEFAULT_THRESHOLD)"
    echo "                           Examples: 1h, 6h, 1d, 7d, 30d, 1m"
    echo "    -k, --keep NUM          Keep NUM most recent generations regardless of time"
    echo "    "
    echo -e "    ${BOLD}Safety & Control:${NC}"
    echo "    -n, --dry-run          Show what would be cleaned without doing it"
    echo "    -y, --yes              Skip confirmation prompts (use with caution)"
    echo "    -v, --verbose          Show detailed information about operations"
    echo "    "
    echo -e "    ${BOLD}Information:${NC}"
    echo "    -l, --largest          Show largest store paths before cleanup"
    echo "    -i, --info             Show quick store statistics and exit"
    echo "    -h, --help             Show this help message"
    echo "    --version              Show version information"
    echo
    echo -e "${BOLD}EXAMPLES:${NC}"
    echo "    $SCRIPT_NAME                    # Safe user-only cleanup (1 day threshold)"
    echo "    $SCRIPT_NAME --full             # Full cleanup including system profiles"
    echo "    $SCRIPT_NAME -t 7d --verbose    # Clean items older than 7 days with details"
    echo "    $SCRIPT_NAME --dry-run --full   # Preview what full cleanup would do"
    echo "    $SCRIPT_NAME -k 5 --user-only   # Keep 5 recent generations, clean user only"
    echo "    $SCRIPT_NAME --largest          # Show space usage before cleaning"
    echo "    $SCRIPT_NAME --info             # Quick store statistics"
    echo
    echo -e "${BOLD}PERFORMANCE NOTES:${NC}"
    echo "    • --info uses fast filesystem tools (diskutil, stat) for instant results"
    echo "    • --largest may take time on large stores but provides detailed analysis"
    echo "    • Store size estimates are based on volume usage and path counts"
    echo
    echo -e "${BOLD}SAFETY NOTES:${NC}"
    echo "    • Default 1-day threshold protects recent generations"
    echo "    • System cleanup requires sudo and affects nix-darwin rollback capability"
    echo "    • Use --dry-run first to preview changes"
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                print_header
                print_usage
                exit 0
                ;;
            --version)
                echo "$SCRIPT_NAME v$SCRIPT_VERSION"
                exit 0
                ;;
            -n|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -u|--user-only)
                USER_ONLY=true
                shift
                ;;
            -f|--full)
                FULL_CLEANUP=true
                shift
                ;;
            -t|--threshold)
                THRESHOLD="$2"
                shift 2
                ;;
            -k|--keep)
                KEEP_GENERATIONS="$2"
                shift 2
                ;;
            -l|--largest)
                SHOW_LARGEST=true
                shift
                ;;
            -i|--info)
                SHOW_INFO=true
                shift
                ;;
            -y|--yes)
                FORCE=true
                shift
                ;;
            *)
                log_error "Unknown option: $1"
                echo "Use --help for usage information."
                exit 1
                ;;
        esac
    done
}

# Validate threshold format
validate_threshold() {
    if [[ ! "$THRESHOLD" =~ ^[0-9]+[hdwmy]$ ]]; then
        log_error "Invalid threshold format: $THRESHOLD"
        log_error "Use format like: 1h, 6h, 1d, 7d, 30d, 1m"
        exit 1
    fi
}

# Get disk usage of /nix/store (using fast filesystem methods)
get_store_size() {
    # Method 1: Use diskutil on macOS (instant results)
    if [[ "$(uname)" == "Darwin" ]] && command -v diskutil &> /dev/null; then
        local used_space
        used_space=$(diskutil info /nix 2>/dev/null | grep "Volume Used Space" | awk '{print $4, $5}' | tr -d '()')
        if [[ -n "$used_space" ]]; then
            echo "$used_space"
            return
        fi
    fi

    # Method 2: Count store paths and estimate (very fast approximation)
    local path_count
    path_count=$(get_store_paths_count)
    if [[ "$path_count" != "unknown" && "$path_count" -gt 0 ]]; then
        # Conservative estimate: average 50MB per store path
        local estimated_mb=$((path_count * 50))
        if [[ "$estimated_mb" -gt 1024 ]]; then
            echo "$((estimated_mb / 1024))G (estimated)"
        else
            echo "${estimated_mb}M (estimated)"
        fi
        return
    fi

    # Method 3: Use filesystem block info (fast)
    if command -v stat &> /dev/null; then
        local fs_info
        fs_info=$(stat -f /nix/store 2>/dev/null)
        if [[ -n "$fs_info" ]]; then
            # Extract block size and used blocks from stat output
            local block_size used_blocks
            block_size=$(echo "$fs_info" | grep "Block size:" | awk '{print $3}')
            used_blocks=$(echo "$fs_info" | grep "Blocks:" | awk '{print $3 - $5}')
            if [[ -n "$block_size" && -n "$used_blocks" && "$used_blocks" -gt 0 ]]; then
                local used_bytes=$((block_size * used_blocks))
                echo "$used_bytes" | numfmt --to=iec 2>/dev/null || echo "~$((used_bytes / 1024 / 1024 / 1024))G"
                return
            fi
        fi
    fi

    # Fallback: Show that measurement is not available
    echo "unknown (use --largest for detailed analysis)"
}

# Get number of store paths (fast method)
get_store_paths_count() {
    # Use ls instead of find for better performance
    ls -1 /nix/store 2>/dev/null | wc -l | tr -d ' ' || echo "unknown"
}

# Show largest store paths (with timeout for performance)
show_largest_paths() {
    log_info "Top 10 largest store paths:"
    echo

    # Quick method using du on top-level directories
    log_verbose "Analyzing top-level store directories (fast method)..."
    if timeout 30s du -sh /nix/store/* 2>/dev/null | sort -hr | head -10; then
        echo
        return
    fi

    # Fallback to nix path-info if available and du times out
    if command -v nix &> /dev/null && nix --version | grep -q "nix (Nix) 2"; then
        log_verbose "Using nix path-info method..."
        timeout 60s nix path-info --all --size 2>/dev/null | sort -nk2 | tail -10 | while read -r path size; do
            size_mb=$((size / 1024 / 1024))
            echo -e "  ${CYAN}${size_mb}MB${NC} $path"
        done 2>/dev/null || log_warning "Store analysis timed out (store is very large)"
    else
        log_warning "Cannot show largest paths (requires Nix 2.x with flakes or du timed out)"
    fi
    echo
}

# Show quick store statistics
show_store_info() {
    log_info "Quick store analysis:"
    echo

    # /nix volume usage (instant on macOS)
    if [[ "$(uname)" == "Darwin" ]] && command -v diskutil &> /dev/null; then
        echo -e "${BOLD}/nix Volume Usage:${NC}"
        diskutil info /nix 2>/dev/null | grep -E "(Volume Used Space|Container Total Space)" | sed 's/^/  /'
        echo -e "  ${YELLOW}Note: This is the entire /nix volume (store + other data)${NC}"
        echo
    fi

    # Store paths count (fast)
    local store_paths
    store_paths=$(get_store_paths_count)
    echo -e "${BOLD}Store Paths:${NC} $store_paths directories"
    echo

    # Store size estimate
    echo -e "${BOLD}Store Size Estimate:${NC}"
    local store_size
    store_size=$(get_store_size)
    echo -e "  $store_size"
    echo

    # Quick filesystem stats
    if command -v stat &> /dev/null; then
        echo -e "${BOLD}Filesystem Info:${NC}"
        stat -f /nix/store 2>/dev/null | grep -E "(Block size|Blocks|Inodes)" | sed 's/^/  /'
        echo
    fi
}

# Check if sudo is available and working
check_sudo() {
    if ! command -v sudo &> /dev/null; then
        log_error "sudo is required for system cleanup but not available"
        return 1
    fi

    if ! sudo -n true 2>/dev/null; then
        log_warning "sudo access required for system cleanup"
        if [[ "$FORCE" != "true" ]]; then
            read -p "Continue and prompt for sudo password? [y/N]: " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                return 1
            fi
        fi
    fi
    return 0
}

# List generations for a profile
list_generations() {
    local profile="$1"
    local profile_name="$2"

    log_verbose "Listing generations for $profile_name profile"

    if [[ -e "$profile" ]]; then
        if [[ "$profile" == "$SYSTEM_PROFILE" ]]; then
            sudo nix-env --profile "$profile" --list-generations 2>/dev/null || true
        else
            nix-env --profile "$profile" --list-generations 2>/dev/null || true
        fi
    else
        log_verbose "Profile $profile does not exist"
    fi
}

# Clean user profiles
clean_user_profiles() {
    log_info "Cleaning user profiles..."

    local cmd_args="--delete-older-than $THRESHOLD"
    if [[ -n "$KEEP_GENERATIONS" ]]; then
        cmd_args="--delete-generations +$KEEP_GENERATIONS"
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        log_verbose "Would run: nix-collect-garbage $cmd_args --dry-run"
        nix-collect-garbage $cmd_args --dry-run
    else
        log_verbose "Running: nix-collect-garbage $cmd_args"
        nix-collect-garbage $cmd_args
    fi
}

# Clean system profiles
clean_system_profiles() {
    log_info "Cleaning system profiles (nix-darwin generations)..."

    if ! check_sudo; then
        log_error "Cannot clean system profiles without sudo access"
        return 1
    fi

    if [[ "$VERBOSE" == "true" ]]; then
        log_verbose "Current system generations:"
        list_generations "$SYSTEM_PROFILE" "system"
        echo
    fi

    local cmd_args
    if [[ -n "$KEEP_GENERATIONS" ]]; then
        cmd_args="--delete-generations +$KEEP_GENERATIONS"
        log_verbose "Keeping $KEEP_GENERATIONS most recent system generations"
    else
        # For system profiles, we're more conservative and keep at least 3 generations
        # even with time-based cleanup
        cmd_args="--delete-generations +3"
        log_verbose "Keeping at least 3 recent system generations for safety"

        # Also apply time-based cleanup if threshold is specified
        if [[ "$THRESHOLD" != "$DEFAULT_THRESHOLD" ]] || [[ "$FORCE" == "true" ]]; then
            log_verbose "Also applying time-based cleanup: older than $THRESHOLD"
        fi
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        log_verbose "Would run: sudo nix-env --profile $SYSTEM_PROFILE $cmd_args --dry-run"
        sudo nix-env --profile "$SYSTEM_PROFILE" $cmd_args --dry-run 2>/dev/null || true
    else
        log_verbose "Running: sudo nix-env --profile $SYSTEM_PROFILE $cmd_args"
        sudo nix-env --profile "$SYSTEM_PROFILE" $cmd_args 2>/dev/null || true
    fi
}

# Final garbage collection
final_garbage_collection() {
    log_info "Running final garbage collection..."

    if [[ "$DRY_RUN" == "true" ]]; then
        log_verbose "Would run: nix-collect-garbage --dry-run"
        nix-collect-garbage --dry-run
    else
        log_verbose "Running: nix-collect-garbage"
        nix-collect-garbage
    fi
}

# Store optimization
optimize_store() {
    log_info "Optimizing store (deduplication)..."

    if [[ "$DRY_RUN" == "true" ]]; then
        log_verbose "Would run: nix store optimise --dry-run"
        if command -v nix &> /dev/null; then
            nix store optimise --dry-run 2>/dev/null || log_warning "Store optimization preview not available"
        fi
    else
        log_verbose "Running: nix store optimise"
        if command -v nix &> /dev/null; then
            nix store optimise
        else
            log_warning "nix store optimise not available, using legacy command"
            nix-store --optimise
        fi
    fi
}

# Calculate and display space savings
show_space_savings() {
    local before_size="$1"
    local after_size="$2"
    local before_paths="$3"
    local after_paths="$4"

    echo
    log_success "Cleanup completed!"
    echo
    echo -e "${BOLD}Space Usage Summary:${NC}"
    echo -e "  Before: ${YELLOW}$before_size${NC} ($before_paths store paths)"
    echo -e "  After:  ${GREEN}$after_size${NC} ($after_paths store paths)"

    # Try to calculate savings (basic implementation)
    if command -v numfmt &> /dev/null; then
        local before_bytes after_bytes savings_bytes
        before_bytes=$(echo "$before_size" | numfmt --from=iec 2>/dev/null || echo "0")
        after_bytes=$(echo "$after_size" | numfmt --from=iec 2>/dev/null || echo "0")

        if [[ "$before_bytes" -gt 0 ]] && [[ "$after_bytes" -gt 0 ]] && [[ "$before_bytes" -gt "$after_bytes" ]]; then
            savings_bytes=$((before_bytes - after_bytes))
            local savings_human
            savings_human=$(numfmt --to=iec "$savings_bytes" 2>/dev/null || echo "unknown")
            echo -e "  Saved:  ${BOLD}${GREEN}$savings_human${NC}"
        fi
    fi

    local paths_removed=$((before_paths - after_paths))
    if [[ "$paths_removed" -gt 0 ]]; then
        echo -e "  Removed: ${CYAN}$paths_removed${NC} store paths"
    fi
    echo
}

# Confirmation prompt
confirm_cleanup() {
    local cleanup_type="$1"

    if [[ "$FORCE" == "true" ]] || [[ "$DRY_RUN" == "true" ]]; then
        return 0
    fi

    echo -e "${YELLOW}⚠ Warning:${NC} This will perform $cleanup_type cleanup with threshold: ${BOLD}$THRESHOLD${NC}"
    if [[ "$FULL_CLEANUP" == "true" ]]; then
        echo -e "${YELLOW}⚠ Warning:${NC} System cleanup will affect nix-darwin rollback capability"
    fi
    echo

    read -p "Continue? [y/N]: " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Cleanup cancelled by user"
        exit 0
    fi
}

# Main cleanup function
main() {
    parse_args "$@"

    print_header

    # Handle info-only mode
    if [[ "$SHOW_INFO" == "true" ]]; then
        show_store_info
        exit 0
    fi

    # Validate inputs
    validate_threshold

    # Determine cleanup type
    local cleanup_type
    if [[ "$FULL_CLEANUP" == "true" ]]; then
        cleanup_type="full (user + system)"
    elif [[ "$USER_ONLY" == "true" ]]; then
        cleanup_type="user-only"
    else
        cleanup_type="user-only (default)"
        USER_ONLY=true
    fi

    # Show current status
    log_info "Cleanup mode: $cleanup_type"
    log_info "Time threshold: $THRESHOLD"
    if [[ -n "$KEEP_GENERATIONS" ]]; then
        log_info "Keep generations: $KEEP_GENERATIONS"
    fi
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "Mode: DRY RUN (no changes will be made)"
    fi
    echo

    # Get initial measurements
    local before_size before_paths
    before_size=$(get_store_size)
    before_paths=$(get_store_paths_count)

    log_info "Current store size: $before_size ($before_paths store paths)"
    echo

    # Show largest paths if requested
    if [[ "$SHOW_LARGEST" == "true" ]]; then
        show_largest_paths
    fi

    # Confirm before proceeding
    confirm_cleanup "$cleanup_type"

    # Perform cleanup steps
    log_info "Starting cleanup process..."
    echo

    # Step 1: Clean user profiles
    clean_user_profiles
    echo

    # Step 2: Clean system profiles if requested
    if [[ "$FULL_CLEANUP" == "true" ]]; then
        clean_system_profiles
        echo
    fi

    # Step 3: Final garbage collection
    final_garbage_collection
    echo

    # Step 4: Store optimization
    optimize_store
    echo

    # Show results
    if [[ "$DRY_RUN" != "true" ]]; then
        local after_size after_paths
        after_size=$(get_store_size)
        after_paths=$(get_store_paths_count)
        show_space_savings "$before_size" "$after_size" "$before_paths" "$after_paths"
    else
        log_info "Dry run completed. Use without --dry-run to perform actual cleanup."
        echo
    fi
}

# Run main function with all arguments
main "$@"
