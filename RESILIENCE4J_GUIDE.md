# Resilience4j en POS Microservices

## ¿Qué es Resilience4j?

Resilience4j es una biblioteca de resiliencia para Java que implementa patrones como:
- **Circuit Breaker**: Protege contra fallos en cascada
- **Retry**: Reintenta operaciones fallidas
- **Time Limiter**: Controla timeouts
- **Bulkhead**: Aísla recursos
- **Rate Limiter**: Limita la tasa de peticiones

## Implementación en Order Service

### 1. Dependencias Agregadas

```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-circuitbreaker-resilience4j</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
```

### 2. Configuración (application.yml)

```yaml
resilience4j:
  circuitbreaker:
    instances:
      productService:
        sliding-window-size: 10
        failure-rate-threshold: 50
        wait-duration-in-open-state: 5000
        permitted-number-of-calls-in-half-open-state: 3
  retry:
    instances:
      productService:
        max-attempts: 3
        wait-duration: 1000
  timelimiter:
    instances:
      productService:
        timeout-duration: 2s
```

### 3. Uso en el Código

```java
@CircuitBreaker(name = "productService", fallbackMethod = "validateProductsFallback")
@Retry(name = "productService", fallbackMethod = "validateProductsFallback")
@TimeLimiter(name = "productService", fallbackMethod = "validateProductsFallback")
public CompletableFuture<ProductResponse> getProductById(Long productId) {
    return CompletableFuture.supplyAsync(() -> productClient.getProductById(productId));
}
```

## Endpoints de Prueba

### 1. Probar Resilience4j
```bash
# Probar con producto existente
curl http://localhost:8082/orders/test-product/1

# Probar con producto inexistente (simular fallo)
curl http://localhost:8082/orders/test-product/999
```

### 2. Monitoreo de Circuit Breakers
```bash
# Estado de circuit breakers
curl http://localhost:8082/actuator/health

# Métricas detalladas
curl http://localhost:8082/actuator/circuitbreakers
```

## Estados del Circuit Breaker

### 1. CLOSED (Cerrado) - Estado Normal
- ✅ Las peticiones pasan normalmente
- ✅ Se registran éxitos y fallos
- ✅ Si el % de fallos supera el umbral → OPEN

### 2. OPEN (Abierto) - Estado de Fallo
- ❌ Las peticiones se bloquean
- ✅ Se ejecuta el fallback method
- ⏰ Después de `wait-duration` → HALF_OPEN

### 3. HALF_OPEN (Semi-abierto) - Estado de Recuperación
- 🔄 Se permiten algunas peticiones de prueba
- ✅ Si son exitosas → CLOSED
- ❌ Si fallan → OPEN

## Configuración Detallada

### Circuit Breaker
- **sliding-window-size**: 10 (ventana de peticiones para calcular fallos)
- **failure-rate-threshold**: 50% (umbral de fallos para abrir)
- **wait-duration-in-open-state**: 5s (tiempo antes de intentar recuperación)
- **permitted-number-of-calls-in-half-open-state**: 3 (peticiones de prueba)

### Retry
- **max-attempts**: 3 (máximo de reintentos)
- **wait-duration**: 1s (tiempo entre reintentos)

### Time Limiter
- **timeout-duration**: 2s (timeout máximo)
- **cancel-running-future**: true (cancela futuros en ejecución)

## Logs y Monitoreo

### Logs de Resilience4j
```bash
# Ver logs en tiempo real
tail -f logs/Order\ Service.log | grep -i resilience
```

### Métricas Disponibles
- Circuit breaker state changes
- Success/failure counts
- Response times
- Retry attempts

## Casos de Uso en POS

### 1. Validación de Productos
```java
// Si product-service falla, usa fallback
ProductResponse product = orderService.getProductById(productId).get();
if (!product.isAvailable()) {
    // Manejar producto no disponible
}
```

### 2. Creación de Órdenes
```java
// La orden se crea incluso si la validación falla
Order order = orderService.createOrder(orderRequest);
```

### 3. Consulta de Usuarios
```java
// Futuro: Validación de usuarios con fallback
@CircuitBreaker(name = "userService", fallbackMethod = "getUserFallback")
public CompletableFuture<UserResponse> getUserById(Long userId) {
    return CompletableFuture.supplyAsync(() -> userClient.getUserById(userId));
}
```

## Beneficios para el POS

### 1. Resiliencia
- ✅ Sistema sigue funcionando aunque algunos servicios fallen
- ✅ Degradación graceful en lugar de errores totales

### 2. Experiencia de Usuario
- ✅ No más pantallas de error confusas
- ✅ Respuestas consistentes y predecibles

### 3. Monitoreo
- ✅ Visibilidad de fallos por servicio
- ✅ Métricas de rendimiento
- ✅ Alertas automáticas

### 4. Recuperación Automática
- ✅ Los servicios se recuperan solos
- ✅ No requiere intervención manual

## Próximos Pasos

1. **Implementar en otros servicios**
   - User Service ↔ Order Service
   - Gateway ↔ Todos los servicios

2. **Configuraciones avanzadas**
   - Bulkhead para aislamiento
   - Rate Limiter para control de carga

3. **Monitoreo avanzado**
   - Prometheus + Grafana
   - Alertas automáticas

4. **Testing**
   - Unit tests con Resilience4j
   - Integration tests con fallos simulados
