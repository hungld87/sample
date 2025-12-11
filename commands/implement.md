---
description: Execute the implementation plan by processing tasks, checking checklists, and optionally converting tasks to GitHub issues.
tools: ["github/github-mcp-server/issue_write"]
scripts:
  sh: scripts/bash/setup-plan.sh --json
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

This command combines implementation execution with optional GitHub issue creation. It processes all tasks defined in tasks.md, validates checklists, executes the implementation plan, and can convert completed tasks to GitHub issues.

## Execution Steps

### 1. Checklist Status Check (from implement.md)

If FEATURE_DIR/checklists/ exists:

- Scan all checklist files and count total/completed/incomplete items
- Create status table with PASS/FAIL status
- If any incomplete: Display table and ask to proceed
- If all complete: Display table and proceed automatically

### 2. Implementation Context Loading (from implement.md)

Load required documents:

- tasks.md: Complete task list and execution plan
- plan.md: Tech stack, architecture, file structure
- Optional: data-model.md, contracts/, research.md, quickstart.md

### 3. Project Setup Verification (from implement.md)

Create/verify ignore files based on detected technologies:

- .gitignore for git repos
- .dockerignore for Docker
- .eslintignore, .prettierignore for respective tools
- .npmignore for npm publishing
- .terraformignore for Terraform
- .helmignore for Kubernetes

Append missing critical patterns, create with full sets if missing.

### 4. Task Execution (from implement.md)

Parse tasks.md structure:

- Task phases: Setup, Tests, Core, Integration, Polish
- Dependencies: Sequential vs parallel execution
- Details: ID, description, file paths, parallel markers [P]

Execute phase-by-phase:

- Setup first: Project structure, dependencies, configuration
- Respect dependencies: Sequential tasks in order, parallel [P] can run together
- TDD approach: Tests before corresponding implementation
- File-based coordination: Same-file tasks sequential
- Validation checkpoints per phase

Progress tracking:

- Report after each completed task
- Mark completed tasks as [X] in tasks.md
- Halt on non-parallel failures, continue with successful parallel tasks
- Provide error context and next steps

### 5. Completion Validation (from implement.md)

Verify all required tasks completed
Check implementation matches specification
Validate tests pass and coverage meets requirements
Confirm follows technical plan
Report final status summary

### 6. Optional GitHub Issue Creation (from taskstoissues.md)

If user requests or GitHub remote detected:

- Run prerequisite script for tasks
- Get Git remote URL via `git config --get remote.origin.url`
- If GitHub URL: Proceed, else abort

For each task in tasks.md:

- Use GitHub MCP server to create issue in repository
- Issues represent task descriptions with file paths
- Do NOT create issues in non-matching repositories

Report created issue count and URLs.

### 7. Report Completion

Output implementation summary: completed tasks, checklist status, any created GitHub issues.
Confirm feature meets original specification and technical plan.

## Key Rules

- Check checklists before proceeding with implementation
- Execute tasks phase-by-phase with dependency respect
- Mark completed tasks as [X] in tasks.md
- Create/verify ignore files based on detected technologies
- Only create GitHub issues for GitHub repositories
- Halt on critical failures, report parallel task failures
- Validate final implementation against spec and plan

Context for implementation: {ARGS}

- Scan all checklist files in the checklists/ directory
- For each checklist, count:
  - Total items: All lines matching `- [ ]` or `- [X]` or `- [x]`
  - Completed items: Lines matching `- [X]` or `- [x]`
  - Incomplete items: Lines matching `- [ ]`
- Create a status table:

  ```text
  | Checklist | Total | Completed | Incomplete | Status |
  |-----------|-------|-----------|------------|--------|
  | ux.md     | 12    | 12        | 0          | ✓ PASS |
  | test.md   | 8     | 5         | 3          | ✗ FAIL |
  | security.md | 6   | 6         | 0          | ✓ PASS |
  ```

- Calculate overall status:

  - **PASS**: All checklists have 0 incomplete items
  - **FAIL**: One or more checklists have incomplete items

- **If any checklist is incomplete**:

  - Display the table with incomplete item counts
  - **STOP** and ask: "Some checklists are incomplete. Do you want to proceed with implementation anyway? (yes/no)"
  - Wait for user response before continuing
  - If user says "no" or "wait" or "stop", halt execution
  - If user says "yes" or "proceed" or "continue", proceed to step 3

- **If all checklists are complete**:
  - Display the table showing all checklists passed
  - Automatically proceed to step 3

3. Load and analyze the implementation context:

   - **REQUIRED**: Read tasks.md for the complete task list and execution plan
   - **REQUIRED**: Read plan.md for tech stack, architecture, and file structure
   - **IF EXISTS**: Read data-model.md for entities and relationships
   - **IF EXISTS**: Read contracts/ for API specifications and test requirements
   - **IF EXISTS**: Read research.md for technical decisions and constraints
   - **IF EXISTS**: Read quickstart.md for integration scenarios

4. **Project Setup Verification**:

   - **REQUIRED**: Create/verify ignore files based on actual project setup:

   **Detection & Creation Logic**:

   - Check if the following command succeeds to determine if the repository is a git repo (create/verify .gitignore if so):

     ```sh
     git rev-parse --git-dir 2>/dev/null
     ```

   - Check if Dockerfile\* exists or Docker in plan.md → create/verify .dockerignore
   - Check if .eslintrc\* exists → create/verify .eslintignore
   - Check if eslint.config.\* exists → ensure the config's `ignores` entries cover required patterns
   - Check if .prettierrc\* exists → create/verify .prettierignore
   - Check if .npmrc or package.json exists → create/verify .npmignore (if publishing)
   - Check if terraform files (\*.tf) exist → create/verify .terraformignore
   - Check if .helmignore needed (helm charts present) → create/verify .helmignore

   **If ignore file already exists**: Verify it contains essential patterns, append missing critical patterns only
   **If ignore file missing**: Create with full pattern set for detected technology

   **Common Patterns by Technology** (from plan.md tech stack):

   - **Node.js/JavaScript/TypeScript**: `node_modules/`, `dist/`, `build/`, `*.log`, `.env*`
   - **Python**: `__pycache__/`, `*.pyc`, `.venv/`, `venv/`, `dist/`, `*.egg-info/`
   - **Java**: `target/`, `*.class`, `*.jar`, `.gradle/`, `build/`
   - **C#/.NET**: `bin/`, `obj/`, `*.user`, `*.suo`, `packages/`
   - **Go**: `*.exe`, `*.test`, `vendor/`, `*.out`
   - **Ruby**: `.bundle/`, `log/`, `tmp/`, `*.gem`, `vendor/bundle/`
   - **PHP**: `vendor/`, `*.log`, `*.cache`, `*.env`
   - **Rust**: `target/`, `debug/`, `release/`, `*.rs.bk`, `*.rlib`, `*.prof*`, `.idea/`, `*.log`, `.env*`
   - **Kotlin**: `build/`, `out/`, `.gradle/`, `.idea/`, `*.class`, `*.jar`, `*.iml`, `*.log`, `.env*`
   - **C++**: `build/`, `bin/`, `obj/`, `out/`, `*.o`, `*.so`, `*.a`, `*.exe`, `*.dll`, `.idea/`, `*.log`, `.env*`
   - **C**: `build/`, `bin/`, `obj/`, `out/`, `*.o`, `*.a`, `*.so`, `*.exe`, `Makefile`, `config.log`, `.idea/`, `*.log`, `.env*`
   - **Swift**: `.build/`, `DerivedData/`, `*.swiftpm/`, `Packages/`
   - **R**: `.Rproj.user/`, `.Rhistory`, `.RData`, `.Ruserdata`, `*.Rproj`, `packrat/`, `renv/`
   - **Universal**: `.DS_Store`, `Thumbs.db`, `*.tmp`, `*.swp`, `.vscode/`, `.idea/`

   **Tool-Specific Patterns**:

   - **Docker**: `node_modules/`, `.git/`, `Dockerfile*`, `.dockerignore`, `*.log*`, `.env*`, `coverage/`
   - **ESLint**: `node_modules/`, `dist/`, `build/`, `coverage/`, `*.min.js`
   - **Prettier**: `node_modules/`, `dist/`, `build/`, `coverage/`, `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`
   - **Terraform**: `.terraform/`, `*.tfstate*`, `*.tfvars`, `.terraform.lock.hcl`
   - **Kubernetes/k8s**: `*.secret.yaml`, `secrets/`, `.kube/`, `kubeconfig*`, `*.key`, `*.crt`

5. Parse tasks.md structure and extract:

   - **Task phases**: Setup, Tests, Core, Integration, Polish
   - **Task dependencies**: Sequential vs parallel execution rules
   - **Task details**: ID, description, file paths, parallel markers [P]
   - **Execution flow**: Order and dependency requirements

6. Execute implementation following the task plan:

   - **Phase-by-phase execution**: Complete each phase before moving to the next
   - **Respect dependencies**: Run sequential tasks in order, parallel tasks [P] can run together
   - **Follow TDD approach**: Execute test tasks before their corresponding implementation tasks
   - **File-based coordination**: Tasks affecting the same files must run sequentially
   - **Validation checkpoints**: Verify each phase completion before proceeding

7. Implementation execution rules:

   - **Setup first**: Initialize project structure, dependencies, configuration
   - **Tests before code**: If you need to write tests for contracts, entities, and integration scenarios
   - **Core development**: Implement models, services, CLI commands, endpoints
   - **Integration work**: Database connections, middleware, logging, external services
   - **Polish and validation**: Unit tests, performance optimization, documentation

8. Progress tracking and error handling:

   - Report progress after each completed task
   - Halt execution if any non-parallel task fails
   - For parallel tasks [P], continue with successful tasks, report failed ones
   - Provide clear error messages with context for debugging
   - Suggest next steps if implementation cannot proceed
   - **IMPORTANT** For completed tasks, make sure to mark the task off as [X] in the tasks file.

9. Completion validation:
   - Verify all required tasks are completed
   - Check that implemented features match the original specification
   - Validate that tests pass and coverage meets requirements
   - Confirm the implementation follows the technical plan
   - Report final status with summary of completed work

Note: This command assumes a complete task breakdown exists in tasks.md. If tasks are incomplete or missing, suggest running `/devkit-cli design` first to regenerate the task list.
