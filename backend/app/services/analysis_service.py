import pandas as pd
import numpy as np

macro_df = pd.read_csv(
    "data/dataset_angka_kecukupan_energi.csv",
    encoding="utf-8",
    on_bad_lines="skip"
)

mineral_df = pd.read_csv(
    "data/dataset_angka_kecukupan_mineral.csv",
    encoding="utf-8",
    on_bad_lines="skip"
)


def safe_value(value):

    if pd.isna(value):
        return None

    if isinstance(value, np.integer):
        return int(value)

    if isinstance(value, np.floating):
        return float(value)

    return value


def analyze(nutrition):

    results = []

    kalori = nutrition.get("kalori") or 0
    protein = nutrition.get("protein") or 0
    lemak = nutrition.get("lemak") or 0
    natrium = nutrition.get("natrium") or 0
    gula = nutrition.get("gula") or 0

    layak_count = 0
    tidak_layak_count = 0

    tidak_direkomendasikan = []

    for _, macro in macro_df.iterrows():

        kelompok_umur = safe_value(
            macro.get("kelompok_umur")
        )

        kategori = safe_value(
            macro.get("kategori")
        )

        jenis_kelamin = safe_value(
            macro.get("jenis_kelamin")
        )

        mineral_row = mineral_df[
            (mineral_df["kelompok_umur"] == kelompok_umur)
            &
            (mineral_df["jenis_kelamin"] == jenis_kelamin)
        ]

        if mineral_row.empty:
            continue

        mineral = mineral_row.iloc[0]

        status = "layak"

        alasan = []

        energi_limit = safe_value(
            macro.get("energi_kkal")
        ) or 999999

        natrium_limit = safe_value(
            mineral.get("natrium_mg")
        ) or 999999

        if kalori > 400:
            alasan.append("Kalori makanan cukup tinggi")

        if lemak > 20:
            alasan.append("Lemak makanan cukup tinggi")

        if gula > 20:
            alasan.append("Kandungan gula cukup tinggi")

        if natrium > 300:
            alasan.append("Kandungan natrium cukup tinggi")

        if natrium > natrium_limit:
            status = "tidak_layak"
            alasan.append(
                f"Natrium melebihi batas ({natrium_limit} mg)"
            )

        if kalori > energi_limit:
            status = "tidak_layak"
            alasan.append(
                f"Kalori melebihi kebutuhan harian ({energi_limit} kkal)"
            )

        if status == "tidak_layak":
            tingkat_risiko = "tinggi"
            tidak_layak_count += 1
            tidak_direkomendasikan.append({
                "kelompok_umur": kelompok_umur,
                "jenis_kelamin": jenis_kelamin
            })
        else:
            tingkat_risiko = "rendah"
            layak_count += 1

        results.append({
            "kategori": kategori,
            "kelompok_umur": kelompok_umur,
            "jenis_kelamin": jenis_kelamin,
            "status": status,
            "tingkat_risiko": tingkat_risiko,
            "alasan": alasan
        })

    ringkasan_gizi = {
        "kalori_tinggi": kalori > 300,
        "protein_tinggi": protein > 20,
        "lemak_tinggi": lemak > 20,
        "natrium_tinggi": natrium > 300,
        "gula_tinggi": gula > 20
    }

    if tidak_layak_count >= 10:
        status_keseluruhan = "berisiko_tinggi"
    elif tidak_layak_count >= 5:
        status_keseluruhan = "cukup_berisiko"
    else:
        status_keseluruhan = "relatif_aman"

    rekomendasi = []

    if gula > 20:
        rekomendasi.append("Batasi konsumsi makanan tinggi gula")

    if lemak > 20:
        rekomendasi.append("Kurangi konsumsi makanan berminyak")

    if natrium > 300:
        rekomendasi.append("Kurangi konsumsi makanan tinggi natrium")

    if not rekomendasi:
        rekomendasi.append("Makanan masih dalam batas aman konsumsi")

    # ✅ FIX: kesimpulan_ai dibuat dinamis berdasarkan data nutrisi aktual
    # Sebelumnya selalu mengembalikan teks yang sama tanpa melihat kondisi makanan
    kandungan_bermasalah = []
    if gula > 20:
        kandungan_bermasalah.append("gula")
    if lemak > 20:
        kandungan_bermasalah.append("lemak")
    if natrium > 300:
        kandungan_bermasalah.append("natrium")

    if tidak_layak_count >= 10:
        if kandungan_bermasalah:
            daftar = ", ".join(kandungan_bermasalah)
            kesimpulan_ai = (
                f"Makanan ini berisiko tinggi untuk banyak kelompok usia. "
                f"Kandungan {daftar} yang tinggi perlu sangat diperhatikan. "
                f"Disarankan untuk membatasi konsumsi atau menghindari makanan ini."
            )
        else:
            kesimpulan_ai = (
                "Makanan ini berisiko tinggi untuk banyak kelompok usia "
                "karena kandungan kalori atau natrium yang melebihi batas harian."
            )

    elif tidak_layak_count >= 5:
        if kandungan_bermasalah:
            daftar = ", ".join(kandungan_bermasalah)
            kesimpulan_ai = (
                f"Makanan ini cukup berisiko untuk beberapa kelompok usia. "
                f"Perhatikan kandungan {daftar} yang tergolong tinggi. "
                f"Konsumsi secukupnya dan imbangi dengan makanan bergizi lainnya."
            )
        else:
            kesimpulan_ai = (
                "Makanan ini cukup berisiko untuk beberapa kelompok usia. "
                "Konsumsi secukupnya dan imbangi dengan pola makan yang seimbang."
            )

    else:
        if kandungan_bermasalah:
            daftar = ", ".join(kandungan_bermasalah)
            kesimpulan_ai = (
                f"Makanan ini relatif aman dikonsumsi oleh sebagian besar kelompok usia. "
                f"Namun tetap perhatikan kandungan {daftar} agar tidak dikonsumsi berlebihan."
            )
        else:
            kesimpulan_ai = (
                "Makanan ini aman dan kandungan gizinya dalam batas kecukupan harian "
                "untuk sebagian besar kelompok usia. Tetap jaga pola makan yang beragam."
            )

    return {
        "ringkasan_gizi": ringkasan_gizi,

        "status_keseluruhan": status_keseluruhan,

        "ringkasan_analisis": {
            "jumlah_layak": layak_count,
            "jumlah_tidak_layak": tidak_layak_count,
            "tidak_direkomendasikan_untuk": tidak_direkomendasikan
        },

        "rekomendasi": rekomendasi,

        "kesimpulan_ai": kesimpulan_ai,

        "analisis_detail": results
    }