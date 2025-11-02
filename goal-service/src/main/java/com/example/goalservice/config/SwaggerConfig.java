package com.example.goalservice.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.License;
import io.swagger.v3.oas.models.servers.Server;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class SwaggerConfig {

    @Bean
    public OpenAPI customOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("Goal Service API")
                        .version("1.0.0")
                        .description("API for managing financial goals, categories, and progress tracking")
                        .contact(new Contact()
                                .name("Finance Tracker Team")
                                .email("support@financetracker.com")
                                .url("https://github.com/yourusername/personal-finance-goal-tracker"))
                        .license(new License()
                                .name("Apache 2.0")
                                .url("https://www.apache.org/licenses/LICENSE-2.0.html")))
                .addServersItem(new Server()
                        .url("http://localhost:8081")
                        .description("API Gateway (via Gateway)"))
                .addServersItem(new Server()
                        .url("http://localhost:8084")
                        .description("Direct Service Access"));
    }
}
