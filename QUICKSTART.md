# Quick Start Guide - ask-the-cli with Ollama

Get up and running in 5 minutes with FREE local AI!

## Why Ollama?

- **100% Free** - No API costs ever
- **Private** - Everything runs on your machine
- **Fast** - After initial model load, responses are quick
- **Offline** - Works without internet (after setup)

## Setup (macOS/Linux)

### Step 1: Install Ollama

**macOS:**
```bash
brew install ollama
```

**Linux:**
```bash
curl -fsSL https://ollama.com/install.sh | sh
```

**Windows:**
Download from [ollama.com/download](https://ollama.com/download)

### Step 2: Start Ollama

```bash
ollama serve
```

Leave this running in a terminal, or set it up as a system service (it will auto-start).

**Tip**: To run in background on Linux/macOS:
```bash
# Using systemd (Linux)
systemctl enable ollama
systemctl start ollama

# Or run in background with nohup
nohup ollama serve > /dev/null 2>&1 &
```

### Step 3: Pull an AI Model

Choose one (recommended: llama3.2 for speed):

```bash
# Fast & lightweight (1.3GB) - RECOMMENDED
ollama pull llama3.2

# More capable but larger (4.7GB)
ollama pull llama3.1

# Good balance (4.1GB)
ollama pull mistral
```

### Step 4: Install the Plugin

**Using Antidote:**

Add to `.zsh_plugins.txt`:
```
cxm6467/ask-the-cli
```

Then:
```bash
antidote load
```

**Using Oh My Zsh:**
```bash
git clone https://github.com/cxm6467/ask-the-cli.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/ask-the-cli
```

Add to `.zshrc`:
```bash
plugins=(... ask-the-cli)
```

**Manual:**
```bash
git clone https://github.com/cxm6467/ask-the-cli.git ~/.zsh/ask-the-cli
echo "source ~/.zsh/ask-the-cli/ask-the-cli.plugin.zsh" >> ~/.zshrc
```

### Step 5: Configure for Ollama

Add to your `~/.zshrc`:

```bash
export ASK_THE_CLI_PROVIDER="ollama"
export ASK_THE_CLI_MODEL="llama3.2"
```

Reload:
```bash
source ~/.zshrc
```

### Step 6: Test It!

```bash
ask how do I find files larger than 100MB
```

## Common Commands

```bash
# Ask questions
ask how to compress a directory with tar

# Get command suggestions
suggest list all docker containers

# Interactive mode
iask

# Check what models you have
ollama list

# Remove a model to save space
ollama rm llama3.1
```

## Troubleshooting

**"Failed to connect to ollama API"**
```bash
# Check if Ollama is running
ollama list

# If not, start it
ollama serve
```

**"Model not found"**
```bash
# Pull the model first
ollama pull llama3.2
```

**First query is slow?**

This is normal! The model loads into memory on first use. Subsequent queries are much faster.

## Switching Models

Try different models anytime:

```bash
# In your .zshrc, change:
export ASK_THE_CLI_MODEL="mistral"

# Then reload
source ~/.zshrc
```

Browse all available models: [ollama.com/library](https://ollama.com/library)

## Advanced: Run Ollama on Startup

**macOS (LaunchAgent):**
```bash
# Ollama installer typically sets this up automatically
brew services start ollama
```

**Linux (systemd):**
```bash
sudo systemctl enable ollama
sudo systemctl start ollama
```

## Need More Power?

Want the best AI quality? Switch to Claude or GPT:

**Anthropic Claude:**
```bash
export ASK_THE_CLI_PROVIDER="anthropic"
export ASK_THE_CLI_API_KEY="sk-ant-..."
export ASK_THE_CLI_MODEL="claude-3-5-sonnet-20241022"
```

**OpenAI GPT:**
```bash
export ASK_THE_CLI_PROVIDER="openai"
export ASK_THE_CLI_API_KEY="sk-..."
export ASK_THE_CLI_MODEL="gpt-4o-mini"
```

See [README.md](README.md) for full configuration options.

## Resources

- [Ollama Documentation](https://github.com/ollama/ollama)
- [Available Models](https://ollama.com/library)
- [Report Issues](https://github.com/cxm6467/ask-the-cli/issues)

Enjoy your free AI-powered CLI assistant!
