# From Zero to First Bug: The Complete Beginner's Guide

**Skill Level:** 🟢 Beginner  
**Time to Complete:** 24 hours  
**Goal:** Find and report your first valid bug  
**Last Updated:** 2026-02-26

---

## 🎯 What You'll Achieve

By following this guide, you will:
- ✅ Set up a professional bug hunting environment
- ✅ Find your first security vulnerability
- ✅ Write a professional bug report
- ✅ Submit to a real bug bounty program
- ✅ Potentially earn your first bounty ($100-$500 typical)

---

## 📊 Visual Roadmap

![Zero to First Bug Roadmap](images/first-bug-roadmap.png)
*Visual guide: 6 steps from setup to first bounty*

---

## ⏰ Timeline Breakdown

| Phase | Time | What You'll Do |
|-------|------|----------------|
| **Hour 0-2:** Setup | 2 hours | Install tools, configure environment |
| **Hour 2-4:** Learn | 2 hours | Understand basics, pick a target |
| **Hour 4-8:** Recon | 4 hours | Find subdomains and live hosts |
| **Hour 8-16:** Testing | 8 hours | Test for vulnerabilities |
| **Hour 16-20:** Documentation | 4 hours | Write your first report |
| **Hour 20-24:** Submission | 4 hours | Submit and follow up |

---

## Hour 0-2: Environment Setup

### Step 1: Install Kali Linux (or Alternative)

**Option A: Virtual Machine (Recommended for Beginners)**
```bash
# Download Kali VM from Offensive Security
# Import into VirtualBox or VMware
# Allocate: 4GB RAM, 2 CPUs, 60GB disk

# Or use Docker
sudo docker pull kalilinux/kali-rolling
sudo docker run -it kalilinux/kali-rolling
```

**Option B: WSL2 on Windows**
```powershell
# In PowerShell (Administrator)
wsl --install -d kali-linux
# Restart computer, then:
wsl -d kali-linux
```

**Option C: Native Installation (Advanced)**
- Download ISO from kali.org
- Create bootable USB
- Install alongside your OS

### Step 2: Install Essential Tools

Run this automated installation script:

```bash
#!/bin/bash
# save as: install_tools.sh

echo "[*] Installing Bug Bounty Tools..."

# Update system
sudo apt update && sudo apt upgrade -y

# Install Go
wget https://go.dev/dl/go1.21.0.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.21.0.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
echo 'export PATH=$PATH:~/go/bin' >> ~/.bashrc
source ~/.bashrc

# Install recon tools
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
go install -v github.com/projectdiscovery/naabu/v2/cmd/naabu@latest
go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest
go install -v github.com/ffuf/ffuf@latest

# Install wordlists
sudo apt install -y seclists
sudo apt install -y wordlists

# Install other tools
sudo apt install -y nmap
sudo apt install -y dirb
sudo apt install -y gobuster
sudo apt install -y whatweb
sudo apt install -y git
sudo apt install -y curl
sudo apt install -y python3-pip

# Install Python tools
pip3 install requests
pip3 install beautifulsoup4

echo "[+] Installation complete!"
echo "[+] Restart your terminal"
```

**Run it:**
```bash
chmod +x install_tools.sh
./install_tools.sh
```

### Step 3: Configure Your Environment

```bash
# Create workspace
mkdir -p ~/bugbounty/{tools,targets,reports,wordlists}
cd ~/bugbounty

# Set up Git (if you want to save your work)
git config --global user.name "Your Name"
git config --global user.email "your@email.com"

# Create useful aliases
echo 'alias bb="cd ~/bugbounty"' >> ~/.bashrc
echo 'alias targets="cd ~/bugbounty/targets"' >> ~/.bashrc
echo 'alias tools="cd ~/bugbounty/tools"' >> ~/.bashrc
source ~/.bashrc
```

### Step 4: Test Your Setup

```bash
# Verify installations
subfinder -version
httpx -version
nuclei -version
ffuf -V
nmap --version

# Test basic connectivity
ping -c 3 google.com
```

**If all commands work, you're ready!** ✅

---

## Hour 2-4: Understanding the Basics

### What is Bug Bounty Hunting?

Bug bounty hunting is:
- Finding security vulnerabilities in websites/apps
- Reporting them responsibly to companies
- Getting paid for valid findings

### Types of Bugs (Easy to Hard)

**🟢 Easy (Start Here):**
1. **Information Disclosure** - Exposed sensitive data
2. **Clickjacking** - UI redressing attacks
3. **Missing Headers** - Security headers
4. **Weak SSL/TLS** - Certificate issues

**🟡 Medium:**
1. **[Cross-Site Scripting](https://cipherops.gitbook.io/bug-bounty-notes/web-application/the-art-of-[xss](https://cipherops.gitbook.io/bug-bounty-notes/web-application/the-art-of-xss-exploitation)-exploitation) (XSS)** - JavaScript injection
2. **Open Redirects** - Unauthorized redirects
3. **[CSRF](https://cipherops.gitbook.io/bug-bounty-notes/web-application/file-inclusion-csrf-injection-directory-traversal)** - [Cross-site request forgery](https://cipherops.gitbook.io/bug-bounty-notes/web-application/file-inclusion-csrf-injection-directory-traversal)
4. **[IDOR](https://cipherops.gitbook.io/bug-bounty-notes/web-application/insecure-direct-object-references-open-redirect-request-smuggling)** - Insecure direct object references

**🔴 Hard:**
1. **[SQL Injection](https://cipherops.gitbook.io/bug-bounty-notes/web-application/comprehensive-guide-to-web-content-discovery-tools-techniques-and-tips)** - Database attacks
2. **Remote Code Execution** - Server takeover
3. **Authentication Bypass** - Login bypasses
4. **Business Logic** - Workflow flaws

### Pick Your First Target

**Best Programs for Beginners:**

1. **[HackerOne](https://cipherops.gitbook.io/bug-bounty-notes/readme/bug-bounty-platforms-compared-where-to-hunt-in-2026) Directory**
   - Filter: "Beginner friendly"
   - Look for: Wide scope, responsive triagers
   - Avoid: Strict scope, slow response times

2. **[Bugcrowd](https://cipherops.gitbook.io/bug-bounty-notes/readme/bug-bounty-platforms-compared-where-to-hunt-in-2026)**
   - Join "Bugcrowd University" first
   - Look for "Priority 1-3" programs
   - Good: Yahoo, eBay, Netgear

3. **Public Programs with Wide Scope**
   - U.S. Dept of Defense (hackerone.com/deptofdefense)
   - Shopify
   - Uber (select programs)

**🎯 Recommended First Target:**
- **U.S. Dept of Defense VDP**
  - URL: https://hackerone.com/deptofdefense
  - Wide scope (.mil domains)
  - No payout (VDP) but great for learning
  - Fast triage
  - Good for resume

---

## Hour 4-8: Reconnaissance (Finding Targets)

### Step-by-Step Recon

**Target Example:** `example.com` (replace with your actual target)

#### 1. Find Subdomains (Passive - Safe)

```bash
# Create directory for target
mkdir -p ~/bugbounty/targets/example.com
cd ~/bugbounty/targets/example.com

# Run subfinder (passive only)
subfinder -d example.com -all -silent -o subs.txt

# Count what we found
wc -l subs.txt
echo "Found $(wc -l < subs.txt) subdomains!"
```

**Expected Output:**
```
50
Found 50 subdomains!
```

#### 2. Find Live Hosts

```bash
# Check which subdomains are live
httpx -l subs.txt -silent -o live_hosts.txt

# See what we found
cat live_hosts.txt
```

**Expected Output:**
```
https://www.example.com
https://api.example.com
https://blog.example.com
https://dev.example.com
```

#### 3. Technology Detection

```bash
# Detect technologies running on each host
httpx -l live_hosts.txt -tech-detect -silent -o tech.txt

# View results
cat tech.txt
```

**Expected Output:**
```
https://www.example.com [Apache, PHP, jQuery]
https://api.example.com [nginx, Node.js]
https://blog.example.com [WordPress, Apache]
```

### Save Your Work

```bash
# Organize findings
mkdir -p {subdomains,hosts,ports,content}
cp subs.txt subdomains/
cp live_hosts.txt hosts/

# Create summary
cat << EOF > summary.txt
Target: example.com
Date: $(date)
Subdomains Found: $(wc -l < subs.txt)
Live Hosts: $(wc -l < live_hosts.txt)
Technologies: $(cat tech.txt | wc -l) hosts scanned

Next Steps:
1. Test each live host for vulnerabilities
2. Start with informational issues
3. Look for XSS in input fields
4. Check for IDOR in URLs
EOF

cat summary.txt
```

---

## Hour 8-16: Finding Your First Bug

### Strategy: Start with Low-Hanging Fruit

#### Bug #1: Information Disclosure (Easiest)

**What to Look For:**
- Exposed `.git` directories
- Backup files (`.bak`, `.old`, `.zip`)
- Config files (`.env`, `config.php`)
- API documentation
- Debug information

**Test These URLs on Each Host:**

```bash
# Create test list
cat << 'EOF' > test_urls.txt
/.git/config
/.env
/config.php
/config.json
/.htaccess
/robots.txt
/sitemap.xml
/api/
/swagger.json
/openapi.json
/backup.zip
/.DS_Store
/wordpress/wp-config.php
/admin/
/phpinfo.php
EOF

# Test each live host
for host in $(cat live_hosts.txt); do
    echo "[*] Testing: $host"
    for endpoint in $(cat test_urls.txt); do
        status=$(curl -s -o /dev/null -w "%{http_code}" "$host$endpoint")
        if [ "$status" = "200" ]; then
            echo "[+] FOUND: $host$endpoint (Status: $status)"
            echo "$host$endpoint" >> findings.txt
        fi
    done
done
```

**Finding Example:**
```
[+] FOUND: https://dev.example.com/.env (Status: 200)
```

**Impact:** Exposed environment variables often contain:
- Database credentials
- API keys
- Secret tokens
- Internal URLs

#### Bug #2: Cross-Site Scripting (XSS)

**What is XSS?**
Injecting JavaScript into web pages that executes in victim's browser.

**Simple Test (Reflected XSS):**

1. Find any input field (search box, contact form, etc.)
2. Enter: `<script>alert('XSS')</script>`
3. Submit and check if alert pops up

**Automated Testing with Nuclei:**

```bash
# Run XSS templates on all hosts
nuclei -l live_hosts.txt -t ~/nuclei-templates/xss/ -silent -o xss_findings.txt

# Check results
cat xss_findings.txt
```

**Manual Testing Script:**

```bash
# Test for basic XSS
test_xss() {
    url=$1
    payload="<script>alert('XSS')</script>"
    
    # Test in URL parameter
    response=$(curl -s "$url/?search=$payload")
    
    if echo "$response" | grep -q "$payload"; then
        echo "[+] Potential XSS: $url"
        echo "$url" >> xss_potential.txt
    fi
}

# Test each host
for host in $(cat live_hosts.txt); do
    test_xss "$host"
done
```

#### Bug #3: IDOR (Insecure Direct Object Reference)

**What is IDOR?**
Accessing other users' data by changing IDs in URLs.

**Example:**
```
# Your account page
https://example.com/user.php?id=123

# Try changing ID
https://example.com/user.php?id=124
https://example.com/user.php?id=125

# If you see other users' data = IDOR bug!
```

**Automated Test:**

```bash
# Find URLs with numeric parameters
cat live_hosts.txt | waybackurls | grep -E "\?.*id=[0-9]+" | head -20 > potential_idor.txt

# Test each
for url in $(cat potential_idor.txt); do
    # Get original
    original=$(curl -s "$url")
    
    # Change ID
    new_url=$(echo "$url" | sed 's/id=[0-9]*/id=9999/')
    test=$(curl -s "$new_url")
    
    # Compare
    if [ "$original" != "$test" ] && [ -n "$test" ]; then
        echo "[+] Potential IDOR: $url"
        echo "$url" >> idor_findings.txt
    fi
done
```

---

## Hour 16-20: Writing Your First Report

### Report Structure

**Template:**

```markdown
# Security Report: [Vulnerability Type] on [Target]

## Executive Summary
Brief description of the issue and impact (2-3 sentences)

## Technical Details

### Vulnerability
- **Type:** [e.g., Information Disclosure]
- **Severity:** [Low/Medium/High/Critical]
- **CVSS Score:** [if known]

### Affected Endpoint
- URL: [full URL]
- Parameter: [if applicable]
- HTTP Method: [GET/POST/etc]

### Steps to Reproduce
1. Navigate to [URL]
2. [Action 1]
3. [Action 2]
4. Observe [result]

### Proof of Concept
[screenshot or video]

### Impact
- What data is exposed?
- Who is affected?
- What's the business risk?

### Remediation
How to fix this issue:
1. [Step 1]
2. [Step 2]

### References
- [OWASP Link]
- [CWE Link]
- [Related articles]

## Additional Notes
[Any other relevant information]

---
Reporter: [Your Name]
Date: [Date]
Twitter: [@YourHandle]
```

### Example Report (Information Disclosure)

```markdown
# Security Report: Exposed .env File on dev.example.com

## Executive Summary
The development subdomain at dev.example.com exposes a .env file 
containing sensitive configuration data including database credentials 
and API keys.

## Technical Details

### Vulnerability
- **Type:** Information Disclosure
- **Severity:** High
- **CVSS Score:** 7.5

### Affected Endpoint
- URL: https://dev.example.com/.env
- HTTP Method: GET

### Steps to Reproduce
1. Navigate to https://dev.example.com/.env
2. Observe the .env file is accessible without authentication
3. File contains DB_HOST, DB_PASSWORD, API_KEY, and other secrets

### Proof of Concept
[Screenshot showing .env file contents]

### Impact
- Database credentials exposed
- API keys for third-party services visible
- Potential for data breach
- Unauthorized system access possible

### Remediation
1. Remove .env file from web root
2. Move configuration files outside public directory
3. Add .env to .gitignore
4. Rotate all exposed credentials immediately
5. Implement proper access controls

### References
- https://owasp.org/www-project-top-ten/2017/A3_2017-Sensitive_Data_Exposure
- https://cwe.mitre.org/data/definitions/200.html

---
Reporter: John Doe
Date: 2026-02-26
Twitter: @johndoe
```

### Creating Proof of Concept

**Screenshots:**
```bash
# Install screenshot tool
sudo apt install -y gnome-screenshot

# Take screenshot
gnome-screenshot -f poc_screenshot.png

# Or use browser extension (Firefox/Chrome)
# "FireShot" or "Awesome Screenshot"
```

**Screen Recording (Video):**
```bash
# Install simplescreenrecorder
sudo apt install -y simplescreenrecorder

# Record reproduction steps
# Keep under 2 minutes
# Show the entire process
```

---

## Hour 20-24: Submission and Follow-Up

### Submitting on HackerOne

1. **Log in** to https://hackerone.com
2. **Navigate** to your target program
3. **Click** "Submit Report"
4. **Fill in:**
   - Title: Clear and descriptive
   - Weakness: Select appropriate category
   - Severity: Your assessment
   - Description: Use your report template
   - Attachments: Screenshots/videos
5. **Submit**

### What Happens Next?

**Timeline:**
- **0-3 days:** Triage review
- **3-7 days:** Initial response
- **1-4 weeks:** Investigation
- **2-6 weeks:** Resolution and bounty

**Possible Outcomes:**
- ✅ **Valid** - Bug accepted, bounty awarded
- ⚠️ **Informative** - Valid but not bounty-eligible
- ❌ **Duplicate** - Someone reported first
- ❌ **Not Applicable** - Out of scope or not a bug
- ❌ **Spam** - Invalid submission

### Following Up

**After 1 week (if no response):**
```
Hi [Triager Name],

I'm following up on my report #[NUMBER] submitted on [DATE].
The issue is [BRIEF DESCRIPTION].

Could you please provide an update on the triage status?

Thanks,
[Your Name]
```

**Be patient but persistent.** Professional communication is key.

---

## 🎉 Congratulations!

**You've completed your first bug bounty hunt!**

### What to Do Next

1. **Celebrate** 🎉 - You did it!
2. **Document** what you learned
3. **Share** your experience (if allowed)
4. **Start** your next hunt
5. **Build** your reputation

### Building Your Reputation

**Tips:**
- Submit quality reports consistently
- Help triagers understand the issue
- Be professional and patient
- Share knowledge with community
- Build your online presence

**Track Your Progress:**
```bash
# Create tracking spreadsheet
cat << 'EOF' > ~/bugbounty/tracking.csv
Date,Program,Vulnerability,Status,Bounty,Notes
2026-02-26,Example Corp,Info Disclosure,New,Pending,First submission!
EOF

# Update after each submission
```

---

## 💡 Pro Tips for Success

### Tip 1: Start Small
- Don't target Google or Facebook first
- Begin with VDPs (Vulnerability Disclosure Programs)
- Look for "beginner friendly" tags

### Tip 2: Focus on One Bug Type
- Master XSS first, then move to IDOR
- Deep knowledge > broad knowledge
- Become the "XSS expert"

### Tip 3: Document Everything
- Save all commands you run
- Screenshot everything
- Keep notes on what worked

### Tip 4: Learn from Others
- Read public reports on HackerOne
- Follow bug hunters on Twitter
- Join Discord communities

### Tip 5: Be Persistent
- 90% of hunting is finding nothing
- That 10% pays for everything
- Consistency beats intensity

---

## 📚 Resources for Beginners

### Free Learning Platforms
- [PortSwigger Web Security Academy](https://portswigger.net/web-security) - FREE
- [TryHackMe](https://tryhackme.com) - Free tier available
- [Hack The Box Academy](https://academy.hackthebox.com) - Free tier
- [PentesterLab](https://pentesterlab.com) - Some free exercises

### YouTube Channels
- [LiveOverflow](https://www.youtube.com/c/LiveOverflow) - Technical deep dives
- [HackerSploit](https://www.youtube.com/c/HackerSploit) - Practical tutorials
- [STÖK](https://www.youtube.com/c/STOKfredrik) - Bug bounty focused
- [NahamSec](https://www.youtube.com/c/NahamSec) - Recon methodology

### Books (Free/Paid)
- "The Web Application Hacker's Handbook" - Classic
- "Real-World Bug Hunting" - Practical examples
- "Bug Bounty Bootcamp" - Beginner friendly

### Communities
- **Twitter:** #bugbountytips
- **Discord:** HackerOne Discord, Bugcrowd Discord
- **Reddit:** r/bugbounty, r/netsec

---

## ⚠️ Common Beginner Mistakes

### Mistake #1: Testing Without Authorization
**❌ DON'T:** Test random websites
**✅ DO:** Only test programs you're registered for

### Mistake #2: Not Reading Scope
**❌ DON'T:** Test out-of-scope assets
**✅ DO:** Carefully read scope before starting

### Mistake #3: Automated Scanning on Production
**❌ DON'T:** Run aggressive scans without permission
**✅ DO:** Check program rules about automation

### Mistake #4: Poor Report Quality
**❌ DON'T:** Submit vague reports
**✅ DO:** Clear steps, screenshots, impact explanation

### Mistake #5: Giving Up Too Soon
**❌ DON'T:** Quit after first rejection
**✅ DO:** Learn from feedback, try again

---

## 🎯 Practice Targets (Safe & Legal)

### Test These Without Fear:
1. **PortSwigger Web Security Academy**
   - https://portswigger.net/web-security
   - Designed for learning
   - No authorization needed

2. **OWASP WebGoat**
   - Intentionally vulnerable app
   - Run locally
   - Safe to break

3. **DVWA (Damn Vulnerable Web App)**
   - Practice SQL injection, XSS
   - Local installation
   - Learn safely

### Installation:
```bash
# Install DVWA with Docker
docker run -d -p 80:80 vulnerables/web-dvwa

# Access at http://localhost
# Login: admin/password
```

---

## 📈 Your First 90 Days

### Week 1-2: Foundation
- Set up environment ✓
- Complete this guide ✓
- Submit 1-2 reports

### Week 3-4: Practice
- Do PortSwigger labs
- Read 10 public reports
- Submit 2-3 more reports

### Month 2: Specialization
- Pick one bug type (e.g., XSS)
- Master it completely
- Submit 5-10 reports

### Month 3: Automation
- Build recon automation
- Create testing scripts
- Scale your efforts

**Goal:** First bounty within 90 days!

---

## 🏆 Success Metrics

**Track These:**
- Reports submitted: ___
- Valid bugs: ___
- Bounties earned: $___
- Programs joined: ___
- Skills learned: ___

**Set Goals:**
- Week 1: Submit first report
- Month 1: Get first valid triage
- Month 3: Earn first bounty
- Month 6: $1000 total earnings
- Year 1: $10,000 total earnings

---

## 📞 Getting Help

**Stuck? Ask for help:**
- HackerOne Support
- Twitter #bugbountytips
- Discord communities
- This guide's GitHub issues

**Remember:** Everyone was a beginner once!

---

**You did it! Welcome to bug bounty hunting! 🐛💰**

*Now go find some bugs!*

---

*Last Updated: 2026-02-26*  
*Next: [AI-Powered Reconnaissance →](01_AI_Powered_Reconnaissance.md)*


---

## 📚 Related Guides
- 🚀 [Bug Bounty Platforms Compared](02_Bug_Bounty_Platforms_Compared.md) — Pick the right platform
- 🛠️ [Setting Up Your Lab](03_Setting_Up_Your_Lab.md) — Build your hacking environment
- 🔍 [AI-Powered Reconnaissance](../reconnaissance/01_AI_Powered_Reconnaissance.md) — Next: start finding targets

---

*Part of the [CipherOps Bug Bounty Notes](https://cipherops.gitbook.io/bug-bounty-notes/) — your guide from zero to first bounty.*

