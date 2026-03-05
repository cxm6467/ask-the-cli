# ask-the-cli

An AI-powered zsh plugin that brings intelligent command-line assistance directly to your terminal. Ask questions about CLI commands, get suggestions, and learn as you work.

**New!** Now supports multiple AI providers including **Ollama** (free, local) alongside Anthropic Claude and OpenAI.

**Quick Start**: Want to use FREE local AI? See [QUICKSTART.md](QUICKSTART.md) for Ollama setup in 5 minutes!

## Features

- **Easy Setup**: Interactive configuration wizard on first run
- **Ask CLI Questions**: Get instant answers about command-line tools and usage
- **Command Suggestions**: Describe what you want to do and get the exact command
- **Interactive Mode**: Have a conversation with your CLI assistant
- **Platform Aware**: Provides answers specific to your operating system
- **Fast & Lightweight**: Minimal dependencies, just curl and zsh
- **Smart Question Detection**: Automatically formats questions with proper quoting
- **Code Snippet Preservation**: Backticks and code blocks are preserved in queries
- **Animated Output**: Claude-style typewriter effect with ESC to skip
- **Customizable Colors**: Match your terminal theme
- **Secure Input Handling**: Automatic sanitization to prevent injection attacks
- **Persistent Configuration**: Settings saved to `~/.ask-the-cli/config`

## Installation

**First-Time Setup**: The plugin includes an interactive configuration wizard that runs automatically on first use. Simply install the plugin and run `ask` to begin the setup process!

### Using [Antidote](https://github.com/mattmc3/antidote)

Add to your `.zsh_plugins.txt`:

```
cxm6467/ask-the-cli
```

Then reload your plugins:

```bash
antidote load
```

### Using [Oh My Zsh](https://ohmyz.sh/)

1. Clone the repository into Oh My Zsh's custom plugins directory:

```bash
git clone https://github.com/cxm6467/ask-the-cli.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/ask-the-cli
```

2. Add the plugin to your `.zshrc`:

```bash
plugins=(... ask-the-cli)
```

3. Reload your shell:

```bash
source ~/.zshrc
```

### Manual Installation

1. Clone the repository:

```bash
git clone https://github.com/cxm6467/ask-the-cli.git ~/.zsh/ask-the-cli
```

2. Source the plugin in your `.zshrc`:

```bash
source ~/.zsh/ask-the-cli/ask-the-cli.plugin.zsh
```

## Configuration

### First-Time Setup Wizard

On first use, ask-the-cli will automatically launch an interactive configuration wizard that helps you:
1. Choose your AI provider (Ollama, Anthropic Claude, or OpenAI GPT)
2. Configure API keys (if needed)
3. Set up animated text output preferences
4. Choose your preferred text color

Your configuration is saved to `~/.ask-the-cli/config` and loaded automatically on subsequent uses.

**To reconfigure**: Delete `~/.ask-the-cli/config` and run `ask` again to restart the wizard.

### Manual Configuration

If you prefer to configure manually or want to change settings later, you can edit `~/.ask-the-cli/config` or set environment variables in your `.zshrc`.

### Choose Your AI Provider

This plugin supports multiple AI providers. Choose based on your needs:

| Provider | Cost | Setup Complexity | Quality |
|----------|------|------------------|---------|
| **Ollama** (local) | Free | Medium | Good |
| **Anthropic** (Claude) | Paid API | Easy | Excellent |
| **OpenAI** (GPT) | Paid API | Easy | Excellent |

### Option 1: Ollama (Recommended for Free/Local Use)

**Ollama** runs AI models locally on your machine - completely free and private!

#### Setup Steps:

1. **Install Ollama**:
   ```bash
   # macOS
   brew install ollama

   # Linux
   curl -fsSL https://ollama.com/install.sh | sh

   # Or download from: https://ollama.com/download
   ```

2. **Start Ollama service**:
   ```bash
   ollama serve
   ```
   (Run this in a separate terminal or as a background service)

3. **Pull a model** (first time only):
   ```bash
   # Recommended: Llama 3.2 (lightweight, fast)
   ollama pull llama3.2

   # Alternative: Llama 3.1 (larger, more capable)
   ollama pull llama3.1

   # Alternative: Mistral (good balance)
   ollama pull mistral
   ```

4. **Configure the plugin** in your `.zshrc`:
   ```bash
   export ASK_THE_CLI_PROVIDER="ollama"
   export ASK_THE_CLI_MODEL="llama3.2"  # or mistral, llama3.1, etc.
   ```

5. **Reload your shell** and start using:
   ```bash
   source ~/.zshrc
   ask how do I find large files
   ```

**Ollama Tips**:
- First query may be slow (model loading), subsequent queries are fast
- Models run entirely on your machine - no internet required after download
- View available models: `ollama list`
- Remove models to save space: `ollama rm <model-name>`

### Option 2: Anthropic Claude (Paid API)

**Best for**: Highest quality responses, latest AI capabilities

1. Get your API key from [Anthropic Console](https://console.anthropic.com/)
2. Configure in your `.zshrc`:
   ```bash
   export ASK_THE_CLI_PROVIDER="anthropic"
   export ASK_THE_CLI_API_KEY="sk-ant-api03-..."
   export ASK_THE_CLI_MODEL="claude-3-5-sonnet-20241022"  # optional
   ```

**Security Note**: Never commit your API key to version control.

### Option 3: OpenAI GPT (Paid API)

**Best for**: If you already have OpenAI credits

1. Get your API key from [OpenAI Platform](https://platform.openai.com/)
2. Configure in your `.zshrc`:
   ```bash
   export ASK_THE_CLI_PROVIDER="openai"
   export ASK_THE_CLI_API_KEY="sk-..."
   export ASK_THE_CLI_MODEL="gpt-4o-mini"  # or gpt-4o, gpt-4-turbo
   ```

### Advanced Configuration

Customize these optional variables in your `.zshrc`:

```bash
# Provider selection (default: anthropic)
export ASK_THE_CLI_PROVIDER="ollama"  # Options: ollama, anthropic, openai

# Maximum tokens in response (default: 1024)
export ASK_THE_CLI_MAX_TOKENS=2048

# Ollama host (default: http://localhost:11434)
export ASK_THE_CLI_OLLAMA_HOST="http://localhost:11434"

# Override API URL (advanced - auto-set based on provider)
# export ASK_THE_CLI_API_URL="https://custom-endpoint.com"

# Animation settings (new!)
export ASK_THE_CLI_ANIMATE=true              # Enable/disable animated output
export ASK_THE_CLI_ANIMATION_DELAY=0.01      # Delay between characters (seconds)
export ASK_THE_CLI_TEXT_COLOR="cyan"         # Options: black, red, green, yellow, blue, magenta, cyan, white, default
```

**New Animation Features:**
- **Animated Text Output**: Responses are displayed character-by-character with a typewriter effect
- **ESC to Skip**: Press ESC at any time to display the rest of the response immediately
- **Configurable Colors**: Customize the text color to match your terminal theme
- **Disable Animation**: Set `ASK_THE_CLI_ANIMATE=false` for instant output

## Usage

### Ask Questions

```bash
# Ask about a specific command
ask how do I find files larger than 100MB

# Ask about concepts
ask what is the difference between grep and awk

# Ask for explanations
ask explain the ps aux command
```

### Get Command Suggestions

```bash
# Describe what you want to do
suggest list all running docker containers

# Get help with complex operations
suggest compress all logs older than 30 days

# Find the right tool
suggest monitor network traffic on port 80
```

### Interactive Mode

Start a conversation session:

```bash
iask
```

Type your questions and get answers. Type `exit` or `quit` to leave.

### Aliases

Quick shortcuts are available:

```bash
askme <question>      # Same as 'ask'
suggestme <query>     # Same as 'suggest'
```

## Examples

```bash
# Find files modified today
$ ask how to find files modified today
find . -type f -mtime 0

# Docker command suggestion
$ suggest stop all running containers
COMMAND: docker stop $(docker ps -q)
EXPLANATION: Lists all container IDs with 'docker ps -q' and stops them

# Complex pipeline
$ ask how to count unique IP addresses in access.log
awk '{print $1}' access.log | sort | uniq | wc -l
```

## Troubleshooting

### Ollama Issues

**"Failed to connect to ollama API"**

Solutions:
1. Check if Ollama is running: `ollama list`
2. Start Ollama service: `ollama serve`
3. Verify the model is installed: `ollama pull llama3.2`
4. Check the host: `export ASK_THE_CLI_OLLAMA_HOST="http://localhost:11434"`

**"Slow responses"**

- First query loads the model into memory (slow)
- Subsequent queries are much faster
- Consider using a smaller model like `llama3.2` instead of `llama3.1`

**"Model not found"**

Pull the model first:
```bash
ollama pull llama3.2
```

### API Provider Issues

**"API Key Not Set"**

```
Error: ASK_THE_CLI_API_KEY is not set.
```

Solution: Export your API key in `.zshrc`:

```bash
export ASK_THE_CLI_API_KEY="your-key"
export ASK_THE_CLI_PROVIDER="anthropic"  # or openai
```

Or switch to Ollama (no API key needed):
```bash
export ASK_THE_CLI_PROVIDER="ollama"
```

**"Connection Errors"**

```
Error: Failed to connect to API
```

Solutions:
- Check your internet connection (not needed for Ollama)
- Verify the API endpoint URL
- Ensure your API key is valid and has credits
- Check provider setting: `echo $ASK_THE_CLI_PROVIDER`

### General Issues

**"Empty Responses / Unable to parse response"**

Solutions:
- Check if curl is installed: `which curl`
- Verify your provider configuration
- Try with a simpler question
- Check raw response for debugging:
  ```bash
  # The error message will show the raw response
  ```

**"Unknown provider error"**

Make sure you're using a valid provider:
```bash
export ASK_THE_CLI_PROVIDER="ollama"     # or anthropic, or openai
```

## Privacy & Security

### Ollama (Local)
- **100% Private**: All processing happens on your machine
- **No Data Transmission**: Questions never leave your computer
- **No API Keys**: No credentials needed
- **Offline Capable**: Works without internet after model download

### Cloud Providers (Anthropic/OpenAI)
- **API Keys**: Store your API key securely, never commit it to git
- **Data Transmission**: Your questions are sent to the provider's API over HTTPS
- **Privacy Policies**: Subject to provider's terms (Anthropic/OpenAI)
- **Rate Limits**: Be mindful of API rate limits and costs

### General
- **No Local Storage**: This plugin does not store conversation history
- **Minimal Data**: Only sends your questions and receives responses

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

1. Fork the repository
2. Create your feature branch: `git checkout -b feature/my-feature`
3. Commit your changes: `git commit -am 'Add new feature'`
4. Push to the branch: `git push origin feature/my-feature`
5. Submit a pull request

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Acknowledgments

- Powered by AI providers:
  - [Ollama](https://ollama.com/) - Local, open-source AI
  - [Anthropic Claude](https://www.anthropic.com/) - Cloud AI API
  - [OpenAI](https://openai.com/) - Cloud AI API
- Inspired by the need for better CLI assistance

## Support

- **Issues**: [GitHub Issues](https://github.com/cxm6467/ask-the-cli/issues)
- **Discussions**: [GitHub Discussions](https://github.com/cxm6467/ask-the-cli/discussions)

---

Made with ❤️ for the command line
