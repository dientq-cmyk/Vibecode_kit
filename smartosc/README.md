# Vibe Coding at SmartOSC — Quick Start Guide

**Audience:** Anyone starting a new AI-assisted project at SmartOSC
**GitLab Instance:** https://git02.smartosc.com/
**AI Tool:** Claude Code + Superpowers plugin

---

## Overview

Vibe coding lets you build real, deployable software by directing an AI assistant — even without writing code yourself. This guide walks you through three phases: **setup → build → deploy**.

Follow these steps in order for every new project.

---

## Step 1 — Set Up Your Environment

Do this once per computer. Skip parts you have already completed.

### 1.1 — Request access to the tools you need (Github Repository, Confluence, Drive, Cluade Code Pro account)

Submit a request via Jira for the tools your project needs — a source-code repository, a Confluence space, a shared Drive, and so on:
**https://jira.smartosc.com/servicedesk/customer/portal/12/create/403**

After IT processes the request, you will receive a repository URL like:

```
https://git02.smartosc.com/your-group/your-project.git
```

Save the **repository URL** — you will need it in Step 2. IT also sets up Git authentication on your machine for you, so you do **not** need to create or manage a Personal Access Token (PAT) yourself.

IT will also provision a **Claude Code Pro account** for you. Save those login details as well — you will use them to sign in the first time you launch Claude Code in step 1.3.

### 1.2 — Install the required vibe-coding applications

To start vibe coding you need a few applications installed: **Docker**, **VS Code**, **Git**, and **Node.js**. Request all of them through a single IT ticket — IT will install and set them up for you:

**https://jira.smartosc.com/servicedesk/customer/portal/12/create/420**

> Docker runs your application in an isolated environment that matches production. VS Code is your code editor, Git tracks your changes, and Node.js provides the `npm` command used to install Claude Code in step 1.3.

**How to open a terminal (the easy way — inside VS Code):**

1. Open **VS Code** — from the Start menu (Windows), Launchpad/Applications (macOS), or your applications menu (Linux). You can also launch it by running `code` in any terminal.
2. *(Optional but recommended)* Open your project folder via **File → Open Folder…** so the terminal starts in the right place.
3. Open the built-in terminal: from the top menu choose **Terminal → New Terminal**, or press `` Ctrl+` `` (the backtick key, just below `Esc`).

A terminal panel opens at the bottom of the VS Code window. Run all the commands in this guide there.

**Check that you are ready to vibe code.** In that terminal, run each command below — every one should print a version number without errors:

| Tool | Command | Expected output |
|---|---|---|
| Git | `git --version` | `git version 2.x.x` |
| Docker | `docker --version` | `Docker version 2x.x.x` |
| Docker Compose | `docker compose version` | `Docker Compose version v2.x.x` |
| VS Code | `code --version` | a version number (e.g. `1.9x.x`) |
| Node.js | `node --version` | `v2x.x.x` (LTS) |
| npm | `npm --version` | a version number (e.g. `10.x.x`) |

If every command prints a version, your environment is ready — continue to step 1.3. If any command errors (e.g. "command not found"), that tool is not installed correctly: reopen your IT ticket so IT can fix it, then close and reopen the terminal and try again.

### 1.3 — Install Claude Code with Superpowers

> Node.js and `npm` were installed in step 1.2. If `npm --version` does not print a version, finish step 1.2 first.

1. Install Claude Code:
   ```
   npm install -g @anthropic-ai/claude-code
   ```
   > On macOS/Linux, if you get a permission error (`EACCES`), re-run with `sudo`: `sudo npm install -g @anthropic-ai/claude-code`.

2. Open Claude Code:
   ```
   claude
   ```
   The first time you run it, Claude Code opens your browser and asks you to log in. Sign in with the **Claude Code Pro account** IT provided in step 1.1.

3. Install the Superpowers plugin. Inside Claude Code, run these three commands in order:

   **Step 1 — Add the Superpowers marketplace**
   ```
   /plugin marketplace add obra/superpowers-marketplace
   ```
   Expected output: `Successfully added marketplace: superpowers-marketplace`

   **Step 2 — Install the Superpowers plugin**
   ```
   /plugin install superpowers@superpowers-marketplace
   ```
   Expected output: `✓ Installed superpowers. Run /reload-plugins to apply.`

   **Step 3 — Reload plugins to activate**
   ```
   /reload-plugins
   ```

4. Verify the installation:

   **Verify Claude Code** — run in your terminal:
   ```
   claude --version
   ```
   Expected output: a version number (e.g., `1.x.x (Claude Code)`).

   **Verify Superpowers** — open Claude Code and run:
   ```
   /plugin
   ```
   You should see `superpowers` listed as installed and enabled. You can also type `/superpowers:` — Claude Code will autocomplete available Superpowers skills (e.g., `brainstorming`, `writing-plans`, `executing-plans`). If the list appears, Superpowers is working.

---

## Step 2 — Initialize the Project

Do this once per project, in order.

### 2.1 — Clone the repository

Open a terminal and clone the repo using the URL from step 1.1:

```
git clone <your-repo-url>
cd <your-project-folder>
```

IT has already set up Git authentication on your machine, so the clone should work without asking for a username or password — and so will future `git pull` / `git push`. If you are prompted for credentials, or the clone fails with a permission error, **do not create a token yourself**: contact IT and they will fix your access.

### 2.2 — Start Claude Code

```
claude
```

### 2.3 — Set up the project structure

Send this prompt to have Claude configure the repository with SmartOSC standards:

> *"Set up this project following SmartOSC standards. Create a proper `.gitignore`, add the `CLAUDE.md` template, create `.env.example` with placeholder keys, and create an empty `THIRD_PARTY_NOTICES.md` table for asset licenses. Show me what will be created before making any changes."*

### 2.4 — Inject the SmartOSC knowledge base

> *"Fetch and read the SmartOSC knowledge base from this URL: `https://git02.smartosc.com/ai-projects/smartosc-vibe-coding-guide/-/raw/main/SmartOSC_Coding_Guide.md`. Apply all rules, conventions, and constraints in that file to every action you take in this project."*

This tells Claude about tech stack requirements, security rules, Docker configuration, and what it must never do.

### 2.5 — Scaffold the project with Superpowers

Follow these three steps in order:

**Step A — Brainstorm the project**

```
/superpowers:brainstorming
```

Claude will explore your intent, requirements, and design before writing any code. Describe what you want to build when prompted:

> *"I want to build [describe your app — what it does, who uses it, what problem it solves]. Use Node.js as the backend. Follow all rules in `SmartOSC_Coding_Guide.md` and `CLAUDE.md`. Also ask me who will log in, what roles they have, who may see or change which data, and which data is sensitive. Ask me which images, icons, fonts, logos, and sounds the app will use and where they come from."*

> **Security and licensing start here.** Answering these questions now (users, roles, who can access what, sensitive data, where images and fonts come from) is much cheaper than fixing security or copyright problems after the code is written.

**Step B — Write the implementation plan**

```
/superpowers:writing-plans
```

Claude will turn the brainstorm output into a concrete, step-by-step implementation plan — full project structure, Dockerfile, docker-compose.yml, and all configuration files. The plan includes a **Security** section: which routes need login, the permission rules, which input is validated, the required security middleware, and which data must never be logged. It also includes a **Licensing** section: every planned library with its license, and the source and license of every image, font, or sound.

**Step C — Execute the plan**

```
/superpowers:executing-plans
```

Claude will execute the plan with review checkpoints, generating all files and confirming each major step with you before proceeding.

### 2.6 — Your tech stack is packaged with Docker Compose (automatic)

You don't need to do anything for this step — it happens on its own. As Claude builds your project, it **automatically** bundles every part of your tech stack (the app plus its dependencies — database, cache, queue, and so on) into a single `docker-compose.yml`, so the whole stack starts with one command and runs the same on every machine. This is a SmartOSC standard baked into the knowledge base you loaded in step 2.4, so it always runs.

Claude generates the `Dockerfile`, the `docker-compose.yml`, and a matching `.env.example`, then tells you in plain language which services it included and what each one does.

If you ever want it to re-check or rebuild this setup, you can ask:

> *"Make sure my whole tech stack is packaged in `docker-compose.yml` following SmartOSC_Coding_Guide.md, and explain each service to me."*

### 2.7 — Run the project locally

```
docker compose up --build
```

Open your browser at `http://localhost:[PORT]` to verify the app is running.

---

## Ongoing Development

Repeat this workflow for every new feature or bug fix.

### Adding a feature

**Step 1 — Brainstorm the feature**

```
/superpowers:brainstorming
```

Explore intent, edge cases, and design before touching any code.

> *"Add [feature description]. Follow all conventions in CLAUDE.md and SmartOSC_Coding_Guide.md. Ask me who may use this feature, whose data it can see or change, and where any new images, fonts, or sounds come from."*

**Step 2 — Write an implementation plan**

```
/superpowers:writing-plans
```

Claude produces a step-by-step plan listing every file that will change, plus a **Security** section for the feature (login and permission rules, input validation, sensitive data) and a **Licensing** section (new libraries and assets with their licenses).

**Step 3 — Implement with TDD**

```
/superpowers:test-driven-development
```

Claude writes tests first, then implements code to make them pass. Use this for any feature that has business logic or can be tested. Every feature that touches protected data also gets **security tests**: not logged in → 401, another user's data → 403, invalid input → 400.

**Step 4 — Execute the plan**

```
/superpowers:executing-plans
```

Claude executes the plan with review checkpoints. For features with many independent tasks, use the parallel variant instead:

```
/superpowers:subagent-driven-development
```

---

### Fixing a bug

```
/superpowers:systematic-debugging
```

Claude applies the scientific method: reproduce → hypothesize → test → fix. Provide the symptom when prompted:

> *"There is a bug: [describe what happens vs. what should happen]. Do not change unrelated code."*

---

### Before finishing a feature

**Step 1 — Verify the work**

```
/superpowers:verification-before-completion
```

Claude checks that the feature actually does what was planned, runs tests, and surfaces any gaps before you mark it done.

**Step 2 — Run a security review**

```
/security-review
```

Claude reviews the changes on your branch for security problems — injection, missing login or permission checks, exposed secrets, unsafe handling of user data — and explains each finding in plain language. Ask Claude to fix anything rated High or Medium before continuing:

> *"Fix the security findings above following the Application Security rules in SmartOSC_Coding_Guide.md. Explain each fix to me."*

**Step 3 — Run a licensing check**

> *"Run the licensing checks from SmartOSC_Coding_Guide.md: check every dependency license against the allowed list, and confirm every image, icon, font, sound, and video is recorded in THIRD_PARTY_NOTICES.md with an approved source. Explain any problem to me in plain language and propose a fix."*

Claude lists any library or asset that could cause a copyright problem and suggests a safe replacement. If something is unclear or needs a paid license, check with IT before continuing.

**Step 4 — Finish the branch**

```
/superpowers:finishing-a-development-branch
```

Claude creates a clean commit, writes a Conventional Commit message, and checks for secrets or stray debug code before pushing.

**Step 5 — Request a code review**

```
/superpowers:requesting-code-review
```

Claude prepares a review-ready summary of the changes, then opens a Merge Request on GitLab.

**Step 6 — Apply review feedback**

```
/superpowers:receiving-code-review
```

Paste the reviewer's comments. Claude prioritises the findings and applies fixes systematically.

---

## Step 3 — Deploy to Production

When the feature branch is merged and all pipeline checks pass, follow this process.

### 3.1 — Production readiness check

> *"Review all code in this project for production readiness. Check for hardcoded secrets, improper dev/production separation, environment variables that should not be committed, and unhandled errors. Also check every rule in the Application Security section of SmartOSC_Coding_Guide.md: input validation, SQL injection, XSS, password hashing, login and permission checks on every route, security middleware (helmet, CORS whitelist, login rate limit), `npm audit` results, secrets or personal data in logs, and Docker running as non-root. Also check every rule in the Licensing & Intellectual Property section: all dependency licenses are on the allowed list, every image, icon, font, sound, and video is in THIRD_PARTY_NOTICES.md with an approved source, and no client or third-party logos are used without permission. Report all findings, most serious first."*

> `/security-review` in "Before finishing a feature" only checks the changes on your branch. This prompt checks the **whole project** — always run it before deploying.

Fix any issues before proceeding.

### 3.2 — Verify all tests pass

> *"Run all tests. Report which pass, which fail, and what the failures mean. Do not proceed if any test is failing."*

### 3.3 — Get the infrastructure summary

> *"Summarize the infrastructure requirements to deploy this project to production: traffic expectations, memory and CPU needs, required environment variables, database setup, background jobs, and recommended Docker resource limits. Format this as a handoff note for the DevOps team."*

### 3.4 — Submit the production deployment request

> **Internal apps only.** This process is for apps used inside the company network or VPN. If your app needs to be **public on the internet** (customers, partners, or access outside the VPN), contact IT for a security consultation **before** submitting the deployment request.

Using the summary from step 3.3, submit a PROD deployment request via Jira:
**https://jira.smartosc.com/servicedesk/customer/portal/12/create/600**

Fill in the ticket with:
- Application domain (e.g., `my-app.smartosc.com`)
- Resource requirements (memory, CPU) from the summary above
- Deployment type: **One-time** or **CI/CD (automated)**
- Required environment variable **names only** — never paste actual values into tickets
- Your name and team

---

## Key Rules — Quick Reference

```
Never commit:       .env · *.key · *.pem · passwords · API keys
Secrets go in:      .env (local only) · GitLab CI/CD Variables (server)
DB host in Docker:  use the service name (e.g. db) — never localhost
Commit format:      type(scope): short description
Branch format:      type/short-description
Never push to:      main directly — always open a Merge Request
Tech stack default: Node.js backend · Docker Compose · dev/prod separated
Security baseline:  validate input · parameterized SQL · login + permission checks
                    helmet · CORS whitelist · rate limit login · npm audit clean
                    no secrets/PII in logs · Docker runs as non-root
Before finishing:   /security-review on every feature branch
Public app?         Internal-only by default — consult IT before going public
Licensing:          libraries MIT/ISC/BSD/Apache only · never GPL/AGPL
                    images, fonts, sounds only from approved sources
                    record every asset in THIRD_PARTY_NOTICES.md · unsure? ask IT
```

---

*Guide version: 1.4 — Last updated: 2026-10-19*
*For support: contact your tech lead or the DevOps team.*
