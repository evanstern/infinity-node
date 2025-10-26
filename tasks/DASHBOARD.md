---
type: dashboard
tags:
  - mdtd
  - dashboard
---

# Task Dashboard

Live overview of all tasks across the infinity-node project using Dataview queries.

## 🔴 Critical Priority (0-1)

```dataview
TABLE status, category, agent, updated as "Last Updated"
FROM "tasks"
WHERE type = "task" AND priority <= 1 AND status != "completed"
SORT priority ASC, status ASC, updated DESC
```

## 📌 Current Tasks (Active Work)

```dataview
TABLE status, priority, category, agent, updated as "Last Updated"
FROM "tasks/current"
WHERE type = "task"
SORT choice(status = "in-progress", 0, choice(status = "blocked", 1, 2)) ASC, priority ASC, updated DESC
```

## 🔥 In Progress

```dataview
TABLE priority, category, agent, file.ctime as "Started"
FROM "tasks/current"
WHERE type = "task" AND status = "in-progress"
SORT priority ASC, file.ctime ASC
```

## ⏸️ Blocked Tasks

```dataview
TABLE priority, category, agent, updated as "Last Updated"
FROM "tasks/current"
WHERE type = "task" AND status = "blocked"
SORT priority ASC, updated DESC
```

## 📋 Backlog (Not Yet Started)

```dataview
TABLE priority, category, agent, created
FROM "tasks/backlog"
WHERE type = "task" AND status = "pending"
SORT priority ASC, created ASC
```

## Tasks by Agent

### Docker Agent

```dataview
TABLE status, priority, updated as "Last Updated"
FROM "tasks"
WHERE type = "task" AND agent = "docker" AND status != "completed"
SORT priority ASC, updated DESC
```

### Infrastructure Agent

```dataview
TABLE status, priority, updated as "Last Updated"
FROM "tasks"
WHERE type = "task" AND agent = "infrastructure" AND status != "completed"
SORT priority ASC, updated DESC
```

### Security Agent

```dataview
TABLE status, priority, updated as "Last Updated"
FROM "tasks"
WHERE type = "task" AND agent = "security" AND status != "completed"
SORT priority ASC, updated DESC
```

### Media Stack Agent

```dataview
TABLE status, priority, updated as "Last Updated"
FROM "tasks"
WHERE type = "task" AND agent = "media" AND status != "completed"
SORT priority ASC, updated DESC
```

### Testing Agent

```dataview
TABLE status, priority, updated as "Last Updated"
FROM "tasks"
WHERE type = "task" AND agent = "testing" AND status != "completed"
SORT priority ASC, updated DESC
```

### Documentation Agent

```dataview
TABLE status, priority, updated as "Last Updated"
FROM "tasks"
WHERE type = "task" AND agent = "documentation" AND status != "completed"
SORT priority ASC, updated DESC
```

## Tasks by Category

### Infrastructure

```dataview
TABLE status, priority, agent, updated as "Last Updated"
FROM "tasks"
WHERE type = "task" AND category = "infrastructure" AND status != "completed"
SORT priority ASC, updated DESC
```

### Docker

```dataview
TABLE status, priority, agent, updated as "Last Updated"
FROM "tasks"
WHERE type = "task" AND category = "docker" AND status != "completed"
SORT priority ASC, updated DESC
```

### Security

```dataview
TABLE status, priority, agent, updated as "Last Updated"
FROM "tasks"
WHERE type = "task" AND category = "security" AND status != "completed"
SORT priority ASC, updated DESC
```

### Media

```dataview
TABLE status, priority, agent, updated as "Last Updated"
FROM "tasks"
WHERE type = "task" AND category = "media" AND status != "completed"
SORT priority ASC, updated DESC
```

### Documentation

```dataview
TABLE status, priority, agent, updated as "Last Updated"
FROM "tasks"
WHERE type = "task" AND category = "documentation" AND status != "completed"
SORT priority ASC, updated DESC
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
TABLE length(rows) as "Completed"
FROM "tasks/completed"
WHERE type = "task"
GROUP BY dateformat(updated, "yyyy-MM") as "Month"
SORT "Month" DESC
LIMIT 12
```

---

**Last Updated:** Auto-refreshes when you open this note in Obsidian
**Note:** These queries require the Dataview plugin to be installed and enabled.
