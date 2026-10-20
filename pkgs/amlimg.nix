{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "amlimg";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "hzyitc";
    repo = "AmlImg";
    rev = "v${version}";
    sha256 = "sha256-/Vo5/4N06qMwSHI6YkrzPi5wQz1yGBMTcWW7Al9/4I4=";
  };

  vendorHash = null;

  ldflags = [
    "-s"
    "-w"
    "-X"
    "main.version=v${version}"
  ];

  postInstall = ''
    if [ -f "$out/bin/amlimg" ]; then
      mv "$out/bin/amlimg" "$out/bin/AmlImg"
    fi
  '';

  meta = with lib; {
    description = "Tool to create Amlogic burn image for USB_Burning_Tool";
    homepage = "https://github.com/hzyitc/AmlImg";
    license = licenses.bsd3;
    mainProgram = "AmlImg";
    platforms = platforms.unix;
  };
}
