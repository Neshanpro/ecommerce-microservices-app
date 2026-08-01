# Incident Report: Checkout Service Outage

**Date:** 2026-08-01  
**Duration:** 5 minutes  
**Impact:** 50% of checkout requests failed  
**Root Cause:** Redis OOM kill due to memory limit misconfiguration  

## Timeline
- 14:30 – Checkout pods enter CrashLoopBackOff
- 14:31 – Prometheus alert triggers
- 14:33 – Investigation reveals Redis pod OOM-killed
- 14:35 – Redis memory limit increased to 256Mi
- 14:36 – Checkout pods restart and become healthy

## Action Items
- Increase Redis memory limit
- Add memory requests for Redis
- Implement retry logic in checkout service
