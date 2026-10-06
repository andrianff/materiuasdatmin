# ---------------------------------------------------------------
# Pembangkit berkas TIRUAN untuk latihan perayapan web (Modul 4).
# Seluruh laman, API, dan umpan di sini adalah BERKAS LOKAL --
# praktikum tidak menyentuh situs mana pun di internet.
# ---------------------------------------------------------------
import json, os, random
random.seed(2026)
os.makedirs("data", exist_ok=True)

wilayah = [
    ("Wilayah A", 1250000, 980, 72.4, "Pulau Utara", 2026),
    ("Wilayah B",  860000, 1120, 65.1, "Pulau Utara", 2026),
    ("Wilayah C", 2340000, 1450, 81.7, "Pulau Tengah", 2026),
    ("Wilayah D",  430000,  760, 48.3, "Pulau Timur", 2026),
    ("Wilayah E", 1780000, 1310, 77.9, "Pulau Tengah", 2026),
    ("Wilayah F",  610000,  845, 55.2, "Pulau Timur", 2026),
    ("Wilayah G", 1980000, 1520, 84.6, "Pulau Utara", 2026),
    ("Wilayah H",  295000,  690, 41.8, "Pulau Timur", 2026),
    ("Wilayah I", 1120000, 1005, 68.9, "Pulau Tengah", 2026),
]

# ---------- (1) laman berhalaman: daftar wilayah, 3 halaman ----------
per = 3
for h in range(1, 4):
    baris = wilayah[(h-1)*per : h*per]
    trs = "\n".join(
        f'<tr><td><a href="detail_{n.split()[-1].lower()}.html">{n}</a></td>'
        f'<td>{p:,}</td><td>{g}</td></tr>'.replace(",", ".")
        for n, p, g, _, _, _ in baris)
    nav = []
    if h > 1: nav.append(f'<a class="sebelumnya" href="daftar_{h-1}.html">Sebelumnya</a>')
    if h < 3: nav.append(f'<a class="berikutnya" href="daftar_{h+1}.html">Berikutnya</a>')
    open(f"data/daftar_{h}.html", "w").write(f"""<!DOCTYPE html>
<html lang="id"><head><meta charset="utf-8"><title>Daftar Wilayah - Halaman {h}</title></head>
<body>
<h1>Daftar Wilayah (Data Latihan)</h1>
<p class="catatan">Halaman {h} dari 3. Seluruh angka bersifat <strong>simulasi</strong>.</p>
<table class="daftar">
<thead><tr><th>Wilayah</th><th>Penduduk</th><th>Pengeluaran</th></tr></thead>
<tbody>
{trs}
</tbody></table>
<nav class="paginasi">{' | '.join(nav)}</nav>
</body></html>""")

# ---------- (2) laman detail tiap wilayah ----------
for n, p, g, a, pulau, th in wilayah:
    kode = n.split()[-1].lower()
    open(f"data/detail_{kode}.html", "w").write(f"""<!DOCTYPE html>
<html lang="id"><head><meta charset="utf-8"><title>{n} - Detail</title></head>
<body>
<h1 class="judul-wilayah">{n}</h1>
<dl class="rincian">
  <dt>Penduduk</dt><dd data-nilai="{p}">{p:,} jiwa</dd>
  <dt>Pengeluaran</dt><dd data-nilai="{g}">Rp {g:,} ribu/kapita/bulan</dd>
  <dt>Akses Internet</dt><dd data-nilai="{a}">{a} persen</dd>
  <dt>Pulau</dt><dd>{pulau}</dd>
  <dt>Tahun</dt><dd>{th}</dd>
</dl>
<p class="sumber">Sumber: survei tiruan {th}. Diperbarui 15 Januari {th}.</p>
</body></html>""".replace(",", "."))

# ---------- (3) tiruan tanggapan API (JSON) ----------
api = {"meta": {"sumber": "API tiruan", "tahun": 2026, "jumlah": len(wilayah),
                "lisensi": "hanya untuk latihan"},
       "data": [{"nama": n, "penduduk": p, "pengeluaran": g,
                 "akses_internet": a, "pulau": pulau}
                for n, p, g, a, pulau, _ in wilayah]}
json.dump(api, open("data/api_wilayah.json", "w"), indent=2, ensure_ascii=False)

# ---------- (4) umpan RSS ----------
item = "\n".join(f"""  <item>
    <title>Rilis statistik {n}</title>
    <link>https://contoh.tiruan/rilis/{n.split()[-1].lower()}</link>
    <pubDate>0{i+1} Feb 2026</pubDate>
    <description>Penduduk {p} jiwa, akses internet {a} persen.</description>
  </item>""" for i, (n, p, g, a, pulau, _) in enumerate(wilayah[:5]))
open("data/umpan_rilis.xml", "w").write(f"""<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0"><channel>
  <title>Rilis Statistik Tiruan</title>
  <link>https://contoh.tiruan/rilis</link>
  <description>Umpan tiruan untuk latihan.</description>
{item}
</channel></rss>""")

# ---------- (5) laman dengan TATA LETAK BERUBAH ----------
trs = "\n".join(f'<tr><td>{n}</td><td>{p}</td><td>{g}</td><td>{a}</td></tr>'
                for n, p, g, a, _, _ in wilayah[:5])
open("data/laman_versi_baru.html", "w").write(f"""<!DOCTYPE html>
<html lang="id"><head><meta charset="utf-8"><title>Statistik Wilayah</title></head>
<body>
<h1>Statistik Wilayah (Data Latihan)</h1>
<table id="tabel-statistik-wilayah">
<thead><tr><th>Nama Wilayah</th><th>Jumlah Penduduk</th><th>Pengeluaran</th>
<th>Akses Internet</th></tr></thead>
<tbody>
{trs}
</tbody></table>
</body></html>""")

# ---------- (6) robots.txt tiruan ----------
open("data/robots_tiruan.txt", "w").write("""User-agent: *
Disallow: /admin/
Disallow: /pencarian
Crawl-delay: 5

User-agent: PerayapNakal
Disallow: /

Sitemap: https://contoh.tiruan/sitemap.xml
""")

print("berkas tiruan dibuat:", len(os.listdir("data")), "berkas di folder data/")
