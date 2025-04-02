import Foundation

/// A simple dependency injection container
class DIContainer {
    private var factories: [String: () -> Any] = [:]
    private var instances: [String: Any] = [:]
    
    static let shared = DIContainer()
    
    private init() {}
    
    /// Register a factory for creating instances of a type
    func register<T>(type: T.Type, factory: @escaping () -> T) {
        let key = String(describing: type)
        factories[key] = factory
    }
    
    /// Register a singleton instance
    func registerSingleton<T>(type: T.Type, instance: T) {
        let key = String(describing: type)
        instances[key] = instance
    }
    
    /// Register a singleton with a factory that will be called only once
    func registerSingleton<T>(type: T.Type, factory: @escaping () -> T) {
        let key = String(describing: type)
        instances[key] = factory()
    }
    
    /// Get an instance of the specified type
    func resolve<T>(_ type: T.Type) -> T {
        let key = String(describing: type)
        
        // Return singleton instance if available
        if let instance = instances[key] as? T {
            return instance
        }
        
        // Create a new instance using the factory
        guard let factory = factories[key] as? () -> T else {
            fatalError("No factory registered for type \(key)")
        }
        
        return factory()
    }
}

/// Convenience protocol for accessing the DI container
protocol DIContainerAware {
    var container: DIContainer { get }
}

extension DIContainerAware {
    var container: DIContainer {
        return DIContainer.shared
    }
    
    func resolve<T>(_ type: T.Type) -> T {
        return container.resolve(type)
    }
} 