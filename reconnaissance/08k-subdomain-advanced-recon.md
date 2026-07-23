# Advanced Subdomain Enumeration: The $8,000 Bug Bounty Recon Technique

![Advanced Recon Pipeline](../../images/reconnaissance/advanced-recon-pipeline.excalidraw)

*View: drag onto [excalidraw.com](https://excalidraw.com) | PNG: [recon-mindmap.png](../images/reconnaissance/recon-mindmap.png)*

---

**Most hunters run subfinder and stop. Here's how advanced recon finds what others miss — with copy-paste commands.**

*By CipherOps | Updated July 2026*

---

I was stuck. Three months in, $850 total. Every report I filed was a duplicate.

The problem wasn't my exploit skills. It was that I was scanning the same targets as everyone else with the same tools. The high-value bugs aren't on the main domain. They're on forgotten infrastructure.

---

## What basic subdomain enumeration misses

Standard flow:

```bash
subfinder -d target.com | httpx | nuclei
```

This finds what certificate transparency logs already know about. The CVEs people have been scanning for since 2021.

What it skips:
- Dev servers decommissioned but never shut down
- Cloud resources created for a sprint in 2019, abandoned, still running
- Subdomains that don't appear in cert logs at all

These are where the $8,000 bugs live.

---

## Advanced recon: the full stack

### Phase 1: Beyond certificate transparency

```bash
subfinder -d target.com -o phase1_subs.txt
assetfinder --subs-only target.com >> phase1_subs.txt

# This is the part most people skip
gobuster dns -d target.com -w ~/wordlists/subdomains-top1m.txt \
  -t 100 -o phase1_brute.txt

cat phase1_subs.txt phase1_brute.txt | sort -u > all_subs.txt
```

### Phase 2: Cloud enumeration

```bash
cloud_enum -k target -k target-backup -k target-dev \
  -k target-staging -k target-old -k target-legacy
```

This found me a forgotten S3 bucket named `target-backup-prod`. List permissions open. Inside: production database dumps from 2019. Customer PII. Valid credentials.

Four years. Nobody reported it. Nobody even looked.

### Phase 3: Full port scanning

```bash
naabu -l all_subs.txt -p 1-65535 -rate 1000 -o open_ports.txt
grep -v ":80\|:443\|:8080\|:8443" open_ports.txt > unusual_ports.txt
```

Everyone scans 80 and 443. Almost nobody scans all 65,535. The services on weird ports tend to be unmonitored and unpatched.

---

## The bug bounty payout

That S3 bucket? $8,000. Tuesday 2:47 AM discovery, triaged by 9:30 AM, resolved Thursday.

---

## Recon tool comparison

| Tool | What it finds | Who uses it | Real value |
|------|--------------|-------------|------------|
| subfinder | Cert log subdomains | Everyone | Baseline |
| gobuster dns | Brute-forced subdomains | Almost nobody | Finds what certs miss |
| cloud_enum | Buckets, cloud resources | Almost nobody | Highest $ per finding |
| naabu (full) | All 65,535 ports | Almost nobody | Unmonitored services |

The pattern is not subtle. Tools in the "everyone" column find the $500 bugs. The "almost nobody" column finds the $8,000 ones.

---

## Copy-paste recon script

```bash
#!/bin/bash
# advanced-recon.sh — Full recon pipeline for bug bounty
TARGET=$1
mkdir recon-$TARGET && cd recon-$TARGET

echo "[*] Standard subdomain enumeration"
subfinder -d $TARGET -o 1_subs.txt
assetfinder --subs-only $TARGET >> 1_subs.txt

echo "[*] DNS brute force (this is where the hidden subdomains are)"
gobuster dns -d $TARGET -w ~/wordlists/subdomains-small.txt -t 100 -o 2_brute.txt

echo "[*] Cloud resource enumeration"
cloud_enum -k $TARGET -k $TARGET-backup -k $TARGET-dev -k $TARGET-staging

echo "[*] Full port scan"
cat 1_subs.txt 2_brute.txt | sort -u | httpx -o 3_live.txt
naabu -l 3_live.txt -p 1-65535 -rate 1000 -o 4_ports.txt

echo "[+] Done. Check 4_ports.txt for unusual ports and cloud_enum for exposed buckets"
```

---

## Related bug bounty recon guides
- [How to start bug bounty: $500 from my first bug in 72 hours](../getting-started/01-first-bug-72-hours.md)
- [Best bug bounty tools: 3 tools that find 80% of bugs](../tool-deep-dives/three-tools-find-bugs.md)
- [AI bug bounty workflow: automate recon with LLMs](../web-testing/ai-assisted-bug-hunting.md)

*Part of [CipherOps Bug Bounty Notes](https://cipherops.gitbook.io/bug-bounty-notes/).*

