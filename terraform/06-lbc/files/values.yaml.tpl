clusterName: ${cluster_name}
region: ${region}
vpcId: ${vpc_id}

replicaCount: ${replica_count}

serviceAccount:
  create: true
  name: ${service_account}
  annotations:
    eks.amazonaws.com/role-arn: ${irsa_role_arn}

resources:
  requests:
    cpu: 100m
    memory: 200Mi
  limits:
    cpu: 200m
    memory: 500Mi

enableServiceMutatorWebhook: false
