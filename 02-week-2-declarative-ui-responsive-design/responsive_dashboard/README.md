# WEEK 2: Declarative UI & Responsive Design

---

## Praktikum: layout sederhana (warm-up)

### membuat kartu profil sederhana
![4](screenshots/4.png)

### eksperimen warmp-up
1. Hapus Expanded pada baris nama, lalu amati peringatan overflow atau perilaku layout-nya; kembalikan setelah itu.
**hapus extended**
![4.1](screenshots/4.1.png)
**undo extended**
![4.1.1](screenshots/4.1.1.png)

2. Ganti mainAxisSize: MainAxisSize.min menjadi nilai default dan amati perubahan tinggi kartu
![4.2](screenshots/4.2.png)

3. Tambahkan satu baris data (misal Email) menggunakan pola Row + Expanded yang sama
![4.3](screenshots/4.3.png)

---

## Praktikum: dashboard responsif

### menyiapkan project
![5](screenshots/5.png)
- **tampilan vertikal** 
![5.1.1](screenshots/5.1.1.png)
- **tampilan horizontal**
![5.1.2](screenshots/5.1.2.png)

### Menambahkan interaksi: StatefulWidget dan Cupertino
- **tampilan vertikal** 
![5.2.1](screenshots/5.2.1.png)
- **tampilan horizontal**
![5.2.2](screenshots/5.2.2.png)

### eksperimen layout
1. Ubah breakpoint dari 700 menjadi nilai lain dan amati perubahan jumlah kolom
![5.3](screenshots/5.3.png)
2. Ubah themeMode menjadi ThemeMode.dark, lalu kembalikan ke ThemeMode.system
![5.4](screenshots/5.4.png)

---

## Tugas dan AI design exploration

### Tugas utama
![6.1.1](screenshots/6.1.1.png)
![6.1.2](screenshots/6.1.2.png)

### AI Prompt Challenge
1. Promt desain: Bandingkan dua tata letak dashboard akademik untuk Flutter: versi GridView dan versi LayoutBuilder + Column. Jelaskan trade-off responsif dan aksesibilitasnya
![6.2.1](screenshots/6.2.1.png)
![6.2.2](screenshots/6.2.2.png)
![6.2.3](screenshots/6.2.3.png)
![6.2.4](screenshots/6.2.4.png)

2. Prompt penguatan konsep: Jelaskan kapan penggunaan Expanded justru menyebabkan overflow di dalam Row, beri contoh kode yang gagal dan perbaikannya
![6.3.1](screenshots/6.3.1.png)
![6.3.2](screenshots/6.3.2.png)
![6.3.3](screenshots/6.3.3.png)
![6.3.4](screenshots/6.3.4.png)

3. verification prompt: Periksa kembali rekomendasi layout di atas: apakah tetap responsif di bawah 600px, apakah mengurangi aksesibilitas, dan apakah ada widget yang tidak tersedia di Flutter stabil saat ini?
![6.4](screenshots/6.4.png)


### Refactoring Challenge

1. Ekstrak kartu informasi menjadi widget reusable
![6.5.1](screenshots/6.5.1.png)
2. Ganti warna dan ukuran yang di-hardcode
![6.5.2](screenshots/6.5.2.png)
3. Pindahkan breakpoint ke satu konstanta
![6.5.3](screenshots/6.5.3.png)
4. Jalankan flutter analyze
![6.5.4](screenshots/6.5.4.png)

### testing dasar
![6.6](screenshots/6.6.png)

---

## Refleksi
- Apa perbedaan cara berpikir imperative dan declarative saat membangun UI?
imperatif: mengubah UI secara manual melalui instruksi
declarative: merender UI secara otomatis berdasarkan deskripsi state

- Kapan Expanded membantu dan kapan penggunaannya justru menghasilkan layout error?
Membantu membagi sisa ruang di dalam Row dan Column. mMnyebabkan layout error jika ditaruh di dalam wadah tanpa batasan ukuran

- Bagaimana breakpoint dan theme memengaruhi pengalaman pengguna?
breakpoint:menyesuaikan tata letak secara responsif
theme: menjaga konsistensi visual

- Apa yang Anda verifikasi dari rekomendasi AI setelah tugas inti selesai?
- kebenaran