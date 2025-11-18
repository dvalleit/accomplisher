import Foundation
import SwiftUI

struct WeightEntry {
    let date: Date
    let weight: Double
}

struct FoodEntry {
    let id: UUID
    let name: String
    let timestamp: Date
    
    init(name: String, timestamp: Date) {
        self.id = UUID()
        self.name = name
        self.timestamp = timestamp
    }
    
    init(id: UUID, name: String, timestamp: Date) {
        self.id = id
        self.name = name
        self.timestamp = timestamp
    }
}

class CalendarViewModel: ObservableObject {
    @Published var currentDate = Date()
    @Published var completedDays: Set<String> = []
    @Published var initialWeight: Double?
    @Published var dailyWeights: [String: Double] = [:]
    @Published var dailyFoodEntries: [String: [FoodEntry]] = [:]
    
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
        print("CalendarViewModel initializing...")
        loadCompletedDays()
        loadInitialWeight()
        loadDailyWeights()
        loadDailyFoodEntries()
        print("CalendarViewModel initialization complete")
        print("Initial weight: \(initialWeight ?? 0)")
        print("Daily weights count: \(dailyWeights.count)")
        print("Daily food entries count: \(dailyFoodEntries.count)")
        print("Completed days count: \(completedDays.count)")
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
    
    func addDailyWeight(weight: Double, date: Date = Date()) {
        let dateString = dateFormatter.string(from: date)
        dailyWeights[dateString] = weight
        saveDailyWeights()
    }
    
    func getWeightForDate(_ date: Date) -> Double? {
        let dateString = dateFormatter.string(from: date)
        return dailyWeights[dateString]
    }
    
    var sortedWeightEntries: [WeightEntry] {
        return dailyWeights.compactMap { (dateString, weight) in
            guard let date = dateFormatter.date(from: dateString) else { return nil }
            return WeightEntry(date: date, weight: weight)
        }.sorted { $0.date < $1.date }
    }
    
    var chartWeightEntries: [WeightEntry] {
        var entries = sortedWeightEntries
        
        // Add initial weight as first entry if we have daily weights and initial weight is set
        if let initialWeight = initialWeight, !entries.isEmpty {
            let firstEntryDate = entries[0].date
            let initialWeightDate = Calendar.current.date(byAdding: .day, value: -1, to: firstEntryDate) ?? firstEntryDate
            let initialEntry = WeightEntry(date: initialWeightDate, weight: initialWeight)
            entries.insert(initialEntry, at: 0)
        }
        
        return entries
    }
    
    var latestWeight: Double? {
        return sortedWeightEntries.last?.weight
    }
    
    // MARK: - Food Tracking Methods
    func addFoodEntry(name: String, date: Date = Date()) {
        let dateString = dateFormatter.string(from: date)
        let foodEntry = FoodEntry(name: name, timestamp: date)
        
        if dailyFoodEntries[dateString] == nil {
            dailyFoodEntries[dateString] = []
        }
        dailyFoodEntries[dateString]?.append(foodEntry)
        saveDailyFoodEntries()
    }
    
    func getFoodEntriesForDate(_ date: Date) -> [FoodEntry] {
        let dateString = dateFormatter.string(from: date)
        return dailyFoodEntries[dateString] ?? []
    }
    
    func deleteFoodEntry(_ entry: FoodEntry) {
        for (dateString, entries) in dailyFoodEntries {
            if let index = entries.firstIndex(where: { $0.id == entry.id }) {
                dailyFoodEntries[dateString]?.remove(at: index)
                if dailyFoodEntries[dateString]?.isEmpty == true {
                    dailyFoodEntries[dateString] = nil
                }
                saveDailyFoodEntries()
                break
            }
        }
    }
    
    private func saveInitialWeight() {
        if let weight = initialWeight {
            UserDefaults.standard.set(weight, forKey: "InitialWeight")
        }
    }
    
    private func loadInitialWeight() {
        if UserDefaults.standard.object(forKey: "InitialWeight") != nil {
            let weight = UserDefaults.standard.double(forKey: "InitialWeight")
            initialWeight = weight
        }
    }
    
    func clearAllData() {
        // Clear all data
        initialWeight = nil
        dailyWeights.removeAll()
        dailyFoodEntries.removeAll()
        completedDays.removeAll()
        
        // Clear UserDefaults
        UserDefaults.standard.removeObject(forKey: "InitialWeight")
        UserDefaults.standard.removeObject(forKey: "DailyWeights")
        UserDefaults.standard.removeObject(forKey: "DailyFoodEntries")
        UserDefaults.standard.removeObject(forKey: "CompletedDays")
    }
    
    private func saveDailyWeights() {
        do {
            let data = try JSONEncoder().encode(dailyWeights)
            UserDefaults.standard.set(data, forKey: "DailyWeights")
            print("Daily weights saved successfully")
        } catch {
            print("Error saving daily weights: \(error)")
        }
    }
    
    private func loadDailyWeights() {
        guard let data = UserDefaults.standard.data(forKey: "DailyWeights") else {
            print("No daily weights data found")
            return
        }
        
        do {
            dailyWeights = try JSONDecoder().decode([String: Double].self, from: data)
            print("Daily weights loaded successfully")
        } catch {
            print("Error loading daily weights: \(error)")
        }
    }
    
    private func saveDailyFoodEntries() {
        // Convert FoodEntry to a serializable format
        let serializableEntries = dailyFoodEntries.mapValues { entries in
            entries.map { entry in
                [
                    "id": entry.id.uuidString,
                    "name": entry.name,
                    "timestamp": entry.timestamp.timeIntervalSince1970
                ] as [String: Any]
            }
        }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: serializableEntries)
            UserDefaults.standard.set(data, forKey: "DailyFoodEntries")
            print("Food entries saved successfully")
        } catch {
            print("Error saving food entries: \(error)")
        }
    }
    
    private func loadDailyFoodEntries() {
        guard let data = UserDefaults.standard.data(forKey: "DailyFoodEntries") else {
            print("No food entries data found")
            return
        }
        
        do {
            guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: [[String: Any]]] else {
                print("Invalid food entries data format")
                return
            }
            
            var loadedEntries: [String: [FoodEntry]] = [:]
            
            for (dateString, entriesArray) in jsonObject {
                var dayEntries: [FoodEntry] = []
                
                for entryDict in entriesArray {
                    if let idString = entryDict["id"] as? String,
                       let id = UUID(uuidString: idString),
                       let name = entryDict["name"] as? String,
                       let timestamp = entryDict["timestamp"] as? TimeInterval {
                        let foodEntry = FoodEntry(id: id, name: name, timestamp: Date(timeIntervalSince1970: timestamp))
                        dayEntries.append(foodEntry)
                    }
                }
                
                if !dayEntries.isEmpty {
                    loadedEntries[dateString] = dayEntries
                }
            }
            
            dailyFoodEntries = loadedEntries
            print("Food entries loaded successfully")
        } catch {
            print("Error loading food entries: \(error)")
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