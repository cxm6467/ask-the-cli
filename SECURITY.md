# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| main    | :white_check_mark: |

## Security Best Practices

### API Key Protection

1. **Never commit API keys**: Always use environment variables
2. **Use .gitignore**: Ensure `.env` files are ignored
3. **Rotate keys regularly**: Change your API key periodically
4. **Limit key permissions**: Use keys with minimal required permissions

### Safe Usage

1. **Review commands before executing**: Always check suggested commands before running
2. **Avoid sensitive data in queries**: Don't include passwords or secrets in questions
3. **Be aware of rate limits**: Monitor your API usage to avoid unexpected costs
4. **Keep dependencies updated**: Regularly update zsh and curl

### Recommended .zshrc Setup

```bash
# Option 1: Source from secure location
if [[ -f ~/.config/ask-the-cli/api-key ]]; then
    export ASK_THE_CLI_API_KEY=$(cat ~/.config/ask-the-cli/api-key)
fi

# Option 2: Use a password manager
# export ASK_THE_CLI_API_KEY=$(security find-generic-password -a $USER -s anthropic-api -w)

# Option 3: Load from .env file (ensure it's in .gitignore)
if [[ -f ~/.zsh/ask-the-cli/.env ]]; then
    source ~/.zsh/ask-the-cli/.env
fi
```

## Reporting a Vulnerability

If you discover a security vulnerability, please report it by:

1. **Do NOT** open a public issue
2. Email the maintainer directly (see GitHub profile)
3. Provide detailed information:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

We will respond within 48 hours and work on a fix promptly.

## Data Privacy

### What Data is Sent

When you use this plugin, the following data is sent to Anthropic's API:
- Your question/query text
- System information (OS type via `uname -s`)
- API version headers

### What Data is NOT Sent

- Command history (unless explicitly included in your question)
- Environment variables
- File contents
- User credentials

### Data Storage

This plugin does NOT store:
- Conversation history
- API responses
- User queries
- Any local cache

All interactions are ephemeral and go directly to the Anthropic API.

## Security Checklist

Before using this plugin:

- [ ] API key is stored securely
- [ ] `.gitignore` includes `.env` and key files
- [ ] API key has appropriate rate limits set
- [ ] You understand queries are sent to external API
- [ ] curl is up to date: `curl --version`
- [ ] Repository is cloned from official source

## Third-Party Dependencies

### Runtime Dependencies

- **curl**: Used for API communication
  - Security: Use latest version
  - Alternative: Could be replaced with zsh's built-in networking (future)

- **Anthropic API**: External service
  - Privacy policy: https://www.anthropic.com/privacy
  - Terms of service: https://www.anthropic.com/terms

### No Additional Dependencies

This plugin intentionally has minimal dependencies to reduce attack surface.

## Updates and Patches

Stay informed about security updates:

1. Watch this repository for security announcements
2. Check [GitHub Security Advisories](https://github.com/cxm6467/ask-the-cli/security/advisories)
3. Review commit messages for security-related changes

## Contact

For security concerns, please contact the maintainer through GitHub.
