# OpenSpec Directory

## Purpose
This directory contains OpenSpec workflow artifacts and specifications for the Flowbar project. OpenSpec is a structured workflow for managing specifications, changes, and documentation through AI-assisted processes.

## Directory Structure

### Root Files
- `AGENTS.md` - This file, providing AI agent instructions for OpenSpec workflow

### Subdirectories

#### `changes/`
Contains change specifications and proposals for the project. Each change represents a planned modification, feature addition, or improvement to be implemented.

**Organization:**
- Individual change files or subdirectories for each proposed change
- May include metadata such as status, priority, and dependencies
- Tracks the lifecycle from proposal through implementation

#### `specs/`
Contains detailed specifications for project components, features, and systems. These serve as the authoritative source of truth for how different parts of the system should behave.

**Organization:**
- Hierarchical structure matching the project's architecture
- Detailed requirements, behaviors, and constraints
- May include diagrams, examples, and acceptance criteria

## AI Agent Instructions

### Working with Changes

When working with the `changes/` directory:

1. **Creating Changes:**
   - Each change should be clearly named and descriptive
   - Include rationale, objectives, and expected outcomes
   - Document any dependencies or prerequisites
   - Specify acceptance criteria

2. **Managing Changes:**
   - Track change status (proposed, approved, in-progress, completed, rejected)
   - Update change documents as implementation progresses
   - Reference related specs and other changes
   - Maintain clear change history

3. **Reviewing Changes:**
   - Assess impact on existing specifications
   - Verify completeness and clarity
   - Check for conflicts with other changes
   - Validate alignment with project goals

### Working with Specifications

When working with the `specs/` directory:

1. **Creating Specifications:**
   - Be thorough and precise in describing requirements
   - Include relevant context and constraints
   - Provide examples and use cases where helpful
   - Reference related specifications and changes

2. **Maintaining Specifications:**
   - Keep specifications current with implementation
   - Document all revisions with rationale
   - Cross-reference related specifications
   - Highlight deprecations or breaking changes

3. **Using Specifications:**
   - Always consult relevant specs before making changes
   - Verify implementations match specifications
   - Identify specification gaps or ambiguities
   - Propose updates when specifications no longer match needs

### Workflow Guidelines

1. **Change-Driven Development:**
   - Start by creating or referencing a change in `changes/`
   - Update or create specifications in `specs/` as needed
   - Implement according to specifications
   - Update change status and documentation

2. **Documentation First:**
   - Prefer updating specifications before implementation
   - Use specifications as the source of truth
   - Ensure documentation and code remain synchronized

3. **Traceability:**
   - Link changes to affected specifications
   - Reference changes when updating specs
   - Maintain clear relationships between artifacts

4. **Collaboration:**
   - Use clear, descriptive language in all documentation
   - Provide context for decisions and requirements
   - Include examples and edge cases
   - Make specifications accessible to all team members

### File Naming Conventions

- Use descriptive, kebab-case filenames
- Include relevant prefixes or categories
- Use consistent terminology across the project
- Consider chronological ordering for related files

### Quality Standards

- **Clarity:** Write for both human and AI readers
- **Completeness:** Include all necessary information
- **Consistency:** Use uniform formatting and terminology
- **Accuracy:** Ensure technical details are correct
- **Maintainability:** Keep documents up-to-date and organized

## Notes

- This directory is part of the OpenSpec workflow system
- All agents working on this project should be familiar with these guidelines
- When in doubt, prefer over-documentation to under-documentation
- Regular maintenance and review of these artifacts ensures project health
