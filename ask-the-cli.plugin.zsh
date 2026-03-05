#!/usr/bin/env zsh
# ask-the-cli - AI-powered CLI assistant for zsh
# Compatible with antidote and oh-my-zsh

# Configuration directory and file
ASK_THE_CLI_CONFIG_DIR="${HOME}/.ask-the-cli"
ASK_THE_CLI_CONFIG_FILE="${ASK_THE_CLI_CONFIG_DIR}/config"

# Load existing configuration if available
if [[ -f "$ASK_THE_CLI_CONFIG_FILE" ]]; then
    source "$ASK_THE_CLI_CONFIG_FILE"
fi

# Configuration defaults
: ${ASK_THE_CLI_PROVIDER:="anthropic"}  # Options: anthropic, openai, ollama
: ${ASK_THE_CLI_API_KEY:=""}
: ${ASK_THE_CLI_API_URL:=""}
: ${ASK_THE_CLI_MODEL:=""}
: ${ASK_THE_CLI_MAX_TOKENS:=1024}
: ${ASK_THE_CLI_OLLAMA_HOST:="http://localhost:11434"}

# Animation configuration
: ${ASK_THE_CLI_ANIMATE:=true}         # Enable/disable animated text output
: ${ASK_THE_CLI_ANIMATION_DELAY:=0.01} # Delay between characters (seconds)
: ${ASK_THE_CLI_TEXT_COLOR:="cyan"}    # Color options: black, red, green, yellow, blue, magenta, cyan, white, default

# First run flag
: ${ASK_THE_CLI_FIRST_RUN:=true}

# Configuration wizard for first run
_ask_the_cli_config_wizard() {
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║      Welcome to ask-the-cli Configuration Wizard!       ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo ""
    echo "Let's set up your AI-powered CLI assistant."
    echo ""

    # Provider selection
    echo "1️⃣  Choose your AI provider:"
    echo "    [1] Ollama (Free, Local, Private) - Recommended for beginners"
    echo "    [2] Anthropic Claude (Paid API) - Best quality"
    echo "    [3] OpenAI GPT (Paid API)"
    echo ""
    echo -n "Select provider (1-3): "
    read provider_choice

    case "$provider_choice" in
        1)
            ASK_THE_CLI_PROVIDER="ollama"
            ASK_THE_CLI_MODEL="llama3.2"
            echo ""
            echo "✓ Selected: Ollama (Local)"
            echo ""
            echo "📝 Note: Make sure Ollama is installed and running:"
            echo "   Install: brew install ollama (or visit ollama.com)"
            echo "   Start:   ollama serve"
            echo "   Pull:    ollama pull llama3.2"
            echo ""
            ;;
        2)
            ASK_THE_CLI_PROVIDER="anthropic"
            ASK_THE_CLI_MODEL="claude-3-5-sonnet-20241022"
            echo ""
            echo "✓ Selected: Anthropic Claude"
            echo ""
            echo -n "Enter your Anthropic API key (or press Enter to skip): "
            read -r api_key
            if [[ -n "$api_key" ]]; then
                ASK_THE_CLI_API_KEY="$api_key"
                echo "✓ API key saved"
            else
                echo "⚠ You can set it later with: export ASK_THE_CLI_API_KEY='your-key'"
            fi
            echo ""
            ;;
        3)
            ASK_THE_CLI_PROVIDER="openai"
            ASK_THE_CLI_MODEL="gpt-4o-mini"
            echo ""
            echo "✓ Selected: OpenAI GPT"
            echo ""
            echo -n "Enter your OpenAI API key (or press Enter to skip): "
            read -r api_key
            if [[ -n "$api_key" ]]; then
                ASK_THE_CLI_API_KEY="$api_key"
                echo "✓ API key saved"
            else
                echo "⚠ You can set it later with: export ASK_THE_CLI_API_KEY='your-key'"
            fi
            echo ""
            ;;
        *)
            echo "Invalid choice. Defaulting to Ollama."
            ASK_THE_CLI_PROVIDER="ollama"
            ASK_THE_CLI_MODEL="llama3.2"
            ;;
    esac

    # Animation settings
    echo "2️⃣  Configure display settings:"
    echo ""
    echo -n "Enable animated typewriter effect? [Y/n]: "
    read animate_choice
    if [[ "$animate_choice" =~ ^[Nn] ]]; then
        ASK_THE_CLI_ANIMATE=false
        echo "✓ Animation disabled"
    else
        ASK_THE_CLI_ANIMATE=true
        echo "✓ Animation enabled (press ESC to skip)"
    fi
    echo ""

    # Color selection
    echo -n "Choose text color (cyan/green/blue/yellow/magenta/red/white) [cyan]: "
    read color_choice
    if [[ -n "$color_choice" ]]; then
        ASK_THE_CLI_TEXT_COLOR="$color_choice"
    else
        ASK_THE_CLI_TEXT_COLOR="cyan"
    fi
    echo "✓ Text color set to: $ASK_THE_CLI_TEXT_COLOR"
    echo ""

    # Save configuration
    mkdir -p "$ASK_THE_CLI_CONFIG_DIR"
    cat > "$ASK_THE_CLI_CONFIG_FILE" <<EOF
# ask-the-cli configuration
# Generated on $(date)

# Provider settings
export ASK_THE_CLI_PROVIDER="$ASK_THE_CLI_PROVIDER"
export ASK_THE_CLI_MODEL="$ASK_THE_CLI_MODEL"
export ASK_THE_CLI_API_KEY="$ASK_THE_CLI_API_KEY"

# Animation settings
export ASK_THE_CLI_ANIMATE=$ASK_THE_CLI_ANIMATE
export ASK_THE_CLI_TEXT_COLOR="$ASK_THE_CLI_TEXT_COLOR"

# First run completed
export ASK_THE_CLI_FIRST_RUN=false
EOF

    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║              Configuration saved successfully!           ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo ""
    echo "Configuration file: $ASK_THE_CLI_CONFIG_FILE"
    echo ""
    echo "Try it out:"
    echo "  ask how do I list files"
    echo "  suggest compress a directory"
    echo "  iask  (interactive mode)"
    echo ""
}

# Set provider-specific defaults
_set_provider_defaults() {
    case "$ASK_THE_CLI_PROVIDER" in
        anthropic)
            : ${ASK_THE_CLI_API_URL:="https://api.anthropic.com/v1/messages"}
            : ${ASK_THE_CLI_MODEL:="claude-3-5-sonnet-20241022"}
            ;;
        openai)
            : ${ASK_THE_CLI_API_URL:="https://api.openai.com/v1/chat/completions"}
            : ${ASK_THE_CLI_MODEL:="gpt-4o-mini"}
            ;;
        ollama)
            : ${ASK_THE_CLI_API_URL:="$ASK_THE_CLI_OLLAMA_HOST/api/generate"}
            : ${ASK_THE_CLI_MODEL:="llama3.2"}
            ;;
        *)
            echo "Error: Unknown provider '$ASK_THE_CLI_PROVIDER'. Use: anthropic, openai, or ollama"
            return 1
            ;;
    esac
}

# Color codes mapping
_get_color_code() {
    local color="$1"
    case "$color" in
        black)   echo "30" ;;
        red)     echo "31" ;;
        green)   echo "32" ;;
        yellow)  echo "33" ;;
        blue)    echo "34" ;;
        magenta) echo "35" ;;
        cyan)    echo "36" ;;
        white)   echo "37" ;;
        *)       echo "0"  ;; # default/reset
    esac
}

# Animated text output with ESC to interrupt and configurable color
_print_animated() {
    local text="$1"
    local color_code=$(_get_color_code "$ASK_THE_CLI_TEXT_COLOR")

    # If animation is disabled, just print normally
    if [[ "$ASK_THE_CLI_ANIMATE" != "true" ]]; then
        echo -e "\033[${color_code}m${text}\033[0m"
        return 0
    fi

    # Set up terminal for reading single characters
    stty -echo -icanon time 0 min 0 2>/dev/null

    local interrupted=0
    local i=1
    local len=${#text}

    # Print with color
    echo -ne "\033[${color_code}m"

    while [[ $i -le $len ]]; do
        # Check for ESC key (ASCII 27)
        local key
        read -k 1 key 2>/dev/null
        if [[ "$key" == $'\e' ]] || [[ "$key" == $'\x1b' ]]; then
            interrupted=1
            # Print rest of text immediately
            echo -n "${text:$i-1}"
            break
        fi

        # Print one character
        echo -n "${text:$i-1:1}"
        ((i++))

        # Small delay between characters
        sleep "$ASK_THE_CLI_ANIMATION_DELAY"
    done

    # Reset color
    echo -e "\033[0m"

    # Restore terminal settings
    stty echo icanon 2>/dev/null

    return $interrupted
}

# Sanitize input for JSON - escape special characters
_sanitize_for_json() {
    local input="$1"
    # Escape backslashes first (must be done before other escapes)
    input="${input//\\/\\\\}"
    # Escape double quotes
    input="${input//\"/\\\"}"
    # Escape newlines
    input="${input//$'\n'/\\n}"
    # Escape tabs
    input="${input//$'\t'/\\t}"
    # Escape carriage returns
    input="${input//$'\r'/\\r}"
    # Escape form feeds
    input="${input//$'\f'/\\f}"
    # Escape backspace
    input="${input//$'\b'/\\b}"
    echo "$input"
}

# Format user input by detecting questions and preserving code snippets
_format_user_input() {
    local input="$1"
    local formatted="$input"

    # Temporary associative array to store code snippets
    typeset -A code_snippets
    local code_counter=0

    # Preserve triple backtick code blocks first (```code```)
    while [[ "$formatted" == *'```'*'```'* ]]; do
        local before="${formatted%%\`\`\`*}"
        local temp="${formatted#*\`\`\`}"
        local code_content="${temp%%\`\`\`*}"
        local after="${temp#*\`\`\`}"
        local match="\`\`\`${code_content}\`\`\`"

        code_snippets[$code_counter]="$match"
        formatted="${before}__CODE_SNIPPET_${code_counter}__${after}"
        ((code_counter++))
    done

    # Preserve single backtick code snippets (`code`)
    while [[ "$formatted" == *'`'*'`'* ]]; do
        local before="${formatted%%\`*}"
        local temp="${formatted#*\`}"
        local code_content="${temp%%\`*}"
        local after="${temp#*\`}"
        local match="\`${code_content}\`"

        # Only preserve if there's content between backticks
        if [[ -n "$code_content" ]]; then
            code_snippets[$code_counter]="$match"
            formatted="${before}__CODE_SNIPPET_${code_counter}__${after}"
            ((code_counter++))
        else
            # If empty backticks, just remove them
            formatted="${before}${after}"
        fi
    done

    # Detect questions - look for question patterns
    # Question indicators: starts with question words or ends with ?
    local is_question=0

    # Check if ends with question mark
    if [[ "$formatted" == *'?'* ]]; then
        is_question=1
    # Check if starts with question words (case-insensitive)
    elif [[ "$formatted" =~ ^[[:space:]]*(how|what|where|when|why|which|who|can|could|should|would|is|are|do|does|did|will)[[:space:]] ]]; then
        is_question=1
    fi

    # Wrap question in quotes
    if [[ $is_question -eq 1 ]]; then
        # If ends with ?, include it in quotes
        if [[ "$formatted" == *'?'* ]]; then
            local question_part="${formatted%%\?*}?"
            local remainder="${formatted#*\?}"
            formatted="\"${question_part}\"${remainder}"
        else
            # Wrap entire input as question
            formatted="\"${formatted}\""
        fi
    fi

    # Restore code snippets
    local key
    for key in ${(k)code_snippets}; do
        formatted="${formatted//__CODE_SNIPPET_${key}__/${code_snippets[$key]}}"
    done

    echo "$formatted"
}

# Call Anthropic API
_call_anthropic() {
    local system_prompt="$(_sanitize_for_json "$1")"
    local user_message="$(_sanitize_for_json "$2")"

    curl -s -X POST "$ASK_THE_CLI_API_URL" \
        -H "Content-Type: application/json" \
        -H "x-api-key: $ASK_THE_CLI_API_KEY" \
        -H "anthropic-version: 2023-06-01" \
        -d @- <<EOF
{
    "model": "$ASK_THE_CLI_MODEL",
    "max_tokens": $ASK_THE_CLI_MAX_TOKENS,
    "system": "$system_prompt",
    "messages": [
        {
            "role": "user",
            "content": "$user_message"
        }
    ]
}
EOF
}

# Call OpenAI API
_call_openai() {
    local system_prompt="$(_sanitize_for_json "$1")"
    local user_message="$(_sanitize_for_json "$2")"

    curl -s -X POST "$ASK_THE_CLI_API_URL" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $ASK_THE_CLI_API_KEY" \
        -d @- <<EOF
{
    "model": "$ASK_THE_CLI_MODEL",
    "max_tokens": $ASK_THE_CLI_MAX_TOKENS,
    "messages": [
        {
            "role": "system",
            "content": "$system_prompt"
        },
        {
            "role": "user",
            "content": "$user_message"
        }
    ]
}
EOF
}

# Call Ollama API (local)
_call_ollama() {
    local system_prompt="$(_sanitize_for_json "$1")"
    local user_message="$(_sanitize_for_json "$2")"

    curl -s -X POST "$ASK_THE_CLI_API_URL" \
        -H "Content-Type: application/json" \
        -d @- <<EOF
{
    "model": "$ASK_THE_CLI_MODEL",
    "prompt": "$system_prompt\n\nUser: $user_message\n\nAssistant:",
    "stream": false,
    "options": {
        "num_predict": $ASK_THE_CLI_MAX_TOKENS
    }
}
EOF
}

# Parse response based on provider
_parse_response() {
    local response="$1"
    local answer=""

    case "$ASK_THE_CLI_PROVIDER" in
        anthropic)
            answer=$(echo "$response" | grep -o '"text":"[^"]*"' | head -1 | sed 's/"text":"\(.*\)"/\1/' | sed 's/\\n/\n/g')
            ;;
        openai)
            answer=$(echo "$response" | grep -o '"content":"[^"]*"' | head -1 | sed 's/"content":"\(.*\)"/\1/' | sed 's/\\n/\n/g')
            ;;
        ollama)
            answer=$(echo "$response" | grep -o '"response":"[^"]*"' | sed 's/"response":"\(.*\)"/\1/' | sed 's/\\n/\n/g')
            ;;
    esac

    echo "$answer"
}

# Main function to ask CLI questions
ask() {
    # Run configuration wizard on first use
    if [[ "$ASK_THE_CLI_FIRST_RUN" == "true" ]]; then
        _ask_the_cli_config_wizard
        # Reload config after wizard
        source "$ASK_THE_CLI_CONFIG_FILE"
    fi

    _set_provider_defaults || return 1

    # Check API key requirement (not needed for Ollama)
    if [[ "$ASK_THE_CLI_PROVIDER" != "ollama" ]] && [[ -z "$ASK_THE_CLI_API_KEY" ]]; then
        echo "Error: ASK_THE_CLI_API_KEY is not set for provider '$ASK_THE_CLI_PROVIDER'."
        echo "Please set your API key: export ASK_THE_CLI_API_KEY='your-api-key'"
        echo "Or use Ollama (local, free): export ASK_THE_CLI_PROVIDER='ollama'"
        return 1
    fi

    if [[ $# -eq 0 ]]; then
        echo "Usage: ask <question>"
        echo "Example: ask how do I find all files modified in the last 24 hours"
        return 1
    fi

    local question="$*"
    local formatted_question=$(_format_user_input "$question")
    local system_prompt="You are a helpful CLI assistant. Provide concise, accurate command-line answers for $(uname -s). When suggesting commands, explain what they do. Be brief and practical."

    echo "Asking ($ASK_THE_CLI_PROVIDER): $formatted_question"
    echo ""

    # Call the appropriate API based on provider
    local response
    case "$ASK_THE_CLI_PROVIDER" in
        anthropic)
            response=$(_call_anthropic "$system_prompt" "$formatted_question")
            ;;
        openai)
            response=$(_call_openai "$system_prompt" "$formatted_question")
            ;;
        ollama)
            response=$(_call_ollama "$system_prompt" "$formatted_question")
            ;;
    esac

    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to connect to $ASK_THE_CLI_PROVIDER API"
        return 1
    fi

    # Parse response based on provider
    local answer=$(_parse_response "$response")

    if [[ -z "$answer" ]]; then
        echo "Error: Unable to parse response from $ASK_THE_CLI_PROVIDER"
        echo "Raw response: $response"
        return 1
    fi

    _print_animated "$answer"
}

# Function to get command suggestions based on partial input
suggest() {
    # Run configuration wizard on first use
    if [[ "$ASK_THE_CLI_FIRST_RUN" == "true" ]]; then
        _ask_the_cli_config_wizard
        # Reload config after wizard
        source "$ASK_THE_CLI_CONFIG_FILE"
    fi

    _set_provider_defaults || return 1

    # Check API key requirement (not needed for Ollama)
    if [[ "$ASK_THE_CLI_PROVIDER" != "ollama" ]] && [[ -z "$ASK_THE_CLI_API_KEY" ]]; then
        echo "Error: ASK_THE_CLI_API_KEY is not set for provider '$ASK_THE_CLI_PROVIDER'."
        echo "Or use Ollama (local, free): export ASK_THE_CLI_PROVIDER='ollama'"
        return 1
    fi

    if [[ $# -eq 0 ]]; then
        echo "Usage: suggest <partial command or description>"
        echo "Example: suggest list all running docker containers"
        return 1
    fi

    local query="$*"
    local formatted_query=$(_format_user_input "$query")
    local system_prompt="You are a CLI command suggestion assistant. Given a description or partial command, suggest the exact command(s) to use. Provide only the command first, then a brief explanation. Format: COMMAND: <command>\nEXPLANATION: <explanation>"
    local user_message="Suggest a command for: $formatted_query"

    echo "Suggesting ($ASK_THE_CLI_PROVIDER): $formatted_query"
    echo ""

    # Call the appropriate API based on provider
    local response
    case "$ASK_THE_CLI_PROVIDER" in
        anthropic)
            response=$(_call_anthropic "$system_prompt" "$user_message")
            ;;
        openai)
            response=$(_call_openai "$system_prompt" "$user_message")
            ;;
        ollama)
            response=$(_call_ollama "$system_prompt" "$user_message")
            ;;
    esac

    # Parse response based on provider
    local answer=$(_parse_response "$response")

    if [[ -z "$answer" ]]; then
        echo "Error: Unable to get suggestions from $ASK_THE_CLI_PROVIDER"
        return 1
    fi

    _print_animated "$answer"
}

# Interactive mode - ask multiple questions
iask() {
    # Run configuration wizard on first use
    if [[ "$ASK_THE_CLI_FIRST_RUN" == "true" ]]; then
        _ask_the_cli_config_wizard
        # Reload config after wizard
        source "$ASK_THE_CLI_CONFIG_FILE"
    fi

    _set_provider_defaults || return 1

    # Check API key requirement (not needed for Ollama)
    if [[ "$ASK_THE_CLI_PROVIDER" != "ollama" ]] && [[ -z "$ASK_THE_CLI_API_KEY" ]]; then
        echo "Error: ASK_THE_CLI_API_KEY is not set for provider '$ASK_THE_CLI_PROVIDER'."
        echo "Or use Ollama (local, free): export ASK_THE_CLI_PROVIDER='ollama'"
        return 1
    fi

    echo "Interactive CLI Assistant using $ASK_THE_CLI_PROVIDER (type 'exit' or 'quit' to leave)"
    echo "---"

    while true; do
        echo -n "ask> "
        read -r question

        if [[ "$question" == "exit" ]] || [[ "$question" == "quit" ]]; then
            echo "Goodbye!"
            break
        fi

        if [[ -n "$question" ]]; then
            ask "$question"
            echo ""
        fi
    done
}

# Alias for quick access
alias askme='ask'
alias suggestme='suggest'

# Add completion for common CLI tools
_ask_completion() {
    local -a suggestions
    suggestions=(
        'how do I'
        'what is'
        'explain'
        'show me how to'
    )
    _describe 'ask starters' suggestions
}

compdef _ask_completion ask
