//
//  AddActivityView.swift
//  Runny
//
//  Created by Vinay Honne  on 1/21/26.
//

import SwiftUI

struct AddActivityView: View {
    @Binding var showScreen: Bool
    @State private var selectedActivity: TypeActivity?
    
    //placeholder initializer bc modifying later
    @State private var activityStats = ActivityViewModel(currentActivity:
                                                            Activity(id: UUID().uuidString, userId: "", type: .running, distance: 0.0, time: 0.0, date: Date(), calories: 0, difficulty: .mid, averagePace: nil))
                                                            
    var body: some View {
        NavigationStack{
            HStack{
                Button{
                    showScreen = false
                }label: {
                    Image(systemName: "arrow.backward")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                        .foregroundStyle(Color.black)
                }
                Text("Start an Activity")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .padding()
                
                
            }
            
            
            Text("Choose an exercise")
                .font(Font.system(size: 20, weight: .bold))
                .foregroundStyle(Color.gray)
            
            Spacer()
                .frame(maxWidth: .infinity, maxHeight: 65)
            
            VStack{
                
                ActivityButton(
                    title: "Running",
                    icon: "figure.run",
                    isSelected: selectedActivity == .running
                ) {
                    selectedActivity = .running
                    activityStats.currentActivity.type = selectedActivity!
                    activityStats.startWorkout()
                }

                  ActivityButton(
                    title: "Walking",
                    icon: "figure.walk",
                    isSelected: selectedActivity == .walking
                ) {
                    selectedActivity = .walking
                    activityStats.currentActivity.type = selectedActivity!
                    activityStats.startWorkout()
                }
                
                ActivityButton(
                    title: "Biking",
                    icon: "figure.outdoor.cycle",
                    isSelected: selectedActivity == .biking
                ) {
                    selectedActivity = .biking
                    activityStats.currentActivity.type = selectedActivity!
                    activityStats.startWorkout()
                }
                
                ActivityButton(
                    title: "Weightlifting",
                    icon: "figure.strengthtraining.traditional",
                    isSelected: selectedActivity == .weightlifting
                ) {
                    selectedActivity = .weightlifting
                    activityStats.currentActivity.type = selectedActivity!
                    activityStats.startWorkout()
                }

            }
            
            Spacer()
            Text("Check in Now")
                .font(Font.system(size: 20, weight: .bold))
            
            
            
            
            NavigationLink {
                MapActivityView(activityStats: activityStats, selectedActivity: $selectedActivity, showScreen: $showScreen)
            } label: {
                ZStack{
                    Circle()
                        .stroke(.black, lineWidth: 4)
                        .fill(Color.yellow)
                        .frame(width: 100, height: 100)
                    
                        .shadow(color: Color.black.opacity(0.5), radius: 3)
                    
                    Text("Go")
                        .font(Font.system(size: 20, weight: .bold))
                        .foregroundStyle(Color.black)
                }
            }
            

            }
            }
        }

// MARK: - Activity Button Component
struct ActivityButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    private var backgroundColor: Color {
        isSelected ? Color(red: 255/255, green: 218/255, blue: 149/255) : Color.gray.opacity(0.3)
    }
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Rectangle()
                    .fill(backgroundColor)
                    .frame(maxWidth: .infinity, maxHeight: 90)
                    .cornerRadius(20)
                    .padding(20)
                
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 30))
                    Text(title)
                        .font(.system(size: 20, weight: .semibold))
                }
                .foregroundStyle(isSelected ? .black : .gray)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

