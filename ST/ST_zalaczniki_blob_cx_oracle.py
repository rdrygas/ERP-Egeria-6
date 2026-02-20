# Skrypt do pobierania załączników z bazy danych Oracle i zapisywania ich na dysku
# Oracle Instant Client Downloads https://www.oracle.com/database/technologies/instant-client/downloads.html

import cx_Oracle
import getpass
import os
import sys

# Inicjalizacja klienta Oracle
try:
    if sys.platform.startswith('win32'): # Dla systemu Windows
        cx_Oracle.init_oracle_client(lib_dir=r"c:\instantclient_12_1") # Ścieżka do Instant Client
    elif sys.platform.startswith('linux'): # Dla systemu Linux
        cx_Oracle.init_oracle_client(lib_dir="/opt/oracle/instantclient_12_1") # Ścieżka do Instant Client
except Exception as e:
    print("Klient Oracle został już zainicjowany lub wystąpił błąd:", e)
    sys.exit(1)

host = "xxx.xxx.xxx.xxx" # Adres hosta bazy danych
port = xxx # Port bazy danych
sid = "xxx" # SID bazy danych

username = input("Podaj nazwę użytkownika do bazy danych: ") # Pobranie nazwy użytkownika od użytkownika
userpwd = getpass.getpass("Podaj hasło do bazy danych: ") # Pobranie hasła do bazy danych od użytkownika

# Połączenie z bazą danych
dsn = cx_Oracle.makedsn(host, port, sid=sid)
conn = cx_Oracle.connect(user=username, password=userpwd, dsn=dsn)
cursor = conn.cursor() # Utworzenie kursora do wykonywania zapytań

# Zapytanie SQL do pobrania danych
query = """
WITH SDN_ZLIKW AS (
SELECT DISTINCT SDN.SDN_S_ID AS S_ID
FROM KGT_DOKUMENTY DOK
JOIN STT_SRODKI_DANE SDN ON DOK.DOK_SDN_ID = SDN.SDN_ID
WHERE DOK.DOK_RDOK_KOD IN ('PL1', 'PL2', 'LAS', 'LM') )
SELECT NUMER_INW, NAZWA_PLIKU, BLOB_DATA
FROM (
SELECT NUMER_INW, NAZWA_PLIKU, Z.ZAL_BLOB AS BLOB_DATA, ROW_NUMBER() OVER (PARTITION BY NAZWA_PLIKU ORDER BY NUMER_INW) AS RN
FROM (
SELECT DISTINCT ST.S_ID AS S_ID, ST.S_NUMER_INW AS NUMER_INW, ZAL.ZAL_NAZWA AS NAZWA, ZAL.ZAL_OPIS AS OPIS, ZAL.ZAL_NAZWA_PLIKU AS NAZWA_PLIKU
FROM  STT_SRODKI ST
JOIN STT_SRODKI_DANE SDN ON ST.S_ID = SDN.SDN_S_ID
JOIN STT_STANY_SRODKA STS ON STS.STS_SDN_S_ID = SDN.SDN_S_ID AND STS.STS_SDN_ID = SDN.SDN_ID
JOIN ZKT_ZALACZNIKI ZAL ON ST.S_ID = ZAL.ZAL_S_ID
WHERE NOT EXISTS ( SELECT 1 FROM SDN_ZLIKW L WHERE L.S_ID = ST.S_ID ) 
AND SDN.SDN_TYP_DATY = 'O' AND SYSDATE BETWEEN STS.STS_DATA_OD AND STS.STS_DATA_DO ) S
JOIN ZKT_ZALACZNIKI Z ON S.S_ID = Z.ZAL_S_ID )
WHERE RN = 1 AND NAZWA_PLIKU IS NOT NULL
"""

if sys.platform.startswith('win32'):
    output_dir = "C:\\EGERIA\\ST_zalaczniki"
elif sys.platform.startswith('linux'):
    output_dir = "/home/user/EGERIA/ST_zalaczniki"
os.makedirs(output_dir, exist_ok=True)

# Wykonanie zapytania i zapis plików
cursor.execute(query) # Wykonanie zapytania SQL
for numer_inw, nazwa_pliku, blob_data in cursor.fetchall(): # Pobranie wyników zapytania
    filename = os.path.join(output_dir, f"{numer_inw}_{nazwa_pliku}")
    with open(filename, 'wb') as f:
        f.write(blob_data.read()) # Zapisanie danych BLOB do pliku
    print(f"Zapisano: {filename}")

cursor.close()
conn.close()
print("Wszystkie pliki zostały pomyślnie wyeksportowane.")
