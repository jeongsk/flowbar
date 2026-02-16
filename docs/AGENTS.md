# AGENTS.md - Documentation Agent Instructions

## Purpose

This directory contains all documentation and specifications for the Flowbar project. It serves as the central source of truth for project requirements, technical specifications, and implementation guidelines.

## Key Files

### PRD.md
- **Purpose**: Product Requirements Document
- **Content**: Project goals, user stories, feature requirements, and acceptance criteria
- **Usage**: Primary reference for understanding what needs to be built
- **Audience**: All team members, stakeholders, and AI agents

### technical-spec.md
- **Purpose**: Technical Specification Document
- **Content**: Architecture decisions, technical requirements, API specifications, data models, and implementation guidelines
- **Usage**: Detailed technical guidance for implementation
- **Audience**: Developers, architects, and technical AI agents

## AI Agent Instructions

When working with documentation in this directory, AI agents should:

### Reading Documentation
1. **Always start with PRD.md** to understand project context and requirements
2. **Reference technical-spec.md** for implementation details and technical constraints
3. **Cross-reference** both documents when making technical decisions

### Writing/Updating Documentation
1. **Maintain consistency** with existing documentation style and format
2. **Be specific and detailed** - avoid ambiguity in specifications
3. **Include examples** where helpful for clarification
4. **Update related sections** when making changes to maintain consistency
5. **Use markdown formatting** for readability
6. **Include diagrams or tables** where they enhance understanding

### Documentation Principles
- **Clarity over brevity** - It's better to be thorough than concise
- **Version control** - All documentation changes should be committed with clear messages
- **Accessibility** - Write for both human and AI readers
- **Maintainability** - Keep documentation up-to-date as the project evolves
- **Single source of truth** - Avoid duplicating information across files

### When Creating New Documentation
1. **Check existing files first** to avoid duplication
2. **Use descriptive filenames** that clearly indicate content
3. **Add to this file** (AGENTS.md) if creating a new key document
4. **Consider audience** - Who will read this and what do they need to know?
5. **Include context** - Background information helps readers understand purpose

## File Organization

```
docs/
├── AGENTS.md              # This file - AI agent instructions
├── PRD.md                 # Product Requirements Document
├── technical-spec.md      # Technical Specification
└── [additional docs]      # Other project documentation
```

## Conventions

- **File naming**: Use kebab-case for multi-word files (e.g., `api-specs.md`)
- **Headings**: Use sentence case for section headings
- **Code blocks**: Specify language for syntax highlighting
- **Links**: Use relative paths for internal documentation links
- **Updates**: Add update notes at the top of files for significant changes

## Contact

For questions about documentation or to suggest improvements, please refer to the project's main README.md or contact the project maintainers.
