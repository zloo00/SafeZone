**Tagline:** *“Safety at the touch of a button”*

---

## **Overview**

**SafeZone** is an iOS emergency safety application designed to provide a fast and efficient way to call for help and notify trusted contacts during dangerous or life-threatening situations.

---

## **Key Features**

### 🔴 **One-Tap SOS Signal**

- Activate emergency mode by holding the SOS button
- Automatically sends SMS/notifications to trusted contacts
- Shares current location in real-time
- Starts hidden audio and video recording
- Option to auto-call emergency services or a hotline

### 📍 **Live Location Sharing**

- Share real-time coordinates with trusted contacts
- Share travel route while moving
- Auto-update location every 10 meters

### 👥 **Trusted Contacts Management**

- Add up to 5 trusted contacts
- Customize notification types per contact
- Flexible settings: share location, media, or trigger calls

### 🎙️ **Automatic Media Recording**

- Hidden microphone audio recording
- Front/rear camera video capture
- Secure cloud storage with encryption
- Configurable recording duration

### 🕵️‍♀️ **Stealth Mode**

- Activate SOS without drawing attention
- Background functionality
- Hidden app icon for discreet use

### ⏰ **Safety Timer**

- Set timer (2–30 minutes)
- Automatically triggers SOS when time runs out
- Ideal for walking in unsafe areas

---

## **Technical Architecture**

### **Frontend**

- **SwiftUI** – modern UI framework
- **Combine** – reactive programming
- **CoreLocation** – location services
- **AVFoundation** – audio/video recording

### **Backend (Planned)**

- **Firebase** – authentication and database
- **Cloud Functions** – backend logic
- **Firestore** – real-time data sync
- **Firebase Storage** – encrypted media files

### **Security**

- **Firebase Auth** – user authentication
- **Biometric Auth** – Face ID / Touch ID
- **Data Encryption** – AES-256
- **Local Storage** – Apple Keychain

---

## **Project Structure**

```
SafeZone/
├── Models/
│   ├── TrustedContact.swift
│   └── EmergencyEvent.swift
├── Services/
│   ├── LocationManager.swift
│   └── EmergencyService.swift
├── Views/
│   ├── MainTabView.swift
│   ├── HomeView.swift
│   ├── ContactsView.swift
│   ├── HistoryView.swift
│   ├── SettingsView.swift
│   └── SafetyTimerView.swift
└── Info.plist

```

---

## **Installation & Running**

1. Clone the repository
2. Open `SafeZone.xcodeproj` in Xcode
3. Select a simulator or device
4. Press Run (⌘+R)

---

## **Requirements**

- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+

---

## **Permissions**

This app requests the following permissions:

- **Location** – to share with trusted contacts
- **Camera** – to record video in emergencies
- **Microphone** – to record audio in emergencies

---

## **User Scenarios**

### **Student Walking Home at Night**

1. Starts a 10-minute safety timer
2. Shares live location with trusted contacts
3. If not canceled in time, SOS is automatically triggered

### **Traveler in a New Country**

1. Adds trusted contacts
2. Uses danger zone map (future feature)
3. Enables stealth mode for discreet operation

### **Person Being Followed**

1. Activates stealth mode
2. Phone begins recording audio/video
3. Sends alerts to trusted contacts

---

## **Monetization**

### **Free Plan**

- Basic SOS signal
- Up to 3 trusted contacts
- Safety timer
- Event history

### **Premium Plan**

- Up to 10 trusted contacts
- Extended cloud storage
- Route analytics
- Auto-activation in specified zones
- Advanced privacy settings

---

## **Competitive Advantages**

- ✅ Combination of location, media, and real-time alerts
- ✅ Supports stealth activation
- ✅ Fast setup and user-friendly interface
- ✅ Full Apple ecosystem integration
- ✅ Privacy-first design

---

## **Security & Privacy**

- All data is encrypted
- Media access restricted by biometrics
- Supports Face ID / Touch ID
- Local storage for sensitive data
- Transparent privacy policy

---

## **License**

© 2025 SafeZone Team. All rights reserved.

---

## **Support**

For questions or support:
📧 Email: [yuwonnie.lu@gmail.com](mailto:yuwonnie.lu@gmail.com)

---

**SafeZone** — *your safety, in your hands.*

---
<img width="1440" height="900" alt="image" src="https://github.com/user-attachments/assets/9928c5dc-7b0b-4a8c-b6bf-c57bccff28f6" />
