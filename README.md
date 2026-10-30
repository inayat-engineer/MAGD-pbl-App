# MUET Notify

MUET Notify is a responsive campus notice app for browsing examination,
fee, event, and scholarship announcements. It includes category and
department filters, deadline countdowns, urgent notices, summary analytics,
and an adaptive desktop master-detail layout.

## Tech stack

- Flutter and Dart
- Material 3
- GoRouter
- `flutter_dotenv` for local configuration loading
- `google_fonts`, `intl`, and `shared_preferences`
- ChangeNotifier-based state management

## Deployment

The web build can be deployed to Vercel using the included
[`vercel.json`](./vercel.json) configuration.

```powershell
flutter build web
```

Deploy the generated `build/web` directory through Vercel.

## Local setup

1. Install Flutter and verify the installation:

   ```powershell
   flutter doctor
   ```

2. Install dependencies:

   ```powershell
   flutter pub get
   ```

3. Create the local environment file:

   ```powershell
   Copy-Item .env.example .env
   ```

   Do not commit `.env`, credentials, or key files. Values bundled into a
   Flutter web app are visible to users, so real secrets must remain on a
   server-side service.

4. Run the app:

   ```powershell
   flutter run -d chrome
   ```

   Or run the Windows desktop target:

   ```powershell
   flutter run -d windows
   ```

5. Validate the project:

   ```powershell
   flutter analyze
   flutter test
   ```
