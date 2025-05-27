import pandas as pd

# conversion rate for SDR to USD
sdr_to_usd_rate = 1.31

# file paths
csv_file_path = '/Users/Sara/Downloads/Book 38(Sheet1).csv'
imf_excel_file_path = '/Users/Sara/Downloads/SNA_DataExtraction-4.xlsx'
excel_file_path = '/Users/Sara/Downloads/SNA_DataExtraction-3.xlsx'

# loading the CSV file
csv_data = pd.read_csv(csv_file_path)

# loading the IMF Excel file
imf_data = pd.read_excel(imf_excel_file_path, sheet_name=0)

# loading the World Bank Excel file
world_bank_data = pd.read_excel(excel_file_path, sheet_name=0, header=None)

# renaming columns for easier processing
imf_data.columns = ["Country", "IMF_Credit_SDR"]
world_bank_data.columns = [
    "Country",
    "IMF_Credit_SDR",
    "World_Bank_IBRD",
    "World_Bank_IDA"
]

# --- Process IMF Data ---
# clean the IMF data by removing unnecessary rows
imf_data_cleaned = imf_data.dropna(subset=["Country", "IMF_Credit_SDR"], how="any")

# convert SDR to USD
imf_data_cleaned["IMF_Credit_SDR"] = pd.to_numeric(imf_data_cleaned["IMF_Credit_SDR"], errors="coerce")
imf_data_cleaned["IMF_Credit_USD"] = imf_data_cleaned["IMF_Credit_SDR"] * sdr_to_usd_rate

# reshape IMF data to match the required format
imf_data_reshaped = imf_data_cleaned[["Country", "IMF_Credit_USD"]].rename(
    columns={"Country": "debtorCountry", "IMF_Credit_USD": "data"}
)
imf_data_reshaped["creditorCountry"] = "IMF"

# --- Process World Bank Data ---
# clean the World Bank data by removing unnecessary rows
world_bank_data_cleaned = world_bank_data.dropna(subset=["Country"])

# convert IBRD and IDA data to numeric and sum them
world_bank_data_cleaned["World_Bank_IBRD"] = pd.to_numeric(world_bank_data_cleaned["World_Bank_IBRD"], errors="coerce")
world_bank_data_cleaned["World_Bank_IDA"] = pd.to_numeric(world_bank_data_cleaned["World_Bank_IDA"], errors="coerce")
world_bank_data_cleaned["World_Bank_Total_USD"] = (
    (world_bank_data_cleaned["World_Bank_IBRD"].fillna(0) + world_bank_data_cleaned["World_Bank_IDA"].fillna(0)) * 1_000_000
)

# reshape World Bank data to match the required format
world_bank_data_reshaped = world_bank_data_cleaned[["Country", "World_Bank_Total_USD"]].rename(
    columns={"Country": "debtorCountry", "World_Bank_Total_USD": "data"}
)
world_bank_data_reshaped["creditorCountry"] = "World Bank"

# --- combine IMF and World Bank Data ---
combined_imf_world_bank = pd.concat([imf_data_reshaped, world_bank_data_reshaped], ignore_index=True)

# --- merge with Existing CSV Data ---
final_combined_data = pd.concat([csv_data, combined_imf_world_bank], ignore_index=True)

# save the final dataset
final_combined_data.to_csv('/Users/Sara/Downloads/Final_Combined_Dataset.csv', index=False)
