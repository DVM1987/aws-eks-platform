# muoidv Sub-comp 08 — PostgreSQL Bitnami values (rendered by templatefile)

fullnameOverride: ${release_name}

# Override sang bitnamilegacy do Bitnami migrate 2025-08
image:
  repository: ${image_repository}

auth:
  postgresPassword: "${postgres_password}"
  username: ${app_username}
  password: "${app_password}"
  database: ${app_database}

primary:
  resources:
    requests:
      cpu: ${cpu_request}
      memory: ${memory_request}
    limits:
      cpu: ${cpu_limit}
      memory: ${memory_limit}
