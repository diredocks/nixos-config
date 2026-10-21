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
    # mozc 2.30.5544.102 (still what nixpkgs ships) fails on Qt >= 6.11: uic now
    # rejects custom widget class names starting with `::`.
    # Upstream fixed it in 3.35.6354 (commit 29c082a, google/mozc#1594), but that
    # release has no git tag yet; nixpkgs tracks the bump in NixOS/nixpkgs#531687.
    # Drop this override once the flake's nixpkgs ships mozc >= 3.35.6354.
    mozc = prev.mozc.overrideAttrs (old: {
      postPatch =
        (old.postPatch or "")
        + ''
          substituteInPlace src/gui/dictionary_tool/dictionary_tool.ui \
            --replace-fail 'class="::mozc::gui::DictionaryContentTableWidget"' \
            'class="mozc::gui::DictionaryContentTableWidget"' \
            --replace-fail '<class>::mozc::gui::DictionaryContentTableWidget</class>' \
            '<class>mozc::gui::DictionaryContentTableWidget</class>'
        '';
    });

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
