//
//  SettingsView.swift
//  Runny
//
//  Created by Vinay Honne  on 1/21/26.
//
import SwiftUI

struct SettingsView: View {
    // MARK: - State Variables (The data behind the forms)
    @State private var name: String = "Vinay Honne"
    @State private var age: String = "26"
    @State private var weight: String = "75"
    @State private var selectedUnit: UnitSystem = .metric
    @State private var dailyStepGoal: Double = 10000
    
    @State private var notifyWorkout: Bool = true
    @State private var notifyHydration: Bool = false
    @State private var syncHealthKit: Bool = true
    @State private var isDarkMode: Bool = false
    
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var userData: UserDataViewModel

    // Enum for Unit Picker
    enum UnitSystem: String, CaseIterable, Identifiable {
        case metric = "Metric (kg, km)"
        case imperial = "Imperial (lbs, mi)"
        var id: String { self.rawValue }
    }

    var body: some View {
        NavigationStack {
            Form {
                // MARK: - SECTION 1: Profile Header
                Section {
                    HStack(spacing: 15) {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.blue) // Brand color
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(auth.userName)
                                .font(.headline)
                            Text("Pro Member")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.15))
                                .foregroundColor(.blue)
                                .cornerRadius(4)
                        }
                    }
                    .padding(.vertical, 4)
                }

                // MARK: - SECTION 2: Body Stats
                Section(header: Text("My Stats")) {
                    HStack {
                        Image(systemName: "figure.arms.open")
                            .foregroundColor(.orange)
                            .frame(width: 20)
                        TextField("Name", text: $name)
                    }
                    
                    HStack {
                        Image(systemName: "scalemass")
                            .foregroundColor(.orange)
                            .frame(width: 20)
                        TextField("Weight", text: $weight)
                            .keyboardType(.decimalPad)
                        Spacer()
                        Text(selectedUnit == .metric ? "kg" : "lbs")
                            .foregroundColor(.gray)
                    }
                }

                // MARK: - SECTION 3: Goals & Units
                Section(header: Text("Goals & Preferences")) {
                    // Unit Picker
                    Picker(selection: $selectedUnit, label: Label("Units", systemImage: "ruler")) {
                        ForEach(UnitSystem.allCases) { unit in
                            Text(unit.rawValue).tag(unit)
                        }
                    }
                    .pickerStyle(.menu) // or .navigationLink for a new page
                    
                    // Step Goal Stepper
                    VStack(alignment: .leading) {
                        HStack {
                            Image(systemName: "flame.fill")
                                .foregroundColor(.red)
                            Text("Daily Step Goal")
                            Spacer()
                            Text("\(Int(dailyStepGoal))")
                                .bold()
                                .foregroundColor(.blue)
                        }
                        Slider(value: $dailyStepGoal, in: 1000...20000, step: 500)
                    }
                    .padding(.vertical, 4)
                }

                // MARK: - SECTION 4: Notifications
                Section(header: Text("Notifications")) {
                    Toggle(isOn: $notifyWorkout) {
                        Label("Workout Reminders", systemImage: "bell.badge.fill")
                            .foregroundColor(.purple)
                    }
                    
                    Toggle(isOn: $notifyHydration) {
                        Label("Hydration Alerts", systemImage: "drop.fill")
                            .foregroundColor(.cyan)
                    }
                }

                // MARK: - SECTION 5: Integrations
                Section(header: Text("Integrations"), footer: Text("Allowing Apple Health access ensures your calorie burn is accurate.")) {
                    Toggle(isOn: $syncHealthKit) {
                        Label("Apple Health Sync", systemImage: "heart.text.square.fill")
                            .foregroundColor(.pink)
                    }
                }

                // MARK: - SECTION 6: Account Actions
                Section {
                    Button(action: {
                        auth.logout()
                    }) {
                        Text("Log Out")
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
            .navigationTitle("Settings")
            // Optional: Add a toolbar button
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        // Handle save action
                    }
                }
            }
        }
    }
}

// MARK: - Preview
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
