# The $8,000 Subdomain That Changed Everything: A Bug Hunter's Journey with Amass

**A Hero's Journey in 30 Days**  
**The Tool:** Amass  
**The Transformation:** From 120 subdomains to 600+  
**The Result:** $8,000 bounty from a forgotten subdomain  
**Reading Time:** 15 minutes

---

**Your Learning Progress:**

☑️ Basic [Reconnaissance](https://cipherops.gitbook.io/bug-bounty-notes/recon-tips)  
🔄 Tool Mastery (current)  
⬜ Vulnerability Discovery  
⬜ Advanced Techniques

---

## The Ordinary World: Meet Alex

Alex had been bug bounty hunting for three months. Not a complete beginner anymore, but not yet successful either. The stats were depressing:

- **Hours invested:** 200+  
- **Subdomains found per target:** ~120  
- **Duplicate reports:** 60%  
- **Total earnings:** $850  
- **Confidence level:** Critically low

Every morning, Alex followed the same routine: fire up [Subfinder](https://cipherops.gitbook.io/bug-bounty-notes/recon-tips/series-on-the-power-of-reconnaissance-tools/tool-4-subfinder-an-essential-guide-for-domain-reconnaissance), run it against the target, get ~100 subdomains, run httpx to check which were live, start testing... and discover that every interesting subdomain had already been found by someone else.

**The breaking point came on a Tuesday.**

Alex had spent six hours on a fintech target, found three [XSS](https://cipherops.gitbook.io/bug-bounty-notes/web-application/the-art-of-xss-exploitation) vulnerabilities, submitted reports with excitement, and received the dreaded response within hours:

> "Thank you for your submission. Unfortunately, this is a duplicate of report #12345 submitted three weeks ago."

Three duplicates in one day. Six hours wasted. $0 earned.

That night, Alex stared at the ceiling, wondering if bug bounty hunting was even worth it. Maybe it was time to quit and focus on the day job.

---

## The Call to Adventure: A Fateful Encounter

The next morning, while doom-scrolling through Twitter, Alex saw a post that would change everything:

> **@jhaddix:** "If you're only using one [subdomain enumeration](https://cipherops.gitbook.io/bug-bounty-notes/recon-tips/best-recon-technique-for-active-subdomain-enumeration) tool, you're missing 70% of the attack surface. Thread 🧵"

Alex read the entire thread. It wasn't about a new technique or a fancy exploit. It was about a tool called **Amass** that supposedly found 4x more subdomains than anything else.

**The claim seemed exaggerated.**

But Alex had nothing to lose. The current approach clearly wasn't working. What if this tool was the missing piece?

---

## Meeting the Mentor: The First Encounter with Amass

### Installation (The Gateway)

With skepticism and hope in equal measure, Alex installed Amass:

```bash
# The simple way
sudo snap install amass

# Verify it worked
amass -version
# Output: version 4.0.0
```

**Two minutes.** That's all it took. No complex dependencies, no configuration files, no Docker containers. Just... installed.

### The First Scan (The Revelation)

Alex picked the same fintech target from the previous day's failures. The one where six hours of work yielded only duplicates.

```bash
# The command that changed everything
amass enum -d target.com -passive
```

The terminal started scrolling. And scrolling. And scrolling.

```
[DNS]             www.target.com
[Brute Forcing]   api.target.com
[CertSpotter]     admin.target.com
[PassiveTotal]    staging.target.com
[Crtsh]           dev-api.target.com
[Brute Forcing]   legacy.target.com
[Archive]         old.target.com
[DNS]             ftp.target.com
[Brute Forcing]   mail.target.com
...
```

**10 minutes later:** 487 subdomains.

Alex stared at the screen, unable to believe what was happening. The previous best tool had found 120 subdomains for this same target. Amass found 487 in 10 minutes.

**The Math:**
- Old approach: 120 subdomains
- Amass: 487 subdomains
- **New subdomains discovered: 367**

That wasn't 4x more. That was **4x total**, which meant **3x more than before**.

### Visualizing the Transformation

![Hero's Journey with Amass](heros-journey-amass.png)

**The journey ahead:**
1. **Ordinary World** - Struggling with basic tools
2. **Call to Adventure** - Discovery of Amass
3. **Meeting the Mentor** - Learning the tool
4. **Trials & Learning** - Mastering advanced features
5. **Critical Discovery** - Finding the hidden subdomain
6. **Transformation** - The bounty
7. **Return** - Sharing knowledge

---

## Trials and Learning: The 30-Day Mastery Challenge

Alex didn't just want to use Amass. Alex wanted to **master** it. The goal: become so proficient that missing subdomains would be a thing of the past.

### Week 1: Understanding the Basics

**Day 1-2: Passive Reconnaissance**

```bash
# Silent reconnaissance - no DNS queries to target
amass enum -d target.com -passive -o passive-results.txt

# What this does:
# - Checks certificate transparency logs
# - Searches DNS databases
# - Queries search engines
# - Uses 80+ data sources
# - Completely stealthy
```

**Key Learning:** Passive enumeration finds subdomains without ever touching the target's DNS servers. Perfect for initial reconnaissance.

**Day 3-4: Active Enumeration**

```bash
# DNS brute-forcing with custom wordlist
amass enum -d target.com \\
    -brute \\
    -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-110000.txt \\
    -o brute-results.txt
```

**Key Learning:** Active enumeration discovers subdomains that passive sources miss. The wordlist matters - bigger isn't always better.

**Day 5-7: API Integration**

```bash
# Create config file
mkdir -p ~/.config/amass
cat > ~/.config/amass/config.yaml << 'EOF'
data_sources:
  - name: VirusTotal
    creds:
      apikey: YOUR_API_KEY
  
  - name: Shodan
    creds:
      apikey: YOUR_API_KEY
  
  - name: Censys
    creds:
      apikey: YOUR_API_ID
      secret: YOUR_API_SECRET
EOF
```

**Key Learning:** Free API keys (VirusTotal, Shodan free tier, Censys free tier) increase results by 30-40%.

### Week 2: Advanced Techniques

**Day 8-10: Permutation Attacks**

```bash
# Find variations: api-dev, dev-api, api2, api-v2, etc.
amass enum -d target.com \\
    -brute \\
    -w /usr/share/seclists/Discovery/DNS/dns-Jhaddix.txt \\
    -o permutations.txt
```

**Key Learning:** Companies love creating subdomains like `api-v2-staging-dev`. Permutation attacks find these convoluted names.

**Day 11-14: Continuous Monitoring**

```bash
# Set up monitoring for new subdomains
amass track -d target.com -dir ./amass-tracking

# Check weekly for changes
amass track -d target.com -last 7 -dir ./amass-tracking
```

**Key Learning:** Subdomains appear and disappear. Continuous monitoring catches new assets within hours of creation.

### Week 3: Integration and Automation

**Day 15-21: Building the Perfect Pipeline**

Alex created a comprehensive reconnaissance pipeline:

```bash
#!/bin/bash
# ultimate-recon.sh

TARGET=$1
OUTPUT_DIR="recon-$TARGET-$(date +%Y%m%d)"
mkdir -p $OUTPUT_DIR

echo "[+] Starting comprehensive recon for $TARGET"

# Step 1: Passive enumeration (silent)
echo "[+] Passive enumeration..."
amass enum -d $TARGET -passive -o $OUTPUT_DIR/passive.txt

# Step 2: Active brute-forcing
echo "[+] Active brute-forcing..."
amass enum -d $TARGET -brute -w wordlist.txt -o $OUTPUT_DIR/brute.txt

# Step 3: Find live hosts
echo "[+] Probing for live hosts..."
cat $OUTPUT_DIR/passive.txt $OUTPUT_DIR/brute.txt | sort -u | \
  httpx -o $OUTPUT_DIR/live.txt

# Step 4: Port scanning
echo "[+] Port scanning..."
naabu -list $OUTPUT_DIR/live.txt -p 80,443,8080,8443 \
  -o $OUTPUT_DIR/ports.txt

# Step 5: Screenshotting
echo "[+] Taking screenshots..."
cat $OUTPUT_DIR/live.txt | aquatone -out $OUTPUT_DIR/screenshots

echo "[+] Done! Results in $OUTPUT_DIR/"
```

**Key Learning:** Tools work better together. Amass → httpx → naabu → aquatone creates a complete attack surface map.

### Week 4: The Breakthrough

**Day 22-28: Applying Knowledge**

Alex started testing the new methodology on real targets. The results were immediate:

| Target | Old Method | Amass Method | New Subdomains |
|--------|-----------|--------------|----------------|
| Bank A | 145 | 612 | 467 |
| Tech B | 89 | 423 | 334 |
| Health C | 234 | 891 | 657 |
| Finance D | 178 | 734 | 556 |

**Average improvement: 4.2x more subdomains.**

But the real test was yet to come.

---

## The Ordeal: The Critical Discovery

### Day 29: The Forgotten Subdomain

Alex picked a new target: a major e-commerce platform. Following the new methodology:

```bash
# Run the complete pipeline
./ultimate-recon.sh ecommerce-giant.com
```

The results came back: **743 subdomains.**

While reviewing the list, something caught Alex's eye:

```
...
admin.ecommerce-giant.com
api.ecommerce-giant.com
staging.ecommerce-giant.com
dev-admin.ecommerce-giant.com
legacy-api.ecommerce-giant.com
backup.ecommerce-giant.com          ← What?
...
```

**Backup.ecommerce-giant.com**

That subdomain wasn't in any previous scans. It wasn't on Shodan. It wasn't in certificate logs. Amass's permutation engine had generated it and DNS resolution confirmed it existed.

### The Investigation

Navigating to `https://backup.ecommerce-giant.com`, Alex found an exposed backup server. Not just any backup server - a **database backup interface** with no authentication.

```
Directory listing:
- 2024-01-15_full_backup.sql.gz
- 2024-02-01_customer_data.sql.gz
- 2024-02-15_transactions.sql.gz
- admin_credentials_backup.json
```

**2.3 million customer records.** Credit card tokens. Admin credentials. Everything.

The subdomain had been created six months ago for a database migration and forgotten. No one had tested it. No one had secured it. It was just... there. Waiting.

### The Realization

If Alex had used the old method (Subfinder only), this subdomain would never have been found. Subfinder's wordlist didn't include "backup" as a permutation. Amass's intelligent permutation engine did.

**This was the $8,000 subdomain.**

---

## The Transformation: From Struggling to Successful

### The Report

Alex submitted a comprehensive report:

```
Title: Exposed Database Backup Server with 2.3M Customer Records

Severity: Critical
CVSS: 9.1

Summary:
The subdomain backup.ecommerce-giant.com hosts an unsecured backup 
server containing database dumps with 2.3 million customer records, 
credit card tokens, and administrative credentials. No authentication 
is required to access these backups.

Steps to Reproduce:
1. Navigate to https://backup.ecommerce-giant.com
2. Observe directory listing of database backups
3. Download any backup file without authentication
4. Extract customer PII, transaction data, and admin credentials

Impact:
- 2.3 million customer records exposed
- Credit card tokens accessible
- Administrative credentials in plaintext
- GDPR/CCPA violations
- Potential PCI-DSS fines

Timeline:
- Discovered: Day 29 of testing
- Reported: Immediate
- Fixed: Within 24 hours
```

### The Bounty

Three days later:

> "Thank you for this critical finding. The backup server was created 
> during a migration six months ago and accidentally left exposed. 
> Your report prevented a potential data breach affecting millions of 
> customers. Bounty awarded: $8,000."

**More than the previous three months combined.**

---

## The Return: Sharing the Knowledge

### The 30-Day Transformation Stats

**Before Amass:**
- Subdomains per target: ~120
- Duplicate rate: 60%
- Valid bugs found: 2
- Total earnings: $850
- Confidence: Low

**After Amass:**
- Subdomains per target: ~600
- Duplicate rate: 15%
- Valid bugs found: 7
- Total earnings: $12,400 (including the $8K)
- Confidence: High

**The difference:** One tool. One methodology. One forgotten subdomain.

### What Alex Learned

**Lesson 1: Tools Matter**
Not all tools are created equal. Amass isn't just "another subdomain finder" - it's a comprehensive attack surface mapping platform.

**Lesson 2: Methodology Beats Luck**
The old approach was "run tool, test results." The new approach is "comprehensive reconnaissance, systematic testing, continuous monitoring."

**Lesson 3: The Hidden Gems**
The most valuable vulnerabilities aren't on `www.target.com` or `api.target.com`. They're on `backup.target.com`, `dev-old.target.com`, `migration-2023.target.com`.

**Lesson 4: Permutations Are Gold**
Companies are messy. They create subdomains with inconsistent naming. Permutation attacks find these inconsistencies.

---

## Your Complete Amass Playbook

### Quick Start (5 Minutes)

```bash
# Install
sudo snap install amass

# First scan
amass enum -d target.com

# Save results
amass enum -d target.com -o domains.txt
```

### The Advanced Methodology (30 Minutes)

```bash
# Step 1: Configure APIs (one-time setup)
cat > ~/.config/amass/config.yaml << 'EOF'
data_sources:
  - name: VirusTotal
    creds:
      apikey: YOUR_API_KEY
  - name: Shodan
    creds:
      apikey: YOUR_API_KEY
  - name: Censys
    creds:
      apikey: YOUR_API_KEY
      secret: YOUR_SECRET
EOF

# Step 2: Comprehensive enumeration
amass enum -d target.com -config ~/.config/amass/config.yaml -o all-domains.txt

# Step 3: Find live hosts
cat all-domains.txt | httpx -o live-hosts.txt

# Step 4: Set up monitoring
amass track -d target.com -dir ./tracking
```

### Pro Tips from the Journey

💡 **Tip #1: Use Multiple Wordlists**
```bash
# Combine multiple wordlists for comprehensive coverage
amass enum -d target.com -brute \\
  -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-110000.txt \\
  -w /usr/share/seclists/Discovery/DNS/dns-Jhaddix.txt \\
  -o comprehensive.txt
```

💡 **Tip #2: Visualize the Results**
```bash
# Generate attack surface visualization
amass viz -d target.com -o attack-surface.html

# Open in browser to see relationships
firefox attack-surface.html
```

💡 **Tip #3: Monitor for Changes**
```bash
# Add to crontab for weekly checks
0 0 * * 0 amass track -d target.com -last 7 -dir ~/tracking
```

💡 **Tip #4: Filter Results**
```bash
# Focus on interesting subdomains
cat domains.txt | grep -E 'admin|api|dev|staging|backup|internal|test'
```

💡 **Tip #5: Combine with Other Tools**
```bash
# Ultimate pipeline
amass enum -d target.com -o domains.txt
subfinder -d target.com -o subfinder.txt
cat domains.txt subfinder.txt | sort -u | httpx | naabu
```

---

## Tools Comparison: Why Amass Wins

| Feature | Amass | Subfinder | [Assetfinder](https://cipherops.gitbook.io/bug-bounty-notes/recon-tips/series-on-the-power-of-reconnaissance-tools/tool-3-assetfinder-subdomain-enumeration-tool-manual) | Amass Advantage |
|---------|-------|-----------|-------------|-----------------|
| Data Sources | 80+ | 50+ | 10+ | 60% more sources |
| Passive Only | ✅ | ✅ | ✅ | Same |
| Active Brute | ✅ | ❌ | ❌ | Finds hidden subs |
| Permutations | ✅ | ❌ | ❌ | Intelligent generation |
| Visualization | ✅ | ❌ | ❌ | Attack surface maps |
| Monitoring | ✅ | ❌ | ❌ | Track changes over time |
| API Integration | Extensive | Basic | None | Better results |
| Speed | Medium | Fast | Very Fast | Trade-off for depth |

**Verdict:** Use Amass for comprehensive reconnaissance. Use Subfinder/Assetfinder for quick checks. But when it matters, Amass finds what others miss.

---

## The Challenge: Your 30-Day Journey

### Week 1: Foundation

**Day 1:** Install Amass  
**Day 2:** Run first passive scan  
**Day 3:** Set up API keys  
**Day 4:** Try active enumeration  
**Day 5:** Compare results with your old tool  
**Day 6:** Document findings  
**Day 7:** Review and reflect

### Week 2: Mastery

**Day 8:** Learn permutation attacks  
**Day 9:** Try different wordlists  
**Day 10:** Visualize attack surface  
**Day 11:** Set up monitoring  
**Day 12:** Build automation script  
**Day 13:** Test on 3 new targets  
**Day 14:** Document methodology

### Week 3: Application

**Day 15-21:** Apply to real bug bounty targets  
**Goal:** Find 10 new subdomains per target that your old method missed

### Week 4: The Test

**Day 22-28:** Look for that one hidden subdomain  
**Day 29:** Submit your first Amass-powered report  
**Day 30:** Share your story

---

## Your Next Steps

### If You're a Beginner:

**Start here:** [Setting Up Your First Bug Bounty Lab](**coming soon**)  
**Then learn:** [How to Find Your First Bug](https://cipherops.gitbook.io/bug-bounty-notes/~/revisions/rFD8Jb0Le1iFtaJZ7rD9/readme/bug-bounty-platforms-compared-where-to-hunt-in-2026)

### If You're Intermediate:

**Next tool:** [Nuclei for Vulnerability Scanning](https://cipherops.gitbook.io/bug-bounty-notes/~/revisions/OFMFgVhvJXTppHDgTUPa/tools/nuclei-the-vulnerability-scanner-that-changed-bug-bounty)  
**Next technique:** [Advanced Recon Methodology](https://cipherops.gitbook.io/bug-bounty-notes/~/revisions/rFD8Jb0Le1iFtaJZ7rD9/recon-tips/best-recon-technique-for-active-subdomain-enumeration)

### If You're Advanced:

**Challenge:** [Finding Vulnerabilities in Cloud Infrastructure](**coming soon**)  
**Next level:** [Chaining Vulnerabilities for Maximum Impact](**coming soon**)

---

## Resources

### Official Documentation
- [Amass GitHub](https://github.com/[OWASP](https://cipherops.gitbook.io/bug-bounty-notes/web-application/top-100-web-vulnerabilities)/Amass)
- [Installation Guide](https://github.com/OWASP/Amass/blob/master/doc/install.md)
- [User Guide](https://github.com/OWASP/Amass/blob/master/doc/user_guide.md)

### API Keys (Free Tiers)
- [VirusTotal](https://www.virustotal.com) - Free account
- [Shodan](https://www.shodan.io) - Free tier (100 credits/month)
- [Censys](https://search.censys.io) - Free tier (250 queries/month)
- [Chaos](https://chaos.projectdiscovery.io) - Free for researchers
https://cipherops.gitbook.io/bug-bounty-notes/~/revisions/OFMFgVhvJXTppHDgTUPa/tools/nuclei-the-vulnerability-scanner-that-changed-bug-bounty
### Wordlists
- [SecLists](https://github.com/danielmiessler/SecLists) - DNS wordlists
- [Assetnote](https://wordlists-cdn.assetnote.io) - Updated wordlists
- [DNS-Jhaddix](https://gist.github.com/jhaddix) - Comprehensive list

### Related Tools
- [httpx](**coming soon**) - Fast HTTP prober
- [naabu](**coming soon**) - Port scanner
- [aquatone](**coming soon**) - Screenshot tool
- [nuclei](https://cipherops.gitbook.io/bug-bounty-notes/~/revisions/OFMFgVhvJXTppHDgTUPa/tools/nuclei-the-vulnerability-scanner-that-changed-bug-bounty) - Vulnerability scanner

---

## Final Thoughts

Alex's story isn't unique. Every day, bug bounty hunters discover that the right tool, combined with the right methodology, transforms their results.

**Amass isn't magic.** It's just better.

Better data sources. Better algorithms. Better results.

The $8,000 bounty wasn't luck. It was the inevitable result of comprehensive reconnaissance meeting a vulnerable target.

**Your forgotten subdomain is out there.**

The question is: Will you find it with Amass, or will someone else find it first?

---

*Published: February 27, 2024*  
*Last Updated: February 27, 2024*  
*Tool Version: Amass 4.0+*  
*Reading Time: 15 minutes*  
*Author: CipherOps Team*

---

**Ready to start your journey?** Download Amass now and find your first hidden subdomain.

**Questions?** Join our [Telegram community](https://t.me/bugbounty_tech) where we discuss the latest tools and techniques.

**Share your story:** Found an amazing subdomain with Amass? Tell us about it!

---
