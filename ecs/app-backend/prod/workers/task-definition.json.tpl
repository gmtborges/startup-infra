[
  {
    "name": "app-worker-1",
    "image": "account-id.dkr.ecr.region.amazonaws.com/app-worker:${tag}",
    "memory": 512,
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
        "value": "arn:aws:s3:::app-prod-envs/prod.env",
        "type": "s3"
      }
    ],
    "logConfiguration": {
      "logDriver": "fluentd",
      "options": {
        "tag": "docker.prod",
        "fluentd-address": "localhost:24224"
      }
    }
  }
]
