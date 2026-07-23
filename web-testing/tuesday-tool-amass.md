# Tool Spotlight: Amass - The Most Powerful Subdomain Enumeration Tool

**Category:** Reconnaissance / OSINT  
**Skill Level:** Beginner → Expert  
**Installation Time:** 3 minutes  
**Best For:** Comprehensive subdomain discovery and attack surface mapping

---

## What is Amass?

**In One Sentence:**  
Amass is the Swiss Army knife of subdomain enumeration, using both active and passive techniques to map an organization's entire external attack surface.

**Why It's Essential:**

Before Amass, subdomain enumeration meant:
- Running 5+ different tools manually
- Missing 70% of subdomains
- Spending days on recon
- No visualization of results

With Amass:
- One tool does everything
- Discovers 3x more subdomains than competitors
- Automated API integrations (80+ data sources)
- Beautiful visual attack surface maps
- Continuous monitoring capabilities

**Bug Bounty Impact:**
- Average new subdomains found: 200-500 per target
- Hidden admin panels, dev servers, staging environments
- Attack surface visualization = better targeting
- Used in $10,000+ bounty reports

---

## Quick Start Guide

### Installation

```bash
# Linux/macOS
sudo snap install amass

# Or download binary
wget https://github.com/OWASP/Amass/releases/latest/download/amass_linux_amd64.zip
unzip amass_linux_amd64.zip
sudo mv amass /usr/local/bin/

# Verify
amass -version
```

### Basic Usage

```bash
# Quick passive scan (no DNS queries)
amass enum -d target.com

# Comprehensive scan with brute-forcing
amass enum -d target.com -brute -w wordlist.txt

# Save results
amass enum -d target.com -o subdomains.txt

# Visual attack surface map
amass viz -d target.com -o graph.html
```

### Pro Tips

💡 **Use API Keys for Better Results:**
```yaml
# ~/.config/amass/config.yaml
data_sources:
  - name: VirusTotal
    creds:
      apikey: YOUR_FREE_API_KEY
```

💡 **Combine with httpx for live hosts:**
```bash
amass enum -d target.com -o domains.txt
cat domains.txt | httpx -o live-hosts.txt
```

💡 **Track changes over time:**
```bash
amass track -d target.com -last 7
```

---

## Why Amass Wins

| Feature | Amass | Subfinder | Assetfinder |
|---------|-------|-----------|-------------|
| Data Sources | 80+ | 20+ | 10+ |
| Brute-forcing | Yes | No | No |
| Visualization | Yes | No | No |
| Monitoring | Yes | No | No |

**Bottom Line:** Amass = complete reconnaissance in one tool.

---

*Tool version: 4.x*  
*Published: 2024-02-27*  
*Author: CipherOps Team*
