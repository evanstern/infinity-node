---
type: dashboard
tags:
  - mdtd
  - dashboard
  - charts
  - visualization
---

# Task Charts & Visualizations

Visual analytics for task tracking across the infinity-node project.

**Quick Navigation:** [[DASHBOARD|← Back to Task Dashboard]]

---

## 📈 Task Completion Trend

Track how many tasks are completed each month over time.

### Graphical Chart

<!-- Static chart using Obsidian Charts plugin -->
<!-- Data should be manually updated from completion trend table in DASHBOARD.md -->
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

_Note: Update data manually from [[DASHBOARD#Completion Trend|Completion Trend table]]_

### Auto-Updating View

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
dv.header(4, "📊 Completion Trend (Last 12 Months)");
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

## 🎯 Active Tasks by Priority

Distribution of non-completed tasks across priority levels (0=critical, 9=lowest).

### Graphical Chart

```chart
type: bar
labels: [P0-P1, P2-P4, P5-P6, P7-P9]
series:
  - title: Active Tasks
    data: [0, 3, 2, 0]
width: 80%
labelColors: false
beginAtZero: true
```

_Note: Update data from [[DASHBOARD#Task Count by Priority|Priority Statistics]]_

### Auto-Updating View

```dataviewjs
// Query all non-completed tasks
const tasks = dv.pages('"tasks"')
    .where(p => p.type === "task" && p.status !== "completed" && p.priority != null);

// Group by priority
const priorityGroups = {
    "P0-P1 (Critical)": 0,
    "P2-P4 (High-Medium)": 0,
    "P5-P6 (Low)": 0,
    "P7-P9 (Very Low)": 0
};

for (let task of tasks) {
    const priority = task.priority;
    if (priority <= 1) {
        priorityGroups["P0-P1 (Critical)"]++;
    } else if (priority <= 4) {
        priorityGroups["P2-P4 (High-Medium)"]++;
    } else if (priority <= 6) {
        priorityGroups["P5-P6 (Low)"]++;
    } else {
        priorityGroups["P7-P9 (Very Low)"]++;
    }
}

dv.header(4, "🎯 Priority Distribution");
dv.paragraph(`**Total active tasks:** ${tasks.length}`);

const maxCount = Math.max(...Object.values(priorityGroups), 1);
const rows = Object.entries(priorityGroups).map(([group, count]) => {
    const barLength = Math.round((count / maxCount) * 30);
    const bar = "█".repeat(barLength);
    const percentage = tasks.length > 0 ? Math.round((count / tasks.length) * 100) : 0;
    return [group, count, bar + ` ${percentage}%`];
});

dv.table(["Priority Range", "Count", "Distribution"], rows);
```

---

## 👥 Tasks by Agent

Workload distribution across different agents.

```dataviewjs
// Query all non-completed tasks
const tasks = dv.pages('"tasks"')
    .where(p => p.type === "task" && p.status !== "completed" && p.agent);

// Group by agent
const agentCounts = {};
for (let task of tasks) {
    const agent = task.agent || "unassigned";
    agentCounts[agent] = (agentCounts[agent] || 0) + 1;
}

// Sort by count descending
const sortedAgents = Object.entries(agentCounts)
    .sort((a, b) => b[1] - a[1]);

dv.header(4, "👥 Agent Workload");
dv.paragraph(`**Total active tasks:** ${tasks.length} across ${sortedAgents.length} agents`);

if (sortedAgents.length === 0) {
    dv.paragraph("_No active tasks_");
} else {
    const maxCount = Math.max(...sortedAgents.map(a => a[1]), 1);
    const rows = sortedAgents.map(([agent, count]) => {
        const barLength = Math.round((count / maxCount) * 40);
        const bar = "█".repeat(barLength);
        const percentage = tasks.length > 0 ? Math.round((count / tasks.length) * 100) : 0;
        // Capitalize agent name
        const agentName = agent.charAt(0).toUpperCase() + agent.slice(1);
        return [agentName, count, bar + ` ${percentage}%`];
    });
    
    dv.table(["Agent", "Tasks", "Workload"], rows);
}
```

---

## 📂 Tasks by Category

Distribution of active tasks across different categories.

```dataviewjs
// Query all non-completed tasks
const tasks = dv.pages('"tasks"')
    .where(p => p.type === "task" && p.status !== "completed" && p.category);

// Group by category
const categoryCounts = {};
for (let task of tasks) {
    const category = task.category || "uncategorized";
    categoryCounts[category] = (categoryCounts[category] || 0) + 1;
}

// Sort by count descending
const sortedCategories = Object.entries(categoryCounts)
    .sort((a, b) => b[1] - a[1]);

dv.header(4, "📂 Category Distribution");
dv.paragraph(`**Total active tasks:** ${tasks.length} across ${sortedCategories.length} categories`);

if (sortedCategories.length === 0) {
    dv.paragraph("_No active tasks_");
} else {
    const maxCount = Math.max(...sortedCategories.map(c => c[1]), 1);
    const rows = sortedCategories.map(([category, count]) => {
        const barLength = Math.round((count / maxCount) * 40);
        const bar = "█".repeat(barLength);
        const percentage = tasks.length > 0 ? Math.round((count / tasks.length) * 100) : 0;
        // Capitalize category name
        const categoryName = category.charAt(0).toUpperCase() + category.slice(1);
        return [categoryName, count, bar + ` ${percentage}%`];
    });
    
    dv.table(["Category", "Tasks", "Distribution"], rows);
}
```

---

## 📊 Task Status Breakdown

Overview of all tasks by current status.

```dataviewjs
// Query all tasks
const tasks = dv.pages('"tasks"')
    .where(p => p.type === "task" && p.status);

// Group by status
const statusCounts = {};
for (let task of tasks) {
    const status = task.status || "unknown";
    statusCounts[status] = (statusCounts[status] || 0) + 1;
}

// Define status order and emojis
const statusOrder = [
    { key: "in-progress", label: "In Progress", emoji: "🔥" },
    { key: "pending", label: "Pending", emoji: "⏸️" },
    { key: "blocked", label: "Blocked", emoji: "🚫" },
    { key: "completed", label: "Completed", emoji: "✅" }
];

dv.header(4, "📊 Status Overview");
dv.paragraph(`**Total tasks:** ${tasks.length}`);

const maxCount = Math.max(...Object.values(statusCounts), 1);
const rows = statusOrder
    .filter(s => statusCounts[s.key] > 0)
    .map(s => {
        const count = statusCounts[s.key];
        const barLength = Math.round((count / maxCount) * 40);
        const bar = "█".repeat(barLength);
        const percentage = tasks.length > 0 ? Math.round((count / tasks.length) * 100) : 0;
        return [`${s.emoji} ${s.label}`, count, bar + ` ${percentage}%`];
    });

dv.table(["Status", "Count", "Distribution"], rows);
```

---

**Last Updated:** Auto-refreshes when you open this note in Obsidian

**Notes:**
- DataviewJS charts update automatically based on current task data
- Static graphical charts require manual updates from [[DASHBOARD|main dashboard]]
- Requires Dataview plugin and Obsidian Charts plugin to be installed

