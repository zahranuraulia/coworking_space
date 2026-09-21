# Dokumentasi Aplikasi Reservasi Coworking Space & Workstation (NexusSpace)

Aplikasi Reservasi Coworking Space & Workstation adalah aplikasi mobile berbasis **Flutter** yang dikembangkan untuk memenuhi kebutuhan teknis **Uji Kompetensi Keahlian (UKK) Rekayasa Perangkat Lunak (RPL) Tahun Pelajaran 2026/2027: Paket B**.

Dokumen ini disusun secara rinci, terstruktur, dan ramah bagi pemula agar siapapun dapat memahami cara kerja aplikasi, arsitektur yang digunakan, alur pengguna (user flow), integrasi API, serta struktur kodenya.

---

## Daftar Isi
1. [Gambaran Umum & Konsep Aplikasi](#1-gambaran-umum--konsep-aplikasi)
2. [Teknologi & Dependensi yang Digunakan](#2-teknologi--dependensi-yang-digunakan)
3. [Pola Arsitektur Aplikasi](#3-pola-arsitektur-aplikasi)
4. [Struktur Direktori & Tanggung Jawab Berkas](#4-struktur-direktori--tanggung-jawab-berkas)
5. [Daftar Endpoint API yang Diterapkan](#5-daftar-endpoint-api-yang-diterapkan)
6. [Alur Pengguna (User Flow)](#6-alur-pengguna-user-flow)
7. [Daftar Service & Tanggung Jawabnya](#7-daftar-service--tanggung-jawabnya)
8. [Logika Khusus & Solusi Teknis (Under the Hood)](#8-logika-khusus--solusi-teknis-under-the-hood)
9. [Desain Sistem Visual (Stitch UI NexusSpace)](#9-desain-sistem-visual-stitch-ui-nexusspace)
10. [Panduan Menjalankan & Menguji Aplikasi](#10-panduan-menjalankan--menguji-aplikasi)

---

## 1. Gambaran Umum & Konsep Aplikasi

Aplikasi ini melayani sistem penyewaan ruangan kerja (*meeting room*, *private office*) dan meja workstation (*personal desk*) secara online. Sistem membedakan dua peran pengguna utama:
1. **Member / Pengunjung**: Pengguna yang mencari ruangan kerja, memilih durasi sewa, menerapkan kupon diskon, memantau status pemesanan, mencetak bukti nota E-Tiket ber-QR code, serta melihat riwayat pengeluaran bulanan.
2. **Admin Pengelola Space**: Pemilik atau manajer lokasi yang mengelola ketersediaan ruangan, melakukan operasional check-in/check-out tamu di lokasi, mengelola kupon promo, mengelola data pelanggan, memantau grafik rekapitulasi omset pendapatan, dan memperbarui identitas lokasi coworking.

### Mekanisme Multi-Tenancy (App Maker)
Untuk memastikan data antar siswa tidak saling tertimpa di server panitia selama ujian:
- Aplikasi menggunakan header wajib `x-maker-key: mk_fb696f19a77243f88b87592080b7bb6d`.
- Server secara otomatis mengisolasi data ruangan, member, voucher promo, dan reservasi hanya untuk pembuat aplikasi yang terdaftar pada Maker Key tersebut.

---

## 2. Teknologi & Dependensi yang Digunakan

Aplikasi dibangun menggunakan teknologi modern:
- **Framework Utama**: Flutter SDK (Dart 3+)
- **HTTP Client**: `dio: ^5.11.1` (Singleton dengan interceptor token dan error handler terpusat)
- **State Persistence**: `shared_preferences: ^2.5.5` (Penyimpanan token JWT dan sesi peran pengguna)
- **Formatting Tanggal & Mata Uang**: `intl: ^0.20.3` (Format tanggal Indonesia dan angka Rupiah)
- **QR Code Rendering**: `qr_flutter: ^4.1.0` (Render visual barcode QR pada E-Tiket untuk check-in)
- **Media & Kamera**: `image_picker: ^1.2.3` (Mengambil foto ruangan kerja dari galeri/kamera)
- **Tipografi**: `google_fonts: ^6.2.1` (Keluarga font resmi *Plus Jakarta Sans*)

---

## 3. Pola Arsitektur Aplikasi

Aplikasi menerapkan pola **Layered Service-Oriented Architecture** yang bersih dan modular. Setiap lapisan kode memiliki batasan tanggung jawab yang jelas (*Separation of Concerns*):

```
┌─────────────────────────────────────────────────────────┐
│               PRESENTATION LAYER (UI)                   │
│   • Screens (Layar Tampilan Member & Admin)             │
│   • Widgets (Komponen Atomik: Button, Card, Badge, Bar) │
└───────────────────────────▲─────────────────────────────┘
                            │ Memanggil data siap pakai
┌───────────────────────────┴─────────────────────────────┐
│                 SERVICE LAYER (Logika API)              │
│   • AuthService, SpaceService, ReservationService, dll. │
└───────────────────────────▲─────────────────────────────┘
                            │ Memproses JSON mentah
┌───────────────────────────┴─────────────────────────────┐
│                 MODEL LAYER (Data Blueprint)            │
│   • Space, Reservation, Discount, Member, ETicket, dll. │
└───────────────────────────▲─────────────────────────────┘
                            │ Melakukan HTTP Request
┌───────────────────────────┴─────────────────────────────┐
│             CORE NETWORK LAYER (ApiClient Singleton)    │
│   • Dio instance terpusat, x-maker-key, Bearer JWT, SSL │
└─────────────────────────────────────────────────────────┘
```

### Mengapa Pola Ini Ramah untuk Pemula?
- **UI Tidak Mengurus HTTP Request**: Halaman tampilan (`Screen`) tidak perlu tahu format URL, header, atau status code HTTP. Cukup memanggil fungsi sederhana seperti `spaceService.getSpaces()`.
- **Penanganan Error Terpusat**: Seluruh error jaringan (misal timeout, 401 Unauthorized, 404 Not Found) diubah menjadi objek `ApiException` yang menghasilkan pesan berbahasa Indonesia yang ramah pengguna.
- **Data Kuat & Aman dari Crash**: Semua respon JSON diubah menjadi objek model Dart yang memiliki proteksi terhadap nilai `null` (*null-safety*).

---

## 4. Struktur Direktori & Tanggung Jawab Berkas

```
lib/
├── main.dart                                # Titik masuk aplikasi & konfigurasi rute navigasi
│
├── core/                                    # Fondasi sistem terpusat
│   ├── constants/
│   │   ├── api_constants.dart               # Daftar endpoint URL dan Maker Key
│   │   └── app_constants.dart               # Konstanta tipe space dan status booking
│   ├── network/
│   │   ├── api_client.dart                  # Singleton Dio, header x-maker-key, auth interceptor
│   │   └── api_exception.dart               # Custom domain exception untuk layer UI
│   ├── theme/
│   │   ├── app_colors.dart                  # Token palet warna resmi Stitch (Midnight Navy, Slate)
│   │   └── app_theme.dart                   # Global ThemeData (Plus Jakarta Sans, card 16dp)
│   └── utils/
│       ├── currency_formatter.dart          # Format Rupiah standar (contoh: Rp 25.000)
│       ├── image_helper.dart                # Normalisasi URL gambar reverse-proxy & HTTPS
│       └── reservation_helper.dart          # Ekstraksi harga bersarang, space, dan format tanggal
│
├── models/                                  # Data blueprint (fromJson & toJson)
│   ├── admin_profile.dart                   # Model profil lokasi coworking
│   ├── discount.dart                        # Model promo diskon (mendukung format flat & nested)
│   ├── e_ticket.dart                        # Model nota digital & payload QR code
│   ├── member.dart                          # Model data pelanggan coworking
│   ├── reservation.dart                     # Model reservasi & detail harga
│   ├── revenue_report.dart                  # Model laporan omset & tren harian
│   ├── space.dart                           # Model unit ruangan kerja & workstation
│   └── user.dart                            # Model pengguna & peran (member / admin_space)
│
├── services/                                # Layer komunikasi API backend
│   ├── admin_service.dart                   # CRUD space admin, profil lokasi, laporan bulanan
│   ├── auth_service.dart                    # Login terpadu, register member, register admin, logout
│   ├── discount_service.dart                # Validasi kode promo, list diskon aktif, CRUD admin
│   ├── e_ticket_service.dart                # Ambil nota digital E-Tiket
│   ├── member_service.dart                  # CRUD data member pelanggan oleh admin
│   ├── reservation_service.dart             # Buat booking, histori, pembatalan, check-in & check-out
│   ├── space_service.dart                   # Katalog publik ruangan & cek ketersediaan jam
│   └── upload_service.dart                  # Upload berkas gambar multipart
│
├── screens/                                 # Antarmuka Pengguna (UI)
│   ├── auth/                                # Layar Autentikasi
│   │   ├── login_screen.dart                # Login universal + dialog deteksi akun panitia
│   │   ├── member_register_screen.dart      # Form registrasi member + konfirmasi sandi & terms
│   │   └── admin_register_screen.dart       # Form registrasi lokasi & admin coworking
│   ├── member/                              # Panel Layar Pengguna (Member)
│   │   ├── member_navbar_screen.dart        # 4 Tab Navigasi Bawah (Beranda, Reservasi, Histori, Akun)
│   │   ├── member_dashboard_screen.dart     # Katalog space, pencarian, filter chips tipe
│   │   ├── booking_screen.dart              # Form booking, pemilih jam, auto-apply kupon promo
│   │   ├── my_booking_screen.dart           # Status reservasi (6 filter chips status) + detail modal
│   │   ├── member_history_screen.dart       # Histori bulanan, rekap pengeluaran, buka E-Tiket
│   │   └── e_ticket_screen.dart             # Visual nota punch-card, QR Code, aksi simpan/bagikan
│   └── admin/                               # Panel Layar Pengelola (Admin Space)
│       ├── admin_navbar_screen.dart         # 5 Tab Navigasi Bawah (Dashboard, Reservasi, Space, Diskon, Member)
│       ├── admin_dashboard_screen.dart      # Ringkasan matriks booking, alert akun panitia
│       ├── reservations/
│       │   ├── admin_reservations_screen.dart  # Data reservasi lengkap + filter bulan + quick approve
│       │   └── reservation_detail_screen.dart  # Detail operasional, timeline status, check-in & check-out
│       ├── spaces/
│       │   ├── admin_space_list_screen.dart    # Katalog space admin + aksi tambah/edit/hapus
│       │   └── admin_space_form_screen.dart    # Form upload foto fisik ruangan, fasilitas, tarif
│       ├── discounts/
│       │   └── admin_discount_screen.dart      # Kelola promo voucher, kupon card, modal tambah promo
│       ├── members/
│       │   └── admin_member_screen.dart        # Direktori member, cari pelanggan, tambah/edit member
│       ├── reports/
│       │   └── admin_revenue_report_screen.dart# Rekapitulasi omset, kurva tren harian, progress bar space
│       └── profile/
│           └── admin_profile_screen.dart       # Pengaturan identitas coworking, nama pemilik, kontak
│
└── widgets/                                 # Komponen UI Reusable (Stitch NexusSpace)
    ├── stitch_app_bar.dart                  # Top bar ramping 48dp, tombol kembali bulat putih
    ├── app_button.dart                      # Tombol 44dp (Primary, Secondary, Outline, Danger)
    ├── app_text_field.dart                  # Input teks seragam (12dp radius, ikon prefix, password toggle)
    ├── space_card.dart                      # Kartu ruangan Stitch (16dp radius, cover 84dp, tag tipe)
    ├── reservation_card.dart                # Kartu reservasi Stitch dengan status dot berwarna
    ├── status_badge.dart                    # Stadium pill badge dengan titik status bulat
    ├── dashed_divider.dart                  # Garis putus-putus untuk kupon voucher & nota
    ├── loading_widget.dart                  # Indikator loading spinner ramah pengguna
    └── empty_state_widget.dart              # Tampilan saat data kosong atau error (Antislop R-27)
```

---

## 5. Daftar Endpoint API yang Diterapkan

Berikut adalah pemetaan seluruh endpoint yang dikonsumsi oleh aplikasi Flutter dari backend server:

| Kategori | Method | Endpoint URL | Fungsi dalam Aplikasi | File Pemanggil |
|---|---|---|---|---|
| **Auth** | `POST` | `/api/auth/login` | Login universal Member / Admin | `AuthService.login` |
| **Auth** | `POST` | `/api/auth/register/member` | Pendaftaran akun member baru | `AuthService.registerMember` |
| **Auth** | `POST` | `/api/auth/register/admin-space` | Pendaftaran akun admin & lokasi | `AuthService.registerAdmin` |
| **Auth** | `GET` | `/api/auth/profile` | Mengambil profil user yang sedang login | `AuthService.checkSession` |
| **Katalog Space** | `GET` | `/api/spaces` | Daftar seluruh ruangan kerja aktif | `SpaceService.getSpaces` |
| **Katalog Space** | `GET` | `/api/spaces/{id}` | Detail satu ruangan kerja | `SpaceService.getSpaceDetail` |
| **Katalog Space** | `GET` | `/api/spaces/availability` | Validasi ketersediaan jam sewa | `SpaceService.checkAvailability` |
| **Katalog Space** | `GET` | `/api/spaces/types` | Daftar tipe space resmi | `SpaceService.getSpaceTypes` |
| **Diskon Publik** | `GET` | `/api/diskon/active` | Daftar voucher promo aktif | `DiscountService.getActiveDiscounts` |
| **Diskon Publik** | `POST` | `/api/diskon/check` | Validasi kode promo di checkout | `DiscountService.checkDiscount` |
| **Diskon Publik** | `GET` | `/api/diskon/{id}` | Detail kode promo publik | `DiscountService.getAdminDiscountDetail` |
| **Reservasi Member** | `POST` | `/api/reservasi` | Membuat pemesanan sewa baru | `ReservationService.createReservation` |
| **Reservasi Member** | `GET` | `/api/reservasi/my` | Daftar status booking milik sendiri | `ReservationService.getMyReservations` |
| **Reservasi Member** | `GET` | `/api/reservasi/my/history` | Histori & pengeluaran bulanan | `ReservationService.getReservationHistory` |
| **Reservasi Member** | `GET` | `/api/reservasi/{id}/e-ticket` | Nota digital & data QR Code | `ReservationService.getETicket` |
| **Reservasi Member** | `PATCH`| `/api/reservasi/{id}/cancel` | Membatalkan pemesanan space | `ReservationService.cancelReservation` |
| **Admin Ruangan** | `GET` | `/api/admin/spaces` | Daftar space milik admin | `AdminService.getSpaces` |
| **Admin Ruangan** | `POST` | `/api/admin/spaces` | Tambah space baru (Multipart) | `AdminService.createSpace` |
| **Admin Ruangan** | `GET` | `/api/admin/spaces/{id}` | Ambil data space untuk diedit | `AdminService.getSpaceDetail` |
| **Admin Ruangan** | `PUT` | `/api/admin/spaces/{id}` | Perbarui data space (Multipart) | `AdminService.updateSpace` |
| **Admin Ruangan** | `DELETE`| `/api/admin/spaces/{id}` | Hapus data ruangan kerja | `AdminService.deleteSpace` |
| **Admin Promo** | `GET` | `/api/admin/diskon` | Daftar semua kupon diskon admin | `DiscountService.getAdminDiscounts` |
| **Admin Promo** | `POST` | `/api/admin/diskon` | Tambah kupon promo baru | `DiscountService.createDiscount` |
| **Admin Promo** | `PUT` | `/api/admin/diskon/{id}` | Perbarui kode diskon | `DiscountService.updateDiscount` |
| **Admin Promo** | `DELETE`| `/api/admin/diskon/{id}` | Hapus kupon promo | `DiscountService.deleteDiscount` |
| **Admin Member** | `GET` | `/api/admin/members` | Daftar member & pencarian | `MemberService.getMembers` |
| **Admin Member** | `POST` | `/api/admin/members` | Tambah member baru oleh admin | `MemberService.createMember` |
| **Admin Member** | `PUT` | `/api/admin/members/{id}` | Edit data profil member | `MemberService.updateMember` |
| **Admin Member** | `DELETE`| `/api/admin/members/{id}` | Hapus data akun member | `MemberService.deleteMember` |
| **Admin Operasional**| `GET` | `/api/admin/reservasi` | Filter jadwal reservasi tamu | `ReservationService.getAdminReservations` |
| **Admin Operasional**| `PATCH`| `/api/admin/reservasi/{id}/status` | Konfirmasi status (Setujui/Tolak)| `ReservationService.updateReservationStatus` |
| **Admin Operasional**| `POST` | `/api/admin/reservasi/{id}/check-in` | Check-in tamu (Status -> Aktif) | `ReservationService.checkInReservation` |
| **Admin Operasional**| `POST` | `/api/admin/reservasi/{id}/check-out`| Check-out tamu (Status -> Selesai)| `ReservationService.checkOutReservation` |
| **Admin Laporan** | `GET` | `/api/admin/reports/monthly` | Omset bulanan & tren harian | `AdminService.getMonthlyReport` |
| **Admin Profil** | `GET` | `/api/admin/profile` | Ambil identitas lokasi space | `AdminService.getProfile` |
| **Admin Profil** | `PUT` | `/api/admin/profile` | Perbarui nama lokasi & kontak | `AdminService.updateProfile` |
| **Media Upload** | `POST` | `/api/upload/spaces` | Upload foto ruangan (.jpg/.png) | `UploadService.uploadSpacePhoto` |
| **Media Upload** | `POST` | `/api/upload/members` | Upload foto profil member | `UploadService.uploadMemberPhoto` |
| **Media Upload** | `POST` | `/api/upload/image` | Upload gambar umum | `UploadService.uploadGeneralImage` |

---

## 6. Alur Pengguna (User Flow)

### A. Alur Autentikasi & Masuk (Universal Login Flow)
1. Pengguna membuka aplikasi dan disambut layar `LoginScreen`.
2. Jika belum memiliki akun:
   - Pilih **Daftar Sebagai Member** untuk masuk ke `MemberRegisterScreen`.
   - Pilih **Daftar Pengelola Space** untuk masuk ke `AdminRegisterScreen`.
3. Setelah memasukkan username dan kata sandi, `AuthService.login()` mengirim request ke `/api/auth/login`.
4. Sistem membaca peran pengguna dari token:
   - Jika `role == 'admin_space'`: Aplikasi mengecek apakah akun tersebut adalah akun global panitia (`admin_space1`). Jika ya, aplikasi menampilkan dialog konfirmasi edukatif sebelum masuk ke `AdminNavbarScreen`.
   - Jika `role == 'member'`: Pengguna langsung dialihkan ke `MemberNavbar`.

---

### B. Alur Pengguna Member (Visitor Booking Flow)
```
[Beranda: Pilih Space] 
       │
       ▼
[Booking Screen: Tentukan Tanggal & Jam Sewa]
       │
       ▼
[Pilih Voucher Promo Aktif ATAU Ketik Kode Kupon Manual]
       │
       ▼ (Subtotal terpotong secara instan dan transparan)
[Tekan "Konfirmasi Reservasi"]
       │
       ▼
[Masuk ke Tab "Reservasi": Status "Belum Dikonfirmasi"]
       │
       ▼ (Menunggu Admin Menyetujui)
[Status berubah "Disetujui" / "Aktif"]
       │
       ▼
[Buka "Lihat E-Tiket": Tampilkan QR Code untuk Check-in di Lokasi]
       │
       ▼
[Tab "Histori": Pantau Riwayat Pemesanan & Total Pengeluaran Bulanan]
```

---

### C. Alur Pengelola Space (Admin Operational Flow)
```
[Admin Dashboard: Ringkasan Jumlah Booking Hari Ini]
       │
       ▼
[Tab "Reservasi": Daftar Pemesanan Masuk]
       │
       ├─── Status "Belum Dikonfirmasi" ──► Tekan "Setujui" (Status menjadi "Disetujui")
       │
       ├─── Tamu Tiba di Lokasi ──────────► Tekan "Check-In" (Status menjadi "Aktif")
       │
       └─── Tamu Selesai Menggunakan ─────► Tekan "Check-Out" (Status menjadi "Selesai")
                                                   │
                                                   ▼
                     [Laporan Omset & Grafik Tren Pendapatan Otomatis Terupdate]
```

---

## 7. Daftar Service & Tanggung Jawabnya

| Nama Service | Berkas | Tanggung Jawab Utama |
|---|---|---|
| **`ApiClient`** | `core/network/api_client.dart` | Singleton HTTP client. Menambahkan header `x-maker-key`, menyisipkan header `Authorization: Bearer <token>`, mem-bypass verifikasi sertifikat SSL lokal, dan mengonversi error ke `ApiException`. |
| **`AuthService`** | `services/auth_service.dart` | Mengelola autentikasi login pengguna, pendaftaran akun baru, deteksi akun template seeder global, dan penghapusan sesi saat logout. |
| **`SpaceService`** | `services/space_service.dart` | Mengambil data katalog ruangan untuk umum, filter berdasarkan kategori space, dan pengecekan tabrakan jadwal (*slot availability*). |
| **`ReservationService`** | `services/reservation_service.dart` | Pembuatan pemesanan sewa baru, pembatalan reservasi member, pengambilan E-Tiket, dan operasional admin (ubah status, check-in, check-out). |
| **`DiscountService`** | `services/discount_service.dart` | Pengambilan kupon diskon aktif, validasi perhitungan potongan promo saat checkout, dan manajemen CRUD voucher promo oleh admin. |
| **`MemberService`** | `services/member_service.dart` | Direktori member coworking, pencarian nama member, serta penambahan, pembaruan, dan penghapusan data pelanggan. |
| **`AdminService`** | `services/admin_service.dart` | Manajemen unit space (dengan dukungan unggah berkas multipart), pengelolaan profil tempat coworking, dan penarikan laporan finansial bulanan. |
| **`UploadService`** | `services/upload_service.dart` | Mengunggah berkas foto fisik ruangan dan foto profil member menggunakan `FormData` multipart. |

---

## 8. Logika Khusus & Solusi Teknis (Under the Hood)

Selama pengujian integrasi dengan server panitia, ditemukan beberapa keunikan format backend yang telah diselesaikan dengan solusi teknis kokoh:

### 1. Ekstraksi Harga Tersembunyi (`ReservationHelper.extractPrice`)
- **Kendala**: Server tidak mengirim `total_bayar` pada level teratas objek reservasi. Sesuai skema database ERD (Hal. 4 PDF), harga disimpan di dalam tabel relasi `detail_reservasi`.
- **Solusi**: Dibuat fungsi cerdas `ReservationHelper.extractPrice(item)` yang secara berurutan mencari:
  1. `item['total_bayar']`
  2. `item['total_harga']`
  3. `item['detail_reservasi'][0]['total_harga']`
  4. `item['price_breakdown']['total_harga']`
  5. Perhitungan manual: `harga_per_jam * durasi_jam`.
  Hasilnya, harga tidak pernah bernilai Rp 0.

### 2. Normalisasi URL Gambar & Reverse Proxy (`ImageHelper.normalizeUrl`)
- **Kendala**: Backend mengembalikan URL gambar dalam format HTTP biasa:
  `http://learn.smktelkom-mlg.sch.id/uploads/spaces/<filename>`.
  URL ini memicu error 404 (karena server panitia menggunakan reverse proxy dengan subpath `/coworking/`) dan diblokir oleh sistem keamanan App Transport Security (ATS) iOS.
- **Solusi**: Dibuat `ImageHelper.normalizeUrl()` yang otomatis:
  1. Mengubah protokol menjadi `https://`.
  2. Menambahkan subpath `/coworking/uploads/` sehingga foto menghasilkan status **HTTP 200 (Success)**.
  3. Mengonversi nama file mentah menjadi URL lengkap.

### 3. Unggah Berkas Fisik Ruangan (Multer Multipart)
- **Kendala**: Controller backend hanya menyimpan nama file foto jika request dikirim dalam bentuk `multipart/form-data` dengan field `foto`. Jika dikirim berupa string JSON, server mengabaikannya dan menyimpan nilai `null`.
- **Solusi**: `AdminService.createSpace` dan `updateSpace` menggunakan `FormData.fromMap` yang membungkus berkas foto ke dalam `MultipartFile.fromFile(localFilePath)`. Foto ruangan kini tersimpan 100% di server.

### 4. Sinkronisasi Dropdown & Validasi Kupon Promo
- **Kendala**: Respon endpoint `POST /api/diskon/check` mengembalikan data kupon di dalam objek bersarang: `data: { diskon: { id: ..., persentase_diskon: ... } }`.
- **Solusi**: Model `Discount.fromJson` dirancang fleksibel untuk membaca data baik dari objek langsung maupun objek bersarang `json['diskon']`, sehingga potongan harga terhitung instan saat kode voucher diketik.

### 5. Auto-Refresh Antar Tab di Layar Mobile
- **Kendala**: Navigasi `IndexedStack` tidak menjalankan ulang `initState()` saat pengguna berpindah tab dari Beranda ke Reservasi atau Histori.
- **Solusi**: Menggunakan `GlobalKey<MyBookingScreenState>` dan `GlobalKey<MemberHistoryScreenState>`. Setiap kali tab ditekan, navbar secara otomatis memanggil fungsi `refresh()` untuk mengambil data terbaru dari server.

---

## 9. Desain Sistem Visual (Stitch UI NexusSpace)

Aplikasi mengimplementasikan spesifikasi desain **Google Stitch Project `2680578259315137478` (NexusSpace Work & Manage)** yang telah dioptimalkan untuk perangkat compact seperti **iPhone 16e (390 x 844 pt)**:

- **Palet Warna Utama**:
  - Primary: `#0F172A` (Midnight Navy)
  - Secondary Accent: `#F97316` (Vivid Tangerine)
  - Canvas: `#F8FAFC` (Slate-50 glare-free background)
  - Surface: `#FFFFFF` (Pure White Card)
  - Border: `#E2E8F0` (Slate-200 subtle outline)
- **Status Semantic Palette**:
  - Menunggu: Amber `#FEF3C7` (bg), `#B45309` (teks), dot amber `#F59E0B`.
  - Disetujui: Emerald `#ECFDF5` (bg), `#047857` (teks), dot emerald `#10B981`.
  - Aktif: Blue `#EFF6FF` (bg), `#1D4ED8` (teks), dot blue `#3B82F6`.
  - Selesai: Slate `#F1F5F9` (bg), `#334155` (teks), dot slate `#64748B`.
  - Dibatalkan: Rose `#FFF1F2` (bg), `#BE123C` (teks), dot rose `#F43F5E`.
- **Tipografi Ramping**:
  - Seluruh teks menggunakan font keluarga **Plus Jakarta Sans** dengan spasi huruf (*letter-spacing*) rapat yang modern dan proporsional di layar ponsel kecil.
- **Bentuk & Sudut (Corner Radii)**:
  - Kartu Konten (*Cards*): `16dp` (*rounded-2xl*) yang empuk dan halus.
  - Form Inputs & Search Bar: `12dp` (*rounded-xl*) dengan tinggi ramping 38-40dp.
  - Status Badges & Filter Tabs: `9999px` (*stadium pill*).
  - Top Bar: Tinggi ramping `48dp` dengan tombol kembali berupa lingkaran putih timbul (*elevation badge*).

---

## 10. Panduan Menjalankan & Menguji Aplikasi

### Prasyarat Lingkungan
- Flutter SDK versi 3.10 atau lebih baru
- Dart SDK versi 3.0 atau lebih baru
- Koneksi internet aktif (untuk berkomunikasi dengan server backend)
- Android Studio / Xcode dengan Simulator iPhone (direkomendasikan iPhone 16e / iPhone 15)

### Langkah Menjalankan Aplikasi
1. Buka terminal pada folder proyek:
   ```bash
   cd /Users/iqbalrizqi/Desktop/app/flutter/coworking_space
   ```
2. Unduh seluruh dependensi paket:
   ```bash
   flutter pub get
   ```
3. Jalankan aplikasi pada simulator atau perangkat fisik:
   ```bash
   flutter run
   ```

### Menjalankan Uji Otomatis (Testing & Quality Assurance)
Aplikasi telah dilengkapi dengan unit test dan widget test otomatis untuk menjamin keandalan kode:
1. **Pemeriksaan Analisis Kode (Linter)**:
   ```bash
   flutter analyze
   ```
   *Ekspektasi: `No issues found!` (0 error, 0 warning).*
2. **Pemeriksaan Test Suite Otomatis**:
   ```bash
   flutter test
   ```
   *Ekspektasi: Seluruh pengujian (CurrencyFormatter, ImageHelper, ReservationHelper, Discount, RevenueReport, Space, dan Root Widget) berstatus PASSED.*

---

**Pengembang**: Tim Siswa RPL SMK Telkom Malang  
**Standar Kompetensi**: UKK RPL 2026/2027 Paket B (Smart Coworking Space Reservation System)
