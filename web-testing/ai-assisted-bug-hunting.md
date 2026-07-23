# AI-Assisted Bug Hunting: How I Use LLMs to Find Bugs 3x Faster

**The tools + prompts that cut my recon time from hours to minutes.**

---

Six months ago I was a purist. "Real hackers don't use AI," I told myself. Then I watched a colleague find an IDOR vulnerability in 12 minutes that had taken me 2 hours manually.

I tried his method the next day. Haven't looked back.

---

## What AI Actually Does Well (And What It Doesn't)

Let's kill the hype first.

**AI is terrible at:**
- Finding novel zero-days (no training data = no insight)
- Replacing your intuition (you still need to understand the bugs)
- Writing exploit chains end-to-end

**AI is excellent at:**
- Automating the boring 80% of recon
- Generating test payloads you forgot about
- Explaining unfamiliar codebases in seconds
- Spotting patterns in large datasets humans miss

**The sweet spot:** AI does the grunt work. You do the thinking.

---

## The AI-Assisted Workflow

### Step 1: Recon Triage (3 minutes instead of 30)

Feed your subdomain list to an LLM and ask it to prioritize:

```
You are a bug bounty reconnaissance analyst. I have 743 live subdomains.
Here are the first 50 with HTTP titles and status codes.

Prioritize by:
1. Likelihood of serious vulnerabilities
2. Unusual tech stacks
3. Forgotten/abandoned services (dev, staging, test, old, legacy)

Return the top 10 I should investigate first, with a one-line reason each.

[Paste subdomain list]
```

### Step 2: Code Understanding (20 minutes instead of 2 hours)

```
Analyze this JavaScript for security-relevant patterns:
1. API endpoints (fetch, axios, XMLHttpRequest)
2. Authentication tokens (JWT, bearer, session storage)
3. Hardcoded secrets (API keys, tokens)
4. Interesting endpoint paths (admin, internal, debug, graphql, v1)
5. Client-side validation that may not be enforced server-side

[Paste JS file]
```

### Step 3: Payload Generation (2 minutes instead of 20)

```
Generate 30 SSTI test payloads for parameter "search".
Target: Jinja2, Twig, Freemarker, Velocity, ERB.
Include expected behavior if vulnerable.
Also generate 10 polyglot payloads testing multiple frameworks.
Format as table for Burp Intruder.
```

### Step 4: Report Writing (10 minutes instead of 45)

```
I found an SSRF in target.com's profile image upload.
Write a vulnerability report with:
1. Executive summary (2-3 sentences)
2. Step-by-step reproduction
3. Impact assessment
4. Specific remediation
Under 500 words. No fluff.

[Paste Burp requests/notes]
```

---

## The Prompt Library

### Recon Prioritization

```
Target: {TARGET} | Live hosts: {COUNT}
Here are live subdomains with titles:
[Paste: cat live.txt | httpx -title -status-code]

Return top 15 to investigate, ranked by vuln potential.
Consider: login/auth pages, file uploads, APIs, admin panels, outdated services, dev/staging hosts.
```

### JS Analysis

```
Analyze this JavaScript for security findings:
1. API routes (internal, undocumented)
2. Secrets (keys, tokens, credentials)
3. Auth logic (client-side handling)
4. Input handling (user input reaching DOM)
Ignore: UI code, animations, analytics, CSS-in-JS.

[Paste JS]
```

### Parameter Fuzzing

```
Parameter "{PARAM}" at endpoint "{ENDPOINT}".
Generate 25 test values each for: XSS, SQLi, SSTI, Path Traversal, SSRF.
Format as JSON array for automation.
```

---

## AI Tools Comparison

| Tool | Best For | Cost | Verdict |
|------|----------|------|---------|
| **Claude** | Code analysis, reports, reasoning | Free tier | Best overall |
| **ChatGPT** | Payloads, quick lookups | Free tier | Good daily driver |
| **GitHub Copilot** | Automation scripts, extensions | $10/mo | Worth it |
| **Local LLMs** | Sensitive data, offline | Free | Slower but private |

**My daily stack:** Claude + ChatGPT + Copilot. $20/month total.

---

*Part of the [CipherOps Bug Bounty Notes](https://cipherops.gitbook.io/bug-bounty-notes/) — real techniques from real hunters.*

