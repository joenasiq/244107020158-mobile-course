# Hasil Test — Week 6: Authentication, Security & FCM

## Ringkasan

| Kategori | Jumlah | Status |
| --- | --- | --- |
| Unit test (`auth_push_test.dart`) | 11 | ✅ Pass |
| Screenshot test (`screenshot_test.dart`) | 4 | ✅ Pass |
| **Total** | **15** | **✅ All passed** |

## Detail Test

### auth_push_test.dart (11 tests)

```
+0: routeFromMessage data kosong mengembalikan /
+1: routeFromMessage route tanpa slash ditambahkan /
+2: routeFromMessage route dengan slash dipertahankan
+3: routeFromMessage data payload membawa id pengumuman
+4: AuthNotifier dengan FakeTokenStore login sukses menyimpan token dan mengembalikan true
+5: AuthNotifier dengan FakeTokenStore logout menghapus token dan mengembalikan false
+6: AuthNotifier dengan FakeTokenStore login gagal menghasilkan error
+7: FakeTokenStore sesi refresh token kosong memaksa login ulang
+8: friendlyErrorMessage timeout → pesan jaringan lama
+9: friendlyErrorMessage 401 → sesi habis
+10: friendlyErrorMessage non-Dio error → pesan asli tanpa prefix Exception:
+11: All tests passed!
```

### screenshot_test.dart (4 tests)

```
+0: screenshot: halaman login
+1: screenshot: halaman home setelah login
+2: screenshot: detail pengumuman
+3: screenshot: detail pengumuman deep link
+4: All tests passed!
```

## Screenshot yang Dihasilkan

| File | Halaman |
| --- | --- |
| `login_page.png` | Form login Campus Notify |
| `home_page.png` | Home setelah login (daftar pengumuman) |
| `announcement_detail.png` | Detail pengumuman #3 (deep link) |
| `announcement_deeplink.png` | Detail pengumuman #5 (deep link) |

## Catatan
- Test berjalan **tanpa Firebase** — menggunakan `FakeTokenStore` dan `FakeAuthRepository`.
- Screenshot menggunakan font Roboto asli + MaterialIcons dari SDK Flutter.
- `flutter analyze` bersih (0 issues) sebelum test dijalankan.
- FCM tidak bisa diuji di widget test — harus dicoba langsung di HP Android.
