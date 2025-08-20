package com.tienda.order_service.controller;

import com.tienda.order_service.model.Order;
import com.tienda.order_service.service.OrderService;
import com.tienda.order_service.dto.ProductResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;
import java.util.concurrent.CompletableFuture;

@RestController
@RequestMapping("/orders")
@Slf4j
public class OrderController {

    private final OrderService orderService;

    public OrderController(OrderService orderService) {
        this.orderService = orderService;
    }

    @PostMapping
    public ResponseEntity<Order> createOrder(@RequestBody Order order) {
        Order newOrder = orderService.createOrder(order);
        return new ResponseEntity<>(newOrder, HttpStatus.CREATED);
    }

    @GetMapping
    public List<Order> getOrders() {
        return orderService.getOrders();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Order> getOrderById(@PathVariable Long id) {
        Optional<Order> order = orderService.getOrderById(id);
        return order.map(ResponseEntity::ok)
                     .orElseGet(() -> ResponseEntity.notFound().build());
    }

    // Endpoint para probar Resilience4j
    @GetMapping("/test-product/{productId}")
    public ResponseEntity<CompletableFuture<ProductResponse>> testProductResilience(@PathVariable Long productId) {
        log.info("Probando Resilience4j para producto ID: {}", productId);
        CompletableFuture<ProductResponse> productFuture = orderService.getProductById(productId);
        return ResponseEntity.ok(productFuture);
    }

    // Endpoint para obtener estado de circuit breakers
    @GetMapping("/health/circuit-breaker")
    public ResponseEntity<String> getCircuitBreakerStatus() {
        return ResponseEntity.ok("Circuit Breaker Status - Endpoint disponible en /actuator/health");
    }
}
