# ✈️ Lakbay
*A Travel Planner App made with Flutter*

---

## 📚 Table of Contents

- [About](#about)
- [How To Install](#how-to-install)
- [Features](#features)
  - [Main Features](#main-features)
  - [Optional Features](#optional-features)

---

## 📌 About

**Lakbay** is a collaborative travel planning app designed to help users create, manage, and share their travel itineraries with ease. Built with Flutter and powered by Firebase, it allows users to sign up, log in, and plan detailed trips—complete with schedules, notes, and location features. Users can connect with friends through QR codes or shared interests, making trip planning more social and interactive. With a clean interface and customizable reminders, Lakbay ensures you're always ready for your next adventure.

---


# ✨ Features Overview

This document outlines the **Main Features** and **Optional Features** of the **Lakbay** travel planning application, based on the official project specifications.

---

## 🏆 Main Features

- User Authentication 

- Travel Plan Management 

- Friend System

- Profile Management

- Find Similar People

- Push Notifications

---

## 📍Optional Features

- Map-Based Location Selection 

- User-Optional Details on Signup 

- QR Code Features 

- Friends List Page 

- UI/UX Enhancements

---
## 🔎 How to Use Lakbay
1. **Sign Up / Sign In**
   - Launch the app and create an account using your name, email, a unique username, and password.
   - You may optionally add your interests and travel styles during sign-up.
   - Existing users can log in using their credentials.
     
    <img src="https://github.com/user-attachments/assets/8aaedce0-96e2-4bb0-82ec-5f6e614b2eb5" width="150"/>
    <img src="https://github.com/user-attachments/assets/cc3df3bf-77eb-40f4-b2ce-7c3f121a5ad6" width="150"/>
    <img src="https://github.com/user-attachments/assets/12e72cc5-ca8a-4146-b8c4-ac9eb8481b68" width="150"/>
---
2. **Set Up Your Profile**
   - Navigate to the Profile tab to view or update your personal details.
   - Upload a profile picture and update your phone number, interests, or travel styles.
   - You can choose to hide your profile from public search in settings.
     
   <img src="https://github.com/user-attachments/assets/4bab3179-1b03-46da-b554-1aadc42373ea" width="150"/>
   <img src="https://github.com/user-attachments/assets/4b0ad344-e1ed-46fe-80a6-3060311ff07a" width="150"/>

---

3. **Create a Travel Plan**
   - Go to the Travel Plans section and tap the "Add" button.
   - Input the travel plan name, date range, and destination (with auto-suggest or map selection).
   - Add itineraries with detailed schedules, notes, checklists, flights, or accommodations.
     
   <img src="https://github.com/user-attachments/assets/2fc06670-fa30-48bf-b592-083c305178c6" width="150"/>
   <img src="https://github.com/user-attachments/assets/61d31529-7c34-4f3d-825d-74cc0099150b" width="150"/>
   <img src="https://github.com/user-attachments/assets/96c8af0b-84f0-42d2-ae6f-8c25b600866d" width="150"/>
---
4. **Share Your Plan**
   - Share travel plans with friends by scanning or generating a QR code.
   - You can also manually invite a friend by entering their username.
   
   <img src="https://github.com/user-attachments/assets/bf493f81-03ba-4a76-ba19-363557cf4705" width="150"/>
   <img src="https://github.com/user-attachments/assets/5683d8b3-80d8-41cf-83fc-d387173869a9" width="150"/>
   <img src="https://github.com/user-attachments/assets/f03329e4-a0c9-4a47-ac41-2da217de59c6" width="150"/>
---
5. **Find & Add Friends**
   - Visit the "Find Similar People" page to discover users with shared interests or travel styles.
   - Tap a user to view their public profile and add them as a friend.
     
   <img src="https://github.com/user-attachments/assets/c00e40a8-477a-4a27-a4a5-a22acc2c49cd" width="150"/>
   <img src="https://github.com/user-attachments/assets/6e8d4637-8387-44e7-b040-1e0da6db7f83" width="150"/>
---
6. **Receive Notifications**
   - Get push reminders for upcoming trips.
   - Configure how far in advance you'd like to be notified.
---
7. **Manage Your Trips**
   - View all travel plans shared with or created by you.
   - Edit, update, or delete your travel plans as needed.
   - Remove collaborators from shared plans anytime.
     
   <img src="https://github.com/user-attachments/assets/95f4b01a-b6f3-42ff-8745-47dfa46e9c0f" width="150"/>
   <img src="https://github.com/user-attachments/assets/3bd7748a-86db-47bb-b55f-eb1c020a512f" width="150"/>


---

## 🔥 How Firestore Works
Lakbay uses Firebase Cloud Firestore as its backend database to store and manage user data, travel plans, itineraries, and friends. When the app runs, it fetches data in real time through StreamBuilder and Firebase services—ensuring updates are instantly reflected across all connected devices. Firestore's document-based structure allows us to organize data efficiently into collections like appusers, travelplans, itineraries, and sharedplans.

<img src="https://github.com/user-attachments/assets/0868b87c-53ad-4bde-964e-62d45419899b" width="600"/>

---

> Tip: Use the app on multiple devices to sync your data seamlessly via Firebase.


---

## 📃 How to Install

To clone and run this application, you'll need **Git**, **Flutter**, and **Android Studio Meerkat** installed on your computer.

```bash
# Clone this repository
git clone https://github.com/CMSC-23-2nd-Sem-2024-2025/project-cmsc23-tabelisma-tadeja-tiamzon-velasco.git

# Go into the repository
cd lakbay

# Install dependencies
flutter pub get

# Point the android sdk path in your local machine using --android-sdk
flutter config --android-sdk "C:\Users\User\AppData\Local\Android\Sdk"

# Run the app
flutter run


