//
//  APIService.swift
//  Runny
//

import Foundation

struct AuthResponse: Codable {
    let user: UserBasic
    let token: String
}

struct UserBasic: Codable {
    let id: String
    let name: String
    let email: String
}

struct CreateActivityRequest: Codable {
    let type: String
    let distance: Double?
    let time: Double
    let date: String
    let calories: Int
    let difficulty: String
}

enum APIError: Error, LocalizedError {
    case invalidURL
    case noToken
    case serverError(String)
    case decodingError

var errorDescription: String? {   
        switch self {
        case .invalidURL: return "Invalid URL"
        case .noToken: return "Not logged in"
        case .serverError(let msg): return msg
        case .decodingError: return "Failed to read server response"
        }
    }
}

struct APIService {

    static let baseURL = "http://54.164.165.243:8080/api"

    private static var token: String? { UserDefaults.standard.string(forKey: "authToken") }

    /// Throws `APIError.serverError` if the response status is not 2xx,
    /// extracting the `error` field from the JSON body when present.
    private static func checkStatus(_ response: URLResponse, data: Data) throws {
        guard let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) else { return }
        let message = (try? JSONDecoder().decode([String: String].self, from: data))?["error"]
            ?? HTTPURLResponse.localizedString(forStatusCode: http.statusCode)
        throw APIError.serverError(message)
    }

    private static func authorizedRequest(url: URL, method: String) throws -> URLRequest {
        guard let token = token else { throw APIError.noToken }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }

    /// Values from Xcode: Target → Info → add rows, or an `Info.plist` with these keys.
    /// Prefer **not** committing real secrets; use a local plist override or your backend for OAuth.
    private static func infoPlistString(forKey key: String) -> String? {
        let raw = (Bundle.main.object(forInfoDictionaryKey: key) as? String)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard let raw, !raw.isEmpty else { return nil }
        return raw
    }

    /// Whoop API calls use the **access token** from Whoop OAuth, not your Runny JWT.
    private static func whoopRequest(url: URL, method: String, whoopAccessToken: String) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(whoopAccessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }

    // MARK: - Auth

    static func register(name: String, email: String, password: String) async throws -> AuthResponse {
        guard let url = URL(string: "\(baseURL)/auth/register") else { throw APIError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["name": name, "email": email, "password": password])

        let (data, response) = try await URLSession.shared.data(for: request)
        try checkStatus(response, data: data)
        return try JSONDecoder().decode(AuthResponse.self, from: data)
    }

    static func login(email: String, password: String) async throws -> AuthResponse {
        guard let url = URL(string: "\(baseURL)/auth/login") else { throw APIError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["email": email, "password": password])

        let (data, response) = try await URLSession.shared.data(for: request)
        try checkStatus(response, data: data)
        return try JSONDecoder().decode(AuthResponse.self, from: data)
    }

    // MARK: - Activities

    static func fetchActivities() async throws -> [Activity] {
        guard let url = URL(string: "\(baseURL)/activities") else { throw APIError.invalidURL }
        let request = try authorizedRequest(url: url, method: "GET")
        let (data, response) = try await URLSession.shared.data(for: request)
        try checkStatus(response, data: data)
        return try JSONDecoder().decode([Activity].self, from: data)
    }

    static func createActivity(activity: Activity) async throws -> Activity {
        guard let url = URL(string: "\(baseURL)/activities") else { throw APIError.invalidURL }
        var request = try authorizedRequest(url: url, method: "POST")

        let formatter = ISO8601DateFormatter()
        let body = CreateActivityRequest(
            type: activity.type.rawValue,
            distance: activity.distance,
            time: activity.time,
            date: formatter.string(from: activity.date),
            calories: activity.calories,
            difficulty: activity.difficulty.rawValue
        )
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)
        try checkStatus(response, data: data)
        return try JSONDecoder().decode(Activity.self, from: data)
    }
 
    static func deleteActivity(id: String) async throws {
        guard let url = URL(string: "\(baseURL)/activities/\(id)") else { throw APIError.invalidURL }
        let request = try authorizedRequest(url: url, method: "DELETE")
        let (data, response) = try await URLSession.shared.data(for: request)
        try checkStatus(response, data: data)
    }

    // MARK: - User

    static func fetchUser() async throws -> User {
        guard let url = URL(string: "\(baseURL)/users/me") else { throw APIError.invalidURL }
        let request = try authorizedRequest(url: url, method: "GET")
        let (data, response) = try await URLSession.shared.data(for: request)
        try checkStatus(response, data: data)
        return try JSONDecoder().decode(User.self, from: data)
    }

    // Whoop OAuth app credentials — set in Target → Info as `WHOOP_CLIENT_ID` and `WHOOP_CLIENT_SECRET` (String).
    // Safer long term: keep the secret on your backend and finish OAuth there.
    static var whoopClientId: String? { infoPlistString(forKey: "WHOOP_CLIENT_ID") }
    static var whoopClientSecret: String? { infoPlistString(forKey: "WHOOP_CLIENT_SECRET") }

    /// Pass the **Whoop user access token** from OAuth (store in Keychain or UserDefaults like `authToken`).
    static func getStrainWhoop(whoopAccessToken: String) async throws -> Double {
        guard let url = URL(string: "https://api.whoop.com/v2/users/me/strain") else { throw APIError.invalidURL }
        let request = whoopRequest(url: url, method: "GET", whoopAccessToken: whoopAccessToken)
        let (data, response) = try await URLSession.shared.data(for: request)
        try checkStatus(response, data: data)
        return try JSONDecoder().decode(Double.self, from: data)
    }
}
