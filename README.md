# Coworking Space Reservation App (NexusSpace)

Aplikasi mobile reservasi ruang kerja dan meja workstation online berbasis **Flutter**, dirancang dan dikembangkan untuk **Uji Kompetensi Keahlian (UKK) RPL 2026/2027: Paket B**.

---

## 🚀 Fitur Utama

- **Autentikasi Multi-Role**: Sistem login cerdas yang mengenali peran **Member** dan **Admin Pengelola Space**, dilengkapi deteksi akun template seeder panitia.
- **Katalog & Ketersediaan**: Eksplorasi unit kerja (*Personal Desk*, *Private Office*, *Meeting Room*) dengan filter kategori, pengecekan slot jam sewa, dan foto ruangan.
- **Sistem Promo Otomatis**: Verifikasi kupon diskon instan yang memotong subtotal secara transparan.
- **E-Tiket & QR Code**: Nota reservasi digital ber-QR Code untuk proses check-in cepat di lokasi.
- **Manajemen Operasional Admin**: Siklus lengkap persetujuan booking, check-in, check-out, serta visualisasi grafik omset pendapatan harian.
- **Desain Sistem Stitch NexusSpace**: Antarmuka responsif berbasis *Plus Jakarta Sans*, sudut membulat 16dp, dan palet warna Midnight Navy.

---

## 📖 Dokumentasi Lengkap

Untuk panduan mendalam mencakup:
- Daftar lengkap seluruh 43 endpoint API
- Penjelasan alur pengguna (User Flow)
- Pola arsitektur Service-Oriented & Clean Layering
- Struktur direktori dan tanggung jawab berkas
- Solusi teknis penanganan reverse-proxy gambar dan ekstraksi harga

Silakan baca dokumen lengkap di:
👉 **[DOCUMENTATION.md](./DOCUMENTATION.md)**

---

## 🛠️ Cara Menjalankan Proyek

1. **Unduh dependensi**:
   ```bash
   flutter pub get
   ```

2. **Jalankan aplikasi**:
   ```bash
   flutter run
   ```

3. **Jalankan pengujian otomatis**:
   ```bash
   flutter analyze
   flutter test
   ```
