# k8s-alertmanager

Alertmanager deployment for the homelab k3s cluster, managed via ArgoCD.

Routes alerts fired by Prometheus to notification targets:
- General alerts → `alertmanager-discord-proxy` (Discord)
- Downtime alerts (PiNodeExporterDown) → `alertmanager-discord-downtime-proxy` (Discord)
- Dead-man's-switch heartbeat (Watchdog, always-firing) → `healthchecks-ping-proxy`, a thin nginx envsubst proxy that pings a self-hosted Healthchecks.io check. The real ping URL (with its secret UUID) lives in the `healthchecks-ping` Secret via External Secrets, never in a ConfigMap — the proxy exists solely so that URL never has to appear in this public repo. `repeat_interval` on this route is 5m, much shorter than the default 4h, so a missed heartbeat is caught promptly. `PING_URL` is blank until a human creates the check in the Healthchecks UI post-deploy.

Run `make check` locally to lint and test manifests.

---

[Homelab Docs](https://github.com/mattjmorrison/homelab/blob/main/docs/INDEX.md)
