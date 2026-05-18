import pandas as pd
import numpy as np

nutrition_df = pd.read_csv(
    "data/nutrition_dataset.csv",
    encoding="utf-8"
)


nutrition_df["food_name"] = (
    nutrition_df["food_name"]
    .astype(str)
    .str.lower()
    .str.strip()
)



def safe_value(value):

    if pd.isna(value):
        return None

    if isinstance(value, np.integer):
        return int(value)

    if isinstance(value, np.floating):
        return float(value)

    return value



def get_nutrition(label):

    label = str(label).lower().strip()

    row = nutrition_df[
        nutrition_df["food_name"] == label
    ]

    if row.empty:
        return None

    data = row.iloc[0]

    return {
        "kalori": safe_value(data.get("kalori")),
        "protein": safe_value(data.get("protein")),
        "lemak": safe_value(data.get("lemak")),
        "karbohidrat": safe_value(data.get("karbohidrat")),
        "gula": safe_value(data.get("gula")),
        "natrium": safe_value(data.get("natrium")),
        "serat": safe_value(data.get("serat")),
        "kalsium": safe_value(data.get("kalsium"))
    }