import Foundation

class CacheManager {
    static let shared = CacheManager()
    
    private let cache = NSCache<NSString, CacheEntry>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    private init() {
        // Get the cache directory
        guard let cacheDir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            fatalError("Unable to find cache directory")
        }
        
        cacheDirectory = cacheDir.appendingPathComponent("ApiCache")
        
        // Create cache directory if it doesn't exist
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            do {
                try fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
            } catch {
                print("Error creating cache directory: \(error)")
            }
        }
    }
    
    /// Set a value in the cache with an expiry duration
    func set(_ value: Any, forKey key: String, expiryDuration: TimeInterval) {
        let expiryDate = Date().addingTimeInterval(expiryDuration)
        let entry = CacheEntry(value: value, expiryDate: expiryDate)
        cache.setObject(entry, forKey: key as NSString)
        
        // If it's Data, also save to disk
        if let data = value as? Data {
            saveDataToDisk(data, forKey: key, expiryDate: expiryDate)
        }
    }
    
    /// Get a value from the cache
    func get(forKey key: String) -> Any? {
        // Check memory cache first
        if let entry = cache.object(forKey: key as NSString), !entry.isExpired {
            return entry.value
        }
        
        // If not in memory, check disk cache
        return getDataFromDisk(forKey: key)
    }
    
    /// Remove a value from the cache
    func remove(forKey key: String) {
        cache.removeObject(forKey: key as NSString)
        removeDataFromDisk(forKey: key)
    }
    
    /// Clear all cached data
    func clearAll() {
        cache.removeAllObjects()
        
        do {
            let fileURLs = try fileManager.contentsOfDirectory(
                at: cacheDirectory,
                includingPropertiesForKeys: nil
            )
            for fileURL in fileURLs {
                try fileManager.removeItem(at: fileURL)
            }
        } catch {
            print("Error clearing cache: \(error)")
        }
    }
    
    // MARK: - Private Methods
    
    private func saveDataToDisk(_ data: Data, forKey key: String, expiryDate: Date) {
        let fileURL = cacheDirectory.appendingPathComponent(key.md5)
        let metadataURL = cacheDirectory.appendingPathComponent("\(key.md5).metadata")
        
        // Save the data
        do {
            try data.write(to: fileURL)
            
            // Save metadata
            let metadata = CacheMetadata(expiryDate: expiryDate)
            let metadataData = try JSONEncoder().encode(metadata)
            try metadataData.write(to: metadataURL)
        } catch {
            print("Error saving data to disk: \(error)")
        }
    }
    
    private func getDataFromDisk(forKey key: String) -> Data? {
        let fileURL = cacheDirectory.appendingPathComponent(key.md5)
        let metadataURL = cacheDirectory.appendingPathComponent("\(key.md5).metadata")
        
        // Check if files exist
        guard fileManager.fileExists(atPath: fileURL.path),
              fileManager.fileExists(atPath: metadataURL.path) else {
            return nil
        }
        
        // Check expiry
        do {
            let metadataData = try Data(contentsOf: metadataURL)
            let metadata = try JSONDecoder().decode(CacheMetadata.self, from: metadataData)
            
            if metadata.isExpired {
                // Remove expired files
                removeDataFromDisk(forKey: key)
                return nil
            }
            
            // Load and return data
            return try Data(contentsOf: fileURL)
        } catch {
            print("Error reading cached data: \(error)")
            return nil
        }
    }
    
    private func removeDataFromDisk(forKey key: String) {
        let fileURL = cacheDirectory.appendingPathComponent(key.md5)
        let metadataURL = cacheDirectory.appendingPathComponent("\(key.md5).metadata")
        
        // Remove files
        try? fileManager.removeItem(at: fileURL)
        try? fileManager.removeItem(at: metadataURL)
    }
}

// MARK: - Supporting Types

class CacheEntry: NSObject {
    let value: Any
    let expiryDate: Date
    
    init(value: Any, expiryDate: Date) {
        self.value = value
        self.expiryDate = expiryDate
        super.init()
    }
    
    var isExpired: Bool {
        return Date() > expiryDate
    }
}

struct CacheMetadata: Codable {
    let expiryDate: Date
    
    var isExpired: Bool {
        return Date() > expiryDate
    }
}

// MARK: - String Extension for MD5

extension String {
    var md5: String {
        let data = Data(self.utf8)
        let hash = data.withUnsafeBytes { pointer -> [UInt8] in
            var hash = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
            CC_MD5(pointer.baseAddress, CC_LONG(data.count), &hash)
            return hash
        }
        return hash.map { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - Import CommonCrypto for MD5
import CommonCrypto 