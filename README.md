# Consultation Booking App

A Flutter and Firebase app for booking consultations with lecturers.
Built with the MVVM architecture using Provider.

## Features

**Student portal:** registration and login with validation, remember me,
password reset, real-time bookings grouped by date, create, edit and delete
bookings, booking details, and a profile with picture upload.

**Admin portal:** admin registration with an access code, a dashboard with
all bookings, search by Student ID, date range filter, confirm and delete.

## Tech stack

Flutter, Dart, Firebase Authentication, Cloud Firestore, Provider.

## Run it yourself

1. Create a Firebase project and enable Email/Password sign-in and Cloud Firestore.
2. Run `flutterfire configure` inside the project folder.
3. In Firestore, create the document `config/admin` with a string field `code`
   (your admin access code).
4. Publish the rules from `firestore.rules` in the Firebase console.
5. Run `flutter pub get`, then `flutter run`.

## Notes

Profile pictures are compressed and stored as base64 text in Firestore,
because Firebase Storage needs a paid plan.