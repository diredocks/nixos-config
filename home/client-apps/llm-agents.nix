{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  home.packages = with inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
    opencode
    pi
  ];
}
