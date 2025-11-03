# Swagger API Documentation Setup

## Overview

This project has been configured with **Springdoc OpenAPI** (Swagger 3.0) for comprehensive API documentation. All microservices now provide interactive API documentation accessible through Swagger UI and OpenAPI specifications.

## 📚 Documentation Access

### Individual Service Documentation

Each microservice exposes its own Swagger UI and OpenAPI specification:

| Service | Swagger UI | OpenAPI Spec | Port |
|---------|-----------|--------------|------|
| **API Gateway** | http://localhost:8081/swagger-ui.html | http://localhost:8081/v3/api-docs | 8081 |
| **Authentication Service** | http://localhost:8082/swagger-ui.html | http://localhost:8082/v3/api-docs | 8082 |
| **User Finance Service** | http://localhost:8083/swagger-ui.html | http://localhost:8083/v3/api-docs | 8083 |
| **Goal Service** | http://localhost:8084/swagger-ui.html | http://localhost:8084/v3/api-docs | 8084 |
| **Insight Service** | http://localhost:8085/swagger-ui.html | http://localhost:8085/v3/api-docs | 8085 |

### Via API Gateway

Access all services through the central API Gateway:

- **Gateway Swagger UI**: http://localhost:8081/swagger-ui.html
- **Gateway OpenAPI Spec**: http://localhost:8081/v3/api-docs

The Gateway provides a unified entry point with links to all microservices' documentation.

## 🔍 Features

### Swagger UI Features

- **Interactive API Testing**: Try out endpoints directly from the browser
- **Request/Response Examples**: See sample data for each endpoint
- **Parameter Documentation**: View all required and optional parameters
- **Response Codes**: Understand all possible HTTP response codes
- **Authorization**: Support for API authentication tokens

### Organized by Tags

All endpoints are organized by tags for easy navigation:

- **Authentication**: User registration, login, profile management
- **Finance**: Transactions and categories management
- **Goals**: Financial goals and progress tracking
- **Analytics**: Spending analytics and trends
- **Recommendations**: Personalized financial recommendations

### Operation Details

Each endpoint includes:

- **Summary**: Brief description of what the endpoint does
- **Description**: Detailed explanation of functionality
- **Parameters**: Path parameters, query parameters, request body details
- **Responses**: Expected HTTP responses with status codes
- **Error Handling**: Common error scenarios and how they're handled

## 📝 Implementation Details

### Springdoc OpenAPI Version

- **Version**: 2.0.4
- **SpringBoot Integration**: Automatic OpenAPI spec generation from annotations
- **Swagger UI**: Interactive Web UI for API exploration

### Dependencies Added

#### For WebMVC Services (Auth, Finance, Goal, Insight)

```xml
<dependency>
    <groupId>org.springdoc</groupId>
    <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
    <version>2.0.4</version>
</dependency>
```

#### For WebFlux Services (API Gateway)

```xml
<dependency>
    <groupId>org.springdoc</groupId>
    <artifactId>springdoc-openapi-starter-webflux-ui</artifactId>
    <version>2.0.4</version>
</dependency>
```

### Configuration

Each service has been configured with the following properties in `application.properties`:

```properties
# OpenAPI/Swagger Configuration
springdoc.api-docs.path=/v3/api-docs
springdoc.swagger-ui.path=/swagger-ui.html
springdoc.swagger-ui.enabled=true
springdoc.swagger-ui.operations-sorter=method
springdoc.swagger-ui.tags-sorter=alpha
springdoc.show-actuator=true
```

### Custom OpenAPI Configuration

Each service includes a `SwaggerConfig` class that customizes the OpenAPI specification:

- **Service Information**: Title, version, description
- **Contact Details**: Team contact information
- **License**: Apache 2.0
- **Server URLs**: Local development and production servers

#### Example SwaggerConfig

```java
@Configuration
public class SwaggerConfig {
    @Bean
    public OpenAPI customOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("Authentication Service API")
                        .version("1.0.0")
                        .description("API for user authentication and management")
                        .contact(new Contact()
                                .name("Finance Tracker Team")
                                .email("support@financetracker.com"))
                        .license(new License()
                                .name("Apache 2.0")))
                .addServersItem(new Server()
                        .url("http://localhost:8081")
                        .description("API Gateway"))
                .addServersItem(new Server()
                        .url("http://localhost:8082")
                        .description("Direct Service Access"));
    }
}
```

## 🏷️ API Annotations

### Controller Level

```java
@RestController
@RequestMapping("/auth")
@Tag(name = "Authentication", description = "User authentication and profile management")
public class AuthController {
    // ...
}
```

### Method Level

```java
@PostMapping("/register")
@Operation(summary = "Register a new user",
           description = "Create a new user account with email and password")
@ApiResponses(value = {
    @ApiResponse(responseCode = "200", description = "User registered successfully"),
    @ApiResponse(responseCode = "400", description = "Invalid request"),
    @ApiResponse(responseCode = "500", description = "Internal server error")
})
public ResponseEntity<Map<String, Object>> register(@RequestBody RegisterRequest request) {
    // ...
}
```

### Annotations Used

| Annotation | Purpose |
|-----------|---------|
| `@Tag` | Groups related endpoints |
| `@Operation` | Documents an API operation |
| `@ApiResponse` | Documents a response status code |
| `@ApiResponses` | Groups multiple response codes |
| `@RequestBody` | Documents request body parameters |
| `@Schema` | Provides schema information for request/response bodies |

## 🚀 Quick Start

### 1. Start the Services

```bash
# Start all services with Docker Compose
docker-compose -f docker-compose-self-hosted.yml up -d

# OR run services locally
mvn spring-boot:run
```

### 2. Access Swagger UI

Open your browser and navigate to any service's Swagger UI:

```
http://localhost:8081/swagger-ui.html
```

### 3. Test an Endpoint

1. Click on any endpoint to expand it
2. Click the **"Try it out"** button
3. Fill in any required parameters
4. Click **"Execute"** to send the request
5. View the response

## 📋 Available Endpoints

### Authentication Service (`/auth`)

- `POST /auth/register` - Register a new user
- `POST /auth/login` - Login with credentials
- `GET /auth/user/{id}` - Get user by ID
- `PUT /auth/user/{id}` - Update user profile
- `DELETE /auth/user/{id}` - Delete user account
- `GET /auth/users` - Get all users

### User Finance Service (`/finance`)

- `POST /finance/transactions` - Create transaction
- `GET /finance/transactions` - Get all transactions
- `GET /finance/transactions/user/{userId}` - Get user transactions
- `GET /finance/transactions/{id}` - Get transaction by ID
- `PUT /finance/transactions/{id}` - Update transaction
- `DELETE /finance/transactions/{id}` - Delete transaction
- `GET /finance/transactions/user/{userId}/summary` - Get transaction summary
- `POST /finance/categories` - Create category
- `GET /finance/categories` - Get all categories
- `GET /finance/categories/{id}` - Get category by ID
- `PUT /finance/categories/{id}` - Update category
- `DELETE /finance/categories/{id}` - Delete category

### Goal Service (`/goals`)

- `POST /goals` - Create goal
- `GET /goals` - Get all goals
- `GET /goals/user/{userId}` - Get user goals
- `GET /goals/{id}` - Get goal by ID
- `PUT /goals/{id}` - Update goal
- `DELETE /goals/{id}` - Delete goal

### Insight Service (`/insights`, `/analytics`, `/recommendations`)

#### Analytics Endpoints

- `GET /analytics/user/{userId}` - Get spending analytics
- `GET /analytics/user/{userId}/summary` - Get spending summary
- `GET /analytics/user/{userId}/trends` - Get spending trends
- `GET /analytics/user/{userId}/top-categories` - Get top spending categories
- `GET /analytics/user/{userId}/recent` - Get recent analytics

#### Recommendations Endpoints

- `GET /recommendations/user/{userId}` - Get user recommendations
- `GET /recommendations/user/{userId}/summary` - Get recommendation summary
- `GET /recommendations/user/{userId}/type/{type}` - Get recommendations by type
- `GET /recommendations/user/{userId}/priority/{priority}` - Get by priority
- `POST /recommendations` - Create recommendation
- `PUT /recommendations/{id}/read` - Mark as read
- `PUT /recommendations/{id}/dismiss` - Dismiss recommendation

## 🔐 Authentication

The API uses JWT (JSON Web Token) for authentication:

1. **Register/Login**: Get a JWT token from the Authentication Service
2. **Use Token**: Include the token in the `Authorization` header
3. **Token Format**: `Bearer <token>`

### Example Request

```bash
curl -X GET http://localhost:8081/finance/transactions/user/1 \
  -H "Authorization: Bearer your_jwt_token_here"
```

## 📊 Response Format

All endpoints return consistent JSON responses:

```json
{
  "success": true,
  "message": "Operation successful",
  "data": {
    // response data
  }
}
```

### Error Response

```json
{
  "success": false,
  "message": "Error description",
  "error": "Error details"
}
```

## 🛠️ Development & Customization

### Adding Documentation to New Endpoints

```java
@PostMapping("/new-endpoint")
@Operation(summary = "Brief description",
           description = "Detailed description of what this endpoint does")
@ApiResponses(value = {
    @ApiResponse(responseCode = "200", description = "Success"),
    @ApiResponse(responseCode = "400", description = "Bad request"),
    @ApiResponse(responseCode = "500", description = "Server error")
})
public ResponseEntity<ResponseType> newEndpoint(@RequestBody RequestType request) {
    // implementation
}
```

### Customizing Service Information

Edit the `SwaggerConfig.java` in each service to customize:

- API title and version
- Description
- Contact information
- License
- Server URLs

## 📈 Benefits

- **Developer Experience**: Self-documenting APIs
- **API Testing**: Interactive exploration without external tools
- **Integration**: Easy integration with API clients and SDKs
- **Maintenance**: Keep documentation in sync with code automatically
- **Client Generation**: Generate client libraries from OpenAPI specs
- **Compliance**: Meet API documentation standards

## 🔗 Related Resources

- [Springdoc OpenAPI Documentation](https://springdoc.org/)
- [OpenAPI 3.0 Specification](https://spec.openapis.org/oas/v3.0.3)
- [Swagger UI Official](https://swagger.io/tools/swagger-ui/)
- [JSON Schema](https://json-schema.org/)

## 📝 Notes

- Swagger UI is enabled by default in all environments
- OpenAPI specs are automatically generated from code annotations
- All endpoints are documented and accessible through the interactive UI
- The API Gateway provides a unified entry point for all services
- Response schemas are automatically inferred from controller return types

---

**Last Updated**: 2024
**Version**: 1.0.0
