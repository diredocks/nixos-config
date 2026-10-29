# This file defines overlays
{inputs, ...}: {
  # Custom packages from the 'pkgs' directory. `prev.lib` avoids forcing
  # `final` while building the attrset, which would recurse.
  additions = final: prev:
    import ../pkgs {
      pkgs = final;
      inherit (prev) lib;
    };

  # This one contains whatever you want to overlay
  modifications = final: prev: {
    strawberry = prev.strawberry.overrideAttrs (old: rec {
      src = prev.fetchFromGitHub {
        owner = "diredocks";
        repo = "strawberryNE";
        rev = "4d79f85ea212aa7267f5c662233ac9f59da2f67f";
        hash = "sha256-zObmN1MlVLg7H+otBarCwXFykcCdgfBLvLFddbnCIgI=";
      };
    });
  };
}
