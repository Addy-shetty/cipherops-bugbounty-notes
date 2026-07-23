# 50 Copy-Paste Recon Commands That Find Bugs

**Skill Level:** All Levels  
**Time:** Copy in 5 minutes, master in a week  
**Updated:** 2026-02-26

---

## 🎯 Quick Navigation

| Category | Commands | Time |
|----------|----------|------|
| [Subdomain Discovery](#subdomain-discovery) | 1-15 | 2 min |
| [Live Host Detection](#live-host-detection) | 16-25 | 1 min |
| [Port Scanning](#port-scanning) | 26-35 | 2 min |
| [Content Discovery](#content-discovery) | 36-45 | 2 min |
| [AI-Powered](#ai-powered-commands) | 46-50 | 2 min |

---

## Subdomain Discovery (1-15)

### Passive Enumeration (No DNS Queries)

```bash
# 1. Subfinder with all sources
subfinder -d target.com -all -silent -o subs.txt

# 2. Amass passive enumeration
amass enum -passive -d target.com -o amass.txt

# 3. Assetfinder (fast)
assetfinder --subs-only target.com | tee assetfinder.txt

# 4. Findomain (high performance)
findomain -t target.com -o findomain.txt

# 5. Chaos (ProjectDiscovery dataset)
chaos -d target.com -silent -o chaos.txt

# 6. GitHub subdomain search
github-subdomains -d target.com -t YOUR_GITHUB_TOKEN | tee github_subs.txt

# 7. Wayback Machine URLs
echo "target.com" | waybackurls | grep -oE "[a-zA-Z0-9_-]+\.target\.com" | sort -u > wayback_subs.txt

# 8. CRT.sh certificate transparency
curl -s "https://crt.sh/?q=%25.target.com&output=json" | jq -r '.[].name_value' | sort -u > crtsh.txt

# 9. BufferOver DNS
curl -s "https://dns.bufferover.run/dns?q=.target.com" | jq -r '.FDNS_A[]' | cut -d',' -f2 | sort -u > bufferover.txt

# 10. ThreatCrowd
curl -s "https://www.threatcrowd.org/searchApi/v2/domain/report/?domain=target.com" | jq -r '.subdomains[]' > threatcrowd.txt

# 11. AlienVault OTX
curl -s "https://otx.alienvault.com/api/v1/indicators/domain/target.com/passive_dns" | jq -r '.passive_dns[]?.hostname' | sort -u > alienvault.txt

# 12. Riddler.io
curl -s "https://riddler.io/search/exportcsv?q=pld:target.com" | grep -oE "[a-zA-Z0-9_-]+\.target\.com" | sort -u > riddler.txt

# 13. SecurityTrails (API key required)
curl -s "https://api.securitytrails.com/v1/domain/target.com/subdomains" -H "APIKEY: YOUR_API_KEY" | jq -r '.subdomains[]' > securitytrails.txt

# 14. Combine all passive sources
cat subs.txt amass.txt assetfinder.txt findomain.txt chaos.txt github_subs.txt wayback_subs.txt crtsh.txt bufferover.txt threatcrowd.txt alienvault.txt riddler.txt securitytrails.txt 2>/dev/null | sort -u > all_passive_subs.txt

# 15. Count unique subdomains
wc -l all_passive_subs.txt
```

---

## Live Host Detection (16-25)

```bash
# 16. Fast HTTP probing
httpx -l all_passive_subs.txt -silent -o live_hosts.txt

# 17. HTTPX with status codes
httpx -l all_passive_subs.txt -status-code -silent -o hosts_status.txt

# 18. HTTPX with title extraction
httpx -l all_passive_subs.txt -title -silent -o hosts_title.txt

# 19. HTTPX with technology detection
httpx -l all_passive_subs.txt -tech-detect -silent -o hosts_tech.txt

# 20. HTTPX with response time
httpx -l all_passive_subs.txt -response-time -silent -o hosts_response.txt

# 21. HTTPX with web server detection
httpx -l all_passive_subs.txt -web-server -silent -o hosts_server.txt

# 22. HTTPX with content type
httpx -l all_passive_subs.txt -content-type -silent -o hosts_content.txt

# 23. HTTPX with final URL (follow redirects)
httpx -l all_passive_subs.txt -follow-redirects -silent -o hosts_final.txt

# 24. HTTPX with IP resolution
httpx -l all_passive_subs.txt -ip -silent -o hosts_ip.txt

# 25. HTTPX with CDN detection
httpx -l all_passive_subs.txt -cdn -silent -o hosts_cdn.txt
```

**Combined Output:**
```bash
# Get everything in one command
httpx -l all_passive_subs.txt -status-code -title -tech-detect -web-server -ip -silent -o hosts_full.txt
```

---

## Port Scanning (26-35)

```bash
# 26. Top 100 ports (fast)
naabu -list live_hosts.txt -top-ports 100 -silent -o ports_top100.txt

# 27. Common web ports
naabu -list live_hosts.txt -p 80,443,8080,8443,3000,5000,8000,9000 -silent -o ports_web.txt

# 28. Full port scan (slow)
naabu -list live_hosts.txt -p - -silent -o ports_all.txt

# 29. Nmap top ports with service detection
nmap -iL live_hosts.txt --top-ports 100 -sV -oN nmap_top100.txt

# 30. Nmap quick scan
nmap -iL live_hosts.txt -F -oN nmap_quick.txt

# 31. Masscan (very fast but noisy)
masscan -iL live_hosts.txt -p1-65535 --rate=1000 -oL masscan.txt

# 32. Find open RDP
naabu -list live_hosts.txt -p 3389 -silent -o ports_rdp.txt

# 33. Find open SSH
naabu -list live_hosts.txt -p 22 -silent -o ports_ssh.txt

# 34. Find open SMB
naabu -list live_hosts.txt -p 445 -silent -o ports_smb.txt

# 35. Find open Databases
naabu -list live_hosts.txt -p 3306,5432,1433,27017,6379,9200 -silent -o ports_db.txt
```

---

## Content Discovery (36-45)

```bash
# 36. Directory brute force (fast)
feroxbuster -u https://target.com -w /usr/share/wordlists/dirb/common.txt -t 50 -o dirs_fast.txt

# 37. Directory brute force (comprehensive)
feroxbuster -u https://target.com -w /usr/share/wordlists/seclists/Discovery/Web-Content/raft-large-directories.txt -t 30 -o dirs_full.txt

# 38. File discovery
feroxbuster -u https://target.com -w /usr/share/wordlists/seclists/Discovery/Web-Content/raft-large-files.txt -t 30 -o files.txt

# 39. API endpoint discovery
feroxbuster -u https://target.com -w /usr/share/wordlists/seclists/Discovery/Web-Content/api/api-endpoints.txt -o api.txt

# 40. Backup file search
ffuf -u https://target.com/FUZZ -w /usr/share/wordlists/seclists/Discovery/Web-Content/backup_files.txt -mc 200 -o backups.txt

# 41. Git directory exposure
ffuf -u https://target.com/.git/FUZZ -w /usr/share/wordlists/seclists/Discovery/Web-Content/common.txt -mc 200 -o git_exposed.txt

# 42. Config file discovery
ffuf -u https://target.com/FUZZ -w /usr/share/wordlists/seclists/Discovery/Web-Content/config_files.txt -mc 200 -o configs.txt

# 43. JavaScript endpoint extraction
getJS -input live_hosts.txt -output js_files.txt && cat js_files.txt | xargs -I {} curl -s {} | grep -oE "(https?://[^\" ]+|/[^\" ]*)" | sort -u > js_endpoints.txt

# 44. Wayback URLs with parameters
cat live_hosts.txt | waybackurls | grep "?" | sort -u > wayback_params.txt

# 45. Parameter discovery with Arjun
arjun -u https://target.com -oT arjun_params.txt
```

---

## AI-Powered Commands (46-50)

```bash
# 46. AI subdomain wordlist generator
python3 << 'EOF'
import openai
openai.api_key = "YOUR_API_KEY"

target = "target.com"
prompt = f"Generate 50 subdomain prefixes for {target} including environments, services, and regions. One per line."

response = openai.ChatCompletion.create(
    model="gpt-3.5-turbo",
    messages=[{"role": "user", "content": prompt}]
)

print(response.choices[0].message.content)
EOF

# 47. AI-powered Google Dorks generator
python3 << 'EOF'
import openai
openai.api_key = "YOUR_API_KEY"

target = "target.com"
prompt = f"Generate 10 Google dorks to find sensitive information about {target}. Include searches for exposed documents, GitHub repos, API docs."

response = openai.ChatCompletion.create(
    model="gpt-3.5-turbo",
    messages=[{"role": "user", "content": prompt}]
)

print(response.choices[0].message.content)
EOF

# 48. AI analysis of technology stack
python3 << 'EOF'
import openai
openai.api_key = "YOUR_API_KEY"

# Read technology detection results
with open('hosts_tech.txt', 'r') as f:
    tech_data = f.read()

prompt = f"Analyze this technology stack and identify potential vulnerabilities and attack vectors:\n\n{tech_data}"

response = openai.ChatCompletion.create(
    model="gpt-4",
    messages=[{"role": "user", "content": prompt}]
)

print(response.choices[0].message.content)
EOF

# 49. AI report generation from findings
python3 << 'EOF'
import openai
openai.api_key = "YOUR_API_KEY"

# Read all findings
with open('live_hosts.txt', 'r') as f:
    hosts = f.read()

with open('ports_top100.txt', 'r') as f:
    ports = f.read()

prompt = f"Generate a reconnaissance summary report including:\n1. Total hosts discovered\n2. Interesting ports\n3. Technology stack analysis\n4. Recommended next steps\n\nHosts:\n{hosts}\n\nPorts:\n{ports}"

response = openai.ChatCompletion.create(
    model="gpt-4",
    messages=[{"role": "user", "content": prompt}]
)

print(response.choices[0].message.content)
EOF

# 50. Complete AI-powered automation pipeline
bash << 'EOF'
#!/bin/bash
# ai_recon_pipeline.sh
TARGET=$1

# Run recon
echo "[*] Starting recon for $TARGET"
subfinder -d $TARGET -all -silent | tee subs.txt
httpx -l subs.txt -tech-detect -silent | tee hosts.txt

# AI Analysis
python3 << 'PYEOF'
import openai
openai.api_key = "YOUR_API_KEY"

with open('hosts.txt', 'r') as f:
    data = f.read()

prompt = f"Analyze this recon data and identify the top 5 targets to investigate:\n\n{data}"

response = openai.ChatCompletion.create(
    model="gpt-4",
    messages=[{"role": "user", "content": prompt}]
)

with open('ai_priorities.txt', 'w') as f:
    f.write(response.choices[0].message.content)

print("[+] AI Analysis saved to ai_priorities.txt")
PYEOF
EOF
chmod +x ai_recon_pipeline.sh
```

---

## 🎯 Master One-Liners

### Complete Recon in One Command
```bash
# Ultimate one-liner (passive only, safe)
subfinder -d target.com -all -silent | httpx -silent -tech-detect | tee results.txt

# With active enumeration (be careful with scope)
subfinder -d target.com -all -silent | dnsx -silent | httpx -silent | feroxbuster --stdin -w common.txt

# AI-enhanced pipeline
subfinder -d target.com -all -silent | tee subs.txt | httpx -silent -tech-detect | tee hosts.txt | python3 -c "
import openai, sys
openai.api_key = 'YOUR_KEY'
data = sys.stdin.read()
print(openai.ChatCompletion.create(model='gpt-4', messages=[{'role': 'user', 'content': f'Analyze: {data}'}]).choices[0].message.content)
"
```

---

## 📊 Infographic: Command Categories

![Command Categories](images/command-categories.png)
*Visual breakdown of the 50 commands by category*

---

## ⚡ Quick Tips

### Tip 1: Always Check Scope
```bash
# Filter out-of-scope domains
cat all_subs.txt | grep -v "out-of-scope.com" | tee in_scope.txt
```

### Tip 2: Rate Limiting
```bash
# Add delays to avoid bans
httpx -l subs.txt -rate-limit 50 -silent
```

### Tip 3: Save Progress
```bash
# Resume if interrupted
subfinder -d target.com -all -silent | anew subs.txt
```

### Tip 4: Use tmux for Long Scans
```bash
# Start session
tmux new -s recon
# Run commands
# Detach: Ctrl+B, D
# Reattach: tmux attach -t recon
```

### Tip 5: Parallel Execution
```bash
# Run multiple tools simultaneously
subfinder -d target.com -silent &
amass enum -passive -d target.com &
assetfinder target.com &
wait
```

---

## 🚀 Next Steps

After running these commands:
1. Analyze results with [AI Analysis Guide →](02_AI_Analysis.md)
2. Start web testing with [OWASP Testing →](../03_Web_Application_Testing/01_OWASP_Testing_Guide.md)
3. Automate with [Recon Automation Pipeline →](01_AI_Powered_Reconnaissance.md#ai-automation-pipeline)

---

## 📥 Download

- [PDF Cheat Sheet](downloads/50-commands-cheatsheet.pdf)
- [Copy-Paste Script](downloads/50-commands.sh)
- [Wallpaper Version](images/50-commands-wallpaper.png)

---

*Use responsibly. Always check scope and get proper authorization before testing.*

*Last Updated: 2026-02-26 • Share: [Twitter](https://twitter.com/intent/tweet?text=50%20Copy-Paste%20Recon%20Commands) • [GitHub](https://github.com/CipherOps/bug-bounty-notes)*


---

## 📚 Related Guides
- 🔍 [50 Copy-Paste Recon Commands](02_50_Copy_Paste_Commands.md) — Quick reference
- 🔍 [Subdomain Enumeration Deep Dive](03_Subdomain_Enumeration_Deep_Dive.md) — Go deeper
- 🛠️ [Nmap Complete Guide](../tool-deep-dives/02_Nmap_Complete_Guide.md) — Next: scan your targets

---

*Part of the [CipherOps Bug Bounty Notes](https://cipherops.gitbook.io/bug-bounty-notes/) — your guide from zero to first bounty.*

