{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    qbittorrent
    inkscape
    obs-studio
    # brave was removed from nixpkgs on 2026-11-03 (no maintainers left to
    # handle security issues); restore the override below if it returns.
    # (brave.override {
    #   commandLineArgs = [
    #     "--enable-features=TouchpadOverscrollHistoryNavigation"
    #   ];
    # })
    hugo
    wireshark
    telegram-desktop
    firefox
    obsidian
    vlc
    remmina
    # zed-editor
    thunderbird
    hmcl
    # jetbrains.idea
    wl-clipboard
    html-to-markdown
  ];
}
