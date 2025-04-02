import Foundation
import Combine

protocol APIClientProtocol {
    /// Perform a network request and return a publisher with the decoded response
    func request<T: Decodable>(endpoint: APIEndpoint) -> AnyPublisher<T, APIError>
    
    /// Perform a network request that returns raw Data
    func requestData(endpoint: APIEndpoint) -> AnyPublisher<Data, APIError>
    
    /// Cancel all ongoing requests
    func cancelAllRequests()
}

/// Defines an API endpoint with all necessary information to make a request
struct APIEndpoint {
    let baseURL: URL
    let path: String
    let method: HTTPMethod
    let queryItems: [URLQueryItem]?
    let headers: [String: String]?
    let body: Data?
    let cachePolicy: URLRequest.CachePolicy
    let timeoutInterval: TimeInterval
    
    init(
        baseURL: URL,
        path: String,
        method: HTTPMethod = .get,
        queryItems: [URLQueryItem]? = nil,
        headers: [String: String]? = nil,
        body: Data? = nil,
        cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy,
        timeoutInterval: TimeInterval = 30.0
    ) {
        self.baseURL = baseURL
        self.path = path
        self.method = method
        self.queryItems = queryItems
        self.headers = headers
        self.body = body
        self.cachePolicy = cachePolicy
        self.timeoutInterval = timeoutInterval
    }
    
    func asURLRequest() -> URLRequest? {
        guard var urlComponents = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: true) else {
            return nil
        }
        
        if let queryItems = queryItems {
            urlComponents.queryItems = queryItems
        }
        
        guard let url = urlComponents.url else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.cachePolicy = cachePolicy
        request.timeoutInterval = timeoutInterval
        
        // Set default headers
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // Set custom headers
        if let headers = headers {
            for (key, value) in headers {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        request.httpBody = body
        
        return request
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
} 