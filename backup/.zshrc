# ------------------------------------------------
# ⚡ Powerlevel10k instant prompt (必须最前)
# ------------------------------------------------
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


# ------------------------------------------------
# PATH 基础
# ------------------------------------------------
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"


# ------------------------------------------------
# ⚡ NVM 懒加载 (解决 shell 启动慢)
# ------------------------------------------------
export NVM_DIR="$HOME/.nvm"
# ------------------------------------------------
# pnpm
# ------------------------------------------------
export PNPM_HOME="$HOME/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"


lazy-nvm() {
  unset -f node npm npx nvm pnpm
  source "$NVM_DIR/nvm.sh"
}

node() { lazy-nvm; node "$@"; }
npm()  { lazy-nvm; npm "$@"; }
npx()  { lazy-nvm; npx "$@"; }
nvm()  { lazy-nvm; nvm "$@"; }
pnpm()  { lazy-nvm; pnpm "$@"; }


# ------------------------------------------------
# Java
# ------------------------------------------------
export JAVA_HOME=$(/usr/libexec/java_home -v 1.8 2>/dev/null)
export PATH="$JAVA_HOME/bin:$PATH"


# ------------------------------------------------
# Perl local lib (如果需要)
# ------------------------------------------------
export PATH="$HOME/perl5/bin:$PATH"
export PERL5LIB="$HOME/perl5/lib/perl5:$PERL5LIB"


# ------------------------------------------------
# Comate
# ------------------------------------------------
export PATH="$HOME/.comate/bin:$PATH"


# ------------------------------------------------
# iTerm2 shell integration
# ------------------------------------------------
[[ -e "$HOME/.iterm2_shell_integration.zsh" ]] && source "$HOME/.iterm2_shell_integration.zsh"


# ------------------------------------------------
# Powerlevel10k
# ------------------------------------------------
source ~/.powerlevel10k/powerlevel10k.zsh-theme
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh


# ------------------------------------------------
# ⚡ Git alias
# ------------------------------------------------
alias g="git"
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gl="git pull"


# ------------------------------------------------
# ⚡ Node / npm alias
# ------------------------------------------------
alias ni="npm install"
alias nr="npm run"
alias nd="npm run dev"
alias nb="npm run build"


# ------------------------------------------------
# ⚡ pnpm alias
# ------------------------------------------------
alias pi="pnpm install"
alias pr="pnpm run"
alias pd="pnpm dev"
alias pb="pnpm build"


# ------------------------------------------------
# ⚡ 通用 alias
# ------------------------------------------------
alias ll="ls -alh"
alias cls="clear"
alias cfg="cd ~/.config && ls -la"
alias killnode="pkill -f node"


# ------------------------------------------------
# 项目目录快捷方式
# ------------------------------------------------
alias webdev="cd ~/Documents/WebDev"
alias workdev="cd ~/Documents/work/nengzhong/react-lingzhou/react"

# code agent ai
export OPENROUTER_API_KEY="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"
