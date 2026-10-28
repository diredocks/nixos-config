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
      };
  };
}
