# ---------------------------------------------------------------
# Pembangkit data simulasi Modul 12
# Data ILUSTRATIF, bukan data nyata dan bukan data resmi.
# ---------------------------------------------------------------

# --- Data berkepadatan BERSARANG: memperjelas kapan OPTICS diperlukan ---
# Sebuah gugus renggang (halo) yang DI DALAMNYA terdapat dua inti padat,
# ditambah satu gugus terpisah. Pada susunan seperti ini tidak ada satu
# nilai Eps pun yang benar: Eps kecil membuang halo menjadi derau,
# Eps besar meleburkan halo dan kedua inti menjadi satu.
set.seed(2026)

halo     <- data.frame(x = rnorm(160, 5.0, 1.60), y = rnorm(160, 5.0, 1.60))
inti_1   <- data.frame(x = rnorm( 80, 3.2, 0.20), y = rnorm( 80, 3.8, 0.20))
inti_2   <- data.frame(x = rnorm( 80, 6.8, 0.20), y = rnorm( 80, 6.2, 0.20))
terpisah <- data.frame(x = rnorm( 60, 11.5, 0.45), y = rnorm( 60, 11.5, 0.45))

titik <- rbind(halo, inti_1, inti_2, terpisah)
titik$kelompok <- c(rep("halo_renggang", 160), rep("inti_padat_1", 80),
                    rep("inti_padat_2", 80), rep("gugus_terpisah", 60))
titik[, 1:2] <- round(titik[, 1:2], 3)

dir.create("data", showWarnings = FALSE)
write.csv(titik, "data/titik_pemantauan.csv", row.names = FALSE)

cat("titik pemantauan:", nrow(titik), "\n"); print(table(titik$kelompok))
