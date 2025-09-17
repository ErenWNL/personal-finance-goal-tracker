package com.example.apigateway.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cloud.client.ServiceInstance;
import org.springframework.cloud.client.discovery.DiscoveryClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/gateway")
public class GatewayInfoController {

    @Autowired
    private DiscoveryClient discoveryClient;

    @GetMapping("/health")
    public Map<String, Object> health() {
        Map<String, Object> response = new HashMap<>();
        response.put("status", "UP");
        response.put("service", "API Gateway");
        response.put("port", 8081);
        response.put("timestamp", LocalDateTime.now());
        response.put("message", "API Gateway is running successfully!");
        return response;
    }

    @GetMapping("/services")
    public Map<String, Object> getRegisteredServices() {
        Map<String, Object> response = new HashMap<>();

        List<String> services = discoveryClient.getServices();
        Map<String, Object> serviceDetails = new HashMap<>();

        for (String serviceName : services) {
            List<ServiceInstance> instances = discoveryClient.getInstances(serviceName);
            Map<String, Object> serviceInfo = new HashMap<>();
            serviceInfo.put("instances", instances.size());

            if (!instances.isEmpty()) {
                ServiceInstance instance = instances.get(0);
                serviceInfo.put("host", instance.getHost());
                serviceInfo.put("port", instance.getPort());
                serviceInfo.put("uri", instance.getUri().toString());
            }

            serviceDetails.put(serviceName, serviceInfo);
        }

        response.put("registeredServices", services);
        response.put("serviceDetails", serviceDetails);
        response.put("totalServices", services.size());
        response.put("timestamp", LocalDateTime.now());

        return response;
    }

    @GetMapping("/routes")
    public Map<String, Object> getRoutes() {
        Map<String, Object> response = new HashMap<>();

        Map<String, String> routes = new HashMap<>();
        routes.put("/auth/**", "authentication-service");
        routes.put("/finance/**", "user-finance-service");
        routes.put("/goals/**", "goal-service");
        routes.put("/insights/**", "insight-service");
        routes.put("/test/**", "insight-service (testing)");
        routes.put("/integrated/**", "insight-service (integrated)");

        response.put("availableRoutes", routes);
        response.put("gatewayUrl", "http://localhost:8081");
        response.put("timestamp", LocalDateTime.now());

        Map<String, String> examples = new HashMap<>();
        examples.put("Auth Health", "GET http://localhost:8081/auth/health");
        examples.put("Finance Health", "GET http://localhost:8081/finance/health");
        examples.put("Goals Health", "GET http://localhost:8081/goals/health");
        examples.put("Insights Health", "GET http://localhost:8081/insights/health");
        examples.put("Test Communication", "GET http://localhost:8081/test/communication-status");
        examples.put("Gateway Services", "GET http://localhost:8081/gateway/services");

        response.put("examples", examples);

        return response;
    }
}