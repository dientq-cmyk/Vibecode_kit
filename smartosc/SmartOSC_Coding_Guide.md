# SmartOSC Vibe Coding — Knowledge Base for AI Assistants

> This file is the authoritative knowledge base for AI coding assistants (Claude Code, Cursor, Copilot, etc.)
> working on SmartOSC vibe coding projects.
>
> **Read this file in full before taking any action in a SmartOSC project.**
> All rules below are mandatory unless the project's own CLAUDE.md explicitly overrides them.

---

## Tech Stack Defaults

When a tech stack is not specified, use these defaults:

| Layer | Default choice | Reason |
|---|---|---|
| Backend / API | **Node.js** (Express or Fastify) | Team familiarity, fast iteration |
| Frontend | React or plain HTML/JS | Based on complexity |
| Database | PostgreSQL | Production-grade, well-supported |
| Containerization | Docker + Docker Compose | Required for all projects |
| CI/CD | GitLab CI (`.gitlab-ci.yml`) | Company standard |
| Package manager | npm | Default for Node.js |

**If the user has already chosen a different stack, follow their choice.** Do not switch stacks mid-project.

---

## Environment Separation — Required

Every project must have **two clearly separated modes**:

### Development mode
- Uses `.env` for local secrets
- Verbose logging enabled
- Hot-reload / watch mode acceptable
- Database seeding scripts allowed
- Debug tools may be included

### Production mode
- Secrets loaded from environment variables only (never from files committed to Git)
- Minimal logging (no stack traces exposed to users)
- No debug endpoints or tools
- `NODE_ENV=production` must be set
- Health check endpoint (`/health`) must exist

**Never mix dev and production configuration.** Use `NODE_ENV` to switch behavior at runtime.

```js
// Correct — reads from environment
const db = process.env.DB_HOST;

// Wrong — hardcoded
const db = 'localhost';
```

---

## TO DO ✅

These actions are required or strongly recommended:

### Code
- Use environment variables for ALL configuration values (ports, hostnames, credentials, feature flags)
- Reference secrets via `process.env.VARIABLE_NAME` — never inline them
- Add a `/health` endpoint that returns HTTP 200 when the app is running
- Keep `Dockerfile` and `docker-compose.yml` at the project root
- Use `env_file: .env` in `docker-compose.yml` to load environment variables
- Set `restart: unless-stopped` on all services in `docker-compose.yml`
- Add a health check on the database service so the app waits for it to be ready
- Use named volumes for database data (so data survives container restarts)
- Separate application code into a `src/` directory

### Git & commits
- Create a new branch for every feature or fix: `feat/feature-name`, `fix/bug-name`
- Write commit messages in Conventional Commits format: `type(scope): short description`
- Use imperative form in descriptions: `add login page` not `added login page`
- Keep commit messages under 72 characters
- Open a Merge Request for all changes — never push directly to `main`
- Delete feature branches after they are merged

### Security
- Add `.env` to `.gitignore` before the first commit — never after
- Include `.env.example` in the repository (keys only, no values)
- Run `git status` before every `git add` to confirm `.env` is not staged
- Ask the user to confirm before committing any file containing credentials
- Store secrets for server deployment in GitLab CI/CD Variables only

### Docker
- Use `docker compose` (not `docker-compose` — the legacy command)
- Use `docker compose up --build` to start the application
- Set `DB_HOST` to the Docker service name (e.g., `db`) — never `localhost`
- Do not include a `version:` field in `docker-compose.yml` (it is deprecated)
- Test that data persists after `docker compose down && docker compose up --build`
- Pin the base image to a specific version tag (e.g. `node:22-alpine`) — never `latest`
- Use a multi-stage `Dockerfile` so build tools and dev dependencies are not shipped in the final image
- Run the app as a non-root user (`USER node` in Node.js images; use `COPY --chown=node:node` so the app can read its files)

---

## NOT TO DO ❌

These actions are forbidden. Never do them, even if asked:

### Secrets and credentials
- ❌ Never commit `.env`, `.env.local`, or any file containing real secrets
- ❌ Never hardcode passwords, API keys, tokens, or connection strings in source code
- ❌ Never put real values in `.env.example`
- ❌ Never commit `.pem`, `.key`, `.p12`, `.pfx`, or certificate files
- ❌ Never include database connection strings with embedded credentials in any committed file
- ❌ Never log secrets to the console, even in development
- ❌ Never put secrets in CI/CD pipeline scripts — use GitLab CI/CD Variables

### Git
- ❌ Never push directly to `main` or `master`
- ❌ Never force-push to `main`
- ❌ Never commit large binary files (videos, installers, compiled binaries)
- ❌ Never write commit messages like `fix stuff`, `update`, `wip`, or `asdfgh`
- ❌ Never delete the `CLAUDE.md` file from any project

### Docker
- ❌ Never use `localhost` as a database host inside Docker
- ❌ Never use `docker-compose` (legacy command) — always `docker compose`
- ❌ Never add `version:` to `docker-compose.yml`
- ❌ Never hardcode secrets in `docker-compose.yml` — always use `env_file`
- ❌ Never run the application container as `root`
- ❌ Never publish the database port to the outside (`ports:` on the `db` service). If the user needs a local DB GUI in development, bind to `127.0.0.1` only (e.g. `127.0.0.1:5432:5432`) and never in production

### Code quality
- ❌ Never expose internal error stack traces in API responses in production
- ❌ Never disable security middleware (CORS, rate limiting, auth checks) without explicit instruction
- ❌ Never leave `TODO` comments in committed code without creating a tracked issue
- ❌ Never leave unused imports, dead code, or commented-out blocks in committed code
- ❌ Never use `console.log` for debugging in production code — use a logger with log levels

### Licensing
- ❌ Never add GPL, AGPL, SSPL, BUSL, non-commercial, or unlicensed dependencies
- ❌ Never download images, icons, fonts, audio, or video from Google Images, Pinterest, social media, or watermarked stock sites
- ❌ Never add an asset without a row in `THIRD_PARTY_NOTICES.md`
- ❌ Never copy code from GPL/AGPL or unlicensed repositories
- ❌ Never remove license or copyright headers from files
- ❌ Never use client or third-party logos without permission

---

## Application Security — Required

> **Internal apps by default.** Projects built with this guide are assumed to be **internal-only** (reached through the company network or VPN). The rules below are the baseline for internal apps.
>
> **Making an app public is out of scope for this guide.** If the user mentions exposing the app to the internet (public domain, customers, partners, mobile clients outside the VPN), stop and tell them: *"Public apps need a security consultation with IT before deployment — please contact IT first."* Do not write public-facing deployment config until the user confirms IT has been consulted.

Apply these rules when generating new code **and** when modifying existing code. If existing code violates them, surface the violation to the user before proceeding.

### Security in every phase
Security is designed in from the start, not added at the end. Do this even if the user does not ask:

| Phase | What to do |
|---|---|
| Brainstorming / design | Ask the user: who will log in, what roles exist, who may see or change which data, and which data is sensitive (personal data, financial data, internal documents). Ask in plain language — the user may be non-technical. |
| Writing the plan | Include a **Security** section in every plan: routes that require login, permission rules per role, input to validate, required middleware, and data that must never be logged. |
| Implementing (TDD) | For every route that touches protected data, write security tests first: not logged in → 401, accessing another user's data or a forbidden role → 403, invalid input → 400. |
| Before finishing | Run `/security-review` on the branch and fix High/Medium findings before committing. |

If the design answers are missing when you reach the plan or implementation phase, stop and ask the user instead of guessing permission rules.

### Input & database
- Validate every request body, query string, and URL parameter against a schema (e.g. `zod` or `joi`) before using it. Reject invalid input with HTTP 400.
- Use **parameterized queries** or an ORM/query builder for all database access. Never build SQL by concatenating or interpolating user input.

  ```js
  // Correct — parameterized
  await db.query('SELECT * FROM users WHERE email = $1', [email]);

  // Wrong — SQL injection
  await db.query(`SELECT * FROM users WHERE email = '${email}'`);
  ```
- Never render user-supplied data as raw HTML — no `innerHTML`, `dangerouslySetInnerHTML`, or unescaped template output. Use text rendering (`textContent`, React's default `{value}`).
- If the app accepts file uploads: enforce a maximum file size, allow only an explicit list of file types (check both extension and MIME type), generate random filenames on the server, and never serve uploaded files from the application's code directory.

### Authentication & authorization
- Hash passwords with `bcrypt` or `argon2`. Never store plain-text passwords, never use MD5/SHA-1/SHA-256 alone for passwords, and never write custom crypto.
- Load JWT/session secrets from environment variables. Set a short token lifetime (e.g. 15–60 minutes for access tokens).
- Session/auth cookies must be `httpOnly`, `secure` (in production), and `sameSite: 'lax'` or `'strict'`.
- If authentication uses cookies, protect state-changing requests (POST/PUT/PATCH/DELETE) against CSRF.
- Every non-public route must check **both**: (1) the user is logged in, and (2) the user is allowed to access *this specific* resource (ownership or role check). Never trust a user ID or role sent from the client.
- Login errors must not reveal whether the username or the password was wrong — use one generic message.

### Required middleware (add at scaffold time)
Every Express/Fastify backend must include security headers, a CORS whitelist, and rate limiting on login. Add them when the project is created — do not wait for the user to ask.

```js
const helmet = require('helmet');
const cors = require('cors');
const rateLimit = require('express-rate-limit');

app.set('trust proxy', 1); // app runs behind the company reverse proxy
app.use(helmet());
app.use(cors({
  origin: (process.env.CORS_ORIGINS || '').split(',').filter(Boolean), // internal domains only
  credentials: true,
}));

const loginLimiter = rateLimit({ windowMs: 15 * 60 * 1000, limit: 10 });
app.post('/api/auth/login', loginLimiter, loginHandler);
```

- Add `CORS_ORIGINS` to `.env.example` (key only).
- Never set the CORS origin to `*` or reflect any origin.
- For Fastify, use the equivalents: `@fastify/helmet`, `@fastify/cors`, `@fastify/rate-limit`.

### Dependencies
- Always commit `package-lock.json`. Use `npm ci` (not `npm install`) in the `Dockerfile`.
- Run `npm audit --audit-level=high` before committing. If it reports **High** or **Critical** issues, tell the user and propose a fix (`npm audit fix` or a version upgrade) before committing.
- Only add well-known, actively maintained packages. Tell the user before adding any new dependency.

### Logging & personal data (PII)
- Never log passwords, tokens, session IDs, API keys, card numbers, or full request bodies of auth endpoints.
- Avoid logging personal data (email, phone number, national ID, address). If a log line needs to identify a user, log the internal user ID instead.

---

## Licensing & Intellectual Property — Required

> **Internal apps are not exempt.** Copyright, licenses, and trademarks apply to internal apps too. Every library, image, icon, font, sound, video, and copied code snippet must have a clear right to use.
>
> **This is operational guidance, not legal advice.** When a case is unclear, when a paid asset or license is needed, or when the user wants to use something not covered below, stop and tell them: *"Please check with IT before using this."*

### Licensing in every phase
Do this even if the user does not ask:

| Phase | What to do |
|---|---|
| Brainstorming / design | Ask the user which images, icons, fonts, logos, sounds, or videos the app will show, and where they come from (made in-house, provided by a client, downloaded, AI-generated). Ask in plain language. |
| Writing the plan | Include a **Licensing** section in every plan: planned libraries with their licenses, and the source and license of every planned asset. |
| Implementing | Check the license before adding any dependency. Record every non-code asset in `THIRD_PARTY_NOTICES.md` in the same change that adds it. |
| Before finishing | Run the dependency license check below and confirm `THIRD_PARTY_NOTICES.md` is complete. |

### Dependencies (npm libraries)
- **Allowed:** `MIT`, `ISC`, `BSD-2-Clause`, `BSD-3-Clause`, `Apache-2.0`, `0BSD`, `CC0-1.0`, `Unlicense`, `BlueOak-1.0.0`.
- **Allowed with notice:** `LGPL-*`, `MPL-2.0` — tell the user before adding, use the library unmodified, and never copy its source into the project.
- **Forbidden:** `GPL-*`, `AGPL-*`, `SSPL`, `BUSL`, `CC-BY-NC-*`, any "non-commercial" license, and packages with no license or `UNLICENSED`. If no allowed alternative exists, stop and tell the user to check with IT.
- This applies to **all** dependencies, including dependencies of dependencies.
- Set `"private": true` in the project's `package.json`, then check licenses with:

  ```
  npx license-checker-rseidelsohn --production --excludePrivatePackages --onlyAllow "MIT;ISC;BSD-2-Clause;BSD-3-Clause;Apache-2.0;0BSD;CC0-1.0;Unlicense;BlueOak-1.0.0"
  ```

  It exits with an error and names the package if any license is outside the list. For packages reported as `UNKNOWN` or with combined licenses (e.g. `(MIT OR GPL-3.0)`), read the package's `LICENSE` file and report the result to the user. LGPL/MPL packages the user approved can be added with `--excludePackages`.
- Never use the unmaintained `license-checker` package — use `license-checker-rseidelsohn`.

### Images, icons, fonts, audio, video
- **Approved sources:**

  | Type | Source | Notes |
  |---|---|---|
  | Fonts | Google Fonts | Open licenses (mostly OFL) — safe for web embedding |
  | Icons | Lucide, Heroicons, Tabler Icons | MIT |
  | Icons | Font Awesome Free | Icons CC BY 4.0 — attribution required |
  | Photos | Unsplash, Pexels, Pixabay | No people or brands implying endorsement |
  | Audio | Freesound (CC0 filter only), Pixabay Audio | — |
  | Any | Created in-house by SmartOSC staff | Note the author |
  | Any | Provided by the client | Only with written permission — note who provided it |

- **Forbidden sources:** Google Images, Pinterest, Dribbble/Behance screenshots, social media, any watermarked image (Getty, Shutterstock, etc.), "free for personal use" fonts (e.g. from dafont), and anything "found on a website".
- Paid stock (Adobe Stock, Envato, Shutterstock, etc.) or any source not listed above → check with IT first.
- AI-generated images or audio: allowed for internal decoration only. Never prompt for real people, logos, brands, or a named artist's style. Record them as "AI-generated" in `THIRD_PARTY_NOTICES.md`.

### Copied code
- Short snippets from StackOverflow (licensed CC BY-SA) must carry a source comment: `// Source: <URL> (CC BY-SA 4.0)`.
- Never copy code from a GPL/AGPL repository or from a repository without a license.
- If you reproduce a substantial piece of code from a specific open-source project, tell the user which project and its license, and apply the dependency rules above.
- Never remove existing license or copyright headers from files.

### Brand & trademarks
- Use the SmartOSC logo and brand assets only from the official brand kit — ask IT where to get it.
- Client logos and names may appear only when the client has given permission. If unsure, check with IT.
- Never use third-party logos (Google, Microsoft, Facebook, etc.) except in their official "Sign in with…" buttons following their brand guidelines.
- Never copy another product's name, logo, or distinctive look so that the app could be mistaken for it.

### Attribution file — `THIRD_PARTY_NOTICES.md`
Keep this file at the project root. Add one row per non-code asset in the same commit that adds the asset:

```markdown
| File | Source URL | License | Author | Attribution required |
|---|---|---|---|---|
| public/img/hero.jpg | https://unsplash.com/photos/xyz | Unsplash License | Jane Doe | No |
| public/fonts/Inter.woff2 | https://fonts.google.com/specimen/Inter | OFL-1.1 | Rasmus Andersson | No |
```

If an asset requires attribution, show it in the app (e.g. an "About" or "Credits" page).

### Out of scope — check with IT
- Using third-party datasets or scraping websites
- Third-party API terms of service (usage limits, data storage, branding rules)
- Questions about ownership of AI-generated content

---

## Security & Licensing Rules Summary

| Risk | Rule |
|---|---|
| Committed secrets | Always check `git status` before `git add`. If `.env` appears, stop immediately. |
| Hardcoded credentials | Use `process.env.VARIABLE_NAME`. Never inline values. |
| Public repositories | All project repos must be **Private**. |
| Token expiry | Personal Access Tokens expire every 90 days. IT provisions and renews them — users do not create or manage tokens. |
| CI/CD secrets | Set in GitLab → Settings → CI/CD → Variables. Never in pipeline YAML. |
| Production vs dev | Use `NODE_ENV` to switch. Never ship dev-only tools to production. |
| SQL injection | Parameterized queries or ORM only. Never concatenate user input into SQL. |
| XSS | Never render user data as raw HTML (`innerHTML`, `dangerouslySetInnerHTML`). |
| Unvalidated input | Validate all request input against a schema (`zod`/`joi`). |
| Weak password storage | `bcrypt` or `argon2` only. Never plain text or bare hashes. |
| Broken access control | Every non-public route checks login **and** ownership/role. |
| Missing security middleware | `helmet` + CORS whitelist + login rate limit on every backend. |
| Vulnerable dependencies | `npm audit --audit-level=high` must be clean before commit. |
| PII in logs | Never log passwords, tokens, or personal data — log user IDs instead. |
| Insecure containers | Pinned base image, multi-stage build, run as non-root `USER node`. |
| Public exposure | Internal-only by default. Public apps require IT security consultation first. |
| Copyleft dependency | No GPL/AGPL/SSPL/BUSL or unlicensed packages. License check must pass before commit. |
| Unlicensed asset | Images, fonts, audio, video only from approved sources, recorded in `THIRD_PARTY_NOTICES.md`. |
| Trademark misuse | No client or third-party logos without permission. Never imitate another product. |

If you detect any of the above violations in existing code, surface them to the user immediately before proceeding.

---

## GitLab Integration

| Action | Details |
|---|---|
| GitLab instance | https://git02.smartosc.com/ |
| Authentication | HTTPS only with Personal Access Token (PAT) |
| PAT expiry | 90 days maximum |
| PAT scopes | `read_repository` + `write_repository` |
| PAT management | Provisioned, configured on the user's machine, and renewed by IT — users never create or rotate tokens. Never instruct a user to generate a PAT; tell them to contact IT instead. |
| CI/CD deploy branch | `main` only |
| Required files | `CLAUDE.md` · `Dockerfile` · `docker-compose.yml` · `.env.example` · `.gitignore` · `.gitlab-ci.yml` · `THIRD_PARTY_NOTICES.md` |

---

## Commit Message Rules

Format: `type(scope): short description`

Allowed types:

| Type | When to use |
|---|---|
| `feat` | Adding a new feature |
| `fix` | Fixing a bug |
| `docs` | Documentation only |
| `style` | Formatting, no logic change |
| `refactor` | Restructuring without behavior change |
| `test` | Adding or updating tests |
| `chore` | Build scripts, dependencies |
| `ci` | CI/CD pipeline changes |
| `revert` | Reverting a previous commit |

Rules:
- Imperative form: `add feature` not `added feature`
- Lowercase, no trailing period
- Under 72 characters

---

## Before Every Commit — Self-Check

Before staging or committing, verify:

1. `git status` shows no `.env`, `*.key`, `*.pem`, or credential files
2. No hardcoded passwords, tokens, or connection strings in any changed file
3. `docker compose up --build` runs without errors
4. The app is accessible at `http://localhost:[PORT]`
5. Commit message follows Conventional Commits format
6. Changes are on a feature branch, not on `main`
7. `npm audit --audit-level=high` reports no High or Critical issues
8. Changed code follows the **Application Security** rules (validated input, parameterized queries, auth checks, no secrets or PII in logs)
9. The dependency license check (`license-checker-rseidelsohn --onlyAllow …`) passes
10. Every image, icon, font, audio, or video file added in this change has a row in `THIRD_PARTY_NOTICES.md`

If any of these checks fail, surface the issue to the user and stop.

---

## Responding to the User

- When generating code, always state which files will be created or modified before making changes
- When a rule from this guide conflicts with a user request, explain the rule and ask for confirmation before proceeding
- When generating `docker-compose.yml`, always verify: no `version:` field, service names used for hostnames, `env_file` present
- When scaffolding a backend, always add the required security middleware (`helmet`, CORS whitelist, login rate limit) and explain in plain language what each one protects against
- When the user mentions making the app public or accessible outside the company network, remind them that IT must be consulted on security first
- When adding a dependency, state its license. If it is not on the allowed list, stop and explain why before adding it
- When the user provides or asks for an image, icon, font, sound, or video, ask where it comes from before adding it. If the source is not approved, suggest an alternative from an approved source
- **Always** package the user's entire chosen stack — the app plus every dependency it needs (database, cache, queue, etc.) — into a single root `docker-compose.yml`. This is mandatory and automatic on every project: do it as a standard part of scaffolding, never treat it as optional, and never wait for the user to request it or to opt in. Because the user may be non-technical, after generating the files explain in plain language which services were included and what each one does
- When asked to deploy, verify the pre-deploy checklist (no hardcoded secrets, all tests pass, dev/prod separation is in place) before writing deployment config
- When asked to commit, write the message for the user — do not leave it blank

---

*Knowledge base version: 1.3 — Last updated: 2026-10-19*
*Maintained by the SmartOSC AI Projects team.*
*Source repository: https://git02.smartosc.com/ai-projects/smartosc-vibe-coding-guide*
