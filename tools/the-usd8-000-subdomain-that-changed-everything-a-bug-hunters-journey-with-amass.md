---
icon: map-location-dot
cover: >-
  https://images.unsplash.com/photo-1473625247510-8ceb1760943f?crop=entropy&cs=srgb&fm=jpg&ixid=M3wxOTcwMjR8MHwxfHNlYXJjaHw1fHxqb3VybmV5fGVufDB8fHx8MTc3MzcyODY1Mnww&ixlib=rb-4.1.0&q=85
coverY: -526.1705551086083
---

# The Amass Complete Guide

Amass is a comprehensive subdomain enumeration and attack-surface mapping tool. Where single-source tools typically find a fraction of a target's subdomains, Amass pulls from 80+ data sources and adds active brute-forcing and intelligent permutations — which is how forgotten hosts like `backup.` or `legacy-api.` surface, the kind that often hold the most impactful bugs. This guide covers installation through an automated recon pipeline.

***

### Why Amass finds more

Most subdomain tools query a handful of passive sources and stop. Amass combines passive enumeration across many more sources with optional active brute-forcing and permutation generation, so it reconstructs subdomains that aren't recorded anywhere — `api-v2-staging`, `dev-old`, `migration-2023` and similar. On a typical target that difference is often 3–4x more subdomains than a passive-only tool, and the extra hosts are disproportionately the untested ones.

***

### Installation

```bash
# Snap
sudo snap install amass

# Verify
amass -version
```

***

### Week 1: the basics

**Passive enumeration** — no DNS queries to the target, fully stealthy:

```bash
amass enum -d target.com -passive -o passive-results.txt
```

This checks certificate transparency logs, DNS databases, and search engines across 80+ sources without ever touching the target's own DNS.

**Active enumeration** — DNS brute-forcing finds hosts passive sources miss:

```bash
amass enum -d target.com \
    -brute \
    -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-110000.txt \
    -o brute-results.txt
```

The wordlist matters more than its size — a well-chosen list beats a huge generic one.

**API integration** — free API keys raise results by roughly 30–40%:

```yaml
# ~/.config/amass/config.yaml
data_sources:
  - name: VirusTotal
    creds:
      apikey: YOUR_API_KEY
  - name: Shodan
    creds:
      apikey: YOUR_API_KEY
  - name: Censys
    creds:
      apikey: YOUR_API_ID
      secret: YOUR_API_SECRET
```

***

### Week 2: advanced techniques

**Permutation attacks** find the convoluted names organizations actually create (`api-dev`, `dev-api`, `api2`, `api-v2`):

```bash
amass enum -d target.com \
    -brute \
    -w /usr/share/seclists/Discovery/DNS/dns-Jhaddix.txt \
    -o permutations.txt
```

**Continuous monitoring** catches subdomains that appear after your first scan:

```bash
# Establish a baseline
amass track -d target.com -dir ./amass-tracking

# Check weekly for what's new
amass track -d target.com -last 7 -dir ./amass-tracking
```

***

### Week 3: the full pipeline

Tools work better chained. This script runs passive and active enumeration, finds live hosts, scans ports, and screenshots everything:

```bash
#!/bin/bash
# ultimate-recon.sh
TARGET=$1
OUTPUT_DIR="recon-$TARGET-$(date +%Y%m%d)"
mkdir -p $OUTPUT_DIR

echo "[+] Passive enumeration..."
amass enum -d $TARGET -passive -o $OUTPUT_DIR/passive.txt

echo "[+] Active brute-forcing..."
amass enum -d $TARGET -brute -w wordlist.txt -o $OUTPUT_DIR/brute.txt

echo "[+] Probing for live hosts..."
cat $OUTPUT_DIR/passive.txt $OUTPUT_DIR/brute.txt | sort -u | \
  httpx -o $OUTPUT_DIR/live.txt

echo "[+] Port scanning..."
naabu -list $OUTPUT_DIR/live.txt -p 80,443,8080,8443 -o $OUTPUT_DIR/ports.txt

echo "[+] Screenshotting..."
cat $OUTPUT_DIR/live.txt | aquatone -out $OUTPUT_DIR/screenshots

echo "[+] Done. Results in $OUTPUT_DIR/"
```

The flow is: **Amass → httpx → naabu → aquatone**, which produces a complete, visual map of the attack surface.

***

### Pro tips

**Combine multiple wordlists** for broader coverage:

```bash
amass enum -d target.com -brute \
  -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-110000.txt \
  -w /usr/share/seclists/Discovery/DNS/dns-Jhaddix.txt \
  -o comprehensive.txt
```

**Visualize the attack surface:**

```bash
amass viz -d target.com -o attack-surface.html
```

**Filter for the interesting hosts:**

```bash
cat domains.txt | grep -E 'admin|api|dev|staging|backup|internal|test'
```

***

### How Amass compares

| Feature       | Amass  | Subfinder | Assetfinder |
| ------------- | ------ | --------- | ----------- |
| Data sources  | 80+    | 50+       | 10+         |
| Passive       | Yes    | Yes       | Yes         |
| Active brute  | Yes    | No        | No          |
| Permutations  | Yes    | No        | No          |
| Visualization | Yes    | No        | No          |
| Monitoring    | Yes    | No        | No          |
| Speed         | Medium | Fast      | Very fast   |

Use Amass for thorough, comprehensive reconnaissance; use Subfinder or Assetfinder for quick checks. When coverage matters, Amass finds what the others miss.

***

### Resources

* [Amass on GitHub](https://github.com/OWASP/Amass)
* [Installation guide](https://github.com/OWASP/Amass/blob/master/doc/install.md)
* [User guide](https://github.com/OWASP/Amass/blob/master/doc/user_guide.md)

**Free API tiers worth adding:** [VirusTotal](https://www.virustotal.com), [Shodan](https://www.shodan.io), [Censys](https://search.censys.io), and [Chaos](https://chaos.projectdiscovery.io) (free for researchers).

**Wordlists:** [SecLists](https://github.com/danielmiessler/SecLists) and [Assetnote](https://wordlists-cdn.assetnote.io).

**Related on this site:**

* [Setting Up Your First Bug Bounty Lab](../getting-started/how-to-guide-setting-up-your-first-bug-bounty-lab.md)
* [Nuclei — the vulnerability scanner](nuclei-the-vulnerability-scanner-that-changed-bug-bounty.md)
* [Best Recon Technique for Active Subdomain Enumeration](../recon-tips/best-recon-technique-for-active-subdomain-enumeration.md)

_Questions? Join the_ [_Telegram community_](https://t.me/bugbounty_tech)_._
