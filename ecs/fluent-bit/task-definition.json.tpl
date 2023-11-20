[
  {
    "name": "fluent-bit",
    "image": "fluent/fluent-bit",
    "memory": 128,
    "essential": true,
    "portMappings": [
      {
        "name": "fluent",
        "containerPort": 24224,
        "hostPort": 24224,
        "protocol": "tcp"
      },
      {
        "name": "fluent-udp",
        "containerPort": 5170,
        "hostPort": 5170,
        "protocol": "udp"
      }
    ],
    "volumesFrom": [
      {
        "sourceContainer": "config"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/${env}-cluster",
        "awslogs-region": "${aws_region}",
        "awslogs-stream-prefix": "ecs"
      }
    }
  },
  {
    "name": "config",
    "image": "${account_id}.dkr.ecr.${aws_region}.amazonaws.com/fluent-bit-config",
    "memory": 64,
    "essential": true,
    "mountPoints": [
      {
        "sourceVolume": "config",
        "containerPath": "/fluent-bit/etc/"
      }
    ]
  }
]
