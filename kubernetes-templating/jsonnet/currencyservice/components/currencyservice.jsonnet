local env = {
  name: std.extVar('qbec.io/env'),
  namespace: std.extVar('qbec.io/defaultNs'),
};

local p = import '../params.libsonnet';
local params = p.components.currencyservice;

[
  {
  "apiVersion": "apps/v1",
  "kind": "Deployment",
  "metadata": {
    "name": params.name
  },
  "spec": {
    "selector": {
      "matchLabels": {
        "app": params.name
      }
    },
    "template": {
      "metadata": {
        "labels": {
          "app": params.name
        }
      },
      "spec": {

        "containers": [
          {
            "name": "server",
            "image": params.image,
            "ports": [
              {
                "containerPort": params.containterPort
              }
            ],
            "readinessProbe": {
              "exec": {
                "command": [
                  "/bin/grpc_health_probe",
                  "-addr=:7000"
                ]
              }
            },
            "livenessProbe": {
              "exec": {
                "command": [
                  "/bin/grpc_health_probe",
                  "-addr=:7000"
                ]
              }
            },
            "env": [
              {
                "name": "PORT",
                "value": "7000"
              }
            ],
            "resources": {
              "requests": {
                "cpu": params.cpu_requests,
                "memory": params.memory_requests
              },
              "limits": {
                "cpu": params.cpu_limits,
                "memory": params.memory_limits
              }
            }
          }
        ]
      }
    }
  }
},

{
  "apiVersion": "v1",
  "kind": "Service",
  "metadata": {
    "name": params.name
  },
  "spec": {
    "type": "ClusterIP",
    "selector": {
      "app": params.name
    },
    "ports": [
      {
        "name": "grpc",
        "port": params.servicePort,
        "targetPort": params.containterPort
      }
    ]
  }
}
]