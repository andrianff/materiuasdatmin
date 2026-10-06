# ---------------------------------------------------------------
# Pembangkit data simulasi Modul 11 -- Association Rule Mining
# Data ILUSTRATIF, bukan data nyata dan bukan data resmi instansi.
# ---------------------------------------------------------------
set.seed(2026)

n_trx <- 1200

barang <- c("air_mineral","beras","gula","kopi","teh","susu","roti","mentega","selai",
            "telur","minyak_goreng","mi_instan","sabun","sampo","deterjen",
            "popok","biskuit","cokelat","keju","buah")

# peluang dasar tiap barang (air_mineral sengaja sangat sering dibeli)
p0 <- c(air_mineral=0.62, beras=0.30, gula=0.22, kopi=0.20, teh=0.16, susu=0.24,
        roti=0.22, mentega=0.12, selai=0.08, telur=0.28, minyak_goreng=0.24,
        mi_instan=0.26, sabun=0.18, sampo=0.14, deterjen=0.16,
        popok=0.07, biskuit=0.18, cokelat=0.12, keju=0.08, buah=0.20)

trx <- vector("list", n_trx)
for (i in seq_len(n_trx)) {
  keranjang <- barang[runif(length(barang)) < p0]

  # --- kaitan yang SENGAJA ditanam ---
  # roti & mentega -> susu (kuat)
  if (all(c("roti","mentega") %in% keranjang) && runif(1) < 0.72)
    keranjang <- c(keranjang, "susu")
  # roti -> selai (sedang)
  if ("roti" %in% keranjang && runif(1) < 0.30) keranjang <- c(keranjang, "selai")
  # kopi -> gula (kuat, dua arah)
  if ("kopi" %in% keranjang && runif(1) < 0.65) keranjang <- c(keranjang, "gula")
  if ("gula" %in% keranjang && runif(1) < 0.25) keranjang <- c(keranjang, "teh")
  # sabun & sampo -> deterjen (kelompok perawatan)
  if (all(c("sabun","sampo") %in% keranjang) && runif(1) < 0.55)
    keranjang <- c(keranjang, "deterjen")
  # popok -> susu (kaitan langka tetapi kuat)
  if ("popok" %in% keranjang && runif(1) < 0.80) keranjang <- c(keranjang, "susu")
  # keju -> roti
  if ("keju" %in% keranjang && runif(1) < 0.60) keranjang <- c(keranjang, "roti")

  keranjang <- unique(keranjang)
  if (length(keranjang) == 0) keranjang <- sample(barang, 1)
  trx[[i]] <- keranjang
}

# --- bentuk panjang: satu baris satu barang ---
panjang <- do.call(rbind, lapply(seq_len(n_trx), function(i)
  data.frame(id_transaksi = sprintf("T%04d", i), item = sort(trx[[i]]),
             stringsAsFactors = FALSE)))

dir.create("data", showWarnings = FALSE)
write.csv(panjang, "data/transaksi_ritel.csv", row.names = FALSE, quote = TRUE)

# --- keterangan barang: untuk agregasi ke tingkat kategori ---
kategori <- c(air_mineral="Minuman", kopi="Minuman", teh="Minuman", susu="Minuman",
              beras="Bahan Pokok", gula="Bahan Pokok", minyak_goreng="Bahan Pokok",
              telur="Bahan Pokok", mi_instan="Bahan Pokok",
              roti="Roti & Olesan", mentega="Roti & Olesan", selai="Roti & Olesan",
              keju="Roti & Olesan", biskuit="Kudapan", cokelat="Kudapan", buah="Kudapan",
              sabun="Perawatan", sampo="Perawatan", deterjen="Perawatan", popok="Perawatan")
write.csv(data.frame(item = names(kategori), kategori = unname(kategori)),
          "data/keterangan_barang.csv", row.names = FALSE, quote = TRUE)

cat("transaksi:", n_trx, "| baris:", nrow(panjang),
    "| rata-rata isi keranjang:", round(nrow(panjang)/n_trx, 2), "\n")

# ---------------------------------------------------------------
# Data kedua: kasus statistik resmi -- kejadian bersama indikator
# keterbatasan rumah tangga (menyerupai pendataan sosial-ekonomi).
# ILUSTRATIF, bukan data resmi.
# ---------------------------------------------------------------
set.seed(2027)
n_rt <- 900

indik <- c("air_tak_layak","sanitasi_tak_layak","atap_lantai_tak_layak","rumah_sempit",
           "bahan_bakar_kayu","tanpa_listrik_memadai","tanpa_internet",
           "kepala_rt_pendidikan_rendah","anak_putus_sekolah","pekerja_informal",
           "tanpa_jaminan_kesehatan","tanpa_tabungan")

q0 <- c(air_tak_layak=0.22, sanitasi_tak_layak=0.20, atap_lantai_tak_layak=0.14,
        rumah_sempit=0.26, bahan_bakar_kayu=0.18, tanpa_listrik_memadai=0.10,
        tanpa_internet=0.30, kepala_rt_pendidikan_rendah=0.28,
        anak_putus_sekolah=0.06, pekerja_informal=0.42,
        tanpa_jaminan_kesehatan=0.24, tanpa_tabungan=0.38)

rt <- vector("list", n_rt)
for (i in seq_len(n_rt)) {
  k <- indik[runif(length(indik)) < q0]
  # keterbatasan permukiman cenderung berkelompok
  if ("air_tak_layak" %in% k && runif(1) < 0.70) k <- c(k, "sanitasi_tak_layak")
  if ("sanitasi_tak_layak" %in% k && runif(1) < 0.45) k <- c(k, "atap_lantai_tak_layak")
  if ("bahan_bakar_kayu" %in% k && runif(1) < 0.55) k <- c(k, "tanpa_listrik_memadai")
  # keterbatasan ekonomi-pendidikan
  if ("kepala_rt_pendidikan_rendah" %in% k && runif(1) < 0.60) k <- c(k, "pekerja_informal")
  if ("pekerja_informal" %in% k && runif(1) < 0.50) k <- c(k, "tanpa_jaminan_kesehatan")
  if ("tanpa_tabungan" %in% k && runif(1) < 0.35) k <- c(k, "pekerja_informal")
  # anak putus sekolah: jarang tetapi berkaitan kuat
  if ("anak_putus_sekolah" %in% k && runif(1) < 0.75) k <- c(k, "kepala_rt_pendidikan_rendah")
  if ("anak_putus_sekolah" %in% k && runif(1) < 0.70) k <- c(k, "tanpa_tabungan")
  k <- unique(k)
  rt[[i]] <- k
}

panjang_rt <- do.call(rbind, lapply(seq_len(n_rt), function(i) {
  if (length(rt[[i]]) == 0) return(NULL)
  data.frame(id_rt = sprintf("RT%04d", i), indikator = sort(rt[[i]]),
             stringsAsFactors = FALSE)
}))
write.csv(panjang_rt, "data/keterbatasan_rt.csv", row.names = FALSE, quote = TRUE)

cat("rumah tangga:", n_rt, "| baris:", nrow(panjang_rt),
    "| rata-rata indikator per RT:", round(nrow(panjang_rt)/n_rt, 2), "\n")
