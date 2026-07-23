# 3 Tools That Find 80% of Bugs (And How to Use Them Like a Pro)

**Stop installing 50 tools. Master these 3.**

---

Every "bug bounty tools" article is the same: 47 tools, 12 categories, infinite GitHub stars. You bookmark it. You install 8 of them. You use 2. You forget the rest.

Here's the truth: **3 tools find 80% of beginner-to-intermediate bugs.** Master these first.

---

## Tool #1: Nuclei — Your Vulnerability Scanner

**What it does:** Automatically tests for thousands of known vulnerabilities using pre-built templates.

### Level 1: Beginner

```bash
# Scan one target
nuclei -u https://target.com -o results.txt

# Scan a list of live hosts
nuclei -l live-hosts.txt -o results.txt
```

### Level 2: Intermediate

```bash
# CVEs only (highest signal)
nuclei -l live.txt -t cves/ -o cves.txt

# Exposed panels (admin, dev tools, debug)
nuclei -l live.txt -t exposures/ -o exposures.txt

# Misconfigurations
nuclei -l live.txt -t misconfiguration/ -o misconfig.txt

# Default credentials
nuclei -l live.txt -t default-logins/ -o logins.txt
```

### Level 3: Pro

```bash
# Custom template
cat > custom-check.yaml << 'EOF'
id: my-check
info:
  name: Check Internal API
  severity: medium
requests:
  - method: GET
    path:
      - "{{BaseURL}}/api/internal/users"
    matchers:
      - type: status
        status:
          - 200
EOF

nuclei -l live.txt -t custom-check.yaml

# Rate limited + authenticated
nuclei -l live.txt -t cves/ -rl 50 -bs 10 -c 10 -H 'Cookie: session=xxx'
```

---

## Tool #2: ffuf — Your Fuzzing Swiss Army Knife

**What it does:** Brute-forces anything. Directories, parameters, subdomains, virtual hosts — if it takes a wordlist, ffuf does it.

### Level 1: Beginner

```bash
# Directory fuzzing
ffuf -u https://target.com/FUZZ -w ~/wordlists/common.txt

# File extension fuzzing
ffuf -u https://target.com/index.FUZZ -w ~/wordlists/extensions.txt
```

### Level 2: Intermediate

```bash
# Parameter discovery (GET)
ffuf -u 'https://target.com/page?FUZZ=test' -w ~/wordlists/params.txt -fs 4242

# Parameter discovery (POST)
ffuf -u 'https://target.com/api/login' -X POST -d '{"FUZZ":"test"}' \
  -w ~/wordlists/params.txt -fc 401

# Virtual host discovery
ffuf -u https://target.com -H 'Host: FUZZ.target.com' \
  -w ~/wordlists/vhosts.txt -fs 6122
```

### Level 3: Pro

```bash
# Multi-stage: find params, then fuzz values
ffuf -u 'https://target.com/api/user?FUZZ=1' -w params.txt -fc 400,404 -o found.json
ffuf -u 'https://target.com/api/user?id=FUZZ' -w sqli.txt -fc 400

# Rate limited, stealthy
ffuf -u https://target.com/FUZZ -w wordlist.txt -p 0.5 -t 5
```

---

## Tool #3: katana — Your Spider on Steroids

**What it does:** Crawls websites like a search engine. Finds every endpoint, form, and parameter.

### Level 1: Beginner

```bash
# Basic crawl
katana -u https://target.com -o urls.txt

# Crawl with depth
katana -u https://target.com -d 5 -o urls.txt
```

### Level 2: Intermediate

```bash
# Crawl + JS parsing (finds hidden endpoints)
katana -u https://target.com -jc -o urls.txt

# Extract only URLs with parameters
katana -u https://target.com -d 3 | grep "?" | sort -u > params.txt

# Crawl + live check pipeline
katana -u https://target.com -d 3 -silent | httpx -o live-crawled.txt
```

### Level 3: Pro

```bash
# Full pipeline
echo https://target.com | katana -d 5 -jc -kf all -c 50 \
  -silent | grep "?" | uro | sort -u > all_params.txt

# Crawl → nuclei
katana -u https://target.com -d 4 -jc -silent \
  | httpx -silent | nuclei -t cves/

# Crawl JS → extract secrets
katana -u https://target.com -d 3 -jc -silent \
  -em js | while read url; do
    curl -s "$url" | grep -E "(api[_-]?key|secret|token|password)"
  done
```

---

## The Complete Pipeline

```bash
#!/bin/bash
# quick-hunt.sh target.com — full pass in 15 minutes
TARGET=$1

echo "[1/4] Finding subdomains..."
subfinder -d $TARGET | httpx -silent > live.txt

echo "[2/4] Crawling for endpoints..."
cat live.txt | katana -d 3 -jc -silent | grep "?" | sort -u > endpoints.txt

echo "[3/4] Scanning for CVEs..."
nuclei -l live.txt -t cves/ -silent > cve-results.txt

echo "[4/4] Fuzzing endpoints..."
cat endpoints.txt | while read url; do
  ffuf -u "$url" -w ~/wordlists/sqli-small.txt -fc 404 -silent
done > fuzz-results.txt

echo "[+] Done. Check cve-results.txt and fuzz-results.txt"
```

---

## Tool Comparison

| Tool | Finds | Time to Learn | Priority |
|------|-------|---------------|----------|
| **Nuclei** | Known vulns, CVEs, misconfigs | 1 hour | Learn first |
| **ffuf** | Unknown endpoints, hidden content | 2 hours | Learn second |
| **katana** | Every endpoint, JS-hidden routes | 30 min | Learn second |
| Everything else | Optimization | Varies | Learn as needed |

---

*Part of the [CipherOps Bug Bounty Notes](https://cipherops.gitbook.io/bug-bounty-notes/) — real techniques from real hunters.*

