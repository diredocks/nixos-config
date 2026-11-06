# Overrides for this directory's auto-discovered secrets.
{...}: {
  age.secrets."vmiss-la-eth0.network" = {
    path = "/etc/systemd/network/vmiss-la-eth0.network";
    mode = "444";
    symlink = true;
  };
}
