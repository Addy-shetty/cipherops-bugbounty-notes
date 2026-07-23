# AI-assisted bug hunting: how I find bugs 3x faster

I used to think "real hackers don't use AI." Then I watched a colleague find an IDOR in 12 minutes that took me 2 hours manually.

I tried his method the next day. Haven't gone back.

---

## What AI is actually good at

Let's be honest about what these things do and don't do.

Things AI is bad at: finding novel zero-days, replacing your intuition, writing end-to-end exploit chains.

Things AI is good at: the boring 80% of recon. Generating payloads you forgot existed. Explaining unfamiliar code in seconds. Spotting patterns across 700 subdomains that a human would glaze over.

The sweet spot: AI does the grunt work. You show up for the parts that need a brain.

---

## The workflow

### Recon triage (3 minutes instead of 30)

Give an LLM your subdomain list. Ask it to prioritize:

```
I have 743 live subdomains from target.com. Here are the first 50
with HTTP titles and status codes.

Prioritize by likelihood of serious vulns: auth portals, admin panels,
API endpoints, file uploads, unusual tech stacks, dev/staging/test hosts.

Return the top 10 I should check first with a one-line reason each.

[paste subdomain list]
```

The top 3 results from this exact prompt pointed me at a Keycloak instance running a 4-year-old version. Known CVEs. Triaged in 2 hours.

### Code review (20 minutes instead of 2 hours)

You find an 8,000 line minified JS file. Instead of reading it line by line:

```
Analyze this JavaScript for security findings:
1. API endpoints (fetch, axios, XMLHttpRequest)
2. Auth tokens (JWT, bearer, session storage)
3. Hardcoded values that look like keys or secrets
4. Internal paths (admin, debug, graphql, v1, internal)
5. Client-side validation that might not exist server-side

Ignore UI code, animation libs, analytics.

[paste JS]
```

This surfaced an endpoint `/api/internal/users/bulk-import` with no auth check. $2,500.

### Payload generation (2 minutes instead of 20)

```
I found parameter "search" on an endpoint. Generate 30 SSTI test
payloads for Jinja2, Twig, Freemarker, Velocity, ERB. Include
expected behavior if vulnerable. Add 10 polyglot payloads that
test multiple frameworks.

Format as a table for Burp Intruder.
```

### Report writing (10 minutes instead of 45)

```
I found SSRF in target.com's profile image upload. Write a report:
1. Executive summary (2-3 sentences)
2. Step-by-step reproduction
3. Impact assessment
4. Specific fix recommendation
Under 500 words. No fluff.

[paste Burp requests/responses and notes]
```

---

## The prompt library

### Recon triage prompt

```
Target: {TARGET} | Live hosts: {COUNT}
[Paste: cat live.txt | httpx -title -status-code]

Return top 15 to investigate. Consider: login pages, file uploads,
APIs, admin panels, outdated services, dev/staging/test hosts.
```

### JS analysis prompt

```
Analyze this JS for: API routes, secrets, auth logic, input handling.
Ignore UI code, animations, analytics.

[paste JS]
```

### Parameter fuzzing prompt

```
Parameter "{PARAM}" at "{ENDPOINT}". Generate 25 values each for
XSS, SQLi, SSTI, path traversal, SSRF. JSON array for automation.
```

---

## Tools comparison

| Tool | Best for | Cost | |
|------|----------|------|---|
| Claude | Code analysis, reasoning | Free tier | Best all-round |
| ChatGPT | Payloads, quick lookups | Free tier | Good daily |
| Copilot | Automation scripts | $10/mo | Worth it |
| Local (Ollama) | Sensitive data, offline | Free | Slower |

My stack: Claude + ChatGPT + Copilot. $20/month.

---

None of this is magic. It doesn't replace knowing what you're doing. What it replaces is the 45 minutes of manually scanning a JS file for API routes at 1 AM when your eyes are blurring.

That's the real multiplier. Not doing things faster. Not burning out on the boring parts.

---

## Related
- [3 tools that find 80% of bugs](../tool-deep-dives/three-tools-find-bugs.md) — the foundation
- [The $8,000 subdomain](../reconnaissance/08k-subdomain-advanced-recon.md) — recon that pays
- [I made $500 from my first bug](../getting-started/01-first-bug-72-hours.md) — start here

*Part of [CipherOps Bug Bounty Notes](https://cipherops.gitbook.io/bug-bounty-notes/).*

