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
}
