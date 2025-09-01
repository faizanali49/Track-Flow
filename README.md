# 🕒 TimeTracker Desktop - Work Activity Monitor

[![Flutter](https://img.shields.io/badge/Flutter-3.0%2B-blue?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-2.17%2B-blue?logo=dart)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Integration-FFCA28?logo=firebase)](https://firebase.google.com)
[![Platform](https://img.shields.io/badge/Platform-Desktop-2196F3)](https://docs.flutter.dev/desktop)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

![TimeTracker Desktop Screenshot](https://i.imgur.com/placeholder.png)
*Replace with an actual screenshot of your application*

---

## 📌 Overview

**TimeTracker Desktop** is a professional, cross-platform work activity monitoring tool built with **Flutter**. It enables teams and individuals to **track, pause, resume, and log work sessions** with **real-time Firebase integration**, ensuring accuracy and reliable data syncing.

---

## ✨ Key Features

- ⏱ **Real-Time Tracking** — Second-by-second precision for online work sessions.  
- ☁ **Firebase Integration** — Secure and reliable data storage in the cloud.  
- 🔄 **Session Management** — Smart handling of online, paused, resumed, and offline states.  
- 📂 **24-Hour Session Continuity** — Seamlessly resume within 24 hours.  
- 📝 **Offline Documentation** — Record titles and descriptions for tasks when going offline.  
- 🖥 **Cross-Platform Support** — Consistent experience on **Windows**, **macOS**, and **Linux**.  
- 💾 **State Persistence** — Local storage to ensure session continuity even after app restarts.

---

## 🚀 Core Functionality

### 🌐 **Online Mode**
<img width="426" height="431" alt="Screenshot 2025-09-01 203357" src="https://github.com/user-attachments/assets/07b38592-9d2e-456c-b1ef-50201d5641f6" />

- User enters a daily work comment.  
- System records start time in Firebase.  
- Timer begins tracking session automatically.  
- Buttons toggle: **Online → Disabled**, **Pause / Offline → Enabled**.

### ⏸ **Pause Mode** 
<img width="427" height="443" alt="Screenshot 2025-09-01 203710" src="https://github.com/user-attachments/assets/3ee6a9f9-40f3-4ff1-920e-2b7aa2ee448d" />

- User provides a pause reason.  
- Firebase logs session status.  
- Data is saved locally for quick resume.  
- Buttons toggle: **Pause → Disabled**, **Resume → Enabled**.

### ▶ **Resume Mode**
<img width="436" height="438" alt="Screenshot 2025-09-01 203724" src="https://github.com/user-attachments/assets/e2cd6865-65f0-4dc8-8684-a7f03360e15e" />

- **Within 24 hours:** Resume session seamlessly.  
- **After 24 hours:** Auto-submit session and reset timer.

### 🔌 **Offline Mode**

<img width="429" height="445" alt="Screenshot 2025-09-01 203457" src="https://github.com/user-attachments/assets/f76fa3e9-f6b6-4d24-a1f7-b26cd587c88a" />
- User enters task details.  
- System records total time and clears session data.  
- UI resets to allow new session tracking.

---

## 🛠 Technical Architecture

| Component | Technology | Purpose |
|-----------|------------|---------|
| **UI Framework** | Flutter 3.0+ | Cross-platform desktop app |
| **State Management** | Riverpod | Efficient and reactive state handling |
| **Backend** | Firebase | Real-time data sync and storage |
| **Window Management** | window_manager | Desktop window configuration |
| **Utilities** | intl | Date/time formatting |

---


## 📦 Installation & Setup

### **Prerequisites**

* [Flutter SDK 3.0+](https://docs.flutter.dev/get-started/install)
* Dart 2.17+
* A configured Firebase project for desktop

### **Steps**

1. **Clone the repository**

   ```bash
   git clone https://github.com/your-username/timetracker-desktop.git
   cd timetracker-desktop
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Configure Firebase**

   * Create a Firebase project.
   * Enable **Desktop support** in Firebase.
   * Replace `lib/services/firebase_options.dart` with your project configuration.

4. **Run the app**

   ```bash
   flutter run -d windows  # macos or linux as needed
   ```

---

## 🧪 Usage

1. **Start the App** — Fixed 450x450 window launches.
2. **Go Online** — Add a comment and start tracking.
3. **Pause Session** — Log pause reason and stop timer.
4. **Resume Session** — Resume within 24 hours seamlessly.
5. **Go Offline** — Submit task details and reset timer.

---
