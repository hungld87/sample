#!/usr/bin/env bash
set -euo pipefail

# generate-commands-for-agent.sh
# Generate command files for a specific AI assistant and script type.
# Usage: generate-commands-for-agent.sh <agent> <script> [output_dir]
#   agent: claude, gemini, copilot, cursor-agent, qwen, opencode, windsurf, codex, kilocode, auggie, roo, codebuddy, qoder, amp, shai, q, bob
#   script: sh or ps
#   output_dir: optional, defaults to current directory

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <agent> <script> [output_dir]" >&2
  exit 1
fi

AGENT="$1"
SCRIPT="$2"
OUTPUT_DIR="${3:-.}"

echo "Generating commands for $AGENT ($SCRIPT) in $OUTPUT_DIR"

rewrite_paths() {
  sed -E \
    -e 's@(/?)memory/@.hyperkit/memory/@g' \
    -e 's@(/?)scripts/@.hyperkit/scripts/@g' \
    -e 's@(/?)templates/@.hyperkit/templates/@g'
}

generate_commands() {
  local agent=$1 ext=$2 arg_format=$3 output_dir=$4 script_variant=$5
  mkdir -p "$output_dir"
  for template in templates/commands/*.md; do
    [[ -f "$template" ]] || continue
    local name description script_command agent_script_command body
    name=$(basename "$template" .md)
    
    # Normalize line endings
    file_content=$(tr -d '\r' < "$template")
    
    # Extract description and script command from YAML frontmatter
    description=$(printf '%s\n' "$file_content" | awk '/^description:/ {sub(/^description:[[:space:]]*/, ""); print; exit}')
    script_command=$(printf '%s\n' "$file_content" | awk -v sv="$script_variant" '/^[[:space:]]*'"$script_variant"':[[:space:]]*/ {sub(/^[[:space:]]*'"$script_variant"':[[:space:]]*/, ""); print; exit}')
    
    if [[ -z $script_command ]]; then
      echo "Warning: no script command found for $script_variant in $template" >&2
      script_command="(Missing script command for $script_variant)"
    fi
    
    # Extract agent_script command from YAML frontmatter if present
    agent_script_command=$(printf '%s\n' "$file_content" | awk '
      /^agent_scripts:$/ { in_agent_scripts=1; next }
      in_agent_scripts && /^[[:space:]]*'"$script_variant"':[[:space:]]*/ {
        sub(/^[[:space:]]*'"$script_variant"':[[:space:]]*/, "")
        print
        exit
      }
      in_agent_scripts && /^[a-zA-Z]/ { in_agent_scripts=0 }
    ')
    
    # Replace {SCRIPT} placeholder with the script command
    body=$(printf '%s\n' "$file_content" | sed "s|{SCRIPT}|${script_command}|g")
    
    # Replace {AGENT_SCRIPT} placeholder with the agent script command if found
    if [[ -n $agent_script_command ]]; then
      body=$(printf '%s\n' "$body" | sed "s|{AGENT_SCRIPT}|${agent_script_command}|g")
    fi
    
    # Remove the scripts: and agent_scripts: sections from frontmatter while preserving YAML structure
    body=$(printf '%s\n' "$body" | awk '
      /^---$/ { print; if (++dash_count == 1) in_frontmatter=1; else in_frontmatter=0; next }
      in_frontmatter && /^scripts:$/ { skip_scripts=1; next }
      in_frontmatter && /^agent_scripts:$/ { skip_scripts=1; next }
      in_frontmatter && /^[a-zA-Z].*:/ && skip_scripts { skip_scripts=0 }
      in_frontmatter && skip_scripts && /^[[:space:]]/ { next }
      { print }
    ')
    
    # Apply other substitutions
    body=$(printf '%s\n' "$body" | sed "s/{ARGS}/$arg_format/g" | sed "s/__AGENT__/$agent/g" | rewrite_paths)
    
    case $ext in
      toml)
        body=$(printf '%s\n' "$body" | sed 's/\\/\\\\/g')
        { echo "description = \"$description\""; echo; echo "prompt = \"\"\""; echo "$body"; echo "\"\"\""; } > "$output_dir/devkit.$name.$ext" ;;
      md)
        echo "$body" > "$output_dir/devkit.$name.$ext" ;;
      agent.md)
        echo "$body" > "$output_dir/devkit.$name.$ext" ;;
    esac
  done
}

generate_copilot_prompts() {
  local agents_dir=$1 prompts_dir=$2
  mkdir -p "$prompts_dir"
  
  # Generate a .prompt.md file for each .agent.md file
  for agent_file in "$agents_dir"/devkit.*.agent.md; do
    [[ -f "$agent_file" ]] || continue
    
    local basename=$(basename "$agent_file" .agent.md)
    local prompt_file="$prompts_dir/${basename}.prompt.md"
    
    # Create prompt file with agent frontmatter
    cat > "$prompt_file" <<EOF
---
agent: ${basename}
---
EOF
  done
}

generate_for_agent() {
  local agent=$1 script=$2 output_dir=$3
  echo "Generating commands for $agent ($script) in $output_dir"
  
  case $agent in
    claude)
      mkdir -p "$output_dir/.claude/commands"
      generate_commands claude md "\$ARGUMENTS" "$output_dir/.claude/commands" "$script" ;;
    gemini)
      mkdir -p "$output_dir/.gemini/commands"
      generate_commands gemini toml "{{args}}" "$output_dir/.gemini/commands" "$script" ;;
    copilot)
      mkdir -p "$output_dir/.github/agents"
      generate_commands copilot agent.md "\$ARGUMENTS" "$output_dir/.github/agents" "$script"
      # Generate companion prompt files
      generate_copilot_prompts "$output_dir/.github/agents" "$output_dir/.github/prompts"
      ;;
    cursor-agent)
      mkdir -p "$output_dir/.cursor/commands"
      generate_commands cursor-agent md "\$ARGUMENTS" "$output_dir/.cursor/commands" "$script" ;;
    qwen)
      mkdir -p "$output_dir/.qwen/commands"
      generate_commands qwen toml "{{args}}" "$output_dir/.qwen/commands" "$script" ;;
    opencode)
      mkdir -p "$output_dir/.opencode/command"
      generate_commands opencode md "\$ARGUMENTS" "$output_dir/.opencode/command" "$script" ;;
    windsurf)
      mkdir -p "$output_dir/.windsurf/workflows"
      generate_commands windsurf md "\$ARGUMENTS" "$output_dir/.windsurf/workflows" "$script" ;;
    codex)
      mkdir -p "$output_dir/.codex/prompts"
      generate_commands codex md "\$ARGUMENTS" "$output_dir/.codex/prompts" "$script" ;;
    kilocode)
      mkdir -p "$output_dir/.kilocode/workflows"
      generate_commands kilocode md "\$ARGUMENTS" "$output_dir/.kilocode/workflows" "$script" ;;
    auggie)
      mkdir -p "$output_dir/.augment/commands"
      generate_commands auggie md "\$ARGUMENTS" "$output_dir/.augment/commands" "$script" ;;
    roo)
      mkdir -p "$output_dir/.roo/commands"
      generate_commands roo md "\$ARGUMENTS" "$output_dir/.roo/commands" "$script" ;;
    codebuddy)
      mkdir -p "$output_dir/.codebuddy/commands"
      generate_commands codebuddy md "\$ARGUMENTS" "$output_dir/.codebuddy/commands" "$script" ;;
    qoder)
      mkdir -p "$output_dir/.qoder/commands"
      generate_commands qoder md "\$ARGUMENTS" "$output_dir/.qoder/commands" "$script" ;;
    amp)
      mkdir -p "$output_dir/.agents/commands"
      generate_commands amp md "\$ARGUMENTS" "$output_dir/.agents/commands" "$script" ;;
    shai)
      mkdir -p "$output_dir/.shai/commands"
      generate_commands shai md "\$ARGUMENTS" "$output_dir/.shai/commands" "$script" ;;
    q)
      mkdir -p "$output_dir/.amazonq/prompts"
      generate_commands q md "\$ARGUMENTS" "$output_dir/.amazonq/prompts" "$script" ;;
    bob)
      mkdir -p "$output_dir/.bob/commands"
      generate_commands bob md "\$ARGUMENTS" "$output_dir/.bob/commands" "$script" ;;
  esac
}

generate_for_agent "$AGENT" "$SCRIPT" "$OUTPUT_DIR"

