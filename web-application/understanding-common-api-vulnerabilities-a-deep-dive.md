---
cover: >-
  https://images.unsplash.com/photo-1717703224683-82a4c6f73d3b?crop=entropy&cs=srgb&fm=jpg&ixid=M3wxOTcwMjR8MHwxfHJhbmRvbXx8fHx8fHx8fDE3MTk0NzI4NzJ8&ixlib=rb-4.0.3&q=85
coverY: 0
---

# 🅰️ Understanding Common API Vulnerabilities: A Deep Dive

APIs are the backbone of modern software, enabling communication and data exchange between systems. However, they come with their own set of vulnerabilities that can be exploited if not properly secured. This article delves into common API vulnerabilities, drawing from the OWASP API Security Top 10 and beyond, to help you identify and mitigate weaknesses during API testing.

### Table of Contents

1. [Information Disclosure](understanding-common-api-vulnerabilities-a-deep-dive.md#information-disclosure)
2. [Broken Object Level Authentication](understanding-common-api-vulnerabilities-a-deep-dive.md#broken-object-level-authentication-bola)
3. [Broken User Authentication](understanding-common-api-vulnerabilities-a-deep-dive.md#broken-user-authentication)
4. [Excessive Data Exposure](understanding-common-api-vulnerabilities-a-deep-dive.md#excessive-data-exposure)
5. [Lack of Resources and Rate Limiting](understanding-common-api-vulnerabilities-a-deep-dive.md#lack-of-resources-and-rate-limiting)
6. [Broken Function Level Authorization](understanding-common-api-vulnerabilities-a-deep-dive.md#broken-function-level-authorization-bfla)
7. [Mass Assignments](understanding-common-api-vulnerabilities-a-deep-dive.md#mass-assignments)
8. [Security Misconfiguration](understanding-common-api-vulnerabilities-a-deep-dive.md#security-misconfiguration)
9. [Injections](understanding-common-api-vulnerabilities-a-deep-dive.md#injections)
10. [Improper Assets Management](understanding-common-api-vulnerabilities-a-deep-dive.md#improper-assets-management)
11. [Business Logic Vulnerabilities](understanding-common-api-vulnerabilities-a-deep-dive.md#business-logic-vulnerabilities-blv)

### Information Disclosure

APIs can inadvertently disclose sensitive information due to inadequate error handling, improper logging, or configuration oversights. Here are common areas where information disclosure can occur:

1. **Error messages**: Detailed error messages can reveal database names, table names, or internal system paths.
2. **API responses**: Sensitive data may be included in API responses if not properly filtered.
3. **Log files**: Improper logging can expose sensitive information if logs are not secured.
4. **Configuration files**: These may contain sensitive details like database credentials or API keys.
5. **Source code comments**: Comments in source code can unintentionally reveal sensitive information.
6. **Directory listings**: Enabled directory listings can expose sensitive files.
7. **HTTP headers**: Misconfigured headers can reveal server or application details.
8. **Metadata and file properties**: Documents and files may contain metadata that reveals sensitive information.
9. **Backup files and archives**: Unsecured backup files can contain sensitive data.

#### Example

A site using WordPress API might unknowingly share information via the API path `/wp-json/wp/v2/users`, revealing all WordPress usernames.

```http
GET https://www.sitename.org/wp-json/wp/v2/users
```

**Response:**

```json
[
  {"id": 1, "name": "Administrator", "slug": "admin"},
  {"id": 2, "name": "Krishna", "slug": ""}
]
```

These usernames can be exploited for brute-force attacks or credential stuffing.

***

#### Error Messages

Verbose error messages help API consumers but can also reveal sensitive details about the API’s architecture, such as server versions or database types.

**Example:** Attempting to authenticate and receiving detailed error messages like "the provided user ID doesn’t exist" vs. "Incorrect Password" can help attackers confirm valid usernames and attempt password brute-forcing.

***

### Broken Object Level Authentication (BOLA)

BOLA occurs when API providers fail to enforce proper object-level access controls, allowing users to access resources they are not authorized to access.

#### Example

```json
{
  "id": "852",
  "name": "Radhe",
  "last_name": "Krishna",
  "link": "https://twitter.com/user/Radhekrishna.142",
  "username": "RadheKrishna.142"
}
```

If authenticated users can access data of others by manipulating object IDs, it indicates a BOLA vulnerability.

#### Detection

* Identify patterns in API paths and parameters.
* Test for unauthorized access by changing object IDs.

### Broken User Authentication

This occurs when there are weaknesses in the API's authentication process, such as poor token generation or handling methods.

#### Example

Collect samples of tokens to test their randomness. Weak token generation allows attackers to forge tokens and gain unauthorized access.

***

### Excessive Data Exposure

APIs may respond with more data than necessary, relying on consumers to filter the data.

#### Example

```json
{
  "id": "129",
  "name": "krishna",
  "privilege": "user",
  "representative": [
    {
      "id": "001",
      "name": "Radha",
      "email": "radha@krishna.vrindavan",
      "privilege": "super-admin",
      "admin": "true",
      "two_factor_auth": "false"
    }
  ]
}
```

A request for user data exposes additional information about related users.

#### Detection

* Review API responses for unnecessary data.
* Test target API endpoints to identify excessive data exposure.

### Lack of Resources and Rate Limiting

API providers should limit the number of requests to prevent system overload and denial of service attacks.

#### Bypass Techniques

* Altering parameters or headers.
* Using different clients or IP addresses.

***

### Broken Function Level Authorization (BFLA)

Occurs when users can access API functionality intended for higher privilege levels.

#### Example

A regular user accessing administrative functions by altering request endpoints or HTTP methods.

#### Detection

* Test admin functions as an unprivileged user.
* Examine API documentation for potential privileged actions.

### Mass Assignments

Happens when APIs accept more parameters than intended, allowing attackers to modify object properties.

#### Example

```json
{
  "user": "Narender",
  "password": "Passwd123",
  "isAdmin": true
}
```

#### Detection

* Check for unexpected parameters in API requests.
* Review API documentation and responses.

### Security Misconfiguration

Common misconfigurations include lack of input sanitization, misconfigured headers, and unnecessary HTTP methods.

#### Example

```json
X-Powered-By: Vulncure
X-XSS-Protection: 1
X-Response-Time: 453
```

#### Detection

* Identify misconfigured headers.
* Test for default credentials and unnecessary HTTP methods.

### Injections

Injection flaws occur when input is not properly sanitized, allowing malicious code execution.

#### Example

```json
POST /api/v1/register HTTP/1.1
{
  "Fname": "Narender",
  "Lname": "Hacker",
  "Address": "' OR 1=0-- -"
}
```

#### Detection

* Test API endpoints with crafted requests.
* Monitor API responses for error messages.

### Improper Assets Management

Exposing outdated or development APIs can lead to various vulnerabilities.

#### Detection

* Pay attention to API documentation and version history.
* Test older API versions for vulnerabilities.

### Business Logic Vulnerabilities (BLV)

Exploitable features due to flawed assumptions in application design.

#### Example

```json
POST /api/v1/login HTTP/1.1
UserID=narender&password=asdf123&MFA=true
```

Manipulating `MFA=true` to `MFA=false` to bypass multi-factor authentication.

#### Detection

* Understand the business logic and assumptions.
* Test features for potential misuse.

### Conclusion

Understanding and identifying these common API vulnerabilities is crucial for ensuring the security of your applications. By thoroughly testing and implementing proper security measures, you can protect your APIs from potential exploits and safeguard sensitive data.

***

**Command and Example**

To test for information disclosure, use a tool like curl or Postman to make API requests and analyze the responses for sensitive data.

```sh
curl -X GET "https://www.sitename.org/wp-json/wp/v2/users"
```

Analyze the JSON response for usernames and other sensitive information. Adjust your security settings to filter out or redact this data before it is sent in API responses.
