import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel = HealthDataViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                StepCardView(title: "Steps Today", stepCount: viewModel.steps)
                StepCardView(title: "Steps/hour (60min)", stepCount: viewModel.stepsLastHour)
                StepCardView(title: "Steps/hour (30min)", stepCount: viewModel.stepsLast30Minutes * 2)
                StepCardView(title: "Steps/hour (10min)", stepCount: viewModel.stepsLast10Minutes * 6)
                StepCardView(title: "Steps/hour (1min)", stepCount: viewModel.stepsLastMinute * 60)
            }
            .padding()
        }
        .onAppear {
            viewModel.startFetchingStepsEveryFiveSeconds()
        }
        .onDisappear {
            viewModel.stopFetchingSteps()
        }
    }
}

struct StepCardView: View {
    var title: String
    var stepCount: Double
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            Text("\(stepCount, specifier: "%.0f")")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading) // Align the VStack content to the left
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(radius: 5)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
