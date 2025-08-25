# Tasky Application Architecture Documentation

## 1. Architectural Overview: Clean Architecture Implementation

### Architecture Layers

```mermaid
graph TD
    A[Presentation Layer] --> B[Domain Layer] --> C[Data Layer]
    
    subgraph Presentation
        A1[Pages/Screens]
        A2[Widgets]
        A3[Providers/State Management]
    end
    
    subgraph Domain
        B1[Entities]
        B2[Repositories Interfaces]
        B3[Use Cases]
    end
    
    subgraph Data
        C1[Local Data Sources]
        C2[Remote Data Sources]
        C3[Repository Implementations]
    end
```

### Key Architectural Principles

1. **Separation of Concerns**: 
   - **Presentation Layer**: Handles UI and user interactions
   - **Domain Layer**: Contains business logic and core entities
   - **Data Layer**: Manages data retrieval and storage

2. **Dependency Rule**:
   - Inner layers (Domain) are independent of outer layers
   - Dependency flow is unidirectional: Presentation → Domain → Data
   - Outer layers depend on inner layers, never vice versa

## 2. State Management: Riverpod Providers

### State Management Architecture

```mermaid
graph TD
    A[UI Widget] --> B[Riverpod Provider]
    B --> C{Provider Type}
    C -->|StateNotifierProvider| D[State Management Logic]
    C -->|FutureProvider| E[Asynchronous Data Fetching]
    C -->|StreamProvider| F[Real-time Data Streams]
    D --> G[Repository/Use Case]
    E --> G
    F --> G
```

### Provider Categories
- **Core Providers**: Singleton services and global configurations
- **Feature Providers**: State management for specific features
- **Dependency Providers**: Injection of services and repositories

## 3. Data Layer: SQLite with Drift ORM

### Database Architecture

```mermaid
graph TD
    A[Repository Implementation] --> B[Local Data Source]
    B --> C[Drift Database]
    C --> D[(SQLite Database)]
    
    subgraph Data Access
        A1[DAO - Data Access Objects]
        A2[Query Generation]
    end
    
    C --> A1
    A1 --> A2
```

### Key Database Characteristics
- Type-safe database operations
- Code-generated DAOs
- Supports complex queries and relationships
- Offline-first data storage strategy

## 4. AI and External Services Integration

```mermaid
graph TD
    A[AI Service Provider] --> B{Service Selection}
    B -->|OpenAI| C[OpenAI Task Parsing]
    B -->|Claude| D[Claude AI Integration]
    
    E[Speech Service] --> F{Fallback Mechanism}
    F -->|Local| G[On-device Speech Recognition]
    F -->|Remote| H[Cloud Speech API]
```

### Service Integration Strategies
- Multiple AI providers with fallback mechanisms
- Configurable API key management
- Abstracted service interfaces for easy extension

## 5. Performance and Monitoring

### Performance Monitoring Strategy

```mermaid
graph TD
    A[App Performance Monitoring]
    A --> B[Startup Time Tracking]
    A --> C[User Interaction Metrics]
    A --> D[Resource Utilization]
    
    B --> E[Initialization Services]
    C --> F[User Flow Analytics]
    D --> G[Memory and CPU Usage]
```

## 6. Error Handling and Resilience

```mermaid
graph TD
    A[Error Detection] --> B{Error Type}
    B -->|Network| C[Offline Fallback]
    B -->|Authentication| D[Re-authentication Flow]
    B -->|Data Integrity| E[Rollback/Recovery]
    
    F[Global Error Handler] --> G[Logging]
    F --> H[User Notification]
```

## Architectural Principles

1. **Type Safety**: Extensive use of sealed classes and enums
2. **Dependency Injection**: Centralized through Riverpod
3. **Immutability**: Prefer immutable data structures
4. **Composability**: Modular and loosely coupled components

## Performance Benchmarks

- **AI Parsing**: <50ms (simple text), <500ms (complex)
- **Task Operations**: <100ms for 1000 operations
- **UI Rendering**: <100ms for complex widgets

## Development Best Practices

- Strict linting rules
- Comprehensive test coverage
- Performance monitoring
- Continuous refactoring
