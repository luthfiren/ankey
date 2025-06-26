# ANKEY

**ANKEY** adalah aplikasi flashcard sederhana untuk membantu proses belajar dengan metode tanya-jawab berbasis kartu. Kamu bisa membuat, mengelola, dan menguji ingatanmu terhadap berbagai materi dengan mudah melalui aplikasi ini.

---

## ✨ Fitur Utama

- **Buat Flashcard** secara manual atau lewat kamera (OCR)
- **Kelola Deck** (grup flashcard, bisa dihapus & edit)
- **Review dan Play Mode** untuk latihan mengingat
- **Integrasi database MySQL di backend**
- **Tampilan modern**
- **Login/Register user**

---

## 🚀 Langkah Instalasi & Menjalankan

### 1. Clone Repositori Frontend (Flutter)

```bash
git clone https://github.com/luthfiren/ankey.git
cd ankey
```

### 2. Clone Repositori Backend

Silakan clone juga backend (Node.js/Express) di:
> [https://github.com/KevinSatrio/ankey_be](https://github.com/KevinSatrio/ankey_be)

---

### 3. Install Node.js & Jalankan Backend

Pastikan sudah install **Node.js** (https://nodejs.org/).

Lalu jalankan backend:
```bash
cd ankey_be
npm install
npm run
```
> **Note:** Jalankan backend **lebih dulu** sebelum menjalankan aplikasi Flutter.

---

### 4. Import Database MySQL

1. **Install** XAMPP (atau software MySQL lain)
2. **Start** Apache & MySQL dari XAMPP Control Panel
3. **Buka** phpMyAdmin: http://localhost/phpmyadmin
4. **Create Database** baru dengan nama **`flutter_auth`** (harus sama persis)
5. **Import file SQL** yang ada di [`database/flutter_auth.sql`](database/flutter_auth.sql)
    - Klik database `flutter_auth` → Import → pilih file `flutter_auth.sql` → Go.

Pastikan struktur tabel sudah sesuai.

---

### 5. Install Dependensi Flutter

```bash
flutter clean
flutter pub get
```

---

### 6. Jalankan Aplikasi

- **Via Android Studio:**  
  Buka folder project → klik Run (pilih device emulator/HP Android) 

- **Via Visual Studio Code:**  
  Pilih device yang diinginkan, lalu tekan Run (F5) atau:

  ```bash
  flutter run
  ```

---

### 7. Pengaturan API & Koneksi

- Pastikan backend sudah berjalan di `http://localhost:5000`
- Pastikan konfigurasi API di project Flutter mengarah ke backend (lihat file `.dart` yang berisi url API).
- Jalankan backend **lebih dulu** sebelum frontend.

---

### 8. Catatan

- **Jalankan backend** lebih dulu sebelum frontend (agar aplikasi bisa login/register dan akses data).
- **Database**: Gunakan XAMPP atau MySQL server lokal lain.
- **Jika ada error koneksi**, cek port backend, IP, dan firewall.

---

## 📂 Struktur File Penting

```
ankey/
  database/
    flutter_auth.sql
  README.md
```

> File SQL ada di folder `database/flutter_auth.sql`.

---

## 📝 Lisensi

Aplikasi ini dikembangkan untuk pembelajaran.  
Silakan gunakan, modifikasi, dan kembangkan sesuai kebutuhan.

---

> **Frontend:** [https://github.com/luthfiren/ankey](https://github.com/luthfiren/ankey)  
> **Backend:** [https://github.com/KevinSatrio/ankey_be](https://github.com/KevinSatrio/ankey_be)

---

## Author
1. Thariq Kemal Hassan			(5026221174) 
2. Luthfi Rihadatul Fajri		(5026221077)
3. Muhammad Kevin Checa Satrio	(5026221083)
4. Rosdiani Adiningsih			(5026221101)
5. Parisya Naylah Suhaymi		(5026221138)
