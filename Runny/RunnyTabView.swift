//
//  TabBar.swift
//  Runny
//
//  Created by Vinay Honne  on 1/21/26.
//

import SwiftUI

struct RunnyTabView: View {
    @State private var selectedTab = 0
    @State private var showScreen = false
    
    
    var body: some View {
        NavigationStack {
            
            TabView(selection: $selectedTab){
                
                Tab(value:0) {
                    HomeView()
                } label: {
                    Image(systemName: "house")
                    Text("Home")
                }
                
                
                Tab(value:1) {
                    RecentsView()
                } label: {
                    Image(systemName: "clock")
                    
                    Text("Recents")
                }
                
                
                Tab(value:2){
                    EmptyView()
                } label: {
                    Image(systemName: "plus")
                }
                
                
                Tab(value:3){
                    ChartView()
                } label: {
                    Image(systemName: "chart.xyaxis.line")
                    Text("Overview")
                }
                
                
                Tab(value:4){
                    SettingsView()
                } label: {
                    Image(systemName: "gear")
                    Text("Settings")
                }
            }
            
            .navigationBarBackButtonHidden(true)
            .onChange(of: selectedTab) { oldvalue, newvalue in
                if newvalue == 2 {
                    showScreen = true
                    
                    //this is to keep the tab from showing the empty screen
                    selectedTab = oldvalue
                    
                }
            }
            
            .fullScreenCover(isPresented: $showScreen){
                AddActivityView(showScreen: $showScreen)
            }
            .tint(.yellow)
            
        }
    }
    
}

#Preview {
    RunnyTabView()
        .environmentObject(UserDataViewModel())
}
