import SwiftUI

struct FoodTrackingView: View {
    @EnvironmentObject var viewModel: CalendarViewModel
    @State private var selectedDate = Date()
    @State private var showingAddFood = false
    
    private var foodEntriesForSelectedDate: [FoodEntry] {
        viewModel.getFoodEntriesForDate(selectedDate)
    }
    
    private var totalCaloriesForDay: Int {
        foodEntriesForSelectedDate.count
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Date picker
                VStack(alignment: .leading, spacing: 10) {
                    Text("Select Date")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(CompactDatePickerStyle())
                        .onChange(of: selectedDate) { _ in
                            // Trigger UI refresh when date changes
                        }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(15)
                
                // Daily summary
                HStack {
                    VStack(alignment: .leading) {
                        Text("Food Items")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("\(totalCaloriesForDay)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("Entries")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("\(foodEntriesForSelectedDate.count)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(15)
                
                // Food entries list
                if foodEntriesForSelectedDate.isEmpty {
                    VStack(spacing: 15) {
                        Image(systemName: "fork.knife")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text("No food items logged")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("Tap the + button to add your first meal")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    List {
                        ForEach(foodEntriesForSelectedDate.sorted(by: { $0.timestamp < $1.timestamp }), id: \.id) { entry in
                            FoodEntryRow(entry: entry) {
                                viewModel.deleteFoodEntry(entry)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Food Tracking")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddFood = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddFood) {
            AddFoodView(selectedDate: selectedDate) { foodName in
                viewModel.addFoodEntry(name: foodName, date: selectedDate)
            }
        }
    }
}

struct FoodEntryRow: View {
    let entry: FoodEntry
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.name)
                    .font(.headline)
                    .fontWeight(.medium)
                
                Text(entry.timestamp, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
        .padding(.vertical, 8)
    }
}

struct AddFoodView: View {
    let selectedDate: Date
    let onSave: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var foodName = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                VStack(spacing: 20) {
                    Text("Add Food Item")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Date: \(selectedDate, style: .date)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Food Name")
                            .font(.headline)
                        
                        TextField("e.g., Chicken Salad", text: $foodName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.body)
                    }
                }
                .padding()
                
                Spacer()
                
                Button(action: saveFood) {
                    Text("Add Food Item")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isValidInput ? Color.blue : Color.gray)
                        .cornerRadius(10)
                }
                .disabled(!isValidInput)
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle("Add Food")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .alert("Error", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private var isValidInput: Bool {
        !foodName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func saveFood() {        
        let trimmedName = foodName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            alertMessage = "Please enter a food name"
            showingAlert = true
            return
        }
        
        onSave(trimmedName)
        dismiss()
    }
}

#Preview {
    FoodTrackingView()
        .environmentObject(CalendarViewModel())
}
