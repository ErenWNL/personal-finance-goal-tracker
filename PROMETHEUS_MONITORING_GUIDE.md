# Prometheus Monitoring Guide
**Personal Finance Goal Tracker - Metrics Collection & Alerts**

---

## Overview

Prometheus will collect metrics from all microservices including:
- Service health and uptime
- API response times and latency
- Request rates and error rates
- JVM memory and CPU usage
- Database connection pools
- Business metrics (transactions created, goals completed, etc.)

---

## Step 1: Add Micrometer Dependencies

Add to each service's `pom.xml`:

```xml
<!-- Micrometer (metrics collection) -->
<dependency>
    <groupId>io.micrometer</groupId>
    <artifactId>micrometer-registry-prometheus</artifactId>
    <version>1.11.0</version>
</dependency>

<!-- Spring Boot Actuator -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
```

---

## Step 2: Configure Actuator Endpoints

Add to `application.properties` or `application.yml`:

```properties
# Actuator Configuration
management.endpoints.web.exposure.include=health,prometheus,metrics,info
management.endpoint.health.show-details=always
management.endpoint.prometheus.enabled=true
management.metrics.export.prometheus.enabled=true
management.metrics.tags.application=${spring.application.name}
management.metrics.tags.environment=${spring.profiles.active}

# Additional metric settings
management.metrics.enable.jvm=true
management.metrics.enable.process=true
management.metrics.enable.system=true
management.metrics.enable.logback=true
management.metrics.enable.tomcat=true
```

Or in `application.yml`:

```yaml
management:
  endpoints:
    web:
      exposure:
        include: health,prometheus,metrics,info
  endpoint:
    health:
      show-details: always
    prometheus:
      enabled: true
  metrics:
    export:
      prometheus:
        enabled: true
    tags:
      application: ${spring.application.name}
      environment: ${spring.profiles.active}
    enable:
      jvm: true
      process: true
      system: true
      logback: true
      tomcat: true
```

---

## Step 3: Custom Metrics

Create file: `src/main/java/com/example/metrics/FinanceMetrics.java`

```java
package com.example.metrics;

import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.MeterRegistry;
import io.micrometer.core.instrument.Timer;
import io.micrometer.core.instrument.Tags;
import org.springframework.stereotype.Component;

import java.util.concurrent.atomic.AtomicInteger;

/**
 * Custom business metrics for Finance Service
 */
@Component
public class FinanceMetrics {

    private final Counter transactionsCreated;
    private final Counter transactionsDeleted;
    private final Counter spendingAlerts;
    private final AtomicInteger activeTransactions;
    private final Timer transactionProcessingTime;

    public FinanceMetrics(MeterRegistry meterRegistry) {
        // Counter for transactions created
        this.transactionsCreated = Counter.builder("finance.transactions.created")
                .description("Total transactions created")
                .tag("service", "finance")
                .register(meterRegistry);

        // Counter for transactions deleted
        this.transactionsDeleted = Counter.builder("finance.transactions.deleted")
                .description("Total transactions deleted")
                .tag("service", "finance")
                .register(meterRegistry);

        // Counter for spending alerts
        this.spendingAlerts = Counter.builder("finance.spending.alerts")
                .description("Total spending alerts triggered")
                .tag("service", "finance")
                .register(meterRegistry);

        // Gauge for active transactions
        this.activeTransactions = meterRegistry.gauge(
                "finance.transactions.active",
                Tags.of("service", "finance"),
                new AtomicInteger(0)
        );

        // Timer for transaction processing
        this.transactionProcessingTime = Timer.builder("finance.transaction.processing.time")
                .description("Time taken to process a transaction")
                .publishPercentiles(0.5, 0.95, 0.99)
                .tag("service", "finance")
                .register(meterRegistry);
    }

    public void incrementTransactionsCreated() {
        transactionsCreated.increment();
    }

    public void incrementTransactionsDeleted() {
        transactionsDeleted.increment();
    }

    public void incrementSpendingAlerts() {
        spendingAlerts.increment();
    }

    public void recordTransactionProcessingTime(long durationMillis) {
        transactionProcessingTime.record(java.time.Duration.ofMillis(durationMillis));
    }

    public void setActiveTransactions(int count) {
        activeTransactions.set(count);
    }

    public void incrementActiveTransactions() {
        activeTransactions.incrementAndGet();
    }

    public void decrementActiveTransactions() {
        activeTransactions.decrementAndGet();
    }
}
```

Create file: `src/main/java/com/example/metrics/GoalMetrics.java`

```java
package com.example.metrics;

import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.MeterRegistry;
import io.micrometer.core.instrument.Tags;
import org.springframework.stereotype.Component;

import java.util.concurrent.atomic.AtomicInteger;

/**
 * Custom business metrics for Goal Service
 */
@Component
public class GoalMetrics {

    private final Counter goalsCreated;
    private final Counter goalsCompleted;
    private final Counter goalsFailed;
    private final AtomicInteger activeGoals;

    public GoalMetrics(MeterRegistry meterRegistry) {
        this.goalsCreated = Counter.builder("goals.created")
                .description("Total goals created")
                .tag("service", "goal")
                .register(meterRegistry);

        this.goalsCompleted = Counter.builder("goals.completed")
                .description("Total goals completed")
                .tag("service", "goal")
                .register(meterRegistry);

        this.goalsFailed = Counter.builder("goals.failed")
                .description("Total goals failed")
                .tag("service", "goal")
                .register(meterRegistry);

        this.activeGoals = meterRegistry.gauge(
                "goals.active",
                Tags.of("service", "goal"),
                new AtomicInteger(0)
        );
    }

    public void incrementGoalsCreated() {
        goalsCreated.increment();
    }

    public void incrementGoalsCompleted() {
        goalsCompleted.increment();
    }

    public void incrementGoalsFailed() {
        goalsFailed.increment();
    }

    public void setActiveGoals(int count) {
        activeGoals.set(count);
    }
}
```

---

## Step 4: Use Metrics in Services

### Finance Service Example

```java
@Service
public class TransactionService {

    @Autowired
    private FinanceMetrics financeMetrics;

    public Transaction createTransaction(Transaction transaction) {
        long startTime = System.currentTimeMillis();

        try {
            Transaction saved = transactionRepository.save(transaction);
            financeMetrics.incrementTransactionsCreated();
            financeMetrics.incrementActiveTransactions();

            long duration = System.currentTimeMillis() - startTime;
            financeMetrics.recordTransactionProcessingTime(duration);

            return saved;
        } catch (Exception e) {
            financeMetrics.decrementActiveTransactions();
            throw e;
        }
    }

    public void deleteTransaction(Long id) {
        transactionRepository.deleteById(id);
        financeMetrics.incrementTransactionsDeleted();
        financeMetrics.decrementActiveTransactions();
    }
}
```

### Goal Service Example

```java
@Service
public class GoalService {

    @Autowired
    private GoalMetrics goalMetrics;

    public Goal createGoal(Goal goal) {
        Goal saved = goalRepository.save(goal);
        goalMetrics.incrementGoalsCreated();
        return saved;
    }

    public Goal completeGoal(Long goalId) {
        Goal goal = goalRepository.findById(goalId).orElseThrow();
        goal.setStatus("COMPLETED");
        Goal saved = goalRepository.save(goal);
        goalMetrics.incrementGoalsCompleted();
        return saved;
    }
}
```

---

## Step 5: Verify Metrics Endpoint

Access metrics from each service:

```bash
# Get all available metrics
curl http://localhost:8083/actuator/metrics

# Get Prometheus format metrics
curl http://localhost:8083/actuator/prometheus

# Get specific metric
curl http://localhost:8083/actuator/metrics/jvm.memory.used
```

---

## Step 6: Prometheus Scrape Configuration

The `prometheus.yml` file (already created) includes scrape configs for:
- api-gateway:8081
- auth-service:8082
- finance-service:8083
- goal-service:8084
- insight-service:8085
- config-server:8888
- eureka-server:8761

All services will be scraped every 15 seconds.

---

## Step 7: Common Metrics to Monitor

### JVM Metrics
```
jvm.memory.used          # Memory currently used (bytes)
jvm.memory.max           # Maximum memory available (bytes)
jvm.memory.committed     # Memory committed (bytes)
jvm.threads.live         # Active thread count
jvm.threads.peak         # Peak thread count
jvm.gc.memory.allocated  # Memory allocated per GC
jvm.gc.max.data.size     # Max memory used by GC
```

### HTTP Metrics
```
http.server.requests                    # HTTP request metrics
http_server_requests_seconds_bucket     # Request latency (Prometheus)
http_server_requests_seconds_count      # Total requests
http_server_requests_seconds_sum        # Total request time
```

### Custom Metrics
```
finance.transactions.created            # Total transactions created
finance.transactions.deleted            # Total transactions deleted
finance.spending.alerts                 # Total spending alerts
finance.transactions.active             # Currently active transactions
goals.created                           # Total goals created
goals.completed                         # Total goals completed
goals.active                            # Currently active goals
```

### Database Metrics
```
jdbc.connections.active                 # Active database connections
jdbc.connections.idle                   # Idle database connections
jdbc.connections.pending                # Pending database connections
```

---

## Step 8: Prometheus Queries

Access Prometheus UI at: http://localhost:9090

### Example Queries

```promql
# Service uptime
up{job="finance-service"}

# Request rate
rate(http_server_requests_seconds_count[5m])

# Request latency (p95)
histogram_quantile(0.95, rate(http_server_requests_seconds_bucket[5m]))

# Error rate
rate(http_server_requests_seconds_count{status=~"5.."}[5m])

# Memory usage
jvm.memory.used{job="finance-service"}

# Transactions created per minute
rate(finance_transactions_created_total[1m])

# Active transactions
finance_transactions_active

# JVM CPU usage
process_cpu_usage{job="finance-service"}
```

---

## Step 9: Create Alert Rules

Create file: `alert_rules.yml`

```yaml
groups:
  - name: personal-finance-alerts
    interval: 30s
    rules:
      # Service Down Alert
      - alert: ServiceDown
        expr: up == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Service {{ $labels.job }} is down"
          description: "Service {{ $labels.job }} has been unavailable for more than 1 minute"

      # High CPU Usage
      - alert: HighCPUUsage
        expr: process_cpu_usage > 0.8
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High CPU usage on {{ $labels.job }}"
          description: "Service {{ $labels.job }} is using {{ $value | humanizePercentage }} CPU"

      # High Memory Usage
      - alert: HighMemoryUsage
        expr: (jvm_memory_used_bytes / jvm_memory_max_bytes) > 0.85
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High memory usage on {{ $labels.job }}"
          description: "Service {{ $labels.job }} is using {{ $value | humanizePercentage }} memory"

      # High Error Rate
      - alert: HighErrorRate
        expr: rate(http_server_requests_seconds_count{status=~"5.."}[5m]) > 0.05
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "High error rate on {{ $labels.job }}"
          description: "Service {{ $labels.job }} has error rate above 5%"

      # High Latency
      - alert: HighLatency
        expr: histogram_quantile(0.95, rate(http_server_requests_seconds_bucket[5m])) > 2
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High latency on {{ $labels.job }}"
          description: "p95 latency is {{ $value | humanizeDuration }}"
```

---

## Step 10: Enable Alerts in Prometheus Config

Update `prometheus.yml`:

```yaml
alerting:
  alertmanagers:
    - static_configs:
        - targets:
            - localhost:9093  # AlertManager address

rule_files:
  - "alert_rules.yml"
```

---

## Dashboard Metrics

The Grafana dashboard includes:

1. **Service Health Status** - Shows which services are up/down
2. **CPU Usage** - Per-service CPU percentage
3. **Memory Usage** - Memory consumption over time
4. **Request Rate** - Requests per second
5. **API Latency** - Response time percentiles

---

## Best Practices

1. **Cardinality**: Avoid high cardinality labels (e.g., user IDs)
2. **Retention**: Keep 15 days of data locally
3. **Scrape Interval**: 15 seconds is good for most cases
4. **Alert Thresholds**: Set conservative thresholds initially
5. **Recording Rules**: Create recording rules for frequently queried metrics
6. **Dashboards**: Create role-specific dashboards for different teams

---

## Troubleshooting

### Metrics not appearing
```bash
# Check if actuator endpoint is accessible
curl http://service:8080/actuator/prometheus

# Check if Prometheus is scraping
curl http://localhost:9090/api/v1/targets
```

### High cardinality issues
- Don't include user IDs or request IDs as labels
- Use recording rules to aggregate high cardinality metrics
- Drop unnecessary metrics

### Performance issues
- Reduce scrape interval if acceptable
- Reduce retention period if storage is constrained
- Filter metrics in prometheus.yml

---

## Next Steps

1. Deploy Prometheus with Docker Compose
2. Add Micrometer dependency to microservices
3. Configure actuator endpoints
4. Create custom metrics
5. Set up Grafana dashboards
6. Create alert rules
7. Monitor and optimize

