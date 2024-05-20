[
  {
    "name": "traefik",
    "image": "traefik:v2.11",
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
      "--entrypoints.web.address=:80",
      "--entryPoints.web.forwardedHeaders.insecure"
    ],
    "dockerLabels": {
      "traefik.enable": "true",
      "traefik.http.routers.traefik.entrypoints": "web",
      "traefik.http.routers.traefik.rule": "Host(`traefik.${env}.app.gg`)",
      "traefik.http.routers.traefik.service": "api@internal",
      "logging": "promtail",
      "logging_jobname": "proxy"
    }
  }
]
