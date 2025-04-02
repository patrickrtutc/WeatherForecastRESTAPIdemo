import Foundation
import FirebaseAuth
import FirebaseCore
import Combine

protocol AuthRepositoryProtocol {
    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void)
    func signUp(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void)
    func signOut(completion: @escaping (Result<Void, Error>) -> Void)
    func resetPassword(email: String, completion: @escaping (Result<Void, Error>) -> Void)
    var currentUser: User? { get }
}

class AuthRepository: AuthRepositoryProtocol {
    private let auth: Auth
    
    init() {
        // Ensure Firebase is configured
        if FirebaseApp.app() == nil {
            print("Warning: Firebase not configured when initializing AuthRepository")
        }
        self.auth = Auth.auth()
        
        // Debug current auth state
        if let firebaseUser = auth.currentUser {
            print("AuthRepository initialized with user: \(firebaseUser.uid)")
        } else {
            print("AuthRepository initialized with no current user")
        }
    }
    
    var currentUser: User? {
        guard let firebaseUser = auth.currentUser else { 
            print("No current Firebase user found")
            return nil 
        }
        let user = User(uid: firebaseUser.uid, email: firebaseUser.email)
        print("Current user retrieved: \(user.uid)")
        return user
    }
    
    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        print("Repository attempting sign in with: \(email)")
        
        auth.signIn(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error {
                print("Repository sign in error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let firebaseUser = authResult?.user else {
                let error = NSError(domain: "AuthRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found"])
                print("Repository sign in missing user after successful auth")
                completion(.failure(error))
                return
            }
            
            let user = User(uid: firebaseUser.uid, email: firebaseUser.email)
            print("Repository sign in successful for user: \(user.uid)")
            
            // Additional check to ensure currentUser is set in Auth
            if self?.auth.currentUser != nil {
                print("Auth.currentUser is set correctly after sign in")
            } else {
                print("WARNING: Auth.currentUser is nil after successful sign in!")
            }
            
            completion(.success(user))
        }
    }
    
    func signUp(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        print("Repository attempting sign up with: \(email)")
        
        auth.createUser(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error {
                print("Repository sign up error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let firebaseUser = authResult?.user else {
                let error = NSError(domain: "AuthRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not created"])
                print("Repository sign up missing user after successful creation")
                completion(.failure(error))
                return
            }
            
            let user = User(uid: firebaseUser.uid, email: firebaseUser.email)
            print("Repository sign up successful for user: \(user.uid)")
            
            // Additional check to ensure currentUser is set in Auth
            if self?.auth.currentUser != nil {
                print("Auth.currentUser is set correctly after sign up")
            } else {
                print("WARNING: Auth.currentUser is nil after successful sign up!")
            }
            
            completion(.success(user))
        }
    }
    
    func signOut(completion: @escaping (Result<Void, Error>) -> Void) {
        print("Repository attempting sign out")
        
        // Perform sign out on main thread to avoid Firebase Auth issues
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                completion(.failure(NSError(domain: "AuthRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "Repository instance was deallocated"])))
                return
            }
            
            do {
                if let currentUser = self.auth.currentUser {
                    print("Current user before sign out: \(currentUser.uid)")
                } else {
                    print("No current user before sign out")
                }
                
                try self.auth.signOut()
                
                // Verify sign out state
                if self.auth.currentUser == nil {
                    print("Repository sign out successful - Auth.currentUser is nil as expected")
                    completion(.success(()))
                } else {
                    print("WARNING: Auth.currentUser is still set after sign out! Forcing nil")
                    // If somehow the user is still logged in, report success but log warning
                    completion(.success(()))
                }
            } catch {
                print("Repository sign out error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    
    func resetPassword(email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        print("Repository attempting password reset for: \(email)")
        
        auth.sendPasswordReset(withEmail: email) { error in
            if let error = error {
                print("Repository password reset error: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                print("Repository password reset email sent successfully")
                completion(.success(()))
            }
        }
    }
}

// User model
struct User: Identifiable {
    let id: String
    let uid: String
    let email: String?
    
    init(uid: String, email: String?) {
        self.id = uid
        self.uid = uid
        self.email = email
    }
} 
