---
icon: '00'
cover: >-
  https://images.unsplash.com/photo-1624969862644-791f3dc98927?crop=entropy&cs=srgb&fm=jpg&ixid=M3wxOTcwMjR8MHwxfHNlYXJjaHwxMHx8Y3liZXJ8ZW58MHx8fHwxNzczODE4Mjg1fDA&ixlib=rb-4.1.0&q=85
coverY: 0
---

# From Zero to First Bug: The Complete Beginner's Guide

**Skill level:** Beginner\
**Time to complete:** \~24 hours\
**Goal:** Find and report your first valid bug

***

### What you'll achieve

By following this guide, you will set up a bug hunting environment, find your first security vulnerability, write a professional bug report, and submit it to a real bug bounty program. A first valid finding on a paid program typically earns $100–$500, though many beginners start on no-bounty VDPs for the experience.

***

### Timeline breakdown

| Phase                         | Time    | What you'll do                       |
| ----------------------------- | ------- | ------------------------------------ |
| **Hour 0-2:** Setup           | 2 hours | Install tools, configure environment |
| **Hour 2-4:** Learn           | 2 hours | Understand basics, pick a target     |
| **Hour 4-8:** Recon           | 4 hours | Find subdomains and live hosts       |
| **Hour 8-16:** Testing        | 8 hours | Test for vulnerabilities             |
| **Hour 16-20:** Documentation | 4 hours | Write your first report              |
| **Hour 20-24:** Submission    | 4 hours | Submit and follow up                 |

***

### Hour 0-2: Environment setup

#### Step 1: Install Kali Linux (or an alternative)

**Option A — Virtual machine (recommended for beginners)**

```bash
# Download the Kali VM from Offensive Security
# Import into VirtualBox or VMware
# Allocate: 4GB RAM, 2 CPUs, 60GB disk

# Or use Docker
sudo docker pull kalilinux/kali-rolling
sudo docker run -it kalilinux/kali-rolling
```

**Option B — WSL2 on Windows**

```powershell
# In PowerShell (Administrator)
wsl --install -d kali-linux
# Restart, then:
wsl -d kali-linux
```

**Option C — Native installation (advanced)**

Download the ISO from kali.org, create a bootable USB, and install alongside your OS.

#### Step 2: Install essential tools

Save this as `install_tools.sh` and run it:

```bash
#!/bin/bash
echo "[*] Installing bug bounty tools..."

sudo apt update && sudo apt upgrade -y

# Install Go
wget https://go.dev/dl/go1.21.0.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.21.0.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
echo 'export PATH=$PATH:~/go/bin' >> ~/.bashrc
source ~/.bashrc

# Recon tools
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
go install -v github.com/projectdiscovery/naabu/v2/cmd/naabu@latest
go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest
go install -v github.com/ffuf/ffuf@latest

# Wordlists and utilities
sudo apt install -y seclists wordlists nmap dirb gobuster whatweb git curl python3-pip
pip3 install requests beautifulsoup4

echo "[+] Installation complete. Restart your terminal."
```

Then:

```bash
chmod +x install_tools.sh
./install_tools.sh
```

#### Step 3: Configure your environment

```bash
mkdir -p ~/bugbounty/{tools,targets,reports,wordlists}
cd ~/bugbounty

git config --global user.name "Your Name"
git config --global user.email "your@email.com"

echo 'alias bb="cd ~/bugbounty"' >> ~/.bashrc
echo 'alias targets="cd ~/bugbounty/targets"' >> ~/.bashrc
echo 'alias tools="cd ~/bugbounty/tools"' >> ~/.bashrc
source ~/.bashrc
```

#### Step 4: Test your setup

```bash
subfinder -version
httpx -version
nuclei -version
ffuf -V
nmap --version
ping -c 3 google.com
```

If all commands work, you're ready.

***

### Hour 2-4: Understanding the basics

Bug bounty hunting means finding security vulnerabilities in websites and apps, reporting them responsibly to the company, and getting paid for valid findings.

#### Types of bugs, easiest to hardest

**Easier (start here):** information disclosure (exposed sensitive data), clickjacking, missing security headers, weak SSL/TLS configuration.

**Medium:** [Cross-Site Scripting (XSS)](../web-application/the-art-of-xss-exploitation.md), open redirects, [CSRF](../web-application/file-inclusion-csrf-injection-directory-traversal.md), and [IDOR](../web-application/insecure-direct-object-references-open-redirect-request-smuggling.md).

**Harder:** SQL injection, remote code execution, authentication bypass, and business-logic flaws.

#### Pick your first target

Good programs for beginners share a few traits: wide scope, responsive triagers, and tolerance for newcomers. On [HackerOne](bug-bounty-platforms-compared-where-to-hunt-in-2026.md), filter the directory for beginner-friendly programs and avoid ones with strict scope or slow response times. On Bugcrowd, work through Bugcrowd University first, then look at Priority 1–3 programs.

**Recommended first target:** the U.S. Dept of Defense VDP (hackerone.com/deptofdefense). It has very wide scope (.mil domains) and fast triage. There's no payout, but it's an excellent place to learn and build a track record.

***

### Hour 4-8: Reconnaissance

Replace `example.com` with your actual target throughout.

**1. Find subdomains (passive, safe)**

```bash
mkdir -p ~/bugbounty/targets/example.com
cd ~/bugbounty/targets/example.com

subfinder -d example.com -all -silent -o subs.txt
echo "Found $(wc -l < subs.txt) subdomains"
```

**2. Find live hosts**

```bash
httpx -l subs.txt -silent -o live_hosts.txt
cat live_hosts.txt
```

**3. Detect technologies**

```bash
httpx -l live_hosts.txt -tech-detect -silent -o tech.txt
cat tech.txt
```

Then organize your findings so the testing phase is tidy:

```bash
mkdir -p {subdomains,hosts,ports,content}
cp subs.txt subdomains/
cp live_hosts.txt hosts/
```

***

### Hour 8-16: Finding your first bug

Start with low-hanging fruit.

**Bug type 1 — Information disclosure (easiest)**

Look for exposed `.git` directories, backup files (`.bak`, `.old`, `.zip`), config files (`.env`, `config.php`), API docs, and debug output. Test a list of common paths against every live host:

```bash
cat << 'EOF' > test_urls.txt
/.git/config
/.env
/config.php
/config.json
/.htaccess
/robots.txt
/api/
/swagger.json
/backup.zip
/.DS_Store
/admin/
/phpinfo.php
EOF

for host in $(cat live_hosts.txt); do
    for endpoint in $(cat test_urls.txt); do
        status=$(curl -s -o /dev/null -w "%{http_code}" "$host$endpoint")
        if [ "$status" = "200" ]; then
            echo "[+] FOUND: $host$endpoint"
            echo "$host$endpoint" >> findings.txt
        fi
    done
done
```

An exposed `.env` often contains database credentials, API keys, and secret tokens — a high-impact finding.

**Bug type 2 — Cross-Site Scripting (XSS)**

XSS is injecting JavaScript that executes in a victim's browser. The quickest manual test: find an input field (search box, contact form), submit a harmless probe, and check whether it executes rather than being escaped. You can also scan with Nuclei:

```bash
nuclei -l live_hosts.txt -t ~/nuclei-templates/xss/ -silent -o xss_findings.txt
```

For the full payload reference, see [The Art of XSS Exploitation](../web-application/the-art-of-xss-exploitation.md).

**Bug type 3 — IDOR (Insecure Direct Object Reference)**

IDOR is accessing other users' data by changing an identifier in a URL — for example, incrementing `?id=123` to `?id=124` and seeing someone else's record. Pull candidate URLs with numeric parameters and compare responses:

```bash
cat live_hosts.txt | waybackurls | grep -E "\?.*id=[0-9]+" | head -20 > potential_idor.txt
```

***

### Hour 16-20: Writing your first report

A good report has a short summary, precise technical details, clear reproduction steps, a proof of concept, an honest impact assessment, and remediation advice. Use this structure:

```markdown
# Security Report: [Vulnerability Type] on [Target]

## Summary
Brief description of the issue and impact (2-3 sentences)

## Technical Details
- Type: [e.g., Information Disclosure]
- Severity: [Low/Medium/High/Critical]
- Affected URL / parameter / method

## Steps to Reproduce
1. Navigate to [URL]
2. [Action]
3. Observe [result]

## Proof of Concept
[screenshot or short video]

## Impact
What data is exposed, who is affected, and the business risk.

## Remediation
How to fix it.

## References
- [OWASP / CWE links]
```

Keep proof-of-concept screenshots clear and any video under two minutes.

***

### Hour 20-24: Submission and follow-up

On HackerOne, open your target program, click **Submit Report**, and fill in a clear title, the correct weakness category, your severity assessment, the report body, and attachments. After submitting, triage typically takes 0–3 days, an initial response 3–7 days, and resolution anywhere from two to six weeks.

Possible outcomes: **Valid** (accepted, bounty awarded), **Informative** (valid but not bounty-eligible), **Duplicate** (someone reported it first), or **Not Applicable** (out of scope). If you've heard nothing after a week, a short, polite follow-up referencing your report number is appropriate.

***

### Common beginner mistakes

* **Testing without authorization.** Only test programs you're registered for.
* **Not reading scope.** Confirm an asset is in scope before touching it.
* **Aggressive scanning on production.** Check each program's rules on automation.
* **Poor report quality.** Vague reports get closed; clear steps and impact get paid.
* **Giving up too soon.** Most hunting finds nothing; learn from feedback and try again.

***

### Practice targets (safe and legal)

Before testing live programs, sharpen your skills on apps built for it: [PortSwigger Web Security Academy](https://portswigger.net/web-security), OWASP WebGoat, and DVWA (Damn Vulnerable Web App).

```bash
# Run DVWA locally with Docker
docker run -d -p 80:80 vulnerables/web-dvwa
# Access at http://localhost  (login: admin/password)
```

***

### Resources for beginners

**Learning platforms:** [PortSwigger Web Security Academy](https://portswigger.net/web-security) (free), [TryHackMe](https://tryhackme.com), [Hack The Box Academy](https://academy.hackthebox.com), [PentesterLab](https://pentesterlab.com).

**YouTube:** [LiveOverflow](https://www.youtube.com/c/LiveOverflow), [HackerSploit](https://www.youtube.com/c/HackerSploit), [STÖK](https://www.youtube.com/c/STOKfredrik), [NahamSec](https://www.youtube.com/c/NahamSec).

**Books:** _The Web Application Hacker's Handbook_, _Real-World Bug Hunting_, _Bug Bounty Bootcamp_.

**Communities:** #bugbountytips on Twitter, the HackerOne and Bugcrowd Discords, and r/bugbounty.

***

Welcome to bug bounty hunting — now go find some bugs.
