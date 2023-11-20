[
  {
    "name": "app-backend",
    "image": "account-id.dkr.ecr.us-east-2.amazonaws.com/app-backend:${tag}",
    "memory": 256,
    "healthCheck": {
      "command": [
        "CMD-SHELL",
        "curl -f http://localhost:3000/ping || exit 1"
      ],
      "interval": 5,
      "timeout": 5,
      "retries": 3,
      "startPeriod": 10
    },
    "portMappings": [
      {
        "name": "app-backend",
        "containerPort": 3000,
        "protocol": "tcp"
      }
    ],
    "essential": true,
    "environmentFiles": [
      {
        "value": "arn:aws:s3:::app-envs/staging.env",
        "type": "s3"
      }
    ],
    "dockerLabels": {
      "traefik.enable": "true",
      "traefik.http.routers.app-backend-latest.entrypoints": "web",
      "traefik.http.routers.app-backend-latest.rule": "Host(`staging.app.com`)",
      "traefik.http.services.app-backend-latest.loadbalancer.server.port": "3000"
    },
    "logConfiguration": {
      "logDriver": "fluentd",
      "options": {
        "tag": "docker.staging",
        "fluentd-address": "localhost:24224"
      }
    }
  },
  {
    "name": "app-worker-1",
    "image": "account-id.dkr.ecr.us-east-2.amazonaws.com/app-worker:${tag}",
    "memory": 256,
    "command": [
      "npm",
      "run",
      "start:worker-1"
    ],
    "healthCheck": {
      "command": [
        "CMD-SHELL",
        "echo 'healthy' || exit 1"
      ],
      "retries": 3,
      "timeout": 5,
      "interval": 30,
      "startPeriod": null
    },
    "essential": true,
    "environmentFiles": [
      {
        "value": "arn:aws:s3:::app-envs/staging.env",
        "type": "s3"
      }
    ],
    "logConfiguration": {
      "logDriver": "fluentd",
      "options": {
        "tag": "docker.staging",
        "fluentd-address": "localhost:24224"
      }
    }
  }
]
