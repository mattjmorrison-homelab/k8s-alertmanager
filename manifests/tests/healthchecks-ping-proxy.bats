#!/usr/bin/env bats

load helpers

@test "renders healthchecks-ping-proxy Deployment with expected pod spec" {
  deployment=$(echo "$RENDERED" | yq eval-all '
    select(.kind == "Deployment" and .metadata.name == "healthchecks-ping-proxy")
  ' -)

  namespace=$(echo "$deployment" | yq eval '.metadata.namespace' -)
  replicas=$(echo "$deployment" | yq eval '.spec.replicas' -)
  selector_app=$(echo "$deployment" | yq eval '.spec.selector.matchLabels.app' -)
  container_port=$(echo "$deployment" | yq eval '.spec.template.spec.containers[0].ports[0].containerPort' -)
  ping_url_secret_name=$(echo "$deployment" | yq eval '.spec.template.spec.containers[0].env[] | select(.name == "PING_URL") | .valueFrom.secretKeyRef.name' -)
  ping_url_secret_key=$(echo "$deployment" | yq eval '.spec.template.spec.containers[0].env[] | select(.name == "PING_URL") | .valueFrom.secretKeyRef.key' -)
  template_volume_configmap=$(echo "$deployment" | yq eval '.spec.template.spec.volumes[] | select(.name == "nginx-template") | .configMap.name' -)
  template_mount_path=$(echo "$deployment" | yq eval '.spec.template.spec.containers[0].volumeMounts[] | select(.name == "nginx-template") | .mountPath' -)

  [ "$namespace" = "monitoring" ]
  [ "$replicas" = "1" ]
  [ "$selector_app" = "healthchecks-ping-proxy" ]
  [ "$container_port" = "9095" ]
  [ "$ping_url_secret_name" = "healthchecks-ping" ]
  [ "$ping_url_secret_key" = "PING_URL" ]
  [ "$template_volume_configmap" = "healthchecks-ping-proxy-template" ]
  [ "$template_mount_path" = "/etc/nginx/templates" ]
}

@test "renders healthchecks-ping-proxy Service with expected selector and ports" {
  service=$(echo "$RENDERED" | yq eval-all '
    select(.kind == "Service" and .metadata.name == "healthchecks-ping-proxy")
  ' -)

  namespace=$(echo "$service" | yq eval '.metadata.namespace' -)
  selector_app=$(echo "$service" | yq eval '.spec.selector.app' -)
  port=$(echo "$service" | yq eval '.spec.ports[0].port' -)
  target_port=$(echo "$service" | yq eval '.spec.ports[0].targetPort' -)

  [ "$namespace" = "monitoring" ]
  [ "$selector_app" = "healthchecks-ping-proxy" ]
  [ "$port" = "9095" ]
  [ "$target_port" = "9095" ]
}

@test "renders healthchecks-ping-proxy-template ConfigMap with an nginx envsubst template" {
  configmap=$(echo "$RENDERED" | yq eval-all '
    select(.kind == "ConfigMap" and .metadata.name == "healthchecks-ping-proxy-template")
  ' -)

  namespace=$(echo "$configmap" | yq eval '.metadata.namespace' -)
  template=$(echo "$configmap" | yq eval '.data["default.conf.template"]' -)

  [ "$namespace" = "monitoring" ]
  [[ "$template" == *"listen 9095;"* ]]
  [[ "$template" == *'proxy_pass $PING_URL;'* ]]
}
