# Expense Tracker

A Flutter personal finance app for recording income and expenses. The dashboard
shows total income, total expenses, and the current balance, with recent
transactions available at a glance. Transactions can be created, reviewed,
edited, and deleted.

## Features

- Local SQLite storage in `expense_tracker.db`, using the `transactions` table.
- SQLite initialization for Android/iOS/macOS, Linux/Windows, and web.
- Browser storage is persisted in IndexedDB and is scoped to the app's origin.
- Transaction form with title, positive amount, category, type, and date.
- Transaction details screen with edit and confirmed delete actions.
- Live dashboard totals and a complete transaction list.
- Income and expense amounts are visually distinguished.

## Run

Install Flutter dependencies and launch on an Android or iOS device or emulator:

```sh
flutter pub get
flutter run
```

The database is managed by Sqflite and persists between app launches. Run the
automated widget tests with:

```sh
flutter test
```
