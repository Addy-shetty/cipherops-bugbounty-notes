# The $8,000 subdomain: how recon finds what everyone else misses

I was stuck. Three months in, $850 total. Every report I filed was a duplicate.

The problem wasn't my exploit skills. It was that I was scanning the same targets as everyone else with the same tools. The money isn't in the obvious subdomains. It's in the ones nobody thinks to look for.

---

## What basic recon misses

Standard flow:

```bash
subfinder -d target.com | httpx | nuclei
```

This finds what certificate transparency logs already know about. The CVEs people have been scanning for since 2021.

What it skips:
- Dev servers decommissioned but never shut down
- Cloud resources created for a sprint in 2019, abandoned, still running
- Subdomains that don't appear in cert logs at all

The high-value bugs live here. Not on the main domain. On the thing someone built three years ago and forgot about.

---

## The stack

### Beyond cert transparency

```bash
subfinder -d target.com -o phase1_subs.txt
assetfinder --subs-only target.com >> phase1_subs.txt

# This is the part most people skip
gobuster dns -d target.com -w ~/wordlists/subdomains-top1m.txt \
  -t 100 -o phase1_brute.txt

cat phase1_subs.txt phase1_brute.txt | sort -u > all_subs.txt
```

Brute forcing subdomains is boring. It's also where the duplicate rate drops to near zero.

### Cloud resources

```bash
cloud_enum -k target -k target-backup -k target-dev \
  -k target-staging -k target-old -k target-legacy
```

This found me a forgotten S3 bucket named `target-backup-prod`. List permissions open. Inside: production database dumps from 2019. Customer PII. Valid credentials.

Four years. Nobody reported it. Nobody even looked.

### Unusual ports

```bash
naabu -l all_subs.txt -p 1-65535 -rate 1000 -o open_ports.txt
grep -v ":80\|:443\|:8080\|:8443" open_ports.txt > unusual_ports.txt
```

Everyone scans 80 and 443. Few scan 8443. Almost nobody scans all 65,535. The services on weird ports tend to be unmonitored and unpatched.

---

## The bug

That S3 bucket? $8,000. Tuesday 2:47 AM discovery, triaged by 9:30 AM, resolved Thursday.

---

## Tool breakdown

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
TARGET=$1
mkdir recon-$TARGET && cd recon-$TARGET

echo "[*] Standard enum"
subfinder -d $TARGET -o 1_subs.txt
assetfinder --subs-only $TARGET >> 1_subs.txt

echo "[*] Brute force (this is where the money is)"
gobuster dns -d $TARGET -w ~/wordlists/subdomains-small.txt -t 100 -o 2_brute.txt

echo "[*] Cloud resources"
cloud_enum -k $TARGET -k $TARGET-backup -k $TARGET-dev -k $TARGET-staging

echo "[*] Full port scan"
cat 1_subs.txt 2_brute.txt | sort -u | httpx -o 3_live.txt
naabu -l 3_live.txt -p 1-65535 -rate 1000 -o 4_ports.txt

echo "[+] Check 4_ports.txt for weird ports and cloud_enum for buckets"
```

---

## Related
- [I made $500 from my first bug](../getting-started/01-first-bug-72-hours.md) — start here
- [3 tools that find 80% of bugs](../tool-deep-dives/three-tools-find-bugs.md) — the pipeline
- [AI-assisted bug hunting](../web-testing/ai-assisted-bug-hunting.md) — automate the boring parts

*Part of [CipherOps Bug Bounty Notes](https://cipherops.gitbook.io/bug-bounty-notes/).*

