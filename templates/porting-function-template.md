# Function Porting Template

**Function Name**: [Function Name]
**Source Language**: [Source Language]
**Target Language**: [Target Language]
**Date**: [YYYY-MM-DD]
**Porting Pipeline**: Systematic 7-Step Process

---

## 1. Function Overview

### Original Function Details

- **Name**: [Function name]
- **Language**: [Source language]
- **File Location**: [Path to original file]
- **Purpose**: [Brief description of what the function does]
- **Parameters**:
  - [param1]: [type] - [description]
  - [param2]: [type] - [description]
- **Return Type**: [Return type and description]
- **Dependencies**: [Required imports/libraries]
- **Complexity**: [Estimated complexity level]

### Target Function Requirements

- **Name**: [Target function name]
- **Language**: [Target language]
- **Expected Behavior**: [Same as original or adapted]
- **Performance Requirements**: [Any specific performance needs]
- **Compatibility Requirements**: [Must maintain compatibility with existing code]

---

## 2. MCP Research & Context Collection

### Function Analysis Results

**Purpose**: [Results from MCP query analysis]
**Behavior**: [Detailed behavior analysis]
**Dependencies**: [Identified dependencies and requirements]

### Migration Considerations

**Language Differences**: [Key differences between source and target languages]
**Type System Mapping**: [How data types will be converted]
**Error Handling Patterns**: [Exception/error handling approaches]

### Equivalent Functions in Target Language

**Direct Equivalents**: [Similar functions in target language ecosystem]
**Library Alternatives**: [Alternative libraries or frameworks]
**Framework Options**: [Suggested frameworks for implementation]

### Best Practices

**Coding Standards**: [Target language best practices]
**Performance Considerations**: [Performance optimization techniques]
**Security Guidelines**: [Security best practices to follow]

### Compatibility Analysis

**Breaking Changes**: [Potential compatibility issues]
**Migration Path**: [Recommended migration strategy]
**Testing Approach**: [Suggested testing methodology]

### MCP Queries Used

```bash
# Context collection queries
mcp_mind_mcp_query_vectors --query "function [function_name] [source_lang] implementation"
mcp_mind_mcp_query_vectors --query "[source_lang] to [target_lang] migration patterns"
semantic_search --query "[function_name] [target_lang] equivalent"
github_repo --repo "relevant/repo" --query "[function_name] [target_lang]"
```

---

## 3. Logical Structure Tree (LST) Analysis

### Function Structure Breakdown

```json
{
  "function_name": "[function_name]",
  "source_language": "[source_lang]",
  "target_language": "[target_lang]",
  "structure_analysis": {
    "signature": "[parsed signature]",
    "parameters": [
      { "name": "param1", "type": "type1", "description": "desc1" },
      { "name": "param2", "type": "type2", "description": "desc2" }
    ],
    "return_type": "[return type]",
    "body_structure": [
      "Input validation and preprocessing",
      "Core algorithmic logic",
      "Error handling and edge cases",
      "Output formatting and return"
    ],
    "complexity": "[complexity metrics]"
  }
}
```

### MCP Graph Analysis Results

**Call Graph**: [Function call relationships]
**Dependencies**: [Internal and external dependencies]
**Control Flow**: [Control flow analysis]
**Data Flow**: [Data flow through the function]

### Chunking Strategy

**Method**: logical_functionality
**Identified Chunks**:

1. **Signature Chunk**: Function signature and parameter handling
2. **Validation Chunk**: Input validation and type checking
3. **Core Logic Chunk**: Main algorithmic implementation
4. **Error Handling Chunk**: Exception handling and cleanup
5. **Output Chunk**: Return value processing and formatting

---

## 4. Task Breakdown & Implementation Plan

### Task 001: Function Signature Porting

**Objective**: Convert function signature from [source_lang] to [target_lang]
**Requirements**:

- Map parameter types correctly
- Convert return type appropriately
- Handle language-specific naming conventions
- Preserve function name or adapt as needed
  **Status**: [Pending/In Progress/Completed]
  **Implementation Notes**: [Details about signature conversion]

### Task 002: Parameter Handling

**Objective**: Implement parameter processing logic
**Requirements**:

- Convert parameter validation
- Handle default values
- Map data type conversions
- Preserve parameter semantics
  **Status**: [Pending/In Progress/Completed]
  **Implementation Notes**: [Parameter handling details]

### Task 003: Main Logic Implementation

**Objective**: Port the core function logic
**Requirements**:

- Convert algorithmic logic
- Handle control structures
- Map built-in functions
- Preserve business logic
  **Status**: [Pending/In Progress/Completed]
  **Implementation Notes**: [Core logic implementation details]

### Task 004: Error Handling

**Objective**: Implement appropriate error handling
**Requirements**:

- Convert exception types
- Map error codes/messages
- Handle edge cases
- Preserve error semantics
  **Status**: [Pending/In Progress/Completed]
  **Implementation Notes**: [Error handling implementation]

---

## 5. Implementation Progress

### Skeleton Generation

**Status**: [Generated/Completed]
**Skeleton File**: [Path to skeleton file]
**Includes**:

- Proper function signature
- Parameter definitions
- Return type annotations
- Documentation template
- TODO placeholders for implementation

### Chunk Implementation Status

| Chunk          | Status                                          | File Location                                    | Notes |
| -------------- | ----------------------------------------------- | ------------------------------------------------ | ----- |
| Signature      | [ ] Pending<br>[ ] In Progress<br>[ ] Completed | `chunks/task_001_signature_chunk.[target_lang]`  |       |
| Parameters     | [ ] Pending<br>[ ] In Progress<br>[ ] Completed | `chunks/task_002_parameters_chunk.[target_lang]` |       |
| Core Logic     | [ ] Pending<br>[ ] In Progress<br>[ ] Completed | `chunks/task_003_body_chunk.[target_lang]`       |       |
| Error Handling | [ ] Pending<br>[ ] In Progress<br>[ ] Completed | `chunks/task_004_error_chunk.[target_lang]`      |       |

### Merge & Finalization

**Status**: [Not Started/In Progress/Completed]
**Merged File**: [Path to final implementation]
**Merge Strategy**: [How chunks were combined]
**Integration Notes**: [Any special integration considerations]

---

## 6. Compatibility Layer Analysis

### Existing Compatibility Layers Found

**Query Results**: [MCP query results for compatibility layers]
**Available Wrappers**: [Found wrapper libraries]
**Migration Utilities**: [Available conversion tools]

### Recommendations

**Suggested Refactoring**: [Recommendations for using compat layers]
**New Layer Development**: [If new compatibility layer should be created]
**Implementation Priority**: [High/Medium/Low]

### MCP Queries for Compatibility

```bash
# Compatibility analysis queries
mcp_mind_mcp_query_vectors --query "compatibility layer [function_name] [source_lang] [target_lang]"
semantic_search --query "[function_name] wrapper [target_lang]"
mcp_mind_mcp_query_vectors --query "[source_lang] to [target_lang] migration tools"
```

---

## 7. Testing & Validation

### Unit Tests

**Test Cases Identified**:

- [Test case 1]: [Description]
- [Test case 2]: [Description]
- [Test case 3]: [Description]

**Test Implementation**: [Location of test files]
**Coverage**: [Expected test coverage percentage]

### Integration Testing

**Integration Points**: [How function integrates with rest of system]
**Test Scenarios**: [Integration test cases]
**Compatibility Validation**: [Ensuring compatibility with existing code]

### Performance Validation

**Benchmarks**: [Performance benchmarks to meet]
**Metrics**: [Key performance indicators]
**Comparison**: [Comparison with original function performance]

---

## 8. Documentation & Review

### Documentation Updates

**API Documentation**: [Updated API docs location]
**Code Comments**: [Inline documentation status]
**Usage Examples**: [Example usage in target language]

### Code Review Checklist

- [ ] Function signature correctly converted
- [ ] Parameter handling preserves semantics
- [ ] Core logic maintains original behavior
- [ ] Error handling appropriate for target language
- [ ] Performance requirements met
- [ ] Code follows target language best practices
- [ ] Documentation complete and accurate
- [ ] Tests pass and provide adequate coverage

### Review Comments

[Space for reviewer feedback and comments]

---

## 9. Deployment & Rollout

### Deployment Plan

**Target Environment**: [Where function will be deployed]
**Dependencies**: [Required libraries/frameworks]
**Configuration**: [Any configuration needed]

### Rollout Strategy

**Phased Rollout**: [How to roll out gradually]
**Feature Flags**: [Any feature flags needed]
**Rollback Plan**: [How to rollback if issues occur]

### Monitoring & Observability

**Metrics to Monitor**: [Key metrics to track]
**Logging**: [Logging strategy]
**Alerts**: [Alert conditions]

---

## 10. Success Criteria & Sign-off

### Success Metrics

- [ ] Function ports correctly and maintains original behavior
- [ ] All tests pass with adequate coverage
- [ ] Performance requirements met or exceeded
- [ ] Code review completed and approved
- [ ] Documentation updated and reviewed
- [ ] Successfully deployed to target environment

### Sign-off

**Developer**: ********\_\_\_******** Date: ****\_\_****
**Reviewer**: ********\_\_\_******** Date: ****\_\_****
**QA**: ********\_\_\_******** Date: ****\_\_****
