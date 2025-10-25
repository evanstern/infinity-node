---
type: dashboard
tags:
  - mdtd
  - dashboard
---

# Task Dashboard

Live overview of all tasks across the infinity-node project using Dataview queries.

## 🔴 Critical Priority

```dataview
TABLE status, category, agent, updated as "Last Updated"
FROM "tasks"
WHERE type = "task" AND priority = "critical"
SORT status ASC, updated DESC
```

## 🔥 In Progress

```dataview
TABLE priority, category, agent, file.ctime as "Started"
FROM "tasks/current"
WHERE type = "task" AND status = "in-progress"
SORT priority DESC, file.ctime ASC
```

## ⏸️ Blocked Tasks

```dataview
TABLE priority, category, agent, updated as "Last Updated"
FROM "tasks/current"
WHERE type = "task" AND status = "blocked"
SORT priority DESC, updated DESC
```

## 📋 Pending Tasks

```dataview
TABLE priority, category, agent, created
FROM "tasks/current" OR "tasks/backlog"
WHERE type = "task" AND status = "pending"
SORT priority DESC, created ASC
```

## Tasks by Agent

### Docker Agent

```dataview
TABLE status, priority, updated as "Last Updated"
FROM "tasks"
WHERE type = "task" AND agent = "docker" AND status != "completed"
SORT priority DESC, updated DESC
```

### Infrastructure Agent

```dataview
TABLE status, priority, updated as "Last Updated"
FROM "tasks"
WHERE type = "task" AND agent = "infrastructure" AND status != "completed"
SORT priority DESC, updated DESC
```

### Security Agent

```dataview
TABLE status, priority, updated as "Last Updated"
FROM "tasks"
WHERE type = "task" AND agent = "security" AND status != "completed"
SORT priority DESC, updated DESC
```

### Media Stack Agent

```dataview
TABLE status, priority, updated as "Last Updated"
FROM "tasks"
WHERE type = "task" AND agent = "media" AND status != "completed"
SORT priority DESC, updated DESC
```

### Testing Agent

```dataview
TABLE status, priority, updated as "Last Updated"
FROM "tasks"
WHERE type = "task" AND agent = "testing" AND status != "completed"
SORT priority DESC, updated DESC
```

### Documentation Agent

```dataview
TABLE status, priority, updated as "Last Updated"
FROM "tasks"
WHERE type = "task" AND agent = "documentation" AND status != "completed"
SORT priority DESC, updated DESC
```

## Tasks by Category

### Infrastructure

```dataview
TABLE status, priority, agent, updated as "Last Updated"
FROM "tasks"
WHERE type = "task" AND category = "infrastructure" AND status != "completed"
SORT priority DESC, updated DESC
```

### Docker

```dataview
TABLE status, priority, agent, updated as "Last Updated"
FROM "tasks"
WHERE type = "task" AND category = "docker" AND status != "completed"
SORT priority DESC, updated DESC
```

### Security

```dataview
TABLE status, priority, agent, updated as "Last Updated"
FROM "tasks"
WHERE type = "task" AND category = "security" AND status != "completed"
SORT priority DESC, updated DESC
```

### Media

```dataview
TABLE status, priority, agent, updated as "Last Updated"
FROM "tasks"
WHERE type = "task" AND category = "media" AND status != "completed"
SORT priority DESC, updated DESC
```

### Documentation

```dataview
TABLE status, priority, agent, updated as "Last Updated"
FROM "tasks"
WHERE type = "task" AND category = "documentation" AND status != "completed"
SORT priority DESC, updated DESC
```

## 📈 Statistics

### Task Count by Status

```dataview
TABLE length(rows) as "Count"
FROM "tasks"
WHERE type = "task"
GROUP BY status
SORT length(rows) DESC
```

### Task Count by Priority

```dataview
TABLE length(rows) as "Count"
FROM "tasks"
WHERE type = "task" AND status != "completed"
GROUP BY priority
SORT length(rows) DESC
```

### Task Count by Agent

```dataview
TABLE length(rows) as "Count"
FROM "tasks"
WHERE type = "task" AND status != "completed"
GROUP BY agent
SORT length(rows) DESC
```

## ✅ Recently Completed

```dataview
TABLE priority, category, agent, updated as "Completed"
FROM "tasks/completed"
WHERE type = "task"
SORT updated DESC
LIMIT 20
```

## 📊 Completion Trend

```dataview
TABLE count(rows) as "Completed"
FROM "tasks/completed"
WHERE type = "task"
GROUP BY dateformat(updated, "yyyy-MM") as "Month"
SORT "Month" DESC
LIMIT 12
```

---

**Last Updated:** Auto-refreshes when you open this note in Obsidian
**Note:** These queries require the Dataview plugin to be installed and enabled.
