# SBMG Flutter Frontend – Government Deployment Whitelist

This document lists **all domains the Flutter frontend needs** for **build-time** and **app runtime** so your government IT can whitelist them. It supplements the backend whitelist.

---

## Summary: What’s Different from Backend

| Category | Backend has it? | Frontend needs? |
|----------|-----------------|-----------------|
| **pub.dev** (Dart packages) | ❌ No | ✅ **Yes** – **critical** for `flutter pub get` / build |
| **storage.googleapis.com** (pub + Flutter SDK) | ❌ No | ✅ **Yes** – **critical** for build |
| **fonts.googleapis.com / fonts.gstatic.com** | ❌ No | ⚠️ Only if `google_fonts` is used at runtime |
| **generativelanguage.googleapis.com** (Gemini) | ❌ No | ⚠️ **Recommend removing** – 3rd‑party AI; not suitable for govt |
| **sbmgrajasthan.com** | ✅ Your API | ✅ **Yes** – API + media |
| **GitHub / npm / PyPI / Docker** | In backend list | ❌ **Not used** by this Flutter app (no npm, no Docker in frontend) |

---

## 1. Build‑time (CI / dev machine where `flutter pub get` and `flutter build` run)

Used when resolving packages and building the app. **If build runs on a restricted government network, these must be whitelisted.**

| Domain | Purpose |
|--------|---------|
| **pub.dev** | Dart/Flutter package registry (`flutter pub get`, `pub get`) |
| **storage.googleapis.com** | Hosts pub package tarballs; also Flutter SDK / engine downloads |

Optional (only if you use a non‑default setup):

| Domain | Purpose |
|--------|---------|
| **pub.dartlang.org** | Legacy/redirect to pub.dev; optional if pub.dev works |
| **dart.googlesource.com** | Only if any Flutter/Dart tooling pulls from Googlesource |
| **github.com** | Only if you use Git dependencies in `pubspec.yaml` (you currently do not) |

**Flutter SDK:**  
If the Flutter SDK is installed from `storage.googleapis.com` (or `flutter.io` CDN), ensure **storage.googleapis.com** is allowed. `flutter upgrade` / first-time install also needs it.

---

## 2. App runtime (end‑user devices: phones, tablets, kiosks)

Domains the **built app** may contact when running in the field.

### 2.1 Required – your backend

| Domain | Purpose |
|--------|---------|
| **sbmgrajasthan.com** | All API calls (`ApiConstants.baseUrl`) and media via `ApiConstants.getMediaUrl()` (schemes, events, complaints, inspections, auth, attendance, etc.) |

(If the API is later moved to another host, e.g. `api.sbmgrajasthan.gov.in`, that host must be whitelisted instead or in addition.)

### 2.2 Google Fonts (optional – can be removed)

The app uses `fontFamily: 'Noto Sans'` and depends on `google_fonts`.  
If `google_fonts` is used at runtime (and no local Noto Sans assets are bundled), it will contact:

| Domain | Purpose |
|--------|---------|
| **fonts.googleapis.com** | CSS/metadata for font families |
| **fonts.gstatic.com** | Font file (`.ttf`/`.woff2`) downloads |

**Recommendation for government:**  
- **Option A:** Remove `google_fonts` and **bundle Noto Sans** (or another font) as an asset. Then **no** `fonts.googleapis.com` or `fonts.gstatic.com` are needed at runtime.  
- **Option B:** Keep `google_fonts` and whitelist **fonts.googleapis.com** and **fonts.gstatic.com**.

### 2.3 Gemini / generativelanguage (recommend removing)

`lib/screens/citizen/feedback_bottom_sheet.dart` calls:

- **generativelanguage.googleapis.com**

This is Google’s Gemini API. For a government, controlled environment:

- **Recommendation:** Remove or disable this integration. Then **generativelanguage.googleapis.com** does **not** need to be whitelisted.

If you must keep it:

| Domain | Purpose |
|--------|---------|
| **generativelanguage.googleapis.com** | Gemini API for the feedback/quiz feature |

### 2.4 `url_launcher` – maps and social (optional, depends on policy)

These are only opened in the **device’s browser** (or maps app) when the user taps a link. The app itself does not load these domains in‑app; the OS/browser does.

- **Maps:** `https://www.google.com/maps/...` (e.g. in complaint details).
- **Social:**  
  - `instagram.com`  
  - `x.com`  
  - `www.facebook.com`  
  - `youtube.com`

Whether to whitelist them depends on:

- Whether field devices are allowed to open external browsers.
- Whether the government allows access to Google, Instagram, X, Facebook, YouTube from those devices.

If the browser/app is locked down and cannot reach these, the links will fail; whitelisting is only relevant on the network the **device** uses (not necessarily the same as backend/build).

---

## 3. Consolidated whitelist for your government IT

### 3.1 Build‑time only (where `flutter pub get` / `flutter build` runs)

```
pub.dev
storage.googleapis.com
```

### 3.2 App runtime only (field devices running the app)

**Minimum (your backend only):**

```
sbmgrajasthan.com
```

**If you keep `google_fonts` at runtime (and do not bundle fonts):**

```
fonts.googleapis.com
fonts.gstatic.com
```

**If you keep the Gemini feedback feature:**

```
generativelanguage.googleapis.com
```

**If you allow opening Google Maps and social links from the device:**

```
www.google.com
instagram.com
x.com
www.facebook.com
youtube.com
```

(Exact subdomains may vary; your IT may use `*.google.com` etc. as per policy.)

### 3.3 Combined: build + runtime (if same network)

```
pub.dev
storage.googleapis.com
sbmgrajasthan.com
fonts.googleapis.com
fonts.gstatic.com
```

Omit `fonts.googleapis.com` / `fonts.gstatic.com` if you bundle fonts and remove `google_fonts` runtime usage.  
Do **not** add `generativelanguage.googleapis.com` if you remove the Gemini integration.

---

## 4. Not needed for this Flutter frontend

- **npm / registry.npmjs.org / registry.yarnpkg.com** – This project has no `package.json`; Flutter uses pub only.
- **PyPI / pypi.org / files.pythonhosted.org** – No Python in the frontend.
- **Docker (registry-1.docker.io, auth.docker.io, index.docker.io, production.cloudflare.docker.com)** – Only if you containerize the **build** (e.g. Flutter in Docker). The app itself does not call Docker.
- **Ubuntu/CentOS/RHEL/Rocky/Alma/EPEL/Red Hat/Launchpad** – Not used by the Flutter app or typical Flutter build; only relevant for the OS on build/servers.
- **GitHub (github.com, raw.githubusercontent.com, api.github.com, etc.)** – Not used by this `pubspec.yaml` (all packages from pub.dev).

---

## 5. Code changes recommended for government deployment

1. **Remove or disable Gemini in `feedback_bottom_sheet.dart`**  
   - Stops use of **generativelanguage.googleapis.com** and avoids 3rd‑party AI in a govt stack.

2. **Bundle Noto Sans (or another font) and drop runtime `google_fonts`**  
   - Add `.ttf`/`.otf` in `assets` and declare in `pubspec.yaml` under `flutter: fonts:`.  
   - Set `fontFamily` to that bundled font.  
   - Remove `google_fonts` from `pubspec.yaml` (or at least avoid using it at runtime).  
   - Then **fonts.googleapis.com** and **fonts.gstatic.com** are not needed at runtime.

3. **Make the API base URL configurable**  
   - If the government host differs from `sbmgrajasthan.com` (e.g. `https://sbmg.rajasthan.gov.in`), load `baseUrl` from build config / env so you don’t need to change code per environment.

4. **Maps and social links**  
   - If government policy disallows Google/social on field devices, consider:
     - Removing “Open in Maps” / social buttons, or  
     - Replacing with an approved map (e.g. Bhuvan, OSM) or internal URLs, and approved social handles (if any).

---

## 6. Checklist for your IT team

- [ ] **Build environment:** Whitelist `pub.dev`, `storage.googleapis.com` (and `pub.dartlang.org` if you see redirects).
- [ ] **App runtime:** Whitelist `sbmgrajasthan.com` (and the correct host if different in govt).
- [ ] **Fonts:** Either whitelist `fonts.googleapis.com` and `fonts.gstatic.com`, or implement bundled fonts and avoid `google_fonts` at runtime.
- [ ] **Gemini:** Confirm feature is removed/disabled; do not whitelist `generativelanguage.googleapis.com` unless explicitly required.
- [ ] **Maps/social:** Decide policy; whitelist `www.google.com`, `instagram.com`, `x.com`, `www.facebook.com`, `youtube.com` only if allowed on field devices.

---

## 7. Reference: backend‑style list (frontend‑specific domains to add)

If your backend list is the base and you only want to **add** what the frontend needs, these are the **extra** domains for the frontend:

**Build (add to backend list only if builds run on the same restricted network):**

```
pub.dev
storage.googleapis.com
```

**Runtime (add for devices running the app):**

```
sbmgrajasthan.com
```

**Optional – add only if you keep the feature:**

```
fonts.googleapis.com
fonts.gstatic.com
generativelanguage.googleapis.com
www.google.com
instagram.com
x.com
www.facebook.com
youtube.com
```

---

*Generated from the SBMG Flutter codebase. Update this document if you add new external services (e.g. analytics, push, or another API).*
