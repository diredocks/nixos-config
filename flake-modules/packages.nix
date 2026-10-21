{
  self,
  lib,
  ...
}: {
  perSystem = {
    system,
    pkgs,
    lib,
    ...
  }: {
    packages =
      (import ../pkgs {inherit pkgs lib;})
      // lib.optionalAttrs (system == "x86_64-linux") {
        # nix build .#packages.x86_64-linux.<name>
        vmiss-la-image = self.nixosConfigurations.vmiss-la.config.system.build.diskoImages;
        racknerd-image = self.nixosConfigurations.racknerd.config.system.build.diskoImages;
        aliyun-image = self.nixosConfigurations.aliyun.config.system.build.diskoImages;
      }
      // lib.optionalAttrs (system == "aarch64-linux") {
        # nix build .#packages.aarch64-linux.tpm312-image
        tpm312-image = self.nixosConfigurations.tpm312.config.system.build.sdImage;
      }
      // lib.optionalAttrs (system == "armv7l-linux") {
        # nix build .#packages.armv7l-linux.onecloud-image
        onecloud-image = self.nixosConfigurations.onecloud.config.system.build.sdImage;
        # nix build .#packages.armv7l-linux.onecloud-burn-image
        onecloud-burn-image = self.nixosConfigurations.onecloud.config.system.build.burnImage;
      };
  };
}
