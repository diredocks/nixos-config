let
  sshKeys = import ./ssh-keys-pub.nix;
in {
  "vmiss-la-eth0.network".publicKeys =
    sshKeys.allUsers
    ++ [
      sshKeys.systems.probook-nix
      sshKeys.systems.vmiss-la
    ];
  "vmiss-la-sb-config.json".publicKeys =
    sshKeys.allUsers
    ++ [
      sshKeys.systems.probook-nix
      sshKeys.systems.vmiss-la
    ];
  "racknerd-sb-config.json".publicKeys =
    sshKeys.allUsers
    ++ [
      sshKeys.systems.probook-nix
      sshKeys.systems.racknerd
    ];
  "aliyun-sb-config.json".publicKeys =
    sshKeys.allUsers
    ++ [
      sshKeys.systems.probook-nix
      sshKeys.systems.aliyun
    ];
  "tpm-sb-config.json".publicKeys =
    sshKeys.allUsers
    ++ [
      sshKeys.systems.probook-nix
      sshKeys.systems.tpm312
    ];
  "magpie.key".publicKeys =
    sshKeys.allUsers
    ++ [
      sshKeys.systems.probook-nix
      sshKeys.systems.tpm312
    ];
  "immich.env".publicKeys =
    sshKeys.allUsers
    ++ [
      sshKeys.systems.probook-nix
      sshKeys.systems.tpm312
    ];
  "cloudflare-dns.key".publicKeys =
    sshKeys.allUsers
    ++ [
      sshKeys.systems.probook-nix
      sshKeys.systems.tpm312
    ];
  "infini.key".publicKeys =
    sshKeys.allUsers
    ++ [
      sshKeys.systems.probook-nix
      sshKeys.systems.racknerd
    ];
}
