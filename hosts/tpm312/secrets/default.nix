# Overrides for this directory's auto-discovered secrets.
{
  config,
  LT,
  ...
}: {
  age.secrets."immich.env".owner = LT.user;
  age.secrets."cloudflare-dns.key".group = config.services.nginx.group;
}
