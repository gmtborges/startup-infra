[
  {
    "name": "traefik",
    "image": "traefik",
    "memory": 256,
    "portMappings": [
      {
        "name": "web",
        "containerPort": 80,
        "hostPort": 80,
        "protocol": "tcp"
      },
      {
        "name": "traefik",
        "containerPort": 8080,
        "hostPort": 8080,
        "protocol": "tcp"
      }
    ],
    "essential": true,
    "command": [
      "--log.level=info",
      "--api.dashboard=true",
      "--ping=true",
      "--accesslog=true",
      "--accesslog.format=json",
      "--providers.ecs=true",
      "--providers.ecs.clusters=${env}",
      "--providers.ecs.exposedbydefault=false",
      "--providers.file.directory=/config/",
      "--providers.file.watch=true",
      "--entrypoints.web.address=:80"
    ],
    "dockerLabels": {
      "traefik.enable": "true",
      "traefik.http.routers.traefik.entrypoints": "web",
      "traefik.http.routers.traefik.rule": "Host(`traefik.${env}.app.com`)",
      "traefik.http.routers.traefik.service": "api@internal"
    },
    "volumesFrom": [
      {
        "sourceContainer": "config"
      }
    ],
    "logConfiguration": {
      "logDriver": "fluentd",
      "options": {
        "fluentd-address": "localhost:24224",
        "tag": "docker.proxy.${env}"
      }
    }
  },
  {
    "name": "config",
    "image": "${account_id}.dkr.ecr.${aws_region}.amazonaws.com/traefik-config",
    "memory": 64,
    "essential": true,
    "mountPoints": [
      {
        "sourceVolume": "config",
        "containerPath": "/config"
      }
    ]
  },
  {
    "name": "cloudflare",
    "image": "cloudflare/cloudflared",
    "memory": 64,
    "essential": true,
    "command": [
      "tunnel",
      "--no-autoupdate",
      "run"
    ],
    "secrets": [
      {
        "name": "TUNNEL_TOKEN",
        "valueFrom": "arn:aws:ssm:${aws_region}:${account_id}:parameter/CLOUDFLARE_TUNNEL_TOKEN"
      }
    ]
  }
]
