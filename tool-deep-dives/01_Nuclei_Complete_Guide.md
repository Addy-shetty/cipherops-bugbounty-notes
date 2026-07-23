# Nuclei: The Swiss Army Knife of Vulnerability Scanning

## My 3 AM Wake-Up Call

It was 3 AM. I'd been staring at a scope for 6 hours with nothing to show. Coffee #4 was getting cold. Then I found it—a misconfigured Jenkins instance that everyone else missed. How? Nuclei. That tool saved my sanity and paid for my rent that month.

If you're serious about bug bounty hunting, you need to know Nuclei. Period. This guide is everything I wish someone had handed me when I started. Real commands. Real workflows. No fluff.

---

## What is Nuclei and Why Should You Care?

Nuclei is an open-source vulnerability scanner created by [ProjectDiscovery](https://projectdiscovery.io). Think of it as a super-powered grep that knows about 10,000+ security vulnerabilities. It uses YAML-based templates to define checks, making it incredibly flexible and community-driven.

### Why Nuclei Won My Heart

1. **Speed**: Scans thousands of targets in minutes, not hours
2. **Accuracy**: Community-validated templates with low false positives
3. **Coverage**: 10,000+ templates covering CVEs, misconfigurations, and exposures
4. **Flexibility**: Custom templates for your specific needs
5. **Integration**: Works with everything—CI/CD, [bug bounty platforms](https://cipherops.gitbook.io/bug-bounty-notes/readme/bug-bounty-platforms-compared-where-to-hunt-in-2026), automation

**Real Talk**: Before Nuclei, I spent 80% of my time on manual recon. After Nuclei? 20%. That extra time? I found 3 more bugs that month.

---

## Installation: 4 Ways to Get Started

### Method 1: Go Install (Recommended for Developers)

```bash
# Requires Go 1.21+
go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest

# Verify installation
nuclei -version
```

**Pro Tip**: Add `$(go env GOPATH)/bin` to your PATH if commands aren't found.

### Method 2: Binary Download (Easiest for Beginners)

```bash
# Download latest release
wget https://github.com/projectdiscovery/nuclei/releases/download/v3.1.10/nuclei_3.1.10_linux_amd64.zip
unzip nuclei_3.1.10_linux_amd64.zip
sudo mv nuclei /usr/local/bin/

# Or use the official install script
curl -s https://raw.githubusercontent.com/projectdiscovery/nuclei/main/install.sh | bash
```

**Screenshot Placeholder**: Terminal showing successful installation with version output
```
[INSERT SCREENSHOT: nuclei-installation.png]
Show: Command execution and version confirmation
```

### Method 3: Docker (For Isolated Environments)

```bash
# Pull the image
docker pull projectdiscovery/nuclei:latest

# Run with mounted templates
docker run -it -v ~/nuclei-templates:/templates projectdiscovery/nuclei -t /templates
```

### Method 4: Kali Linux (Pre-installed)

```bash
# Already there, just update
sudo apt update && sudo apt install nuclei
```

---

## Quick Start: Your First Scan in 5 Minutes

### Step 1: Update Templates

Nuclei needs templates to work. Think of them as the "knowledge base" of vulnerabilities.

```bash
# Download/update all templates
nuclei -update-templates

# This downloads ~10,000 templates to ~/.local/nuclei-templates/
# Takes 2-3 minutes depending on your connection
```

**What just happened?** You now have templates for:
- CVEs (Common Vulnerabilities and Exposures)
- Misconfigurations (exposed panels, default creds)
- Exposures (API keys, sensitive files)
- Technologies (WordPress, Jenkins, etc.)

### Step 2: Basic Target Scan

```bash
# Single target
nuclei -u https://target.com

# Multiple targets from file
nuclei -l targets.txt

# With specific templates
nuclei -u https://target.com -t nuclei-templates/http/exposures/
```

**Screenshot Placeholder**: First scan execution
```
[INSERT SCREENSHOT: nuclei-first-scan.png]
Show: Basic scan running with colorful output showing findings
```

### Step 3: Understanding the Output

```
[2024-02-27 14:23:15] [exposed-panels] [http] [info] https://target.com/admin [jenkins-panel]
[2024-02-27 14:23:18] [tech-detect] [http] [info] https://target.com [WordPress]
```

**What this means:**
- Timestamp: When the check ran
- Template: Which vulnerability it checked
- Protocol: HTTP/HTTPS/TCP
- Severity: info/low/medium/high/critical
- URL: Where the finding occurred
- Extra: Additional context (panel name, technology, etc.)

---

## Real-World Command Examples

### Scenario 1: Bug Bounty Recon Pipeline

This is my go-to command when I get a new scope:

```bash
# Full recon with categorized output
nuclei -l targets.txt \
  -severity critical,high,medium \
  -o nuclei-results.txt \
  -json-export nuclei-results.json \
  -stats \
  -si 10

# Explanation:
# -severity: Only show critical/high/medium (ignore info/low noise)
# -o: Save human-readable output
# -json-export: Machine-readable for further processing
# -stats: Show scan progress every 10 seconds
# -si: Silence interval - update stats every 10 seconds
```

**Real Example Output:**
```
[CRITICAL] CVE-2023-XXXXX - Remote Code Execution
[HIGH] Exposed .git directory
[MEDIUM] Missing security headers
```

### Scenario 2: Focused Technology Scanning

Found a WordPress site? Don't scan everything—be smart:

```bash
# WordPress-specific checks
nuclei -u https://target.com -t nuclei-templates/http/technologies/wordpress/

# Jenkins targets
nuclei -u https://target.com -t nuclei-templates/http/exposed-panels/jenkins-

# API endpoints
nuclei -u https://api.target.com -t nuclei-templates/http/exposures/apis/
```

### Scenario 3: Rate-Limited Scanning (Ethical Hacking)

```bash
# Respectful scanning with rate limits
nuclei -l targets.txt \
  -rl 100 \
  -bs 25 \
  -c 25

# Explanation:
# -rl: Rate limit - 100 requests per second
# -bs: Bulk size - process 25 hosts at once
# -c: Concurrency - 25 parallel threads
```

**Why this matters**: Most bug bounty programs have rate limits. Violate them = banned. This keeps you safe.

### Scenario 4: Silent Operation (Stealth Mode)

```bash
# Minimal output for automation
nuclei -l targets.txt -silent -o results.txt

# With notification
nuclei -l targets.txt -silent -o results.txt && notify -bulk results.txt
```

### Scenario 5: Excluding False Positives

```bash
# Exclude specific templates that give false positives
nuclei -l targets.txt -etags "fuzz,brute-force"

# Exclude specific templates by ID
nuclei -l targets.txt -exclude-templates nuclei-templates/http/fuzzing/
```

---

## AI-Powered Workflows: Working Smarter, Not Harder

### Workflow 1: AI Template Generation

Stuck on a custom vulnerability? Use AI to generate templates:

```bash
# Use AI to analyze and create custom templates
nuclei -l targets.txt -ai "Find exposed admin panels with default credentials"
```

**Manual Method (With ChatGPT/[Claude](https://cipherops.gitbook.io/bug-bounty-notes/tools/supercharge-your-bug-bounty-hunting-with-claude-security-skills-the-complete-guide)):**

1. **Describe your need:**
   ```
   "I need a Nuclei template that checks for exposed 
   phpMyAdmin panels at common paths"
   ```

2. **AI generates template:**
   ```yaml
   id: phpmyadmin-exposed
   
   info:
     name: Exposed phpMyAdmin Panel
     author: ai-generated
     severity: high
   
   http:
     - method: GET
       path:
         - "{{BaseURL}}/phpmyadmin"
         - "{{BaseURL}}/phpMyAdmin"
         - "{{BaseURL}}/pma"
       
       matchers:
         - type: word
           words:
             - "phpMyAdmin"
             - "pma_username"
   ```

3. **Save and use:**
   ```bash
   # Save as custom-template.yaml
   nuclei -u https://target.com -t custom-template.yaml
   ```

### Workflow 2: Automated Report Generation

```bash
# Scan and generate AI-ready report
nuclei -l targets.txt -json-export results.json

# Then ask AI to analyze:
# "Analyze these Nuclei results and prioritize by exploitability"
```

### Workflow 3: Intelligent Target Selection

```bash
# Use AI to select templates based on technology stack
# First, detect technologies
nuclei -u https://target.com -t technologies/ -silent -o tech.txt

# Then, AI suggests relevant templates:
# "Based on detected WordPress and Apache, use these templates..."
```

---

## Advanced Techniques That Pay Bills

### Technique 1: Custom Template Creation

**My Template for Exposed .env Files:**

```yaml
id: exposed-env-file

info:
  name: Exposed .env File
  author: your-name
  severity: high
  description: |
    Detects exposed .env files which often contain 
    database credentials, API keys, and other secrets

dna: |
  Exposed environment configuration file may contain sensitive information

http:
  - method: GET
    path:
      - "{{BaseURL}}/.env"
      - "{{BaseURL}}/.env.local"
      - "{{BaseURL}}/.env.production"
      - "{{BaseURL}}/api/.env"
    
    matchers:
      - type: regex
        regex:
          - "DB_PASSWORD"
          - "API_KEY"
          - "SECRET_KEY"
          - "APP_KEY"
      - type: status
        status:
          - 200
    
    extractors:
      - type: regex
        regex:
          - "DB_PASSWORD=[A-Za-z0-9]+"
          - "API_KEY=[A-Za-z0-9]+"
```

**Save as:** `~/.local/nuclei-templates/custom/exposed-env.yaml`

**Run it:**
```bash
nuclei -l targets.txt -t ~/.local/nuclei-templates/custom/
```

### Technique 2: Workflow Automation

**Create a workflow file** (`recon-workflow.yaml`):

```yaml
id: bug-bounty-recon

info:
  name: Bug Bounty Recon Workflow
  author: your-name

workflows:
  - template: technologies/tech-detect.yaml
    subtemplates:
      - tags: wordpress
      - tags: jenkins
      - tags: api
  
  - template: exposures/
    subtemplates:
      - tags: config
      - tags: git
      - tags: files

  - template: vulnerabilities/
    subtemplates:
      - severity: critical
      - severity: high
```

**Run workflow:**
```bash
nuclei -l targets.txt -w recon-workflow.yaml
```

### Technique 3: Integration with Other Tools

**Chain with [Subfinder](https://cipherops.gitbook.io/bug-bounty-notes/recon-tips/series-on-the-power-of-reconnaissance-tools/tool-4-subfinder-an-essential-guide-for-domain-reconnaissance):**
```bash
# Find subdomains, then scan with Nuclei
subfinder -d target.com -silent | nuclei -t exposures/
```

**Chain with HTTPX:**
```bash
# Probe for live hosts, then scan
cat targets.txt | httpx -silent | nuclei -t technologies/
```

**Full Pipeline:**
```bash
# Complete recon pipeline
echo "target.com" | \
  subfinder -silent | \
  httpx -silent | \
  nuclei -severity critical,high -o bounty-findings.txt
```

---

## Troubleshooting Common Issues

### Issue 1: "No Templates Found"

**Problem**: Nuclei can't find templates

**Fix:**
```bash
# Update templates
nuclei -update-templates

# Or specify template path explicitly
nuclei -u target.com -t ~/.local/nuclei-templates/
```

### Issue 2: "Too Many Open Files"

**Problem**: Hitting system limits with large target lists

**Fix:**
```bash
# Increase file descriptor limit
ulimit -n 10000

# Reduce concurrency
nuclei -l targets.txt -c 10
```

### Issue 3: Rate Limited by Target

**Problem**: Getting 429 errors or blocked

**Fix:**
```bash
# Slow down scanning
nuclei -l targets.txt -rl 50 -c 10

# Use random delay
nuclei -l targets.txt -rd 1

# Rotate user agents
nuclei -l targets.txt -H "User-Agent: Mozilla/5.0 ..."
```

### Issue 4: False Positives Everywhere

**Problem**: Too much noise in results

**Fix:**
```bash
# Use stricter templates
nuclei -l targets.txt -severity critical,high

# Exclude noisy templates
nuclei -l targets.txt -etags "fuzz,brute-force,info"

# Validate with rescan
nuclei -u target.com -t specific-template.yaml -validate
```

---

## 💰 Level Up: When Open Source Isn't Enough

### Commercial Alternatives That Complement Nuclei

| Tool | Best For | Price | Affiliate Link |
|------|----------|-------|----------------|
| **[Burp Suite](https://cipherops.gitbook.io/bug-bounty-notes/web-application/introducing-20-web-application-hacking-tools) Pro** | Manual testing, advanced fuzzing | $449/year | [Get Burp Pro](AFFILIATE_LINK) |
| **ProjectDiscovery Cloud** | Managed Nuclei infrastructure | $99/mo | [Try Cloud](AFFILIATE_LINK) |
| **Detectify** | Continuous monitoring | Custom | [Learn More](AFFILIATE_LINK) |

**My Recommendation**: Start with Nuclei (free), then add Burp Suite Pro when you need advanced manual testing. The combination is unstoppable.

### Why I Upgraded to Burp Suite Pro

After 6 months with Nuclei, I hit a wall. I needed to:
- Manually inspect responses
- Perform authenticated testing
- Create complex attack sequences

**Burp Pro solved all of this**. It integrates beautifully with Nuclei—use Nuclei for recon, Burp for exploitation.

[**Get Burp Suite Pro - 20% Off**](AFFILIATE_LINK)

---

## Cloud Infrastructure: Power Your Scans

### Recommended VPS for Bug Bounty

**Why You Need a VPS:**
- 24/7 scanning without killing your laptop
- Static IP for consistent results
- More RAM for large-scale scans
- Better bandwidth

**My Top Picks:**

| Provider | Specs | Price | Best For | Link |
|----------|-------|-------|----------|------|
| **DigitalOcean** | 2GB RAM, 1 CPU | $12/mo | Beginners | [$25 Free Credit](AFFILIATE_LINK) |
| **Linode** | 4GB RAM, 2 CPU | $24/mo | Power users | [$100 Free Credit](AFFILIATE_LINK) |
| **Vultr** | 2GB RAM, 1 CPU | $10/mo | Budget option | [$100 Free Credit](AFFILIATE_LINK) |
| **Hetzner** | 8GB RAM, 2 CPU | €5.35/mo | Best value | [Sign Up](AFFILIATE_LINK) |

**Pro Setup on VPS:**
```bash
# Install essentials
sudo apt update && sudo apt install -y golang-go git tmux

# Install Nuclei
go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest

# Setup persistent session
tmux new -s bounty-session

# Run long scans
nuclei -l massive-target-list.txt -o results.txt

# Detach with Ctrl+B, D
# Reattach later: tmux attach -t bounty-session
```

---

## Comparison: Nuclei vs The Competition

| Feature | Nuclei | Burp Suite | Nessus | OpenVAS |
|---------|--------|------------|--------|---------|
| **Price** | Free | $449/year | $2,390/year | Free |
| **Speed** | ⚡⚡⚡⚡⚡ | ⚡⚡⚡ | ⚡⚡ | ⚡⚡ |
| **Templates** | 10,000+ | Built-in | Built-in | 50,000+ |
| **Customization** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ |
| **Bug Bounty Focus** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐ |
| **Community** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ |
| **Learning Curve** | Medium | Steep | Medium | Steep |

**Verdict**: For bug bounty hunting, Nuclei + Burp Suite Pro is the golden combination. Nuclei for automated recon, Burp for manual exploitation.

---

## Quick Reference Cheat Sheet

### Essential Commands

```bash
# Update everything
nuclei -update-templates

# Basic scan
nuclei -u https://target.com

# Multiple targets with severity filter
nuclei -l targets.txt -severity critical,high

# Specific templates only
nuclei -u target.com -t nuclei-templates/http/exposures/

# Rate-limited scan
nuclei -l targets.txt -rl 100 -c 25

# Silent mode
nuclei -l targets.txt -silent -o results.txt

# With statistics
nuclei -l targets.txt -stats -si 10

# Validate templates
nuclei -t custom-template.yaml -validate

# List all templates
nuclei -tl | head -20
```

### Template Categories

```bash
# Exposures (sensitive files, configs)
nuclei-templates/http/exposures/

# Technologies (WordPress, Jenkins, etc.)
nuclei-templates/http/technologies/

# CVEs (known vulnerabilities)
nuclei-templates/http/cves/

# Misconfigurations
nuclei-templates/http/misconfiguration/

# Vulnerabilities (generic)
nuclei-templates/http/vulnerabilities/
```

### Output Formats

```bash
# Plain text
nuclei -l targets.txt -o results.txt

# JSON (for automation)
nuclei -l targets.txt -json-export results.json

# Markdown (for reports)
nuclei -l targets.txt -markdown-export results.md

# SARIF (for CI/CD)
nuclei -l targets.txt -sarif-export results.sarif
```

---

## Pro Tips from the Trenches

### Tip 1: Template Management

Keep your templates organized:

```bash
# Create custom template directory
mkdir -p ~/.local/nuclei-templates/custom/

# Download community templates
git clone https://github.com/projectdiscovery/nuclei-templates.git

# Update weekly (add to cron)
nuclei -update-templates
```

### Tip 2: Scope Compliance

**Always respect scope. Always.**

```bash
# Read scope first
cat scope.txt

# Exclude out-of-scope domains
nuclei -l targets.txt -exclude out-of-scope.txt

# Test one target first
nuclei -u https://test.target.com -severity info
```

### Tip 3: Result Management

```bash
# Organize by date
mkdir -p ~/bounty-results/$(date +%Y-%m-%d)

# Save with timestamps
nuclei -l targets.txt -o ~/bounty-results/$(date +%Y-%m-%d)/findings.txt

# Compare with previous scans
diff old-results.txt new-results.txt
```

### Tip 4: Team Collaboration

```bash
# Share findings in JSON
nuclei -l targets.txt -json-export team-results.json

# Import to your tracker
cat team-results.json | jq '.[] | {template, host, severity}' > summary.txt
```

---

## Summary & Your Next Steps

### What You Learned

✅ Installed Nuclei 4 different ways  
✅ Ran your first vulnerability scan  
✅ Mastered 5+ real-world command scenarios  
✅ Created AI-powered workflows  
✅ Built custom templates  
✅ Integrated with other tools  
✅ Troubleshot common issues  
✅ Understood when to upgrade to paid tools  

### Your Action Plan

**Today:**
1. Install Nuclei using Method 1 or 2
2. Update templates: `nuclei -update-templates`
3. Run your first scan on a test target

**This Week:**
1. Create your first custom template
2. Build a recon pipeline with subfinder + httpx
3. Document 3 findings using Nuclei

**This Month:**
1. Submit your [first bug](https://cipherops.gitbook.io/bug-bounty-notes/readme/embarking-on-your-hacking-journey-a-guide-for-beginners) found with Nuclei
2. Consider upgrading to Burp Suite Pro
3. Set up a VPS for 24/7 scanning

### Recommended Next Reads

- [50 Copy-Paste Commands for Bug Bounty](../02_Reconnaissance/02_50_Copy_Paste_Commands.md)
- [AI-Powered Reconnaissance Guide](../02_Reconnaissance/01_AI_Powered_Reconnaissance.md)
- [Setting Up Your Lab](../01_Getting_Started/03_Setting_Up_Your_Lab.md)

### Get Help

**Stuck?** Join the community:
- [ProjectDiscovery Discord](https://discord.gg/projectdiscovery)
- [Nuclei GitHub Discussions](https://github.com/projectdiscovery/nuclei/discussions)
- [Bug Bounty Forum](https://bugbountyforum.com)

---

## 💡 Upgrade Your Arsenal

### Tools That Work Great With Nuclei

**Cloud VPS for 24/7 Scanning:**
- [DigitalOcean - $25 Free Credit](AFFILIATE_LINK) ← My top pick for beginners
- [Linode - $100 Free Credit](AFFILIATE_LINK) ← Best for power users

**Advanced Testing:**
- [Burp Suite Pro - 20% Off](AFFILIATE_LINK) ← Essential for manual testing
- [PentesterLab Pro](AFFILIATE_LINK) ← Practice vulnerabilities safely

**Automation:**
- [GitHub Copilot](AFFILIATE_LINK) ← Write scripts faster
- [ChatGPT Plus](AFFILIATE_LINK) ← Generate custom templates

---

*Found this guide helpful? Star the [ProjectDiscovery/nuclei](https://github.com/projectdiscovery/nuclei) repo and share this guide with your bug bounty crew. Happy hunting!* 🔍

---

**Last Updated:** February 2024  
**Author:** Your Name  
**Community:** [ProjectDiscovery](https://projectdiscovery.io)  
**License:** This guide is free to share with attribution


---

## 📚 Related Guides
- 🛠️ [Nuclei Complete Guide](01_Nuclei_Complete_Guide.md) — Automated vuln scanning
- 🔍 [Reconnaissance](../reconnaissance/01_AI_Powered_Reconnaissance.md) — Find targets first
- 🌐 [Web Testing](../web-testing/sql-injection-20260316.md) — Next: exploit what you find

---

*Part of the [CipherOps Bug Bounty Notes](https://cipherops.gitbook.io/bug-bounty-notes/) — your guide from zero to first bounty.*

