import Foundation
import Combine

class APIClient: APIClientProtocol {
    private let session: URLSession
    private var cancellables = Set<AnyCancellable>()
    private let decoder: JSONDecoder
    private let retryCount: Int
    private let retryDelay: TimeInterval
    
    init(
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder(),
        retryCount: Int = 3,
        retryDelay: TimeInterval = 1.0
    ) {
        self.session = session
        self.decoder = decoder
        self.retryCount = retryCount
        self.retryDelay = retryDelay
    }
    
    func request<T: Decodable>(endpoint: APIEndpoint) -> AnyPublisher<T, APIError> {
        guard endpoint.asURLRequest() != nil else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        return requestData(endpoint: endpoint)
            .decode(type: T.self, decoder: decoder)
            .mapError { error -> APIError in
                if let apiError = error as? APIError {
                    return apiError
                }
                return APIError.decodingFailed
            }
            .eraseToAnyPublisher()
    }
    
    func requestData(endpoint: APIEndpoint) -> AnyPublisher<Data, APIError> {
        guard let request = endpoint.asURLRequest() else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }
                
                // Check status code
                switch httpResponse.statusCode {
                case 200...299:
                    return data
                case 401:
                    throw APIError.unauthorized
                case 400...499:
                    throw APIError.requestFailed(statusCode: httpResponse.statusCode)
                case 500...599:
                    throw APIError.serverError(String(data: data, encoding: .utf8) ?? "Unknown server error")
                default:
                    throw APIError.unknown
                }
            }
            .mapError { error -> APIError in
                if let apiError = error as? APIError {
                    return apiError
                }
                
                return APIError.networkError(error.localizedDescription)
            }
            // Standard retry - will retry any error up to retryCount times
            .retry(retryCount)
            .eraseToAnyPublisher()
    }
    
    func cancelAllRequests() {
        cancellables.removeAll()
    }
}

// MARK: - Custom Retry Extension
// If you need the advanced retry functionality, add this extension:

extension Publisher {
    func retryWithDelay<S>(
        _ retries: Int,
        delay: TimeInterval,
        scheduler: S,
        shouldRetry: @escaping (Failure) -> Bool = { _ in true }
    ) -> AnyPublisher<Output, Failure> where S: Scheduler {
        self.catch { error -> AnyPublisher<Output, Failure> in
            // If we shouldn't retry or we've used all retries, fail
            guard shouldRetry(error), retries > 0 else {
                return Fail(error: error).eraseToAnyPublisher()
            }
            
            // Otherwise, delay and retry
            return Just(())
                .delay(for: .seconds(delay), scheduler: scheduler)
                .flatMap { _ in
                    self.retryWithDelay(retries - 1, delay: delay, scheduler: scheduler, shouldRetry: shouldRetry)
                }
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
} 
