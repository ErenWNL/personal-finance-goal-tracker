package com.example.userfinanceservice.service;

import io.minio.GetObjectArgs;
import io.minio.MinioClient;
import io.minio.PutObjectArgs;
import io.minio.RemoveObjectArgs;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.InputStream;
import java.util.UUID;

/**
 * Service for managing files in MinIO S3-compatible storage
 */
@Service
public class FileStorageService {

    private static final Logger logger = LoggerFactory.getLogger(FileStorageService.class);

    @Autowired
    private MinioClient minioClient;

    private static final String[] ALLOWED_BUCKETS = {
            "receipts", "goal-images", "user-profiles", "exports", "backups"
    };

    /**
     * Upload a file to MinIO
     * @param bucketName The bucket to upload to
     * @param file The file to upload
     * @return The file name/key in MinIO
     */
    public String uploadFile(String bucketName, MultipartFile file) {
        try {
            validateBucket(bucketName);

            String fileName = generateFileName(file.getOriginalFilename());

            minioClient.putObject(
                    PutObjectArgs.builder()
                            .bucket(bucketName)
                            .object(fileName)
                            .stream(file.getInputStream(), file.getSize(), -1)
                            .contentType(file.getContentType())
                            .build()
            );

            logger.info("File uploaded successfully: {} to bucket: {}", fileName, bucketName);
            return fileName;

        } catch (Exception e) {
            logger.error("Error uploading file to MinIO: {}", e.getMessage());
            throw new RuntimeException("Failed to upload file: " + e.getMessage());
        }
    }

    /**
     * Download a file from MinIO
     * @param bucketName The bucket name
     * @param fileName The file name/key
     * @return InputStream of the file
     */
    public InputStream downloadFile(String bucketName, String fileName) {
        try {
            validateBucket(bucketName);

            return minioClient.getObject(
                    GetObjectArgs.builder()
                            .bucket(bucketName)
                            .object(fileName)
                            .build()
            );

        } catch (Exception e) {
            logger.error("Error downloading file from MinIO: {}", e.getMessage());
            throw new RuntimeException("Failed to download file: " + e.getMessage());
        }
    }

    /**
     * Delete a file from MinIO
     * @param bucketName The bucket name
     * @param fileName The file name/key
     */
    public void deleteFile(String bucketName, String fileName) {
        try {
            validateBucket(bucketName);

            minioClient.removeObject(
                    RemoveObjectArgs.builder()
                            .bucket(bucketName)
                            .object(fileName)
                            .build()
            );

            logger.info("File deleted successfully: {} from bucket: {}", fileName, bucketName);

        } catch (Exception e) {
            logger.error("Error deleting file from MinIO: {}", e.getMessage());
            throw new RuntimeException("Failed to delete file: " + e.getMessage());
        }
    }

    /**
     * Validate bucket name
     */
    private void validateBucket(String bucketName) {
        boolean isValid = false;
        for (String allowedBucket : ALLOWED_BUCKETS) {
            if (allowedBucket.equals(bucketName)) {
                isValid = true;
                break;
            }
        }
        if (!isValid) {
            throw new IllegalArgumentException("Invalid bucket name: " + bucketName);
        }
    }

    /**
     * Generate a unique file name
     */
    private String generateFileName(String originalFileName) {
        String extension = "";
        if (originalFileName != null && originalFileName.contains(".")) {
            extension = originalFileName.substring(originalFileName.lastIndexOf("."));
        }
        return UUID.randomUUID() + extension;
    }
}
