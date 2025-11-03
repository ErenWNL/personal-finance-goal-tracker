# MinIO Integration Guide
**Personal Finance Goal Tracker - Self-Hosted Object Storage**

---

## Overview

MinIO is an S3-compatible object storage service that will be used to store:
- Transaction receipts and invoices
- Goal images and motivation photos
- User profile pictures
- CSV exports and financial reports
- Database backups

---

## Step 1: Add MinIO Dependencies

Add to each service's `pom.xml`:

```xml
<!-- MinIO SDK -->
<dependency>
    <groupId>io.minio</groupId>
    <artifactId>minio</artifactId>
    <version>8.5.3</version>
</dependency>

<!-- AWS SDK (for compatibility) -->
<dependency>
    <groupId>software.amazon.awssdk</groupId>
    <artifactId>s3</artifactId>
    <version>2.20.0</version>
</dependency>
```

---

## Step 2: Create MinIO Configuration

Create file: `src/main/java/com/example/config/MinIOConfig.java`

```java
package com.example.config;

import io.minio.MinioClient;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * MinIO Configuration for S3-compatible object storage
 */
@Configuration
public class MinIOConfig {

    @Value("${minio.url:http://minio:9000}")
    private String minioUrl;

    @Value("${minio.access-key:minioadmin}")
    private String accessKey;

    @Value("${minio.secret-key:minioadmin123}")
    private String secretKey;

    /**
     * Creates MinIO client bean
     */
    @Bean
    public MinioClient minioClient() {
        return MinioClient.builder()
                .endpoint(minioUrl)
                .credentials(accessKey, secretKey)
                .build();
    }
}
```

---

## Step 3: Create File Storage Service

Create file: `src/main/java/com/example/service/FileStorageService.java`

```java
package com.example.service;

import io.minio.*;
import io.minio.errors.MinioException;
import io.minio.http.Method;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.concurrent.TimeUnit;

/**
 * Service for managing files in MinIO
 */
@Service
public class FileStorageService {

    private static final Logger logger = LoggerFactory.getLogger(FileStorageService.class);

    @Autowired
    private MinioClient minioClient;

    @Value("${minio.bucket.receipts:receipts}")
    private String receiptsBucket;

    @Value("${minio.bucket.images:goal-images}")
    private String imagesBucket;

    @Value("${minio.bucket.profiles:user-profiles}")
    private String profilesBucket;

    @Value("${minio.bucket.exports:exports}")
    private String exportsBucket;

    @Value("${minio.bucket.backups:backups}")
    private String backupsBucket;

    /**
     * Initialize MinIO buckets (call on startup)
     */
    public void initializeBuckets() {
        try {
            createBucketIfNotExists(receiptsBucket);
            createBucketIfNotExists(imagesBucket);
            createBucketIfNotExists(profilesBucket);
            createBucketIfNotExists(exportsBucket);
            createBucketIfNotExists(backupsBucket);
            logger.info("All MinIO buckets initialized successfully");
        } catch (Exception e) {
            logger.error("Error initializing MinIO buckets", e);
        }
    }

    /**
     * Create bucket if it doesn't exist
     */
    private void createBucketIfNotExists(String bucketName) throws Exception {
        boolean exists = minioClient.bucketExists(BucketExistsArgs.builder()
                .bucket(bucketName)
                .build());

        if (!exists) {
            minioClient.makeBucket(MakeBucketArgs.builder()
                    .bucket(bucketName)
                    .build());
            logger.info("Created bucket: {}", bucketName);
        }
    }

    /**
     * Upload transaction receipt
     */
    public String uploadReceipt(Long transactionId, MultipartFile file) throws Exception {
        String fileName = "transaction-" + transactionId + "-" + System.currentTimeMillis()
            + "-" + file.getOriginalFilename();
        return uploadFile(receiptsBucket, "receipts/" + transactionId + "/" + fileName, file);
    }

    /**
     * Upload goal image
     */
    public String uploadGoalImage(Long goalId, MultipartFile file) throws Exception {
        String fileName = "goal-" + goalId + "-" + System.currentTimeMillis()
            + "-" + file.getOriginalFilename();
        return uploadFile(imagesBucket, "goals/" + goalId + "/" + fileName, file);
    }

    /**
     * Upload user profile picture
     */
    public String uploadProfilePicture(Long userId, MultipartFile file) throws Exception {
        String fileName = "profile-" + userId + "-" + System.currentTimeMillis()
            + "-" + file.getOriginalFilename();
        return uploadFile(profilesBucket, "users/" + userId + "/" + fileName, file);
    }

    /**
     * Upload CSV export
     */
    public String uploadExport(Long userId, String fileName, MultipartFile file) throws Exception {
        String key = "exports/" + userId + "/" + System.currentTimeMillis() + "-" + fileName;
        return uploadFile(exportsBucket, key, file);
    }

    /**
     * Upload backup file
     */
    public String uploadBackup(String backupName, InputStream inputStream, long size) throws Exception {
        String key = "backups/" + System.currentTimeMillis() + "-" + backupName;

        try {
            minioClient.putObject(PutObjectArgs.builder()
                    .bucket(backupsBucket)
                    .object(key)
                    .stream(inputStream, size, -1)
                    .contentType("application/octet-stream")
                    .build());

            String url = getPresignedUrl(backupsBucket, key, 24 * 60 * 60); // 24 hours
            logger.info("Backup uploaded: {}", key);
            return url;
        } catch (MinioException e) {
            logger.error("Error uploading backup: {}", e.getMessage());
            throw new Exception("Error uploading backup", e);
        }
    }

    /**
     * Generic file upload method
     */
    private String uploadFile(String bucket, String key, MultipartFile file) throws Exception {
        try {
            minioClient.putObject(PutObjectArgs.builder()
                    .bucket(bucket)
                    .object(key)
                    .stream(file.getInputStream(), file.getSize(), -1)
                    .contentType(file.getContentType())
                    .build());

            String url = getPresignedUrl(bucket, key, 24 * 60 * 60); // 24 hours
            logger.info("File uploaded: {} to {}", key, bucket);
            return url;
        } catch (MinioException e) {
            logger.error("Error uploading file: {}", e.getMessage());
            throw new Exception("Error uploading file to MinIO", e);
        }
    }

    /**
     * Download file
     */
    public byte[] downloadFile(String bucket, String key) throws Exception {
        try {
            InputStream stream = minioClient.getObject(GetObjectArgs.builder()
                    .bucket(bucket)
                    .object(key)
                    .build());
            return stream.readAllBytes();
        } catch (MinioException e) {
            logger.error("Error downloading file: {}", e.getMessage());
            throw new Exception("Error downloading file from MinIO", e);
        }
    }

    /**
     * Delete file
     */
    public void deleteFile(String bucket, String key) throws Exception {
        try {
            minioClient.removeObject(RemoveObjectArgs.builder()
                    .bucket(bucket)
                    .object(key)
                    .build());
            logger.info("File deleted: {} from {}", key, bucket);
        } catch (MinioException e) {
            logger.error("Error deleting file: {}", e.getMessage());
            throw new Exception("Error deleting file from MinIO", e);
        }
    }

    /**
     * Generate presigned URL (temporary access)
     */
    public String getPresignedUrl(String bucket, String key, int expirationSeconds) throws Exception {
        try {
            String url = minioClient.getPresignedObjectUrl(GetPresignedObjectUrlArgs.builder()
                    .method(Method.GET)
                    .bucket(bucket)
                    .object(key)
                    .expiration(expirationSeconds, TimeUnit.SECONDS)
                    .build());
            return url;
        } catch (MinioException e) {
            logger.error("Error generating presigned URL: {}", e.getMessage());
            throw new Exception("Error generating presigned URL", e);
        }
    }

    /**
     * List files in bucket
     */
    public java.util.List<String> listFiles(String bucket, String prefix) throws Exception {
        java.util.List<String> files = new java.util.ArrayList<>();
        try {
            Iterable<Result<Item>> results = minioClient.listObjects(ListObjectsArgs.builder()
                    .bucket(bucket)
                    .prefix(prefix)
                    .recursive(true)
                    .build());

            for (Result<Item> result : results) {
                Item item = result.get();
                if (!item.isDir()) {
                    files.add(item.objectName());
                }
            }
        } catch (MinioException e) {
            logger.error("Error listing files: {}", e.getMessage());
            throw new Exception("Error listing files from MinIO", e);
        }
        return files;
    }
}
```

---

## Step 4: Update application.properties

Add to `application.properties` or `application.yml`:

```properties
# MinIO Configuration
minio.url=http://minio:9000
minio.access-key=minioadmin
minio.secret-key=minioadmin123
minio.bucket.receipts=receipts
minio.bucket.images=goal-images
minio.bucket.profiles=user-profiles
minio.bucket.exports=exports
minio.bucket.backups=backups
```

Or in `application.yml`:

```yaml
minio:
  url: http://minio:9000
  access-key: minioadmin
  secret-key: minioadmin123
  bucket:
    receipts: receipts
    images: goal-images
    profiles: user-profiles
    exports: exports
    backups: backups
```

---

## Step 5: Create REST Endpoints

### Finance Service - Transaction Receipt Upload

Create file: `src/main/java/com/example/finance/controller/TransactionFileController.java`

```java
@RestController
@RequestMapping("/api/finance/transactions/{id}/files")
public class TransactionFileController {

    @Autowired
    private FileStorageService fileStorageService;

    @Autowired
    private TransactionRepository transactionRepository;

    /**
     * Upload receipt for transaction
     */
    @PostMapping("/receipt")
    public ResponseEntity<?> uploadReceipt(
            @PathVariable Long id,
            @RequestParam("file") MultipartFile file) {
        try {
            Transaction transaction = transactionRepository.findById(id)
                    .orElseThrow(() -> new NotFoundException("Transaction not found"));

            String fileUrl = fileStorageService.uploadReceipt(id, file);

            transaction.setReceiptUrl(fileUrl);
            transactionRepository.save(transaction);

            return ResponseEntity.ok(Map.of(
                    "message", "Receipt uploaded successfully",
                    "url", fileUrl,
                    "transactionId", id
            ));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", e.getMessage()));
        }
    }

    /**
     * Download receipt
     */
    @GetMapping("/receipt/download")
    public ResponseEntity<byte[]> downloadReceipt(@PathVariable Long id) {
        try {
            Transaction transaction = transactionRepository.findById(id)
                    .orElseThrow(() -> new NotFoundException("Transaction not found"));

            if (transaction.getReceiptUrl() == null) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
            }

            String key = transaction.getReceiptUrl();
            byte[] fileContent = fileStorageService.downloadFile("receipts", key);

            return ResponseEntity.ok()
                    .contentType(MediaType.APPLICATION_OCTET_STREAM)
                    .header("Content-Disposition", "attachment; filename=receipt.pdf")
                    .body(fileContent);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
}
```

### Goal Service - Goal Image Upload

Create file: `src/main/java/com/example/goal/controller/GoalFileController.java`

```java
@RestController
@RequestMapping("/api/goals/{id}/files")
public class GoalFileController {

    @Autowired
    private FileStorageService fileStorageService;

    @Autowired
    private GoalRepository goalRepository;

    /**
     * Upload goal image
     */
    @PostMapping("/image")
    public ResponseEntity<?> uploadGoalImage(
            @PathVariable Long id,
            @RequestParam("file") MultipartFile file) {
        try {
            Goal goal = goalRepository.findById(id)
                    .orElseThrow(() -> new NotFoundException("Goal not found"));

            String imageUrl = fileStorageService.uploadGoalImage(id, file);

            goal.setImageUrl(imageUrl);
            goalRepository.save(goal);

            return ResponseEntity.ok(Map.of(
                    "message", "Image uploaded successfully",
                    "url", imageUrl,
                    "goalId", id
            ));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", e.getMessage()));
        }
    }
}
```

---

## Step 6: Initialize MinIO Buckets on Startup

Create file: `src/main/java/com/example/config/StartupConfiguration.java`

```java
package com.example.config;

import com.example.service.FileStorageService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.ApplicationRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Startup configuration to initialize MinIO buckets
 */
@Configuration
public class StartupConfiguration {

    @Autowired
    private FileStorageService fileStorageService;

    @Bean
    public ApplicationRunner initializeMinIO() {
        return args -> {
            fileStorageService.initializeBuckets();
        };
    }
}
```

---

## Step 7: Usage Examples

### Upload Receipt

```bash
curl -X POST \
  -F "file=@receipt.pdf" \
  http://localhost:8083/api/finance/transactions/1/files/receipt
```

### Upload Goal Image

```bash
curl -X POST \
  -F "file=@goal.jpg" \
  http://localhost:8084/api/goals/1/files/image
```

### Download Receipt

```bash
curl -X GET \
  http://localhost:8083/api/finance/transactions/1/files/receipt/download \
  -o receipt.pdf
```

---

## MinIO Console Access

**URL**: http://localhost:9001
**Username**: minioadmin
**Password**: minioadmin123

From the console, you can:
- View all buckets
- Manage files
- Set bucket policies
- Monitor usage

---

## S3 SDK Compatibility

MinIO is fully S3-compatible, so you can also use AWS SDK if needed:

```java
// Using AWS SDK instead of MinIO SDK
S3Client s3Client = S3Client.builder()
    .endpointOverride(URI.create("http://minio:9000"))
    .region(Region.US_EAST_1)
    .credentialsProvider(StaticCredentialsProvider.create(
        AwsBasicCredentials.create("minioadmin", "minioadmin123")
    ))
    .build();
```

---

## Bucket Lifecycle Policies

Example lifecycle policy for automatic cleanup:

```json
{
  "Rules": [
    {
      "ID": "DeleteOldExports",
      "Status": "Enabled",
      "Filter": {
        "Prefix": "exports/"
      },
      "Expiration": {
        "Days": 30
      }
    },
    {
      "ID": "ArchiveOldBackups",
      "Status": "Enabled",
      "Filter": {
        "Prefix": "backups/"
      },
      "Transitions": [
        {
          "Days": 90,
          "StorageClass": "GLACIER"
        }
      ]
    }
  ]
}
```

---

## Security Best Practices

1. **Change Default Credentials**: Always change `minioadmin` and `minioadmin123`
2. **Enable TLS**: Use HTTPS in production
3. **Bucket Policies**: Restrict access to specific users/roles
4. **Versioning**: Enable versioning for important buckets
5. **Encryption**: Enable server-side encryption
6. **Access Logs**: Enable access logging for audit trails

---

## Troubleshooting

### Connection Issues
```bash
# Test MinIO connectivity
curl -v http://localhost:9000/minio/health/live
```

### Bucket Access Issues
- Check credentials in application.properties
- Verify bucket exists and policies are correct
- Check user permissions in MinIO console

### Performance Issues
- Monitor MinIO metrics in Prometheus
- Check disk space availability
- Consider adding more MinIO instances for high availability

---

## Next Steps

1. Deploy MinIO with Docker Compose
2. Add MinIO configuration to each microservice
3. Implement file upload endpoints
4. Set up backup policies
5. Monitor MinIO health via Prometheus

