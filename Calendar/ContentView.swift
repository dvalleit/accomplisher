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