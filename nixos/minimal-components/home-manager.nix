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

    users.${LT.user} = {
      imports = [entrypoint];
      home = {
        username = LT.user;
        homeDirectory = LT.userHome;
        stateVersion = host.homeStateVersion;
      };
      programs.home-manager.enable = true;
    };
  };
}
