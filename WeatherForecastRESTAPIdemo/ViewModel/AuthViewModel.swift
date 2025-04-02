import Foundation
import Combine
import FirebaseAuth

@MainActor
class AuthViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isAuthenticated = false
    
    private let authRepository: AuthRepositoryProtocol
    
    init(authRepository: AuthRepositoryProtocol = AuthRepository()) {
        print("Initializing AuthViewModel")
        self.authRepository = authRepository
        
        // Initialize user state from repository
        refreshUserState()
    }
    
    // Refresh the user state from the repository
    func refreshUserState() {
        self.currentUser = authRepository.currentUser
        let newAuthState = authRepository.currentUser != nil
        
        if self.isAuthenticated != newAuthState {
            print("AuthViewModel changing authentication state from \(self.isAuthenticated) to \(newAuthState)")
            self.isAuthenticated = newAuthState
            
            // Force UI update by explicitly notifying SwiftUI
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
        
        print("AuthViewModel refreshed state - isAuthenticated: \(self.isAuthenticated)")
        if let user = self.currentUser {
            print("Current user ID: \(user.uid)")
        } else {
            print("No current user")
        }
    }
    
    func signIn(email: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        print("AuthViewModel: Attempting to sign in with email: \(email)")
        
        authRepository.signIn(email: email, password: password) { [weak self] result in
            guard let self = self else { return }
            
            // Ensure updates happen on the main thread
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let user):
                    self.currentUser = user
                    print("AuthViewModel: Sign in successful for user: \(user.uid)")
                    
                    // Update authentication state
                    self.isAuthenticated = true
                    
                    // Explicitly notify observers of the change
                    self.objectWillChange.send()
                    
                case .failure(let error):
                    self.errorMessage = self.formatErrorMessage(error)
                    print("AuthViewModel: Sign in error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func signUp(email: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        print("AuthViewModel: Attempting to sign up with email: \(email)")
        
        authRepository.signUp(email: email, password: password) { [weak self] result in
            guard let self = self else { return }
            
            // Ensure updates happen on the main thread
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let user):
                    self.currentUser = user
                    print("AuthViewModel: Sign up successful for user: \(user.uid)")
                    
                    // Update authentication state
                    self.isAuthenticated = true
                    
                    // Explicitly notify observers of the change
                    self.objectWillChange.send()
                    
                case .failure(let error):
                    self.errorMessage = self.formatErrorMessage(error)
                    print("AuthViewModel: Sign up error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func resetPassword(email: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = nil
        
        print("AuthViewModel: Attempting to send password reset for email: \(email)")
        
        authRepository.resetPassword(email: email) { [weak self] result in
            guard let self = self else { return }
            
            // Ensure updates happen on the main thread
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success:
                    print("AuthViewModel: Password reset email sent successfully")
                    completion(true)
                case .failure(let error):
                    self.errorMessage = self.formatErrorMessage(error)
                    print("AuthViewModel: Password reset error: \(error.localizedDescription)")
                    completion(false)
                }
            }
        }
    }
    
    func signOut() {
        print("AuthViewModel: Attempting to sign out")
        isLoading = true
        
        authRepository.signOut { [weak self] result in
            guard let self = self else { return }
            
            // Ensure updates happen on the main thread
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success:
                    print("AuthViewModel: Sign out successful")
                    
                    // Clear user state before changing authentication state
                    self.currentUser = nil
                    
                    // Update authentication state
                    self.isAuthenticated = false
                    
                    // Explicitly notify observers of state changes
                    self.objectWillChange.send()
                    
                    print("AuthViewModel: Authentication state now set to \(self.isAuthenticated)")
                    
                case .failure(let error):
                    self.errorMessage = self.formatErrorMessage(error)
                    print("AuthViewModel: Sign out error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // Helper method to convert Firebase auth errors to user-friendly messages
    private func formatErrorMessage(_ error: Error) -> String {
        let nsError = error as NSError
        let errorCode = nsError.code
        
        // Handle Firebase Auth errors based on their error codes directly
        // since AuthErrorCode structure can vary across Firebase versions
        switch errorCode {
        // Invalid email errors
        case 17007: // invalidEmail
            return "The email address is badly formatted. Please enter a valid email."
        
        // Password errors
        case 17009: // wrongPassword
            return "Incorrect password. Please try again."
        case 17026: // weakPassword
            return "Your password is too weak. Please use at least 6 characters with a mix of letters and numbers."
        
        // User account errors
        case 17011: // userNotFound
            return "No account found with this email. Please check your email or sign up."
        case 17008: // emailAlreadyInUse
            return "This email is already in use. Please use a different email or try signing in."
        case 17005: // userDisabled
            return "This account has been disabled. Please contact support."
        
        // Rate limiting and network errors
        case 17010: // tooManyRequests
            return "Too many unsuccessful login attempts. Please try again later or reset your password."
        case 17020: // networkError
            return "Network error. Please check your internet connection and try again."
        
        // Credential errors
        case 17004: // invalidCredential
            return "Invalid login credentials. Please check your email and password."
        case 17000: // operationNotAllowed
            return "This operation is not allowed. Please contact support."
        
        // If we don't have a specific message for this code, use the description
        default:
            if error.localizedDescription.contains("network") {
                return "Network connection error. Please check your internet and try again."
            } else if error.localizedDescription.contains("password") {
                return "Password error: \(error.localizedDescription)"
            } else if error.localizedDescription.contains("email") {
                return "Email error: \(error.localizedDescription)"
            } else {
                return "Authentication error: \(error.localizedDescription)"
            }
        }
    }
} 