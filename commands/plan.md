---
description: Create project constitution, feature specification, and technical plan in one comprehensive planning phase.
handoffs:
  - label: Design Implementation Details
    agent: devkit-cli design
    prompt: Create detailed tasks and analysis for the plan
scripts:
  sh: scripts/bash/setup-plan.sh --json "{ARGS}"
agent_scripts:
  sh: scripts/bash/update-agent-context.sh __AGENT__
  ps: scripts/powershell/update-agent-context.ps1 -AgentType __AGENT__
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

This command combines constitution creation, specification writing, clarification, and technical planning into a single comprehensive planning phase. It establishes the project foundation, defines the feature requirements, and creates the technical implementation plan.

## Execution Steps

### 1. Constitution Setup (from constitution.md)

Load the existing constitution template at `/memory/constitution.md`.

- Identify every placeholder token of the form `[ALL_CAPS_IDENTIFIER]`.
- Collect/derive values for placeholders from user input or repo context.
- For governance dates: `RATIFICATION_DATE` is today, `LAST_AMENDED_DATE` is today.
- Increment `CONSTITUTION_VERSION` according to semantic versioning rules.
- Fill the template precisely, ensuring principles are declarative, testable, and free of vague language.
- Write the completed constitution back to `/memory/constitution.md`.

### 2. Feature Specification (from hyperkit.md)

Generate a concise short name (2-4 words) for the branch from the feature description.
Check for existing branches and create new one with next available number.
Load `templates/spec-template.md` to understand required sections.

Parse user description and extract key concepts (actors, actions, data, constraints).
For unclear aspects, make informed guesses based on context and industry standards.
Limit [NEEDS CLARIFICATION] markers to maximum 3.
Fill User Scenarios & Testing section, Functional Requirements, Success Criteria (measurable, technology-agnostic).
Identify Key Entities if data involved.

Create spec quality checklist at `FEATURE_DIR/checklists/requirements.md`.
Validate spec against quality criteria and resolve clarifications interactively (max 3 questions).
Write the specification to SPEC_FILE using the template structure.

### 3. Specification Clarification (from clarify.md)

Load the current spec file and perform ambiguity & coverage scan using taxonomy:

- Functional Scope & Behavior
- Domain & Data Model
- Interaction & UX Flow
- Non-Functional Quality Attributes
- Integration & External Dependencies
- Edge Cases & Failure Handling
- Constraints & Tradeoffs
- Terminology & Consistency

Generate prioritized queue of clarification questions (maximum 5).
Present questions sequentially, recommend best practices options.
Update spec with accepted answers, maintaining minimal and testable clarifications.
Validate after each update.

### 4. Technical Planning (from plan.md)

Load context from FEATURE_SPEC and constitution.
Execute plan workflow using IMPL_PLAN template:

- Fill Technical Context (mark unknowns as "NEEDS CLARIFICATION")
- Fill Constitution Check section from constitution
- Evaluate gates (ERROR if violations unjustified)

Phase 0: Generate research.md (resolve all NEEDS CLARIFICATION)

- Extract unknowns from Technical Context
- Generate research tasks for unknowns, dependencies, integrations
- Consolidate findings in research.md

Phase 1: Generate data-model.md, contracts/, quickstart.md

- Extract entities from feature spec → data-model.md
- Generate API contracts from functional requirements → /contracts/
- Update agent context by running agent script

Re-evaluate Constitution Check post-design.

### 5. Report Completion

Report branch name, spec file path, plan file path, generated artifacts (research.md, data-model.md, contracts/, quickstart.md), and constitution version.
Suggest next command: `/devkit-cli design` for detailed task breakdown and analysis.

## Key Rules

- Use absolute paths
- ERROR on constitution violations or unresolved clarifications
- Preserve heading hierarchy and section order
- Keep clarifications minimal and testable
- Ensure principles are declarative and testable
- Success criteria must be measurable and technology-agnostic
- Limit clarification questions to 5 total
- Follow semantic versioning for constitution updates

Context for planning: {ARGS}
