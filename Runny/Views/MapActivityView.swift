//
//  MapActivityView.swift
//  Runny
//
//  Created by Vinay Honne  on 2/5/26.
//

import SwiftUI
import CoreLocation

struct MapActivityView: View {
    
    @State private var locationManager = LocationManager()
    
    //observing changes on the class defined in the parent view, so use observed object
    @ObservedObject var activityStats: ActivityViewModel
    
    @Binding var selectedActivity: TypeActivity?
    @Binding var showScreen: Bool
    
    // Computed property that returns the activity name
    var currentActivity: String {
        switch selectedActivity {
        case .running:
            return "Running"
        case .biking:
            return "Biking"
        case .weightlifting:
            return "Weightlifting"
        case .walking:
            return "Walking"
        case .none:
            return "Unknown Activity"
        }
    }
    
    var body: some View {
            NavigationStack {
                ScrollView{
                    MapView(locationManager: locationManager)
                        .onChange(of: locationManager.totalDistance) { _, newDistance in
                            activityStats.updateDistance(newDistance)
                        }
                    
                    ZStack{
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color(red: 255/255, green: 218/255, blue: 149/255))
                            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                            .frame(maxWidth: .infinity, minHeight: 110)
                        
                        VStack{
                            Image(systemName: "clock.fill")
                                .font(Font.system(size: 20))
                                .padding(.bottom, 5)
                            Text(activityStats.formattedTime)
                                .fontWeight(.semibold)
                        }
                        .navigationBarBackButtonHidden(true)
                        
                    }
                    .padding(20)
                    
                    if selectedActivity == .running || selectedActivity == .biking || selectedActivity == .walking {
                        
                        ZStack{
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color(red: 255/255, green: 218/255, blue: 149/255))
                                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                                .frame(maxWidth: .infinity, minHeight: 110)
                            
                            HStack{
                                VStack{
                                    Image(systemName: "road.lanes")
                                        .font(Font.system(size: 20))
                                        .fontWeight(.bold)
                                        .padding(.bottom, 5)
                                    Text(activityStats.formattedDistance)
                                        .fontWeight(.semibold)
                                }
                                
                                Spacer()
                                    .frame(width: 60)
                                VStack{
                                    Image(systemName: "tachometer")
                                        .font(Font.system(size: 20))
                                        .fontWeight(.bold)
                                        .padding(.bottom, 5)
                                    Text(activityStats.formattedPace)
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                        .padding(20)
                    }
                    
                    Spacer()
                    
                    //add a confirmation
                    HStack(spacing: 30){
                        Button{
                            //pause button
                            if !activityStats.isPaused{
                                activityStats.pauseWorkout()
                            }
                            else{
                                activityStats.resumeWorkout()
                            }
                        } label: {
                            ZStack{
                                Circle()
                                    .stroke(.black, lineWidth: 4)
                                    .fill(Color.yellow)
                                    .frame(width: 100, height: 100)
                                
                                    .shadow(color: Color.black.opacity(0.5), radius: 3)
                                
                                Text(activityStats.isPaused ? "Resume" : "Pause")
                                    .font(Font.system(size: 20, weight: .bold))
                                    .foregroundStyle(Color.black)
                                    .navigationTitle(currentActivity)
                                
                            }
                        }
                        NavigationLink {
                            FinishedActivityView(activityStats: activityStats, showScreen: $showScreen)
                                .onAppear {
                                    if !locationManager.routeCoordinates.isEmpty {
                                        activityStats.routeCoordinates = locationManager.routeCoordinates
                                    }
                                    locationManager.stopUpdatingLocation()  
                                    activityStats.stopWorkout()
                                }
                        } label: {
                            ZStack{
                                Circle()
                                    .stroke(.black, lineWidth: 4)
                                    .fill(Color.yellow)
                                    .frame(width: 100, height: 100)
                                
                                    .shadow(color: Color.black.opacity(0.5), radius: 3)
                                
                                Text("Stop")
                                    .font(Font.system(size: 20, weight: .bold))
                                    .foregroundStyle(Color.black)
                                    .navigationTitle(currentActivity)
                                
                            }
                        }
                    
                        
                    }
                }
                
            }
        
        //ask for location
            .onAppear {
                locationManager.requestPermission()
                locationManager.resetDistance()
                locationManager.startUpdatingLocation()
            }
    }
}
