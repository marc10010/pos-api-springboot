package com.tienda.user_service.service;

import com.tienda.user_service.model.User;
import com.tienda.user_service.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.mockito.Mockito.*;
import static org.junit.jupiter.api.Assertions.*;

@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    @Mock
    private UserRepository userRepository;

    private UserService userService;

    @BeforeEach
    void setUp() {
        userService = new UserService(userRepository);
    }

    @Test
    void getAllUsers_ShouldReturnListOfUsers() {
        // Arrange
        User user1 = new User("John Doe", "john@example.com");
        User user2 = new User("Jane Doe", "jane@example.com");
        List<User> expectedUsers = Arrays.asList(user1, user2);
        
        when(userRepository.findAll()).thenReturn(expectedUsers);

        // Act
        List<User> actualUsers = userService.getAllUsers();

        // Assert
        assertNotNull(actualUsers);
        assertEquals(2, actualUsers.size());
        assertEquals(expectedUsers, actualUsers);
        verify(userRepository).findAll();
    }

    @Test
    void getUserById_WhenUserExists_ShouldReturnUser() {
        // Arrange
        Long userId = 1L;
        User expectedUser = new User("John Doe", "john@example.com");
        when(userRepository.findById(userId)).thenReturn(Optional.of(expectedUser));

        // Act
        Optional<User> actualUser = userService.getUserById(userId);

        // Assert
        assertTrue(actualUser.isPresent());
        assertEquals(expectedUser, actualUser.get());
        verify(userRepository).findById(userId);
    }

    @Test
    void getUserById_WhenUserDoesNotExist_ShouldReturnEmpty() {
        // Arrange
        Long userId = 1L;
        when(userRepository.findById(userId)).thenReturn(Optional.empty());

        // Act
        Optional<User> actualUser = userService.getUserById(userId);

        // Assert
        assertFalse(actualUser.isPresent());
        verify(userRepository).findById(userId);
    }

    @Test
    void createUser_ShouldReturnSavedUser() {
        // Arrange
        User userToCreate = new User("John Doe", "john@example.com");
        when(userRepository.save(any(User.class))).thenReturn(userToCreate);

        // Act
        User createdUser = userService.createUser(userToCreate);

        // Assert
        assertNotNull(createdUser);
        assertEquals(userToCreate.getName(), createdUser.getName());
        assertEquals(userToCreate.getEmail(), createdUser.getEmail());
        verify(userRepository).save(userToCreate);
    }

    @Test
    void deleteUser_ShouldCallRepositoryDelete() {
        // Arrange
        Long userId = 1L;

        // Act
        userService.deleteUser(userId);

        // Assert
        verify(userRepository).deleteById(userId);
    }

    @Test
    void createUser_WhenEmailExists() {
        // Arrange
        String existingEmail = "john@example.com";
        User existingUser = new User("John Doe", existingEmail);
        User newUser = new User("Jane Doe", existingEmail); // Mismo email

        when(userRepository.findByEmail(existingEmail)).thenReturn(Optional.of(existingUser));

        // Act & Assert
        assertThrows(IllegalArgumentException.class, () -> {
            userService.createUser(newUser);
        });
        
        verify(userRepository).findByEmail(existingEmail);
        verify(userRepository, never()).save(any(User.class));
    }
}
