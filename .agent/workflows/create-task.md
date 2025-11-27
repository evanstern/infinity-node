---
description: Create Task - MDTD Task Creation Assistant
---

1. Gather Requirements
   - Ask the user for the task title, problem statement, category, and priority (0-9).
   - Assess complexity (Simple, Moderate, Complex).

2. Get Next Task ID
   - Run `scripts/tasks/get-next-task-id.sh` to get the next available task ID.
   - // turbo
   - Store the ID (e.g., IN-037) in tasks/.task-id-counter.

3. Create Task File
   - Generate a filename: `tasks/backlog/IN-NNN-task-title-kebab-case.md`.
   - Create the file using `templates/task-template.md` as a base (or a standard structure if template unavailable).
   - Fill in the frontmatter:
     ```yaml
     type: task
     task-id: IN-NNN
     status: pending
     priority: N
     category: [category]
     agent: [agent]
     created: YYYY-MM-DD
     updated: YYYY-MM-DD
     complexity: [complexity]
     ```
   - Populate sections: Problem, Solution, Risks, Scope, Execution, Acceptance Criteria.

4. Update Task Counter
   - Run `scripts/tasks/update-task-counter.sh` to ensure the counter is in sync.
   - // turbo

5. Validate Task
   - Run `scripts/tasks/validate-task.sh IN-NNN` to ensure the task file is valid.
   - // turbo

6. Confirm Creation
   - Notify the user that the task has been created and validated.
