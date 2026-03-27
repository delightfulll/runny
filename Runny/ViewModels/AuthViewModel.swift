//
//  AuthViewModel.swift
//  Runny
//

import Foundation
import Combine

class AuthViewModel: ObservableObject {

    @Published var isLoggedIn: Bool = false
    @Published var errorMessage: String = ""
    @Published var isLoading: Bool = false

    private(set) var userId: String = ""
    private(set) var userName: String = ""
    private(set) var userEmail: String = ""

    init() {
        let token = UserDefaults.standard.string(forKey: "authToken")
        isLoggedIn = token != nil
        userId = UserDefaults.standard.string(forKey: "userId") ?? ""
        userName = UserDefaults.standard.string(forKey: "userName") ?? ""
        userEmail = UserDefaults.standard.string(forKey: "userEmail") ?? ""
    }

    func register(name: String, email: String, password: String) async {
        await MainActor.run { isLoading = true; errorMessage = "" }
        do {
            let response = try await APIService.register(name: name, email: email, password: password)
            saveSession(token: response.token, user: response.user)
        } catch {
            await MainActor.run { errorMessage = error.localizedDescription }
        }
        await MainActor.run { isLoading = false }
    }

    func login(email: String, password: String) async {
        await MainActor.run { isLoading = true; errorMessage = "" }
        do {
            let response = try await APIService.login(email: email, password: password)
            saveSession(token: response.token, user: response.user)
        } catch {
            await MainActor.run { errorMessage = error.localizedDescription }
        }
        await MainActor.run { isLoading = false }
    }

    func logout() {
        UserDefaults.standard.removeObject(forKey: "authToken")
        UserDefaults.standard.removeObject(forKey: "userId")
        UserDefaults.standard.removeObject(forKey: "userName")
        UserDefaults.standard.removeObject(forKey: "userEmail")
        isLoggedIn = false
        userId = ""
        userName = ""
        userEmail = ""
    }

    private func saveSession(token: String, user: UserBasic) {
        UserDefaults.standard.set(token, forKey: "authToken")
        UserDefaults.standard.set(user.id, forKey: "userId")
        UserDefaults.standard.set(user.name, forKey: "userName")
        UserDefaults.standard.set(user.email, forKey: "userEmail")
        userId = user.id
        userName = user.name
        userEmail = user.email
        isLoggedIn = true
    }
}
