---
icon: '1'
coverY: 0
---

# AI-Powered Reconnaissance: The Complete 2026 Guide



{% tabs %}
{% tab title="Context" %}
**Skill Level:** Beginner to Advanced\
**Time to Complete:** 30 minutes\
**Tools Needed:** Terminal, Git, Python3, OpenAI API (optional)\
**Last Updated:** 2026-02-26
{% endtab %}
{% endtabs %}

***

### 📊 Visual Overview

&#x20;_Infographic: The 4-Phase AI-Powered Recon Workflow_

**Quick Navigation:**

* Phase 1: Target Discovery - 5 min
* Phase 2: Subdomain Enumeration - 10 min
* Phase 3: Service Detection - 10 min
* Phase 4: Content Discovery - 5 min
* AI Automation Pipeline - Bonus

***

### 🎯 What You'll Learn

By the end of this guide, you'll be able to:

* ✅ Find hidden subdomains using AI-enhanced wordlists
* ✅ Detect services and technologies automatically
* ✅ Discover API endpoints and sensitive files
* ✅ Build a complete recon automation pipeline
* ✅ Use LLMs to analyze and prioritize findings

***

### Prerequisites

Before starting, ensure you have:

```bash
# Install required tools
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
go install -v github.com/projectdiscovery/naabu/v2/cmd/naabu@latest
go install -v github.com/ffuf/ffuf@latest

# Python for AI integration
pip3 install openai requests beautifulsoup4

# Create workspace
mkdir -p ~/bugbounty/recon && cd ~/bugbounty/recon
```

***

### Phase 1: Target Discovery

#### 🔍 What We're Doing

Gathering information about the target from public sources before active scanning.

#### 📋 Copy-Paste Commands

**1.1 Find ASN and IP Ranges**

```bash
# Install asnmap
go install -v github.com/projectdiscovery/asnmap/cmd/asnmap@latest

# Get ASN by organization name
asnmap -org "Facebook" -silent

# Get IP ranges for domain
asnmap -d "facebook.com" -silent

# Output to file
asnmap -org "Target Inc" -silent -o target_asn.txt
```

**Expected Output:**

```
AS32934
31.13.64.0/18
157.240.0.0/16
...
```

**1.2 WHOIS and DNS History**

```bash
# Historical DNS records
curl -s "https://dns.history.api/example.com" | jq

# Reverse WHOIS
whois -h whois.radb.net "!gAS32934" | grep -Eo "([0-9.]+){4}/[0-9]+"
```

**1.3 Cloud Asset Discovery**

```bash
# Find S3 buckets
python3 << 'EOF'
import requests

target = "target"
buckets = [f"{target}-backup", f"{target}-assets", f"{target}-dev"]

for bucket in buckets:
    url = f"https://{bucket}.s3.amazonaws.com"
    r = requests.head(url)
    if r.status_code != 404:
        print(f"[+] Found: {url} (Status: {r.status_code})")
EOF
```

#### 🤖 AI-Powered Enhancement

Use ChatGPT/Claude to generate target-specific queries:

```python
# ai_recon_helper.py
import openai
import sys

openai.api_key = "your-api-key"

def generate_dorks(target):
    prompt = f"""Generate 10 Google dorks to find sensitive information about {target}.
    Include searches for:
    - Exposed documents
    - GitHub repositories
    - API documentation
    - Admin panels
    - Config files
    
    Format as: site:target.com [dork]"""
    
    response = openai.ChatCompletion.create(
        model="gpt-4",
        messages=[{"role": "user", "content": prompt}]
    )
    
    return response.choices[0].message.content

if __name__ == "__main__":
    target = sys.argv[1]
    print(generate_dorks(target))
```

**Usage:**

```bash
python3 ai_recon_helper.py "target.com"
```

**Pro Tip:** 💡 Save the generated dorks to a file and run them automatically

***

### Phase 2: Subdomain Enumeration

#### 📊 Infographic: Subdomain Enumeration Flow

&#x20;_Passive → Active → Permutation → Resolution_

#### 📋 Copy-Paste Commands

**2.1 Passive Enumeration (No DNS Queries)**

```bash
# Using subfinder with all sources
subfinder -d target.com -all -silent -o subs_passive.txt

# Using amass (slower but thorough)
amass enum -passive -d target.com -o subs_amass.txt

# Using assetfinder
assetfinder --subs-only target.com | tee subs_assetfinder.txt

# Combine all
sort -u subs_*.txt > all_subs.txt
wc -l all_subs.txt
```

**2.2 Active Enumeration (DNS Brute Force)**

```bash
# Download wordlist
wget https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/DNS/subdomains-top1million-5000.txt

# DNS brute force with puredns
go install -v github.com/d3mondev/puredns/v2@latest
puredns bruteforce subdomains-top1million-5000.txt target.com -r resolvers.txt | tee subs_active.txt
```

**2.3 Permutation Scanning**

```bash
# Install gotator
go install -v github.com/Josue87/gotator@latest

# Generate permutations
gotator -sub all_subs.txt -perm permutations.txt -depth 2 -numbers 5 > subs_permutations.txt

# Resolve permutations
puredns resolve subs_permutations.txt -r resolvers.txt | tee subs_permuted.txt
```

**2.4 AI-Enhanced Wordlist Generation**

```python
# ai_wordlist.py
import openai

def generate_wordlist(domain):
    prompt = f"""Generate 50 subdomain prefixes for {domain} based on common patterns.
    Categories to include:
    - Environment (dev, staging, prod, test)
    - Services (api, app, mail, ftp)
    - Locations (us, eu, asia)
    - Departments (hr, admin, support)
    - Infrastructure (cdn, static, assets)
    
    Return only the subdomain names, one per line."""
    
    response = openai.ChatCompletion.create(
        model="gpt-3.5-turbo",
        messages=[{"role": "user", "content": prompt}]
    )
    
    return response.choices[0].message.content

# Generate and save
with open("ai_wordlist.txt", "w") as f:
    f.write(generate_wordlist("target.com"))
```

**Usage:**

```bash
python3 ai_wordlist.py
cat ai_wordlist.txt | dnsx -silent -r resolvers.txt | tee subs_ai.txt
```

#### 🎯 One-Liner: Complete Subdomain Discovery

```bash
# Master command - does everything
subfinder -d target.com -all -silent | \
  tee subs_passive.txt | \
  dnsx -silent -a -resp | \
  tee subs_resolved.txt | \
  wc -l
```

***

### Phase 3: Service Detection

#### 📊 Technology Detection Matrix

&#x20;_Visual guide to fingerprinting web technologies_

#### 📋 Copy-Paste Commands

**3.1 HTTP Probing**

```bash
# Fast HTTP probing with httpx
httpx -l all_subs.txt -silent -o live_hosts.txt

# With technology detection
httpx -l all_subs.txt -tech-detect -status-code -title -silent -o hosts_tech.txt

# Screenshot enumeration (optional)
httpx -l live_hosts.txt -ss -o screenshots/
```

**Expected Output:**

```
https://api.target.com [200] [API Gateway] [nginx]
https://dev.target.com [403] [Development] [Apache]
```

**3.2 Port Scanning**

```bash
# Quick port scan with naabu
naabu -list live_hosts.txt -top-ports 100 -silent -o ports.txt

# Full port scan (slow)
naabu -list live_hosts.txt -p - -silent -o all_ports.txt

# Service version detection
nmap -iL live_hosts.txt -sV -O --top-ports 100 -oN nmap_scan.txt
```

**3.3 Web Technology Fingerprinting**

```bash
# Using whatweb
whatweb -i live_hosts.txt --log-json=whatweb.json

# Using wappalyzer (CLI)
npx wappalyzer https://target.com -o wappalyzer.json

# Using nuclei for tech detection
nuclei -l live_hosts.txt -t technologies/ -silent -o tech_detected.txt
```

#### 🤖 AI Analysis of Results

```python
# analyze_tech.py
import json
import openai

def analyze_tech_stack(tech_file):
    with open(tech_file, 'r') as f:
        tech_data = json.load(f)
    
    prompt = f"""Analyze this technology stack data and identify:
    1. Potential vulnerabilities based on outdated versions
    2. Interesting attack vectors
    3. Hidden services or admin panels to look for
    4. Prioritization of targets
    
    Data: {json.dumps(tech_data, indent=2)}
    
    Provide actionable recommendations for a bug bounty hunter."""
    
    response = openai.ChatCompletion.create(
        model="gpt-4",
        messages=[{"role": "user", "content": prompt}]
    )
    
    return response.choices[0].message.content

# Run analysis
print(analyze_tech("whatweb.json"))
```

***

### Phase 4: Content Discovery

#### 📋 Copy-Paste Commands

**4.1 Directory Brute Forcing**

```bash
# Fast scan with feroxbuster
feroxbuster -u https://target.com -w /usr/share/wordlists/dirb/common.txt -t 50 -o dirs.txt

# Comprehensive scan
feroxbuster -u https://target.com -w /usr/share/wordlists/seclists/Discovery/Web-Content/raft-large-directories.txt -t 30 -o dirs_full.txt

# API endpoint discovery
feroxbuster -u https://api.target.com -w /usr/share/wordlists/seclists/Discovery/Web-Content/api/api-endpoints.txt -o api_endpoints.txt
```

**4.2 JavaScript Analysis**

```bash
# Download all JS files
getJS -input live_hosts.txt -output js_files.txt

# Extract endpoints from JS
cat js_files.txt | xargs -I {} curl -s {} | grep -oE "(https?://[^\" ]+|/[^\" ]*)" | sort -u > js_endpoints.txt

# AI-powered JS analysis
python3 << 'EOF'
import re
import openai

with open('js_files.txt', 'r') as f:
    js_urls = [line.strip() for line in f]

# Download and analyze first 5 JS files
js_content = ""
for url in js_urls[:5]:
    import requests
    try:
        r = requests.get(url)
        js_content += r.text[:5000]  # First 5000 chars
    except:
        pass

prompt = f"""Analyze this JavaScript code and find:
1. API endpoints
2. Hardcoded secrets or keys
3. Debug endpoints
4. Interesting functions or routes

Code: {js_content[:2000]}"""

response = openai.ChatCompletion.create(
    model="gpt-4",
    messages=[{"role": "user", "content": prompt}]
)

print(response.choices[0].message.content)
EOF
```

**4.3 GitHub Reconnaissance**

```bash
# Search for exposed secrets
git-hound --subdomains all_subs.txt --output github_secrets.txt

# Search for config files
github-subdomain -t YOUR_GITHUB_TOKEN -d target.com | tee github_subs.txt

# Manual GitHub dorks
echo "target.com api_key" | xargs -I {} sh -c 'gh search code "{}" --limit 10'
```

#### 🎯 Quick Win Commands

```bash
# Find backup files
ffuf -u https://target.com/FUZZ -w /usr/share/wordlists/seclists/Discovery/Web-Content/backup_files.txt -mc 200

# Find git exposed
ffuf -u https://target.com/.git/FUZZ -w /usr/share/wordlists/seclists/Discovery/Web-Content/common.txt -mc 200

# Find config files
ffuf -u https://target.com/FUZZ -w /usr/share/wordlists/seclists/Discovery/Web-Content/config_files.txt -mc 200
```

***

### 🤖 AI Automation Pipeline

#### Complete Docker-Based Recon System

Create `recon_automation.sh`:

```bash
#!/bin/bash
# AI-Powered Reconnaissance Automation Script
# Usage: ./recon_automation.sh target.com

TARGET=$1
OUTPUT_DIR="recon_$(date +%Y%m%d)_$TARGET"
mkdir -p $OUTPUT_DIR

echo "[+] Starting AI-Powered Recon for $TARGET"

# Phase 1: Subdomain Enumeration
echo "[*] Phase 1: Subdomain Enumeration"
subfinder -d $TARGET -all -silent | tee $OUTPUT_DIR/subs.txt
amass enum -passive -d $TARGET -o $OUTPUT_DIR/subs_amass.txt
cat $OUTPUT_DIR/subs*.txt | sort -u > $OUTPUT_DIR/all_subs.txt

# Phase 2: DNS Resolution
echo "[*] Phase 2: DNS Resolution"
cat $OUTPUT_DIR/all_subs.txt | dnsx -silent -a -resp | tee $OUTPUT_DIR/subs_resolved.txt

# Phase 3: HTTP Probing
echo "[*] Phase 3: HTTP Probing"
cat $OUTPUT_DIR/all_subs.txt | httpx -silent -tech-detect -status-code | tee $OUTPUT_DIR/live_hosts.txt

# Phase 4: Port Scanning
echo "[*] Phase 4: Port Scanning"
cat $OUTPUT_DIR/all_subs.txt | naabu -top-ports 100 -silent | tee $OUTPUT_DIR/ports.txt

# Phase 5: Content Discovery
echo "[*] Phase 5: Content Discovery"
mkdir -p $OUTPUT_DIR/content
for host in $(cat $OUTPUT_DIR/live_hosts.txt | awk '{print $1}'); do
    feroxbuster -u $host -w /usr/share/wordlists/dirb/common.txt -t 30 -o $OUTPUT_DIR/content/$(echo $host | sed 's/[^a-zA-Z0-9]/_/g').txt
done

# Phase 6: AI Analysis
echo "[*] Phase 6: AI Analysis"
python3 << EOF
import json
import openai

# Read all results
with open('$OUTPUT_DIR/live_hosts.txt', 'r') as f:
    hosts = f.read()

with open('$OUTPUT_DIR/ports.txt', 'r') as f:
    ports = f.read()

prompt = f"""Analyze this reconnaissance data for target $TARGET and provide:
1. Most interesting targets to investigate first
2. Potential vulnerabilities based on technology stack
3. Recommended next steps
4. Low-hanging fruit opportunities

Live Hosts:
{hosts}

Open Ports:
{ports}"""

response = openai.ChatCompletion.create(
    model="gpt-4",
    messages=[{"role": "user", "content": prompt}]
)

print(response.choices[0].message.content)

with open('$OUTPUT_DIR/ai_analysis.txt', 'w') as f:
    f.write(response.choices[0].message.content)
EOF

echo "[+] Recon Complete! Results saved to $OUTPUT_DIR/"
echo "[+] AI Analysis: $OUTPUT_DIR/ai_analysis.txt"
```

**Usage:**

```bash
chmod +x recon_automation.sh
./recon_automation.sh target.com
```

***

### 💡 Pro Tips

#### Tip 1: Rate Limiting

```bash
# Add delays to avoid blocking
httpx -l subs.txt -rate-limit 50 -silent
```

#### Tip 2: Resolver Rotation

```bash
# Use multiple DNS resolvers
curl -s https://raw.githubusercontent.com/janmasarik/resolvers/master/resolvers.txt > resolvers.txt
dnsx -l subs.txt -r resolvers.txt -retry 3
```

#### Tip 3: VPS for Large Scans

```bash
# Use a VPS to avoid IP bans
# DigitalOcean, Linode, or Hetzner work great
# Run recon from cloud instance
```

#### Tip 4: Monitoring Changes

```bash
# Track changes over time
# Install notify
go install -v github.com/projectdiscovery/notify@latest

# Set up monitoring
subfinder -d target.com -all | anew subs.txt | notify
```

#### Tip 5: Scope Management

```bash
# Filter out-of-scope domains
cat all_subs.txt | grep -v "out-of-scope.com" | tee in_scope.txt
```

***

### 🎯 Quick Reference: All-in-One Commands

#### Master One-Liner

```bash
# Complete recon in one command
subfinder -d target.com -all -silent | \
  tee subs.txt | \
  dnsx -silent -a | \
  tee resolved.txt | \
  httpx -silent -tech-detect | \
  tee live.txt | \
  nuclei -t technologies/ -silent | \
  tee tech.txt
```

#### Cloud Recon

```bash
# Find cloud assets
for provider in s3 gcs azure; do
  echo "Checking $provider buckets..."
  cat all_subs.txt | xargs -I {} sh -c "curl -s https://{}.s3.amazonaws.com | head -1" 2>/dev/null
done
```

#### Historical Data

```bash
# Wayback Machine URLs
cat all_subs.txt | waybackurls | tee wayback.txt

# GAU (GetAllUrls)
cat all_subs.txt | gau | tee gau_urls.txt

# Combine and filter
sort -u wayback.txt gau_urls.txt | grep -E "\.(js|json|xml|txt|git)$" > interesting_urls.txt
```

***

### 📚 Resources & Tools

#### Essential Tools

* [Subfinder](https://github.com/projectdiscovery/subfinder) - Subdomain discovery
* [Amass](https://github.com/owasp-amass/amass) - In-depth enumeration
* [HTTPX](https://github.com/projectdiscovery/httpx) - Fast HTTP prober
* [Naabu](https://github.com/projectdiscovery/naabu) - Port scanner
* [Feroxbuster](https://github.com/epi052/feroxbuster) - Content discovery
* [Nuclei](https://github.com/projectdiscovery/nuclei) - Vulnerability scanner

#### Wordlists

* [SecLists](https://github.com/danielmiessler/SecLists) - Security wordlists
* [Assetnote Wordlists](https://wordlists.assetnote.io) - High-quality wordlists

#### AI Tools

* [ChatGPT](https://chat.openai.com) - For analysis and queries
* [Claude](https://claude.ai) - For code generation
* [GitHub Copilot](https://github.com/features/copilot) - For automation scripts

***

### ⚠️ Common Mistakes to Avoid

1. **❌ Not respecting rate limits** → Get IP banned
   * **✅ Fix:** Add `-rate-limit` flags and delays
2. **❌ Skipping passive recon** → Miss obvious targets
   * **✅ Fix:** Always start with passive enumeration
3. **❌ Not filtering results** → Information overload
   * **✅ Fix:** Use `grep`, `sort -u`, and focus on in-scope
4. **❌ Running tools blindly** → Wasted time
   * **✅ Fix:** Understand what each tool does
5. **❌ Not documenting findings** → Lose track
   * **✅ Fix:** Use consistent naming and organize by date

***

### 🎓 Practice Targets

**Beginner:**

* [HackerOne Directory](https://hackerone.com/directory/programs) - Filter for beginners
* [Bugcrowd Programs](https://bugcrowd.com/programs) - Look for "wide scope"

**Intermediate:**

* [YesWeHack](https://www.yeswehack.com) - European programs
* [Intigriti](https://www.intigriti.com) - Quality programs

**Advanced:**

* Private invite-only programs
* Synack Red Team
* Cobalt.io

***

### 📥 Download This Guide

* PDF Version
* Automation Scripts
* Mind Map (PNG)

***

### 🔄 Next Steps

After completing recon:

1. Web Application Testing →
2. API Security Testing →
3. Report Writing →

***

_Found this helpful?_ [_Share on Twitter_](https://twitter.com/intent/tweet?text=Check%20out%20this%20AI-Powered%20Recon%20Guide%20by%20@CipherOps_tech) _•_ [_Contribute on GitHub_](https://github.com/CipherOps/bug-bounty-notes)

_Last Updated: 2026-02-26 • Contributed by: @CipherOps\_tech_
