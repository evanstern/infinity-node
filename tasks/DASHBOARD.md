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

**📊 [[CHARTS|View Visual Charts & Analytics]] →**

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

### 📈 Visual Completion Trend

<!-- Chart generated using Obsidian Charts plugin -->
<!-- Data must be manually synced with the table above -->
<!-- Reference: https://charts.phib.ro/Meta/Charts/Charts+Documentation -->

```chart
type: line
labels: [2024-10, 2024-11]
series:
  - title: Tasks Completed
    data: [20, 2]
tension: 0.2
width: 80%
labelColors: false
fill: true
beginAtZero: true
```

_Note: Chart data should be manually updated to match the completion trend table above. For auto-updating visualization, see the DataviewJS alternative below._

**DataviewJS Alternative (Auto-updating):**

```dataviewjs
// Query all completed tasks
const tasks = dv.pages('"tasks/completed"')
    .where(p => p.type === "task" && p.updated);

// Group tasks by month
const monthCounts = {};
for (let task of tasks) {
    const month = task.updated.toFormat("yyyy-MM");
    monthCounts[month] = (monthCounts[month] || 0) + 1;
}

// Sort months and get last 12
const sortedMonths = Object.keys(monthCounts).sort();
const last12Months = sortedMonths.slice(-12);

// Prepare data
const data = last12Months.map(month => monthCounts[month] || 0);
const totalTasks = data.reduce((a, b) => a + b, 0);

// ASCII bar chart visualization
dv.header(4, "📊 Task Completion Trend (Auto-updating)");
dv.paragraph(`**Total:** ${totalTasks} tasks completed across ${last12Months.length} months`);

if (data.length === 0) {
    dv.paragraph("_No completed tasks yet_");
} else {
    const maxCount = Math.max(...data, 1);
    const rows = last12Months.map((month, i) => {
        const count = data[i];
        const barLength = Math.round((count / maxCount) * 30);
        const bar = "█".repeat(barLength);
        const percentage = maxCount > 0 ? Math.round((count / maxCount) * 100) : 0;
        return [month, count, bar + ` ${percentage}%`];
    });

    dv.table(["Month", "Count", "Visual Trend"], rows);
}
```

---

**Last Updated:** Auto-refreshes when you open this note in Obsidian
**Note:** These queries and charts require the Dataview plugin to be installed and enabled.
