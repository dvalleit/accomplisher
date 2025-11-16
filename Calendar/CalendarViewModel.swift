import Foundation
import SwiftUI

class CalendarViewModel: ObservableObject {
    @Published var currentDate = Date()
    @Published var completedDays: Set<String> = []
    @Published var initialWeight: Double?
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    var monthYearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }
    
    init() {
        loadCompletedDays()
        loadInitialWeight()
    }
    
    func daysInMonth() -> [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentDate),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfYear, for: monthInterval.start),
              let monthLastWeek = calendar.dateInterval(of: .weekOfYear, for: monthInterval.end - 1) else {
            return []
        }
        
        var days: [Date] = []
        var date = monthFirstWeek.start
        
        while date < monthLastWeek.end {
            days.append(date)
            date = calendar.date(byAdding: .day, value: 1, to: date)!
        }
        
        return days
    }
    
    func isCurrentMonth(_ date: Date) -> Bool {
        calendar.isDate(date, equalTo: currentDate, toGranularity: .month)
    }
    
    func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }
    
    func isDayCompleted(_ date: Date) -> Bool {
        let dateString = dateFormatter.string(from: date)
        return completedDays.contains(dateString)
    }
    
    func toggleDayCompletion(_ date: Date) {
        let dateString = dateFormatter.string(from: date)
        
        if completedDays.contains(dateString) {
            completedDays.remove(dateString)
        } else {
            completedDays.insert(dateString)
        }
        
        saveCompletedDays()
    }
    
    func goToPreviousMonth() {
        currentDate = calendar.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
    }
    
    func goToNextMonth() {
        currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
    }
    
    func goToToday() {
        currentDate = Date()
    }
    
    func setInitialWeight(_ weight: Double) {
        initialWeight = weight
        saveInitialWeight()
    }
    
    private func saveInitialWeight() {
        if let weight = initialWeight {
            UserDefaults.standard.set(weight, forKey: "InitialWeight")
        }
    }
    
    private func loadInitialWeight() {
        let weight = UserDefaults.standard.double(forKey: "InitialWeight")
        if weight > 0 {
            initialWeight = weight
        }
    }
    
    private func saveCompletedDays() {
        let data = Array(completedDays)
        UserDefaults.standard.set(data, forKey: "CompletedDays")
    }
    
    private func loadCompletedDays() {
        if let data = UserDefaults.standard.array(forKey: "CompletedDays") as? [String] {
            completedDays = Set(data)
        }
    }
}