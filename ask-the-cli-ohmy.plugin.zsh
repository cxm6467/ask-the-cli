# ask-the-cli.plugin.zsh
# Automatically detects questions typed as commands and opens Claude Code
# Free, fast, no API keys needed

# Main handler - intercepts command not found
command_not_found_handler() {
    local cmd="$1"
    shift
    local full_command="$cmd $*"

    # Check if it looks like a question
    if _claude_assist_is_question "$full_command"; then
        echo ""
        echo "🤔 This looks like a question!"
        echo "   → \"$full_command\""
        echo ""

        # Optional: prompt for confirmation (comment out for auto-open)
        echo -n "Open in Claude Code? [Y/n] "
        read -q response
        echo ""

        if [[ $response =~ ^[Yy]$ ]] || [[ -z $response ]]; then
            echo "Opening Claude Code..."
            claude "$full_command"
            return 0
        else
            echo "Cancelled."
            return 1
        fi
    fi

    # Not a question - show normal error
    echo "zsh: command not found: $cmd" >&2
    return 127
}

# Question detection using heuristics
_claude_assist_is_question() {
    local text="$1"

    # Must have at least 2 words
    local word_count=$(echo "$text" | wc -w | tr -d ' ')
    [[ $word_count -lt 2 ]] && return 1

    # Ignore common commands even if they look like questions
    local first_word=$(echo "$text" | awk '{print $1}' | tr '[:upper:]' '[:lower:]')
    case "$first_word" in
        ask|suggest|iask|sudo|cd|ls|git|npm|yarn|pnpm|docker|kubectl|vim|nvim|nano|cat|grep|find|make|cargo|go|python|node|pip|apt|brew|dnf|yum|pacman|systemctl|ssh|scp|rsync)
            return 1
            ;;
    esac

    # Question words at start (case insensitive)
    if [[ "$text" =~ ^[Ww]hat ]] || \
       [[ "$text" =~ ^[Ww]hy ]] || \
       [[ "$text" =~ ^[Hh]ow ]] || \
       [[ "$text" =~ ^[Ww]hen ]] || \
       [[ "$text" =~ ^[Ww]here ]] || \
       [[ "$text" =~ ^[Ww]ho ]] || \
       [[ "$text" =~ ^[Ww]hich ]] || \
       [[ "$text" =~ ^[Cc]an ]] || \
       [[ "$text" =~ ^[Cc]ould ]] || \
       [[ "$text" =~ ^[Ss]hould ]] || \
       [[ "$text" =~ ^[Ww]ould ]] || \
       [[ "$text" =~ ^[Ii]s ]] || \
       [[ "$text" =~ ^[Aa]re ]] || \
       [[ "$text" =~ ^[Dd]o ]] || \
       [[ "$text" =~ ^[Dd]oes ]] || \
       [[ "$text" =~ ^[Dd]id ]] || \
       [[ "$text" =~ ^[Ww]ill ]] || \
       [[ "$text" =~ ^[Hh]as ]] || \
       [[ "$text" =~ ^[Hh]ave ]]; then
        return 0
    fi

    # Contains question mark
    [[ "$text" == *\?* ]] && return 0

    # Common question patterns (case insensitive)
    if echo "$text" | grep -qiE "(difference between|compare|versus|vs|explain|tell me|show me|teach me|help me understand)"; then
        return 0
    fi

    return 1
}

# Optional: Add alias for explicit questions
# alias ask='claude'  # Disabled - conflicts with ask-the-cli plugin
alias '?'='claude'
