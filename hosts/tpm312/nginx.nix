{config, ...}: {
  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
  };

  security.acme = {
    acceptTerms = true;
    certs."tpm" = {
      domain = "*.tpm.clickfling.top";
      dnsProvider = "cloudflare";
      # hosts/tpm312/secrets/cloudflare-dns.key
      environmentFile = config.age.secrets."cloudflare-dns.key".path;
      group = config.services.nginx.group;
    };
  };
}
