local base = import './base.libsonnet';

base {
  components +: {
      currencyservice +: {
          cpu_limits: "400m",
          memory_limits: "256Mi",
      },
  },
}