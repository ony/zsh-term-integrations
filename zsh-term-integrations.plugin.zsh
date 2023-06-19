0="${${ZERO:-${0:#$ZSH_ARGZERO}}:-${(%):-%N}}"
0="${${(M)0:#/*}:-$PWD/$0}"

autoload -Uz add-zsh-hook

# generic title reporting using ncurses
if tput hs; then
  _tput_tsl=$(tput tsl)
  _tput_fsl=$(tput fsl)
  _zsh_term_integration_title() {
    if [[ -n "$PS_TERM_TITLE" ]]; then
      print -Pn "$_tput_tsl$PS_TERM_TITLE$_tput_fsl"
    fi
  }
  add-zsh-hook precmd _zsh_term_integration_title
fi

# https://codeberg.org/dnkl/foot/wiki#user-content-shell-integration
case "$TERM" in
foot|foot-*|foot+*)
  _zsh_term_integration_prompt_marker() {
    print -Pn "\e]133;A\e\\"
  }
  add-zsh-hook precmd _zsh_term_integration_prompt_marker

  _zsh_term_integration_pwd_info() {
    local LC_ALL=C
    export LC_ALL
    setopt localoptions extendedglob
    input=( ${(s::)PWD} )
    uri=${(j::)input/(#b)([^A-Za-z0-9_.\!~*\'\(\)-\/])/%${(l:2::0:)$(([##16]#match))}}
    print -n "\e]7;file://${HOSTNAME}${uri}\e\\"
  }
  add-zsh-hook chpwd _zsh_term_integration_pwd_info
  ;;
esac

# https://sw.kovidgoyal.net/kitty/overview/#integration-with-shells
if test -n "$KITTY_INSTALLATION_DIR"; then
  export KITTY_SHELL_INTEGRATION="enabled"
  autoload -Uz -- "$KITTY_INSTALLATION_DIR"/shell-integration/zsh/kitty-integration
  kitty-integration
  unfunction kitty-integration
fi
