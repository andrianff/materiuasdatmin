# ---------------------------------------------------------------
# Pembangkit data simulasi Modul 13 -- GPBoost
# Data ILUSTRATIF hasil simulasi; BUKAN data resmi instansi mana pun.
#
# Rancangan: struktur BERTINGKAT yang khas pada pendataan resmi --
# rumah tangga tersarang di dalam wilayah. Pengaruh peubah penjelas
# sengaja dibuat NONLINEAR, dan tiap wilayah memiliki EFEK ACAK
# yang ditanam, sehingga dapat diperiksa apakah model memulihkannya.
# ---------------------------------------------------------------
set.seed(2026)

n_wilayah <- 60
per_wil   <- 20
n         <- n_wilayah * per_wil

wilayah <- rep(sprintf("W%02d", seq_len(n_wilayah)), each = per_wil)

# peubah penjelas tingkat rumah tangga
lama_sekolah  <- round(runif(n,  0, 16), 1)
umur_krt      <- round(runif(n, 20, 70), 0)
anggota_rt    <- sample(1:8, n, replace = TRUE, prob = c(6,14,22,24,17,10,5,2)/100)

# pengaruh tetap yang NONLINEAR (inilah yang harus ditemukan boosting)
f <- 2.0 * sin(pi * lama_sekolah / 16) +          # naik lalu melandai
     1.5 * (umur_krt > 45) +                       # ambang tajam
     0.25 * anggota_rt

# efek acak wilayah yang DITANAM (simpangan baku 1,2)
b_wilayah <- rnorm(n_wilayah, 0, 1.2)
names(b_wilayah) <- sprintf("W%02d", seq_len(n_wilayah))

y <- 8 + f + b_wilayah[wilayah] + rnorm(n, 0, 0.5)

rt <- data.frame(
  id_rt        = sprintf("RT%04d", seq_len(n)),
  wilayah      = wilayah,
  lama_sekolah = lama_sekolah,
  umur_krt     = umur_krt,
  anggota_rt   = anggota_rt,
  pengeluaran  = round(y, 3)          # dalam juta rupiah per bulan (ilustratif)
)

dir.create("data", showWarnings = FALSE)
write.csv(rt, "data/rumahtangga_wilayah.csv", row.names = FALSE)

# efek acak sebenarnya disimpan terpisah: dipakai untuk MEMERIKSA
# apakah model berhasil memulihkannya (tidak tersedia pada data nyata)
write.csv(data.frame(wilayah = names(b_wilayah), efek_sebenarnya = round(b_wilayah, 4)),
          "data/efek_wilayah_sebenarnya.csv", row.names = FALSE)

cat("rumah tangga:", n, "| wilayah:", n_wilayah,
    "| simpangan baku efek wilayah:", round(sd(b_wilayah), 3), "\n")
