# k8s-alertmanager

Alertmanager deployment for the homelab k3s cluster, managed via ArgoCD.

Routes alerts fired by Prometheus to notification targets via two Discord webhooks:
- General alerts → `alertmanager-discord-proxy`
- Downtime alerts (PiNodeExporterDown) → `alertmanager-discord-downtime-proxy`

Run `make check` locally to lint and test manifests.

---

[Homelab Docs](https://github.com/mattjmorrison/homelab/blob/main/docs/INDEX.md)
