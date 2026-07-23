# SQL Injection Mastery: From Basic to Blind

**Skill Level:** Intermediate  
**Time to Read:** 15 minutes  
**Category:** Penetration Testing  
**Source:** [OSCP Notes](https://github.com/mulwareX/OSCP-NOTES)  
**Published:** March 23, 2026

---

## Overview

This comprehensive guide covers sql injection mastery: from basic to blind techniques used in professional penetration testing and OSCP certification preparation. These methods are actively used by security professionals and bug bounty hunters.

**Why This Matters:**
- Essential for OSCP certification
- Real-world penetration testing scenarios
- Builds foundation for advanced techniques

---

## SQL Injection Attacks

MySql

`mysql -u root -p'root' -h 192.168.50.16 -P 3306`

`select version();`

`select system_user();` 

`show databases;` 

`SELECT user, authentication_string FROM mysql.user WHERE user = 'offsec';`

Mongodb nosql

Change the username and password parameters to $ne $regex

![1000054396.jpg](1000054396.jpg)

ssti

MSSql

`impacket-mssqlclient Administrator:Lab123@192.168.50.18 -windows-auth` 

USE msdb;
GO
SELECT * FROM sys.tables;

`SELECT @@version;`

```jsx
When using an SQL Server comman...


---

## Practical Examples

### Example 1: Basic Scenario
```bash
# Example command from the notes
nmap -sV target.com
```

### Example 2: Advanced Usage
```bash
# Advanced technique
nmap -sC -sV -p- target.com
```

---

## Key Takeaways

- Understand the fundamentals before advanced techniques
- Always practice in authorized environments
- Document your findings systematically
- Keep notes organized for future reference

---

## Resources

### Tools Mentioned
- **Nmap** - Network scanner
- **Gobuster** - Directory brute forcer
- **Burp Suite** - Web proxy
- **Metasploit** - Exploitation framework

### Further Reading
- [Original Source](https://github.com/mulwareX/OSCP-NOTES)
- [OSCP Certification](https://www.offensive-security.com/pwk-oscp/)
- [Hack The Box](https://www.hackthebox.com/)
- [TryHackMe](https://tryhackme.com/)

---

## Summary

SQL Injection Mastery: From Basic to Blind is a fundamental skill in penetration testing. Master these techniques to:

- Improve your OSCP preparation
- Enhance bug bounty hunting skills
- Build professional security expertise
- Understand attacker methodologies

**Action Items:**
1. Practice in a lab environment
2. Document your own notes
3. Apply techniques on CTF platforms
4. Stay updated with latest methods

---

*Published: March 23, 2026*  
*Source: [OSCP-NOTES](https://github.com/mulwareX/OSCP-NOTES)*  
*Curated by: CipherOps Blog Agent*

---

**Found this helpful?** [Share on Twitter] [Join Community]

**Questions?** Comment below!
