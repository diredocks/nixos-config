{
  self,
  inputs,
  lib,
  ...
}: let
  LT = import ../helpers {
    inherit inputs self lib;
  };

  # All deploy targets are x86_64-linux, so only build that package set.
  deployPkgs = import inputs.nixpkgs {
    system = "x86_64-linux";
    overlays = [
      (final: prev: {
        deploy-rs = {
          inherit ((inputs.deploy-rs.overlays.default final prev).deploy-rs) lib;
          inherit (prev) deploy-rs;
        };
      })
    ];
  };
in {
  flake.deploy = {
    sshUser = LT.user;
    user = "root";
    interactiveSudo = true;
    autoRollback = false;
    magicRollback = false;
    remoteBuild = true;

    nodes =
      lib.mapAttrs (host: hostname: {
        inherit hostname;
        profiles.system.path = deployPkgs.deploy-rs.lib.activate.nixos self.nixosConfigurations.${host};
      }) {
        vmiss-la = "vmlatl";
        racknerd = "rntl";
        aliyun = "alitl";
      };
  };
}
