{
  self,
  inputs,
  lib,
  ...
}: let
  # `deploy-rs.lib` lives only in the overlay, which rebuilds deploy-rs from
  # source — keep nixpkgs' binary and take just the lib.
  deployRsOverlay = final: prev: {
    deploy-rs = {
      inherit (prev) deploy-rs;
      inherit ((inputs.deploy-rs.overlays.default final prev).deploy-rs) lib;
    };
  };

  # Activation runs on the target, so it needs the host's own (platform-correct)
  # package set.
  activateFor = cfg: (cfg.pkgs.extend deployRsOverlay).deploy-rs.lib.activate.nixos cfg;
in {
  flake.deploy = {
    sshUser = "root";
    user = "root";
    interactiveSudo = false;
    autoRollback = true;
    magicRollback = true;
    remoteBuild = true;

    nodes =
      lib.mapAttrs (host: hostname: {
        inherit hostname;
        profiles.system.path = activateFor self.nixosConfigurations.${host};
      }) {
        vmiss-la = "vmlatl";
        racknerd = "rntl";
        aliyun = "alitl";
        tpm312 = "tpmtl";
      };
  };
}
