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
      environmentFile = config.age.secrets.cloudflare-dns.path;
      group = config.services.nginx.group;
    };
  };

  age.secrets.cloudflare-dns.file = ../../secrets/cloudflare-dns.key;
}
