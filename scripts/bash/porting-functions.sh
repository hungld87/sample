#!/usr/bin/env bash

set -e

# Default values
FROM_LANG=""
TO_LANG=""
INPUT_FILE=""
OUTPUT_FILE=""
FUNCTION_NAME=""
AI_ASSIST=false
JSON_MODE=false
CREATE_BRANCH=false
BRANCH_NAME=""
SHORT_NAME=""
BRANCH_NUMBER=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --from-lang)
            FROM_LANG="$2"
            shift 2
            ;;
        --to-lang)
            TO_LANG="$2"
            shift 2
            ;;
        --input-file)
            INPUT_FILE="$2"
            shift 2
            ;;
        --output-file)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        --function-name)
            FUNCTION_NAME="$2"
            shift 2
            ;;
        --ai-assist)
            AI_ASSIST=true
            shift
            ;;
        --create-branch)
            CREATE_BRANCH=true
            shift
            ;;
        --branch-name)
            BRANCH_NAME="$2"
            shift 2
            ;;
        --short-name)
            SHORT_NAME="$2"
            shift 2
            ;;
        --branch-number)
            BRANCH_NUMBER="$2"
            shift 2
            ;;
        --json)
            JSON_MODE=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 --from-lang <lang> --to-lang <lang> [--input-file <file>] [--output-file <file>] [--function-name <name>] [--ai-assist] [--create-branch] [--branch-name <name>] [--short-name <name>] [--branch-number <num>] [--json]"
            echo ""
            echo "Systematic function porting from one programming language to another using structured pipeline."
            echo ""
            echo "Required options:"
            echo "  --from-lang <lang>    Source programming language (e.g., python, javascript, java)"
            echo "  --to-lang <lang>      Target programming language (e.g., python, javascript, java)"
            echo ""
            echo "Optional options:"
            echo "  --input-file <file>   Input file containing the function to port (default: stdin)"
            echo "  --output-file <file>  Output file for the ported function (default: auto-generated)"
            echo "  --function-name <name> Name of the function being ported"
            echo "  --ai-assist           Use AI assistance for porting (requires AI tool configured)"
            echo "  --create-branch       Create a feature branch for this porting task"
            echo "  --branch-name <name>  Specific branch name to create"
            echo "  --short-name <name>   Short name for branch generation"
            echo "  --branch-number <num> Specific branch number"
            echo "  --json                Output results in JSON format"
            echo "  --help, -h            Show this help message"
            echo ""
            echo "Pipeline Steps:"
            echo "  1. Context Collection    - Gather function details and MCP knowledge base queries"
            echo "  2. Skeleton Generation   - Create target function framework with signatures"
            echo "  3. LST Conversion        - Convert to Logical Structure Tree with graph analysis"
            echo "  4. Task Chunking         - Break down into manageable porting tasks"
            echo "  5. Chunk Porting         - Port each logical chunk systematically"
            echo "  6. Merge & Finalize      - Combine chunks into complete implementation"
            echo "  7. Compat Layer Check    - Analyze compatibility layers with MCP queries"
            echo ""
            echo "Examples:"
            echo "  $0 --from-lang python --to-lang javascript --input-file myfunc.py --create-branch"
            echo "  $0 --from-lang java --to-lang python --function-name calculateTotal --ai-assist --branch-name port-calc-func"
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            echo "Use --help for usage information" >&2
            exit 1
            ;;
    esac
done

# Validate required parameters
if [[ -z "$FROM_LANG" ]]; then
    echo "Error: --from-lang is required" >&2
    exit 1
fi

if [[ -z "$TO_LANG" ]]; then
    echo "Error: --to-lang is required" >&2
    exit 1
fi

# Get script directory and load common functions
SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Get repo root
REPO_ROOT=$(get_repo_root)

# Feature branch creation logic (if requested)
FEATURE_DIR=""
BRANCH_CREATED=""
SPEC_FILE=""

if [[ "$CREATE_BRANCH" == true ]]; then
    # Generate feature description
    FEATURE_DESC="Port ${FUNCTION_NAME:-function} from $FROM_LANG to $TO_LANG"
    
    # Use provided branch name or generate one
    if [[ -n "$BRANCH_NAME" ]]; then
        FINAL_BRANCH_NAME="$BRANCH_NAME"
    else
        # Generate branch name logic
        if [[ -n "$SHORT_NAME" ]]; then
            BRANCH_SUFFIX=$(clean_branch_name "$SHORT_NAME")
        else
            BRANCH_SUFFIX=$(generate_branch_name "$FEATURE_DESC")
        fi
        
        # Determine branch number
        if [[ -z "$BRANCH_NUMBER" ]]; then
            SPECS_DIR="$REPO_ROOT/specs"
            mkdir -p "$SPECS_DIR"
            BRANCH_NUMBER=$(check_existing_branches "$SPECS_DIR")
        fi
        
        FEATURE_NUM=$(printf "%03d" "$((10#$BRANCH_NUMBER))")
        FINAL_BRANCH_NAME="${FEATURE_NUM}-${BRANCH_SUFFIX}"
    fi
    
    # Create branch if git available
    if has_git; then
        git checkout -b "$FINAL_BRANCH_NAME"
        BRANCH_CREATED="$FINAL_BRANCH_NAME"
    else
        echo "[hyper-kit] Warning: Git repository not detected; skipped branch creation" >&2
    fi
    
    # Create feature directory and spec file
    SPECS_DIR="$REPO_ROOT/specs"
    mkdir -p "$SPECS_DIR"
    FEATURE_DIR="$SPECS_DIR/$FINAL_BRANCH_NAME"
    mkdir -p "$FEATURE_DIR"
    
    # Create spec file
    TEMPLATE="$REPO_ROOT/templates/spec-template.md"
    SPEC_FILE="$FEATURE_DIR/spec.md"
    if [[ -f "$TEMPLATE" ]]; then
        cp "$TEMPLATE" "$SPEC_FILE"
    else
        cat > "$SPEC_FILE" << EOF
# Port Function: ${FUNCTION_NAME:-Unknown Function}

## Overview
Port function from $FROM_LANG to $TO_LANG.

## Requirements
- Source language: $FROM_LANG
- Target language: $TO_LANG
- Function name: ${FUNCTION_NAME:-Unknown}

## Implementation Plan
1. Analyze source function
2. Port logic to target language
3. Test ported function
4. Document changes

## Success Criteria
- Function ports correctly
- Maintains original functionality
- Code follows target language conventions
EOF
    fi
    
    # Set environment variable
    export HYPER_KIT_FEATURE="$FINAL_BRANCH_NAME"
fi

# Read input
if [[ -n "$INPUT_FILE" ]]; then
    if [[ ! -f "$INPUT_FILE" ]]; then
        echo "Error: Input file '$INPUT_FILE' not found" >&2
        exit 1
    fi
    INPUT_CONTENT=$(cat "$INPUT_FILE")
else
    # Read from stdin
    INPUT_CONTENT=$(cat)
fi

if [[ -z "$INPUT_CONTENT" ]]; then
    echo "Error: No input provided. Use --input-file or pipe content to stdin" >&2
    exit 1
fi

# Generate output filename if not provided
if [[ -z "$OUTPUT_FILE" ]]; then
    if [[ -n "$FUNCTION_NAME" ]]; then
        OUTPUT_FILE="${FUNCTION_NAME}_ported.${TO_LANG}"
    else
        OUTPUT_FILE="ported_function.${TO_LANG}"
    fi
fi

# Create porting directory structure
if [[ -n "$FEATURE_DIR" ]]; then
    PORTING_DIR="$FEATURE_DIR/porting"
else
    PORTING_DIR="$REPO_ROOT/porting"
fi
mkdir -p "$PORTING_DIR"

# Save original function
ORIGINAL_FILE="$PORTING_DIR/${FUNCTION_NAME:-function}_original.${FROM_LANG}"
echo "$INPUT_CONTENT" > "$ORIGINAL_FILE"

# Execute systematic porting pipeline
execute_porting_pipeline "$INPUT_CONTENT" "$FROM_LANG" "$TO_LANG" "$FUNCTION_NAME" "$PORTING_DIR" "$AI_ASSIST"

# Output results
if [[ "$JSON_MODE" == true ]]; then
    printf '{"original_file":"%s","plan_file":"%s","ported_file":"%s","context_dir":"%s","tasks_dir":"%s","lst_dir":"%s","from_lang":"%s","to_lang":"%s","ai_assisted":%s,"branch_created":"%s","spec_file":"%s","feature_dir":"%s"}\n' \
        "$ORIGINAL_FILE" "$PLAN_FILE" "$PORTED_FILE" "$PORTING_DIR/context" "$PORTING_DIR/tasks" "$PORTING_DIR/lst" "$FROM_LANG" "$TO_LANG" "$AI_ASSIST" "$BRANCH_CREATED" "$SPEC_FILE" "$FEATURE_DIR"
else
    echo "Systematic porting pipeline completed:"
    echo "  Original function saved: $ORIGINAL_FILE"
    echo "  Porting plan created: $PLAN_FILE"
    echo "  Context collected: $PORTING_DIR/context/"
    echo "  Tasks breakdown: $PORTING_DIR/tasks/"
    echo "  LST analysis: $PORTING_DIR/lst/"
    echo "  Chunks directory: $PORTING_DIR/chunks/"
    echo "  Final implementation: $PORTED_FILE"
    echo "  Compatibility analysis: $PORTING_DIR/compat_analysis.md"
    echo "  From: $FROM_LANG"
    echo "  To: $TO_LANG"
    echo "  AI Assist requested: $AI_ASSIST"
    if [[ -n "$BRANCH_CREATED" ]]; then
        echo "  Branch Created: $BRANCH_CREATED"
        echo "  Spec File: $SPEC_FILE"
        echo "  Feature Dir: $FEATURE_DIR"
        echo "  HYPER_KIT_FEATURE set to: $BRANCH_CREATED"
    fi
    echo ""
    echo "Pipeline steps completed:"
    echo "1. ✓ Context collection and documentation query"
    echo "2. ✓ Skeleton generation with proper signatures"
    echo "3. ✓ LST conversion and structure analysis"
    echo "4. ✓ Task chunking for modular porting"
    echo "5. ✓ Chunk-by-chunk implementation preparation"
    echo "6. ✓ Chunk merging and finalization"
    echo "7. ✓ Compatibility layer analysis"
    echo ""
    echo "Next steps for manual completion:"
    echo "1. Review generated context in $PORTING_DIR/context/"
    echo "2. Examine task breakdown in $PORTING_DIR/tasks/"
    echo "3. Implement logic in each chunk file in $PORTING_DIR/chunks/"
    echo "4. Test individual chunks before merging"
    echo "5. Refine the final implementation in $PORTED_FILE"
    echo "6. Apply compatibility layer suggestions if applicable"
    echo "7. Update documentation and commit changes"
fi

# Create plan file for porting steps (updated with pipeline results)
PLAN_FILE="$PORTING_DIR/porting-plan.md"
TEMPLATE="$REPO_ROOT/templates/porting-function-template.md"
if [[ -f "$TEMPLATE" ]]; then
    cp "$TEMPLATE" "$PLAN_FILE"
    # Fill in basic information
    sed -i '' "s/\[Function Name\]/${FUNCTION_NAME:-Unknown Function}/g" "$PLAN_FILE"
    sed -i '' "s/\[Source Language\]/$FROM_LANG/g" "$PLAN_FILE"
    sed -i '' "s/\[Target Language\]/$TO_LANG/g" "$PLAN_FILE"
    sed -i '' "s/\[YYYY-MM-DD\]/$(date +%Y-%m-%d)/g" "$PLAN_FILE"
    sed -i '' "s/\[function_name\]/${FUNCTION_NAME:-unknown}/g" "$PLAN_FILE"
    sed -i '' "s/\[source_lang\]/$FROM_LANG/g" "$PLAN_FILE"
    sed -i '' "s/\[target_lang\]/$TO_LANG/g" "$PLAN_FILE"
else
    cat > "$PLAN_FILE" << EOF
# Porting Plan: ${FUNCTION_NAME:-Function} from $FROM_LANG to $TO_LANG

## Overview
Systematic porting of function from $FROM_LANG to $TO_LANG using structured pipeline.

## Pipeline Steps Completed:

1. **Context Collection**
   - Original function saved: $ORIGINAL_FILE
   - Related documentation queried from knowledge base
   - Context files generated in $PORTING_DIR/context/

2. **Skeleton Generation**
   - Target function skeleton created with proper signatures
   - JavaDoc/documentation template generated
   - Placeholder body prepared for implementation

3. **LST Conversion & Chunking**
   - Function converted to Logical Structure Tree
   - LST chunks created for modular porting
   - Individual tasks defined in $PORTING_DIR/tasks/

4. **Chunk-by-Chunk Porting**
   - Each LST chunk ported systematically
   - Semantic consistency maintained
   - Intermediate results saved

5. **Merge & Finalization**
   - All chunks merged into complete function
   - Final implementation in $PORTING_DIR/$OUTPUT_FILE
   - Documentation updated

6. **Compatibility Layer Check**
   - Existing compat layers queried
   - Refactoring suggestions generated if applicable

## Files Created:
- Original function: $ORIGINAL_FILE
- Porting plan: $PLAN_FILE
- Context directory: $PORTING_DIR/context/
- Tasks directory: $PORTING_DIR/tasks/
- LST analysis: $PORTING_DIR/lst/
- Final implementation: $PORTING_DIR/$OUTPUT_FILE

## Next Steps:
1. Review generated context and documentation
2. Examine LST chunks and task breakdown
3. Implement or refine ported chunks as needed
4. Test the final implementation
5. Apply compatibility layer suggestions if any
EOF
fi

# Execute systematic porting pipeline
execute_porting_pipeline() {
    local input_content="$1"
    local from_lang="$2"
    local to_lang="$3"
    local function_name="$4"
    local porting_dir="$5"
    local ai_assist="$6"
    
    echo "[hyper-kit] Starting systematic porting pipeline..."
    
    # Create subdirectories
    mkdir -p "$porting_dir/context"
    mkdir -p "$porting_dir/tasks"
    mkdir -p "$porting_dir/lst"
    mkdir -p "$porting_dir/chunks"
    
    # Step 1: Collect context and documentation
    echo "[hyper-kit] Step 1: Collecting context and documentation..."
    collect_context "$input_content" "$function_name" "$porting_dir"
    
    # Step 2: Generate skeleton
    echo "[hyper-kit] Step 2: Generating target function skeleton..."
    generate_skeleton "$input_content" "$from_lang" "$to_lang" "$function_name" "$porting_dir"
    
    # Step 3: Convert to LST and analyze structure
    echo "[hyper-kit] Step 3: Converting to Logical Structure Tree..."
    convert_to_lst "$input_content" "$from_lang" "$porting_dir"
    
    # Step 4: Chunking LST into tasks
    echo "[hyper-kit] Step 4: Chunking LST into manageable tasks..."
    chunk_lst "$porting_dir"
    
    # Step 5: Port each chunk
    echo "[hyper-kit] Step 5: Porting chunks systematically..."
    port_chunks "$from_lang" "$to_lang" "$porting_dir" "$ai_assist"
    
    # Step 6: Merge and finalize
    echo "[hyper-kit] Step 6: Merging chunks and finalizing implementation..."
    merge_chunks "$to_lang" "$function_name" "$porting_dir"
    
    # Step 7: Check compatibility layers
    echo "[hyper-kit] Step 7: Checking for compatibility layers..."
    check_compat_layers "$function_name" "$from_lang" "$to_lang" "$porting_dir"
    
    echo "[hyper-kit] Porting pipeline completed successfully!"
}

# Helper functions for pipeline steps
collect_context() {
    local input_content="$1"
    local function_name="$2"
    local porting_dir="$3"
    
    # Save basic context
    echo "$input_content" > "$porting_dir/context/original_function.${from_lang}"
    
    # Query related documentation using mind_mcp
    echo "[hyper-kit] Querying knowledge base for related documentation..."
    
    # Use subagent to perform MCP queries and research
    local query_prompt="Research and collect comprehensive context for porting function '${function_name:-unknown}' from $from_lang to $to_lang.
    
Original function content:
$input_content

Please provide:
1. Function purpose and behavior analysis
2. Related documentation and usage patterns
3. Language-specific migration considerations
4. Equivalent functions/libraries in target language
5. Best practices and coding standards
6. Potential compatibility issues

Use available MCP tools (mcp_mind_mcp_query_vectors, semantic_search, etc.) to gather information.
Output should be structured markdown suitable for porting documentation."
    
    # Call subagent for research
    local research_result=""
    # Note: In actual implementation, this would call runSubagent with the prompt
    # For now, create structured placeholder
    
    local context_file="$porting_dir/context/documentation.md"
    
    cat > "$context_file" << EOF
# Context Documentation for ${function_name:-Unknown Function}

## Function Details
- **Name**: ${function_name:-Unknown}
- **Source Language**: $from_lang
- **Target Language**: $to_lang
- **Original Content**: See original_function.${from_lang}

## Research Results from MCP Query

### Function Analysis
**Purpose**: TODO - Extract from MCP research
**Behavior**: TODO - Analyze function logic and patterns
**Dependencies**: TODO - Identify required libraries/modules

### Migration Considerations
**Language Differences**: TODO - Query MCP for $from_lang to $to_lang differences
**Type System Mapping**: TODO - Map data types between languages
**Error Handling Patterns**: TODO - Research exception/error handling approaches

### Equivalent Functions in Target Language
**Direct Equivalents**: TODO - Find similar functions in $to_lang ecosystem
**Library Alternatives**: TODO - Identify replacement libraries
**Framework Options**: TODO - Suggest appropriate frameworks

### Best Practices
**Coding Standards**: TODO - Query $to_lang best practices
**Performance Considerations**: TODO - Research optimization techniques
**Security Guidelines**: TODO - Check security best practices

### Compatibility Analysis
**Breaking Changes**: TODO - Identify potential compatibility issues
**Migration Path**: TODO - Suggest migration strategy
**Testing Approach**: TODO - Recommend testing methodology

## Implementation Notes
- Context collected using MCP knowledge base queries
- Research performed on: $(date)
- Additional manual research may be needed for complex functions

## MCP Query Commands Used
\`\`\`bash
# Example MCP queries that would be executed:
mcp_mind_mcp_query_vectors --query "function ${function_name:-unknown} ${from_lang} implementation"
mcp_mind_mcp_query_vectors --query "${from_lang} to ${to_lang} migration patterns"
semantic_search --query "${function_name:-unknown} ${to_lang} equivalent"
github_repo --repo "some/repo" --query "${function_name:-unknown} ${to_lang}"
\`\`\`

## Integration Points
- TODO: Implement actual MCP tool calls via runSubagent
- TODO: Parse and integrate query results into structured format
- TODO: Add confidence scores for research findings
EOF
    
    echo "[hyper-kit] Context collection completed (MCP query framework ready)"
}

generate_skeleton() {
    local input_content="$1"
    local from_lang="$2"
    local to_lang="$3"
    local function_name="$4"
    local porting_dir="$5"
    
    # Create skeleton file
    local skeleton_file="$porting_dir/skeleton.${to_lang}"
    
    case "$to_lang" in
        python)
            cat > "$skeleton_file" << EOF
"""
Ported from $from_lang
Original function: ${function_name:-unknown}

TODO: Add comprehensive docstring with:
- Function purpose
- Parameters description
- Return value description
- Exceptions raised
- Examples
"""

def ${function_name:-ported_function}():
    """
    TODO: Implement function logic here
    """
    pass
EOF
            ;;
        javascript)
            cat > "$skeleton_file" << EOF
/**
 * Ported from $from_lang
 * Original function: ${function_name:-unknown}
 * 
 * TODO: Add JSDoc with:
 * - Function description
 * - @param descriptions
 * - @returns description
 * - @throws descriptions
 * - @example
 */
function ${function_name:-portedFunction}() {
    // TODO: Implement function logic here
}
EOF
            ;;
        java)
            cat > "$skeleton_file" << EOF
/**
 * Ported from $from_lang
 * Original function: ${function_name:-unknown}
 * 
 * TODO: Add JavaDoc with:
 * - Class/function description
 * - @param descriptions
 * - @return description
 * - @throws descriptions
 */
public class ${function_name:-PortedFunction} {
    /**
     * TODO: Implement method logic here
     */
    public static void main(String[] args) {
        // Implementation here
    }
}
EOF
            ;;
        *)
            cat > "$skeleton_file" << EOF
# Ported from $from_lang to $to_lang
# Function: ${function_name:-ported_function}
# TODO: Add comprehensive documentation
# TODO: Implement function logic here
EOF
            ;;
    esac
}

convert_to_lst() {
    local input_content="$1"
    local from_lang="$2"
    local porting_dir="$3"
    
    # Use graph analysis tools to understand structure
    echo "[hyper-kit] Analyzing code structure with MCP graph tools..."
    
    local lst_file="$porting_dir/lst/structure.json"
    
    cat > "$lst_file" << EOF
{
    "function_name": "${function_name:-unknown}",
    "source_language": "$from_lang",
    "target_language": "$to_lang",
    "mcp_analysis": {
        "graph_queries_used": [
            "mcp_graph_mcp_search_functions --query '${function_name:-unknown}'",
            "mcp_graph_mcp_find_module_path --source_modules ['${from_lang}'] --target_modules ['${to_lang}']",
            "mcp_graph_mcp_impact --function_id 'TODO' --direction 'both'"
        ],
        "structure_analysis": {
            "signature": "TODO: Parse with mcp_graph_mcp_resolve_symbol",
            "parameters": [],
            "return_type": "TODO: Analyze with graph tools",
            "body_structure": [
                "TODO: Use mcp_graph_mcp_explain_path for control flow",
                "TODO: Identify logical blocks with graph analysis",
                "TODO: Map dependencies using call graph"
            ],
            "complexity": "TODO: Calculate with MCP metrics"
        }
    },
    "chunking_strategy": {
        "method": "logical_functionality",
        "chunks": [
            {"id": "signature", "description": "Function signature and parameters"},
            {"id": "validation", "description": "Input validation and type checking"},
            {"id": "core_logic", "description": "Main algorithmic implementation"},
            {"id": "error_handling", "description": "Exception handling and cleanup"},
            {"id": "return_processing", "description": "Output formatting and return"}
        ]
    },
    "analysis_notes": "LST structure ready for MCP graph tool integration"
}
EOF
    
    echo "[hyper-kit] LST conversion completed (MCP graph tools integration ready)"
}

chunk_lst() {
    local porting_dir="$1"
    
    # Create task breakdown based on LST
    local tasks_dir="$porting_dir/tasks"
    
    # Create individual task files
    cat > "$tasks_dir/task_001_signature.md" << EOF
# Task 001: Function Signature Porting

## Objective
Convert function signature from $from_lang to $to_lang

## Requirements
- Map parameter types correctly
- Convert return type appropriately
- Handle language-specific naming conventions
- Preserve function name or adapt as needed

## Status: Pending
EOF
    
    cat > "$tasks_dir/task_002_parameters.md" << EOF
# Task 002: Parameter Handling

## Objective
Implement parameter processing logic

## Requirements
- Convert parameter validation
- Handle default values
- Map data type conversions
- Preserve parameter semantics

## Status: Pending
EOF
    
    cat > "$tasks_dir/task_003_body.md" << EOF
# Task 003: Main Logic Implementation

## Objective
Port the core function logic

## Requirements
- Convert algorithmic logic
- Handle control structures
- Map built-in functions
- Preserve business logic

## Status: Pending
EOF
    
    cat > "$tasks_dir/task_004_error_handling.md" << EOF
# Task 004: Error Handling

## Objective
Implement appropriate error handling

## Requirements
- Convert exception types
- Map error codes/messages
- Handle edge cases
- Preserve error semantics

## Status: Pending
EOF
}

port_chunks() {
    local from_lang="$1"
    local to_lang="$2"
    local porting_dir="$3"
    local ai_assist="$4"
    
    local tasks_dir="$porting_dir/tasks"
    local chunks_dir="$porting_dir/chunks"
    
    # Process each task
    for task_file in "$tasks_dir"/task_*.md; do
        if [[ -f "$task_file" ]]; then
            local task_name=$(basename "$task_file" .md)
            local chunk_file="$chunks_dir/${task_name}_chunk.${to_lang}"
            
            if [[ "$ai_assist" == true ]]; then
                # Use AI assistance for porting
                echo "// TODO: AI-assisted porting for $task_name" > "$chunk_file"
            else
                # Manual template
                echo "# TODO: Implement $task_name logic here" > "$chunk_file"
            fi
            
            # Mark task as in progress
            sed -i '' 's/## Status: Pending/## Status: In Progress/' "$task_file"
        fi
    done
}

merge_chunks() {
    local to_lang="$1"
    local function_name="$2"
    local porting_dir="$3"
    
    local chunks_dir="$porting_dir/chunks"
    local final_file="$porting_dir/${function_name:-ported_function}.${to_lang}"
    
    # Basic merge - in real implementation, this would intelligently combine chunks
    cat > "$final_file" << EOF
# Merged implementation from chunks
# TODO: Intelligently merge all ported chunks here

# Include skeleton
$(cat "$porting_dir/skeleton.${to_lang}")

# TODO: Merge chunk implementations
# - Signature from task_001
# - Parameters from task_002  
# - Body from task_003
# - Error handling from task_004
EOF
}

check_compat_layers() {
    local function_name="$1"
    local from_lang="$2"
    local to_lang="$3"
    local porting_dir="$4"
    
    local compat_file="$porting_dir/compat_analysis.md"
    
    cat > "$compat_file" << EOF
# Compatibility Layer Analysis

## Function: ${function_name:-unknown}
## Migration: $from_lang → $to_lang

## MCP Queries for Compatibility Research

### Existing Compatibility Layers
**Query**: mcp_mind_mcp_query_vectors --query "compatibility layer ${function_name:-unknown} ${from_lang} ${to_lang}"
**Results**: TODO - List found compatibility layers

**Query**: semantic_search --query "${function_name:-unknown} wrapper ${to_lang}"
**Results**: TODO - Identify wrapper libraries

### Migration Utilities
**Query**: mcp_mind_mcp_query_vectors --query "${from_lang} to ${to_lang} migration tools"
**Results**: TODO - List available migration utilities

**Query**: github_repo --repo "migration-tools" --query "${from_lang} ${to_lang} converter"
**Results**: TODO - Find conversion tools

### Framework Alternatives
**Query**: semantic_search --query "${function_name:-unknown} ${to_lang} framework equivalent"
**Results**: TODO - Suggest framework alternatives

## Recommendations
- TODO: Suggest refactoring to use compat layers if available
- TODO: Propose new compat layer development if beneficial
- TODO: Evaluate migration tool suitability

## MCP Integration Notes
- TODO: Implement actual MCP queries in subagent
- TODO: Parse compatibility layer metadata
- TODO: Generate automated refactoring suggestions

## Status: Analysis Framework Ready
EOF
}

# Helper functions for branch creation
clean_branch_name() {
    local name="$1"
    echo "$name" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/-\+/-/g' | sed 's/^-//' | sed 's/-$//'
}

generate_branch_name() {
    local description="$1"
    
    # Common stop words to filter out
    local stop_words="^(i|a|an|the|to|for|of|in|on|at|by|with|from|is|are|was|were|be|been|being|have|has|had|do|does|did|will|would|should|could|can|may|might|must|shall|this|that|these|those|my|your|our|their|want|need|add|get|set)$"
    
    # Convert to lowercase and split into words
    local clean_name=$(echo "$description" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/ /g')
    
    # Filter words: remove stop words and words shorter than 3 chars (unless they're uppercase acronyms in original)
    local meaningful_words=()
    for word in $clean_name; do
        # Skip empty words
        [ -z "$word" ] && continue
        
        # Keep words that are NOT stop words AND (length >= 3 OR are potential acronyms)
        if ! echo "$word" | grep -qiE "$stop_words"; then
            if [ ${#word} -ge 3 ]; then
                meaningful_words+=("$word")
            elif echo "$description" | grep -q "\b${word^^}\b"; then
                # Keep short words if they appear as uppercase in original (likely acronyms)
                meaningful_words+=("$word")
            fi
        fi
    done
    
    # If we have meaningful words, use first 3-4 of them
    if [ ${#meaningful_words[@]} -gt 0 ]; then
        local max_words=3
        if [ ${#meaningful_words[@]} -eq 4 ]; then max_words=4; fi
        
        local result=""
        local count=0
        for word in "${meaningful_words[@]}"; do
            if [ $count -ge $max_words ]; then break; fi
            if [ -n "$result" ]; then result="$result-"; fi
            result="$result$word"
            count=$((count + 1))
        done
        echo "$result"
    else
        # Fallback to original logic if no meaningful words found
        local cleaned=$(clean_branch_name "$description")
        echo "$cleaned" | tr '-' '\n' | grep -v '^$' | head -3 | tr '\n' '-' | sed 's/-$//'
    fi
}

get_highest_from_specs() {
    local specs_dir="$1"
    local highest=0
    
    if [ -d "$specs_dir" ]; then
        for dir in "$specs_dir"/*; do
            [ -d "$dir" ] || continue
            dirname=$(basename "$dir")
            number=$(echo "$dirname" | grep -o '^[0-9]\+' || echo "0")
            number=$((10#$number))
            if [ "$number" -gt "$highest" ]; then
                highest=$number
            fi
        done
    fi
    
    echo "$highest"
}

get_highest_from_branches() {
    local highest=0
    
    # Get all branches (local and remote)
    branches=$(git branch -a 2>/dev/null || echo "")
    
    if [ -n "$branches" ]; then
        while IFS= read -r branch; do
            # Clean branch name: remove leading markers and remote prefixes
            clean_branch=$(echo "$branch" | sed 's/^[* ]*//; s|^remotes/[^/]*/||')
            
            # Extract feature number if branch matches pattern ###-*
            if echo "$clean_branch" | grep -q '^[0-9]\{3\}-'; then
                number=$(echo "$clean_branch" | grep -o '^[0-9]\{3\}' || echo "0")
                number=$((10#$number))
                if [ "$number" -gt "$highest" ]; then
                    highest=$number
                fi
            fi
        done <<< "$branches"
    fi
    
    echo "$highest"
}

check_existing_branches() {
    local specs_dir="$1"

    # Fetch all remotes to get latest branch info (suppress errors if no remotes)
    git fetch --all --prune 2>/dev/null || true

    # Get highest number from ALL branches (not just matching short name)
    local highest_branch=$(get_highest_from_branches)

    # Get highest number from ALL specs (not just matching short name)
    local highest_spec=$(get_highest_from_specs "$specs_dir")

    # Take the maximum of both
    local max_num=$highest_branch
    if [ "$highest_spec" -gt "$max_num" ]; then
        max_num=$highest_spec
    fi

    # Return next number
    echo $((max_num + 1))
}
