{
  components: {
    currencyservice: {
      name: "currencyservice",
      image: "gcr.io/google-samples/microservices-demo/currencyservice:v0.1.3",
      cpu_requests: "100m",
      memory_requests: "64Mi",
      cpu_limits: "200m",
      memory_limits: "128Mi",
      containterPort: 7000,
      servicePort: 7000,
    },
  },
}