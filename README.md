# Point of Sale API - Microservices

Sistema de Point of Sale (POS) implementado con arquitectura de microservicios usando Spring Boot y Spring Cloud.

## Arquitectura

El proyecto está compuesto por los siguientes microservicios:

- **discovery-service** (Puerto 8761): Servidor Eureka para descubrimiento de servicios
- **user-service** (Puerto 8080): Gestión de usuarios
- **product-service** (Puerto 8081): Gestión de productos
- **order-service** (Puerto 8082): Gestión de órdenes con validación de productos

## Tecnologías Utilizadas

- **Spring Boot 3.1.0**
- **Spring Cloud Hoxton.SR12**
- **Spring Data JPA**
- **H2 Database** (para desarrollo)
- **Maven** (gestión de dependencias)
- **Lombok** (reducción de código boilerplate)

## Comunicación entre Microservicios

- **OpenFeign**: Para comunicación cliente-servidor entre microservicios
- **Eureka**: Para descubrimiento y registro de servicios
- **Order Service** ↔ **Product Service**: Validación de productos antes de crear órdenes

## Cómo Ejecutar

### 1. Compilar el proyecto
```bash
mvn clean compile
```

### 2. Ejecutar los servicios (en orden)

#### Discovery Service (Primero)
```bash
cd discovery-service
mvn spring-boot:run
```

#### Product Service
```bash
cd product-service
mvn spring-boot:run
```

#### User Service
```bash
cd user-service
mvn spring-boot:run
```

#### Order Service
```bash
cd order-service
mvn spring-boot:run
```

## Endpoints Disponibles

### User Service (http://localhost:8080)
- `GET /users` - Obtener todos los usuarios
- `GET /users/{id}` - Obtener usuario por ID
- `POST /users` - Crear nuevo usuario
- `DELETE /users/{id}` - Eliminar usuario

### Product Service (http://localhost:8081)
- `GET /api/products` - Obtener todos los productos
- `GET /api/products/{id}` - Obtener producto por ID
- `POST /api/products` - Crear nuevo producto
- `DELETE /api/products/{id}` - Eliminar producto

### Order Service (http://localhost:8082)
- `GET /orders` - Obtener todas las órdenes
- `GET /orders/{id}` - Obtener orden por ID
- `POST /orders` - Crear nueva orden (valida productos)

## Monitoreo

- **Eureka Dashboard**: http://localhost:8761
- **H2 Console**:
  - User Service: http://localhost:8080/h2-console
  - Product Service: http://localhost:8081/h2-console
  - Order Service: http://localhost:8082/h2-console

## Estructura del Proyecto

```
pointOfSaleAPI/
├── discovery-service/     # Servidor Eureka
├── user-service/         # Gestión de usuarios
├── product-service/      # Gestión de productos
├── order-service/        # Gestión de órdenes
└── pom.xml              # POM padre
```

## Próximos Pasos

- [ ] Implementar API Gateway
- [ ] Agregar Circuit Breaker (Resilience4j)
- [ ] Implementar autenticación y autorización
- [ ] Agregar logging centralizado
- [ ] Implementar métricas con Micrometer
- [ ] Containerización con Docker
- [ ] Orquestación con Kubernetes
