import SwiftUI

struct ContactsView: View {
    @State private var contacts: [TrustedContact] = []
    @State private var showingAddContact = false
    @State private var showingEditContact: TrustedContact?
    
    var body: some View {
        NavigationView {
            VStack {
                if contacts.isEmpty {
                    EmptyContactsView()
                } else {
                    ContactsListView(contacts: $contacts, onEdit: { contact in
                        showingEditContact = contact
                    })
                }
            }
            .navigationTitle("Доверенные контакты")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddContact = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddContact) {
                AddContactView { contact in
                    contacts.append(contact)
                }
            }
            .sheet(item: $showingEditContact) { contact in
                EditContactView(contact: contact) { updatedContact in
                    if let index = contacts.firstIndex(where: { $0.id == contact.id }) {
                        contacts[index] = updatedContact
                    }
                }
            }
        }
    }
}

// MARK: - Empty Contacts View
struct EmptyContactsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Нет доверенных контактов")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Добавьте доверенных контактов, чтобы они могли получать уведомления в случае экстренной ситуации")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
    }
}

// MARK: - Contacts List View
struct ContactsListView: View {
    @Binding var contacts: [TrustedContact]
    let onEdit: (TrustedContact) -> Void
    
    var body: some View {
        List {
            ForEach(contacts) { contact in
                ContactRowView(contact: contact) {
                    onEdit(contact)
                }
            }
            .onDelete(perform: deleteContacts)
        }
    }
    
    private func deleteContacts(offsets: IndexSet) {
        contacts.remove(atOffsets: offsets)
    }
}

// MARK: - Contact Row View
struct ContactRowView: View {
    let contact: TrustedContact
    let onEdit: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(contact.name)
                    .font(.headline)
                
                Text(contact.phoneNumber)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if let email = contact.email {
                    Text(email)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 8) {
                    if contact.receivesLocation {
                        Label("Локация", systemImage: "location")
                            .font(.caption2)
                            .foregroundColor(.green)
                    }
                    
                    if contact.receivesMedia {
                        Label("Медиа", systemImage: "video")
                            .font(.caption2)
                            .foregroundColor(.blue)
                    }
                    
                    if contact.receivesCall {
                        Label("Звонок", systemImage: "phone")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                }
            }
            
            Spacer()
            
            Button(action: onEdit) {
                Image(systemName: "pencil")
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Add Contact View
struct AddContactView: View {
    @Environment(\.dismiss) private var dismiss
    let onSave: (TrustedContact) -> Void
    
    @State private var name = ""
    @State private var phoneNumber = ""
    @State private var email = ""
    @State private var receivesLocation = true
    @State private var receivesMedia = false
    @State private var receivesCall = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Основная информация") {
                    TextField("Имя", text: $name)
                    TextField("Номер телефона", text: $phoneNumber)
                        .keyboardType(.phonePad)
                    TextField("Email (необязательно)", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                Section("Уведомления") {
                    Toggle("Получает локацию", isOn: $receivesLocation)
                    Toggle("Получает медиа", isOn: $receivesMedia)
                    Toggle("Получает звонки", isOn: $receivesCall)
                }
            }
            .navigationTitle("Добавить контакт")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        let contact = TrustedContact(name: name, phoneNumber: phoneNumber, email: email.isEmpty ? nil : email)
                        onSave(contact)
                        dismiss()
                    }
                    .disabled(name.isEmpty || phoneNumber.isEmpty)
                }
            }
        }
    }
}

// MARK: - Edit Contact View
struct EditContactView: View {
    @Environment(\.dismiss) private var dismiss
    let contact: TrustedContact
    let onSave: (TrustedContact) -> Void
    
    @State private var name: String
    @State private var phoneNumber: String
    @State private var email: String
    @State private var receivesLocation: Bool
    @State private var receivesMedia: Bool
    @State private var receivesCall: Bool
    
    init(contact: TrustedContact, onSave: @escaping (TrustedContact) -> Void) {
        self.contact = contact
        self.onSave = onSave
        
        _name = State(initialValue: contact.name)
        _phoneNumber = State(initialValue: contact.phoneNumber)
        _email = State(initialValue: contact.email ?? "")
        _receivesLocation = State(initialValue: contact.receivesLocation)
        _receivesMedia = State(initialValue: contact.receivesMedia)
        _receivesCall = State(initialValue: contact.receivesCall)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Основная информация") {
                    TextField("Имя", text: $name)
                    TextField("Номер телефона", text: $phoneNumber)
                        .keyboardType(.phonePad)
                    TextField("Email (необязательно)", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                Section("Уведомления") {
                    Toggle("Получает локацию", isOn: $receivesLocation)
                    Toggle("Получает медиа", isOn: $receivesMedia)
                    Toggle("Получает звонки", isOn: $receivesCall)
                }
            }
            .navigationTitle("Редактировать контакт")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        var updatedContact = contact
                        updatedContact.name = name
                        updatedContact.phoneNumber = phoneNumber
                        updatedContact.email = email.isEmpty ? nil : email
                        updatedContact.receivesLocation = receivesLocation
                        updatedContact.receivesMedia = receivesMedia
                        updatedContact.receivesCall = receivesCall
                        
                        onSave(updatedContact)
                        dismiss()
                    }
                    .disabled(name.isEmpty || phoneNumber.isEmpty)
                }
            }
        }
    }
}

#Preview {
    ContactsView()
} 