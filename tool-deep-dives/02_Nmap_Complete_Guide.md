# Nmap: The Network Mapper That Never Gets Old

## The Room Where It All Started

Picture this: A dark room, three monitors glowing, and me staring at a `/24` subnet wondering which of these 254 hosts were actually alive. I was manually pinging each one. Three hours in, I had found 12 hosts and lost all feeling in my wrist. That's when my mentor walked in, laughed, and typed five characters: `nmap -sn`.

Twenty seconds later, I had the full picture. All 47 live hosts. Port 22 on most. Port 80 on 12. Port 3306 exposed on three (yikes). I found my [first bug](https://cipherops.gitbook.io/bug-bounty-notes/readme/embarking-on-your-hacking-journey-a-guide-for-beginners) that night—a misconfigured MySQL with no password.

Nmap didn't just save me time; it saved my sanity and kickstarted my bug bounty career. This guide is everything I wish someone had handed me before I wore out my wrist.

---

## What is Nmap and Why Is It Everywhere?

Nmap (Network Mapper) is the Swiss Army knife of network discovery. Created by Gordon Lyon (Fyodor) in 1997, it's been the industry standard for 25+ years. It's not just a port scanner—it's a complete network [reconnaissance](https://cipherops.gitbook.io/bug-bounty-notes/recon-tips) toolkit.

### Why Nmap Dominates

1. **Universal**: Works on every OS, scans every protocol
2. **Fast**: Scan thousands of hosts in minutes with proper tuning
3. **Scriptable**: 600+ NSE (Nmap Scripting Engine) scripts for everything
4. **Accurate**: OS fingerprinting, service version detection, timing controls
5. **Battle-tested**: Used by millions, trusted by governments

**Real Talk**: I use Nmap on every single engagement. Every. Single. One. It's the first tool in my arsenal and the last one I close.

---

## Installation: You're Probably Already Done

### Method 1: Pre-installed (Most Linux Distros)

```bash
# Check if you already have it
nmap --version

# Update to latest
sudo apt update && sudo apt install nmap  # Debian/Ubuntu
sudo yum install nmap                      # RHEL/CentOS
sudo pacman -S nmap                        # Arch
```

**Pro Tip**: Most Kali Linux and penetration testing distros include Nmap by default. Check first before installing!

### Method 2: macOS (Homebrew)

```bash
# Install with Homebrew
brew install nmap

# Verify
nmap --version
```

**Screenshot Placeholder**: Terminal showing successful installation
```
[INSERT SCREENSHOT: nmap-installation.png]
Show: nmap --version output with version info and platform
```

### Method 3: Windows (Official Installer)

```powershell
# Download from https://nmap.org/download.html
# Run nmap-<version>-setup.exe
# Add to PATH: C:\Program Files (x86)\Nmap

# Verify in Command Prompt
nmap --version
```

### Method 4: Source Compilation (Advanced)

```bash
# For the absolute latest features
git clone https://github.com/nmap/nmap.git
cd nmap
./configure
make
sudo make install
```

---

## Quick Start: Your First Scan in 60 Seconds

### Step 1: Basic Host Discovery

```bash
# Ping scan - find live hosts without port scanning
nmap -sn 192.168.1.0/24

# Scan a single target
nmap target.com

# Scan multiple targets
nmap target1.com target2.com target3.com
```

**What just happened?** Nmap sent ICMP echo requests (pings) to discover which hosts are up. The `-sn` flag skips port scanning—perfect for quick recon.

### Step 2: Your First Port Scan

```bash
# Default scan: Top 1000 ports
nmap target.com

# Scan all 65,535 ports (slow but thorough)
nmap -p- target.com

# Scan specific ports
nmap -p 22,80,443,8080 target.com
```

**Screenshot Placeholder**: First port scan results
```
[INSERT SCREENSHOT: nmap-first-scan.png]
Show: Nmap scan output showing open ports and services
```

### Step 3: Understanding the Output

```
Starting Nmap 7.94 ( https://nmap.org ) at 2024-02-27 14:30 EST
Nmap scan report for target.com (93.184.216.34)
Host is up (0.045s latency).
Not shown: 995 filtered tcp ports (no-response)
PORT     STATE SERVICE
22/tcp   open  ssh
80/tcp   open  http
443/tcp  open  https
3306/tcp open  mysql
8080/tcp open  http-proxy

Nmap done: 1 IP address (1 host up) scanned in 12.34 seconds
```

**What this means:**
- **STATE**: open (accessible), closed (accessible but no service), filtered (firewalled)
- **SERVICE**: Nmap's best guess based on port number
- **Latency**: Network response time
- **filtered**: Could mean firewall, could mean something interesting to investigate

---

## Real-World Command Examples

### Scenario 1: Bug Bounty Scope Recon

This is my bread and butter—mapping a new scope quickly:

```bash
# Discover live hosts in a subnet
nmap -sn 192.168.1.0/24 -oG live-hosts.txt

# Aggressive scan on discovered hosts
nmap -A -iL live-hosts.txt -oN detailed-scan.txt

# Explanation:
# -sn: Ping scan only (fast host discovery)
# -oG: Greppable output for scripting
# -A: Aggressive (OS detection, version detection, script scanning, traceroute)
# -iL: Input from file
# -oN: Normal output to file
```

**Real Example Output:**
```
Host: 192.168.1.10 ()
Ports: 22/open/tcp//ssh///, 80/open/tcp//http///, 443/open/tcp//https///
OS: Linux 3.10 - 4.11
```

### Scenario 2: Stealthy Scanning (Avoiding Detection)

```bash
# Slow scan to evade detection
nmap -sS -T2 --max-retries 1 target.com

# Fragment packets to bypass simple firewalls
nmap -sS -f target.com

# Use decoys to hide your real IP
nmap -sS -D RND:10 target.com

# Explanation:
# -sS: SYN scan (half-open, stealthier)
# -T2: Timing template (sneaky/slow)
# -f: Fragment packets
# -D: Decoy scan with random IPs
```

**Why this matters**: Many bug bounty programs have IDS/IPS. Scanning too aggressively can get your IP banned or trigger incident response.

### Scenario 3: Service Version Detection

```bash
# Detect service versions (crucial for vulnerability matching)
nmap -sV target.com

# Aggressive version detection
nmap -sV --version-intensity 5 target.com

# Scan with version detection and OS fingerprinting
nmap -sV -O target.com
```

**Output Example:**
```
PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 8.2p1 Ubuntu 4ubuntu0.5 (Ubuntu Linux; protocol 2.0)
80/tcp open  http    Apache httpd 2.4.41 ((Ubuntu))
```

**Pro Tip**: Version numbers are gold. "Apache 2.4.41" tells you exactly which CVEs to check.

### Scenario 4: Comprehensive Web Server Scan

```bash
# Web-focused scan with scripts
nmap -sV -sC -p 80,443,8080,8443 target.com

# Scan with all HTTP-related NSE scripts
nmap -sV --script=http-* target.com

# Specific vulnerability scan
nmap --script vuln target.com
```

### Scenario 5: UDP Scanning (Often Forgotten)

```bash
# UDP scan (DNS, SNMP, etc.)
nmap -sU -p 53,161,162 target.com

# Common UDP ports quickly
nmap -sU --top-ports 100 target.com

# Explanation:
# -sU: UDP scan (much slower than TCP)
# UDP often exposes SNMP, DNS issues
```

---

## AI-Powered Workflows: Work Smarter

### Workflow 1: AI-Assisted Target Prioritization

```bash
# Scan and save results
nmap -A target.com -oX scan-results.xml

# Then ask AI to analyze:
# "Based on these Nmap results, which services should I prioritize for 
#  bug bounty hunting? Rank by likelihood of vulnerabilities."
```

**AI Analysis Example:**
```
Priority 1: Port 3306 (MySQL) - Check for weak/default credentials
Priority 2: Port 22 (SSH) - Verify OpenSSH version for CVE-2023-XXXX
Priority 3: Port 80/443 (HTTP) - Standard web app testing
```

### Workflow 2: Automated Script Selection

```bash
# Detect services first
nmap -sV target.com -oG services.txt

# AI suggests relevant NSE scripts:
# "Services detected: SSH (OpenSSH 8.2), HTTP (Apache 2.4)
#  Recommended scripts: ssh-auth-methods, http-title, http-methods"

# Run suggested scripts
nmap --script ssh-auth-methods,http-title,http-methods target.com
```

### Workflow 3: Vulnerability Correlation

```bash
# Full scan with all bells and whistles
nmap -A --script vuln target.com -oN full-scan.txt

# Extract versions and ask AI:
# "These services were found: [paste output]
#  List known CVEs and exploitation methods for each."
```

---

## Advanced Techniques for Serious Hunters

### Technique 1: Timing and Performance Tuning

```bash
# Aggressive timing (faster but noisier)
nmap -T5 target.com

# Polite timing (slower, stealthier)
nmap -T2 target.com

# Custom timing
nmap --min-rate 1000 --max-retries 2 target.com

# Scan 1000 hosts in parallel
nmap -iL targets.txt -T4 --max-parallelism 100
```

**Timing Templates:**
- **T0 (Paranoid)**: Very slow, IDS evasion
- **T1 (Sneaky)**: Slow, avoid detection
- **T2 (Polite)**: Slow down to save bandwidth
- **T3 (Normal)**: Default, balanced
- **T4 (Aggressive)**: Fast, assume good network
- **T5 (Insane)**: Very fast, may miss things

### Technique 2: NSE Script Mastery

**Essential Scripts for Bug Bounty:**

```bash
# HTTP enumeration
nmap --script http-title,http-headers,http-methods target.com

# SSL/TLS analysis
nmap --script ssl-cert,ssl-enum-ciphers,ssl-heartbleed target.com

# Vulnerability scanning
nmap --script vuln target.com

# SMB enumeration (Windows targets)
nmap --script smb-os-discovery,smb-enum-shares target.com

# DNS enumeration
nmap --script dns-brute,dns-zone-transfer target.com
```

**Custom Script Workflow:**

```bash
# Create a custom script
mkdir -p ~/.nmap/scripts/

# Save as ~/.nmap/scripts/custom-http-check.nse
```

```lua
-- Custom HTTP check script
local http = require "http"
local shortport = require "shortport"

description = [[Custom check for exposed admin panels]]

portrule = shortport.http

action = function(host, port)
  local paths = {"/admin", "/administrator", "/wp-admin", "/panel"}
  
  for _, path in ipairs(paths) do
    local response = http.get(host, port, path)
    if response and response.status == 200 then
      return "Possible admin panel found at: " .. path
    end
  end
  
  return nil
end
```

```bash
# Run custom script
nmap --script ~/.nmap/scripts/custom-http-check.nse target.com
```

### Technique 3: Output Formats for Automation

```bash
# Multiple output formats simultaneously
nmap -A target.com -oA scan-results

# Creates:
# scan-results.nmap  (human-readable)
# scan-results.xml   (XML for parsing)
# scan-results.gnmap (greppable)

# Parse XML with Python
cat scan-results.xml | python3 -c "
import sys, xml.etree.ElementTree as ET
tree = ET.parse(sys.stdin)
for host in tree.findall('.//host'):
    addr = host.find('.//address').get('addr')
    print(f'Host: {addr}')
"
```

---

## Troubleshooting Common Issues

### Issue 1: "Host seems down"

**Problem**: Nmap can't reach the target

**Fix:**
```bash
# Skip host discovery (assume host is up)
nmap -Pn target.com

# Or use different discovery methods
nmap -PS22,80,443 target.com  # TCP SYN probe
nmap -PA22,80,443 target.com  # TCP ACK probe
```

### Issue 2: Scan Too Slow

**Problem**: Taking forever on large scopes

**Fix:**
```bash
# Fast scan mode (top 100 ports only)
nmap -F target.com

# Increase speed (use carefully)
nmap -T5 --min-rate 1000 target.com

# Exclude specific ports that hang
nmap --exclude-ports 445,3389 target.com
```

### Issue 3: Permission Denied

**Problem**: "You requested a scan type which requires root privileges"

**Fix:**
```bash
# Use sudo for SYN scans
sudo nmap -sS target.com

# Or use TCP connect scan (no root needed)
nmap -sT target.com
```

### Issue 4: Inconsistent Results

**Problem**: Getting different results each scan

**Fix:**
```bash
# Increase retry count
nmap --max-retries 5 target.com

# Use TCP connect for reliability
nmap -sT --max-retries 3 target.com

# Scan multiple times and compare
nmap target.com -oN scan1.txt
nmap target.com -oN scan2.txt
diff scan1.txt scan2.txt
```

---

## 💰 Level Up: Commercial Tools Worth Considering

### When Nmap Isn't Enough

| Tool | Best For | Price | Affiliate Link |
|------|----------|-------|----------------|
| **[Burp Suite](https://cipherops.gitbook.io/bug-bounty-notes/web-application/introducing-20-web-application-hacking-tools) Pro** | Web app testing, manual inspection | $449/year | [Get Burp Pro](AFFILIATE_LINK) |
| **Nessus** | Compliance scanning, reporting | $2,390/year | [Try Nessus](AFFILIATE_LINK) |
| **Qualys** | Enterprise vulnerability management | Custom | [Learn More](AFFILIATE_LINK) |
| **Detectify** | Continuous external monitoring | $99/mo | [Start Trial](AFFILIATE_LINK) |

**My Recommendation**: Nmap is unbeatable for discovery and initial recon. Pair it with Burp Suite Pro for deep web application testing. I use Nmap to find the target, Burp to exploit it.

[**Get Burp Suite Pro - Bug Bounty Essential**](AFFILIATE_LINK)

### Why I Upgraded My Toolkit

After 50+ bug bounty submissions using only open-source tools, I hit a wall:
- Manual request/response inspection was painful
- Couldn't easily modify and replay requests
- Missing automated vulnerability detection

**Burp Suite Pro filled all these gaps**. The combination of Nmap + Burp is unstoppable for bug bounty hunting.

---

## Cloud Infrastructure: Scale Your Scans

### Why You Need a VPS for Nmap

**Local Scanning Problems:**
- Your ISP might block aggressive scanning
- Laptop battery dies on long scans
- IP gets banned, affecting other traffic
- Limited bandwidth

**VPS Benefits:**
- Static IP dedicated to scanning
- 24/7 operation
- Better bandwidth
- Isolated from your personal network

### Recommended VPS Providers

| Provider | Specs | Price | Best For | Link |
|----------|-------|-------|----------|------|
| **DigitalOcean** | 2GB RAM, 1 CPU | $12/mo | Beginners | [$25 Free Credit](AFFILIATE_LINK) |
| **Linode** | 4GB RAM, 2 CPU | $24/mo | Power users | [$100 Free Credit](AFFILIATE_LINK) |
| **Vultr** | 2GB RAM, 1 CPU | $10/mo | Budget | [$100 Free Credit](AFFILIATE_LINK) |
| **Hetzner** | 8GB RAM, 2 CPU | €5.35/mo | Best value | [Sign Up](AFFILIATE_LINK) |

**Pro Setup:**
```bash
# Install on VPS
sudo apt update && sudo apt install -y nmap tmux

# Persistent scanning session
tmux new -s nmap-session

# Run comprehensive scan
sudo nmap -A -iL targets.txt -oN comprehensive-scan.txt

# Detach: Ctrl+B, D
# Reattach: tmux attach -t nmap-session
```

---

## Comparison: Nmap vs The Competition

| Feature | Nmap | Masscan | Zmap | Unicornscan |
|---------|------|---------|------|-------------|
| **Speed** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Accuracy** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ |
| **NSE Scripts** | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐ | ⭐⭐ |
| **OS Detection** | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐ | ⭐⭐⭐ |
| **Ease of Use** | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ |
| **Documentation** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐ |
| **Bug Bounty Fit** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |

**Verdict**: Nmap is slower than Masscan/Zmap for pure port scanning, but the NSE scripts and accuracy make it irreplaceable for bug bounty work. Use Masscan for initial wide discovery, Nmap for detailed analysis.

---

## Quick Reference Cheat Sheet

### Essential Commands

```bash
# Host discovery
nmap -sn 192.168.1.0/24

# Quick port scan (top 100)
nmap -F target.com

# Full port scan
nmap -p- target.com

# Service version detection
nmap -sV target.com

# Aggressive scan (OS, version, scripts, traceroute)
nmap -A target.com

# Stealthy SYN scan
sudo nmap -sS target.com

# UDP scan
sudo nmap -sU target.com

# Scan from file
nmap -iL targets.txt

# Output all formats
nmap -A target.com -oA results
```

### Port States Explained

```
open       - Port is accessible, service running
closed     - Port is accessible, no service listening
filtered   - Firewall blocking, can't determine state
unfiltered - Port accessible but can't determine open/closed
```

### Timing Templates

```bash
-T0  # Paranoid (IDS evasion)
-T1  # Sneaky (slow)
-T2  # Polite (gentle)
-T3  # Normal (default)
-T4  # Aggressive (fast)
-T5  # Insane (very fast, may miss things)
```

### NSE Script Categories

```bash
nmap --script auth      # Authentication checks
nmap --script broadcast # Host discovery
nmap --script brute     # Brute force attacks
nmap --script default   # Default safe scripts
nmap --script discovery # Network discovery
nmap --script dos       # Denial of service (careful!)
map --script exploit    # Exploitation (careful!)
nmap --script external  # Third-party services
nmap --script fuzzer    # Fuzzing
nmap --script intrusive # Intrusive scripts
nmap --script malware   # Malware detection
nmap --script safe      # Safe scripts
nmap --script version   # Version detection
nmap --script vuln      # Vulnerability scanning
```

---

## Pro Tips from the Trenches

### Tip 1: Always Save Your Scans

```bash
# Create organized directory structure
mkdir -p ~/bounty-scans/$(date +%Y-%m-%d)

# Save with descriptive names
nmap -A target.com -oA ~/bounty-scans/$(date +%Y-%m-%d)/target-com-full

# Compare scans over time
diff scan-2024-01-15.nmap scan-2024-02-27.nmap
```

### Tip 2: Scope Compliance

```bash
# Read scope first!
cat scope.txt

# Exclude out-of-scope IPs
nmap -iL targets.txt --excludefile out-of-scope.txt

# Single host test first
nmap -sV test-target.com

# Check rate limits
nmap --max-rate 100 target.com
```

### Tip 3: Combine with Other Tools

```bash
# Nmap + Nuclei pipeline
nmap -p- target.com -oG - | \
  awk '/Host/{print $2}' | \
  nuclei -t exposures/

# Nmap + Subfinder
subfinder -d target.com | \
  xargs -I {} nmap -F {}
```

### Tip 4: Team Collaboration

```bash
# Share XML results
cat scan-results.xml | \
  python3 -c "import sys, xml.etree.ElementTree as ET; 
  tree = ET.parse(sys.stdin); 
  [print(f'{h.find('.//address').get(\"addr\")}: {[p.get(\"portid\") for p in h.findall('.//port')]}') 
   for h in tree.findall('.//host')]"

# Create summary reports
nmap -A target.com -oX scan.xml
xsltproc /usr/share/nmap/nmap.xsl scan.xml > scan-report.html
```

---

## Summary & Your Next Steps

### What You Learned

✅ Installed Nmap on any OS  
✅ Discovered live hosts in seconds  
✅ Scanned ports with precision  
✅ Detected service versions  
✅ Created AI-assisted workflows  
✅ Wrote custom NSE scripts  
✅ Optimized scan performance  
✅ Troubleshot common issues  
✅ Understood commercial alternatives  

### Your Action Plan

**Today:**
1. Verify Nmap is installed: `nmap --version`
2. Scan your home network: `nmap -sn 192.168.1.0/24`
3. Try a basic port scan on a test target

**This Week:**
1. Create a recon script with Nmap + subfinder
2. Experiment with 5 different NSE scripts
3. Document your first finding using Nmap

**This Month:**
1. Submit a bug found with Nmap recon
2. Write your first custom NSE script
3. Set up a VPS for 24/7 scanning

### Recommended Next Reads

- [Nuclei Complete Guide](01_Nuclei_Complete_Guide.md) - Automation after Nmap
- [50 Copy-Paste Commands](../02_Reconnaissance/02_50_Copy_Paste_Commands.md)
- [AI-Powered Reconnaissance](../02_Reconnaissance/01_AI_Powered_Reconnaissance.md)

### Get Help

**Stuck?** Join the community:
- [Nmap Security Scanner Community](https://nmap.org/community)
- [Nmap Dev Mailing List](https://cgi.insecure.org/mailman/listinfo/nmap-dev)
- [Bug Bounty Forum](https://bugbountyforum.com)

---

## 💡 Upgrade Your Arsenal

### Tools That Work Great With Nmap

**Cloud VPS for Scanning:**
- [DigitalOcean - $25 Free Credit](AFFILIATE_LINK) ← Perfect for beginners
- [Linode - $100 Free Credit](AFFILIATE_LINK) ← Best performance

**Advanced Testing:**
- [Burp Suite Pro](AFFILIATE_LINK) ← Essential after Nmap finds targets
- [PentesterLab Pro](AFFILIATE_LINK) ← Practice Nmap + exploitation

**Automation:**
- [GitHub Copilot](AFFILIATE_LINK) ← Write NSE scripts faster
- [ChatGPT Plus](AFFILIATE_LINK) ← Analyze scan results

---

*Found this guide helpful? Share it with your bug bounty crew and star the [Nmap repository](https://github.com/nmap/nmap). Happy hunting!* 🔍

---

**Last Updated:** February 2024  
**Author:** Your Name  
**Community:** [Nmap Project](https://nmap.org)  
**License:** This guide is free to share with attribution


---

## 📚 Related Guides
- 🛠️ [Nuclei Complete Guide](01_Nuclei_Complete_Guide.md) — Automated vuln scanning
- 🔍 [Reconnaissance](../reconnaissance/01_AI_Powered_Reconnaissance.md) — Find targets first
- 🌐 [Web Testing](../web-testing/sql-injection-20260316.md) — Next: exploit what you find

---

*Part of the [CipherOps Bug Bounty Notes](https://cipherops.gitbook.io/bug-bounty-notes/) — your guide from zero to first bounty.*

