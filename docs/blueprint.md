# Product Blueprint — Fasting Tracker

> Dokumen acuan produk dan implementasi untuk AI coding assistant.  
> Status: MVP / UI-focused school project  
> Referensi produk: GoFasting — https://play.google.com/store/apps/details?id=gofasting.fastingtracker.fasting.intermittentfasting  
> Nama proyek: sementara, gunakan `Fasting Tracker` sampai nama final dipilih.

---

## 1. Product Overview

Bangun aplikasi mobile untuk membantu pengguna mencatat jadwal intermittent fasting, memantau sesi puasa yang sedang berjalan, dan melihat riwayat sederhana.

Aplikasi ini terinspirasi oleh kategori produk GoFasting, tetapi bukan salinan layar atau asetnya. Fokus proyek adalah pengalaman pengguna yang sederhana, visual yang konsisten, dan fungsi inti yang benar-benar bekerja.

### Product statement

"An uncomplicated fasting companion that helps users manage a fasting schedule, track an active session, and understand their consistency."

### Tujuan MVP

1. Pengguna dapat memilih atau mengatur jadwal fasting.
2. Pengguna dapat memulai, mengakhiri, dan membatalkan sesi fasting.
3. Dashboard menampilkan status dan timer yang akurat.
4. Pengguna dapat melihat ringkasan dan riwayat sesi.
5. UI terasa rapi, mudah dipahami, dan responsif.

### Bukan tujuan MVP

- Mengembangkan platform kesehatan lengkap.
- Mengimplementasikan AI food scanner atau calorie estimation.
- Mengintegrasikan wearable, Google Fit, atau Apple Health.
- Membuat backend, autentikasi, pembayaran, dan sinkronisasi cloud.
- Memberikan diagnosis, rekomendasi medis, atau klaim penurunan berat badan.
- Meniru seluruh fitur, branding, ilustrasi, atau aset GoFasting.

---

## 2. Product Principles

1. **Timer-first:** status fasting dan aksi utama harus menjadi fokus dashboard.
2. **Low cognitive load:** pengguna harus memahami status aplikasi dalam beberapa detik.
3. **One primary action:** hanya satu CTA utama yang dominan pada satu keadaan.
4. **Honest data:** jangan menampilkan statistik palsu seolah-olah berasal dari pengguna.
5. **Progressive disclosure:** detail sekunder ditampilkan ketika dibutuhkan.
6. **Accessible UI:** kontras, ukuran teks, target sentuh, dan state harus jelas.
7. **Functional prototype:** setiap tombol yang terlihat harus memiliki perilaku yang masuk akal.

---

## 3. Target Users

Target prototipe adalah pengguna dewasa yang ingin mencatat jadwal makan dan sesi intermittent fasting secara mandiri.

Personas sederhana:

- **Beginner:** belum memahami jadwal fasting dan membutuhkan pilihan yang mudah dipahami.
- **Routine builder:** sudah memiliki jadwal dan ingin timer serta riwayat yang praktis.
- **Progress reviewer:** ingin melihat durasi dan konsistensi dari sesi sebelumnya.

Jangan mengasumsikan semua pengguna ingin menurunkan berat badan. Tujuan pengguna dapat berbeda-beda.

---

## 4. MVP Feature Scope

### P0 — Wajib selesai

| Feature | Deskripsi | Acceptance criteria |
|---|---|---|
| Dashboard | Menampilkan status fasting, jadwal, timer/progress, dan CTA utama | Status dan CTA berubah sesuai state |
| Fasting plan | Memilih preset 14:10, 16:8, 18:6, 20:4 | Pilihan tersimpan dan ditampilkan di dashboard |
| Start fasting | Membuat sesi baru | Start menyimpan timestamp mulai |
| Active timer | Menghitung durasi dari timestamp, bukan sekadar menambah angka tiap detik | Timer tetap benar setelah app ditutup/dibuka |
| End fasting | Mengakhiri sesi aktif | Menyimpan waktu selesai dan durasi aktual |
| History | Menampilkan sesi yang sudah selesai | Data berasal dari sesi yang tersimpan |
| Local persistence | Menyimpan plan dan sesi secara lokal | Data tetap ada setelah aplikasi direstart |

### P1 — Jika waktu cukup

| Feature | Deskripsi | Catatan |
|---|---|---|
| Weekly summary | Jumlah sesi, total durasi, rata-rata durasi | Hitung dari history |
| Weight log | Input berat badan manual dan daftar catatan | Jangan menjadikan berat badan sebagai pusat pengalaman |
| Water tracker | Tambah jumlah gelas/ml dan reset harian | Fitur tambahan, bukan fokus MVP |
| Reminder UI | Pengaturan pengingat mulai/selesai | Boleh berupa UI terlebih dahulu jika notifikasi belum dikerjakan |
| Dark mode | Tema gelap | Kerjakan setelah layout utama stabil |

### P2 — Jangan dikerjakan untuk versi sekolah yang waktunya singkat

- AI food scanner.
- Barcode scanner dan database makanan.
- Macro/calorie tracking lengkap.
- Step counter dan integrasi sensor.
- Akun, cloud sync, social features.
- Subscription, ads, payment.
- Personalized health recommendations.
- Advanced analytics.

**Scope lock:** selesaikan P0 sebelum menyentuh P1 atau P2.

---

## 5. Information Architecture

Bottom navigation yang disarankan:

1. **Home** — dashboard dan fasting timer.
2. **Progress** — ringkasan mingguan dan statistik.
3. **History** — daftar sesi fasting sebelumnya.
4. **Profile** — preferensi, jadwal, dan informasi aplikasi.

Jika waktu sangat terbatas, gunakan tiga tab: Home, History, Profile. Progress dapat menjadi bagian dari Home.

### Screen inventory

#### A. Onboarding / Setup (opsional, maksimal 2–3 layar)

Tujuan: menjelaskan fungsi aplikasi dan membiarkan pengguna memilih jadwal.

Elemen:
- Welcome title dan deskripsi singkat.
- Penjelasan bahwa aplikasi hanya alat pencatat, bukan layanan medis.
- Pilihan jadwal fasting.
- CTA `Continue`.

Hindari onboarding panjang, login wajib, atau pertanyaan kesehatan yang tidak diperlukan untuk demo.

#### B. Home Dashboard

Ini adalah layar terpenting dan harus menerima porsi desain serta implementasi terbesar.

Urutan konten yang direkomendasikan:

1. Header: sapaan singkat, tanggal, avatar/profile shortcut.
2. Status label: `Not Fasting` atau `Fasting in Progress`.
3. Hero timer card:
   - Durasi berjalan `HH:MM:SS` ketika aktif.
   - Target durasi.
   - Progress ring/bar.
   - Estimasi waktu selesai berdasarkan jadwal.
4. Primary CTA:
   - Idle: `Start Fasting`.
   - Active: `End Fasting`.
5. Selected plan: contoh `16:8`, fasting 16 jam, eating window 8 jam.
6. Quick stats: total sesi minggu ini dan rata-rata durasi.
7. Recent activity: 2–3 sesi terakhir.

Jangan memenuhi dashboard dengan semua fitur sekaligus. Timer dan CTA harus paling menonjol.

#### C. Fasting Plan Selection

Elemen:
- Title: `Choose your fasting plan`.
- Kartu preset 14:10, 16:8, 18:6, 20:4.
- Penjelasan fasting window dan eating window.
- Selected state yang jelas.
- CTA `Save Plan`.

Catatan: preset adalah pilihan pencatatan jadwal, bukan rekomendasi medis. Jangan menyebut satu plan cocok untuk semua orang.

#### D. Active Fasting

Bisa berupa state pada Home atau halaman detail terpisah. Untuk MVP, lebih efisien menjadikannya state dashboard.

Elemen:
- Timer real-time.
- Start time.
- Target end time.
- Progress indicator.
- Tombol `End Fasting`.
- Confirmation dialog sebelum sesi diakhiri.

#### E. End Session Confirmation / Summary

Ketika pengguna menekan End:
- Tampilkan konfirmasi.
- Setelah dikonfirmasi, simpan `endAt`.
- Hitung durasi aktual.
- Tampilkan ringkasan: start time, end time, actual duration, dan plan.
- CTA `Done`.

Jangan otomatis mengubah sesi menjadi sukses jika pengguna mengakhiri sebelum target. Tampilkan durasi aktual secara netral.

#### F. History

Elemen:
- Filter sederhana: All / This week (opsional).
- Daftar sesi berdasarkan tanggal.
- Setiap item menampilkan waktu mulai, waktu selesai, durasi, dan plan.
- Empty state ketika belum ada sesi.
- Detail sesi dapat berupa bottom sheet atau halaman detail.

#### G. Progress

Elemen:
- Total fasting sessions.
- Total fasting hours.
- Average session duration.
- Weekly bar chart sederhana.
- Range waktu: 7 days / 30 days (opsional).

Semua nilai wajib dihitung dari data lokal. Jangan mengarang angka untuk membuat UI terlihat penuh.

#### H. Profile / Settings

Elemen:
- Selected fasting plan.
- Edit plan.
- Reminder toggle (jika diimplementasikan).
- Theme preference (opsional).
- About app.
- Privacy note.
- Reset demo data (khusus build demo, dengan konfirmasi).

---

## 6. Core User Flows

### Flow 1 — First-time user

`Launch → Welcome/Setup → Choose Plan → Home (Idle)`

### Flow 2 — Start fasting

`Home (Idle) → Start Fasting → Active Timer`

Saat Start:
- Buat sesi baru.
- Isi `startAt` dengan waktu sekarang.
- Isi `plannedDurationMinutes` berdasarkan plan.
- Isi `status = active`.
- Simpan data lokal.

### Flow 3 — End fasting

`Home (Active) → End Fasting → Confirmation → Session Summary → Home (Idle)`

Saat End:
- Isi `endAt` dengan waktu sekarang.
- Hitung `actualDurationSeconds = endAt - startAt`.
- Ubah `status = completed`.
- Simpan sesi.
- Jangan menghapus riwayat sesi sebelumnya.

### Flow 4 — View history

`Bottom Navigation → History → Session Detail`

### Flow 5 — Change plan

`Profile/Plan Shortcut → Plan Selection → Save → Home`

Jika sesi sedang aktif, jangan mengubah target sesi yang sedang berjalan secara diam-diam. Pilihan paling sederhana: perubahan plan berlaku untuk sesi berikutnya.

---

## 7. State Model and Timer Logic

Gunakan state eksplisit:

- `idle`: tidak ada sesi aktif.
- `active`: sesi sedang berjalan.
- `completed`: sesi telah selesai dan masuk history.

Contoh model:

```text
FastingPlan
- id: String
- name: String
- fastingHours: int
- eatingHours: int

FastingSession
- id: String
- planId: String
- planNameSnapshot: String
- startAt: DateTime
- endAt: DateTime?
- plannedDurationMinutes: int
- actualDurationSeconds: int?
- status: idle | active | completed
```

### Timer rule — sangat penting

Jangan membuat timer dengan pola `elapsedSeconds++` sebagai sumber data utama. Pola itu akan meleset ketika aplikasi masuk background, dihentikan sistem, atau perangkat tidur.

Gunakan timestamp:

```text
elapsed = currentDateTime - session.startAt
remaining = plannedDuration - elapsed
progress = clamp(elapsed / plannedDuration, 0, 1)
```

Timer UI boleh refresh setiap detik, tetapi nilai dasarnya selalu dihitung ulang dari `startAt`.

Ketentuan tambahan:
- Jika `remaining <= 0`, tampilkan target tercapai.
- Jangan otomatis mengakhiri sesi ketika target tercapai. Biarkan pengguna mengakhiri sesi.
- Simpan tanggal dalam format yang dapat diparse kembali.
- Tangani sesi aktif yang ditemukan ketika aplikasi dibuka ulang.
- Gunakan timezone lokal secara konsisten.
- Cegah dua sesi aktif sekaligus.
- Jika pengguna membatalkan sesi, tentukan apakah sesi dibuang atau disimpan sebagai `cancelled`. Untuk MVP, sesi yang belum selesai dapat dibuang setelah konfirmasi.

---

## 8. Data and Persistence

Untuk MVP sekolah, local-first lebih masuk akal daripada langsung membuat backend.

Pilihan penyimpanan bergantung pada stack:
- Flutter: `shared_preferences` untuk pengaturan sederhana; `Hive` atau `sqflite` untuk data sesi terstruktur.
- React Native: AsyncStorage untuk preferensi; SQLite untuk data sesi.
- Web prototype: localStorage untuk demo sederhana, IndexedDB jika data lebih kompleks.

Pisahkan:
- UI/presentation.
- Business logic.
- Data model.
- Local storage/repository.

Jangan menaruh seluruh logika timer dan penyimpanan di dalam satu widget/screen.

### Sample seed data

Gunakan data dummy hanya untuk preview/design mode. Tandai dengan jelas sebagai demo data dan jangan mencampurnya dengan data pengguna.

---

## 9. UI / UX Direction

### Visual direction

Rekomendasi: **calm, modern, minimal health-tech**.

Karakter:
- Bersih dan tenang.
- Fokus pada angka timer.
- Spacing konsisten.
- Card seperlunya, bukan setiap elemen harus menjadi card.
- Satu warna aksen utama.
- Tipografi sans-serif yang mudah dibaca.
- Hindari terlalu banyak gradient, glow, dan dekorasi.

Palet awal (dapat disesuaikan):
- Background: `#F7F8F5`
- Surface: `#FFFFFF`
- Primary: `#426B5A`
- Primary dark: `#294A3D`
- Text primary: `#202722`
- Text secondary: `#737D76`
- Border: `#E5E9E5`
- Warning: `#D99A45`
- Error: `#C65B54`

Dark mode bukan prioritas MVP.

### Typography

- Gunakan satu keluarga font sans-serif.
- Heading: semibold/bold.
- Body: regular.
- Timer: angka besar, tabular figures jika tersedia.
- Jangan menggunakan terlalu banyak ukuran font.

### Component rules

Buat komponen reusable:
- `PrimaryButton`
- `SecondaryButton`
- `FastingTimer`
- `ProgressIndicator`
- `PlanCard`
- `StatCard`
- `SessionHistoryTile`
- `EmptyState`
- `ConfirmationDialog`
- `AppBottomNavigation`

### Interaction states

Setiap komponen interaktif harus memiliki:
- Default.
- Pressed.
- Disabled.
- Loading (jika ada proses asynchronous).
- Selected (untuk plan/filter).
- Empty/error state bila relevan.

### Responsive and accessibility

- Uji pada ukuran layar kecil dan besar.
- Hindari overflow dan scroll horizontal yang tidak disengaja.
- Target sentuh ideal sekitar 44–48 dp.
- Jangan mengandalkan warna saja untuk membedakan status.
- Pastikan teks sekunder tetap terbaca.
- Beri label yang jelas pada icon-only buttons.

---

## 10. Suggested Technical Architecture

Jika menggunakan Flutter:

```text
lib/
  app/
    app.dart
    routes.dart
    theme/
      app_theme.dart
      app_colors.dart
      app_typography.dart

  features/
    home/
      presentation/
        home_screen.dart
        widgets/
          fasting_timer.dart
          active_session_card.dart
          quick_stats.dart

    fasting/
      data/
        fasting_repository.dart
        local_fasting_repository.dart
      domain/
        fasting_plan.dart
        fasting_session.dart
        fasting_timer_service.dart
      presentation/
        plan_selection_screen.dart
        session_summary_screen.dart

    history/
      presentation/
        history_screen.dart
        session_detail_screen.dart

    progress/
      presentation/
        progress_screen.dart

    profile/
      presentation/
        profile_screen.dart

  shared/
    widgets/
    utils/
```

Gunakan state management yang sudah dikuasai tim. Jangan menambah library hanya karena AI menyarankannya. Untuk proyek kecil, pendekatan sederhana dan konsisten lebih baik daripada arsitektur berlebihan.

Jika menggunakan stack lain, pertahankan pemisahan tanggung jawab yang sama.

---

## 11. Implementation Plan — Short Timeline

Urutan kerja yang disarankan:

### Phase 1 — Foundation
- Tetapkan nama sementara, stack, dan struktur project.
- Buat theme, typography, spacing, dan navigation.
- Buat semua screen dalam bentuk static UI.

### Phase 2 — Core interaction
- Implementasikan plan selection.
- Implementasikan Start/End.
- Implementasikan state idle/active/completed.
- Implementasikan timer berbasis timestamp.

### Phase 3 — Persistence and history
- Simpan plan dan sesi secara lokal.
- Muat ulang sesi aktif saat aplikasi dibuka.
- Tampilkan history dari data yang tersimpan.

### Phase 4 — Polish
- Perbaiki spacing, hierarchy, empty state, dan dialog.
- Uji layar kecil.
- Uji restart saat timer aktif.
- Perbaiki overflow, navigation, dan state yang tidak sinkron.

### Phase 5 — Optional
- Tambahkan progress summary atau water tracker hanya jika P0 stabil.

**Definition of Done:** pengguna dapat memilih plan, memulai sesi, menutup dan membuka aplikasi tanpa kehilangan timer, mengakhiri sesi, lalu melihat sesi tersebut di history.

---

## 12. Testing Checklist

### Functional
- [ ] Plan default tampil dengan benar.
- [ ] Pengguna dapat memilih plan lain.
- [ ] Start membuat tepat satu active session.
- [ ] Timer menghitung durasi berdasarkan timestamp.
- [ ] Timer tetap benar setelah app restart.
- [ ] End menyimpan end time dan durasi aktual.
- [ ] Sesi completed muncul di history.
- [ ] Tidak mungkin membuat dua sesi aktif.
- [ ] Empty state muncul jika belum ada history.
- [ ] Perubahan plan berlaku untuk sesi berikutnya.

### UI
- [ ] Tidak ada overflow.
- [ ] Tombol utama mudah ditemukan.
- [ ] Timer terbaca jelas.
- [ ] Selected state plan terlihat.
- [ ] Dialog konfirmasi berfungsi.
- [ ] Bottom navigation bekerja.
- [ ] Layout diuji pada setidaknya dua ukuran layar.

### Edge cases
- [ ] Aplikasi ditutup saat sesi aktif.
- [ ] Aplikasi dibuka kembali setelah target waktu lewat.
- [ ] Pengguna menekan Start berkali-kali.
- [ ] Pengguna menekan End lalu membatalkan dialog.
- [ ] Tidak ada sesi history.
- [ ] Data lokal kosong atau tidak dapat diparse.

---

## 13. Health, Safety, and Content Boundaries

Aplikasi ini adalah **habit/session tracker**, bukan alat diagnosis atau layanan medis.

- Jangan menjanjikan penurunan berat badan.
- Jangan menyatakan bahwa aplikasi dapat mencegah atau menyembuhkan penyakit.
- Jangan membuat klaim pasti tentang ketosis, detoksifikasi, pembakaran lemak, atau tahapan biologis berdasarkan timer saja.
- Jangan menganggap semua jadwal fasting cocok untuk semua orang.
- Jangan memberikan rekomendasi fasting personal berdasarkan data yang tidak dikumpulkan atau tidak divalidasi.
- Sediakan catatan bahwa pengguna dengan kondisi medis, pengguna yang hamil/menyusui, riwayat gangguan makan, atau pengguna yang masih dalam masa pertumbuhan perlu berkonsultasi dengan tenaga kesehatan sebelum mencoba pola puasa.
- Untuk proyek sekolah, tampilkan disclaimer singkat dan gunakan data demo yang tidak mendorong perilaku ekstrem.

Contoh disclaimer UI:

"Fasting Tracker is a tracking tool, not medical advice. Fasting may not be suitable for everyone. Consult a qualified healthcare professional if you are unsure whether fasting is appropriate for you."

---

# 14. Master Prompt for AI Coding Assistant

Salin prompt berikut sebagai instruksi utama ketika meminta AI membangun aplikasi.

```text
You are a senior mobile application engineer and product-minded UI/UX developer.

PROJECT
Build a mobile application called "Fasting Tracker" (working title), inspired by the product category and core workflow of GoFasting. This is a school project with a short development timeline. The goal is a polished, functional MVP, not a full commercial health platform.

PRODUCT GOAL
Help users select a fasting schedule, start and end a fasting session, see an accurate live timer, and review completed sessions.

SCOPE PRIORITY
P0 — Must implement:
1. Home dashboard.
2. Fasting plan selection: 14:10, 16:8, 18:6, 20:4.
3. Start fasting action.
4. Active fasting timer.
5. End fasting confirmation and session summary.
6. Session history.
7. Local persistence for plan and sessions.

P1 — Only after P0 works:
- Weekly summary.
- Manual weight log.
- Simple water tracker.
- Reminder settings UI.

Do not implement AI food scanning, barcode scanning, calorie databases, wearable integrations, authentication, cloud sync, subscriptions, ads, or social features unless explicitly requested.

CORE UX
The Home dashboard is the most important screen. It must clearly show:
- Current fasting status.
- A large, readable timer.
- Selected fasting plan and target duration.
- Progress indicator.
- One primary CTA.

When idle, the primary CTA is "Start Fasting".
When active, the primary CTA is "End Fasting".

Keep the interface calm, minimal, modern, and easy to understand. Use consistent spacing, typography, colors, and reusable components. Avoid excessive cards, gradients, decorative elements, and unnecessary screens.

TIMER ENGINEERING RULE
Do not use an incrementing counter as the source of truth.
Persist session.startAt as a timestamp.
Calculate elapsed time using currentDateTime - startAt.
Calculate progress from elapsed time / planned duration.
The UI may refresh every second, but must recalculate from timestamps.
The timer must remain accurate after app backgrounding, process termination, and restart.
Do not automatically end a session when the planned duration is reached.
Prevent more than one active session at a time.

DATA MODEL
FastingPlan:
- id
- name
- fastingHours
- eatingHours

FastingSession:
- id
- planId
- planNameSnapshot
- startAt
- endAt (nullable)
- plannedDurationMinutes
- actualDurationSeconds (nullable)
- status: active or completed

ARCHITECTURE
Separate presentation/UI, business logic, models, and persistence.
Use reusable widgets/components.
Keep state transitions explicit.
Do not place the entire application in one screen or one giant component.
Use the existing project structure and dependencies where possible.
Do not install new dependencies without explaining why they are necessary.

DATA RULES
Use local persistence for the MVP.
Do not fabricate user statistics.
Demo/seed data must be clearly identified as demo data.
Completed sessions must be derived from actual saved sessions.
Changing the selected plan should affect future sessions, not silently mutate an active session.

SCREENS
1. Home Dashboard.
2. Plan Selection.
3. History.
4. Session Summary/Detail.
5. Progress (optional).
6. Profile/Settings (minimal).

QUALITY
- No overflow on small screens.
- All visible buttons must work.
- Include empty, selected, disabled, and confirmation states where relevant.
- Use accessible contrast and readable typography.
- Handle app restart during an active session.
- Handle malformed or missing local data safely.
- Keep the code readable and maintainable.

HEALTH SAFETY
This is a tracking tool, not a medical application.
Do not provide diagnoses, medical recommendations, or promises about weight loss.
Do not claim that a timer can determine ketosis, detoxification, fat burning, or other biological states.
Include a concise disclaimer that fasting may not be suitable for everyone.

WORKING METHOD
Before coding:
1. Inspect the existing project and identify its framework, dependencies, and current structure.
2. Summarize the implementation plan.
3. Identify missing decisions instead of inventing requirements.
4. Implement one milestone at a time.

During coding:
1. Prefer small, reviewable changes.
2. Explain which files are created or modified.
3. Run available checks/builds after meaningful changes.
4. Fix errors before proceeding.
5. Do not rewrite unrelated code.

Do not start with every feature at once. First build the navigation and static Home UI, then implement the plan selection and timer state, then persistence and history, and finally polish the interface.
```

---

## 15. Prompt for AI UI Design

Gunakan prompt ini jika AI yang digunakan khusus untuk menghasilkan desain UI atau screen mockup.

```text
Design a polished mobile UI for a minimal intermittent fasting session tracker.

The primary screen is a Home Dashboard. The user should immediately understand:
1. Whether a fasting session is active.
2. How long the session has lasted.
3. The selected fasting schedule.
4. How much progress has been made.
5. What action they should take next.

Visual direction:
- Modern, calm, minimal health-tech.
- Light neutral background.
- Deep muted green as the primary accent.
- Clear typography and strong information hierarchy.
- Large timer as the visual focal point.
- Generous but efficient spacing.
- Rounded corners used consistently.
- Subtle borders and shadows only when useful.
- Professional, realistic mobile product design.

Required components:
- Compact top header.
- Fasting status label.
- Large timer/progress visualization.
- Primary Start Fasting or End Fasting button.
- Selected plan information.
- Two or three small summary metrics.
- Recent session list.
- Bottom navigation.

Avoid:
- Excessive gradients and neon colors.
- Too many cards.
- Decorative charts without meaningful data.
- Tiny text.
- Unnecessary illustrations.
- Fake health claims.
- Copying GoFasting branding or exact screen layouts.

Create clear variants for:
A. Idle state — no active fasting session.
B. Active state — fasting timer running.
C. Empty history state.
D. Plan selection state.

Keep the same design system across every screen.
```

---

## 16. AI Collaboration Rules

Untuk menghindari AI menghasilkan kode yang terlihat benar tetapi sulit dirawat:

1. Berikan dokumen ini sebagai product context sebelum meminta implementasi.
2. Minta AI memeriksa project yang sudah ada sebelum membuat file.
3. Minta satu screen atau satu milestone per instruksi.
4. Jangan menerima tombol yang hanya dekoratif.
5. Minta AI menjelaskan state dan data flow untuk fitur timer.
6. Review perubahan kode sebelum meminta fitur berikutnya.
7. Jangan biarkan AI menambahkan fitur di luar scope tanpa alasan.
8. Jalankan aplikasi dan uji interaksi nyata setelah setiap milestone.

### Suggested task sequence

```text
Task 1: Inspect the project and propose a clean implementation plan.
Task 2: Build the app theme, navigation, and static Home dashboard.
Task 3: Build the fasting plan selection screen.
Task 4: Implement the fasting session state and timestamp-based timer.
Task 5: Implement local persistence and app restart recovery.
Task 6: Implement end-session confirmation and session summary.
Task 7: Build history and empty states.
Task 8: Polish responsive layout and run functional tests.
```

---

## 17. Final MVP Acceptance Criteria

Proyek dianggap selesai ketika skenario berikut berjalan:

1. Pengguna membuka aplikasi dan melihat Home dashboard.
2. Pengguna memilih jadwal 16:8.
3. Pengguna menekan Start Fasting.
4. Dashboard berubah ke Active state dan timer berjalan.
5. Pengguna menutup aplikasi lalu membukanya kembali.
6. Timer menunjukkan durasi yang sesuai dengan waktu sebenarnya.
7. Pengguna menekan End Fasting dan mengonfirmasi.
8. Aplikasi menampilkan ringkasan sesi.
9. Sesi yang selesai muncul di History.
10. Pengguna dapat memulai sesi berikutnya tanpa merusak data sebelumnya.

**Prioritas akhir:** timer yang benar + dashboard yang jelas + alur Start/End yang solid lebih bernilai daripada sepuluh fitur tambahan yang setengah jadi.
