[
  {
    "name": "app-backend-green",
    "image": "account-id.dkr.ecr.region.amazonaws.com/app-backend:${tag}",
    "memory": 512,
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
        "value": "arn:aws:s3:::app-prod-envs/prod.env",
        "type": "s3"
      }
    ],
    "dockerLabels": {
      "traefik.enable": "true",
      "traefik.http.routers.app-green.entrypoints": "web",
      "traefik.http.routers.app-green.rule": "Host(`green.prod.app.com`)",
      "traefik.http.services.app-green.loadbalancer.server.port": "3000"
    },
    "logConfiguration": {
      "logDriver": "fluentd",
      "options": {
        "tag": "docker.prod",
        "fluentd-address": "localhost:24224"
      }
    }
  }
]
