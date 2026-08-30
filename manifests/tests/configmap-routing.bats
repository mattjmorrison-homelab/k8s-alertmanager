#!/usr/bin/env bats

load helpers

@test "routes PiNodeExporterDown alerts to the discord-downtime receiver" {
  alertmanager_config=$(echo "$RENDERED" | yq eval-all '
    select(.kind == "ConfigMap" and .metadata.name == "alertmanager-config") | .data["alertmanager.yml"]
  ' -)

  sub_route_receiver=$(echo "$alertmanager_config" | yq eval '.route.routes[] | select(.receiver == "discord-downtime") | .receiver' -)
  sub_route_matcher=$(echo "$alertmanager_config" | yq eval '.route.routes[] | select(.receiver == "discord-downtime") | .matchers[0]' -)
  receiver_url=$(echo "$alertmanager_config" | yq eval '.receivers[] | select(.name == "discord-downtime") | .webhook_configs[0].url' -)
  receiver_send_resolved=$(echo "$alertmanager_config" | yq eval '.receivers[] | select(.name == "discord-downtime") | .webhook_configs[0].send_resolved' -)

  [ "$sub_route_receiver" = "discord-downtime" ]
  [ "$sub_route_matcher" = 'alertname = "PiNodeExporterDown"' ]
  [ "$receiver_url" = "http://alertmanager-discord-downtime-proxy.monitoring.svc:9094" ]
  [ "$receiver_send_resolved" = "true" ]
}
