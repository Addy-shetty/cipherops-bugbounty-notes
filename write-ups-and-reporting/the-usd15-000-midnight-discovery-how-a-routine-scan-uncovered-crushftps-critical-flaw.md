---
icon: cloud-check
cover: >-
  https://images.unsplash.com/photo-1772442164006-ba1b8e7bfc32?crop=entropy&cs=srgb&fm=jpg&ixid=M3wxOTcwMjR8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NzM2NDI2NTh8&ixlib=rb-4.1.0&q=85
coverY: 0
---

# The $15,000 CrushFTP Discovery (CVE-2024-4040)

How a newly disclosed critical CVE, matched against an old recon note, turned into a $15,000 bounty in a single night — and what the vulnerability actually is. Everything here is for education and responsible disclosure only; never test systems you don't own or have explicit permission to test.

***

### The setup

A CVE alert landed for CrushFTP: unauthenticated remote code execution, CVSS 9.8, already being exploited in the wild. CrushFTP is enterprise file-transfer software used by large companies, government agencies, and financial institutions — so an unauthenticated RCE in it is about as serious as it gets.

The name rang a bell. Three weeks earlier, during recon on a financial-services target, I'd noted a subdomain running an enterprise file-transfer service on port 9090 and moved on because it wasn't my focus at the time. With the CVE fresh, that forgotten note was suddenly the whole game. The lesson that keeps proving itself: **good notes save hunts.**

***

### Confirming it (passively)

The first rule is don't test what you can't safely verify. Passive checks only, starting with a banner grab:

```bash
# Is the service actually CrushFTP?
curl -s -I https://ftp-transfer.target.com:9090/ | grep -i server
# -> Server: CrushFTP Server
```

Then the version, read straight off the login page:

```bash
curl -s https://ftp-transfer.target.com:9090/WebInterface/login.html | \
  grep -oE 'CrushFTP [0-9]+\.[0-9]+\.[0-9]+'
# -> CrushFTP 10.7.0
```

Vulnerable versions are 10.7.1 and below and 11.1.0 and below, so 10.7.0 was in scope. That was enough to confirm exposure without sending a single exploit attempt.

***

### What the vulnerability is

CVE-2024-4040 is a server-side template injection / improper-access-control flaw in CrushFTP's web interface that lets an unauthenticated attacker read files outside the VFS sandbox and, in turn, achieve remote code execution. Because it needs no credentials and no internal access, a single internet-facing, unpatched instance is enough for full server compromise.

The impact chain from there is the serious part: full server access means potential exposure of the files it moves (often financial and customer data), theft of any credentials on the box, a pivot point into the internal network, and — on a cloud host — access to the instance metadata service and its cloud credentials.

***

### Responsible disclosure

I did **not** exploit it. Confirming the vulnerable version against a known-vulnerable release was sufficient to report. The write-up that went in covered a short executive summary, the technical details, a safe proof (version confirmation, not a working exploit), the impact assessment, remediation steps, and a timeline:

```
Title: Unauthenticated RCE in CrushFTP (CVE-2024-4040)
Severity: Critical (CVSS 9.8)
Affected: ftp-transfer.target.com:9090, CrushFTP 10.7.0

Summary:
The server runs a CrushFTP version vulnerable to CVE-2024-4040,
an unauthenticated flaw allowing file read outside the sandbox
and remote code execution.

Impact:
- Complete server compromise
- Access to transferred financial files
- Potential credential theft and lateral movement
- Cloud metadata / credential exposure if cloud-hosted

Recommended actions:
1. Update to a patched CrushFTP release immediately
2. Restrict access with IP whitelisting
3. Enable detailed logging and review access logs
```

The vendor's program confirmed it as critical, shipped an emergency patch the same day, and approved a **$15,000** bounty.

***

### Detection and prevention

**Passive detection (safe):**

```bash
# Version from the login page
curl -s https://target.com:9090/WebInterface/login.html | grep -i crushftp

# Banner
curl -s -I https://target.com:9090/ | grep Server
```

**Active detection (authorized targets only)** — a public Nuclei template exists for this CVE:

```bash
nuclei -u https://target.com:9090 -t http/cves/2024/CVE-2024-4040.yaml
```

**For defenders:** update to a patched CrushFTP release right away. If you can't patch immediately, restrict access with IP whitelisting or pull external access temporarily, and review access logs for signs of exploitation. Longer term, subscribe to CrushFTP's security advisories and run automated vulnerability scanning against your own perimeter so you learn about exposure before an attacker does.

***

### Takeaways

* **An information edge is real.** Subscribing to CVE feeds meant acting on this within the day it dropped.
* **Document everything.** A three-week-old throwaway note about a subdomain is what made this fast.
* **Disclose responsibly.** Confirming the version was enough; there was no need to exploit financial data to prove impact.
* **Automate CVE checks** against your target list so matches surface without waiting on a notification.

***

### Resources

* [NVD — CVE-2024-4040](https://nvd.nist.gov/vuln/detail/CVE-2024-4040)
* [CISA Known Exploited Vulnerabilities catalog](https://www.cisa.gov/known-exploited-vulnerabilities-catalog)
* [CrushFTP security advisory](https://www.crushftp.com/crush10wiki/Wiki.jsp?page=Security)

**Related on this site:**

* [Nuclei — the vulnerability scanner](../tools/nuclei-the-vulnerability-scanner-that-changed-bug-bounty.md)
* [The Amass complete guide](../tools/the-usd8-000-subdomain-that-changed-everything-a-bug-hunters-journey-with-amass.md)
* [Setting Up Your First Bug Bounty Lab](../getting-started/how-to-guide-setting-up-your-first-bug-bounty-lab.md)

_Questions about the technical details? Join the_ [_Telegram community_](https://t.me/bugbounty_tech)_._
