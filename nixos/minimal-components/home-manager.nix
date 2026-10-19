{
  LT,
  config,
  inputs,
  ...
}: let
  host = LT.hosts."${config.networking.hostName}";
  entrypoint =
    if host.hasTag LT.tags.client
    then ../../home/client.nix
    else ../../home/none.nix;
in {
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {inherit inputs LT;};

    users.leo = {
      imports = [entrypoint];
      home = {
        username = "leo";
        homeDirectory = "/home/leo";
        stateVersion = host.homeStateVersion;
      };
      programs.home-manager.enable = true;
    };
  };
}
