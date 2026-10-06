# ---------------------------------------------------------------
# Pembangkit data simulasi Modul 8 -- Klasifikasi Dasar
# Data ILUSTRATIF hasil simulasi; BUKAN data resmi.
#
# Rancangan sengaja memuat TIGA jenis hubungan sekaligus, agar ketiga
# metode pada modul ini masing-masing memperoleh kesempatan menunjukkan
# keunggulannya:
#   (1) hubungan MONOTON pada rasio cicilan dan riwayat telat
#       -> menguntungkan regresi logistik terregularisasi;
#   (2) AMBANG tajam pada pendapatan dan INTERAKSI dengan status rumah
#       -> menguntungkan pohon keputusan;
#   (3) peubah kategorik yang bekerja hampir bebas satu sama lain
#       -> menguntungkan Naive Bayes.
# ---------------------------------------------------------------
set.seed(2026)
n <- 900

umur          <- round(runif(n, 21, 65))
pendapatan    <- round(exp(rnorm(n, log(12000), 0.45)), 2)
lama_kerja    <- round(pmin(pmax(rnorm(n, 12, 8), 0), umur - 18), 1)
rasio_cicilan <- round(pmin(pmax(rnorm(n, 0.35, 0.16), 0.02), 0.95), 3)
jumlah_kartu  <- rpois(n, 2.2)
riwayat_telat <- rpois(n, 2.0)
pendidikan    <- sample(c("SD", "SMP", "SMA", "Diploma", "Sarjana"), n,
                        replace = TRUE, prob = c(0.10, 0.18, 0.42, 0.15, 0.15))
status_rumah  <- sample(c("Milik", "Sewa", "Keluarga"), n,
                        replace = TRUE, prob = c(0.45, 0.33, 0.22))

skor <- -1.30 +
  # (1) monoton -- terbaca baik oleh model linear dalam log-odds
  2.6 * (rasio_cicilan - 0.35) / 0.16 * 0.35 +
  0.30 * riwayat_telat +
  -0.030 * lama_kerja +
  # (2) ambang dan interaksi -- hanya tertangkap model berbasis pohon
  1.10 * (pendapatan < 9000) +
  1.00 * (rasio_cicilan > 0.55 & status_rumah == "Sewa") +
  -0.80 * (pendapatan > 20000 & rasio_cicilan < 0.30) +
  # (3) sumbangan kategorik yang hampir bebas -- ranah Naive Bayes
  ifelse(pendidikan %in% c("SD", "SMP"), 0.55,
         ifelse(pendidikan == "Sarjana", -0.45, 0)) +
  ifelse(status_rumah == "Milik", -0.40, 0.20) +
  0.10 * jumlah_kartu

p <- 1 / (1 + exp(-skor))
gagal_bayar <- ifelse(rbinom(n, 1, p) == 1, "ya", "tidak")

nasabah <- data.frame(
  id = sample(seq_len(n)), umur = umur, pendapatan = pendapatan,
  lama_kerja = lama_kerja, rasio_cicilan = rasio_cicilan,
  jumlah_kartu = jumlah_kartu, riwayat_telat = riwayat_telat,
  pendidikan = pendidikan, status_rumah = status_rumah,
  gagal_bayar = gagal_bayar)

dir.create("data", showWarnings = FALSE)
write.csv(nasabah, "data/data_nasabah.csv", row.names = FALSE)
cat("baris:", n, "| proporsi gagal bayar:", round(mean(gagal_bayar == "ya"), 4), "\n")
