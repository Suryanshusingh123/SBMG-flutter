# Release Signing Setup Guide

This guide explains how to set up release signing for your Android app to meet audit requirements.

## Problem

The audit team reported that your APK/App Bundle was signed in debug mode. Release builds must be signed with a release keystore, not the debug keystore.

## Solution

You need to:
1. Generate a release keystore (if you don't have one)
2. Create a `key.properties` file with your keystore information
3. Build your app in release mode

---

## Step 1: Generate a Release Keystore

If you don't already have a keystore, generate one using the following command:

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

**Important Notes:**
- Replace `~/upload-keystore.jks` with your desired keystore path and filename
- Replace `upload` with your desired key alias
- You'll be prompted to enter:
  - A password for the keystore (save this!)
  - A password for the key alias (can be the same or different)
  - Your name, organization, city, state, and country
- The `-validity 10000` means the certificate is valid for 10,000 days (~27 years)

**⚠️ CRITICAL:** Store your keystore file and passwords securely. If you lose them, you won't be able to update your app on Google Play Store.

---

## Step 2: Create key.properties File

1. Copy the example file:
   ```bash
   cp android/key.properties.example android/key.properties
   ```

2. Edit `android/key.properties` and fill in your actual values:

   ```properties
   storePassword=your-actual-keystore-password
   keyPassword=your-actual-key-password
   keyAlias=your-actual-key-alias
   storeFile=../upload-keystore.jks
   ```

   **Notes:**
   - `storePassword`: The password you set for the keystore
   - `keyPassword`: The password you set for the key alias (can be same as storePassword)
   - `keyAlias`: The alias you used when generating the keystore (e.g., `upload`)
   - `storeFile`: Path to your keystore file relative to the `android/` directory
     - If your keystore is in your home directory: `storeFile=../upload-keystore.jks`
     - If it's in the android directory: `storeFile=upload-keystore.jks`
     - Use absolute paths if needed: `storeFile=/Users/yourname/upload-keystore.jks`

3. Verify that `key.properties` is in `.gitignore` (it should be already). **Never commit this file to version control!**

---

## Step 3: Build Release APK/App Bundle

### Build a signed APK:
```bash
flutter build apk --release
```

The signed APK will be located at:
```
build/app/outputs/flutter-apk/app-release.apk
```

### Build a signed App Bundle (for Google Play Store):
```bash
flutter build appbundle --release
```

The signed App Bundle will be located at:
```
build/app/outputs/bundle/release/app-release.aab
```

---

## Verification

To verify that your APK/AAB is signed with a release key (not debug), you can check the signing certificate:

### For APK:
```bash
keytool -printcert -jarfile build/app/outputs/flutter-apk/app-release.apk
```

### For AAB:
You'll need to extract and check the signing certificate. Alternatively, upload it to Google Play Console - it will show you if it's properly signed.

---

## Troubleshooting

### Error: "key.properties file is missing"
- Make sure you've created `android/key.properties` (not just the .example file)
- Check that the file path is correct

### Error: "storeFile not found"
- Verify the `storeFile` path in `key.properties` is correct
- Use absolute path if relative path doesn't work
- Make sure the keystore file exists at the specified location

### Error: "Cannot recover key"
- Check that your `keyPassword` matches the password you set for the key alias
- Verify the `keyAlias` is correct

### Error: "Keystore was tampered with, or password was incorrect"
- Verify your `storePassword` is correct
- Make sure you're using the right keystore file

---

## Security Best Practices

1. **Backup your keystore**: Store it in a secure location (encrypted backup, password manager, etc.)
2. **Never commit keystore or key.properties**: These files contain sensitive credentials
3. **Use strong passwords**: Use long, random passwords for your keystore and key
4. **Document your setup**: Keep a secure record of your keystore location and credentials (in a password manager, not in code)
5. **Limit access**: Only authorized team members should have access to the release keystore

---

## Next Steps

After setting up release signing:
1. Build your release APK/AAB using the commands above
2. Upload the signed release build to your audit team
3. For Google Play Store: Upload the `.aab` file through Google Play Console
