import SwiftUI

struct WeightEntryView: View {
    @EnvironmentObject var viewModel: CalendarViewModel
    @State private var weightInput: String = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Title
            Text("Set Your Initial Weight")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            // Current weight display
            if let currentWeight = viewModel.initialWeight {
                VStack(spacing: 10) {
                    Text("Current Weight")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("\(currentWeight, specifier: "%.1f") lbs")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.blue)
                }
                .padding(.vertical)
            }
            
            // Weight input section
            VStack(spacing: 20) {
                Text("Enter your weight in pounds:")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                TextField("Weight (lbs)", text: $weightInput)
                    .font(.title2)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(maxWidth: 200)
                
                Button(action: saveWeight) {
                    Text(viewModel.initialWeight == nil ? "Set Initial Weight" : "Update Weight")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .disabled(weightInput.isEmpty)
            }
            .padding(.horizontal, 40)
            
            Spacer()
            
            // Navigation hint
            if viewModel.initialWeight != nil {
                Text("Tap the calendar tab below to track your daily progress!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .padding()
        .onAppear {
            if let weight = viewModel.initialWeight {
                weightInput = String(format: "%.1f", weight)
            }
        }
        .alert("Weight Saved", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func saveWeight() {
        guard let weight = Double(weightInput), weight > 0 else {
            alertMessage = "Please enter a valid weight"
            showingAlert = true
            return
        }
        
        viewModel.setInitialWeight(weight)
        alertMessage = "Weight saved successfully!"
        showingAlert = true
    }
}

#Preview {
    WeightEntryView()
        .environmentObject(CalendarViewModel())
}