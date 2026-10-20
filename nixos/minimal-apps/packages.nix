{
  inputs,
  lib,
  config,
  outputs,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    zip
    rar
    wget
    curl
    vim
    htop
    patchelf
    file
    fzf
    fastfetch
    fd
    ripgrep
    just
    git
    tmux
    jq
  ];
}
