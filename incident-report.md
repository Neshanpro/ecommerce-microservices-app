# 🚨 Post-Mortem Report: Checkout Service Outage

---

## 📋 Incident Summary

| Attribute | Details |
| :--- | :--- |
| **Incident ID** | `INC-2026-08-01-001` |
| **Date** | August 1, 2026 |
| **Time Frame** | 14:30 UTC – 14:35 UTC |
| **Duration** | 5 minutes |
| **Severity** | **Critical (Sev-1)** |
| **Status** | **Resolved** |
| **Services Affected** | Checkout Service (`ecommerce` namespace), Redis (`default` namespace) |
| **User Impact** | ~50% of checkout transaction requests failed |
| **Root Cause** | Redis memory limit exceeded (100Mi), triggering Kubernetes OOMKill |

---

## 📊 Impact Assessment

### Baseline Metrics Comparison

| Metric | Before Incident (Normal) | During Incident (Outage) | After Incident (Recovered) |
| :--- | :--- | :--- | :--- |
| **Checkout Pod Status** | ✅ `2/2` Running | ❌ `0/2` `CrashLoopBackOff` | ✅ `2/2` Running |
| **Transaction Success Rate** | ✅ `99.9%` | ❌ `~50.0%` | ✅ `99.9%` |
| **P95 Latency** | ✅ `150ms` | ❌ `2000ms+` (Timeouts) | ✅ `150ms` |

---

## ⏱️ Incident Timeline

| Time (UTC) | Event Description | Role / Actor |
| :--- | :--- | :--- |
| **14:30:00** | Checkout pods enter `CrashLoopBackOff` following Redis dependency failure. | System |
| **14:30:30** | Prometheus alert `PodCrashLooping` triggers in channel. | Prometheus |
| **14:31:00** | On-call engineer acknowledges alert; Grafana shows `0/2` pods ready. | On-Call Engineer |
| **14:31:30** | Investigation initiated on application logs and pod statuses. | On-Call Engineer |
| **14:32:00** | `kubectl logs` reports: `connection refused to redis`. | On-Call Engineer |
| **14:32:30** | Inspection reveals Redis pod in `default` namespace is continuously restarting. | On-Call Engineer |
| **14:33:00** | `kubectl describe pod redis-xxx` confirms `OOMKilled` status (Exit Code 137). | On-Call Engineer |
| **14:33:30** | **Root Cause Identified:** Redis memory limit configured too low (`100Mi`). | On-Call Engineer |
| **14:34:00** | Redis manifest patched: memory limit raised to `256Mi` with `50Mi` request. | On-Call Engineer |
| **14:34:30** | Redis pod restarts successfully and enters `Running` status. | System |
| **14:35:00** | Checkout service reconnects and transitions to healthy `Running` state. | System |
| **14:35:30** | End-to-end checkout flow verified functional; metrics stabilizing. | On-Call Engineer |
| **14:36:00** | Incident officially declared **Resolved**. | On-Call Engineer |

---

## 🔍 Root Cause Analysis

### Technical Cause
The primary outage was caused by a **Redis Out of Memory (OOM) Termination**:
* Memory limit was capped at `100Mi`.
* During peak traffic load, cache memory usage spiked to **120Mi**.
* The Linux kernel OOM killer terminated the Redis container.
* With Redis down, the Checkout Service failed its health dependency checks and entered a `CrashLoopBackOff` loop.

### Cascading Failure Diagram

```text
┌────────────────────────┐         ┌────────────────────────┐
│    Checkout Service    │ ──────► │      Redis Cache       │
│  (ecommerce namespace) │         │  (default namespace)   │
└───────────┬────────────┘         └───────────┬────────────┘
            │                                  │
            │ Connection Refused               │ Usage: 120Mi (Limit: 100Mi)
            ▼                                  ▼
┌────────────────────────┐         ┌────────────────────────┐
│   CrashLoopBackOff     │         │   Kernel OOMKilled     │
│   (~50% Traffic Drop)  │         │  (Exit Code 137)       │
└────────────────────────┘         └────────────────────────┘
```

### Contributing Factors
1. **Missing Memory Requests**: No memory requests were defined for the Redis pod, allowing unscheduled memory allocation spikes.
2. **Alerting Blind Spot**: Absence of pre-OOM memory usage threshold alerts (`>80%`).
3. **Tight Coupling**: Checkout Service lacked resilient connection retry logic and fallback mechanisms when Redis was unreachable.

---

## 🛠️ Action Items

### Immediate (Completed)
- [x] Increased Redis memory limit from `100Mi` to `256Mi`.
- [x] Defined memory requests (`50Mi`) for Redis deployment.
- [x] Successfully restarted and verified Redis and Checkout services.

### Short-Term (Next 48 Hours)
- [ ] Implement exponential backoff connection retry logic in the Checkout Service code.
- [ ] Implement an init-container or startup probe for Checkout Service to verify Redis readiness.
- [ ] Configure Prometheus alert rules for Redis memory usage exceeding **80%**.

### Long-Term (Next Sprint)
- [ ] Implement Circuit Breaker pattern for external and in-memory cache dependencies.
- [ ] Deploy HA Redis Cluster with sentinel/replication to prevent single-point-of-failure issues.
- [ ] Implement graceful degradation pathways when Redis is temporarily unavailable.
- [ ] Conduct chaos testing simulating cache dependency termination.

---

## 📈 Monitoring & Alert Additions

The following Prometheus alert rules have been prepared to prevent similar recurrences:

```yaml
groups:
  - name: redis_alerts
    rules:
      - alert: RedisMemoryUsageHigh
        expr: (redis_memory_used_bytes / redis_memory_max_bytes) * 100 > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Redis memory usage elevated (>80%)"
          description: "Redis pod {{ $labels.pod }} memory usage is at {{ $value }}% of configured limit."

      - alert: RedisDown
        expr: redis_up == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Redis Service Unavailable"
          description: "Redis instance on pod {{ $labels.pod }} has been down for over 1 minute."
```
