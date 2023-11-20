[
  {
    "name": "prometheus",
    "image": "prom/prometheus:v2.47.0",
    "memory": 512,
    "portMappings": [
      {
        "name": "prom",
        "containerPort": 9090,
        "hostPort": 9090,
        "protocol": "tcp"
      }
    ],
    "volumesFrom": [
      {
        "sourceContainer": "monitor-config"
      }
    ],
    "mountPoints": [
      {
        "sourceVolume": "prometheus-vol",
        "containerPath": "/prometheus"
      }
    ],
    "links": [
      "alertmanager"
    ],
    "essential": true,
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/prod-cluster",
        "awslogs-region": "sa-east-1",
        "awslogs-stream-prefix": "ecs"
      }
    }
  },
  {
    "name": "monitor-config",
    "image": "${account_id}.dkr.ecr.${aws_region}.amazonaws.com/monitor-config",
    "memory": 64,
    "essential": true,
    "mountPoints": [
      {
        "sourceVolume": "prom-config",
        "containerPath": "/etc/prometheus/"
      },
      {
        "sourceVolume": "alert-config",
        "containerPath": "/etc/alertmanager/"
      }
    ]
  },
  {
    "name": "grafana",
    "image": "grafana/grafana-oss",
    "memory": 1024,
    "portMappings": [
      {
        "name": "grafana",
        "containerPort": 3000,
        "protocol": "tcp"
      }
    ],
    "environment": [
      {
        "name": "GF_SERVER_ROOT_URL",
        "value": "http://grafana.prod.app.com"
      },
      {
        "name": "GF_INSTALL_PLUGINS",
        "value": "grafana-clock-panel,grafana-piechart-panel,camptocamp-prometheus-alertmanager-datasource,vonage-status-panel"
      }
    ],
    "mountPoints": [
      {
        "sourceVolume": "grafana-vol",
        "containerPath": "/var/lib/grafana"
      }
    ],
    "essential": true,
    "dockerLabels": {
      "traefik.enable": "true",
      "traefik.http.routers.grafana.entrypoints": "web",
      "traefik.http.routers.grafana.rule": "Host(`grafana.prod.app.com`)"
    },
    "links": [
      "prometheus",
      "alertmanager"
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/prod-cluster",
        "awslogs-region": "sa-east-1",
        "awslogs-stream-prefix": "ecs"
      }
    }
  },
  {
    "name": "alertmanager",
    "image": "prom/alertmanager:v0.26.0",
    "memory": 256,
    "portMappings": [
      {
        "name": "alertmanager",
        "containerPort": 9093,
        "hostPort": 9093,
        "protocol": "tcp"
      }
    ],
    "volumesFrom": [
      {
        "sourceContainer": "monitor-config"
      }
    ],
    "essential": true,
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/prod-cluster",
        "awslogs-region": "sa-east-1",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]
