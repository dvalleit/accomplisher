import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var viewModel: CalendarViewModel
    
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    let weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var body: some View {
        VStack(spacing: 20) {
            // Month navigation header
            HStack {
                Button(action: viewModel.goToPreviousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Text(viewModel.monthYearFormatter.string(from: viewModel.currentDate))
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: viewModel.goToNextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            
            // Weekday headers
            HStack {
                ForEach(weekdays, id: \.self) { weekday in
                    Text(weekday)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
            
            // Calendar grid
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(viewModel.daysInMonth(), id: \.self) { date in
                    DayView(date: date)
                        .environmentObject(viewModel)
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Today button
            Button(action: viewModel.goToToday) {
                HStack {
                    Image(systemName: "calendar")
                    Text("Go to Today")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
            }
            .padding(.bottom)
        }
        .background(Color(.systemBackground))
    }
}

#Preview {
    CalendarView()
        .environmentObject(CalendarViewModel())
}