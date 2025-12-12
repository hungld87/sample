#!/usr/bin/env bash

# Update agent context files with information from plan.md
#
# This script maintains AI agent context files by parsing feature specifications 
# and updating agent-specific configuration files with project information.
#
# MAIN FUNCTIONS:
# 1. Environment Validation
#    - Verifies git repository structure and branch information
#    - Checks for required plan.md files and templates
#    - Validates file permissions and accessibility
#
# 2. Plan Data Extraction
#    - Parses plan.md files to extract project metadata
#    - Identifies language/version, frameworks, databases, and project types
#    - Handles missing or incomplete specification data gracefully
#
# 3. Agent File Management
#    - Creates new agent context files from templates when needed
#    - Updates existing agent files with new project information
#    - Preserves manual additions and custom configurations
#    - Supports multiple AI agent formats and directory structures
#
# 4. Content Generation
#    - Generates language-specific build/test commands
#    - Creates appropriate project directory structures
#    - Updates technology stacks and recent changes sections
#    - Maintains consistent formatting and timestamps
#
# 5. Multi-Agent Support
#    - Handles agent-specific file paths and naming conventions
#    - Supports: Claude, Gemini, Copilot, Cursor, Qwen, opencode, Codex, Windsurf, Kilo Code, Auggie CLI, Roo Code, CodeBuddy CLI, Qoder CLI, Amp, SHAI, or Amazon Q Developer CLI
#    - Can update single agents or all existing agent files
#    - Creates default Claude file if no agent files exist
#
# Usage: ./update-agent-context.sh [agent_type]
# Agent types: claude|gemini|copilot|cursor-agent|qwen|opencode|codex|windsurf|kilocode|auggie|shai|q|bob|qoder
# Leave empty to update all existing agent files

set -e

# Enable strict error handling
set -u
set -o pipefail

#==============================================================================
# Configuration and Global Variables
#==============================================================================

# Get script directory and load common functions
SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Get all paths and variables from common functions
eval $(get_feature_paths)

NEW_PLAN="$IMPL_PLAN"  # Alias for compatibility with existing code
AGENT_TYPE="${1:-}"

# Agent-specific file paths for Hyper-Dev project
CLAUDE_FILE="$REPO_ROOT/CLAUDE.md"
GEMINI_FILE="$REPO_ROOT/GEMINI.md"
COPILOT_FILE="$REPO_ROOT/.github/agents/copilot-instructions.md"
CURSOR_FILE="$REPO_ROOT/.cursor/rules/hyper-dev-rules.mdc"
QWEN_FILE="$REPO_ROOT/QWEN.md"
AGENTS_FILE="$REPO_ROOT/AGENTS.md"
WINDSURF_FILE="$REPO_ROOT/.windsurf/rules/hyper-dev-rules.md"
KILOCODE_FILE="$REPO_ROOT/.kilocode/rules/hyper-dev-rules.md"
AUGGIE_FILE="$REPO_ROOT/.augment/rules/hyper-dev-rules.md"
ROO_FILE="$REPO_ROOT/.roo/rules/hyper-dev-rules.md"
CODEBUDDY_FILE="$REPO_ROOT/CODEBUDDY.md"
QODER_FILE="$REPO_ROOT/QODER.md"
AMP_FILE="$REPO_ROOT/AGENTS.md"
SHAI_FILE="$REPO_ROOT/SHAI.md"
Q_FILE="$REPO_ROOT/AGENTS.md"
BOB_FILE="$REPO_ROOT/AGENTS.md"

# Template file for Hyper-Dev project
TEMPLATE_FILE="$REPO_ROOT/templates/agent-file-template.md"

# Agent-specific directories for commands
CLAUDE_DIR="$REPO_ROOT/.claude"
GEMINI_DIR="$REPO_ROOT/.gemini"
COPILOT_DIR="$REPO_ROOT/.github/agents"
CURSOR_DIR="$REPO_ROOT/.cursor/rules"
QWEN_DIR="$REPO_ROOT/.qwen"
AGENTS_DIR="$REPO_ROOT/.agents"
WINDSURF_DIR="$REPO_ROOT/.windsurf/rules"
KILOCODE_DIR="$REPO_ROOT/.kilocode/rules"
AUGGIE_DIR="$REPO_ROOT/.augment/rules"
ROO_DIR="$REPO_ROOT/.roo/rules"
CODEBUDDY_DIR="$REPO_ROOT/.codebuddy"
QODER_DIR="$REPO_ROOT/.qoder"
AMP_DIR="$REPO_ROOT/.amp"
SHAI_DIR="$REPO_ROOT/.shai"
Q_DIR="$REPO_ROOT/.q"
BOB_DIR="$REPO_ROOT/.bob"

# Agent-specific extensions
CLAUDE_EXT="md"
GEMINI_EXT="toml"
COPILOT_EXT="agent.md"
CURSOR_EXT="md"
QWEN_EXT="toml"
AGENTS_EXT="md"
WINDSURF_EXT="md"
KILOCODE_EXT="md"
AUGGIE_EXT="md"
ROO_EXT="md"
CODEBUDDY_EXT="md"
QODER_EXT="md"
AMP_EXT="md"
SHAI_EXT="md"
Q_EXT="md"
BOB_EXT="md"

# Agent-specific commands directories
CLAUDE_COMMANDS_DIR="$CLAUDE_DIR/commands"
GEMINI_COMMANDS_DIR="$GEMINI_DIR/commands"
COPILOT_COMMANDS_DIR="$REPO_ROOT/.github/agents"
CURSOR_COMMANDS_DIR="$CURSOR_DIR/commands"
QWEN_COMMANDS_DIR="$QWEN_DIR/commands"
AGENTS_COMMANDS_DIR="$AGENTS_DIR/command"
WINDSURF_COMMANDS_DIR="$WINDSURF_DIR/workflows"
KILOCODE_COMMANDS_DIR="$KILOCODE_DIR/workflows"
AUGGIE_COMMANDS_DIR="$AUGGIE_DIR/commands"
ROO_COMMANDS_DIR="$ROO_DIR/commands"
CODEBUDDY_COMMANDS_DIR="$CODEBUDDY_DIR/commands"
QODER_COMMANDS_DIR="$QODER_DIR/commands"
AMP_COMMANDS_DIR="$AMP_DIR/commands"
SHAI_COMMANDS_DIR="$SHAI_DIR/commands"
Q_COMMANDS_DIR="$Q_DIR/prompts"
BOB_COMMANDS_DIR="$BOB_DIR/commands"

copy_commands_to_agent_dir() {
    local commands_dir="$1"
    local ext="$2"
    
    mkdir -p "$commands_dir"
    
    # Copy command templates
    for template in "$REPO_ROOT/templates/commands/"*.md; do
        [[ -f "$template" ]] || continue
        local name=$(basename "$template" .md)
        cp "$template" "$commands_dir/devkit.$name.$ext"
    done
    
    log_info "Copied command templates to $commands_dir with ext $ext"
}

# Global variables for parsed plan data
NEW_LANG=""
NEW_FRAMEWORK=""
NEW_DB=""
NEW_PROJECT_TYPE=""

#==============================================================================
# Utility Functions
#==============================================================================

log_info() {
    echo "INFO: $1"
}

log_success() {
    echo "✓ $1"
}

log_error() {
    echo "ERROR: $1" >&2
}

log_warning() {
    echo "WARNING: $1" >&2
}

# Cleanup function for temporary files
cleanup() {
    local exit_code=$?
    rm -f /tmp/agent_update_*_$$
    rm -f /tmp/manual_additions_$$
    exit $exit_code
}

# Set up cleanup trap
trap cleanup EXIT INT TERM

#==============================================================================
# Validation Functions
#==============================================================================

validate_environment() {
    # Check if we have a current branch/feature (git or non-git)
    if [[ -z "$CURRENT_BRANCH" ]]; then
        log_error "Unable to determine current feature"
        if [[ "$HAS_GIT" == "true" ]]; then
            log_info "Make sure you're on a feature branch"
        else
            log_info "Set HYPER_KIT_FEATURE environment variable or create a feature first"
        fi
        exit 1
    fi
    
    # Check if plan.md exists
    if [[ ! -f "$NEW_PLAN" ]]; then
        log_error "No plan.md found at $NEW_PLAN"
        log_info "Make sure you're working on a feature with a corresponding spec directory"
        if [[ "$HAS_GIT" != "true" ]]; then
            log_info "Use: export HYPER_KIT_FEATURE=your-feature-name or create a new feature first"
        fi
        exit 1
    fi
    
    # Check if template exists (needed for new files)
    if [[ ! -f "$TEMPLATE_FILE" ]]; then
        log_warning "Template file not found at $TEMPLATE_FILE"
        log_warning "Creating new agent files will fail"
    fi
}

#==============================================================================
# Plan Parsing Functions
#==============================================================================

extract_plan_field() {
    local field_pattern="$1"
    local plan_file="$2"
    
    # Try different patterns for the new template format
    local value=""
    
    # Pattern 1: **Field**: value
    value=$(grep "^\*\*${field_pattern}\*\*: " "$plan_file" 2>/dev/null | \
        head -1 | \
        sed "s|^\*\*${field_pattern}\*\*: ||" | \
        sed 's/^[ \t]*//;s/[ \t]*$//' || echo "")
    
    # Pattern 2: - **Field**: value (for list items)
    if [[ -z "$value" ]]; then
        value=$(grep "^- \*\*${field_pattern}\*\*: " "$plan_file" 2>/dev/null | \
            head -1 | \
            sed "s|^- \*\*${field_pattern}\*\*: ||" | \
            sed 's/^[ \t]*//;s/[ \t]*$//' || echo "")
    fi
    
    # Pattern 3: Field: value (for simple fields)
    if [[ -z "$value" ]]; then
        value=$(grep "^${field_pattern}: " "$plan_file" 2>/dev/null | \
            head -1 | \
            sed "s|^${field_pattern}: ||" | \
            sed 's/^[ \t]*//;s/[ \t]*$//' || echo "")
    fi
    
    # Filter out placeholder values
    if [[ "$value" == "["*"]" ]] || [[ "$value" == "[ "* ]] || [[ "$value" == *"TODO"* ]]; then
        echo ""
    else
        echo "$value"
    fi
}

parse_plan_data() {
    local plan_file="$1"
    
    if [[ ! -f "$plan_file" ]]; then
        log_error "Plan file not found: $plan_file"
        return 1
    fi
    
    if [[ ! -r "$plan_file" ]]; then
        log_error "Plan file is not readable: $plan_file"
        return 1
    fi
    
    log_info "Parsing plan data from $plan_file"
    
    # Extract information from the new porting template format
    NEW_LANG=$(extract_plan_field "Target Language" "$plan_file")
    if [[ -z "$NEW_LANG" ]]; then
        NEW_LANG=$(extract_plan_field "Source Language" "$plan_file")
    fi
    
    NEW_FRAMEWORK=$(extract_plan_field "Dependencies" "$plan_file")
    NEW_DB=$(extract_plan_field "Storage" "$plan_file")  # May not be relevant for function porting
    NEW_PROJECT_TYPE="Function Porting"
    
    # Try to extract additional context
    local source_lang=$(extract_plan_field "Source Language" "$plan_file")
    local function_name=$(extract_plan_field "Function Name" "$plan_file")
    
    # Log what we found
    if [[ -n "$function_name" ]]; then
        log_info "Found function: $function_name"
    fi
    
    if [[ -n "$source_lang" ]]; then
        log_info "Found source language: $source_lang"
    fi
    
    if [[ -n "$NEW_LANG" ]]; then
        log_info "Found target language: $NEW_LANG"
    else
        log_warning "No target language information found in plan"
    fi
    
    if [[ -n "$NEW_FRAMEWORK" ]]; then
        log_info "Found dependencies: $NEW_FRAMEWORK"
    fi
    
    if [[ -n "$NEW_DB" ]] && [[ "$NEW_DB" != "N/A" ]]; then
        log_info "Found storage: $NEW_DB"
    fi
    
    log_info "Project type: $NEW_PROJECT_TYPE"
}

format_technology_stack() {
    local lang="$1"
    local framework="$2"
    local parts=()
    
    # Add non-empty parts
    [[ -n "$lang" && "$lang" != "NEEDS CLARIFICATION" ]] && parts+=("$lang")
    [[ -n "$framework" && "$framework" != "NEEDS CLARIFICATION" && "$framework" != "N/A" ]] && parts+=("$framework")
    
    # Join with proper formatting
    if [[ ${#parts[@]} -eq 0 ]]; then
        echo ""
    elif [[ ${#parts[@]} -eq 1 ]]; then
        echo "${parts[0]}"
    else
        # Join multiple parts with " + "
        local result="${parts[0]}"
        for ((i=1; i<${#parts[@]}; i++)); do
            result="$result + ${parts[i]}"
        done
        echo "$result"
    fi
}

#==============================================================================
# Template and Content Generation Functions
#==============================================================================

get_project_structure() {
    local project_type="$1"
    
    if [[ "$project_type" == *"web"* ]]; then
        echo "backend/\\nfrontend/\\ntests/"
    else
        echo "src/\\ntests/"
    fi
}

get_commands_for_language() {
    local lang="$1"
    
    case "$lang" in
        *"Python"*)
            echo "cd src && pytest && ruff check ."
            ;;
        *"Rust"*)
            echo "cargo test && cargo clippy"
            ;;
        *"JavaScript"*|*"TypeScript"*)
            echo "npm test \\&\\& npm run lint"
            ;;
        *)
            echo "# Add commands for $lang"
            ;;
    esac
}

get_language_conventions() {
    local lang="$1"
    echo "$lang: Follow standard conventions"
}

create_new_agent_file() {
    local target_file="$1"
    local temp_file="$2"
    local project_name="$3"
    local current_date="$4"
    
    if [[ ! -f "$TEMPLATE_FILE" ]]; then
        log_error "Template not found at $TEMPLATE_FILE"
        return 1
    fi
    
    if [[ ! -r "$TEMPLATE_FILE" ]]; then
        log_error "Template file is not readable: $TEMPLATE_FILE"
        return 1
    fi
    
    log_info "Creating new agent context file from template..."
    
    if ! cp "$TEMPLATE_FILE" "$temp_file"; then
        log_error "Failed to copy template file"
        return 1
    fi
    
    # Replace template placeholders
    local project_structure
    project_structure=$(get_project_structure "$NEW_PROJECT_TYPE")
    
    local commands
    commands=$(get_commands_for_language "$NEW_LANG")
    
    local language_conventions
    language_conventions=$(get_language_conventions "$NEW_LANG")
    
    # Perform substitutions with error checking using safer approach
    # Escape special characters for sed by using a different delimiter or escaping
    local escaped_lang=$(printf '%s\n' "$NEW_LANG" | sed 's/[\[\.*^$()+{}|]/\\&/g')
    local escaped_framework=$(printf '%s\n' "$NEW_FRAMEWORK" | sed 's/[\[\.*^$()+{}|]/\\&/g')
    local escaped_branch=$(printf '%s\n' "$CURRENT_BRANCH" | sed 's/[\[\.*^$()+{}|]/\\&/g')
    
    # Build technology stack and recent change strings conditionally
    local tech_stack
    if [[ -n "$escaped_lang" && -n "$escaped_framework" ]]; then
        tech_stack="- $escaped_lang + $escaped_framework ($escaped_branch)"
    elif [[ -n "$escaped_lang" ]]; then
        tech_stack="- $escaped_lang ($escaped_branch)"
    elif [[ -n "$escaped_framework" ]]; then
        tech_stack="- $escaped_framework ($escaped_branch)"
    else
        tech_stack="- ($escaped_branch)"
    fi

    local recent_change
    if [[ -n "$escaped_lang" && -n "$escaped_framework" ]]; then
        recent_change="- $escaped_branch: Added $escaped_lang + $escaped_framework"
    elif [[ -n "$escaped_lang" ]]; then
        recent_change="- $escaped_branch: Added $escaped_lang"
    elif [[ -n "$escaped_framework" ]]; then
        recent_change="- $escaped_branch: Added $escaped_framework"
    else
        recent_change="- $escaped_branch: Added"
    fi

    local substitutions=(
        "s|\[PROJECT NAME\]|$project_name|"
        "s|\[DATE\]|$current_date|"
        "s|\[FEATURE_NAME\]|$CURRENT_BRANCH|"
        "s|\[LANGUAGE\]|$NEW_LANG|"
        "s|\[FRAMEWORKS\]|$NEW_FRAMEWORK|"
        "s|\[STATUS\]|In Progress|"
        "s|\[BRIEF_DESCRIPTION\]|Feature implementation|"
        "s|\[PRIORITY_LEVEL\]|Medium|"
        "s|\[CHANGE_DESCRIPTION\]|Feature development|"
        "s|\[EXTRACTED FROM ALL PLAN.MD FILES\]|$tech_stack|"
        "s|\[ACTUAL STRUCTURE FROM PLANS\]|$project_structure|g"
        "s|\[ONLY COMMANDS FOR ACTIVE TECHNOLOGIES\]|$commands|"
        "s|\[LANGUAGE-SPECIFIC, ONLY FOR LANGUAGES IN USE\]|$language_conventions|"
        "s|\[LAST 3 FEATURES AND WHAT THEY ADDED\]|$recent_change|"
    )
    
    for substitution in "${substitutions[@]}"; do
        if ! sed -i.bak -e "$substitution" "$temp_file"; then
            log_error "Failed to perform substitution: $substitution"
            rm -f "$temp_file" "$temp_file.bak"
            return 1
        fi
    done
    
    # Convert \n sequences to actual newlines
    newline=$(printf '\n')
    sed -i.bak2 "s/\\\\n/${newline}/g" "$temp_file"
    
    # Clean up backup files
    rm -f "$temp_file.bak" "$temp_file.bak2"
    
    return 0
}




update_existing_agent_file() {
    local target_file="$1"
    local current_date="$2"
    
    log_info "Updating existing agent context file..."
    
    # Use a single temporary file for atomic update
    local temp_file
    temp_file=$(mktemp) || {
        log_error "Failed to create temporary file"
        return 1
    }
    
    # Process the file in one pass
    local tech_stack=$(format_technology_stack "$NEW_LANG" "$NEW_FRAMEWORK")
    local new_tech_entries=()
    local new_change_entry=""
    
    # Prepare new technology entries
    if [[ -n "$tech_stack" ]] && ! grep -q "$tech_stack" "$target_file"; then
        new_tech_entries+=("- $tech_stack ($CURRENT_BRANCH)")
    fi
    
    if [[ -n "$NEW_DB" ]] && [[ "$NEW_DB" != "N/A" ]] && [[ "$NEW_DB" != "NEEDS CLARIFICATION" ]] && ! grep -q "$NEW_DB" "$target_file"; then
        new_tech_entries+=("- $NEW_DB ($CURRENT_BRANCH)")
    fi
    
    # Prepare new change entry
    if [[ -n "$tech_stack" ]]; then
        new_change_entry="- $CURRENT_BRANCH: Added $tech_stack"
    elif [[ -n "$NEW_DB" ]] && [[ "$NEW_DB" != "N/A" ]] && [[ "$NEW_DB" != "NEEDS CLARIFICATION" ]]; then
        new_change_entry="- $CURRENT_BRANCH: Added $NEW_DB"
    fi
    
    # Check if sections exist in the file
    local has_active_technologies=0
    local has_recent_changes=0
    
    if grep -q "^## Active Technologies" "$target_file" 2>/dev/null; then
        has_active_technologies=1
    fi
    
    if grep -q "^## Recent Changes" "$target_file" 2>/dev/null; then
        has_recent_changes=1
    fi
    
    # Process file line by line
    local in_tech_section=false
    local in_changes_section=false
    local tech_entries_added=false
    local changes_entries_added=false
    local existing_changes_count=0
    local file_ended=false
    
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Handle Active Technologies section
        if [[ "$line" == "## Active Technologies" ]]; then
            echo "$line" >> "$temp_file"
            in_tech_section=true
            continue
        elif [[ $in_tech_section == true ]] && [[ "$line" =~ ^##[[:space:]] ]]; then
            # Add new tech entries before closing the section
            if [[ $tech_entries_added == false ]] && [[ ${#new_tech_entries[@]} -gt 0 ]]; then
                printf '%s\n' "${new_tech_entries[@]}" >> "$temp_file"
                tech_entries_added=true
            fi
            echo "$line" >> "$temp_file"
            in_tech_section=false
            continue
        elif [[ $in_tech_section == true ]] && [[ -z "$line" ]]; then
            # Add new tech entries before empty line in tech section
            if [[ $tech_entries_added == false ]] && [[ ${#new_tech_entries[@]} -gt 0 ]]; then
                printf '%s\n' "${new_tech_entries[@]}" >> "$temp_file"
                tech_entries_added=true
            fi
            echo "$line" >> "$temp_file"
            continue
        fi
        
        # Handle Recent Changes section
        if [[ "$line" == "## Recent Changes" ]]; then
            echo "$line" >> "$temp_file"
            # Add new change entry right after the heading
            if [[ -n "$new_change_entry" ]]; then
                echo "$new_change_entry" >> "$temp_file"
            fi
            in_changes_section=true
            changes_entries_added=true
            continue
        elif [[ $in_changes_section == true ]] && [[ "$line" =~ ^##[[:space:]] ]]; then
            echo "$line" >> "$temp_file"
            in_changes_section=false
            continue
        elif [[ $in_changes_section == true ]] && [[ "$line" == "- "* ]]; then
            # Keep only first 2 existing changes
            if [[ $existing_changes_count -lt 2 ]]; then
                echo "$line" >> "$temp_file"
                ((existing_changes_count++))
            fi
            continue
        fi
        
        # Update timestamp
        if [[ "$line" =~ \*\*Last\ updated\*\*:.*[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9] ]]; then
            echo "$line" | sed "s/[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]/$current_date/" >> "$temp_file"
        else
            echo "$line" >> "$temp_file"
        fi
    done < "$target_file"
    
    # Post-loop check: if we're still in the Active Technologies section and haven't added new entries
    if [[ $in_tech_section == true ]] && [[ $tech_entries_added == false ]] && [[ ${#new_tech_entries[@]} -gt 0 ]]; then
        printf '%s\n' "${new_tech_entries[@]}" >> "$temp_file"
        tech_entries_added=true
    fi
    
    # If sections don't exist, add them at the end of the file
    if [[ $has_active_technologies -eq 0 ]] && [[ ${#new_tech_entries[@]} -gt 0 ]]; then
        echo "" >> "$temp_file"
        echo "## Active Technologies" >> "$temp_file"
        printf '%s\n' "${new_tech_entries[@]}" >> "$temp_file"
        tech_entries_added=true
    fi
    
    if [[ $has_recent_changes -eq 0 ]] && [[ -n "$new_change_entry" ]]; then
        echo "" >> "$temp_file"
        echo "## Recent Changes" >> "$temp_file"
        echo "$new_change_entry" >> "$temp_file"
        changes_entries_added=true
    fi
    
    # Move temp file to target atomically
    if ! mv "$temp_file" "$target_file"; then
        log_error "Failed to update target file"
        rm -f "$temp_file"
        return 1
    fi
    
    return 0
}
#==============================================================================
# Main Agent File Update Function
#==============================================================================

update_agent_file() {
    local target_file="$1"
    local agent_name="$2"
    
    if [[ -z "$target_file" ]] || [[ -z "$agent_name" ]]; then
        log_error "update_agent_file requires target_file and agent_name parameters"
        return 1
    fi
    
    log_info "Updating $agent_name context file: $target_file"
    
    local project_name
    project_name=$(basename "$REPO_ROOT")
    local current_date
    current_date=$(date +%Y-%m-%d)
    
    # Create directory if it doesn't exist
    local target_dir
    target_dir=$(dirname "$target_file")
    if [[ ! -d "$target_dir" ]]; then
        if ! mkdir -p "$target_dir"; then
            log_error "Failed to create directory: $target_dir"
            return 1
        fi
    fi
    
    if [[ ! -f "$target_file" ]]; then
        # Create new file from template
        local temp_file
        temp_file=$(mktemp) || {
            log_error "Failed to create temporary file"
            return 1
        }
        
        if create_new_agent_file "$target_file" "$temp_file" "$project_name" "$current_date"; then
            if mv "$temp_file" "$target_file"; then
                log_success "Created new $agent_name context file"
            else
                log_error "Failed to move temporary file to $target_file"
                rm -f "$temp_file"
                return 1
            fi
        else
            log_error "Failed to create new agent file"
            rm -f "$temp_file"
            return 1
        fi
    else
        # Update existing file
        if [[ ! -r "$target_file" ]]; then
            log_error "Cannot read existing file: $target_file"
            return 1
        fi
        
        if [[ ! -w "$target_file" ]]; then
            log_error "Cannot write to existing file: $target_file"
            return 1
        fi
        
        if update_existing_agent_file "$target_file" "$current_date"; then
            log_success "Updated existing $agent_name context file"
        else
            log_error "Failed to update existing agent file"
            return 1
        fi
    fi
    
    return 0
}

#==============================================================================
# Agent Selection and Processing
#==============================================================================

update_specific_agent() {
    local agent_type="$1"
    
    case "$agent_type" in
        claude)
            update_agent_file "$CLAUDE_FILE" "Claude Code"
            copy_commands_to_agent_dir "$CLAUDE_COMMANDS_DIR" "$CLAUDE_EXT"
            ;;
        gemini)
            update_agent_file "$GEMINI_FILE" "Gemini CLI"
            copy_commands_to_agent_dir "$GEMINI_COMMANDS_DIR" "$GEMINI_EXT"
            ;;
        copilot)
            update_agent_file "$COPILOT_FILE" "GitHub Copilot"
            copy_commands_to_agent_dir "$COPILOT_COMMANDS_DIR" "$COPILOT_EXT"
            ;;
        cursor-agent)
            update_agent_file "$CURSOR_FILE" "Cursor IDE"
            copy_commands_to_agent_dir "$CURSOR_COMMANDS_DIR" "$CURSOR_EXT"
            ;;
        qwen)
            update_agent_file "$QWEN_FILE" "Qwen Code"
            copy_commands_to_agent_dir "$QWEN_COMMANDS_DIR" "$QWEN_EXT"
            ;;
        opencode)
            update_agent_file "$AGENTS_FILE" "opencode"
            copy_commands_to_agent_dir "$AGENTS_COMMANDS_DIR" "$AGENTS_EXT"
            ;;
        codex)
            update_agent_file "$AGENTS_FILE" "Codex CLI"
            copy_commands_to_agent_dir "$AGENTS_COMMANDS_DIR" "$AGENTS_EXT"
            ;;
        windsurf)
            update_agent_file "$WINDSURF_FILE" "Windsurf"
            copy_commands_to_agent_dir "$WINDSURF_COMMANDS_DIR" "$WINDSURF_EXT"
            ;;
        kilocode)
            update_agent_file "$KILOCODE_FILE" "Kilo Code"
            copy_commands_to_agent_dir "$KILOCODE_COMMANDS_DIR" "$KILOCODE_EXT"
            ;;
        auggie)
            update_agent_file "$AUGGIE_FILE" "Auggie CLI"
            copy_commands_to_agent_dir "$AUGGIE_COMMANDS_DIR" "$AUGGIE_EXT"
            ;;
        roo)
            update_agent_file "$ROO_FILE" "Roo Code"
            copy_commands_to_agent_dir "$ROO_COMMANDS_DIR" "$ROO_EXT"
            ;;
        codebuddy)
            update_agent_file "$CODEBUDDY_FILE" "CodeBuddy CLI"
            copy_commands_to_agent_dir "$CODEBUDDY_COMMANDS_DIR" "$CODEBUDDY_EXT"
            ;;
        qoder)
            update_agent_file "$QODER_FILE" "Qoder CLI"
            copy_commands_to_agent_dir "$QODER_COMMANDS_DIR" "$QODER_EXT"
            ;;
        amp)
            update_agent_file "$AMP_FILE" "Amp"
            copy_commands_to_agent_dir "$AMP_COMMANDS_DIR" "$AMP_EXT"
            ;;
        shai)
            update_agent_file "$SHAI_FILE" "SHAI"
            copy_commands_to_agent_dir "$SHAI_COMMANDS_DIR" "$SHAI_EXT"
            ;;
        q)
            update_agent_file "$Q_FILE" "Amazon Q Developer CLI"
            copy_commands_to_agent_dir "$Q_COMMANDS_DIR" "$Q_EXT"
            ;;
        bob)
            update_agent_file "$BOB_FILE" "IBM Bob"
            copy_commands_to_agent_dir "$BOB_COMMANDS_DIR" "$BOB_EXT"
            ;;
        *)
            log_error "Unknown agent type '$agent_type'"
            log_error "Expected: claude|gemini|copilot|cursor-agent|qwen|opencode|codex|windsurf|kilocode|auggie|roo|amp|shai|q|bob|qoder"
            exit 1
            ;;
    esac
}

update_all_existing_agents() {
    local found_agent=false
    
    if [[ -f "$CLAUDE_FILE" ]]; then
        update_agent_file "$CLAUDE_FILE" "Claude Code"
        copy_commands_to_agent_dir "$CLAUDE_COMMANDS_DIR" "$CLAUDE_EXT"
        found_agent=true
    fi
    
    if [[ -f "$GEMINI_FILE" ]]; then
        update_agent_file "$GEMINI_FILE" "Gemini CLI"
        copy_commands_to_agent_dir "$GEMINI_COMMANDS_DIR" "$GEMINI_EXT"
        found_agent=true
    fi
    
    if [[ -f "$COPILOT_FILE" ]]; then
        update_agent_file "$COPILOT_FILE" "GitHub Copilot"
        copy_commands_to_agent_dir "$COPILOT_COMMANDS_DIR" "$COPILOT_EXT"
        found_agent=true
    fi
    
    if [[ -f "$CURSOR_FILE" ]]; then
        update_agent_file "$CURSOR_FILE" "Cursor IDE"
        copy_commands_to_agent_dir "$CURSOR_COMMANDS_DIR" "$CURSOR_EXT"
        found_agent=true
    fi
    
    if [[ -f "$QWEN_FILE" ]]; then
        update_agent_file "$QWEN_FILE" "Qwen Code"
        copy_commands_to_agent_dir "$QWEN_COMMANDS_DIR" "$QWEN_EXT"
        found_agent=true
    fi
    
    if [[ -f "$AGENTS_FILE" ]]; then
        update_agent_file "$AGENTS_FILE" "Codex/opencode"
        copy_commands_to_agent_dir "$AGENTS_COMMANDS_DIR" "$AGENTS_EXT"
        found_agent=true
    fi
    
    if [[ -f "$WINDSURF_FILE" ]]; then
        update_agent_file "$WINDSURF_FILE" "Windsurf"
        copy_commands_to_agent_dir "$WINDSURF_COMMANDS_DIR" "$WINDSURF_EXT"
        found_agent=true
    fi
    
    if [[ -f "$KILOCODE_FILE" ]]; then
        update_agent_file "$KILOCODE_FILE" "Kilo Code"
        copy_commands_to_agent_dir "$KILOCODE_COMMANDS_DIR" "$KILOCODE_EXT"
        found_agent=true
    fi

    if [[ -f "$AUGGIE_FILE" ]]; then
        update_agent_file "$AUGGIE_FILE" "Auggie CLI"
        copy_commands_to_agent_dir "$AUGGIE_COMMANDS_DIR" "$AUGGIE_EXT"
        found_agent=true
    fi
    
    if [[ -f "$ROO_FILE" ]]; then
        update_agent_file "$ROO_FILE" "Roo Code"
        copy_commands_to_agent_dir "$ROO_COMMANDS_DIR" "$ROO_EXT"
        found_agent=true
    fi

    if [[ -f "$CODEBUDDY_FILE" ]]; then
        update_agent_file "$CODEBUDDY_FILE" "CodeBuddy CLI"
        copy_commands_to_agent_dir "$CODEBUDDY_COMMANDS_DIR" "$CODEBUDDY_EXT"
        found_agent=true
    fi

    if [[ -f "$SHAI_FILE" ]]; then
        update_agent_file "$SHAI_FILE" "SHAI"
        copy_commands_to_agent_dir "$SHAI_COMMANDS_DIR" "$SHAI_EXT"
        found_agent=true
    fi

    if [[ -f "$QODER_FILE" ]]; then
        update_agent_file "$QODER_FILE" "Qoder CLI"
        copy_commands_to_agent_dir "$QODER_COMMANDS_DIR" "$QODER_EXT"
        found_agent=true
    fi

    if [[ -f "$Q_FILE" ]]; then
        update_agent_file "$Q_FILE" "Amazon Q Developer CLI"
        copy_commands_to_agent_dir "$Q_COMMANDS_DIR" "$Q_EXT"
        found_agent=true
    fi
    
    if [[ -f "$BOB_FILE" ]]; then
        update_agent_file "$BOB_FILE" "IBM Bob"
        copy_commands_to_agent_dir "$BOB_COMMANDS_DIR" "$BOB_EXT"
        found_agent=true
    fi
    
    # If no agent files exist, create a default Claude file
    if [[ "$found_agent" == false ]]; then
        log_info "No existing agent files found, creating default Claude file..."
        update_agent_file "$CLAUDE_FILE" "Claude Code"
        copy_commands_to_agent_dir "$CLAUDE_COMMANDS_DIR" "$CLAUDE_EXT"
    fi
}
print_summary() {
    echo
    log_info "Summary of changes:"
    
    if [[ -n "$NEW_LANG" ]]; then
        echo "  - Added language: $NEW_LANG"
    fi
    
    if [[ -n "$NEW_FRAMEWORK" ]]; then
        echo "  - Added framework: $NEW_FRAMEWORK"
    fi
    
    if [[ -n "$NEW_DB" ]] && [[ "$NEW_DB" != "N/A" ]]; then
        echo "  - Added database: $NEW_DB"
    fi
    
    echo

    log_info "Usage: $0 [claude|gemini|copilot|cursor-agent|qwen|opencode|codex|windsurf|kilocode|auggie|codebuddy|shai|q|bob|qoder]"
}

#==============================================================================
# Main Execution
#==============================================================================

main() {
    # Validate environment before proceeding
    validate_environment
    
    log_info "=== Updating agent context files for feature $CURRENT_BRANCH ==="
    
    # Parse the plan file to extract project information
    if ! parse_plan_data "$NEW_PLAN"; then
        log_error "Failed to parse plan data"
        exit 1
    fi
    
    # Process based on agent type argument
    local success=true
    
    if [[ -z "$AGENT_TYPE" ]]; then
        # No specific agent provided - update all existing agent files
        log_info "No agent specified, updating all existing agent files..."
        if ! update_all_existing_agents; then
            success=false
        fi
    else
        # Specific agent provided - update only that agent
        log_info "Updating specific agent: $AGENT_TYPE"
        if ! update_specific_agent "$AGENT_TYPE"; then
            success=false
        fi
    fi
    
    # Print summary
    print_summary
    
    if [[ "$success" == true ]]; then
        log_success "Agent context update completed successfully"
        exit 0
    else
        log_error "Agent context update completed with errors"
        exit 1
    fi
}

# Execute main function if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi

