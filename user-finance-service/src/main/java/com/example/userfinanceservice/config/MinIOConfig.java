package com.example.userfinanceservice.config;

import io.minio.BucketExistsArgs;
import io.minio.MakeBucketArgs;
import io.minio.MinioClient;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * MinIO Configuration for S3-compatible object storage
 */
@Configuration
public class MinIOConfig {

    private static final Logger logger = LoggerFactory.getLogger(MinIOConfig.class);

    @Value("${minio.url:http://minio:9000}")
    private String minioUrl;

    @Value("${minio.access-key:minioadmin}")
    private String minioAccessKey;

    @Value("${minio.secret-key:minioadmin123}")
    private String minioSecretKey;

    private static final String[] BUCKET_NAMES = {
            "receipts", "goal-images", "user-profiles", "exports", "backups"
    };

    @Bean
    public MinioClient minioClient() {
        return MinioClient.builder()
                .endpoint(minioUrl)
                .credentials(minioAccessKey, minioSecretKey)
                .build();
    }

    /**
     * Initialize MinIO buckets on application startup
     */
    @Bean
    public CommandLineRunner initMinIOBuckets(MinioClient minioClient) {
        return args -> {
            try {
                for (String bucketName : BUCKET_NAMES) {
                    boolean exists = minioClient.bucketExists(
                            BucketExistsArgs.builder()
                                    .bucket(bucketName)
                                    .build()
                    );

                    if (!exists) {
                        minioClient.makeBucket(
                                MakeBucketArgs.builder()
                                        .bucket(bucketName)
                                        .build()
                        );
                        logger.info("Created MinIO bucket: {}", bucketName);
                    } else {
                        logger.info("MinIO bucket already exists: {}", bucketName);
                    }
                }
                logger.info("MinIO bucket initialization completed successfully");
            } catch (Exception e) {
                logger.warn("Error initializing MinIO buckets: {}. This may be normal if MinIO is not available yet.", e.getMessage());
            }
        };
    }
}
