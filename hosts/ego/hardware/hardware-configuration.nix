{
  inputs,
  pkgs,
  ...
}: let
  overlay = pkgs.deviceTree.compileDTS {
    name = "gaokun3-boe-panel-dtbo";
    dtsFile = pkgs.writeText "gaokun3-boe-panel.dts" ''
      /dts-v1/;
      /plugin/;

      / {
      	compatible = "huawei,gaokun3";

      	fragment@0 {
      		target = <&panel>;

      		__overlay__ {
      			compatible = "boe,ppc357db1-4", "himax,hx83121a";
      		};
      	};
      };
    '';
  };
in {
  imports = [
    inputs.gaokun3.nixosModules.gaokun3
  ];
  hardware.gaokun3.enable = true;
  hardware.deviceTree = {
    filter = "sc8280xp-huawei-gaokun3*.dtb";
    overlays = [
      {
        name = "gaokun3-boe-panel";
        filter = "sc8280xp-huawei-gaokun3";
        dtboFile = overlay;
      }
    ];
  };
}
