import SwiftUI

struct SafetyTimerView: View {
    @EnvironmentObject var emergencyService: EmergencyService
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedDuration: TimeInterval = 300 // 5 минут по умолчанию
    @State private var showingConfirmation = false
    
    private let durationOptions: [(String, TimeInterval)] = [
        ("2 минуты", 120),
        ("5 минут", 300),
        ("10 минут", 600),
        ("15 минут", 900),
        ("30 минут", 1800)
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Иконка и заголовок
                VStack(spacing: 15) {
                    Image(systemName: "timer")
                        .font(.system(size: 60))
                        .foregroundColor(.orange)
                    
                    Text("Таймер безопасности")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Если вы не отключите таймер вовремя, будет автоматически активирован SOS сигнал")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Выбор длительности
                VStack(alignment: .leading, spacing: 15) {
                    Text("Длительность таймера:")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(durationOptions, id: \.1) { option in
                        Button(action: {
                            selectedDuration = option.1
                        }) {
                            HStack {
                                Image(systemName: selectedDuration == option.1 ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(selectedDuration == option.1 ? .orange : .gray)
                                
                                Text(option.0)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                            }
                            .padding()
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(10)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Кнопка активации
                Button(action: {
                    showingConfirmation = true
                }) {
                    HStack {
                        Image(systemName: "timer")
                        Text("Активировать таймер")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(15)
                }
                .padding(.horizontal)
                .alert("Активировать таймер безопасности?", isPresented: $showingConfirmation) {
                    Button("Отмена", role: .cancel) { }
                    Button("Активировать") {
                        emergencyService.activateSafetyTimer(duration: selectedDuration)
                        dismiss()
                    }
                } message: {
                    Text("Таймер будет активен \(formatDuration(selectedDuration)). Если вы не отключите его вовремя, будет отправлен SOS сигнал.")
                }
            }
            .navigationTitle("Таймер безопасности")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        
        if minutes > 0 {
            return "\(minutes) мин \(seconds) сек"
        } else {
            return "\(seconds) сек"
        }
    }
}

#Preview {
    SafetyTimerView()
        .environmentObject(EmergencyService(locationManager: LocationManager()))
} 