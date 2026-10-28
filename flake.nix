{
  description = "Diredocks' NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    inputactions-ctl = {
      url = "git+https://github.com/InputActions/ctl?submodules=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    inputactions-kwin = {
      url = "git+https://github.com/InputActions/kwin?submodules=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    inputactions-overlay = {
      url = "git+https://github.com/InputActions/overlay?submodules=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lazyvim = {
      url = "github:pfassina/lazyvim-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];

      imports = [
        ./flake-modules/deploy.nix
        ./flake-modules/nixos-configurations.nix
        ./flake-modules/packages.nix
      ];

      flake = {
        overlays = import ./overlays {inherit inputs;};
      };

      perSystem = {pkgs, ...}: {
        formatter = pkgs.alejandra;
      };
    };
}
