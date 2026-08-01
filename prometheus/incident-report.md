# Incident Report: Checkout Service Outage

## 📋 Incident Summary

| Field | Details |
|-------|---------|
| **Incident ID** | INC-2026-08-01-001 |
| **Date** | August 1, 2026 |
| **Time** | 14:30 UTC |
| **Duration** | 5 minutes (14:30 - 14:35 UTC) |
| **Severity** | Critical |
| **Status** | Resolved |
| **Service Affected** | Checkout Service (ecommerce namespace) |
| **Impact** | ~50% of checkout requests failed |
| **Root Cause** | Redis memory limit exceeded causing OOM kill |

---

## 📊 Impact Assessment

### Before Incident
- ✅ Checkout pods: 2/2 running
- ✅ Success rate: 99.9%
- ✅ P95 latency: 150ms

### During Incident
- ❌ Checkout pods: 0/2 running (CrashLoopBackOff)
- ❌ Success rate: ~50%
- ❌ P95 latency: 2000ms (timeouts)

### After Incident
- ✅ Checkout pods: 2/2 running
- ✅ Success rate: 99.9%
- ✅ P95 latency: 150ms

---

## ⏱️ Incident Timeline

| Time (UTC) | Event | Who |
|------------|-------|-----|
| **14:30** | Checkout pods enter CrashLoopBackOff after Redis dependency fails | System |
| **14:30:30** | Prometheus alert `PodCrashLooping` triggers | Prometheus |
| **14:31** | Grafana dashboard shows 0/2 pods ready | Oncall Engineer |
| **14:31:30** | Oncall engineer begins investigation | Oncall Engineer |
| **14:32** | `kubectl logs checkout-xxx` shows "connection refused to redis" | Oncall Engineer |
| **14:32:30** | `kubectl get pods -n default` shows Redis pod restarting | Oncall Engineer |
| **14:33** | `kubectl describe pod redis-xxx` shows OOMKilled | Oncall Engineer |
| **14:33:30** | Root cause identified: Redis memory limit too low (100Mi) | Oncall Engineer |
| **14:34** | Redis memory limit increased to 256Mi (via manifest update) | Oncall Engineer |
| **14:34:30** | Redis pod restarts successfully | System |
| **14:35** | Checkout pods restart and become healthy | System |
| **14:35:30** | All services verified healthy | Oncall Engineer |
| **14:36** | Incident resolved | Oncall Engineer |

---

## 🔍 Root Cause Analysis

### Technical Cause
Redis OOM (Out of Memory) killed due to:
- Memory limit set to 100Mi (insufficient)
- Memory usage spiked to 120Mi during peak load
- OOM Killer terminated Redis pod
- Checkout service couldn't connect to Redis → CrashLoopBackOff

### Contributing Factors
1. **No memory requests configured** for Redis (only limits)
2. **No resource monitoring** on Redis pod (spike not detected earlier)
3. **No retry logic** in checkout service for Redis connection failures

### System Context
Checkout Service → Redis Cache
↓
Memory Limit: 100Mi
↓
120Mi used → OOM Kill
↓
Checkout fails → CrashLoopBackOff


---

## 🛠️ Action Items

### Immediate (Completed)
- [x] Increase Redis memory limit from 100Mi to 256Mi
- [x] Add memory requests for Redis (50Mi)
- [x] Restart Redis and Checkout services

### Short-term (Next 48 hours)
- [ ] Add retry logic in checkout service for Redis connection failures
- [ ] Add Redis health check before checkout service starts
- [ ] Configure Prometheus alert for Redis memory usage >80%

### Long-term (Next sprint)
- [ ] Implement circuit breaker pattern for external dependencies
- [ ] Add Redis cluster for high availability
- [ ] Implement graceful degradation when Redis is unavailable
- [ ] Add Chaos testing for dependency failures

---

## 📈 Metrics & Monitoring Additions

```yaml
# Additional Prometheus alerts to prevent recurrence
- alert: RedisMemoryUsage
  expr: (redis_memory_used_bytes / redis_memory_max_bytes) * 100 > 80
  for: 5m
  annotations:
    summary: "Redis memory usage >80%"

- alert: RedisDown
  expr: redis_up == 0
  for: 1m
  annotations:
    summary: "Redis is down"
