#!/usr/bin/env bats

load helpers

@test "renders alertmanager-discord-downtime-proxy Deployment with expected pod spec" {
  deployment=$(echo "$RENDERED" | yq eval-all '
    select(.kind == "Deployment" and .metadata.name == "alertmanager-discord-downtime-proxy")
  ' -)

  namespace=$(echo "$deployment" | yq eval '.metadata.namespace' -)
  replicas=$(echo "$deployment" | yq eval '.spec.replicas' -)
  selector_app=$(echo "$deployment" | yq eval '.spec.selector.matchLabels.app' -)
  container_port=$(echo "$deployment" | yq eval '.spec.template.spec.containers[0].ports[0].containerPort' -)
  webhook_secret_name=$(echo "$deployment" | yq eval '.spec.template.spec.containers[0].env[] | select(.name == "DISCORD_WEBHOOK") | .valueFrom.secretKeyRef.name' -)
  webhook_secret_key=$(echo "$deployment" | yq eval '.spec.template.spec.containers[0].env[] | select(.name == "DISCORD_WEBHOOK") | .valueFrom.secretKeyRef.key' -)

  [ "$namespace" = "monitoring" ]
  [ "$replicas" = "1" ]
  [ "$selector_app" = "alertmanager-discord-downtime-proxy" ]
  [ "$container_port" = "9094" ]
  [ "$webhook_secret_name" = "alertmanager-discord" ]
  [ "$webhook_secret_key" = "DOWNTIME_WEBHOOK_URL" ]
}

@test "renders alertmanager-discord-downtime-proxy Service with expected selector and ports" {
  service=$(echo "$RENDERED" | yq eval-all '
    select(.kind == "Service" and .metadata.name == "alertmanager-discord-downtime-proxy")
  ' -)

  namespace=$(echo "$service" | yq eval '.metadata.namespace' -)
  selector_app=$(echo "$service" | yq eval '.spec.selector.app' -)
  port=$(echo "$service" | yq eval '.spec.ports[0].port' -)
  target_port=$(echo "$service" | yq eval '.spec.ports[0].targetPort' -)

  [ "$namespace" = "monitoring" ]
  [ "$selector_app" = "alertmanager-discord-downtime-proxy" ]
  [ "$port" = "9094" ]
  [ "$target_port" = "9094" ]
}
