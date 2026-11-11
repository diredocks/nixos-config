{
  config,
  pkgs,
  ...
}: let
  endpoint = "aHR0cHM6Ly9hcGkuZ2l0aHViLmNvbS9yZXBvcy9taWxlY3VjdW1iZXIvaXpoaWNoZW5nLWNoZWNraW4vYWN0aW9ucy93b3JrZmxvd3MvY2hlY2tpbi55bWwvZGlzcGF0Y2hlcw==";
in {
  systemd.services.checkin-dispatch = {
    description = "Trigger scheduled check-in workflow via GitHub API";
    path = with pkgs; [curl coreutils];
    script = ''
      set -euo pipefail
      token=$(< "$CREDENTIALS_DIRECTORY/gh-token")
      url=$(printf %s '${endpoint}' | base64 -d)
      curl -sS --fail-with-body -X POST \
        -H "Authorization: Bearer $token" \
        -H "Accept: application/vnd.github+json" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        "$url" \
        -d '{"ref":"main"}' -w '%{http_code}\n'
    '';
    serviceConfig = {
      Type = "oneshot";
      LoadCredential = "gh-token:${config.age.secrets."gh-token".path}";
    };
  };

  systemd.timers.checkin-dispatch = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "*-*-* 21:40:00 Asia/Shanghai";
      Persistent = true;
    };
  };
}
