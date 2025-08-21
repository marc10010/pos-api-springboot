package com.tienda.user_service.repository;

import com.tienda.user_service.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    //JPA Repository already has the methods for the CRUD operations
}