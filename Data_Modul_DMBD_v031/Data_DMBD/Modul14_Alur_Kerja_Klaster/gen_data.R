# ---------------------------------------------------------------
# Pembangkit data simulasi Modul 14 -- Alur Kerja Pengelompokan
# Data ILUSTRATIF hasil simulasi; BUKAN data resmi.
#
# Modul ini memakai DUA data yang sengaja berlawanan sifat, agar alur
# kerja yang sama dapat diperlihatkan pada kedua ujungnya:
#
#   (1) data_wilayah.csv (dari Modul 12) -- TANPA struktur berklaster.
#       Hopkins mendekati 0,5, tidak berbeda dari data acak. Alur kerja
#       yang benar berhenti di tahap pertama, dan itulah pelajarannya.
#
#   (2) wilayah_berpola.csv (dibangkitkan di sini) -- BERSTRUKTUR jelas,
#       empat kelompok dengan pusat yang sengaja TIDAK segaris. Di sini
#       alur kerja yang sama berjalan sampai tuntas dan memperlihatkan
#       apa yang dapat dicapai pengelompokan bila strukturnya memang ada.
#
# Tanpa data kedua, mahasiswa hanya melihat metode gagal dan tidak
# pernah melihatnya berhasil.
# ---------------------------------------------------------------
set.seed(2026)

n_per <- c(60, 55, 50, 45)
# Pusat sengaja tidak segaris: bila keempat kelompok berderet pada satu
# gradien, siluet cenderung memilih k = 2 karena kelompok berdekatan melebur.
pusat <- rbind(c(75, 11.5, 55, 0.35), c(55,  5.5, 88, 0.72),
               c(82,  5.0, 40, 0.68), c(48, 10.5, 80, 0.30))
sdv <- c(3.0, 0.6, 4.0, 0.05)

X <- do.call(rbind, lapply(seq_along(n_per), function(k)
  cbind(rnorm(n_per[k], pusat[k, 1], sdv[1]),
        rnorm(n_per[k], pusat[k, 2], sdv[2]),
        rnorm(n_per[k], pusat[k, 3], sdv[3]),
        rnorm(n_per[k], pusat[k, 4], sdv[4]))))

wilayah <- data.frame(
  id             = sprintf("W%03d", seq_len(nrow(X))),
  ipm            = round(X[, 1], 1),
  lama_sekolah   = round(X[, 2], 1),
  akses_sanitasi = round(pmin(pmax(X[, 3], 0), 100), 1),
  rasio_kerja    = round(X[, 4], 3),
  kelompok_asli  = rep(paste0("K", 1:4), n_per))

# Kolom kelompok_asli hanya untuk MEMERIKSA hasil; pada data nyata ia
# tidak tersedia dan tidak boleh dipakai saat mengelompokkan.
dir.create("data", showWarnings = FALSE)
write.csv(wilayah, "data/wilayah_berpola.csv", row.names = FALSE)

cat("baris:", nrow(wilayah), "| kelompok:", length(n_per), "\n")
print(table(wilayah$kelompok_asli))
