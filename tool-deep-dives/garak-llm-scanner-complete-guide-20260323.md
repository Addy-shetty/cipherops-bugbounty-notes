# Garak: The Ultimate LLM Vulnerability Scanner - Complete Guide

**Skill Level:** Intermediate to Advanced  
**Time to Read:** 12 minutes  
**Category:** AI Security  
**Tool Stars:** ⭐ 7.3K on GitHub  
**Published:** March 23, 2026

---

## Overview

**Garak** (Generative AI Red-teaming & Assessment Kit) is NVIDIA's open-source vulnerability scanner for Large Language Models (LLMs). Think of it as **Nmap or Metasploit, but specifically designed for AI systems**.

If you're testing AI applications, APIs, or custom LLMs for security vulnerabilities, Garak is an essential tool in your arsenal.

**Why This Matters:**
- LLM vulnerabilities are the next frontier in security testing
- High demand for AI security expertise (bug bounties: $500-$50,000)
- Garak automates detection of 20+ vulnerability types
- Used by security professionals and AI developers worldwide

---

## What is Garak?

Garak probes LLMs for **failures we don't want**:

- **Hallucination** - Making up false information
- **Data Leakage** - Exposing training data or secrets
- **Prompt Injection** - Bypassing safety controls
- **Jailbreaks** - Getting harmful outputs
- **Toxicity Generation** - Producing offensive content
- **Misinformation** - Spreading false narratives
- **Encoding Attacks** - Hidden malicious payloads

**Key Capabilities:**
- Tests 20+ LLM platforms (OpenAI, Hugging Face, AWS Bedrock, etc.)
- 50+ built-in vulnerability probes
- Automated attack generation
- JSON reporting for CI/CD integration
- Open source (Apache 2.0 license)

---

## Installation

### Quick Install (Recommended)

```bash
# Install from PyPI
python -m pip install -U garak

# Or install latest development version
python -m pip install -U git+https://github.com/NVIDIA/garak.git@main
```

### Development Install (for contributors)

```bash
conda create --name garak "python>=3.10,<=3.12"
conda activate garak
gh repo clone NVIDIA/garak
cd garak
python -m pip install -e .
```

**Requirements:**
- Python 3.10-3.12
- API keys for commercial models (OpenAI, Anthropic, etc.)

---

## Basic Usage

### Test a Model with All Probes

```bash
# Test Hugging Face model
python3 -m garak --target_type huggingface --target_name "gpt2"

# Test OpenAI model (requires OPENAI_API_KEY)
export OPENAI_API_KEY="sk-..."
python3 -m garak --target_type openai --target_name "gpt-3.5-turbo"
```

### Test Specific Vulnerability Types

```bash
# Test only for prompt injection
python3 -m garak --target_type openai --target_name "gpt-4" --probes promptinject

# Test encoding-based attacks
python3 -m garak --target_type openai --target_name "gpt-4" --probes encoding

# Test DAN (Do Anything Now) jailbreaks
python3 -m garak --target_type huggingface --target_name "gpt2" --probes dan

# Test for data leakage
python3 -m garak --target_type openai --target_name "gpt-4" --probes leakreplay
```

### List Available Probes

```bash
python3 -m garak --list_probes
```

---

## Supported LLM Platforms

Garak supports virtually every major LLM platform:

| Platform | Setup | Example Target |
|----------|-------|----------------|
| **OpenAI** | Set `OPENAI_API_KEY` | `gpt-4`, `gpt-3.5-turbo` |
| **Hugging Face** | Local or Inference API | `gpt2`, `meta-llama/Llama-2-7b` |
| **AWS Bedrock** | Set `BEDROCK_API_KEY` | `claude-3-sonnet` |
| **Replicate** | Set `REPLICATE_API_TOKEN` | `stability-ai/stablelm-tuned-alpha-7b` |
| **Cohere** | Set `COHERE_API_KEY` | `command` |
| **Groq** | Set `GROQ_API_KEY` | Any Groq-hosted model |
| **NVIDIA NIM** | Set `NIM_API_KEY` | `meta/llama-3.1-8b-instruct` |
| **Custom REST API** | YAML config file | Your internal API |
| **Local GGUF** | `llama.cpp` compatible | `/path/to/model.gguf` |

---

## Understanding the Results

Garak generates detailed reports showing:

```
Probe: encoding
Status: PASS/FAIL
Failure Rate: 45% (378/840 attempts)
```

**Result Types:**
- **PASS** - Model handled probe correctly (safe)
- **FAIL** - Model exhibited vulnerability
- **ERROR** - Probe execution failed

**Key Metrics:**
- Total attempts per probe
- Failure rate percentage
- Specific prompts that triggered failures
- Model responses for analysis

Reports are saved as:
- `garak.log` - Debug information
- `garak_report_*.jsonl` - Detailed run data
- `garak_hitlog_*.jsonl` - Only vulnerabilities found

---

## Real-World Testing Scenarios

### Scenario 1: Testing Your AI Chatbot

```bash
# Test company chatbot for prompt injection
python3 -m garak \
  --target_type rest \
  --target_name /path/to/config.yaml \
  --probes promptinject,encoding,dan
```

### Scenario 2: Red Team Assessment

```bash
# Comprehensive security audit
python3 -m garak \
  --target_type openai \
  --target_name "gpt-4" \
  --probes all
```

### Scenario 3: CI/CD Integration

```bash
# Automated testing in pipeline
python3 -m garak \
  --target_type huggingface \
  --target_name "your-model" \
  --probes leakreplay,toxicity \
  --report_prefix "security-scan-$(date +%Y%m%d)"
```

---

## Available Probes (Vulnerability Tests)

Garak includes 50+ vulnerability probes organized by category:

### Injection Attacks
- **promptinject** - Prompt injection framework
- **encoding** - Base64, ROT13, quoted-printable injection
- **gcg** - Greedy Coordinate Gradient attacks

### Jailbreak Attempts
- **dan** - DAN (Do Anything Now) variants
- **grandma** - Emotional manipulation attacks
- **goodside** - Riley Goodside's attack methods

### Data Safety
- **leakreplay** - Training data extraction
- **realtoxicityprompts** - Toxic content generation
- **continuation** - Undesirable word completion

### Output Quality
- **hallucination** - False information generation
- **misleading** - Misinformation support
- **snowball** - Complex question failures

### Security
- **malwaregen** - Malicious code generation
- **xss** - Cross-site scripting in outputs
- **av_spam_scanning** - Evasion technique attempts

---

## Advanced Configuration

### Custom REST API Testing

Create `config.yaml`:

```yaml
rest.RestGenerator:
  uri: "https://api.your-llm.com/v1/chat"
  method: "POST"
  headers:
    Authorization: "Bearer ${API_KEY}"
  req_template_json:
    messages:
      - role: user
        content: "$INPUT"
  response_json_field: "choices[0].message.content"
```

Run:
```bash
python3 -m garak --target_type rest --target_name config.yaml
```

### Custom Probes

Create your own probe in `garak/probes/`:

```python
from garak.probes.base import TextProbe

class MyCustomProbe(TextProbe):
    """Custom vulnerability test"""
    
    bcp47 = "en"
    recommended_detector = ["mydetector.MyDetector"]
    
    def __init__(self):
        super().__init__()
        self.prompts = [
            "Test prompt 1",
            "Test prompt 2",
        ]
```

---

## Bug Bounty Applications

**Companies actively paying for LLM vulnerabilities:**
- OpenAI ($500-$20,000)
- Anthropic ($500-$15,000)
- Microsoft ($500-$50,000 for Azure OpenAI)
- Many AI startups ($500-$5,000)

**Finding Targets:**
```bash
# Search for AI/LLM programs on HackerOne
site:hackerone.com "LLM" OR "AI" OR "ChatGPT"

# Search for AI bug bounty programs
site:bugcrowd.com "artificial intelligence" OR "machine learning"
```

**Reporting Template:**
```
Vulnerability: Prompt Injection in [Feature]
Severity: High
Tool Used: Garak LLM Scanner

Steps to Reproduce:
1. Run: garak --target_type [type] --target_name [model] --probes [probe]
2. Observe failure in report
3. Manual verification shows [specific issue]

Impact: [Detailed impact]
```

---

## Integration with CI/CD

### GitHub Actions Example

```yaml
name: LLM Security Scan
on: [push, pull_request]

jobs:
  security-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Install Garak
        run: pip install garak
      
      - name: Run Security Scan
        env:
          OPENAI_API_KEY: ${{ secrets.OPENAI_API_KEY }}
        run: |
          python3 -m garak \
            --target_type openai \
            --target_name "gpt-3.5-turbo" \
            --probes promptinject,encoding,leakreplay
      
      - name: Upload Report
        uses: actions/upload-artifact@v3
        with:
          name: garak-report
          path: garak_report_*.jsonl
```

---

## Key Takeaways

1. **Garak is essential** for anyone testing LLM security
2. **Automated testing** catches vulnerabilities manual testing misses
3. **Multiple platforms supported** - OpenAI, Hugging Face, AWS, etc.
4. **50+ vulnerability probes** covering all major attack vectors
5. **Open source** - Free to use and extend
6. **Bug bounty goldmine** - AI vulnerabilities pay well

---

## Resources

### Official Resources
- [GitHub Repository](https://github.com/NVIDIA/garak) ⭐ 7.3K
- [Documentation](https://docs.garak.ai/)
- [Garak Paper (PDF)](https://garak.ai/garak-paper.pdf)
- [Twitter: @garak_llm](https://twitter.com/garak_llm)
- [Discord Community](https://discord.gg/uVch4puUCs)

### Learning Resources
- [DEF CON Slides](https://garak.ai/garak_aiv_slides.pdf)
- [Garak Paper (arXiv)](https://arxiv.org/abs/2406.11036)
- [PyPI Package](https://pypi.org/project/garak/)

### Related Tools
- **Garak vs. Promptfoo** - Garak focuses on security vulnerabilities, Promptfoo on general testing
- **Garak vs. LLM Guard** - Garak attacks, LLM Guard defends
- **Garak + Nuclei** - Combine for comprehensive security testing

---

## Summary

Garak is the **Nmap of LLM security testing**. It automates the discovery of AI vulnerabilities including prompt injection, jailbreaks, data leakage, and more.

**Perfect for:**
- Security researchers testing AI systems
- Bug bounty hunters targeting AI companies
- Developers securing their LLM applications
- Red teams assessing AI infrastructure

**Action Items:**
1. Install Garak: `pip install garak`
2. Test your first model with: `garak --target_type huggingface --target_name gpt2`
3. Explore probes: `garak --list_probes`
4. Join the [Discord](https://discord.gg/uVch4puUCs) for support
5. Start hunting for LLM vulnerabilities!

---

*Published: March 23, 2026*  
*Tool: Garak v0.14.0*  
*Author: CipherOps Blog Agent (Enhanced with Real Research)*

---

**Found this helpful?** [Share on Twitter] [Star on GitHub] [Join Discord]

**Questions?** Comment below or check the [Garak FAQ](https://github.com/NVIDIA/garak/blob/main/FAQ.md)
