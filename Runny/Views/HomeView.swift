//
//  ContentView.swift
//  Runny
//
//  Created by Vinay Honne  on 1/18/26.
//

import SwiftUI


//use a struct to create a new copy every time

//classes are used via reference in which it is shared (like google docs)
struct User {
    let name: String
    let yesterdayStrain: Int
    let dailyStreak: Int
    let recovery: Int
}

struct HomeView: View {
    var user = User(name: "Vinay", yesterdayStrain: 12, dailyStreak: 6, recovery: 10)
    var date: Date = Date()
    var body: some View {
        VStack {
            Text("Ready to win, \(user.name)?")
                .font(Font.largeTitle.bold())
                .padding(15)
            
            Text(date.formatted(Date.FormatStyle()
                .month(.abbreviated)
                .day(.twoDigits)
                .weekday(.abbreviated)))
            .font(.title.bold())
            Spacer()
            
            //strain rectangle
            ZStack{
                Rectangle()
                    .fill(Color(red: 255/255, green: 218/255, blue: 149/255))
                    .frame(width: .infinity, height: 120)
                    .cornerRadius(20)
                    .padding(20)
                
                Text("Yesterday's strain")
                    .font(Font.headline)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment:.init(horizontal: .leading, vertical: .top))
                    .padding(60)
                Text("Recovery")
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment:.init(horizontal: .trailing, vertical: .top))
                    .padding(60)
                ZStack{
                    Circle()
                        .fill(Color.green)
                        .frame(width: 50, height: 50)
                        .padding(10)
                    Text("\(user.yesterdayStrain)")
                        .padding(.trailing)
                }
                
                ZStack{
                    Circle()
                        .fill(Color.red)
                        .frame(width: 50, height: 50)
                        .padding(10)
                    Text("\(user.recovery)")
                        .padding(.trailing)
                }
                }
            }
            //streak rectangle
            ZStack{
                Rectangle()
                    .fill(Color(red: 255/255, green: 218/255, blue: 149/255))
                    .frame(width: .infinity, height: 120)
                    .cornerRadius(20)
                    .padding(20)
                Text("Daily Streak")
                    .font(Font.headline)
            }
            //recent activity rectangle
            ZStack{
                Rectangle()
                    .fill(Color(red: 255/255, green: 218/255, blue: 149/255))
                    .frame(width: .infinity, height: 210)
                    .cornerRadius(20)
                    .padding(20)
                Text("Most Recent Activity")
                    .font(Font.headline)
            }
            
            
            Spacer()
            Spacer()
        }
    }

#Preview {
    HomeView()
}
