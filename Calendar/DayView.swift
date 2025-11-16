import SwiftUI

struct DayView: View {
    let date: Date
    @EnvironmentObject var viewModel: CalendarViewModel
    
    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(backgroundColor)
                .frame(height: 50)
            
            if viewModel.isDayCompleted(date) {
                // Big red X covering the full block
                Image(systemName: "xmark")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // Day number when not completed
                Text(dayFormatter.string(from: date))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(textColor)
            }
        }
        .onTapGesture {
            // Only allow interaction with current month days
            if viewModel.isCurrentMonth(date) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    viewModel.toggleDayCompletion(date)
                }
            }
        }
        .opacity(viewModel.isCurrentMonth(date) ? 1.0 : 0.3)
    }
    
    private var backgroundColor: Color {
        if viewModel.isToday(date) {
            return .blue.opacity(0.2)
        } else if viewModel.isDayCompleted(date) {
            return .green.opacity(0.1)
        } else {
            return .gray.opacity(0.1)
        }
    }
    
    private var textColor: Color {
        if !viewModel.isCurrentMonth(date) {
            return .secondary
        } else if viewModel.isToday(date) {
            return .blue
        } else {
            return .primary
        }
    }
    
    private var checkmarkColor: Color {
        if viewModel.isToday(date) {
            return .blue
        } else {
            return .green
        }
    }
}

#Preview {
    DayView(date: Date())
        .environmentObject(CalendarViewModel())
        .padding()
}