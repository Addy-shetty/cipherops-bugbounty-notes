# Tool Spotlight: Nuclei - The Vulnerability Scanner That Changed Bug Bounty

**Category:** Vulnerability Scanner  
**Skill Level:** Beginner → Advanced  
**Installation Time:** 2 minutes  
**Best For:** Automated vulnerability detection at scale

---

## What is Nuclei?

**In One Sentence:**  
Nuclei is a fast, customizable vulnerability scanner that uses templates to detect security issues across websites, APIs, and infrastructure.

**Why It's Revolutionary:**

Before Nuclei, bug bounty hunters had to:
- Write custom scripts for each vulnerability type
- Manually chain multiple tools together
- Spend hours on recon before finding anything

After Nuclei:
- 7,000+ community-built templates ready to use
- Scan 1,000 targets in minutes, not hours
- Detect CVEs within hours of disclosure
- Write your own templates for custom findings

**Real Bug Bounty Impact:**
- Used in 10,000+ disclosed reports
- Average time savings: 80% on initial recon
- Community reports: $500-$50,000+ bounties found using Nuclei

---

## Why Use It?

### For Bug Bounty Hunters:

✅ **Speed** - Scan hundreds of targets in parallel  
✅ **Coverage** - 7,000+ templates for every bug class  
✅ **Customization** - Write templates for your specific targets  
✅ **Actively Maintained** - New CVE templates within 24 hours  
✅ **Free & Open Source** - No license costs  
✅ **Integration-Friendly** - Works with CI/CD, automation  

### Comparison: Manual vs Nuclei

| Task | Manual Time | With Nuclei | Time Saved |
|------|-------------|-------------|------------|
| Check for CVEs | 4 hours | 10 minutes | 96% |
| Find exposed panels | 2 hours | 5 minutes | 96% |
| Test for misconfigurations | 3 hours | 15 minutes | 92% |
| Initial recon | 1 day | 30 minutes | 98% |

---

## Installation

### Quick Install (Recommended)

```bash
# Linux/macOS
wget https://github.com/projectdiscovery/nuclei/releases/latest/download/nuclei-linux-amd64.zip
unzip nuclei-linux-amd64.zip
sudo mv nuclei /usr/local/bin/

# Or use install script
curl -s https://api.github.com/repos/projectdiscovery/nuclei/releases/latest | \
  grep "browser_download_url.*linux_amd64.zip" | \
  cut -d '"' -f 4 | \
  wget -i - -O nuclei.zip && unzip nuclei.zip && sudo mv nuclei /usr/local/bin/
```

### Using Go

```bash
go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest
```

### Docker

```bash
docker pull projectdiscovery/nuclei:latest

# Run
docker run projectdiscovery/nuclei -u https://target.com
```

### Verify Installation

```bash
nuclei -version

# Should show:
# [INF] Current Version: 3.x.x
```

**Update Templates (Required!):**
```bash
nuclei -update-templates

# Updates to latest templates
# Run this weekly to get new CVEs
```

---

## Basic Usage

### Command Structure

```bash
nuclei -u <target> [options]
```

### Your First Scan

```bash
# Scan single target
nuclei -u https://target.com

# Scan with specific templates
nuclei -u https://target.com -t cves/

# Scan with rate limiting (polite scanning)
nuclei -u https://target.com -rl 10

# Output to file
nuclei -u https://target.com -o results.txt

# JSON output for automation
nuclei -u https://target.com -json -o results.json
```

### Common Use Cases

#### 1. Quick CVE Check

**Command:**
```bash
nuclei -u https://target.com -t cves/ -severity high,critical
```

**What it does:**
- Checks for known CVEs
- Only high and critical severity
- Takes 2-5 minutes

**Real Output:**
```
[cve-2024-21626] [http] [high] https://target.com/api/v1/status
[cve-2023-4911] [http] [high] https://target.com/admin/login
```

**Action:**
These are goldmine findings! CVEs often pay $1,000-$15,000+ on bug bounty platforms.

#### 2. Exposed Panel Discovery

**Command:**
```bash
nuclei -u https://target.com -t exposed-panels/
```

**What it finds:**
- Admin panels
- Database dashboards
- Monitoring tools
- Development environments

**Real Output:**
```
[grafana-panel] [http] [info] https://target.com/grafana/login
[kibana-exposure] [http] [medium] https://target.com:5601
[phpmyadmin-panel] [http] [high] https://target.com/phpmyadmin
```

**Why it matters:**
Exposed panels often lead to full system compromise. Report these ASAP!

#### 3. Technology Detection

**Command:**
```bash
nuclei -u https://target.com -t technologies/
```

**What it reveals:**
- Server software
- Frameworks
- JavaScript libraries
- Third-party services

**Real Output:**
```
[tech-detect:apache] [http] [info] https://target.com [Apache/2.4.41]
[tech-detect:jquery] [http] [info] https://target.com [jquery-3.4.1]
[tech-detect:react] [http] [info] https://target.com [React]
```

**Bug Bounty Value:**
- jQuery 3.4.1 → Check for XSS CVEs
- Apache 2.4.41 → Check for known exploits
- React → Look for prototype pollution

#### 4. Misconfiguration Hunt

**Command:**
```bash
nuclei -u https://target.com -t misconfiguration/
```

**Finds:**
- CORS misconfigurations
- Missing security headers
- Information disclosure
- Default credentials

**Real Output:**
```
[missing-csp] [http] [low] https://target.com
[information-disclosure] [http] [medium] https://target.com/.env
[cors-misconfig] [http] [medium] https://target.com/api/
```

---

## Advanced Features

### Running Large Scans

**Scan 1,000 targets:**
```bash
# Create targets file
cat targets.txt
https://target1.com
https://target2.com
...
https://target1000.com

# Run scan
nuclei -l targets.txt -o all-results.txt

# With concurrency (faster)
nuclei -l targets.txt -c 50 -o all-results.txt

# Resume interrupted scans
nuclei -l targets.txt -resume -o all-results.txt
```

### Custom Template Creation

**Why Write Custom Templates?**
- Target-specific vulnerabilities
- Unique business logic bugs
- Chain multiple findings
- Automate your methodology

**Basic Template Structure:**
```yaml
id: custom-endpoint-check

info:
  name: Custom Endpoint Exposure
  author: your-name
  severity: medium
  description: Checks for exposed /debug endpoint

http:
  - method: GET
    path:
      - "{{BaseURL}}/debug"
    
    matchers:
      - type: word
        words:
          - "debug"
          - "traceback"
          - "environment"
        condition: or
        
      - type: status
        status:
          - 200
```

**Save as:** `custom-template.yaml`

**Run it:**
```bash
nuclei -u https://target.com -t custom-template.yaml
```

### Filtering Results

**By Severity:**
```bash
nuclei -u https://target.com -severity critical,high
```

**By Tags:**
```bash
# Only scan for SQL injection
nuclei -u https://target.com -tags sqli

# Exclude certain tags
nuclei -u https://target.com -etags dos,fuzz
```

**By Template IDs:**
```bash
# Run specific CVEs only
nuclei -u https://target.com -id cve-2024-21626,cve-2023-4911
```

### Integration with Recon Workflow

**Complete Pipeline:**
```bash
#!/bin/bash

TARGET=$1
OUTPUT_DIR="recon-$TARGET"
mkdir -p $OUTPUT_DIR

echo "[+] Starting recon for $TARGET"

# 1. Subdomain enumeration
echo "[+] Finding subdomains..."
subfinder -d $TARGET -o $OUTPUT_DIR/subdomains.txt

# 2. Find live hosts
echo "[+] Probing for live hosts..."
cat $OUTPUT_DIR/subdomains.txt | httpx -o $OUTPUT_DIR/live.txt

# 3. Run Nuclei on all live hosts
echo "[+] Running Nuclei..."
nuclei -l $OUTPUT_DIR/live.txt \
       -o $OUTPUT_DIR/nuclei-results.txt \
       -severity critical,high,medium

# 4. Parse results
echo "[+] Parsing results..."
grep "\[critical\]" $OUTPUT_DIR/nuclei-results.txt > $OUTPUT_DIR/critical.txt
grep "\[high\]" $OUTPUT_DIR/nuclei-results.txt > $OUTPUT_DIR/high.txt

echo "[+] Done! Check $OUTPUT_DIR/ for results"
```

---

## Integration with Your Workflow

### In Recon Pipeline

**Daily Automation:**
```bash
# Daily CVE check on all targets
nuclei -l all-targets.txt -t cves/ -severity critical,high -o daily-cves.txt

# Alert if new CVEs found
if [ -s daily-cves.txt ]; then
    echo "New CVEs found!" | mail -s "CVE Alert" your-email@domain.com
fi
```

### With Other Tools

**Chain with httpx:**
```bash
# Find live hosts, then scan
cat subdomains.txt | httpx | nuclei -t cves/
```

**Chain with subfinder:**
```bash
subfinder -d target.com | nuclei -t technologies/
```

**Chain with notify:**
```bash
# Get instant notifications for findings
nuclei -u https://target.com -t cves/ -severity critical | notify
```

---

## Configuration Tips

### Rate Limiting (Critical!)

**Don't Get Banned:**
```bash
# Respectful scanning
nuclei -u https://target.com -rl 10        # 10 requests/second
nuclei -u https://target.com -rlm 1000     # 1000 requests/minute
nuclei -u https://target.com -c 10         # 10 concurrent threads
```

**Bug Bounty Programs:**
```bash
# Check scope first!
cat scope.txt
*.target.com
NOT *.api.target.com

# Respect scope
nuclei -l scope-targets.txt -exclude-hosts excluded.txt
```

### Optimizing Performance

**For Large Scans:**
```bash
nuclei -l targets.txt \
       -c 50 \              # 50 concurrent connections
       -rl 100 \            # 100 requests/second
       -timeout 5 \         # 5 second timeout
       -retries 1 \         # 1 retry only
       -o results.txt
```

**Memory Optimization:**
```bash
# For machines with limited RAM
nuclei -l large-target-list.txt -bs 100    # Batch size 100
```

---

## Comparison: Nuclei vs Alternatives

| Feature | Nuclei | Nessus | Burp Scanner | OWASP ZAP |
|---------|--------|--------|--------------|-----------|
| **Cost** | Free | $2,990+/yr | $449/yr | Free |
| **Speed** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |
| **Customization** | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ |
| **Template Library** | 7,000+ | Built-in | Limited | Limited |
| **Community** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Ease of Use** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **CI/CD Integration** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ |

**Verdict:** Nuclei wins for bug bounty due to speed, customization, and cost (free!)

---

## Pro Tips

💡 **Tip #1: Update Templates Weekly**
```bash
# Add to crontab (runs every Sunday at 2 AM)
0 2 * * 0 nuclei -update-templates
```

💡 **Tip #2: Create a Baseline**
```bash
# Run initial scan, save as baseline
nuclei -u https://target.com -o baseline.txt

# Future scans: diff against baseline
nuclei -u https://target.com -o current.txt
diff baseline.txt current.txt > new-findings.txt
```

💡 **Tip #3: Template Management**
```bash
# Keep custom templates organized
mkdir -p ~/nuclei-templates/custom/

# Save your templates there
cp my-template.yaml ~/nuclei-templates/custom/

# Use custom templates
nuclei -u https://target.com -t ~/nuclei-templates/custom/
```

💡 **Tip #4: Reporting Template**
When you find something with Nuclei, include in report:
```
Vulnerability: [CVE-ID or Template Name]
Tool Used: Nuclei v3.x.x
Template: cves/2024/cve-2024-21626.yaml
Command: nuclei -u https://target.com -id cve-2024-21626
Evidence: [Include Nuclei output]
```

💡 **Tip #5: Don't Blindly Report**
Nuclei findings need verification:
```bash
# Nuclei says: [cve-2024-21626] found

# You MUST:
1. Manually verify the finding
2. Check if it's actually exploitable
3. Assess real business impact
4. Then report
```

💡 **Tip #6: Use with Proxy**
```bash
# Route through Burp for manual inspection
nuclei -u https://target.com -proxy-url http://127.0.0.1:8080
```

💡 **Tip #7: Passive Mode**
```bash
# Use with waybackurls for passive recon
cat subdomains.txt | waybackurls | nuclei -t cves/
```

---

## Resources

### Official Documentation
- [Nuclei GitHub](https://github.com/projectdiscovery/nuclei)
- [Template Guide](https://nuclei.projectdiscovery.io/templating-guide/)
- [Template Directory](https://github.com/projectdiscovery/nuclei-templates)

### Template Resources
- [Official Templates](https://github.com/projectdiscovery/nuclei-templates) - 7,000+ templates
- [Community Templates](https://github.com/projectdiscovery/nuclei-templates/discussions)
- [Template Editor](https://nuclei.projectdiscovery.io/template-editor/) - Online template builder

### Video Tutorials
- [Nuclei Playlist - ProjectDiscovery](https://www.youtube.com/playlist?list=PLAQ-4xX7gQkLklqZMydQH8x9R9zeF5hE8)
- [Bug Bounty Reports with Nuclei](https://www.youtube.com/results?search_query=nuclei+bug+bounty)

### Related Guides
- [Complete Recon Methodology](internal-link)
- [Vulnerability Research with Nuclei](internal-link)
- [Custom Template Development](internal-link)

---

## Summary

Nuclei has transformed bug bounty hunting from manual, time-consuming work to scalable, automated reconnaissance. With 7,000+ templates and active community support, it's the most valuable free tool in your arsenal.

**Key Takeaways:**
- Install: 2 minutes
- First scan: 30 seconds
- Time saved: 80%+ on recon
- Cost: $0
- ROI: Infinite

**Action Items:**
1. Install Nuclei today
2. Run `nuclei -update-templates`
3. Scan your first target
4. Write one custom template
5. Join the community

**Remember:** Nuclei finds the low-hanging fruit so you can focus on complex vulnerabilities that pay big bounties.

---

*Tool version: v3.1.0*  
*Last updated: 2024-02-20*  
*Templates count: 7,200+*  
*Author: CipherOps Team*

---

**Questions?** Join our [Discord](https://discord.gg/cipherops) or [Telegram](https://t.me/bugbounty_tech)

**Found a great template?** Submit it to the [official repository](https://github.com/projectdiscovery/nuclei-templates)
