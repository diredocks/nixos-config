{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  LT,
  ...
}: {
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.displayManager = {
    autoLogin.enable = true;
    autoLogin.user = LT.user;
  };
  services.desktopManager.plasma6.enable = true;
  programs.kdeconnect.enable = true;
  environment.systemPackages = with pkgs; [
    inputs.inputactions.packages.${pkgs.stdenv.hostPlatform.system}.inputactions-ctl
    inputs.inputactions.packages.${pkgs.stdenv.hostPlatform.system}.inputactions-kwin
    kdePackages.oxygen
  ];
  security.pam.services.${LT.user}.kwallet.enable = true;
  services.udev.packages = [
    (pkgs.writeTextFile {
      name = "inputactions-udev-rules";
      text = ''
        ENV{ID_INPUT_TOUCHPAD}=="1", TAG+="uaccess"
      '';
      destination = "/etc/udev/rules.d/71-touchpad.rules";
    })
  ];
  programs.kde-pim.enable = false;
  security.polkit = {
    enable = true;
    enablePkexecWrapper = true;
  };
}
