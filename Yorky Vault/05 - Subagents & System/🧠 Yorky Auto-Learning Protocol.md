---
tags: [auto-learning, skills, memory, protocol, yorky]
created: 2026-09-20
updated: 2026-09-20
version: 1.0.0
---

# 🧠 Yorky Auto-Learning & Skill Evolution Protocol

> [!IMPORTANT] Core Principle: No Learning Left Behind
> Every pattern discovered, bug fixed, workflow optimized, or user correction must be persisted immediately after task completion — either to **MEMORY** (facts, preferences, environment) or to **SKILLS** (reusable procedures).

---

## 📋 Auto-Learning Decision Loop

```text
TASK COMPLETES
       │
       ▼
┌──────────────────┐
│  EXTRACT LEARNINGS  │  ← What worked? What failed? What was new?
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│  CLASSIFY TYPE     │
└────────┬─────────┘
    ┌────┴────┐
    ▼         ▼
MEMORY     SKILLS
(facts)   (procedures)
    │         │
    ▼         ▼
UPDATE     UPDATE/CREATE
```

---

## 🎯 Classification Rules

### 1. → Goes to MEMORY (`MEMORY.md`)
* User preferences, corrections, feedback, communication style.
* Environment facts: paths, ports, DB configs, tool versions, Chrome profile.
* Channel/brand constants: colors, handles, IDs, schedules.
* Hard operational rules: *"never kill Chrome"*, *"exact DB counts only"*.

### 2. → Goes to SKILLS (`skills/`)
* Multi-step workflows with specific commands or CDP scripts.
* Troubleshooting patterns with verified root causes.
* Tool-specific operations (CDP, Flow, Innertube, PostgreSQL).
* Quality gates, verification protocols, safety rules.

---

## 🏷️ Skill Naming Conventions (Mandatory)

| ❌ Rejected Pattern | ✅ Approved Pattern | Rationale |
| :--- | :--- | :--- |
| `short-35-fix` | `short-forensic-troubleshooting` | Generalizable, not session-specific |
| `session-12-learnings` | `cdp-extraction-pitfalls` | Describes domain/action, not the date |
| `google-flow-problems` | `google-flow-clip-continuity` | Specific failure mode & actionable |
| `comment-bug-fix` | `innertube-comment-extraction` | Tool + domain, not "bug" |

**Rules**:
1. Lowercase with hyphens only.
2. Domain-first format: `tool-domain-action` or `domain-problem-solution`.
3. No numbers, dates, *"session"*, *"short-N"*, *"fix"*, or *"problem"*.
4. If a learning extends an existing skill → **patch that skill** instead of creating bloat.
5. If genuinely a new domain (>3 expected uses) → **create a new modular skill**.

---

## 🔄 Synchronization with Obsidian Vault (Mandatory Autonomous Step)

> [!CAUTION] Executive Directive (Yatharth Sachdeva — Sept 20, 2026)
> Yorky must autonomously author and maintain the Obsidian Vault. AntiGravity must not have to manually sync or clean up documentation for Yorky.

Whenever memory or skills evolve, Yorky must execute this complete 4-step sequence:
1. **Create the dedicated documentation note** in the appropriate domain folder (never stop at a 1-line bullet in session history).
2. **Update [[⚙️ Active Skills Architecture]]** so the documented list exactly matches `hermes --profile youtube skills list`.
3. **Cross-link with wikilinks** `[[Note Name]]` from [[🏠 Studio Command Center]] and relevant domain master guides.
4. **Update timestamps** in frontmatter (`updated: YYYY-MM-DD`).

---

See also: [[⚙️ Active Skills Architecture]] • [[📜 Historical Session Learnings]] • [[🤖 Subagent Delegation Protocol]]
