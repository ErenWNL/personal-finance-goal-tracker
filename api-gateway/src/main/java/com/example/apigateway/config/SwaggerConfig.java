package com.example.apigateway.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.License;
import io.swagger.v3.oas.models.servers.Server;
import io.swagger.v3.oas.models.ExternalDocumentation;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class SwaggerConfig {

    @Bean
    public OpenAPI customOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("Personal Finance Goal Tracker API")
                        .version("1.0.0")
                        .description("Comprehensive microservices API for personal finance management, including authentication, transactions, goals, and insights")
                        .contact(new Contact()
                                .name("Finance Tracker Team")
                                .email("support@financetracker.com")
                                .url("https://github.com/yourusername/personal-finance-goal-tracker"))
                        .license(new License()
                                .name("Apache 2.0")
                                .url("https://www.apache.org/licenses/LICENSE-2.0.html")))
                .externalDocs(new ExternalDocumentation()
                        .description("Finance Tracker Documentation")
                        .url("https://financetracker.example.com/docs"))
                .addServersItem(new Server()
                        .url("http://localhost:8081")
                        .description("Local Gateway"))
                .addServersItem(new Server()
                        .url("http://localhost:8082")
                        .description("Authentication Service (Direct)"))
                .addServersItem(new Server()
                        .url("http://localhost:8083")
                        .description("User Finance Service (Direct)"))
                .addServersItem(new Server()
                        .url("http://localhost:8084")
                        .description("Goal Service (Direct)"))
                .addServersItem(new Server()
                        .url("http://localhost:8085")
                        .description("Insight Service (Direct)"));
    }
}
