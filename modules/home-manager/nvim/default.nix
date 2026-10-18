{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.lazyvim = {
    enable = true;
    extraPackages = with pkgs; [
      # LazyVim
      stylua
      tree-sitter
      # Telescope
      ripgrep
      # lazygit
      lazygit
      fd
      gcc
    ];
    configFiles = ./lua;
    extras = {
      lang.typescript.enable = true;
      lang.go.enable = true;
      lang.clangd.enable = true;
    };
    # pluginSource = "nixpkgs";
  };
  # Set default editor
  home.sessionVariables.EDITOR = "nvim";
}
