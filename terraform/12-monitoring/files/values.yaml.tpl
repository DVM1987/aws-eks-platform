defaultRules:
  create: true

prometheusOperator:
  enabled: true
  resources:
    requests:
      cpu: 100m
      memory: 100Mi
    limits:
      cpu: 200m
      memory: 200Mi

prometheus:
  enabled: true
  prometheusSpec:
    serviceMonitorSelectorNilUsesHelmValues: false
    podMonitorSelectorNilUsesHelmValues: false
    ruleSelectorNilUsesHelmValues: false
    probeSelectorNilUsesHelmValues: false
    scrapeConfigSelectorNilUsesHelmValues: false

    retention: ${prometheus_retention}
    retentionSize: "${prometheus_retention_size}"

    resources:
      requests:
        cpu: 200m
        memory: 512Mi
      limits:
        cpu: 1000m
        memory: 2Gi

    storageSpec:
      volumeClaimTemplate:
        spec:
          storageClassName: gp3
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: ${prometheus_pvc_size}

  ingress:
    enabled: false

alertmanager:
  enabled: true
  alertmanagerSpec:
    resources:
      requests:
        cpu: 50m
        memory: 64Mi
      limits:
        cpu: 200m
        memory: 256Mi

    storage:
      volumeClaimTemplate:
        spec:
          storageClassName: gp3
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: ${alertmanager_pvc_size}

  ingress:
    enabled: false

grafana:
  enabled: true
  adminPassword: "${grafana_admin_password}"

  persistence:
    enabled: true
    type: pvc
    storageClassName: gp3
    accessModes: ["ReadWriteOnce"]
    size: ${grafana_pvc_size}

  resources:
    requests:
      cpu: 100m
      memory: 128Mi
    limits:
      cpu: 300m
      memory: 384Mi

  sidecar:
    dashboards:
      enabled: true
      label: grafana_dashboard
      labelValue: "1"
      searchNamespace: ALL
      folder: /tmp/dashboards
    datasources:
      enabled: true
      defaultDatasourceEnabled: true
      searchNamespace: ALL

  grafana.ini:
    server:
      root_url: "https://${grafana_host}"
      serve_from_sub_path: false

  ingress:
    enabled: true
    ingressClassName: alb
    annotations:
      alb.ingress.kubernetes.io/group.name: ${alb_group_name}
      alb.ingress.kubernetes.io/scheme: internet-facing
      alb.ingress.kubernetes.io/target-type: ip
      alb.ingress.kubernetes.io/listen-ports: '[{"HTTP":80},{"HTTPS":443}]'
      alb.ingress.kubernetes.io/ssl-redirect: "443"
      alb.ingress.kubernetes.io/certificate-arn: ${acm_cert_arn}
      alb.ingress.kubernetes.io/healthcheck-path: /api/health
      alb.ingress.kubernetes.io/healthcheck-interval-seconds: "15"
      alb.ingress.kubernetes.io/healthcheck-timeout-seconds: "5"
      alb.ingress.kubernetes.io/success-codes: "200"
    hosts:
      - ${grafana_host}
    path: /
    pathType: Prefix

kube-state-metrics:
  enabled: true

prometheus-node-exporter:
  enabled: true
  hostNetwork: true
  hostPID: true

kubeControllerManager:
  enabled: false
kubeScheduler:
  enabled: false
kubeEtcd:
  enabled: false
kubeProxy:
  enabled: true
