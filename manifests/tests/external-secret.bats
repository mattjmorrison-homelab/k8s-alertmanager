#!/usr/bin/env bats

load helpers

@test "renders alertmanager-discord ExternalSecret with DOWNTIME_WEBHOOK_URL data entry" {
  external_secret=$(echo "$RENDERED" | yq eval-all '
    select(.kind == "ExternalSecret" and .metadata.name == "alertmanager-discord")
  ' -)

  remote_ref_key=$(echo "$external_secret" | yq eval '.spec.data[] | select(.secretKey == "DOWNTIME_WEBHOOK_URL") | .remoteRef.key' -)
  remote_ref_property=$(echo "$external_secret" | yq eval '.spec.data[] | select(.secretKey == "DOWNTIME_WEBHOOK_URL") | .remoteRef.property' -)

  [ "$remote_ref_key" = "homelab/k8s-alertmanager/downtime-webhook-url" ]
  [ "$remote_ref_property" = "value" ]
}
