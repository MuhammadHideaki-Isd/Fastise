# Implementation Log — Fastise

Dokumen ini mencatat status implementasi aktual, keputusan arsitektur, dan hasil
verifikasi. Spesifikasi produk tetap mengacu pada [`Blueprint.md`](Blueprint.md);
urutan kerja mengacu pada [`antigravity-instruction.md`](antigravity-instruction.md).

## Current status

- **Last completed task:** Task 13 — Final MVP verification
- **Next required task:** None (seluruh P0 dan task 1–13 selesai)
- **Optional next steps:** screenshot/dokumentasi visual, fitur P1 yang ditunda,
  build release, localization
- **Current blockers:** None
- **Last verification:** 25 November 2026

## Project snapshot

- Framework: Flutter stable 3.47.4, Dart 3.13.3.
- Package: `fastise`, display name **Fastise**.
- Storage: `shared_preferences` (satu-satunya dependency tambahan).
- State: `ChangeNotifier` + `InheritedNotifier`; tanpa package state management.
- Test suite: 10 file test, 64 test lulus.
- Analyzer: `flutter analyze` tanpa issue.
- Artefak: debug APK tersedia di `build/app/outputs/flutter-apk/app-debug.apk`.

## Task progress

- [x] Task 1 — Project inspection
- [x] Task 2 — App foundation (theme, navigation, shell)
- [x] Task 3 — Static Home UI
- [x] Task 4 — Fasting plan
- [x] Task 5 — Session model and state
- [x] Task 6 — Timestamp-based timer
- [x] Task 7 — Local persistence and recovery
- [x] Task 8 — End flow and session summary
- [x] Task 9 — History
- [x] Task 10 — Progress
- [x] Task 11 — Profile and settings
- [x] Task 12 — UI polish and responsive checks
- [x] Task 13 — Final verification

## Completed task notes

### Task 1 — Project inspection

- Mengidentifikasi project Flutter, entry point, dependency awal, dan struktur
  `lib/` yang masih berisi template counter.
- Baseline saat itu: `flutter pub get` sukses dan `flutter analyze` bersih.
- Tidak ada perubahan kode; hasil inspeksi menjadi dasar rencana task berikutnya.

### Task 2 — App foundation

- `lib/main.dart` — inisialisasi `SharedPreferences`, membuat controller, dan
  menjalankan aplikasi.
- `lib/app/app.dart` — `FastiseApp`, app shell, dan bottom navigation empat tab
  (Home, Progress, History, Profile).
- `lib/app/theme/app_colors.dart`, `lib/app/theme/app_theme.dart` — token warna,
  tipografi, card, button, navigation bar, dan input.
- Placeholder screen dibuat agar semua tab dapat dibuka.

### Task 3 — Static Home UI

- `lib/features/home/presentation/home_screen.dart` — header, tanggal, sapaan,
  kartu plan, quick stats, dan recent activity.
- `lib/features/home/presentation/widgets/fasting_hero_card.dart` — hero timer,
  status, start/target info, dan CTA.
- `lib/features/home/presentation/widgets/fasting_timer.dart` — timer ring dan
  angka `HH:MM:SS`.
- `lib/shared/widgets/stat_card.dart`, `lib/shared/widgets/empty_state.dart`.

### Task 4 — Fasting plan

- `lib/features/fasting/domain/fasting_plan.dart` — preset 14:10, 16:8, 18:6,
  20:4 dan default 16:8.
- `lib/features/fasting/presentation/plan_selection_screen.dart` — kartu plan,
  selected state, info fasting/eating window, disclaimer, dan `Save Plan`.
- Plan aktif ditampilkan di Home dan Profile; perubahan plan berlaku untuk sesi
  berikutnya.

### Task 5 — Session model and state

- `lib/features/fasting/domain/fasting_session.dart` — model sesi dengan
  `startAt`, `endAt`, `plannedDurationMinutes`, `actualDurationSeconds`, dan
  status active/completed; serialization aman terhadap data rusak.
- `lib/features/fasting/application/fasting_controller.dart` — start, end,
  cancel, reset, pencegahan dua sesi aktif, dan snapshot plan.
- `lib/features/fasting/application/fasting_scope.dart` — akses state ke widget.

### Task 6 — Timestamp-based timer

- Elapsed, remaining, progress, dan target end dihitung dari `startAt` pada
  `FastingSession`.
- UI timer me-refresh tiap detik hanya untuk repaint; sumber kebenaran tetap
  timestamp.
- Sesi aktif dipulihkan saat aplikasi dibuka kembali.
- Target tercapai tidak mengakhiri sesi otomatis; pengguna tetap memutuskan.
- Test: `test/home_timer_test.dart`, `test/fasting_controller_test.dart`.

### Task 7 — Local persistence and recovery

- `lib/features/fasting/data/fasting_repository.dart` — baca/tulis plan, sesi
  aktif, dan daftar sesi completed dalam JSON melalui `shared_preferences`.
- Data hilang/rusak/tipe tidak terduga ditangani tanpa melempar exception.
- Sesi active dipulihkan saat startup; sesi completed diurutkan terbaru dulu.
- Test: `test/fasting_repository_test.dart`.

### Task 8 — End flow and session summary

- `lib/shared/widgets/confirmation_dialog.dart` — dialog konfirmasi reusable.
- End flow menyimpan `endAt` dan durasi aktual, menampilkan summary, lalu kembali
  ke dashboard idle.
- Cancel dialog tidak mengubah sesi; discard session tidak masuk history.
- Durasi aktual ditampilkan netral (tidak dilabeli gagal).
- Test: `test/end_flow_test.dart`.

### Task 9 — History

- `lib/features/history/presentation/history_screen.dart` — daftar sesi,
  grouping tanggal, filter All / This week, counter, dan empty state.
- `lib/features/fasting/presentation/session_history_tile.dart` — durasi, plan,
  rentang waktu, progress bar, dan akses detail.
- `lib/features/fasting/presentation/session_details.dart` — bottom sheet detail
  sesi.
- Test: `test/history_test.dart`.

### Task 10 — Progress

- `lib/features/fasting/domain/fasting_stats.dart` — total, rata-rata, filter
  rentang, dan agregasi harian dari sesi completed.
- `lib/features/progress/presentation/progress_screen.dart` — ringkasan 7/30
  hari, total sesi, total durasi, rata-rata, dan grafik batang.
- Home menampilkan quick stats minggu berjalan dari data yang sama.
- Tidak ada data demo atau angka fabrikasi.
- Test: `test/progress_test.dart`.

### Task 11 — Profile and settings

- `lib/features/profile/presentation/profile_screen.dart` — plan aktif, edit
  plan, informasi aplikasi, privacy note, health note, dan reset data.
- Reset data memakai konfirmasi dan menghapus plan, sesi aktif, serta history.
- Test: `test/profile_test.dart`.

### Task 12 — UI polish and responsive checks

- Penyempurnaan tema, kontras teks sekunder, timer ring, plan cards, dialog,
  history tile, summary, dan empty state.
- Layout dibatasi `maxWidth: 600` dan diuji pada ukuran ponsel kecil, ponsel
  biasa, tablet, serta text scale besar.
- Test: `test/layout_test.dart`, `test/widget_test.dart`.

### Task 13 — Final verification

- `test/acceptance_test.dart` menjalankan skenario Blueprint §17:
  pilih plan → start → restart → timer akurat → end → summary → history →
  sesi baru tanpa merusak data lama.
- Konfigurasi Android memakai AGP 9.1.1 dan Kotlin 2.4.0.
- Build debug APK berhasil dibuat.
- Verifikasi akhir: analyzer bersih dan 64 test lulus.

### Post-task — UI refinement

- Commit `a65e9e1` merapikan tema, komponen presentasi, plan selection, history,
  progress, profile, dan timer.
- Tidak ada perubahan scope produk.

## Architecture decisions

1. **Local-first, tanpa backend.** Tidak ada akun, autentikasi, cloud sync, atau
   analytics. Semua data berada di perangkat.
2. **`shared_preferences` untuk semua data MVP.** Blueprint menyarankan Hive atau
   sqflite untuk sesi terstruktur; implementasi memilih `shared_preferences` agar
   dependency tetap minimal dan volume data proyek sekolah masih kecil. Semua
   sesi disimpan sebagai satu JSON list; setiap perubahan menulis ulang list.
   Konsekuensinya: belum ada migrasi/versioning dan performa akan menurun jika
   history sangat besar.
3. **Timestamp sebagai sumber kebenaran.** Tidak ada `elapsedSeconds++`; elapsed,
   remaining, progress, dan target end selalu diturunkan dari `startAt`.
4. **UTC untuk storage, lokal untuk tampilan.** `startAt`/`endAt` disimpan sebagai
   ISO 8601 UTC lalu diubah ke timezone lokal saat dibaca.
5. **Satu sesi aktif.** `startFasting()` tidak melakukan apa pun jika sudah ada
   sesi aktif, sehingga double tap tidak membuat sesi ganda.
6. **Plan snapshot.** Sesi menyimpan `planId` dan `planNameSnapshot`; perubahan
   plan tidak mengubah target sesi yang sedang berjalan.
7. **Cancel = discard.** Untuk MVP, sesi yang dibatalkan setelah konfirmasi
   dibuang dan tidak masuk history.
8. **Tidak auto-end.** Mencapai target hanya menandai “Target reached”; sesi tetap
   berjalan sampai pengguna mengakhiri.
9. **Statistik hanya dari sesi completed.** Tidak ada seed data yang terlihat
   seperti data pengguna. Minggu dimulai Senin; agregasi harian memakai tanggal
   mulai sesi.
10. **State sederhana.** `ChangeNotifier` + `InheritedNotifier` dianggap cukup
    untuk skala aplikasi; tidak menambah package state management.

## Implemented vs deferred

| Scope | Status | Catatan |
|---|---|---|
| Dashboard + timer | Selesai | Termasuk idle/active state |
| Plan 14:10, 16:8, 18:6, 20:4 | Selesai | Plan selection + persistence |
| Start/End/Cancel session | Selesai | Konfirmasi + summary |
| Local persistence + recovery | Selesai | `shared_preferences` |
| History + detail + filter | Selesai | All / This week |
| Progress 7/30 hari | Selesai | P1 yang sempat dikerjakan |
| Profile + reset data | Selesai | Dengan konfirmasi |
| Onboarding | Ditunda | Opsional di Blueprint |
| Weight log | Ditunda | P1 |
| Water tracker | Ditunda | P1 |
| Reminder UI/notification | Ditunda | P1 |
| Dark mode | Ditunda | P1 |
| AI food scanner, barcode, cloud, akun, sosial | Tidak dikerjakan | P2 / out of scope |

## Verification evidence

Per 25 November 2026 (setelah perapian dokumen dan metadata branding):

```text
flutter analyze  -> No issues found! (6.8s)
flutter test     -> 00:10 +64: All tests passed!
flutter build web --release -> Built build\web
flutter build apk --debug   -> Built build\app\outputs\flutter-apk\app-debug.apk
```

Cakupan test:

- `acceptance_test.dart` — alur end-to-end + restart.
- `fasting_controller_test.dart` — transisi state, double start, plan snapshot.
- `fasting_repository_test.dart` — persistence, data rusak, recovery.
- `home_timer_test.dart` — perhitungan timer dan target.
- `end_flow_test.dart` — konfirmasi, cancel, summary.
- `history_test.dart`, `progress_test.dart`, `profile_test.dart` — layar dan data.
- `layout_test.dart` — overflow pada beberapa ukuran layar dan text scale.
- `widget_test.dart` — dashboard idle dan navigasi.

Yang **belum** diverifikasi ulang pada sesi ini:

- Menjalankan aplikasi di emulator/perangkat fisik secara manual.
- Build release Android/iOS/desktop.
- Notifikasi, dark mode, dan fitur P1 yang ditunda.

## Known limitations

- Penulisan storage memakai `unawaited(...)`. Jika proses mati tepat di antara
  penyimpanan completed dan penghapusan active, sesi dapat muncul di history
  sekaligus masih aktif saat restart berikutnya.
- Tidak ada penanganan error yang terlihat pengguna jika penulisan storage gagal.
- Home menghitung tanggal dan statistik saat build; jika aplikasi dibiarkan
  terbuka melewati tengah malam, teks tanggal/minggu baru berubah setelah ada
  rebuild.
- Format tanggal dan seluruh UI masih berbahasa Inggris, ditulis manual tanpa
  `intl`.
- Belum ada migrasi/versioning untuk JSON yang tersimpan.
- Debug APK berukuran besar karena mode debug; belum ada release build final.

## Dokumen acuan

- `Blueprint.md` — sumber kebenaran produk dan acceptance criteria.
- `antigravity-instruction.md` — aturan kerja dan 13 task (acuan tunggal urutan
  task).
- `README.md` — ringkasan proyek, cara menjalankan, dan alur demo.

Duplikat dokumen lama (`fasting_tracker_product_blueprint (1).md` dan
`antigravity_task_by_task_instructions.md`) dihapus karena isinya identik
byte-per-byte dengan dua dokumen acuan di atas.
