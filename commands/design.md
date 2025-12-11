---
description: Generate detailed implementation tasks, perform consistency analysis, and create quality checklists for the feature.
handoffs:
  - label: Implement Feature
    agent: devkit-cli implement
    prompt: Execute the implementation plan with detailed tasks
scripts:
  sh: scripts/bash/setup-plan.sh --json
  ps: scripts/powershell/check-prerequisites.ps1 -Json
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

This command combines task generation, consistency analysis, and checklist creation into a comprehensive design phase. It breaks down the technical plan into actionable tasks, analyzes for inconsistencies, and creates quality validation checklists.

## Execution Steps

### 1. Task Generation (from tasks.md)

Run prerequisite script and parse FEATURE_DIR and AVAILABLE_DOCS list.
Load design documents: plan.md (tech stack, libraries, structure), spec.md (user stories with priorities).

Execute task generation workflow:

- Extract tech stack, libraries, project structure from plan.md
- Extract user stories with priorities from spec.md
- Map entities and endpoints to user stories
- Generate tasks organized by user story with strict checklist format

Generate tasks.md with:

- Phase 1: Setup tasks (project initialization)
- Phase 2: Foundational tasks (blocking prerequisites)
- Phase 3+: User Stories in priority order with independent test criteria
- Final Phase: Polish & cross-cutting concerns
- All tasks follow format: `- [ ] [TaskID] [P?] [Story?] Description with file path`

Report task count, parallel opportunities, and MVP scope.

### 2. Consistency Analysis (from analyze.md)

Run prerequisite script and parse FEATURE_DIR and AVAILABLE_DOCS.
Derive absolute paths for SPEC, PLAN, TASKS.

Load artifacts progressively:

- spec.md: Overview, Functional/Non-Functional Requirements, User Stories, Edge Cases
- plan.md: Architecture choices, Data Model references, Phases, Technical constraints
- tasks.md: Task IDs, Descriptions, Phase grouping, Parallel markers, Referenced file paths
- constitution.md for principle validation

Build semantic models:

- Requirements inventory with stable keys
- User story/action inventory with acceptance criteria
- Task coverage mapping
- Constitution rule set

Detection passes for high-signal findings (limit 50):

- Duplication Detection
- Ambiguity Detection (vague adjectives lacking criteria)
- Underspecification
- Constitution Alignment
- Coverage Gaps
- Inconsistency (terminology drift, conflicting requirements)

Severity assignment: CRITICAL, HIGH, MEDIUM, LOW.

Produce compact analysis report with:

- Findings table (ID, Category, Severity, Location, Summary, Recommendation)
- Coverage summary table (Requirement Key, Has Task?, Task IDs, Notes)
- Constitution alignment issues
- Unmapped tasks
- Metrics (total requirements, tasks, coverage %, ambiguity/duplication counts, critical issues)

Provide next actions based on issue severity.

### 3. Checklist Creation (from checklist.md)

Derive up to THREE contextual clarifying questions from user input and spec/plan/tasks signals.
Understand user request: derive checklist theme, consolidate must-have items.

Load feature context from FEATURE_DIR:

- spec.md: Feature requirements and scope
- plan.md: Technical details, dependencies
- tasks.md: Implementation tasks

Generate checklist as "Unit Tests for Requirements":

- Create `FEATURE_DIR/checklists/` directory
- Generate unique filename based on domain (e.g., `ux.md`, `api.md`, `security.md`)
- Number items sequentially CHK001+
- Group by requirement quality dimensions: Completeness, Clarity, Consistency, Acceptance Criteria Quality, Scenario Coverage, Edge Case Coverage, Non-Functional Requirements, Dependencies & Assumptions, Ambiguities & Conflicts

Each item tests requirements quality, not implementation:

- "Are [requirement type] defined for [scenario]?" [Completeness]
- "Is [vague term] quantified with specific criteria?" [Clarity]
- "Are requirements consistent between [section A] and [section B]?" [Consistency]
- "Can [requirement] be objectively measured?" [Measurability]
- "Are [edge cases] addressed in requirements?" [Coverage]

Structure following checklist-template.md with title, meta section, category headings, ID formatting.

### 4. Report Completion

Output paths to generated tasks.md, analysis report, and checklist files.
Summarize task count, analysis findings count and severity breakdown, checklist item count and focus areas.
Suggest next command: `/devkit-cli implement` for execution.

## Key Rules

- Tasks MUST be organized by user story for independent implementation
- Analysis is READ-ONLY, output structured report only
- Checklists test requirements quality, not implementation behavior
- Use absolute paths
- Limit analysis findings to 50 total
- Checklist items must include traceability references or gap markers
- Preserve task format: `- [ ] [TaskID] [P?] [Story?] Description with file path`

Context for design: {ARGS}
