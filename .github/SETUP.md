# GitHub Actions Setup Guide

This guide explains how to configure the required secrets for the Android build and Firebase deployment workflow.

## Required GitHub Secrets

To use the GitHub Actions workflow, you need to configure the following secrets in your repository:

### Android Build Secrets

1. **RELEASE_STORE_PASSWORD** - Password for the release keystore
2. **RELEASE_KEY_ALIAS** - Alias of the key in the keystore
3. **RELEASE_KEY_PASSWORD** - Password for the key
4. **APP_PACKAGE** - Application package name (e.g., `org.telegram.messenger`)

### Firebase Secrets

5. **FIREBASE_APP_ID** - Your Firebase App ID
   - Found in Firebase Console → Project Settings → General → Your apps
   - Format: `1:123456789:android:abcdef123456`

6. **FIREBASE_SERVICE_CREDENTIALS** - Firebase service account credentials JSON
   - Go to Firebase Console → Project Settings → Service accounts
   - Click "Generate new private key"
   - Copy the entire JSON content

### Telegram Channel Secrets

7. **TELEGRAM_BOT_TOKEN** - Bot token from [@BotFather](https://t.me/BotFather)
   - Open BotFather in Telegram and run `/newbot`
   - Copy the token (format: `123456789:ABCdefGHIjklMNOpqrsTUVwxyz`)

8. **TELEGRAM_CHANNEL_ID** - Your channel identifier
   - Public channel: `@your_channel_name`
   - Private channel: numeric ID such as `-1001234567890`
   - Add the bot as a channel admin with **Post Messages** permission

When both Telegram secrets are configured, every successful build automatically posts to the channel with:
- The APK file (if under Telegram's 50 MB bot upload limit)
- Otherwise, bilingual release notes with a download link to the Firebase-hosted APK

If the secrets are not set, the Telegram step is skipped automatically.

### Automatic Version Generation

- **APP_VERSION_NAME** is automatically generated based on the build date (format: `YYYY.MM.DD`, e.g., `2025.10.19`)
- **APP_VERSION_CODE** is automatically set to the GitHub Actions run number (increments with each workflow run)

## How to Add Secrets to GitHub

1. Go to your GitHub repository
2. Click on **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add each secret with its name and value
5. Click **Add secret**

## Testing the Workflow

Once all secrets are configured:

1. Push code to any branch
2. Go to the **Actions** tab in your repository
3. Watch the workflow run
4. The APK will be uploaded to Firebase App Distribution, Firebase Storage, and (if configured) your Telegram channel

## Customization

### Change the build variant

To build a different variant, edit `.github/workflows/build-and-deploy.yml`:

```yaml
- name: Build Release APK
  run: ./gradlew :TMessagesProj_App:assembleBundleAfatRelease --stacktrace
```

Available variants:
- `:TMessagesProj_App:assembleAfatRelease`
- `:TMessagesProj_App:assembleBundleAfatRelease`
- `:TMessagesProj_AppStandalone:assembleRelease`

### Change Firebase distribution groups

Edit the `groups` field in the workflow file:

```yaml
groups: testers,developers,beta-users
```

### Trigger on specific branches only

Change the `on.push.branches` section:

```yaml
on:
  push:
    branches:
      - main
      - develop
```

## Troubleshooting

### Build fails with signing errors
- Verify that all signing credentials secrets are correctly set
- Check that the keystore file exists at `TMessagesProj/config/release.keystore`

### Firebase upload fails
- Verify `FIREBASE_APP_ID` is correct
- Ensure `FIREBASE_SERVICE_CREDENTIALS` contains valid JSON
- Check that the "testers" group exists in Firebase App Distribution

### APK not found
- Check the build logs to see which APK was generated
- Update the `file` path in the Firebase upload step to match the actual output path

### Telegram post fails
- Verify `TELEGRAM_BOT_TOKEN` is correct
- Ensure the bot is an admin of the channel with **Post Messages** permission
- For private channels, use the numeric channel ID (starts with `-100`)
- If the APK is larger than 50 MB, the workflow posts release notes with a Firebase download link instead of attaching the file
