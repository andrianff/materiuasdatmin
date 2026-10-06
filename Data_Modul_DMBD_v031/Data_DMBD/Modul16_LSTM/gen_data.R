# ---------------------------------------------------------------
# Pembangkit data simulasi Modul 16 -- LSTM untuk deret waktu
# Data ILUSTRATIF hasil simulasi; BUKAN data resmi.
#
# Rancangan: 24 wilayah, 120 bulan (10 tahun) indikator bulanan.
# Sengaja dibuat memuat TREN, MUSIMAN TAHUNAN, dan satu pola
# NONLINEAR (dampak yang meluruh setelah kejutan) agar keunggulan
# maupun keterbatasan LSTM dapat diperiksa terhadap acuan sederhana.
# ---------------------------------------------------------------
set.seed(2026)

n_wil <- 24; n_bulan <- 120
wilayah <- sprintf("W%02d", seq_len(n_wil))
taraf   <- rnorm(n_wil, 100, 12)          # taraf khas tiap wilayah
tren    <- rnorm(n_wil, 0.15, 0.08)       # kemiringan tren per bulan
amp     <- runif(n_wil, 6, 14)            # amplitudo musiman
geser   <- runif(n_wil, 0, 2 * pi)        # fase musiman

baris <- list()
for (i in seq_len(n_wil)) {
  t <- seq_len(n_bulan)
  musim <- amp[i] * sin(2 * pi * t / 12 + geser[i])
  # kejutan pada bulan ke-40 yang dampaknya meluruh perlahan (nonlinear)
  kejut <- ifelse(t >= 40, -18 * exp(-(t - 40) / 15), 0)
  nilai <- taraf[i] + tren[i] * t + musim + kejut + rnorm(n_bulan, 0, 3)
  baris[[i]] <- data.frame(
    wilayah = wilayah[i],
    bulan   = t,
    tahun   = 2016 + (t - 1) %/% 12,
    bulan_ke = ((t - 1) %% 12) + 1,
    nilai   = round(nilai, 2))
}
deret <- do.call(rbind, baris)

dir.create("data", showWarnings = FALSE)
write.csv(deret, "data/deret_bulanan.csv", row.names = FALSE)
cat("baris:", nrow(deret), "| wilayah:", n_wil, "| bulan:", n_bulan,
    "| rentang nilai:", round(range(deret$nilai), 1), "\n")


# ---------------------------------------------------------------
# Data KEDUA: deret berdinamika NONLINEAR (deret_rezim.csv)
#
# Data pertama (deret_bulanan.csv) bersifat tren + musiman + derau --
# pola yang justru menjadi keunggulan acuan naif musiman, sehingga LSTM
# tidak mengungguli acuan secara meyakinkan. Itu pelajaran yang jujur,
# tetapi ia tidak memperlihatkan KAPAN LSTM sepadan dengan biayanya.
#
# Data kedua ini memuat dinamika yang tidak dapat ditiru acuan naif:
# nilai berikutnya bergantung pada DUA nilai sebelumnya, dan koefisien
# kebergantungannya BERPINDAH REZIM menurut tingkat bulan sebelumnya.
# Pola berulang yang bergantung keadaan seperti inilah yang menjadi
# ranah jaringan berulang.
# ---------------------------------------------------------------
set.seed(2026)
n_wil <- 20; TT <- 120

satu_deret <- function() {
  y <- numeric(TT); y[1:2] <- rnorm(2, 50, 3)
  for (t in 3:TT) {
    # rezim ditentukan tingkat bulan sebelumnya: di atas 55 deret meredam,
    # di bawahnya deret menguat -- keduanya berbagi musiman tahunan
    y[t] <- if (y[t - 1] > 55) {
      0.55 * y[t - 1] - 0.35 * y[t - 2] + 28 + 6 * sin(2 * pi * t / 12) + rnorm(1, 0, 1.4)
    } else {
      1.25 * y[t - 1] - 0.45 * y[t - 2] -  4 + 6 * sin(2 * pi * t / 12) + rnorm(1, 0, 1.4)
    }
  }
  y
}

rezim <- do.call(rbind, lapply(seq_len(n_wil), function(w)
  data.frame(wilayah = sprintf("W%02d", w), bulan = seq_len(TT),
             tahun = 2016 + (seq_len(TT) - 1) %/% 12,
             bulan_ke = (seq_len(TT) - 1) %% 12 + 1,
             nilai = round(satu_deret(), 2))))

write.csv(rezim, "data/deret_rezim.csv", row.names = FALSE)
cat("deret rezim:", nrow(rezim), "baris |", n_wil, "wilayah x", TT, "bulan\n")
