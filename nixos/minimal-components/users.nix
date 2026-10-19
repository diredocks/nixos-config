{
  pkgs,
  LT,
  ...
}: {
  # Base interactive account. Host- and role-specific bits (SSH keys, extra
  # groups, PAM/desktop integration) are added by the relevant modules.
  users.users.${LT.user} = {
    isNormalUser = true;
    initialPassword = "1";
    extraGroups = ["wheel"];
    shell = pkgs.zsh;
  };
}
