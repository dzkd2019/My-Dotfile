ZIM_HOME=${ZDOTDIR:-${HOME}}/.zim
ZDOTDIR=${HOME}/.zim
# Install missing modules and update ${ZIM_HOME}/init.zsh if missing or outdated.
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZIM_CONFIG_FILE:-${ZDOTDIR:-${HOME}}/.zimrc} ]]; then
  source /usr/share/zimfw/zimfw.zsh init
fi


# 配置bat，使其可以接管-h --help的输出，利用less进行分页并进行彩色输出
alias vim='nvim'
alias bathelp='bat --plain --language=help'
alias -g -- -h='-h 2>&1 | bat --language=help --style=plain'
alias -g -- --help='--help 2>&1 | bat --language=help --style=plain'

alias update='sudo pacman -Syu'

psearch() {
  pacman -Ss "$@"
}

aursearch() {
  paru -Ss "$@"
}

haspackage() {
  pacman -Q | rg -i "$@"
}

help() {
    "$@" --help 2>&1 | bathelp
}

# fd配合as-tree，将搜索结果进行树状输出
tree() {
    fd . "$@" | as-tree
}

# ripgrep->fzf->vim [QUERY]
# fzf配合ripgrep，不使用交互模式，在当前目录搜索一个pattern串，并调用bat进行预览，enter/ctrl+o调用nvim编辑
rgv() (
  RELOAD='reload:rg --column --color=always --smart-case {q} || :'
  OPENER='if [[ $FZF_SELECT_COUNT -eq 0 ]]; then
            nvim {1} +{2}     # No selection. Open the current line in nvim.
          else
            nvim +cw -q {+f}  # Build quickfix list for the selected items.
          fi'
  fzf --disabled --ansi --multi \
      --bind "start:$RELOAD" --bind "change:$RELOAD" \
      --bind "enter:become:$OPENER" \
      --bind "ctrl-o:execute:$OPENER" \
      --bind 'alt-a:select-all,alt-d:deselect-all,ctrl-/:toggle-preview' \
      --delimiter : \
      --preview 'bat --style=full --color=always --highlight-line {2} {1}' \
      --preview-window '~4,+{2}+4/3,<80(up)' \
      --query "$*"
)

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

eval "$(ssh-agent -s)" > /dev/null 2>&1
ssh-add ~/.ssh/id_ed25519 > /dev/null 2>&1

set -o vi

# Initialize modules.
source ${ZIM_HOME}/init.zsh
eval "$(zoxide init zsh)"

unsetopt NOCLOBBER

export RUSTUP_UPDATE_ROOT=https://mirrors.tuna.tsinghua.edu.cn/rustup/rustup
export RUSTUP_DIST_SERVER=https://mirrors.tuna.tsinghua.edu.cn/rustup
export UV_DEFAULT_INDEX=https://pypi.tuna.tsinghua.edu.cn/simple
export PATH="$PATH:$HOME/go/bin"
export CLAUDE_CODE_REMOTE_SEND_KEEPALIVES=true
export BUN_CONFIG_HTTP_IDLE_TIMEOUT=300
export BUN_CONFIG_HTTP_RETRY_COUNT=3
export NODE_OPTIONS="--dns-result-order=ipv4first"
export TLDR_CACHE_ENABLED=1
