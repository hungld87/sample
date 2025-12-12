#!/usr/bin/env bash

set -e

# Parse command line arguments
PLAN_NAME="plan.md"
OUTPUT_DIR="."
JSON_MODE=false
ARGS=()

for arg in "$@"; do
    case "$arg" in
        --json) 
            JSON_MODE=true 
            ;;
        --name=*)
            PLAN_NAME="${arg#*=}"
            ;;
        --dir=*)
            OUTPUT_DIR="${arg#*=}"
            ;;
        --help|-h) 
            echo "Usage: $0 [--name=plan.md] [--dir=.] [--json]"
            echo "  --name    Name of the plan file (default: plan.md)"
            echo "  --dir     Output directory (default: current directory)"
            echo "  --json    Output results in JSON format"
            echo "  --help    Show this help message"
            exit 0 
            ;;
        *) 
            ARGS+=("$arg") 
            ;;
    esac
done

# Get script directory and load common functions
SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Get repo root
REPO_ROOT=$(get_repo_root)

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"

# Set plan path
PLAN_PATH="$OUTPUT_DIR/$PLAN_NAME"

# Copy plan template if it exists
TEMPLATE="$REPO_ROOT/templates/plan-template.md"
if [[ -f "$TEMPLATE" ]]; then
    cp "$TEMPLATE" "$PLAN_PATH"
    echo "Copied plan template to $PLAN_PATH"
else
    echo "Warning: Plan template not found at $TEMPLATE"
    # Create a basic plan file if template doesn't exist
    cat > "$PLAN_PATH" << 'EOF'
# Implementation Plan

## Overview
Brief description of what this plan covers.

## Goals
- Goal 1
- Goal 2

## Tasks
1. Task 1
2. Task 2

## Timeline
- Phase 1: Description
- Phase 2: Description

## Dependencies
- Dependency 1
- Dependency 2

## Success Criteria
- Criteria 1
- Criteria 2
EOF
    echo "Created basic plan template at $PLAN_PATH"
fi

# Output results
if $JSON_MODE; then
    printf '{"plan_path":"%s","template_used":"%s"}\n' "$PLAN_PATH" "$TEMPLATE"
else
    echo "Plan created: $PLAN_PATH"
    echo "Template used: $TEMPLATE"
fi

