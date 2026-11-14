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
  # Autologin stays off on purpose. With SDDM's Wayland greeter the autologin
  # session receives SIGTERM ~0.5 s after "Session started true" (reproduced on
  # 3/3 boots), sddm falls back to the greeter, and the kwin the still-running
  # startplasma-wayland then launches is bound to a logind session that no
  # longer exists: "Could not determine the active graphical session" ->
  # "Failed to open drm device /dev/dri/card1: Permission denied" -> no outputs
  # -> plasmashell SIGSEGV x3 -> start-limit-hit, so no desktop
  # (sddm #2142 and friends). Re-enable once that hand-off is fixed upstream.
  services.displayManager = {
    autoLogin.enable = false;
  };
  # kwin_wayland opens /dev/dri/card1 (root:video 0660) itself whenever logind
  # cannot hand it a seat, so GPU access must not depend only on the per-session
  # uaccess ACL: once that ACL is revoked the failure is a hard EACCES, not a
  # warning, and the compositor comes up headless.
  users.users.${LT.user}.extraGroups = ["video"];
  services.desktopManager.plasma6.enable = true;
  programs.kdeconnect.enable = true;
  environment.systemPackages = with pkgs; [
    inputs.inputactions-ctl.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.inputactions-kwin.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.inputactions-overlay.packages.${pkgs.stdenv.hostPlatform.system}.default
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
