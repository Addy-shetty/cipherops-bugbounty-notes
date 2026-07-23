# How to Start Bug Bounty Hunting: I Made $500 From My First Bug (72-Hour Roadmap)

![72-Hour Bug Bounty Roadmap](../../images/getting-started/first-bug-72hr-roadmap.excalidraw)

*View: drag onto [excalidraw.com](https://excalidraw.com) | PNG: [first-bug-roadmap.png](../images/getting-started/first-bug-roadmap.png)*

---

**A step-by-step bug bounty beginner guide with copy-paste commands.**

*By CipherOps | Updated July 2026*

---

You don't need 50 tools. You don't need to "understand everything." You need 3 days and the willingness to look stupid.

I spent 6 hours on Day 1 and found absolutely nothing. By Day 3 I had $500 in my HackerOne account. The difference wasn't skill. It was picking one target and not stopping.

---

## Day 1: stop learning, start scanning

Most beginners do this backwards. Weeks of "learning" before ever opening a target.

Skip that. Pick one VDP on HackerOne. Run three commands:

```bash
subfinder -d target.com -o subs.txt
httpx -l subs.txt -o live.txt
nuclei -l live.txt -t exposures/ -o findings.txt
```

I didn't understand what nuclei did yet. Didn't matter. It found an exposed `.git` directory on a subdomain nobody else had checked. A P2 bug. Good enough.

I submitted it at 11:47 PM, sure it would be marked "informative" and ignored.

---

## Day 2: the bug that actually paid

Woke up to a triaged report. The program owner wrote back:

> "Nice find. Can you demonstrate impact by extracting credentials?"

Took me 30 minutes to figure out git-dumper. Another 15 to find an AWS access key in an `.env` file committed 8 months ago. Full S3 access. From a VDP with no bounty.

That report? Triaged to resolved in 48 hours. No money, but it taught me the pattern. Your second bug is 10x faster. Your fifth is automatic.

---

## Day 3: from free to paid program

Same process, different target. This time a paid program:

```bash
subfinder -d target.com | httpx | nuclei -t cves/ -o cves.txt
```

Found CVE-2021-41773 on a dev server someone forgot about. $500. Total active time: maybe 90 minutes. Most of that was writing the report.

---

## The bug bounty beginner's pattern

| Phase | Time | What |
|-------|------|------|
| Recon | 30 min | subfinder → httpx → nuclei |
| Verify | 45 min | Manual check, curl, browser |
| Report | 15 min | Screenshots, impact, repro steps |

Stuff that wastes your time:
- Installing 47 tools before running your first scan
- Reading every beginner guide on Medium
- Switching targets when you don't find something in 20 minutes
- Waiting until you "know enough"

Stuff that works:
- One target. Three days. Three tools.
- Submit even if you're not sure. Worst case: "informative"
- Repeat until it stops feeling scary

---

## Your first 72 hours as a bug bounty hunter

| Day | Goal | Action |
|-----|------|--------|
| 1 | Find anything | Run the 3-tool pipeline on one VDP |
| 2 | Verify one finding | Understand what your nuclei output means |
| 3 | Submit | Even if it's informative. Ship it |

---

## Related bug bounty guides
- [Advanced recon techniques: how I found an $8,000 subdomain](../reconnaissance/08k-subdomain-advanced-recon.md)
- [Best bug bounty tools: 3 tools that find 80% of vulnerabilities](../tool-deep-dives/three-tools-find-bugs.md)
- [AI bug bounty hunting: use LLMs to find bugs 3x faster](../web-testing/ai-assisted-bug-hunting.md)

*Part of [CipherOps Bug Bounty Notes](https://cipherops.gitbook.io/bug-bounty-notes/).*

