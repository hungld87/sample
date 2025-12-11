# Hyper Dev Kit - AI Agent Context

**Project**: Hyper Dev Kit
**Version**: 1.0.0
**Last Updated**: [DATE]
**Current Feature**: [FEATURE_NAME]

---

## Project Overview

Hyper Dev Kit is a comprehensive development toolkit that provides systematic approaches for software development tasks including:

- **Function Porting**: Automated pipeline for porting functions between programming languages
- **Project Planning**: Structured planning and specification management
- **Code Generation**: Template-based code generation with best practices
- **Quality Assurance**: Testing and validation frameworks

### Technology Stack

- **Primary Language**: [LANGUAGE]
- **Frameworks**: [FRAMEWORKS]
- **Tools**: Git, Bash scripting, Python, Markdown
- **Target Platforms**: macOS, Linux, Windows

### Project Structure

```
hyper-dev/
├── scripts/bash/          # Automation scripts
├── templates/             # Code and documentation templates
├── src/                   # Source code
│   └── devkit-cli/        # Main CLI application
├── docs/                  # Documentation
└── specs/                 # Feature specifications
```

---

## Current Development Context

### Active Feature: [FEATURE_NAME]

**Status**: [STATUS]
**Description**: [BRIEF_DESCRIPTION]
**Priority**: [PRIORITY_LEVEL]

### Recent Changes

- [DATE]: [CHANGE_DESCRIPTION]
- [DATE]: [CHANGE_DESCRIPTION]
- [DATE]: [CHANGE_DESCRIPTION]

### Key Files to Reference

- `src/devkit-cli/__init__.py` - Main CLI application
- `scripts/bash/common.sh` - Shared utilities
- `templates/porting-function-template.md` - Porting documentation template
- `planning-framework.md` - Project planning guidelines

---

## Development Guidelines

### Code Style

- Follow language-specific best practices
- Use meaningful variable and function names
- Include comprehensive documentation
- Write tests for new functionality

### Git Workflow

- Feature branches: `###-feature-description`
- Commit messages: `type(scope): description`
- Pull requests: Include testing and documentation

### Quality Standards

- Code review required for all changes
- Unit test coverage > 80%
- Documentation updated with code changes
- Backward compatibility maintained

---

## AI Agent Instructions

### General Guidelines

- Always reference this context file for project information
- Use the established patterns and templates
- Maintain consistency with existing codebase
- Ask for clarification when requirements are unclear

### Task-Specific Guidance

#### Function Porting

1. Use the systematic 7-step pipeline
2. Generate comprehensive documentation
3. Include MCP research queries
4. Test ported functionality thoroughly

#### Feature Development

1. Create spec file first (`specs/###-feature/spec.md`)
2. Use appropriate templates from `templates/`
3. Follow TDD approach when possible
4. Update agent context after changes

#### Bug Fixes

1. Reproduce issue first
2. Create test case demonstrating the bug
3. Fix with minimal changes
4. Verify fix doesn't break existing functionality

---

## Communication Preferences

### Code Comments

- Use clear, descriptive comments
- Explain complex logic
- Reference related functions/files
- Update comments when code changes

### Documentation

- Keep README files current
- Document API changes
- Include usage examples
- Update troubleshooting guides

### Commit Messages

```
feat: add function porting pipeline
fix: resolve template parsing issue
docs: update agent context instructions
refactor: simplify common utilities
```

---

## Quality Assurance

### Testing Strategy

- Unit tests for individual functions
- Integration tests for workflows
- Manual testing for complex features
- Regression testing before releases

### Code Review Checklist

- [ ] Code follows style guidelines
- [ ] Tests included and passing
- [ ] Documentation updated
- [ ] No security vulnerabilities
- [ ] Performance impact assessed
- [ ] Backward compatibility maintained

---

## Troubleshooting

### Common Issues

**Issue**: Template not found
**Solution**: Check `templates/` directory and file permissions

**Issue**: Git branch conflicts
**Solution**: Use `git status` and resolve conflicts manually

**Issue**: Script execution fails
**Solution**: Check file permissions and bash version

### Getting Help

1. Check existing documentation in `docs/`
2. Review recent commits for similar changes
3. Ask team members for guidance
4. Create issue in project repository

---

## Future Enhancements

### Planned Features

- [ ] Enhanced MCP integration
- [ ] Multi-language support expansion
- [ ] Automated testing pipeline
- [ ] Performance monitoring tools

### Technical Debt

- [ ] Refactor legacy scripts
- [ ] Update outdated dependencies
- [ ] Improve error handling
- [ ] Add comprehensive logging

---

_This context file is automatically maintained. Manual additions below this line will be preserved during updates._

---

## Manual Additions

[Add any agent-specific notes, preferences, or context here]
