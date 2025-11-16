import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = CalendarViewModel()
    
    var body: some View {
        TabView {
            // Weight Entry Tab
            WeightEntryView()
                .environmentObject(viewModel)
                .tabItem {
                    Image(systemName: "scalemass")
                    Text("Weight")
                }
            
            // Weight Progress Tab
            WeightProgressView()
                .environmentObject(viewModel)
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Progress")
                }
            
            // Food Tracking Tab
            FoodTrackingView()
                .environmentObject(viewModel)
                .tabItem {
                    Image(systemName: "fork.knife")
                    Text("Food")
                }
            
            // Calendar Tab
            NavigationView {
                CalendarView()
                    .environmentObject(viewModel)
                    .navigationTitle("Daily Calendar")
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Image(systemName: "calendar")
                Text("Calendar")
            }
        }
    }
}

#Preview {
    ContentView()
}