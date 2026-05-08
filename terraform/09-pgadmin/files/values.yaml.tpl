replicaCount: 1

env:
  email: ${admin_email}
  password: ${admin_password}

persistentVolume:
  enabled: true
  storageClass: gp3
  size: 8Gi
  accessModes:
    - ReadWriteOnce

ingress:
  enabled: true
  ingressClassName: alb
  annotations:
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/group.name: ${alb_group_name}
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP":80},{"HTTPS":443}]'
    alb.ingress.kubernetes.io/ssl-redirect: '443'
    alb.ingress.kubernetes.io/certificate-arn: ${acm_cert_arn}
    alb.ingress.kubernetes.io/healthcheck-path: /misc/ping
    alb.ingress.kubernetes.io/healthcheck-protocol: HTTP
  hosts:
    - host: ${host}
      paths:
        - path: /
          pathType: Prefix

resources:
  requests:
    cpu: 100m
    memory: 200Mi
  limits:
    cpu: 200m
    memory: 500Mi

startupProbe:
  failureThreshold: 30
  periodSeconds: 10
  timeoutSeconds: 5
