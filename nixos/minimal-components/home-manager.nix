{
  LT,
  inputs,
  ...
}: let
  entrypoint =
    if LT.this.hasTag LT.tags.client
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
        stateVersion = LT.this.homeStateVersion;
      };
      programs.home-manager.enable = true;
    };
  };
}
