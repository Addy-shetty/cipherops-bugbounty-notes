# 3 tools that find 80% of bugs

Every tools article is the same: 47 tools, 12 categories, infinite stars. You bookmark it, install 8, use 2, forget the rest.

You need 3. Master these and you have 80% of what most bug bounty hunters use day to day.

---

## Nuclei

Automated vulnerability scanning. Pre-built templates for CVEs, misconfigurations, exposed panels, default credentials.

### Beginner

```bash
nuclei -u https://target.com -o results.txt
nuclei -l live-hosts.txt -o results.txt
```

### Intermediate

```bash
nuclei -l live.txt -t cves/ -o cves.txt
nuclei -l live.txt -t exposures/ -o exposures.txt
nuclei -l live.txt -t misconfiguration/ -o misconfig.txt
nuclei -l live.txt -t default-logins/ -o logins.txt
```

### Pro

```bash
nuclei -l live.txt -t cves/ -rl 50 -bs 10 -c 10 \
  -H 'Cookie: session=xxx'

# Custom template for one-off checks
cat > check.yaml << 'EOF'
id: internal-api
info:
  name: Check internal API
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
nuclei -l live.txt -t check.yaml
```

---

## ffuf

Brute-forces anything. Directories, parameters, subdomains, POST bodies. If it takes a wordlist, ffuf does it.

### Beginner

```bash
ffuf -u https://target.com/FUZZ -w ~/wordlists/common.txt
ffuf -u https://target.com/index.FUZZ -w ~/wordlists/extensions.txt
```

### Intermediate

```bash
ffuf -u 'https://target.com/page?FUZZ=test' \
  -w ~/wordlists/params.txt -fs 4242

ffuf -u 'https://target.com/api/login' -X POST \
  -d '{"FUZZ":"test"}' -w ~/wordlists/params.txt -fc 401

ffuf -u https://target.com \
  -H 'Host: FUZZ.target.com' -w ~/wordlists/vhosts.txt -fs 6122
```

### Pro

```bash
# Find params, then fuzz values
ffuf -u 'https://target.com/api/user?FUZZ=1' \
  -w params.txt -fc 400,404 -o found.json
ffuf -u 'https://target.com/api/user?id=FUZZ' \
  -w sqli.txt -fc 400

# Stealthy
ffuf -u https://target.com/FUZZ -w wordlist.txt -p 0.5 -t 5
```

---

## katana

Crawls like a search engine. Finds endpoints, forms, and parameters hidden behind JavaScript.

### Beginner

```bash
katana -u https://target.com -o urls.txt
katana -u https://target.com -d 5 -o urls.txt
```

### Intermediate

```bash
katana -u https://target.com -jc -o urls.txt
katana -u https://target.com -d 3 | grep "?" | sort -u > params.txt
katana -u https://target.com -d 3 -silent | httpx -o live-crawled.txt
```

### Pro

```bash
echo https://target.com | katana -d 5 -jc -kf all -c 50 \
  -silent | grep "?" | uro | sort -u > all_params.txt

# Crawl JS files, grep for secrets
katana -u https://target.com -d 3 -jc -silent \
  -em js | while read url; do
    curl -s "$url" | grep -E "(api[_-]?key|secret|token|password)"
  done
```

---

## The full pipeline

```bash
#!/bin/bash
TARGET=$1

echo "[1/4] Subdomains..."
subfinder -d $TARGET | httpx -silent > live.txt

echo "[2/4] Crawling..."
cat live.txt | katana -d 3 -jc -silent | grep "?" | sort -u > endpoints.txt

echo "[3/4] CVEs..."
nuclei -l live.txt -t cves/ -silent > cve-results.txt

echo "[4/4] Fuzzing..."
cat endpoints.txt | while read url; do
  ffuf -u "$url" -w sqli-small.txt -fc 404 -silent
done > fuzz-results.txt
```

---

## Comparison

| Tool | Finds | Learn time | Priority |
|------|-------|-----------|----------|
| Nuclei | Known vulns, CVEs | 1 hour | First |
| ffuf | Hidden endpoints, params | 2 hours | Second |
| katana | JS-hidden routes | 30 min | Second |
| Others | Optimization | Varies | Later |

When you want to install a new tool, ask: "Can one of these 3 already do this?" The answer is yes more often than you'd think.

---

## Related
- [I made $500 from my first bug](../getting-started/01-first-bug-72-hours.md) — see the pipeline in action
- [The $8,000 subdomain](../reconnaissance/08k-subdomain-advanced-recon.md) — recon techniques
- [AI-assisted bug hunting](../web-testing/ai-assisted-bug-hunting.md) — add AI to this stack

*Part of [CipherOps Bug Bounty Notes](https://cipherops.gitbook.io/bug-bounty-notes/).*

