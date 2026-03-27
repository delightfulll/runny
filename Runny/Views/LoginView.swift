//
//  LoginView.swift
//  Runny
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var auth: AuthViewModel

    @State private var isRegistering = false
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    VStack(spacing: 4) {
                        Text("Runny")
                            .font(.system(size: 42, weight: .bold))
                        Text(isRegistering ? "Create an account" : "Welcome back")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 60)

                    VStack(spacing: 14) {
                        if isRegistering {
                            InputField(placeholder: "Name", text: $name)
                        }
                        InputField(placeholder: "Email", text: $email)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                        InputField(placeholder: "Password", text: $password, isSecure: true)
                    }
                    .padding(.horizontal)

                    if !auth.errorMessage.isEmpty {
                        Text(auth.errorMessage)
                            .foregroundStyle(.red)
                            .font(.subheadline)
                            .padding(.horizontal)
                    }

                    Button {
                        Task {
                            if isRegistering {
                                await auth.register(name: name, email: email, password: password)
                            } else {
                                await auth.login(email: email, password: password)
                            }
                        }
                    } label: {
                        Group {
                            if auth.isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text(isRegistering ? "Sign Up" : "Log In")
                                    .font(.title3.weight(.bold))
                                    .foregroundStyle(.white)
                            }
                        }
                        .frame(maxWidth: .infinity, minHeight: 52)
                        .background(
                            LinearGradient(colors: [.orange, .red], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .clipShape(Capsule())
                        .shadow(color: .orange.opacity(0.3), radius: 8, x: 0, y: 6)
                    }
                    .padding(.horizontal)
                    .disabled(auth.isLoading)

                    Button {
                        withAnimation { isRegistering.toggle() }
                        auth.errorMessage = ""
                    } label: {
                        Text(isRegistering ? "Already have an account? Log In" : "Don't have an account? Sign Up")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}

struct InputField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false

    var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .autocorrectionDisabled()
    }
}
