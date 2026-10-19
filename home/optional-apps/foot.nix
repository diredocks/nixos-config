{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  programs.foot = {
    enable = true;
    settings = {
      main = {
        term = "xterm-256color";
        font = "ComicShannsMono Nerd Font:size=14";
        pad = "0x0";
        resize-delay-ms = 0;
        initial-window-size-chars = "115x35";
      };

      mouse = {
        hide-when-typing = "yes";
      };

      cursor = {
        style = "block";
        blink = "no";
      };

      bell = {
        system = "no";
      };

      colors = {
        background = "24283b";
        foreground = "a9b1d6";

        regular0 = "32344a";
        regular1 = "f7768e";
        regular2 = "9ece6a";
        regular3 = "e0af68";
        regular4 = "7aa2f7";
        regular5 = "ad8ee6";
        regular6 = "449dab";
        regular7 = "9699a8";

        bright0 = "444b6a";
        bright1 = "ff7a93";
        bright2 = "b9f27c";
        bright3 = "ff9e64";
        bright4 = "7da6ff";
        bright5 = "bb9af7";
        bright6 = "0db9d7";
        bright7 = "acb0d0";
      };
    };
  };
}
