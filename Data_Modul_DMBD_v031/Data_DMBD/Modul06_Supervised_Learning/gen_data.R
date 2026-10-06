# ---------------------------------------------------------------
# Pembangkit data simulasi Modul 6 -- Konsep Supervised Learning
# Data ILUSTRATIF hasil simulasi; BUKAN data resmi.
#
# Modul ini membahas gagasan dasar: pembagian latih-uji, lewat-suai,
# dan penawaran bias-ragam. Agar gagasan itu dapat DIPERLIHATKAN, data
# harus memuat hubungan yang sungguh ada namun TIDAK sempurna:
#   - sinyal sedang pada beberapa peubah, sehingga model sederhana
#     sudah mengungguli tebakan tetapi masih menyisakan ruang;
#   - satu ambang dan satu interaksi, sehingga model lentur dapat
#     unggul -- dan lewat-suai dapat diperagakan bila dibiarkan;
#   - derau yang cukup besar, sehingga selisih latih-uji terlihat.
# ---------------------------------------------------------------
set.seed(2026)
n <- 1000

umur              <- round(runif(n, 21, 65))
pendapatan        <- round(exp(rnorm(n, log(9000), 0.5)), 2)
lama_kerja        <- round(pmin(pmax(rnorm(n, 11, 7), 0), umur - 18), 1)
rasio_utang       <- round(pmin(pmax(rnorm(n, 0.30, 0.15), 0.01), 0.95), 3)
jumlah_tanggungan <- rpois(n, 2.1)
pendidikan        <- sample(c("SMP", "SMA", "D3", "S1"), n,
                            replace = TRUE, prob = c(0.18, 0.45, 0.17, 0.20))
status_rumah      <- sample(c("Milik", "Sewa", "Keluarga"), n,
                            replace = TRUE, prob = c(0.44, 0.34, 0.22))

skor <- -1.15 +
  3.0 * (rasio_utang - 0.30) +          # monoton, cukup kuat
  0.26 * jumlah_tanggungan +
  -0.035 * lama_kerja +
  0.9 * (pendapatan < 6000) +           # ambang
  0.8 * (rasio_utang > 0.5 & status_rumah == "Sewa") +   # interaksi
  ifelse(pendidikan == "SMP", 0.45, ifelse(pendidikan == "S1", -0.40, 0))

p <- 1 / (1 + exp(-skor))
gagal_bayar <- ifelse(rbinom(n, 1, p) == 1, "ya", "tidak")

kredit <- data.frame(id = sample(seq_len(n)), umur = umur,
  pendapatan = pendapatan, lama_kerja = lama_kerja, rasio_utang = rasio_utang,
  jumlah_tanggungan = jumlah_tanggungan, pendidikan = pendidikan,
  status_rumah = status_rumah, gagal_bayar = gagal_bayar)

dir.create("data", showWarnings = FALSE)
write.csv(kredit, "data/data_kredit.csv", row.names = FALSE)
cat("baris:", n, "| proporsi gagal bayar:", round(mean(gagal_bayar == "ya"), 4), "\n")
