import SwiftUI
import FirebaseAuth

struct AuthenticationView: View {
    @ObservedObject var viewModel: AuthViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        VStack {
            // App logo or title
            VStack(spacing: 10) {
                Image(systemName: "cloud.sun.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                
                Text("Weather Forecast")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Your personal weather companion")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 50)
            .padding(.bottom, 30)
            
            // Tab selector
            Picker("", selection: $selectedTab) {
                Text("Sign In").tag(0)
                Text("Sign Up").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal, 30)
            
            // Error message (moved to top of form for better visibility)
            if let errorMessage = viewModel.errorMessage {
                ErrorMessageView(message: errorMessage)
            }
            
            // Content based on selected tab
            if selectedTab == 0 {
                LoginView(viewModel: viewModel)
                    .transition(.opacity)
            } else {
                SignUpView(viewModel: viewModel)
                    .transition(.opacity)
            }
            
            // Loading indicator
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding(.top, 20)
            }
            
            Spacer()
            
            // Debug text to show authentication state
            #if DEBUG
            VStack(alignment: .leading, spacing: 4) {
                Text("Debug Info:")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text("Auth State: \(viewModel.isAuthenticated ? "Authenticated" : "Not Authenticated")")
                    .font(.caption)
                    .foregroundColor(viewModel.isAuthenticated ? .green : .red)
                if let user = viewModel.currentUser {
                    Text("User ID: \(user.uid)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 30)
            .padding(.bottom, 10)
            #endif
        }
        .padding()
        .background(Color(.systemBackground))
        .onChange(of: viewModel.isAuthenticated) { authenticated in
            print("Authentication view detected auth state change: \(authenticated)")
        }
        .onAppear {
            print("Authentication view appeared - current auth state: \(viewModel.isAuthenticated)")
            
            // Force refresh user state when view appears
            viewModel.refreshUserState()
            print("Auth view refreshed state: \(viewModel.isAuthenticated)")
        }
        .id("AuthView-\(viewModel.isAuthenticated)") // Force view recreation when auth state changes
    }
}

struct ErrorMessageView: View {
    let message: String
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
            
            Text(message)
                .foregroundColor(.red)
                .font(.subheadline)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(8)
        .padding(.horizontal, 30)
        .padding(.vertical, 10)
        .transition(.opacity)
        .animation(.easeInOut, value: message)
    }
}

struct LoginView: View {
    @ObservedObject var viewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showForgotPassword = false
    @State private var resetEmail = ""
    @State private var showResetConfirmation = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Email field with validation icon
            HStack {
                Image(systemName: "envelope.fill")
                    .foregroundColor(.gray)
                    .frame(width: 20)
                
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .textContentType(.emailAddress)
                    .autocorrectionDisabled()
                
                if !email.isEmpty {
                    Image(systemName: isValidEmail(email) ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(isValidEmail(email) ? .green : .red)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            
            // Password field with secure toggle
            HStack {
                Image(systemName: "lock.fill")
                    .foregroundColor(.gray)
                    .frame(width: 20)
                
                SecureField("Password", text: $password)
                    .textContentType(.password)
                    .autocorrectionDisabled()
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            
            Button(action: {
                print("Sign in button tapped with email: \(email)")
                viewModel.signIn(email: email, password: password)
            }) {
                Text("Sign In")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isFormValid ? Color.blue : Color.blue.opacity(0.5))
                    .cornerRadius(8)
            }
            .disabled(!isFormValid || viewModel.isLoading)
            
            Button("Forgot Password?") {
                resetEmail = email
                showForgotPassword = true
            }
            .font(.subheadline)
            .foregroundColor(.blue)
            .padding(.top, 10)
            
            // Help text for sign in
            Text("Enter your email and password to access your weather forecast")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 10)
        }
        .padding(.horizontal, 30)
        .padding(.top, 20)
        .alert("Reset Password", isPresented: $showForgotPassword) {
            TextField("Enter your email", text: $resetEmail)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            
            Button("Cancel", role: .cancel) { }
            Button("Reset") {
                viewModel.resetPassword(email: resetEmail) { success in
                    if success {
                        showResetConfirmation = true
                    }
                }
            }
        }
        .alert("Password Reset Email Sent", isPresented: $showResetConfirmation) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Check your email for instructions to reset your password.")
        }
    }
    
    private var isFormValid: Bool {
        isValidEmail(email) && !password.isEmpty
    }
    
    // Simple email validation
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}

struct SignUpView: View {
    @ObservedObject var viewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var passwordsDoNotMatch = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Email field with validation icon
            HStack {
                Image(systemName: "envelope.fill")
                    .foregroundColor(.gray)
                    .frame(width: 20)
                
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .textContentType(.emailAddress)
                    .autocorrectionDisabled()
                
                if !email.isEmpty {
                    Image(systemName: isValidEmail(email) ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(isValidEmail(email) ? .green : .red)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            
            // Password field
            HStack {
                Image(systemName: "lock.fill")
                    .foregroundColor(.gray)
                    .frame(width: 20)
                
                SecureField("Password", text: $password)
                    .textContentType(.newPassword)
                    .autocorrectionDisabled()
                
                if !password.isEmpty {
                    Image(systemName: isStrongPassword(password) ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(isStrongPassword(password) ? .green : .red)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            
            // Password strength indicator
            if !password.isEmpty && !isStrongPassword(password) {
                Text("Password should be at least 6 characters with letters and numbers")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
            
            // Confirm password field
            HStack {
                Image(systemName: "lock.fill")
                    .foregroundColor(.gray)
                    .frame(width: 20)
                
                SecureField("Confirm Password", text: $confirmPassword)
                    .textContentType(.newPassword)
                    .autocorrectionDisabled()
                
                if !confirmPassword.isEmpty {
                    Image(systemName: password == confirmPassword ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(password == confirmPassword ? .green : .red)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .onChange(of: confirmPassword) { _ in
                passwordsDoNotMatch = password != confirmPassword && !confirmPassword.isEmpty
            }
            
            if passwordsDoNotMatch {
                Text("Passwords do not match")
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            Button(action: {
                print("Sign up button tapped with email: \(email)")
                if password == confirmPassword {
                    viewModel.signUp(email: email, password: password)
                } else {
                    passwordsDoNotMatch = true
                }
            }) {
                Text("Create Account")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isFormValid ? Color.blue : Color.blue.opacity(0.5))
                    .cornerRadius(8)
            }
            .disabled(!isFormValid || viewModel.isLoading)
            
            // Help text for sign up
            Text("Create an account to save your favorite locations and personalize your weather experience")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 10)
        }
        .padding(.horizontal, 30)
        .padding(.top, 20)
    }
    
    private var isFormValid: Bool {
        isValidEmail(email) && isStrongPassword(password) && password == confirmPassword
    }
    
    // Simple email validation
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    // Password strength validation
    private func isStrongPassword(_ password: String) -> Bool {
        return password.count >= 6
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView(viewModel: AuthViewModel())
    }
} 