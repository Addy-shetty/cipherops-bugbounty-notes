# Setting Up Your Bug Bounty Lab: The Complete Guide

**Skill Level:** 🟢 Beginner  
**Time:** 1-2 hours  
**Goal:** Professional hunting environment ready to go  
**Last Updated:** 2026-02-27

---

## 💻 Why Your Lab Setup Matters

I learned this the hard way.

My first "lab" was my personal laptop with Kali Linux dual-booted. Seemed fine, right?

**Then I:**
- Accidentally deleted my personal files during an [nmap](https://cipherops.gitbook.io/bug-bounty-notes/tools/nmaps-nse-scripts-for-ethical-password-testing) scan (don't ask)
- Broke my WiFi driver installing tools
- Spent 3 hours fixing dependency issues instead of hunting
- Almost lost a $1,000 bounty because my environment crashed

**The lesson:** Your lab is your workshop. A messy workshop = messy results.

This guide will set you up with a **professional-grade environment** that just works. No more "it works on my machine" excuses.

---

## 🎯 What We're Building

By the end of this guide, you'll have:

- ✅ Kali Linux VM properly configured
- ✅ 20+ essential tools installed
- ✅ Directory structure for organization
- ✅ VPN and proxy configured
- ✅ [Burp Suite](https://cipherops.gitbook.io/bug-bounty-notes/web-application/introducing-20-web-application-hacking-tools) ready to rock
- ✅ Automation scripts for efficiency

**Total time:** 1-2 hours (mostly automated)

---

## Step 1: Choose Your Setup

### Option A: Virtual Machine (RECOMMENDED for Beginners)

**Best for:** Learning, safe testing, easy snapshots  
**Pros:** Isolated, portable, snapshot/restore  
**Cons:** Slightly slower than native

**My choice:** This is what I use for 90% of my hunting.

### Option B: WSL2 (Windows Subsystem for Linux)

**Best for:** Windows users who want Linux tools  
**Pros:** Fast, integrated with Windows, low resource  
**Cons:** Some tools don't work perfectly

**Good for:** Quick scans, basic recon

### Option C: Native Linux Installation

**Best for:** Experienced users, maximum performance  
**Pros:** Fastest, all tools work perfectly  
**Cons:** Risky (can break system), harder to snapshot

**My choice:** I have a native Kali install on a dedicated machine for heavy lifting.

### Option D: Cloud VPS

**Best for:** Advanced users, avoiding IP bans  
**Pros:** High bandwidth, different IP, always on  
**Cons:** Costs money ($5-20/month), latency

**My choice:** I use DigitalOcean droplets for large-scale recon.

---

## Step 2: Virtual Machine Setup (Recommended Path)

### 2.1 Download Kali Linux VM

**Don't install from ISO** (takes forever). Use the pre-built VM.

1. Go to: https://www.kali.org/get-kali/#kali-virtual-machines
2. Download the **VirtualBox** or **VMware** image
3. File size: ~3-4 GB
4. Extract the ZIP file

### 2.2 Import into VirtualBox

```bash
# Open VirtualBox
# File → Import Appliance
# Select the .ova file you downloaded
# Adjust settings:
#   - RAM: 4096 MB (minimum), 8192 MB (recommended)
#   - CPUs: 2 (minimum), 4 (recommended)
#   - Storage: 60 GB (minimum)
# Click Import
```

**My VM Settings:**
- RAM: 8192 MB (I have 32GB total)
- CPUs: 4
- Storage: 100 GB
- Network: Bridged Adapter (gets own IP)
- Display: 128MB video memory, 3D acceleration ON

### 2.3 First Boot & Update

```bash
# Start the VM
# Login: kali / kali

# Update everything first
sudo apt update && sudo apt full-upgrade -y

# This takes 30-60 minutes depending on your internet
# Go get coffee ☕
```

**Why update first?** Kali images are updated quarterly. You want the latest tools and security patches.

---

## Step 3: Directory Structure (Organization is Key)

I can't stress this enough: **organize from day one.**

```bash
# Create the structure
mkdir -p ~/bugbounty/{tools,targets,reports,wordlists,scripts,notes}

# What each folder is for:
# tools/     - Custom tools you download
# targets/   - One folder per target
# reports/   - Bug reports you write
# wordlists/ - Custom wordlists
# scripts/   - Automation scripts
# notes/     - Personal notes

# Create target template
mkdir -p ~/bugbounty/targets/TEMPLATE/{recon,exploitation,screenshots,evidence}
```

### My Actual Directory

```
~/bugbounty/
├── tools/
│   ├── custom-nuclei-templates/
│   ├── recon-scripts/
│   └── report-templates/
├── targets/
│   ├── example-com-2024-01/
│   │   ├── recon/
│   │   ├── exploitation/
│   │   └── report.md
│   └── shopify-2024-02/
│       ├── recon/
│       └── report.md
├── reports/
│   ├── report-template.md
│   └── cvss-calculator.md
├── wordlists/
│   ├── custom-subdomains.txt
│   └── api-endpoints.txt
├── scripts/
│   ├── auto-recon.sh
│   └── screenshot.sh
└── notes/
    ├── methodology.md
    └── tools-i-like.md
```

**This organization has saved me countless hours.** When I need to find something from 6 months ago, I know exactly where it is.

---

## Step 4: Install Essential Tools

### 4.1 One-Command Installation Script

I created this script after reinstalling my lab 5 times. It installs everything automatically.

```bash
#!/bin/bash
# save as: ~/bugbounty/scripts/install-tools.sh

echo "🚀 Bug Bounty Lab Setup Script"
echo "=============================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print status
print_status() {
    echo -e "${YELLOW}[*]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# Update system
print_status "Updating system packages..."
sudo apt update && sudo apt upgrade -y
print_success "System updated"

# Install Go (required for many tools)
print_status "Installing Go..."
if ! command -v go &> /dev/null; then
    wget https://go.dev/dl/go1.21.5.linux-amd64.tar.gz
    sudo tar -C /usr/local -xzf go1.21.5.linux-amd64.tar.gz
    echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.zshrc
    echo 'export PATH=$PATH:~/go/bin' >> ~/.zshrc
    source ~/.zshrc
    print_success "Go installed"
else
    print_success "Go already installed"
fi

# Create Go directories
mkdir -p ~/go/bin

# Install recon tools
print_status "Installing reconnaissance tools..."

go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
go install -v github.com/projectdiscovery/naabu/v2/cmd/naabu@latest
go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest
go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest
go install -v github.com/ffuf/ffuf@latest
go install -v github.com/tomnomnom/assetfinder@latest
go install -v github.com/jaeles-project/gospider@latest

print_success "Recon tools installed"

# Install wordlists
print_status "Installing wordlists..."
sudo apt install -y seclists
print_success "Wordlists installed"

# Install Burp Suite Community
print_status "Note: Burp Suite needs to be downloaded manually from portswigger.net"
echo "Download from: https://portswigger.net/burp/communitydownload"

# Install other tools
print_status "Installing additional tools..."

sudo apt install -y nmap
sudo apt install -y dirb
sudo apt install -y gobuster
sudo apt install -y whatweb
sudo apt install -y sqlmap
sudo apt install -y metasploit-framework
sudo apt install -y john
sudo apt install -y hashcat
sudo apt install -y hydra
sudo apt install -y feroxbuster
sudo apt install -y ffuf

print_success "Additional tools installed"

# Install Python tools
print_status "Installing Python tools..."
pip3 install requests
pip3 install beautifulsoup4
pip3 install openai
pip3 install pyftpdlib

print_success "Python tools installed"

# Install Docker (optional but recommended)
print_status "Installing Docker..."
sudo apt install -y docker.io
sudo systemctl enable docker --now
sudo usermod -aG docker $USER
print_success "Docker installed (log out and back in for group changes)"

# Create useful aliases
print_status "Creating aliases..."
cat << 'EOF' >> ~/.zshrc

# Bug Bounty Aliases
alias bb='cd ~/bugbounty'
alias targets='cd ~/bugbounty/targets'
alias tools='cd ~/bugbounty/tools'
alias recon='cd ~/bugbounty/targets/*/recon 2>/dev/null || echo "No active target"'
alias reset-target='rm -rf ~/bugbounty/targets/current && mkdir -p ~/bugbounty/targets/current/{recon,exploitation,screenshots,evidence}'
EOF

print_success "Aliases created"

echo ""
echo "=============================="
echo "✅ Setup Complete!"
echo "=============================="
echo ""
echo "Next steps:"
echo "1. Log out and log back in (for Docker group)"
echo "2. Download Burp Suite from portswigger.net"
echo "3. Run 'source ~/.zshrc' to load aliases"
echo "4. Start hunting! 🐛"
echo ""
```

**Run it:**
```bash
chmod +x ~/bugbounty/scripts/install-tools.sh
~/bugbounty/scripts/install-tools.sh
```

This takes about 20-30 minutes. Fully automated.

---

## Step 5: Configure Burp Suite

Burp Suite is **essential** for web testing. Here's how I set it up.

### 5.1 Installation

```bash
# Download from PortSwigger
# https://portswigger.net/burp/communitydownload

# Or use the Kali built-in version (older but works)
sudo apt install -y burpsuite

# Or download Pro if you have a license (recommended)
```

**I use Burp Suite Pro.** It's $449/year but pays for itself with one medium bounty.

### 5.2 Initial Configuration

**Project Options → Sessions:**
- Cookie jar: Enabled
- Session handling rules: Default
- Macros: None yet

**Project Options → Misc:**
- Logging: Enable all
- Save to: ~/bugbounty/tools/burp-logs/

**User Options → Display:**
- Font size: 14 (easier on eyes)
- Theme: Dark (obviously)

**User Options → Connections:**
- Upstream proxy: If using VPN
- SOCKS proxy: If needed

### 5.3 Essential Extensions

Install these from the BApp Store:

1. **Logger++** - Better logging
2. **Autorize** - Authorization testing
3. **Turbo Intruder** - Fast HTTP attacks
4. **Param Miner** - Parameter discovery
5. **Upload Scanner** - File upload testing
6. **JSON Beautifier** - Pretty print JSON
7. **WAFDetect** - WAF identification

**How to install:**
```
Extender → BApp Store → Search → Install
```

### 5.4 Browser Configuration

**Firefox (recommended):**
1. Install FoxyProxy extension
2. Configure proxy: 127.0.0.1:8080
3. Import Burp CA certificate
4. Set up separate profile for testing

**Chrome:**
1. SwitchyOmega extension
2. Same proxy settings
3. Import CA cert

**Pro tip:** Use Firefox for testing, Chrome for research. Keeps things separate.

---

## Step 6: VPN & Proxy Setup

### 6.1 Why You Need a VPN

**Not for anonymity** (that's not how VPNs work).

**For:**
- Changing IP when rate-limited
- Testing geo-specific features
- Avoiding ISP throttling
- Protecting your home IP

### 6.2 VPN Setup

I use **Mullvad** ($5/month, no logs, accepts crypto).

```bash
# Install Mullvad
# Download from: https://mullvad.net/en/download/

# Or use OpenVPN with any provider
sudo apt install -y openvpn

# Connect
sudo openvpn --config your-config.ovpn
```

**Other good options:**
- ProtonVPN (free tier available)
- NordVPN (if you must)
- Self-hosted WireGuard (advanced)

### 6.3 Proxy Chains

For advanced setups:

```bash
# Install proxychains
sudo apt install -y proxychains4

# Edit config
sudo nano /etc/proxychains4.conf

# Add at bottom:
socks5 127.0.0.1 9050

# Use with tools:
proxychains4 nmap -sT target.com
```

**I use this for:**
- Testing from different countries
- Avoiding WAF blocks
- Distributing scan load

---

## Step 7: Automation Scripts

### 7.1 Target Setup Script

```bash
#!/bin/bash
# save as: ~/bugbounty/scripts/setup-target.sh

if [ -z "$1" ]; then
    echo "Usage: setup-target.sh <domain>"
    echo "Example: setup-target.sh example.com"
    exit 1
fi

DOMAIN=$1
DATE=$(date +%Y-%m-%d)
TARGET_DIR="~/bugbounty/targets/${DOMAIN}-${DATE}"

# Create directory structure
mkdir -p ${TARGET_DIR}/{recon,exploitation,screenshots,evidence,notes}

# Create README
cat > ${TARGET_DIR}/README.md << EOF
# Target: ${DOMAIN}
Date: ${DATE}
Status: Active

## Notes
- 

## Findings
- 

## To-Do
- [ ] Subdomain enumeration
- [ ] Port scanning
- [ ] Content discovery
- [ ] Manual testing
EOF

# Create scope file
touch ${TARGET_DIR}/scope.txt

# Create notes file
cat > ${TARGET_DIR}/notes/recon-notes.md << EOF
# Reconnaissance Notes: ${DOMAIN}

## Subdomains Found
- 

## Live Hosts
- 

## Technologies
- 

## Interesting Findings
- 
EOF

echo "✅ Target setup complete: ${TARGET_DIR}"
echo "cd ${TARGET_DIR}"
```

**Use it:**
```bash
setup-target.sh example.com
cd ~/bugbounty/targets/example.com-2026-02-27/
```

### 7.2 Quick Recon Script

```bash
#!/bin/bash
# save as: ~/bugbounty/scripts/quick-recon.sh

DOMAIN=$1
OUTPUT_DIR=$2

if [ -z "$DOMAIN" ] || [ -z "$OUTPUT_DIR" ]; then
    echo "Usage: quick-recon.sh <domain> <output-dir>"
    exit 1
fi

echo "🔍 Quick Recon for: $DOMAIN"

# Subdomain enumeration
echo "[*] Finding subdomains..."
subfinder -d $DOMAIN -all -silent > $OUTPUT_DIR/subdomains.txt

# DNS resolution
echo "[*] Resolving DNS..."
cat $OUTPUT_DIR/subdomains.txt | dnsx -silent > $OUTPUT_DIR/resolved.txt

# HTTP probing
echo "[*] Probing HTTP..."
cat $OUTPUT_DIR/resolved.txt | httpx -silent -title -tech-detect > $OUTPUT_DIR/live-hosts.txt

echo "✅ Quick recon complete!"
echo "Results in: $OUTPUT_DIR"
```

---

## Step 8: Burp Project Templates

### 8.1 Reusable Project

Save a "template" project with your:
- Preferred extensions installed
- Scope settings
- Proxy configuration
- Target templates

**How:**
```
Project → Save Copy → "template.burp"
Project → Open → "template.burp" (when starting new target)
```

### 8.2 Target-Specific Projects

For each major target, create a dedicated project:
```
~/bugbounty/targets/example-com/project.burp
```

**Why:** Keeps data separate, easier to reference later.

---

## Step 9: Backup Strategy

### 9.1 VM Snapshots

**Before major updates:**
```
VirtualBox: Machine → Take Snapshot
Name it: "Before-[update-description]"
```

**I keep snapshots:**
- Fresh install (baseline)
- After major tool updates
- Before trying risky tools
- Weekly during heavy hunting

### 9.2 Target Backups

```bash
# Backup script
#!/bin/bash
# save as: ~/bugbounty/scripts/backup.sh

cd ~/bugbounty
tar -czf "backup-$(date +%Y-%m-%d).tar.gz" targets/ reports/ notes/
echo "✅ Backup created"
```

**Run weekly:**
```bash
0 2 * * 0 ~/bugbounty/scripts/backup.sh  # Every Sunday at 2am
```

---

## ✅ Final Checklist

Before you start hunting, verify:

### Tools Check
```bash
# Verify all tools work
subfinder -version
httpx -version
naabu -version
nuclei -version
ffuf -h
burpsuite --version
nmap --version
```

### Directory Check
```bash
ls ~/bugbounty/
# Should see: tools/ targets/ reports/ wordlists/ scripts/ notes/
```

### Network Check
```bash
ping -c 3 google.com
# Should get responses
```

### Burp Check
```bash
# Start Burp
# Check proxy is listening on 8080
netstat -tlnp | grep 8080
```

---

## 🚀 You're Ready!

Your lab is now set up like a pro's.

**What's next?**
1. Pick a target from [[Bug Bounty Platforms](https://cipherops.gitbook.io/bug-bounty-notes/readme/bug-bounty-platforms-compared-where-to-hunt-in-2026) Compared](02_Bug_Bounty_Platforms_Compared.md)
2. Run your first recon with [AI-Powered Reconnaissance](../02_Reconnaissance/01_AI_Powered_Reconnaissance.md)
3. Find your [First Bug](01_From_Zero_to_First_Bug.md)

**Pro tip:** Bookmark this page. You'll come back to it when setting up new machines or helping friends.

---

## 🔧 Troubleshooting

### Problem: "Command not found"
**Fix:** Add to PATH in ~/.zshrc:
```bash
export PATH=$PATH:~/go/bin:/usr/local/go/bin
```

### Problem: Tool installation fails
**Fix:** Update Go and try again:
```bash
# Remove old Go
sudo rm -rf /usr/local/go
# Reinstall latest version
# (rerun the install script)
```

### Problem: Burp won't start
**Fix:** Check Java version:
```bash
java -version
# Should be Java 11 or higher
```

### Problem: VM is slow
**Fix:** Allocate more resources:
- Minimum 4GB RAM, 2 CPUs
- Recommended 8GB RAM, 4 CPUs
- Enable 3D acceleration

---

## 📚 Resources

- [Kali Linux Documentation](https://www.kali.org/docs/)
- [Burp Suite Documentation](https://portswigger.net/burp/documentation)
- [OWASP Testing Guide](https://owasp.org/www-project-web-security-testing-guide/)

---

**Questions? Stuck somewhere? DM me on Twitter @CipherOps_tech**

*Now go break something (legally)! 🐛💥*

*Last Updated: 2026-02-27*


---

## 📚 Related Guides
- 🚀 [Bug Bounty Platforms Compared](02_Bug_Bounty_Platforms_Compared.md) — Pick the right platform
- 🛠️ [Setting Up Your Lab](03_Setting_Up_Your_Lab.md) — Build your hacking environment
- 🔍 [AI-Powered Reconnaissance](../reconnaissance/01_AI_Powered_Reconnaissance.md) — Next: start finding targets

---

*Part of the [CipherOps Bug Bounty Notes](https://cipherops.gitbook.io/bug-bounty-notes/) — your guide from zero to first bounty.*

