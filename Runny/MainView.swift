//
//  TabBar.swift
//  Runny
//
//  Created by Vinay Honne  on 1/21/26.
//

import SwiftUI

struct MainView: View {
    
    var body: some View {
        TabView{
            Tab() {
                HomeView()
            } label: {
                Text("Home")
            }
            Tab() {
                RecentsView()
            } label: {
                Text("Recents")
            }
            
            Tab() {
                AddActivityView()
            } label: {
                Text("+")
            }
            Tab(){
                OverviewView()
            } label: {
                Text("Overview")
            }
            Tab(){
                SettingsView()
            } label: {
                Text("Settings")
                }
            }
        }
    }


#Preview {
    MainView()
}
