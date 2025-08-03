import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var emergencyService: EmergencyService
    @State private var showingClearConfirmation = false
    
    var body: some View {
        NavigationView {
            VStack {
                if emergencyService.emergencyHistory.isEmpty {
                    EmptyHistoryView()
                } else {
                    HistoryListView(events: emergencyService.emergencyHistory)
                }
            }
            .navigationTitle("История")
            .toolbar {
                if !emergencyService.emergencyHistory.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Очистить") {
                            showingClearConfirmation = true
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .alert("Очистить историю?", isPresented: $showingClearConfirmation) {
                Button("Отмена", role: .cancel) { }
                Button("Очистить", role: .destructive) {
                    emergencyService.clearEmergencyHistory()
                }
            } message: {
                Text("Это действие нельзя отменить.")
            }
        }
    }
}

// MARK: - Empty History View
struct EmptyHistoryView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "clock.badge.questionmark")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("История пуста")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Здесь будут отображаться все активированные экстренные события")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
    }
}

// MARK: - History List View
struct HistoryListView: View {
    let events: [EmergencyEvent]
    
    var body: some View {
        List {
            ForEach(events) { event in
                EmergencyEventRow(event: event)
            }
        }
    }
}

// MARK: - Emergency Event Row
struct EmergencyEventRow: View {
    let event: EmergencyEvent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: event.type.icon)
                    .foregroundColor(event.type == .sos ? .red : .orange)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(event.type.displayName)
                        .font(.headline)
                    
                    Text(formatDate(event.timestamp))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if event.isActive {
                    Text("АКТИВНО")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red)
                        .cornerRadius(8)
                }
            }
            
            if let location = event.location {
                HStack {
                    Image(systemName: "location")
                        .foregroundColor(.blue)
                        .font(.caption)
                    
                    Text("\(location.latitude, specifier: "%.4f"), \(location.longitude, specifier: "%.4f")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if let duration = event.duration {
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(.green)
                        .font(.caption)
                    
                    Text("Длительность: \(formatDuration(duration))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if !event.contactsNotified.isEmpty {
                HStack {
                    Image(systemName: "person.2")
                        .foregroundColor(.purple)
                        .font(.caption)
                    
                    Text("Уведомлено контактов: \(event.contactsNotified.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if event.mediaRecorded {
                HStack {
                    Image(systemName: "video")
                        .foregroundColor(.blue)
                        .font(.caption)
                    
                    Text("Медиа записано")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
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
    HistoryView()
        .environmentObject(EmergencyService(locationManager: LocationManager()))
} 