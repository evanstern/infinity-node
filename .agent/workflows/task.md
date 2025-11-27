---
description: Task Execution - Complete Task Workflow
---

1. Pre-Task Review
   - Read the task file (e.g., `tasks/current/IN-XXX-*.md` or `tasks/backlog/IN-XXX-*.md`).
   - Check if the task is still relevant and scope is clear.
   - Identify risks and dependencies.

2. Strategy Development
   - Plan the implementation steps.
   - Identify necessary changes and potential impact.

3. Start Task
   - Update task status to `in-progress` and set `started: YYYY-MM-DD`.
   - Move task file from `tasks/backlog/` to `tasks/current/` if applicable.
   - `git mv tasks/backlog/IN-XXX-*.md tasks/current/IN-XXX-*.md`

4. Execute Work
   - Perform the necessary code changes.
   - Update the task file progress as you go (check off items).
   - Test incrementally.

5. Testing & Validation
   - Verify all acceptance criteria.
   - Run automated tests if applicable.
   - Perform manual validation.

6. Completion
   - Update task status to `completed` and set `completed: YYYY-MM-DD`.
   - Move task file to `tasks/completed/`.
   - `git mv tasks/current/IN-XXX-*.md tasks/completed/IN-XXX-*.md`
   - Review changes and prepare for commit.
   - Use the `commit` workflow to commit the changes.
