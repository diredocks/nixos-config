# The gaokun3 board tree in the upstream project describes the CSOT
# PPC357DB1-4 panel, and this machine has the BOE PPC357DB1-4 instead. Both are
# HX83121A panels with identical timings; what differs is the init sequence in
# panel-himax-hx83121a, and the driver selects it at probe time from the panel
# node's *first* compatible (`of_device_get_match_data`). Booting a BOE panel
# with the CSOT sequence leaves the panel partly initialised, so the board tree
# has to say which one is fitted.
#
# Fixing that in the gaokun3 input would mean carrying a fork of its dts/, so
# the correction is a device tree overlay applied by NixOS instead: it retargets
# only the panel node of the gaokun3 DTBs and leaves the kernel package -- and
# with it the binary cache hits -- untouched. The kernel is patched to keep
# symbols in the DTBs (`dtc -@`), which is what lets the overlay name the node
# by its `panel` label rather than by a path.
{pkgs, ...}: let
  # The overlay is compiled here rather than left to
  # hardware.deviceTree.overlays, because that path passes the kernel's -dev
  # output to deviceTree.compileDTS as its #include search path. The -dev output
  # is not in the gaokun3 cache, so asking for it would make every build of this
  # module (and of the installer ISO) build the whole kernel. This overlay
  # includes nothing, so it compiles on its own.
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
  hardware.deviceTree = {
    # `dtbSource` is the kernel's whole dtbs/ tree and applyOverlays rewrites
    # every .dtb it finds there. This module only ever boots the gaokun3 trees,
    # so filter the source down to them before the overlay pass; the overlay's
    # own filter then names the trees whose panel node it must touch.
    filter = "sc8280xp-huawei-gaokun3*.dtb";

    overlays = [
      {
        name = "gaokun3-boe-panel";
        # A substring test against the DTB path, not a glob. Both the normal
        # and the EL2 tree (sc8280xp-huawei-gaokun3-el2.dtb) match.
        filter = "sc8280xp-huawei-gaokun3";
        dtboFile = overlay;
      }
    ];
  };
}
