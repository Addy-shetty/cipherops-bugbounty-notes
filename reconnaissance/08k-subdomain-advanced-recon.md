# The $8,000 Subdomain: How Advanced Recon Finds What Others Miss

**Most hunters run subfinder and stop. Here's what happens when you don't.**

---

I was stuck at $850 total earnings after 3 months. Decent, but not enough to quit my day job. Every report I submitted was a duplicate — someone had already found the bug before me.

The problem wasn't my hacking skills. It was my recon.

Everyone else was scanning the same subdomains. Running the same tools. Finding the same bugs. I was competing in a crowded room when there was an empty room next door.

Here's how I found it.

---

## The Problem With Basic Recon

Standard recon flow that 90% of hunters use:

```bash
subfinder -d target.com | httpx | nuclei
```

This finds the obvious stuff. The subdomains everyone already knows about. The CVEs everyone already scanned for.

**What it misses:**
- Forgotten dev/staging servers
- Old cloud instances still running
- Subdomains not in certificate transparency logs
- Internal services accidentally exposed

These are where the money lives.

---

## The Advanced Recon Stack

Here's the flow that found me an $8,000 bug. Every command is copy-paste ready.

### Phase 1: Beyond Certificate Transparency

```bash
# Standard subdomain enum (everyone does this)
subfinder -d target.com -o phase1_subs.txt
assetfinder --subs-only target.com >> phase1_subs.txt

# What most people skip: brute-force common patterns
gobuster dns -d target.com -w ~/wordlists/subdomains-top1m.txt \
  -t 100 -o phase1_brute.txt

# Combine and deduplicate
cat phase1_subs.txt phase1_brute.txt | sort -u > all_subs.txt
```

### Phase 2: The Forgotten Servers

```bash
# Find subdomains resolving to internal/non-standard IPs
cat all_subs.txt | dnsx -resp -a -aaaa -cname | \
  grep -v "cloudflare\|aws\|azure" > interesting_dns.txt

# Check historical DNS — what USED to point here?
cat all_subs.txt | while read sub; do
  curl -s "https://dnsarchive.net/api/v1/$sub" | jq -r '.records[]?.value'
done > historical_ips.txt
```

### Phase 3: The Forgotten Cloud

```bash
# Find cloud buckets named after the company
cloud_enum -k target -k target-backup -k target-dev \
  -k target-staging -k target-old -k target-legacy

# Check for abandoned cloudfront distributions
aws cloudfront list-distributions --query \
  "Items[?contains(Aliases.Items[0],'target')].DomainName"
```

### Phase 4: The Forgotten Ports

```bash
# Most people scan port 80 and 443. That's it.
naabu -l all_subs.txt -p 1-65535 -rate 1000 -o open_ports.txt

# Filter for unusual ports
grep -v ":80\|:443\|:8080\|:8443" open_ports.txt > unusual_ports.txt
```

---

## The Bug

Phase 3 found it. A forgotten S3 bucket named `target-backup-prod` with list permissions enabled. Inside: database dumps from 2019. Production credentials. Customer PII.

The bucket had been there for 4 years. Nobody had ever reported it. Because nobody ran `cloud_enum`.

**Timeline:**
- Discovery: Tuesday, 02:47 AM
- Report submitted: Tuesday, 03:12 AM
- Triaged: Tuesday, 09:30 AM
- **Bounty paid: $8,000**

---

## Recon Tool Comparison

| Tool | What It Finds | Everyone Uses It? | Unique Value |
|------|--------------|-------------------|--------------|
| **subfinder** | Known subdomains (cert logs) | Yes | Fast baseline |
| **assetfinder** | Known subdomains (multiple sources) | Yes | Second opinion |
| **gobuster dns** | Unknown subdomains (brute force) | Few do | Finds what certs miss |
| **cloud_enum** | Cloud buckets + resources | Almost nobody | Highest $ per finding |
| **dnsx** | DNS records + resolution | Sometimes | Identifies non-standard infra |
| **naabu** | Open ports (all 65535) | Almost nobody | Finds unmonitored services |

---

## Copy-Paste: Your Advanced Recon Script

```bash
#!/bin/bash
# advanced-recon.sh — Drop this on any target
TARGET=$1
mkdir recon-$TARGET && cd recon-$TARGET

echo "[*] Phase 1: Standard enum"
subfinder -d $TARGET -o 1_subs.txt
assetfinder --subs-only $TARGET >> 1_subs.txt

echo "[*] Phase 2: Brute force"
gobuster dns -d $TARGET -w ~/wordlists/subdomains-small.txt -t 100 -o 2_brute.txt

echo "[*] Phase 3: Cloud resources"
cloud_enum -k $TARGET -k $TARGET-backup -k $TARGET-dev -k $TARGET-staging -k $TARGET-old

echo "[*] Phase 4: Full port scan"
cat 1_subs.txt 2_brute.txt | sort -u | httpx -o 3_live.txt
naabu -l 3_live.txt -p 1-65535 -rate 1000 -o 4_ports.txt

echo "[+] Done. Check 4_ports.txt for unusual ports."
echo "[+] Check cloud_enum output for exposed buckets."
```

---

*Part of the [CipherOps Bug Bounty Notes](https://cipherops.gitbook.io/bug-bounty-notes/) — real techniques from real hunters.*

