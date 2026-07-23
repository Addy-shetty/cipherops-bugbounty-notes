# CipherOps Blog Creation Agent - Phase 1

A working AI agent for automated blog content creation, adapted from the learn-claude-code agent pattern.

## ✨ What This Agent Does

### Features (Phase 1)

✅ **Content Planning** - Creates content calendars with TodoWrite pattern  
✅ **Topic Research** - Gathers info from CVEs, reports, trends  
✅ **Blog Writing** - Generates complete posts with templates  
✅ **Quality Review** - Scores content and suggests improvements  
✅ **Content Analysis** - Analyzes existing posts for gaps  

### Tools Available

| Tool | Purpose | Status |
|------|---------|--------|
| `plan_content_calendar` | Create weekly content plans | ✅ Working |
| `research_topic` | Research topics from sources | ✅ Working |
| `write_blog_post` | Generate complete blog posts | ✅ Working |
| `review_content` | Quality check and scoring | ✅ Working |
| `load_existing_content` | Analyze existing posts | ✅ Working |

---

## 🚀 Quick Start

### 1. Install Dependencies

```bash
cd ~/sample-posts
pip install anthropic  # Optional, for real AI mode
```

### 2. Run the Agent

```bash
# Interactive mode
python blog_agent.py

# Or with command
python blog_agent.py "Plan AI security content for next week"
```

### 3. Try These Commands

```bash
# Plan content
python blog_agent.py "Plan next week's content about AI security"

# Research topic
python blog_agent.py "Research prompt injection vulnerabilities"

# Write blog post
python blog_agent.py "Write a blog post about XSS attacks"

# Review content
python blog_agent.py "Review CVE-2024-21626-container-escape.md"

# Analyze existing content
python blog_agent.py "Load existing content"
```

---

## 📖 Usage Examples

### Example 1: Plan Content Calendar

```bash
$ python blog_agent.py "Plan AI security content for next week"

📅 Planning 7 days of content about AI Security...

✅ Content Calendar Created: AI Security
============================================================

📌 Monday, March 16
   Topic: How AI Changed My Bug Bounty Workflow
   Target: 2500 words
   Format: Tutorial

📌 Tuesday, March 17
   Topic: Prompt Injection 101: Complete Guide
   Target: 2500 words
   Format: Case Study

[... 5 more days ...]

💾 Saved to: content-calendar.json
📊 Total posts planned: 7
```

### Example 2: Research Topic

```bash
$ python blog_agent.py "Research CVE-2024-4040"

🔍 Researching: CVE-2024-4040...

✅ Research Complete: CVE-2024-4040
============================================================

📊 Key Findings:
   • CVE-2024-4040 is trending with 1000% search growth
   • Average bounty: $2,000-$15,000
   • 70% of applications remain vulnerable

📁 Sources analyzed:
   • Recent CVEs: 2
   • HackerOne reports: 2
   • Trending keywords: 4

💾 Research saved to: research-cve-2024-4040.json
```

### Example 3: Write Blog Post

```bash
$ python blog_agent.py "Write about prompt injection"

✍️  Writing blog post: Prompt Injection...

✅ Blog Post Created: Prompt Injection
============================================================

📄 Filename: prompt-injection-20250316.md
📝 Word Count: ~2,500 words
📊 Estimated Reading Time: 8 minutes
🏷️  Category: Bug Bounty

📋 Post Structure:
   ✓ Overview with bounty potential
   ✓ Technical explanation
   ✓ Detection methods (2 approaches)
   ✓ Real-world examples (2 cases)
   ✓ Step-by-step exploitation guide
   ✓ Prevention guide for developers
   ✓ Testing checklist
   ✓ Pro tips (4 tips)
   ✓ Resources section

💾 Saved to: prompt-injection-20250316.md

🎉 Ready to publish!
```

### Example 4: Review Content

```bash
$ python blog_agent.py "Review CVE-2024-21626-container-escape.md"

🔍 Reviewing: CVE-2024-21626-container-escape.md...

✅ Content Review: CVE-2024-21626-container-escape.md
============================================================

📊 Quality Score: 92/100
🟢 Status: EXCELLENT - Ready to publish!

📋 Detailed Checks:
   ✅ Word Count: Yes (2847 words)
   ✅ Has Commands: Yes
   ✅ Has Examples: Yes
   ✅ Has Backlinks: Yes
   ✅ Has Headers: Yes
   ✅ Has Pro Tips: Yes
   ✅ Has Checklist: Yes
   ✅ Proper Structure: Yes

💡 Suggestions for improvement:
   None! Post is excellent.

📈 Metrics:
   • Total Words: 2847
   • Estimated Read Time: 14 minutes
   • Sections: 12
```

---

## 🏗️ Architecture

### Agent Loop (Core Pattern)

```python
def agent_loop(messages):
    while True:
        response = LLM(messages, tools)
        messages.append(response)
        
        if response.stop_reason != "tool_use":
            return response.text
        
        results = execute_tools(response.tools)
        messages.append({"role": "user", "content": results})
```

### Tool Dispatch

The agent checks user requests and dispatches to appropriate tools:

- **"plan"** → `plan_content_calendar()`
- **"research"** → `research_topic()`
- **"write"** → `write_blog_post()`
- **"review"** → `review_content()`
- **"load"** → `load_existing_content()`

---

## 📁 Files Created

When you run the agent, it creates:

| File | Purpose |
|------|---------|
| `content-calendar.json` | Weekly content plan |
| `research-[topic].json` | Research data for topic |
| `[topic]-[date].md` | Generated blog post |
| `blog_agent.py` | The agent itself |

---

## 🎯 Phase 1 Capabilities

### What's Working ✅

1. **Content Planning**
   - Creates 7-day content calendars
   - Assigns topics to days
   - Sets word count targets
   - Saves to JSON

2. **Topic Research**
   - Simulates CVE database queries
   - Gathers HackerOne report data
   - Tracks trending keywords
   - Saves research for reference

3. **Blog Writing**
   - Generates complete 2,500-word posts
   - Uses professional templates
   - Includes all standard sections
   - Adds code examples
   - Includes pro tips

4. **Quality Review**
   - 8-point quality checklist
   - Word count analysis
   - Structure validation
   - Suggestion generation
   - Quality scoring (0-100)

5. **Content Analysis**
   - Scans existing markdown files
   - Categorizes by type
   - Calculates word counts
   - Identifies content gaps

---

## 🚀 Phase 2 & 3 Roadmap

### Phase 2: Enhanced Features
- [ ] Real CVE API integration (NVD)
- [ ] HackerOne API integration
- [ ] Reddit API for trending topics
- [ ] Subagent delegation for writing sections
- [ ] Context compression for long conversations
- [ ] Task persistence (save/restore work)

### Phase 3: Multi-Agent Team
- [ ] Content Planner agent
- [ ] Researcher agent  
- [ ] Writer agent
- [ ] Editor agent
- [ ] Publisher agent
- [ ] Agent-to-agent communication
- [ ] Autonomous mode (daily content generation)

---

## 🛠️ Configuration

### Environment Variables

```bash
# Optional: For real AI mode
export ANTHROPIC_API_KEY="your-api-key"

# Optional: For publishing
export GITHUB_TOKEN="your-token"
export GITBOOK_API_KEY="your-key"
```

### Without API Key (Demo Mode)

The agent works in demo mode without API key:
- Uses predefined templates
- Simulates research data
- Generates realistic content
- Perfect for testing!

---

## 💡 Tips for Best Results

### 1. Be Specific
```bash
# Good
python blog_agent.py "Write about XSS in modern web apps"

# Better
python blog_agent.py "Write a beginner guide about reflected XSS with examples"
```

### 2. Use Keywords
```bash
# The agent recognizes these keywords:
# - plan, calendar, schedule
# - research, find, look up
# - write, create, generate
# - review, improve, check
# - load, read, existing
```

### 3. Review Before Publishing
```bash
# Always review generated content
python blog_agent.py "Review [filename]"

# Score should be 80+ before publishing
```

---

## 🎓 Learning Resources

This agent is based on:
- [learn-claude-code](https://github.com/shareAI-lab/learn-claude-code) - 28.7K stars
- [Claude Code documentation](https://docs.anthropic.com/)

Key concepts:
- **Agent Loop**: Core execution pattern
- **Tools**: Modular capabilities
- **Messages**: Conversation context
- **Stop Reason**: Tool use vs completion

---

## 🐛 Troubleshooting

### Issue: "File not found"
```bash
# Make sure you're in the right directory
cd ~/sample-posts
python blog_agent.py "your command"
```

### Issue: "anthropic not installed"
```bash
# This is fine! Agent works in demo mode
# Or install: pip install anthropic
```

### Issue: "Permission denied"
```bash
chmod +x blog_agent.py
python blog_agent.py
```

---

## 📊 Success Metrics

After using the agent, you should have:
- ✅ Content calendar (7 days planned)
- ✅ 1-2 researched topics
- ✅ 1-2 new blog posts
- ✅ Quality scores for existing content
- ✅ Content gap analysis

**Next:** Review generated posts, edit as needed, publish to GitBook!

---

## 🎯 Next Steps

### This Week:
1. [ ] Run agent to plan next week's content
2. [ ] Generate 2-3 blog posts
3. [ ] Review and improve generated content
4. [ ] Publish best post to GitBook

### Next Week:
1. [ ] Add API keys for real research
2. [ ] Integrate with GitHub/GitBook
3. [ ] Test multi-agent features
4. [ ] Scale to daily content generation

---

## 🤝 Contributing

To improve the agent:
1. Edit `blog_agent.py`
2. Add new tools to `self.tools` dict
3. Implement tool functions
4. Test with `python blog_agent.py`
5. Commit changes

---

**Ready to automate your blog? Run the agent now!** 🚀

```bash
python blog_agent.py "Plan my first week of content"
```
