//
//  RunnyApp.swift
//  Runny
//
//  Created by Vinay Honne  on 1/18/26.
//

import SwiftUI

@main
struct RunnyApp: App {

    @StateObject var userData = UserDataViewModel()
    @StateObject var auth = AuthViewModel()
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                if auth.isLoggedIn {
                    RunnyTabView()
                        .environmentObject(userData)
                        .environmentObject(auth)
                        .onAppear {
                            userData.loadFromServer()
                        }
                } else {
                    LoginView()
                        .environmentObject(auth)
                }

                SplashView()
                    .opacity(showSplash ? 1 : 0)
                    .animation(.easeOut(duration: 0.6), value: showSplash)
            }
            .preferredColorScheme(.light)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showSplash = false
                }
            }
        }
    }
}

struct SplashView: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Text("Runny")
                .font(.system(size: 36, weight: .bold))

            Text("Exercise for Everyone")
                .font(.system(size: 36, weight: .bold))
                .padding(.top, 40)

            Spacer()

            Text("Made with Love")
                .font(.system(size: 36, weight: .bold))

            Spacer()
                .frame(height: 80)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.white)
    }
}
