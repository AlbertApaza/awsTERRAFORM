import pandas as pd
import json
import time
import os

csv_path = "../IOT-temp.csv"
if not os.path.exists(csv_path):
    print(f"Error: No se encontró el archivo CSV en la ruta {csv_path}")
    exit(1)

df = pd.read_csv(csv_path)

output_data = []

for index, row in df.iterrows():
    record = {
        'id': row['id'],
        'room_id': row['room_id'],
        'noted_date': row['noted_date'],
        'temp': row['temp'],
        'out_in': row['out_in']
    }
    output_data.append(record)

    time.sleep(0.5)
    print('Simulación de análisis de dato: \n', record)

output_path = "output/IOT-temp-output.json"
os.makedirs(os.path.dirname(output_path), exist_ok=True)
with open(output_path, "w") as f:
    json.dump(output_data, f, indent=4)

print("Análisis local completado y almacenado en output/IOT-temp-output.json")
