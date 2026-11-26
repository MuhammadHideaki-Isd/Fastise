# Fastise

Aplikasi Flutter untuk mencatat sesi _intermittent fasting_: memilih jadwal, memulai
dan mengakhiri sesi, melihat timer yang akurat, serta meninjau riwayat dan
statistik sederhana. Semua data disimpan lokal di perangkat.

Fastise adalah proyek sekolah (UJIKOM). Aplikasi ini **bukan alat medis** dan
tidak memberikan diagnosis atau rekomendasi kesehatan.

## Fitur

- **Dashboard** — status puasa, timer besar, progress ring, target selesai, dan
  satu CTA utama (`Start Fasting` / `End Fasting`).
- **Pilihan plan** — preset 14:10, 16:8, 18:6, dan 20:4 dengan selected state
  yang jelas.
- **Timer berbasis timestamp** — durasi dihitung dari `startAt`, bukan counter
  yang bertambah tiap detik. Timer tetap benar setelah aplikasi ditutup dan
  dibuka kembali.
- **End session** — dialog konfirmasi, penyimpanan waktu selesai dan durasi
  aktual, lalu halaman ringkasan.
- **Riwayat** — daftar sesi selesai, filter All / This week, detail sesi, dan
  empty state.
- **Progress** — total sesi, total durasi, rata-rata durasi, dan grafik 7/30
  hari yang dihitung dari sesi tersimpan.
- **Profil** — plan aktif, informasi privasi, catatan kesehatan, dan reset data
  dengan konfirmasi.
- **Local persistence** — plan, sesi aktif, dan riwayat disimpan dengan
  `shared_preferences`; sesi aktif dipulihkan saat aplikasi dibuka.

## Alur demo

1. Buka aplikasi — dashboard tampil dalam keadaan idle.
2. Ketuk kartu plan, pilih **16:8**, lalu **Save Plan**.
3. Ketuk **Start Fasting**.
4. Pastikan dashboard berubah ke state aktif dan timer berjalan.
5. Tutup aplikasi, lalu buka kembali.
6. Pastikan timer menunjukkan durasi sebenarnya (bukan mulai dari nol).
7. Ketuk **End Fasting**, lalu konfirmasi.
8. Lihat halaman **Session summary** dan ketuk **Done**.
9. Buka tab **History** — sesi muncul dengan durasi dan plan yang benar.
10. Mulai sesi baru; riwayat sebelumnya tetap utuh.

## Teknologi dan arsitektur

- Flutter stable (diuji dengan Flutter 3.47.4 / Dart 3.13.3)
- `shared_preferences` untuk penyimpanan lokal
- `ChangeNotifier` + `InheritedNotifier` untuk state aplikasi (tanpa package
  state management tambahan)

```text
lib/
  app/
    app.dart                 # App shell + bottom navigation
    theme/                   # Warna dan tema
  features/
    fasting/
      application/           # FastingController + scope
      data/                  # FastingRepository (local storage)
      domain/                # FastingPlan, FastingSession, FastingStats
      presentation/          # Plan selection, summary, detail, history tile
    home/presentation/       # Dashboard + timer widget
    progress/presentation/   # Statistik 7/30 hari
    history/presentation/    # Riwayat sesi
    profile/presentation/    # Profil dan reset data
  shared/
    utils/                   # Formatter tanggal/durasi
    widgets/                 # EmptyState, StatCard, ConfirmationDialog
test/                        # Unit, widget, layout, dan acceptance test
```

Pemisahan tanggung jawab: UI tidak menghitung timer sendiri, tidak menyimpan
data langsung, dan tidak membaca storage secara langsung.

## Menjalankan

Prasyarat: Flutter stable sudah terpasang dan `flutter doctor` bersih untuk
platform yang dipakai.

```bash
flutter pub get
flutter run
```

Untuk web:

```bash
flutter run -d chrome
```

## Pengujian

```bash
flutter analyze
flutter test
```

Status terakhir: `flutter analyze` tanpa issue, **64 test lulus**, `flutter build
web --release` berhasil, dan debug APK berhasil dibangun. Test
`test/acceptance_test.dart` mencakup alur lengkap dari memilih plan, start,
restart aplikasi, end, melihat history, sampai memulai sesi berikutnya.

## Data dan privasi

- Tidak ada akun, backend, cloud sync, analytics, atau iklan.
- Semua data tersimpan di perangkat melalui `shared_preferences`.
- Tanggal disimpan dalam ISO 8601 UTC dan ditampilkan dalam timezone lokal.
- Data yang rusak atau tidak terbaca diabaikan dengan aman (fallback ke default).
- **Reset all data** menghapus plan, sesi aktif, dan seluruh riwayat.

## Batasan yang diketahui

- UI masih berbahasa Inggris dan format tanggal ditulis manual (belum
  localization).
- Fitur P1 yang belum dibuat: weight log, water tracker, reminder, dan dark mode.
- Build release Android belum diverifikasi; artefak yang tersedia adalah debug
  APK.
- Penulisan storage bersifat fire-and-forget; pada kondisi ekstrem aplikasi
  dimatikan tepat setelah End, ada kemungkinan data aktif dan completed sempat
  tidak sinkron.
- Belum ada versioning/migrasi untuk format JSON yang tersimpan.

## Dokumen proyek

- [`Blueprint.md`](Blueprint.md) — spesifikasi produk, scope, state model, dan
  acceptance criteria.
- [`antigravity-instruction.md`](antigravity-instruction.md) — aturan kerja dan
  13 task implementasi (acuan tunggal urutan task).
- [`IMPLEMENTATION_LOG.md`](IMPLEMENTATION_LOG.md) — status task, keputusan
  arsitektur, hasil verifikasi, dan known limitations.

## Disclaimer

Fastise adalah alat pencatat sesi, bukan alat medis. Puasa tidak cocok untuk
semua orang. Konsultasikan dengan tenaga kesehatan jika Anda memiliki kondisi
medis, sedang hamil atau menyusui, memiliki riwayat gangguan makan, atau masih
dalam masa pertumbuhan.

Proyek ini terinspirasi dari kategori produk aplikasi fasting tracker
(seperti GoFasting), tetapi tidak menyalin branding, aset, atau layout layar
produk tersebut.
