# ---------------------------------------------------------------
# Pembangkit data simulasi Modul 15 -- LightGBM
# Data ILUSTRATIF hasil simulasi; BUKAN data resmi.
#
# Kasus: klasifikasi rumah tangga penerima manfaat program.
# Dirancang dengan tiga ciri yang menonjolkan keunggulan LightGBM:
#   (1) UKURAN besar (40.000 baris) sehingga kecepatan terasa,
#   (2) peubah KATEGORIK berkardinalitas tinggi (kode kabupaten),
#   (3) kelas TIDAK SEIMBANG (sekitar 12 persen positif).
# ---------------------------------------------------------------
set.seed(2026)

n <- 40000
n_kab <- 120

kabupaten <- sample(sprintf("K%03d", seq_len(n_kab)), n, replace = TRUE)
efek_kab  <- rnorm(n_kab, 0, 0.8); names(efek_kab) <- sprintf("K%03d", seq_len(n_kab))

lama_sekolah <- round(pmin(pmax(rnorm(n, 8, 3.5), 0), 16), 1)
umur_krt     <- round(runif(n, 20, 75))
anggota_rt   <- sample(1:9, n, replace = TRUE, prob = c(5,12,20,23,17,11,7,3,2)/100)
luas_lantai  <- round(exp(rnorm(n, 3.6, 0.45)), 1)
jenis_pekerjaan <- sample(c("Informal","Formal","Petani","Wirausaha","Tidak bekerja"),
                          n, replace = TRUE, prob = c(0.38,0.22,0.20,0.13,0.07))
punya_aset   <- rbinom(n, 1, 0.45)

# Hubungan sengaja dibuat SANGAT NONLINEAR dan penuh INTERAKSI:
# inilah keadaan yang membuat model berbasis pohon unggul atas model linear.
skor <- -2.70 +
  -1.4 * (lama_sekolah < 6) + 0.3 * (lama_sekolah > 12) +        # ambang, bukan lereng
   1.6 * (anggota_rt >= 6 & luas_lantai < 40) +                   # interaksi kuat
  -1.2 * (luas_lantai > 60) +
   1.3 * (jenis_pekerjaan %in% c("Informal","Tidak bekerja") & punya_aset == 0) +
  -0.9 * (jenis_pekerjaan == "Formal" & lama_sekolah > 9) +
   1.1 * (umur_krt > 60 & anggota_rt <= 2) +                      # lansia sendirian
   0.8 * sin(pi * umur_krt / 30) +                                # berkala, bukan monoton
   efek_kab[kabupaten]

p <- 1 / (1 + exp(-skor))
penerima <- rbinom(n, 1, p)

rt <- data.frame(
  id_rt = sprintf("RT%05d", seq_len(n)),
  kabupaten = kabupaten,
  lama_sekolah = lama_sekolah,
  umur_krt = umur_krt,
  anggota_rt = anggota_rt,
  luas_lantai = luas_lantai,
  jenis_pekerjaan = jenis_pekerjaan,
  punya_aset = punya_aset,
  penerima = penerima
)

dir.create("data", showWarnings = FALSE)
write.csv(rt, "data/penerima_manfaat.csv", row.names = FALSE)
cat("baris:", n, "| kabupaten:", n_kab,
    "| proporsi positif:", round(mean(penerima), 4), "\n")
