# GoKigali 🇷🇼

This is my final Flutter assignment for the Kigali City Services & Places Directory. 

I used Flutter for the frontend and Firebase for the backend.

---

## Features

- **User Accounts:** 

You can sign up with an email and password. It also requires you to verify your email before you can log in.
- **Directory:** 

A list of places and services in Kigali.
- **Search & Filter:** 

You can search for a place by typing its name or by clicking on category chips (like Hospital, Restaurant, etc.).
- **Map View:** 

I added a map using `flutter_map` that shows all the places as markers. You can click a marker to see more details.
- **My Listings:**

  - Anyone logged in can create a new listing.
  - You can only edit or delete a listing if you are the person who created it.
- **Get Directions:** 

On the details page or the map, there's a button that opens Google Maps to get directions to the place.

---

## How It Works (State Management)

We decided to use the **Provider** package to manage state because it keeps the code organized and separates the UI from the database logic.

- **`AuthProvider`**

This handles Firebase Authentication. It checks if a user is logged in and if their email is verified. It also stores the user's profile info from Firestore so we can show their name on the Settings screen.
- **`ListingProvider`**

This handles reading and writing listings to Firestore. It gets all the listings to show on the map and directory, and it filters them when you type in the search bar or click a category. It also grabs just the logged-in user's listings to show on the "My Listings" screen.

---

## Firestore Database Schema

We have two main collections in our Firebase database:

### 1. `users` collection

This stores extra info about the user that Firebase Auth doesn't keep track of easily.

- `id` (String) - the user's Auth UID
- `email` (String)
- `displayName` (String)
- `createdAt` (Timestamp)

### 2. `listings` collection

This is where the actual places/services are saved.

- `id` (String)
- `name` (String)
- `category` (String)
- `address` (String)
- `contactNumber` (String)
- `description` (String)
- `latitude` (Number)
- `longitude` (Number)
- `createdBy` (String) - this stores the UID of the user who made the listing
- `timestamp` (Timestamp)

### Database Security Rules

To make sure people don't mess with other people's data, we set up Firestore security rules:

- No one can read or write by default.
- You have to be logged in to read the directory.
- You have to be logged in to create a listing.
- **Most importantly -** You can only update or delete a listing if your UID matches the `createdBy` field on the document.

---

## How to Run It

1. Clone this repository.
2. Run `flutter pub get` in the terminal to install the packages.
3. Hook it up to a Firebase project (make sure you have your `google-services.json` or `GoogleService-Info.plist`).
4. Run `flutter run`!
