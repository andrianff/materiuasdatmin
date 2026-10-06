# ---------------------------------------------------------------
# Pembangkit data simulasi Modul 5 -- Prapemrosesan Data
# Data ILUSTRATIF hasil simulasi; BUKAN data resmi.
#
# Modul ini membahas pembersihan, penanganan nilai hilang, pencilan,
# dan pembakuan. Agar manfaat prapemrosesan dapat DIPERLIHATKAN --
# bukan sekadar dikerjakan -- data memuat hubungan yang benar-benar
# ada dengan peubah sasaran, ditambah persoalan yang sengaja ditanam:
#   - nilai hilang bertipe MAR (bergantung wilayah dan pendidikan),
#     sehingga penghapusan baris menimbulkan bias yang dapat diukur;
#   - pencilan pada pendapatan, sehingga pembakuan yang tahan pencilan
#     memberi hasil berbeda dari pembakuan biasa;
#   - satuan yang jauh berbeda antar-peubah, sehingga pembakuan
#     mengubah hasil metode berbasis jarak.
# ---------------------------------------------------------------
set.seed(2026)
n <- 1000

wilayah      <- sample(c("Perkotaan", "Perdesaan"), n, replace = TRUE, prob = c(0.5, 0.5))
pendidikan   <- sample(c("SD", "SMP", "SMA", "PT"), n, replace = TRUE,
                       prob = c(0.16, 0.24, 0.40, 0.20))
umur         <- round(runif(n, 20, 70))
lama_sekolah <- round(pmin(pmax(rnorm(n, c(SD = 4, SMP = 8, SMA = 11, PT = 15)[pendidikan], 1.6), 0), 18), 1)
pendapatan   <- round(exp(rnorm(n, log(8000) + 0.06 * lama_sekolah, 0.45)), 2)
pengeluaran  <- round(0.62 * pendapatan / 10 + rnorm(n, 0, 120), 2)
skor_literasi <- round(pmin(pmax(28 + 2.4 * lama_sekolah + rnorm(n, 0, 7), 0), 100), 1)

skor <- -2.20 + 0.16 * lama_sekolah + 0.021 * skor_literasi +
  0.00004 * (pendapatan - 8000) - 0.75 * (wilayah == "Perdesaan")
target <- ifelse(rbinom(n, 1, 1 / (1 + exp(-skor))) == 1, "ya", "tidak")

kotor <- data.frame(id = sample(seq_len(n)), wilayah = wilayah,
  pendidikan = pendidikan, umur = umur, pendapatan = pendapatan,
  pengeluaran = pengeluaran, lama_sekolah = lama_sekolah,
  skor_literasi = skor_literasi, target = target)

# --- persoalan yang SENGAJA ditanam ---
# (1) pencilan pendapatan: 2 persen amatan bernilai 10-30 kali lipat
i_out <- sample(n, round(0.02 * n))
kotor$pendapatan[i_out] <- round(kotor$pendapatan[i_out] * runif(length(i_out), 10, 30), 2)

# (2) nilai hilang MAR: peluang hilang lebih besar di perdesaan
#     dan pada pendidikan rendah -- penghapusan baris membuang mereka
#     secara tidak sebanding, sehingga menimbulkan bias yang terukur
p_hilang <- 0.05 + 0.18 * (kotor$wilayah == "Perdesaan") +
            0.12 * (kotor$pendidikan %in% c("SD", "SMP"))
kotor$pendapatan[runif(n) < p_hilang]    <- NA
kotor$skor_literasi[runif(n) < p_hilang * 0.6] <- NA

# (3) duplikat dan galat penulisan kategori
kotor <- rbind(kotor, kotor[sample(n, 15), ])
j <- sample(nrow(kotor), 25); kotor$wilayah[j] <- toupper(kotor$wilayah[j])
j <- sample(nrow(kotor), 18); kotor$pendidikan[j] <- tolower(kotor$pendidikan[j])

dir.create("data", showWarnings = FALSE)
write.csv(kotor, "data/data_kotor.csv", row.names = FALSE)

referensi <- data.frame(
  wilayah = c("Perkotaan", "Perdesaan"),
  indeks_wilayah = c(1.00, 0.78),
  keterangan = c("acuan", "faktor penyesuaian biaya hidup"))
write.csv(referensi, "data/data_referensi.csv", row.names = FALSE)

cat("baris:", nrow(kotor), "| hilang pendapatan:", sum(is.na(kotor$pendapatan)),
    "| duplikat: 15 | proporsi target ya:", round(mean(kotor$target == "ya"), 4), "\n")
