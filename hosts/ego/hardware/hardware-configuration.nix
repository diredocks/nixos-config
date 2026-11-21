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
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 1024 * 8;
    }
  ];
  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };
  services.udev.extraRules = ''
    ACTION=="add|change", SUBSYSTEM=="power_supply", KERNEL=="gaokun-ec-battery", ATTR{smart_charge_delay}="24", ATTR{charge_control_end_threshold}="70", ATTR{charge_control_start_threshold}="40", ATTR{battery_adaptive_charge}="1"
    ACTION=="add|change", SUBSYSTEM=="input", KERNEL=="event*", ATTRS{idVendor}=="12d1", ATTRS{idProduct}=="10b8", ENV{ID_INPUT_TOUCHPAD}=="1", ENV{ID_BUS}="i2c", ENV{ID_INPUT_TOUCHPAD_INTEGRATION}="internal"
  '';
  environment.etc."libinput/local-overrides.quirks".text = ''
    [Huawei MateBook E Go Internal Keyboard]
    MatchUdevType=keyboard
    MatchBus=usb
    MatchVendor=0x12D1
    MatchProduct=0x10B8
    AttrKeyboardIntegration=internal
  '';
}
