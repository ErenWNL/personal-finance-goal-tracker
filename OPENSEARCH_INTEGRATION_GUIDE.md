# OpenSearch Integration Guide
**Personal Finance Goal Tracker - Full-Text Search & Analytics**

---

## Overview

OpenSearch will provide:
- Full-text search on transactions (description, category, etc.)
- Advanced filtering across millions of records
- Real-time aggregations for analytics
- Anomaly detection in spending patterns
- Complex analytics for insight generation

---

## Step 1: Add OpenSearch Dependencies

Add to each service's `pom.xml`:

```xml
<!-- OpenSearch Client -->
<dependency>
    <groupId>org.opensearch.client</groupId>
    <artifactId>opensearch-rest-high-level-client</artifactId>
    <version>2.5.0</version>
</dependency>

<!-- Spring Data Elasticsearch (works with OpenSearch) -->
<dependency>
    <groupId>org.springframework.data</groupId>
    <artifactId>spring-data-elasticsearch</artifactId>
    <version>5.1.0</version>
</dependency>
```

---

## Step 2: Create OpenSearch Configuration

Create file: `src/main/java/com/example/config/OpenSearchConfig.java`

```java
package com.example.config;

import org.opensearch.client.RestHighLevelClient;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.elasticsearch.client.ClientConfiguration;
import org.springframework.data.elasticsearch.client.RestClients;
import org.springframework.data.elasticsearch.repository.config.EnableElasticsearchRepositories;

/**
 * OpenSearch Configuration for full-text search and analytics
 */
@Configuration
@EnableElasticsearchRepositories(basePackages = "com.example.search.repository")
public class OpenSearchConfig {

    @Value("${opensearch.host:opensearch-node1}")
    private String host;

    @Value("${opensearch.port:9200}")
    private int port;

    /**
     * Create OpenSearch client
     */
    @Bean
    public RestHighLevelClient client() {
        final ClientConfiguration clientConfiguration = ClientConfiguration.builder()
                .connectedTo(host + ":" + port)
                .build();

        return RestClients.create(clientConfiguration).rest();
    }
}
```

---

## Step 3: Create Document Models

Create file: `src/main/java/com/example/search/document/TransactionDocument.java`

```java
package com.example.search.document;

import org.springframework.data.annotation.Id;
import org.springframework.data.elasticsearch.annotations.Document;
import org.springframework.data.elasticsearch.annotations.Field;
import org.springframework.data.elasticsearch.annotations.FieldType;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Transaction indexed in OpenSearch for full-text search
 */
@Document(indexName = "transactions")
public class TransactionDocument {

    @Id
    private Long id;

    @Field(type = FieldType.Long)
    private Long userId;

    @Field(type = FieldType.Text, analyzer = "standard")
    private String description;

    @Field(type = FieldType.Keyword)
    private String category;

    @Field(type = FieldType.Keyword)
    private String type; // INCOME, EXPENSE

    @Field(type = FieldType.Double)
    private BigDecimal amount;

    @Field(type = FieldType.Date)
    private LocalDateTime transactionDate;

    @Field(type = FieldType.Date)
    private LocalDateTime createdAt;

    @Field(type = FieldType.Keyword)
    private String status;

    @Field(type = FieldType.Text)
    private String notes;

    // Constructors
    public TransactionDocument() {}

    public TransactionDocument(Long id, Long userId, String description, String category,
                              String type, BigDecimal amount, LocalDateTime transactionDate,
                              LocalDateTime createdAt, String status, String notes) {
        this.id = id;
        this.userId = userId;
        this.description = description;
        this.category = category;
        this.type = type;
        this.amount = amount;
        this.transactionDate = transactionDate;
        this.createdAt = createdAt;
        this.status = status;
        this.notes = notes;
    }

    // Getters and setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }

    public LocalDateTime getTransactionDate() { return transactionDate; }
    public void setTransactionDate(LocalDateTime transactionDate) { this.transactionDate = transactionDate; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }
}
```

---

## Step 4: Create Repository

Create file: `src/main/java/com/example/search/repository/TransactionSearchRepository.java`

```java
package com.example.search.repository;

import com.example.search.document.TransactionDocument;
import org.springframework.data.elasticsearch.repository.ElasticsearchRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * OpenSearch repository for transaction search
 */
@Repository
public interface TransactionSearchRepository extends ElasticsearchRepository<TransactionDocument, Long> {

    /**
     * Find transactions by user and description (full-text search)
     */
    List<TransactionDocument> findByUserIdAndDescriptionContaining(Long userId, String description);

    /**
     * Find transactions by user and category
     */
    List<TransactionDocument> findByUserIdAndCategory(Long userId, String category);

    /**
     * Find transactions by user and type
     */
    List<TransactionDocument> findByUserIdAndType(Long userId, String type);

    /**
     * Find transactions by user and amount range
     */
    List<TransactionDocument> findByUserIdAndAmountBetween(Long userId, BigDecimal minAmount, BigDecimal maxAmount);
}
```

---

## Step 5: Create Search Service

Create file: `src/main/java/com/example/search/service/TransactionSearchService.java`

```java
package com.example.search.service;

import com.example.search.document.TransactionDocument;
import com.example.search.repository.TransactionSearchRepository;
import org.elasticsearch.index.query.BoolQueryBuilder;
import org.elasticsearch.index.query.QueryBuilders;
import org.elasticsearch.search.aggregations.AggregationBuilders;
import org.elasticsearch.search.aggregations.bucket.terms.TermsAggregation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.elasticsearch.core.ElasticsearchOperations;
import org.springframework.data.elasticsearch.core.SearchHits;
import org.springframework.data.elasticsearch.core.query.NativeSearchQuery;
import org.springframework.data.elasticsearch.core.query.NativeSearchQueryBuilder;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/**
 * Service for searching transactions in OpenSearch
 */
@Service
public class TransactionSearchService {

    @Autowired
    private TransactionSearchRepository searchRepository;

    @Autowired
    private ElasticsearchOperations elasticsearchOperations;

    /**
     * Index a transaction for search
     */
    public TransactionDocument indexTransaction(TransactionDocument document) {
        return searchRepository.save(document);
    }

    /**
     * Delete transaction from index
     */
    public void deleteTransaction(Long id) {
        searchRepository.deleteById(id);
    }

    /**
     * Full-text search on transaction description
     */
    public List<TransactionDocument> searchDescription(Long userId, String query) {
        return searchRepository.findByUserIdAndDescriptionContaining(userId, query);
    }

    /**
     * Search transactions by category
     */
    public List<TransactionDocument> searchByCategory(Long userId, String category) {
        return searchRepository.findByUserIdAndCategory(userId, category);
    }

    /**
     * Search transactions by type (INCOME/EXPENSE)
     */
    public List<TransactionDocument> searchByType(Long userId, String type) {
        return searchRepository.findByUserIdAndType(userId, type);
    }

    /**
     * Search transactions by amount range
     */
    public List<TransactionDocument> searchByAmountRange(Long userId, BigDecimal minAmount, BigDecimal maxAmount) {
        return searchRepository.findByUserIdAndAmountBetween(userId, minAmount, maxAmount);
    }

    /**
     * Advanced search with multiple filters
     */
    public SearchHits<TransactionDocument> advancedSearch(
            Long userId,
            String description,
            String category,
            String type,
            BigDecimal minAmount,
            BigDecimal maxAmount,
            LocalDateTime startDate,
            LocalDateTime endDate,
            Pageable pageable) {

        BoolQueryBuilder query = QueryBuilders.boolQuery();

        // User filter
        query.must(QueryBuilders.termQuery("userId", userId));

        // Description filter (full-text search)
        if (description != null && !description.isEmpty()) {
            query.must(QueryBuilders.matchQuery("description", description));
        }

        // Category filter
        if (category != null && !category.isEmpty()) {
            query.must(QueryBuilders.termQuery("category", category));
        }

        // Type filter
        if (type != null && !type.isEmpty()) {
            query.must(QueryBuilders.termQuery("type", type));
        }

        // Amount range filter
        if (minAmount != null || maxAmount != null) {
            query.must(QueryBuilders.rangeQuery("amount")
                    .gte(minAmount != null ? minAmount.doubleValue() : null)
                    .lte(maxAmount != null ? maxAmount.doubleValue() : null));
        }

        // Date range filter
        if (startDate != null || endDate != null) {
            query.must(QueryBuilders.rangeQuery("transactionDate")
                    .gte(startDate != null ? startDate.toString() : null)
                    .lte(endDate != null ? endDate.toString() : null));
        }

        NativeSearchQuery searchQuery = new NativeSearchQueryBuilder()
                .withQuery(query)
                .withPageable(pageable)
                .build();

        return elasticsearchOperations.search(searchQuery, TransactionDocument.class);
    }

    /**
     * Get spending by category
     */
    public Map<String, Double> getSpendingByCategory(Long userId) {
        NativeSearchQuery query = new NativeSearchQueryBuilder()
                .withQuery(QueryBuilders.boolQuery()
                        .must(QueryBuilders.termQuery("userId", userId))
                        .must(QueryBuilders.termQuery("type", "EXPENSE")))
                .withAggregations(
                        AggregationBuilders.terms("categories")
                                .field("category")
                                .size(100))
                .build();

        SearchHits<TransactionDocument> results = elasticsearchOperations
                .search(query, TransactionDocument.class);

        Map<String, Double> categoryMap = new java.util.HashMap<>();
        // Process aggregations and populate map
        return categoryMap;
    }

    /**
     * Get monthly spending trend
     */
    public Map<String, Double> getMonthlySpendin Trend(Long userId) {
        NativeSearchQuery query = new NativeSearchQueryBuilder()
                .withQuery(QueryBuilders.boolQuery()
                        .must(QueryBuilders.termQuery("userId", userId))
                        .must(QueryBuilders.termQuery("type", "EXPENSE")))
                .withAggregations(
                        AggregationBuilders.dateHistogram("monthly_spending")
                                .field("transactionDate")
                                .calendarInterval("month"))
                .build();

        SearchHits<TransactionDocument> results = elasticsearchOperations
                .search(query, TransactionDocument.class);

        Map<String, Double> monthlyMap = new java.util.HashMap<>();
        // Process aggregations and populate map
        return monthlyMap;
    }

    /**
     * Detect anomalies in spending
     */
    public List<TransactionDocument> detectAnomalies(Long userId) {
        // Get average spending
        SearchHits<TransactionDocument> allTransactions = advancedSearch(
                userId, null, null, "EXPENSE", null, null, null, null, Pageable.unpaged());

        double average = 0;
        int count = 0;

        for (var hit : allTransactions) {
            average += hit.getContent().getAmount().doubleValue();
            count++;
        }

        if (count > 0) {
            average /= count;
        }

        // Return transactions above 2x average
        double threshold = average * 2;
        BigDecimal thresholdBD = new BigDecimal(threshold);

        return searchByAmountRange(userId, thresholdBD, new BigDecimal(Double.MAX_VALUE));
    }
}
```

---

## Step 6: Create REST Endpoints

Create file: `src/main/java/com/example/finance/controller/TransactionSearchController.java`

```java
@RestController
@RequestMapping("/api/finance/search")
public class TransactionSearchController {

    @Autowired
    private TransactionSearchService searchService;

    /**
     * Search transactions by description
     */
    @GetMapping("/description")
    public ResponseEntity<?> searchByDescription(
            @RequestParam String query,
            @RequestHeader("X-User-Id") Long userId) {
        try {
            List<TransactionDocument> results = searchService.searchDescription(userId, query);
            return ResponseEntity.ok(results);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", e.getMessage()));
        }
    }

    /**
     * Advanced search with filters
     */
    @GetMapping("/advanced")
    public ResponseEntity<?> advancedSearch(
            @RequestParam(required = false) String description,
            @RequestParam(required = false) String category,
            @RequestParam(required = false) String type,
            @RequestParam(required = false) BigDecimal minAmount,
            @RequestParam(required = false) BigDecimal maxAmount,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endDate,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestHeader("X-User-Id") Long userId) {
        try {
            Pageable pageable = PageRequest.of(page, size);
            SearchHits<TransactionDocument> results = searchService.advancedSearch(
                    userId, description, category, type, minAmount, maxAmount,
                    startDate, endDate, pageable);

            return ResponseEntity.ok(results);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", e.getMessage()));
        }
    }

    /**
     * Get spending by category
     */
    @GetMapping("/analytics/category")
    public ResponseEntity<?> getSpendingByCategory(
            @RequestHeader("X-User-Id") Long userId) {
        try {
            Map<String, Double> results = searchService.getSpendingByCategory(userId);
            return ResponseEntity.ok(results);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", e.getMessage()));
        }
    }

    /**
     * Detect spending anomalies
     */
    @GetMapping("/anomalies")
    public ResponseEntity<?> detectAnomalies(
            @RequestHeader("X-User-Id") Long userId) {
        try {
            List<TransactionDocument> results = searchService.detectAnomalies(userId);
            return ResponseEntity.ok(results);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", e.getMessage()));
        }
    }
}
```

---

## Step 7: Update application.properties

```properties
# OpenSearch Configuration
spring.elasticsearch.uris=http://opensearch-node1:9200
spring.elasticsearch.rest.username=
spring.elasticsearch.rest.password=
spring.data.elasticsearch.client.reactive.endpoints=opensearch-node1:9200
```

---

## Step 8: Index Existing Transactions

Create file: `src/main/java/com/example/config/OpenSearchInitializer.java`

```java
package com.example.config;

import com.example.finance.entity.Transaction;
import com.example.finance.repository.TransactionRepository;
import com.example.search.document.TransactionDocument;
import com.example.search.service.TransactionSearchService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.ApplicationRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Initialize OpenSearch with existing transactions
 */
@Configuration
public class OpenSearchInitializer {

    @Autowired
    private TransactionRepository transactionRepository;

    @Autowired
    private TransactionSearchService searchService;

    @Bean
    public ApplicationRunner initializeOpenSearch() {
        return args -> {
            // Get all transactions and index them
            transactionRepository.findAll().forEach(transaction -> {
                TransactionDocument document = new TransactionDocument(
                        transaction.getId(),
                        transaction.getUser().getId(),
                        transaction.getDescription(),
                        transaction.getCategory(),
                        transaction.getType(),
                        transaction.getAmount(),
                        transaction.getTransactionDate(),
                        transaction.getCreatedAt(),
                        transaction.getStatus(),
                        transaction.getNotes()
                );
                searchService.indexTransaction(document);
            });
        };
    }
}
```

---

## Step 9: OpenSearch Dashboards Access

**URL**: http://localhost:5601

- Create indexes
- Run aggregations
- Monitor cluster health
- View index statistics

---

## Example Queries

### Search all transactions
```bash
curl -X GET "http://localhost:9200/transactions/_search" -H "Content-Type: application/json" -d'
{
  "query": {
    "match_all": {}
  }
}'
```

### Search by description
```bash
curl -X GET "http://localhost:9200/transactions/_search" -H "Content-Type: application/json" -d'
{
  "query": {
    "bool": {
      "must": [
        {"term": {"userId": 1}},
        {"match": {"description": "grocery"}}
      ]
    }
  }
}'
```

### Aggregate by category
```bash
curl -X GET "http://localhost:9200/transactions/_search" -H "Content-Type: application/json" -d'
{
  "size": 0,
  "query": {"term": {"type": "EXPENSE"}},
  "aggs": {
    "categories": {
      "terms": {"field": "category", "size": 100}
    }
  }
}'
```

---

## Best Practices

1. **Mapping**: Define index mappings carefully (text vs keyword)
2. **Analyzer**: Use appropriate analyzers for full-text search
3. **Sharding**: For large datasets, use multiple shards
4. **Refresh Interval**: Balance between freshness and performance
5. **Index Lifecycle**: Use ILM policies for automatic index rotation
6. **Backup**: Regular backups of OpenSearch indexes

---

## Performance Tips

1. Use keyword fields for exact matching
2. Use text fields for full-text search
3. Implement proper pagination for large result sets
4. Use aggregations instead of retrieving all documents
5. Monitor index size and query performance
6. Implement caching for frequently queried data

---

## Next Steps

1. Deploy OpenSearch with Docker Compose
2. Add Spring Data Elasticsearch dependency
3. Create document models and repositories
4. Implement search service and endpoints
5. Index existing transactions
6. Monitor search performance
7. Create OpenSearch dashboards

