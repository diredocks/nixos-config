{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  programs.zsh = {
    enable = true;
    shellAliases = {
      neofetch = "fastfetch";
    };
    antidote = {
      enable = true;
      plugins = [
        # oh-my-zsh libs
        "getantidote/use-omz"
        "ohmyzsh/ohmyzsh path:lib"
        # oh-my-zsh plugins
        "ohmyzsh/ohmyzsh path:plugins/z"
        "ohmyzsh/ohmyzsh path:plugins/git"
        "ohmyzsh/ohmyzsh path:plugins/ssh-agent"
        # theme
        "ohmyzsh/ohmyzsh path:themes/ys.zsh-theme"
        # community
        "Aloxaf/fzf-tab"
        "zsh-users/zsh-autosuggestions"
        "joshskidmore/zsh-fzf-history-search"
      ];
    };
    enableCompletion = false;
    initContent = ''
      zstyle :omz:plugins:ssh-agent identities github_key
      zstyle :omz:plugins:ssh-agent lifetime 24h
      zstyle :omz:plugins:ssh-agent lazy yes
    '';
  };
}
