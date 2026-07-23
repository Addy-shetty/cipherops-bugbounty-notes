---
icon: question
cover: >-
  https://images.unsplash.com/photo-1676282824476-ed6148e7c28a?crop=entropy&cs=srgb&fm=jpg&ixid=M3wxOTcwMjR8MHwxfHNlYXJjaHwyfHxob3d8ZW58MHx8fHwxNzc0MjQ1OTAxfDA&ixlib=rb-4.1.0&q=85
coverY: 0
---

# How-To Guide: Setting Up Your First Bug Bounty Lab

**Skill Level:** Beginner\
**Time to Complete:** 60 minutes\
**Cost:** $0 (using free tools)\
**Goal:** Create a safe environment to practice hacking

***

### Why You Need a Lab

**The Problem:**

* Can't practice on real targets without permission
* Risk of legal issues if you test on production
* Need safe environment to experiment
* Must learn tools without breaking things

**The Solution:** Your own vulnerable lab environment where you can:

* Practice legally and safely
* Break things without consequences
* Learn at your own pace
* Test tools and techniques
* Build confidence before real targets

***

### Lab Architecture

```
┌─────────────────────────────────────┐
│         Your Computer               │
│  ┌─────────────────────────────┐   │
│  │   Kali Linux VM              │   │
│  │   ├─ Burp Suite              │   │
│  │   ├─ Nmap                    │   │
│  │   ├─ Nuclei                  │   │
│  │   └─ Custom tools            │   │
│  └─────────────────────────────┘   │
│              │                      │
│              ▼                      │
│  ┌─────────────────────────────┐   │
│  │   Vulnerable Targets         │   │
│  │   ├─ OWASP Juice Shop        │   │
│  │   ├─ DVWA                    │   │
│  │   ├─ WebGoat                 │   │
│  │   └─ VulnHub VMs             │   │
│  └─────────────────────────────┘   │
└─────────────────────────────────────┘
```

***

### Step 1: Install Virtualization Software

#### Option A: VirtualBox (FREE - Recommended for Beginners)

**Download:**

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install virtualbox

# macOS
brew install --cask virtualbox

# Windows
# Download from: https://www.virtualbox.org/wiki/Downloads
```

**Verify Installation:**

```bash
vboxmanage --version
# Should show version number
```

#### Option B: VMware Workstation Player (FREE for Personal Use)

**Download:** https://www.vmware.com/products/workstation-player.html

#### Option C: VMware Fusion (macOS - Free for Personal Use)

**Download:** https://www.vmware.com/products/fusion.html

***

### Step 2: Download Kali Linux VM

#### Pre-built VM (Fastest - 15 minutes)

**Download:**

```bash
# Download from Offensive Security
wget https://kali.download/virtual-images/kali-linux-2024.1-vmware-amd64.7z

# Or browser: https://www.kali.org/get-kali/#kali-virtual-machines
```

**Extract and Import:**

```bash
# Install 7zip if needed
sudo apt install p7zip-full

# Extract
7z x kali-linux-2024.1-vmware-amd64.7z

# Import into VirtualBox/VMware
# File → Import Appliance → Select .ova file
```

**Default Credentials:**

```
Username: kali
Password: kali
```

#### Manual Installation (Customizable - 45 minutes)

If you want to customize:

1. Download Kali ISO: https://www.kali.org/get-kali/#kali-installer-images
2. Create new VM in VirtualBox
3. Allocate: 4GB RAM, 2 CPU cores, 80GB disk
4. Boot from ISO and install

***

### Step 3: Configure Kali Linux

#### First Boot Setup

**1. Update System:**

```bash
sudo apt update && sudo apt full-upgrade -y
# This takes 10-30 minutes
```

**2. Install Essential Tools:**

```bash
# Bug bounty essentials
sudo apt install -y \
    git \
    python3-pip \
    golang \
    jq \
    nmap \
    masscan \
    dirb \
    gobuster \
    wfuzz \
    sqlmap \
    nikto \
    whatweb
```

**3. Install Burp Suite Community Edition:**

```bash
# Already installed in Kali!
# Just run:
burp-suite

# Or find in Applications → Web Application Analysis
```

**4. Configure Burp Proxy:**

```bash
# In Burp Suite:
# 1. Proxy → Options → Proxy Listeners → Add
# 2. Bind to port: 8080
# 3. Bind to address: All interfaces
# 4. Click OK

# In Firefox (on your host):
# 1. Settings → Network Settings → Manual Proxy
# 2. HTTP Proxy: 127.0.0.1:8080
# 3. Check "Use this proxy for all protocols"
```

**5. Install Additional Tools:**

```bash
# ProjectDiscovery tools
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest
go install -v github.com/projectdiscovery/naabu/v2/cmd/naabu@latest

# Update Nuclei templates
nuclei -update-templates

# Add to PATH
echo 'export PATH=$PATH:~/go/bin' >> ~/.zshrc
source ~/.zshrc
```

***

### Step 4: Set Up Vulnerable Targets

#### Target 1: OWASP Juice Shop (Web App)

**What:** Modern vulnerable web application\
**Vulnerabilities:** OWASP Top 10, business logic flaws\
**Best For:** Beginners to advanced

**Installation (Docker):**

```bash
# Install Docker if not present
sudo apt install docker.io

# Run Juice Shop
docker run --rm -p 3000:3000 bkimminich/juice-shop

# Access at: http://localhost:3000
```

**Hacking Challenges:**

* SQL Injection (login bypass)
* XSS (stored, reflected, DOM)
* Authentication bypass
* Business logic flaws
* XXE injection

#### Target 2: DVWA (Damn Vulnerable Web App)

**What:** Classic vulnerable PHP application\
**Vulnerabilities:** SQLi, XSS, CSRF, File Upload\
**Best For:** Learning basics

**Installation:**

```bash
# Run with Docker
docker run --rm -p 8080:80 vulnerables/web-dvwa

# Access at: http://localhost:8080
# Login: admin / password
```

**Difficulty Levels:**

* Low: Vulnerable code (learn the basics)
* Medium: Some sanitization (learn bypasses)
* High: Secure code (learn what good looks like)

#### Target 3: WebGoat

**What:** OWASP learning platform\
**Best For:** Structured learning path

**Installation:**

```bash
docker run -p 8080:8080 -t webgoat/webgoat

# Access at: http://localhost:8080/WebGoat
```

#### Target 4: VulnHub VMs

**What:** Downloadable vulnerable machines\
**Best For:** Full system compromise practice

**Popular VMs:**

* **Mr. Robot** (Easy) - Based on TV show
* **Metasploitable 2** (Medium) - Multiple services
* **Kioptrix Level 1** (Easy) - Classic beginner VM

**Setup:**

1. Download from: https://www.vulnhub.com/
2. Import .ova into VirtualBox
3. Set network to "Internal Network"
4. Find IP with `netdiscover` or `nmap`

***

### Step 5: Network Configuration

#### Isolate Your Lab (Security!)

**Why:**

* Prevents accidental scanning of your real network
* Keeps vulnerable machines contained
* Allows safe exploitation

**VirtualBox Setup:**

```
1. File → Preferences → Network → Host-only Networks
2. Create new host-only adapter (vboxnet0)
3. Assign IP range: 192.168.56.0/24

4. For each VM:
   Settings → Network → Adapter 1 → Host-only Adapter
   Select: vboxnet0
```

**Verify Isolation:**

```bash
# From Kali VM
ping 192.168.56.1  # Should work (host)
ping 192.168.1.1   # Should NOT work (real network)
```

***

### Step 6: First Hacking Session

#### Let's Hack Juice Shop!

**Goal:** Find 5 vulnerabilities

**1. Login Bypass (SQL Injection)**

```
# Go to: http://localhost:3000/#/login

Email: ' OR '1'='1'--
Password: anything

# Result: Logged in as admin!
```

**2. XSS (Stored)**

```
# Go to: Contact Us page

Enter in comment:
<script>alert('XSS')</script>

# Result: JavaScript executes when admin views it
```

**3. Find Admin Panel**

```bash
# Use gobuster to find hidden pages
gobuster dir -u http://localhost:3000 -w /usr/share/wordlists/dirb/common.txt

# Look for:
# /admin
# /api
# /ftp
```

**4. Access FTP**

```
# Navigate to: http://localhost:3000/ftp/
# Download confidential documents
```

**5. Business Logic Flaw**

```
# Add negative quantity to cart
# Result: Store pays YOU!
```

***

### Daily Practice Routine

#### 30-Minute Practice Session

```
0:00 - 0:05   Pick a vulnerability type to practice
0:05 - 0:15   Read about it (PortSwigger Academy)
0:15 - 0:25   Practice on Juice Shop/DVWA
0:25 - 0:30   Document what you learned
```

#### Weekly Goals

**Week 1:**

* [ ] Set up lab (this guide!)
* [ ] Complete 5 Juice Shop challenges
* [ ] Learn Burp Suite basics

**Week 2:**

* [ ] Practice SQL Injection (10 variations)
* [ ] Master XSS (3 types)
* [ ] Complete 10 more challenges

**Week 3:**

* [ ] Solve first VulnHub VM
* [ ] Practice with real-world tools (Nuclei, Nmap)
* [ ] Document methodology

**Week 4:**

* [ ] Attempt first real bug bounty program
* [ ] Focus on low-hanging fruit
* [ ] Submit first report

***

### Pro Tips

💡 **Tip #1: Take Screenshots**

```bash
# Document everything
# Use: Flameshot or Shutter
sudo apt install flameshot
```

💡 **Tip #2: Keep Notes**

```bash
# Use Obsidian or CherryTree
# Organize by:
# - Vulnerability type
# - Tools used
# - Lessons learned
# - Payloads that worked
```

💡 **Tip #3: Snapshot VMs**

```
VirtualBox:
1. Machine → Take Snapshot
2. Name it: "Clean Install"
3. Restore anytime you break things
```

💡 **Tip #4: Backup Your Progress**

```bash
# Save important files
cp -r ~/reports ~/lab-backup/
cp -r ~/notes ~/lab-backup/
cp -r ~/payloads ~/lab-backup/
```

💡 **Tip #5: Join Communities**

* Discord: Bug Bounty Hunter Methodology
* Reddit: r/bugbounty
* Telegram: https://t.me/bugbounty\_tech

***

### Troubleshooting

#### Problem: Can't Access Targets

```bash
# Check if Docker is running
sudo systemctl start docker

# Check network settings
ip addr show

# Verify port forwarding
docker ps
```

#### Problem: Burp Suite Not Working

```bash
# Check if proxy is running
netstat -tlnp | grep 8080

# Reset Burp config
rm -rf ~/.BurpSuite/
```

#### Problem: VM Won't Start

```bash
# Check virtualization is enabled in BIOS
# Enable Intel VT-x / AMD-V in BIOS settings

# Check disk space
df -h
```

***

### Resources

#### Learning Platforms

* **PortSwigger Web Security Academy** (FREE)
* **Hack The Box Academy** (FREE tier)
* **TryHackMe** (FREE tier)
* **Cybrary** (FREE courses)

#### Practice Targets

* **OWASP Juice Shop**
* **DVWA**
* **WebGoat**
* **VulnHub**
* **Hack The Box**
* **TryHackMe**

#### Tools Reference

* **Kali Tools:** https://www.kali.org/tools/
* **Bug Bounty Toolkit:** https://github.com/ZephrFish/BugBountyToolkit

***

### Next Steps

**After completing this guide:**

1. ✅ Practice daily (even 30 minutes helps!)
2. ✅ Complete all Juice Shop challenges
3. ✅ Solve 3 VulnHub VMs
4. ✅ Learn one new tool per week
5. ✅ Join bug bounty communities
6. ✅ Read disclosed reports on HackerOne
7. ✅ Start with safe programs (VDP)

**Remember:** Every expert was once a beginner. Your lab is where you build the skills that earn real bounties!

***

_Published: 2024-02-29_\
&#xNAN;_&#x4C;ast Updated: 2024-02-29_\
&#xNAN;_&#x54;arget Audience: Beginners_\
&#xNAN;_&#x41;uthor: CipherOps Team_

***

**Lab set up?** Share your progress with us on [Telegram](https://t.me/bugbounty_tech)!
