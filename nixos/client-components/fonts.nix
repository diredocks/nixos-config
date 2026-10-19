{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      source-han-sans
      source-han-serif
      source-code-pro
      jetbrains-mono
      ubuntu-classic
      # nerd-fonts.jetbrains-mono
      nerd-fonts.comic-shanns-mono
      # nerd-fonts.agave
      # nerd-fonts.iosevka
      adwaita-fonts
    ];
    fontconfig = {
      enable = true;
      defaultFonts = {
        emoji = ["Noto Color Emoji"];
        monospace = ["Noto Sans Mono CJK SC" "DejaVu Sans Mono"];
        sansSerif = ["Noto Sans CJK SC" "Source Han Sans SC" "DejaVu Sans"];
        serif = ["Noto Serif CJK SC" "Source Han Serif SC" "DejaVu Serif"];
      };
      useEmbeddedBitmaps = true;
      antialias = true;
      subpixel.rgba = "rgb";
      hinting.style = "slight";
    };
  };
}
