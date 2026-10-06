# ---------------------------------------------------------------
# Pembangkit data simulasi Modul 7 -- Persiapan Proyek Data Mining
# Data ILUSTRATIF hasil simulasi; BUKAN data resmi.
#
# Modul ini membahas penyiapan proyek: perumusan sasaran, penilaian
# kelayakan data, dan penyusunan acuan. Agar penilaian kelayakan itu
# BERMAKNA, data harus memuat hubungan yang benar-benar ada --
# sehingga acuan sederhana mengungguli tebakan, dan analis dapat
# menyimpulkan bahwa proyek layak dilanjutkan.
#
# Struktur yang ditanam:
#   - pengeluaran dan lama sekolah berhubungan kuat dengan status penerima;
#   - akses air dan listrik berhubungan sedang;
#   - perdesaan/perkotaan bekerja sebagai pengubah pengaruh (interaksi).
# ---------------------------------------------------------------
set.seed(2026)
n <- 1200

wilayah      <- sample(c("Perkotaan", "Perdesaan"), n, replace = TRUE, prob = c(0.45, 0.55))
umur_krt     <- round(runif(n, 22, 70))
anggota_rt   <- sample(1:9, n, replace = TRUE, prob = c(6,13,21,23,17,10,6,2,2)/100)
lama_sekolah <- round(pmin(pmax(rnorm(n, ifelse(wilayah == "Perkotaan", 9.5, 6.8), 3.2), 0), 16), 1)
pengeluaran  <- round(exp(rnorm(n, log(ifelse(wilayah == "Perkotaan", 11000, 8000)), 0.42)), 2)
akses_listrik <- round(pmin(pmax(rnorm(n, ifelse(wilayah == "Perkotaan", 92, 74), 12), 0), 100), 1)
akses_air     <- round(pmin(pmax(rnorm(n, ifelse(wilayah == "Perkotaan", 85, 62), 15), 0), 100), 1)

skor <- 1.10 +
  -0.00016 * (pengeluaran - 9000) +      # makin tinggi pengeluaran, makin kecil peluang
  -0.13 * lama_sekolah +
  0.22 * anggota_rt +
  -0.016 * akses_air +
  -0.010 * akses_listrik +
  0.55 * (wilayah == "Perdesaan") +
  0.60 * (wilayah == "Perdesaan" & lama_sekolah < 6)     # interaksi

p <- 1 / (1 + exp(-skor))
penerima_bantuan <- ifelse(rbinom(n, 1, p) == 1, "ya", "tidak")

proyek <- data.frame(id = sample(seq_len(n)), wilayah = wilayah,
  umur_krt = umur_krt, anggota_rt = anggota_rt, lama_sekolah = lama_sekolah,
  pengeluaran = pengeluaran, akses_listrik = akses_listrik,
  akses_air = akses_air, penerima_bantuan = penerima_bantuan)

dir.create("data", showWarnings = FALSE)
write.csv(proyek, "data/data_proyek.csv", row.names = FALSE)
cat("baris:", n, "| proporsi penerima:", round(mean(penerima_bantuan == "ya"), 4), "\n")
