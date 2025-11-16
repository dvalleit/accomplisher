import SwiftUI
import Charts

struct WeightProgressView: View {
    @EnvironmentObject var viewModel: CalendarViewModel
    @State private var showingAddWeight = false
    @State private var selectedDate = Date()
    @State private var weightInput = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if viewModel.dailyWeights.isEmpty {
                    // Empty state
                    VStack(spacing: 20) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No Weight Data")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Start tracking your daily weight to see your progress chart")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Button(action: { showingAddWeight = true }) {
                            Text("Add First Weight Entry")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    }
                } else {
                    // Weight progress chart
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Weight Progress")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                if let latestWeight = viewModel.latestWeight {
                                    Text("Current: \(latestWeight, specifier: "%.1f") kg")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            if let initialWeight = viewModel.initialWeight,
                               let currentWeight = viewModel.latestWeight {
                                let change = currentWeight - initialWeight
                                HStack {
                                    Image(systemName: change >= 0 ? "arrow.up" : "arrow.down")
                                        .foregroundColor(change >= 0 ? .red : .green)
                                    Text("\(abs(change), specifier: "%.1f") kg")
                                        .foregroundColor(change >= 0 ? .red : .green)
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                        
                        // Line Chart
                        Chart(viewModel.chartWeightEntries, id: \.date) { entry in
                            LineMark(
                                x: .value("Date", entry.date),
                                y: .value("Weight", entry.weight)
                            )
                            .foregroundStyle(Color.blue)
                            .lineStyle(StrokeStyle(lineWidth: 3))
                            
                            PointMark(
                                x: .value("Date", entry.date),
                                y: .value("Weight", entry.weight)
                            )
                            .foregroundStyle(Color.blue)
                            .symbolSize(50)
                        }
                        .frame(height: 200)
                        .chartXAxis {
                            AxisMarks(values: .automatic(desiredCount: 5)) { _ in
                                AxisGridLine()
                                AxisValueLabel(format: .dateTime.month().day())
                            }
                        }
                        .chartYAxis {
                            AxisMarks { _ in
                                AxisGridLine()
                                AxisValueLabel()
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
                    
                    // Recent entries list
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Recent Entries")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        ForEach(viewModel.sortedWeightEntries.suffix(5).reversed(), id: \.date) { entry in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(entry.date, style: .date)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Text(entry.date, style: .time)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Text("\(entry.weight, specifier: "%.1f") kg")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                Button(action: {
                                    selectedDate = entry.date
                                    weightInput = String(format: "%.1f", entry.weight)
                                    showingAddWeight = true
                                }) {
                                    Image(systemName: "pencil")
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(10)
                            .shadow(radius: 1)
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .navigationTitle("Weight Progress")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        selectedDate = Date()
                        weightInput = ""
                        showingAddWeight = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddWeight) {
            WeightEntrySheet(
                date: $selectedDate,
                weightInput: $weightInput,
                onSave: { date, weight in
                    viewModel.addDailyWeight(weight: weight, date: date)
                    alertMessage = "Weight entry saved!"
                    showingAlert = true
                }
            )
        }
        .alert("Success", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
}

struct WeightEntrySheet: View {
    @Binding var date: Date
    @Binding var weightInput: String
    let onSave: (Date, Double) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                VStack(spacing: 15) {
                    Text("Log Weight")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                        .datePickerStyle(CompactDatePickerStyle())
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Weight (kg)")
                            .font(.headline)
                        
                        TextField("Enter weight", text: $weightInput)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.title3)
                    }
                }
                .padding()
                
                Spacer()
                
                Button(action: saveWeight) {
                    Text("Save Weight")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(weightInput.isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(10)
                }
                .disabled(weightInput.isEmpty)
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle("Add Weight")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func saveWeight() {
        guard let weight = Double(weightInput), weight > 0 else { return }
        onSave(date, weight)
        dismiss()
    }
}

#Preview {
    WeightProgressView()
        .environmentObject(CalendarViewModel())
}