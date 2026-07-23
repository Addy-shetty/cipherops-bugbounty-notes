# I Made $500 From My First Bug. Here's Exactly How You Can Too.

**A 72-hour roadmap from zero to first bounty.**

---

I stared at my screen for 6 hours on Day 1 and found nothing. Not a single vulnerability. I had watched every YouTube tutorial, read every "beginner's guide," and still couldn't find a bug to save my life.

By Day 3, I had $500 in my HackerOne account.

Here's exactly what changed — no theory, just what actually worked.

---

## Day 1: Stop Learning. Start Hunting.

Most beginners do this backwards. They spend weeks "learning" before ever opening a target. Wrong move.

**What I did instead:**

```bash
# Step 1: Pick ONE target. Not ten. One.
# I chose a VDP (no bounty) program on HackerOne with a wide scope.

# Step 2: Run exactly these 3 tools. No more.
subfinder -d target.com -o subs.txt
httpx -l subs.txt -o live.txt
nuclei -l live.txt -t exposures/ -o findings.txt
```

That's it. Three commands. I didn't understand what any of them did yet — I just ran them.

**The mistake I almost made:** Installing 50 tools before starting. You need 3. Maybe 5. Everything else is procrastination dressed as preparation.

**Nuclei found an exposed .git directory.** I didn't know what that meant. I googled it. Turns out you can download the entire source code history of a web app from an exposed .git folder. That's a P2 bug on most programs.

I submitted it at 11:47 PM. Went to bed convinced it would be marked "informative."

---

## Day 2: The Bug That Changed Everything

I woke up to a triaged report. Not "informative." **Triaged.** The program owner had replied:

> "Nice find. Can you demonstrate impact by extracting any credentials?"

So I learned `git-dumper` in 30 minutes:

```bash
# Extract the entire repo from exposed .git
git-dumper https://target.com/.git/ ./leaked-repo/

# Search for secrets
cd leaked-repo
grep -r "password\|api_key\|secret\|token" --include="*.{py,js,yml,env,json}" .
```

Found an AWS access key in a `.env` file that someone committed 8 months ago. Valid. Full S3 bucket access.

That $0 VDP report? Triaged → Resolved in 48 hours.

**The real lesson:** Your first bug teaches you the pattern. The second one is 10x faster. The fifth one is automatic.

---

## Day 3: From VDP to Paid Program

Armed with one resolved report and a pattern that worked, I moved to a paid program.

Same process:

```bash
# Recon — 30 minutes
subfinder -d target.com | httpx | nuclei -t cves/ -o cves.txt

# Manual check — 45 minutes
# Pick the interesting findings and verify by hand

# Submit — 15 minutes
# Screenshots, impact statement, steps to reproduce
```

Found a CVE-2021-41773 (Apache path traversal) on a forgotten dev server. $500 bounty. Total time: ~90 minutes.

---

## The Pattern That Actually Works

| Phase | Time | Tools |
|-------|------|-------|
| **Recon** | 30 min | subfinder → httpx → nuclei |
| **Verify** | 45 min | Manual testing, curl, browser |
| **Report** | 15 min | Screenshots, impact, repro steps |

**Stop doing this:**
- Reading 50 blog posts before starting
- Installing every tool in the Awesome-Hacking list
- Waiting until you "understand everything"
- Switching targets every 20 minutes

**Start doing this:**
- Pick one target. Stick with it for 3 days.
- Run 3 tools. Learn what they found.
- Submit even if you're not sure. Worst case: "informative."
- Repeat. Speed comes from reps, not research.

---

## Your First 72 Hours

| Day | Goal | Action |
|-----|------|--------|
| **Day 1** | Find anything | Run subfinder + httpx + nuclei on one VDP |
| **Day 2** | Verify one finding | Learn what your nuclei output actually means |
| **Day 3** | Submit a report | Even if it's "informative." Ship it. |

---

*Part of the [CipherOps Bug Bounty Notes](https://cipherops.gitbook.io/bug-bounty-notes/) — real techniques from real hunters.*

