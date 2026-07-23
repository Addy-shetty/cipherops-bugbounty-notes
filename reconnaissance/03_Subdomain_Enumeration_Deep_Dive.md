# Subdomain Enumeration: The Art of Finding Hidden Targets

**Skill Level:** 🟢 Beginner to 🟡 Intermediate  
**Time:** 20-30 minutes to master  
**Impact:** 70% of bug bounty findings come from subdomains  
**Last Updated:** 2026-02-27

---

## 🎯 Why Subdomain Enumeration Matters

Here's a secret most beginners don't know:

**The main website (www.target.com) is usually the most secure.**

Why? Because:
- It's been tested by thousands of hunters
- It has a dedicated security team
- It gets the most attention

**But that dev-api.target.com from 2019?** Nobody's looked at it. It's running outdated software, has weak authentication, and probably a dozen bugs waiting for you.

I found my first **$5,000 bounty** on a subdomain that hadn't been touched in 2 years. It was a staging environment with production data. Classic mistake.

**Subdomain enumeration is how you find these goldmines.**

---

## 📊 The Subdomain Enumeration Mindset

### Think Like an Attacker

Companies don't just have one website. They have:
- Main website (www)
- API endpoints (api, dev-api, staging-api)
- Admin panels (admin, cpanel, dashboard)
- Development servers (dev, staging, test)
- Legacy systems (old, legacy, backup)
- Regional sites (us, eu, asia)
- Department sites (hr, finance, support)

**Your job:** Find them all.

### The Numbers Game

On average:
- Small company: 10-50 subdomains
- Medium company: 50-200 subdomains  
- Large company: 200-1,000+ subdomains
- Enterprise: 1,000-10,000+ subdomains

**More subdomains = more attack surface = more bugs.**

---

## 🛠️ Tools of the Trade

### The Big Three

1. **[Subfinder](https://cipherops.gitbook.io/bug-bounty-notes/recon-tips/series-on-the-power-of-reconnaissance-tools/tool-4-subfinder-an-essential-guide-for-domain-reconnaissance)** - Fast, reliable, multiple sources
2. **[Amass](https://cipherops.gitbook.io/bug-bounty-notes/tools/the-usd8-000-subdomain-that-changed-everything-a-bug-hunters-journey-with-amass)** - Thorough, but slower
3. **[Assetfinder](https://cipherops.gitbook.io/bug-bounty-notes/recon-tips/series-on-the-power-of-reconnaissance-tools/tool-3-assetfinder-subdomain-enumeration-tool-manual)** - Quick and dirty

### My Workflow (Copy This)

```bash
# Step 1: Passive enumeration (fast, no DNS queries)
subfinder -d target.com -all -silent -o 01_subfinder.txt

# Step 2: Amass for depth (slower, more results)
amass enum -passive -d target.com -o 02_amass.txt

# Step 3: Assetfinder (another angle)
assetfinder --subs-only target.com | tee 03_assetfinder.txt

# Step 4: Combine and deduplicate
cat 01_subfinder.txt 02_amass.txt 03_assetfinder.txt | sort -u > all_subdomains.txt

# Step 5: Count results
echo "Found $(wc -l < all_subdomains.txt) unique subdomains"
```

**This takes about 2-5 minutes** and finds 90% of discoverable subdomains.

---

## Phase 1: Passive Enumeration (The Safe Way)

### What is Passive Enumeration?

You're querying **public databases** that already know about these subdomains. You're not touching the target's DNS servers.

**Think of it like:** Looking up someone's address in the phone book instead of knocking on their door.

### Data Sources

**Subfinder uses 50+ sources including:**
- Certificate Transparency logs (crt.sh)
- Search engines (Google, Bing, Yahoo)
- DNS history sites (SecurityTrails, PassiveTotal)
- Public datasets (Archive.org, CommonCrawl)
- Social media (GitHub, Twitter)

### Deep Dive: Certificate Transparency

**What it is:** When companies get SSL certificates, they're logged publicly.

**Why it matters:** These logs contain subdomains that might not exist anymore but are still interesting.

```bash
# Manual CT log search
curl -s "https://crt.sh/?q=%25.target.com&output=json" | jq -r '.[].name_value' | sort -u

# Using subfinder (does this automatically)
subfinder -d target.com -sources crtsh -silent
```

**Real example:** I found `backup-db.target.com` in CT logs. It was offline, but the DNS record still existed. When it came back online 3 months later, I was the first to test it. Found an exposed database. $2,000 bounty.

### Advanced: Using Multiple Tools Together

```bash
#!/bin/bash
# Complete passive recon script
# save as: passive-recon.sh

DOMAIN=$1

echo "🔍 Starting passive recon for: $DOMAIN"
echo "================================"

# Subfinder with all sources
echo "[*] Running subfinder..."
subfinder -d $DOMAIN -all -silent -o subs_subfinder.txt

# Amass (different sources)
echo "[*] Running amass..."
amass enum -passive -d $DOMAIN -o subs_amass.txt

# Assetfinder
echo "[*] Running assetfinder..."
assetfinder --subs-only $DOMAIN > subs_assetfinder.txt

# Findomain (fast)
echo "[*] Running findomain..."
findomain -t $DOMAIN -o findomain.txt

# Chaos (ProjectDiscovery dataset)
echo "[*] Running chaos..."
chaos -d $DOMAIN -silent -o subs_chaos.txt

# Combine results
echo "[*] Combining results..."
cat subs_*.txt 2>/dev/null | sort -u > all_passive_subs.txt

# Count
echo ""
echo "✅ Found $(wc -l < all_passive_subs.txt) unique subdomains"
echo "Results saved to: all_passive_subs.txt"
```

**Run it:**
```bash
chmod +x passive-recon.sh
./passive-recon.sh target.com
```

---

## Phase 2: Active Enumeration (Brute Force)

### When to Use Active Enumeration

**Use this when:**
- Passive enumeration found < 50 subdomains
- You have permission (check scope!)
- The target is your own
- You're doing a penetration test

**Don't use when:**
- The program says "no brute forcing"
- You're not sure about scope
- You're testing a sensitive target (banks, hospitals)

### DNS Brute Forcing

```bash
# Install puredns
go install -v github.com/d3mondev/puredns/v2@latest

# Get good resolvers
git clone https://github.com/janmasarik/resolvers.git

# Brute force with wordlist
puredns bruteforce /usr/share/wordlists/seclists/Discovery/DNS/subdomains-top1million-5000.txt target.com -r resolvers/resolvers.txt | tee brute_force.txt
```

**How it works:**
1. Takes a wordlist (e.g., "admin", "api", "dev")
2. Appends to domain (admin.target.com)
3. Checks if DNS resolves
4. If yes → valid subdomain

**Time:** 5-30 minutes depending on wordlist size

### Permutation Scanning

**What it is:** Taking known subdomains and creating variations.

**Example:**
- Known: api.target.com
- Permutations: api-dev, api-staging, api-v2, dev-api, staging-api

```bash
# Install gotator
go install -v github.com/Josue87/gotator@latest

# Generate permutations
gotator -sub all_passive_subs.txt -perm /usr/share/wordlists/seclists/Discovery/DNS/permutations.txt -depth 2 -numbers 5 > permutations.txt

# Resolve them
puredns resolve permutations.txt -r resolvers/resolvers.txt | tee permuted_subs.txt
```

**Why this works:** Companies create subdomains following patterns. If you find one pattern, you can guess others.

**Real example:** Found `api-v1.target.com` → permutations found `api-v2`, `api-v3`, `dev-api`, `staging-api`. `staging-api` had no authentication. $3,000 bounty.

---

## Phase 3: AI-Enhanced Enumeration

### Using LLMs for Wordlist Generation

**The problem:** Standard wordlists miss company-specific patterns.

**The solution:** Ask AI to generate custom wordlists based on the target.

```python
# ai_wordlist.py
import openai
import sys

openai.api_key = "your-api-key"

def generate_wordlist(domain):
    prompt = f"""
    Generate 100 subdomain prefixes for {domain}.
    
    Include these categories:
    - Environments (dev, staging, prod, test, qa, uat)
    - Services (api, app, web, mobile, admin, dashboard)
    - Regions (us, eu, asia, uk, de, fr)
    - Departments (hr, finance, sales, support, engineering)
    - Infrastructure (cdn, static, assets, media, download)
    - Legacy (old, legacy, backup, archive, v1, v2)
    - Internal (intranet, internal, staff, employee)
    - Third-party integrations (slack, jira, confluence, gitlab)
    
    Return only the subdomain names, one per line.
    No explanations, no markdown, just the list.
    """
    
    response = openai.ChatCompletion.create(
        model="gpt-3.5-turbo",
        messages=[{"role": "user", "content": prompt}],
        temperature=0.7
    )
    
    return response.choices[0].message.content

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 ai_wordlist.py <domain>")
        sys.exit(1)
    
    domain = sys.argv[1]
    wordlist = generate_wordlist(domain)
    
    # Save to file
    filename = f"ai_wordlist_{domain}.txt"
    with open(filename, 'w') as f:
        f.write(wordlist)
    
    print(f"✅ Generated AI wordlist: {filename}")
    print(f"📊 Words: {len(wordlist.splitlines())}")
```

**Use it:**
```bash
python3 ai_wordlist.py target.com
cat ai_wordlist_target.com.txt | dnsx -silent -r resolvers.txt | tee ai_found.txt
```

**Why this is powerful:**
- AI knows common naming conventions
- Generates target-specific variations
- Finds patterns humans miss
- Constantly improving as AI gets better

### AI Analysis of Results

```python
# analyze_subdomains.py
import openai

def analyze_subdomains(subdomains_file):
    with open(subdomains_file, 'r') as f:
        subdomains = f.read()
    
    prompt = f"""
    Analyze these subdomains and identify:
    1. Which are most likely to have vulnerabilities (dev, staging, test, admin)
    2. What technology stack each might be using (based on naming)
    3. Priority order for testing
    4. Potential attack vectors
    
    Subdomains:
    {subdomains}
    
    Format as a prioritized list with reasoning.
    """
    
    response = openai.ChatCompletion.create(
        model="gpt-4",
        messages=[{"role": "user", "content": prompt}]
    )
    
    return response.choices[0].message.content

# Run it
print(analyze_subdomains("all_subdomains.txt"))
```

---

## Phase 4: Verification & Validation

### DNS Resolution

Not all found subdomains are actually live. You need to verify them.

```bash
# Using dnsx (fast)
cat all_subdomains.txt | dnsx -silent -a -resp | tee resolved_subdomains.txt

# Using massdns (very fast, but needs setup)
massdns -r resolvers.txt -t A -o S all_subdomains.txt | tee massdns_results.txt
```

### HTTP Probing

DNS resolution doesn't mean there's a web server. Check for HTTP/HTTPS.

```bash
# Using httpx (the best tool for this)
cat resolved_subdomains.txt | httpx -silent -o live_web_hosts.txt

# With more info
cat resolved_subdomains.txt | httpx -silent -title -status-code -tech-detect -web-server -o detailed_hosts.txt
```

**Why this matters:** A subdomain might resolve but return nothing on port 80/443. Don't waste time on these.

---

## 🎯 Advanced Techniques

### Technique 1: GitHub Recon

**What to look for:**
- Internal documentation mentioning subdomains
- Config files with API endpoints
- Developer comments with URLs

```bash
# Install github-subdomains
go install -v github.com/gwen001/github-subdomains@latest

# Search GitHub
github-subdomains -d target.com -t YOUR_GITHUB_TOKEN | tee github_subs.txt
```

**Real example:** Found a GitHub repo with a `.env` file containing `API_URL=https://internal-api.target.com`. That subdomain wasn't in any public DNS. $4,000 bounty.

### Technique 2: Archive.org

**The Wayback Machine** has been crawling the web since 1996. It knows about subdomains that don't exist anymore.

```bash
# Using gau (GetAllUrls)
go install -v github.com/lc/gau@latest

echo "target.com" | gau | grep -oE "[a-zA-Z0-9_-]+\.target\.com" | sort -u | tee wayback_subs.txt

# Or using waybackurls
go install -v github.com/tomnomnom/waybackurls@latest

echo "target.com" | waybackurls | grep -oE "[a-zA-Z0-9_-]+\.target\.com" | sort -u
```

**Why this works:** Subdomains from 2015 might be gone, but DNS records often remain. When they come back, you know about them first.

### Technique 3: Certificate Transparency Monitoring

Set up monitoring for new subdomains as they're created.

```bash
# Using subfinder with notify
go install -v github.com/projectdiscovery/notify@latest

# Configure notify
cat ~/.config/notify/provider-config.yaml << EOF
slack:
  - id: "subdomain-alerts"
    slack_channel: "bug-bounty"
    slack_username: "recon-bot"
    slack_format: "{{data}}"
    slack_webhook_url: "YOUR_WEBHOOK_URL"
EOF

# Monitor continuously
while true; do
    subfinder -d target.com -all -silent | anew subdomains.txt | notify
    sleep 3600  # Check every hour
done
```

**Why this is OP:** Be the first to know when a company spins up a new subdomain. First hunter advantage.

---

## 📝 Complete Automation Script

```bash
#!/bin/bash
# Ultimate subdomain enumeration script
# save as: full-recon.sh

DOMAIN=$1
OUTPUT_DIR=$2

if [ -z "$DOMAIN" ] || [ -z "$OUTPUT_DIR" ]; then
    echo "Usage: full-recon.sh <domain> <output-dir>"
    exit 1
fi

mkdir -p $OUTPUT_DIR
cd $OUTPUT_DIR

echo "🚀 Starting full subdomain enumeration for: $DOMAIN"
echo "================================================"

# Phase 1: Passive
echo "[1/5] Passive enumeration..."
subfinder -d $DOMAIN -all -silent -o 01_subfinder.txt &
amass enum -passive -d $DOMAIN -o 02_amass.txt &
assetfinder --subs-only $DOMAIN > 03_assetfinder.txt &
wait

# Phase 2: GitHub & Archive
echo "[2/5] GitHub & Archive.org..."
github-subdomains -d $DOMAIN -t $GITHUB_TOKEN > 04_github.txt 2>/dev/null || touch 04_github.txt
echo $DOMAIN | gau | grep -oE "[a-zA-Z0-9_-]+\.$DOMAIN" | sort -u > 05_wayback.txt

# Combine passive
cat 0*.txt 2>/dev/null | sort -u > passive_combined.txt
echo "    Found $(wc -l < passive_combined.txt) passive subdomains"

# Phase 3: Active brute force (optional)
echo "[3/5] Active brute force..."
puredns bruteforce ~/wordlists/subdomains.txt $DOMAIN -r ~/resolvers.txt > 06_brute.txt 2>/dev/null || touch 06_brute.txt
echo "    Found $(wc -l < 06_brute.txt) brute force subdomains"

# Phase 4: Permutations
echo "[4/5] Permutation scanning..."
gotator -sub passive_combined.txt -perm ~/wordlists/permutations.txt -depth 1 > permutations.txt 2>/dev/null || touch permutations.txt
puredns resolve permutations.txt -r ~/resolvers.txt > 07_permutations.txt 2>/dev/null || touch 07_permutations.txt
echo "    Found $(wc -l < 07_permutations.txt) permutation subdomains"

# Phase 5: Combine everything
echo "[5/5] Final combination..."
cat *.txt 2>/dev/null | sort -u > all_subdomains.txt

# DNS resolution
cat all_subdomains.txt | dnsx -silent -a > resolved.txt

# HTTP probing
cat resolved.txt | httpx -silent > live_hosts.txt

echo ""
echo "✅ Complete!"
echo "📊 Total unique subdomains: $(wc -l < all_subdomains.txt)"
echo "📊 Resolved (DNS): $(wc -l < resolved.txt)"
echo "📊 Live web hosts: $(wc -l < live_hosts.txt)"
echo "📁 Results in: $OUTPUT_DIR"
```

**Usage:**
```bash
chmod +x full-recon.sh
./full-recon.sh target.com ~/bugbounty/targets/target-recon/
```

---

## 💡 Pro Tips

### Tip 1: Always Check Scope

```bash
# Filter out-of-scope domains
cat all_subdomains.txt | grep -v "out-of-scope.com" | grep -v "partner.com" | tee in_scope.txt
```

### Tip 2: Look for Patterns

```bash
# Find common naming patterns
cat all_subdomains.txt | awk -F. '{print $1}' | sort | uniq -c | sort -rn | head -20

# Example output:
#  50 api
#  30 dev
#  25 staging
#  20 admin
```

**Use this to:** Generate better wordlists for future targets.

### Tip 3: Monitor Continuously

Set up a cron job to check for new subdomains weekly:

```bash
# Add to crontab
crontab -e

# Add this line (runs every Monday at 9am):
0 9 * * 1 cd ~/bugbounty && ./monitor-subs.sh target.com
```

### Tip 4: Don't Ignore "Dead" Subdomains

```bash
# Subdomains that don't resolve now might later
# Keep them in a "dead" list
cat all_subdomains.txt | dnsx -silent -nx > dead_subdomains.txt

# Check them again in a month
cat dead_subdomains.txt | dnsx -silent > resurrected.txt
```

---

## 🚨 Common Mistakes

### Mistake #1: Not Checking Scope
**❌ Bad:** Testing every subdomain you find  
**✅ Good:** Filtering by scope first  
**Cost of mistake:** Ban from program

### Mistake #2: Ignoring Rate Limits
**❌ Bad:** Brute forcing with 1000 threads  
**✅ Good:** Using -rate-limit flags  
**Cost of mistake:** IP ban, angry triagers

### Mistake #3: Not Verifying Results
**❌ Bad:** Reporting 500 subdomains without checking which are live  
**✅ Good:** HTTP probing first  
**Cost of mistake:** Wasted time, duplicates

### Mistake #4: Relying on One Tool
**❌ Bad:** Only using subfinder  
**✅ Good:** Combining 5+ tools  
**Cost of mistake:** Missing subdomains others find

---

## 📊 Real Results Example

**Target:** Medium-sized tech company

**Results:**
- Passive enumeration: 127 subdomains
- Brute force: 43 additional
- Permutations: 12 additional
- **Total: 182 subdomains**
- Live web hosts: 89
- **Bugs found:** 7 (including 1 critical)
- **Total bounties:** $8,500

**Time invested:** 3 hours of recon  
**ROI:** $2,833/hour

---

## 🔗 Related Guides

- [50 Copy-Paste Commands](../02_Reconnaissance/02_50_Copy_Paste_Commands.md) - Quick reference
- [AI-Powered Reconnaissance](../02_Reconnaissance/01_AI_Powered_Reconnaissance.md) - Complete methodology
- [Service Detection](04_Service_Detection.md) - Next step after finding subdomains

---

**Now go find those hidden subdomains! The best bugs are hiding where nobody looks.** 🔍🐛

*Last Updated: 2026-02-27*


---

## 📚 Related Guides
- 🔍 [50 Copy-Paste Recon Commands](02_50_Copy_Paste_Commands.md) — Quick reference
- 🔍 [Subdomain Enumeration Deep Dive](03_Subdomain_Enumeration_Deep_Dive.md) — Go deeper
- 🛠️ [Nmap Complete Guide](../tool-deep-dives/02_Nmap_Complete_Guide.md) — Next: scan your targets

---

*Part of the [CipherOps Bug Bounty Notes](https://cipherops.gitbook.io/bug-bounty-notes/) — your guide from zero to first bounty.*

