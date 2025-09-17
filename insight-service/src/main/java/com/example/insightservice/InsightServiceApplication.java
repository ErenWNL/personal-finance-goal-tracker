package com.example.insightservice;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;

@SpringBootApplication
@EnableDiscoveryClient
public class InsightServiceApplication {

    public static void main(String[] args) {
        SpringApplication.run(InsightServiceApplication.class, args);
    }
}