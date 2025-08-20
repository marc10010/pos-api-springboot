package com.tienda.order_service.service;

import com.tienda.order_service.model.Order;
import com.tienda.order_service.repository.OrderRepository;
import com.tienda.order_service.client.ProductClient;
import com.tienda.order_service.dto.ProductResponse;
import io.github.resilience4j.circuitbreaker.annotation.CircuitBreaker;
import io.github.resilience4j.retry.annotation.Retry;
import io.github.resilience4j.timelimiter.annotation.TimeLimiter;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.concurrent.CompletableFuture;

@Service
@Slf4j
public class OrderService {

    private final OrderRepository orderRepository;
    private final ProductClient productClient;

    public OrderService(OrderRepository orderRepository, ProductClient productClient) {
        this.orderRepository = orderRepository;
        this.productClient = productClient;
    }

    public Order createOrder(Order order) {
        // Validar productos antes de crear la orden
        validateProducts(order);
        
        order.setOrderDate(LocalDateTime.now());
        return orderRepository.save(order);
    }

    @CircuitBreaker(name = "productService", fallbackMethod = "validateProductsFallback")
    @Retry(name = "productService", fallbackMethod = "validateProductsFallback")
    @TimeLimiter(name = "productService", fallbackMethod = "validateProductsFallback")
    public CompletableFuture<ProductResponse> getProductById(Long productId) {
        log.info("Consultando producto con ID: {}", productId);
        return CompletableFuture.supplyAsync(() -> productClient.getProductById(productId));
    }

    public CompletableFuture<ProductResponse> validateProductsFallback(Long productId, Exception ex) {
        log.warn("Fallback ejecutado para producto ID: {}. Error: {}", productId, ex.getMessage());
        
        // Crear un producto de fallback
        ProductResponse fallbackProduct = new ProductResponse();
        fallbackProduct.setId(productId);
        fallbackProduct.setName("Producto no disponible");
        fallbackProduct.setPrice(0.0);
        fallbackProduct.setAvailable(false);
        
        return CompletableFuture.completedFuture(fallbackProduct);
    }

    private void validateProducts(Order order) {
        // Aquí puedes agregar la lógica de validación de productos
        // Por ejemplo, verificar que los productos existen y están disponibles
        log.info("Validando productos para la orden: {}", order.getId());
    }

    public List<Order> getOrders() {
        return orderRepository.findAll();
    }

    public Optional<Order> getOrderById(Long id) {
        return orderRepository.findById(id);
    }
}
