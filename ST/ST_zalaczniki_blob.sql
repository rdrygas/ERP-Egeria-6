/*
    Zapytanie SQL do pobrania unikalnych załączników BLOB dla środków trwałych,
    które nie zostały zlikwidowane, wraz z ich numerami inwentarzowymi i nazwami plików.
*/

WITH SDN_ZLIKW AS (
    SELECT DISTINCT 
        SDN.SDN_S_ID AS S_ID
    FROM 
        KGT_DOKUMENTY DOK
        JOIN STT_SRODKI_DANE SDN ON DOK.DOK_SDN_ID = SDN.SDN_ID
    WHERE 
        DOK.DOK_RDOK_KOD IN ('PL1', 'PL2', 'LAS', 'LM') -- Kody dokumentów likwidacji
)

SELECT
    NR_INWENTARZOWY,
    NAZWA_PLIKU,
    BLOB_DATA
FROM (
    SELECT
        NR_INWENTARZOWY,
        NAZWA_PLIKU,
        Z.ZAL_BLOB AS BLOB_DATA,
        ROW_NUMBER() OVER (PARTITION BY NAZWA_PLIKU ORDER BY NAZWA_PLIKU) AS RN
    FROM
        (
            SELECT DISTINCT
                ST.S_ID AS S_ID,
                ST.S_NUMER_INW AS NR_INWENTARZOWY,
                ZAL.ZAL_NAZWA AS NAZWA,
                ZAL.ZAL_OPIS AS OPIS,
                ZAL.ZAL_NAZWA_PLIKU AS NAZWA_PLIKU
            FROM 
                STT_SRODKI ST
                JOIN STT_SRODKI_DANE SDN ON ST.S_ID = SDN.SDN_S_ID
                JOIN STT_STANY_SRODKA STS ON STS.STS_SDN_S_ID = SDN.SDN_S_ID AND STS.STS_SDN_ID = SDN.SDN_ID
                JOIN ZKT_ZALACZNIKI ZAL ON ST.S_ID = ZAL.ZAL_S_ID
            WHERE 
                NOT EXISTS ( SELECT 1 FROM SDN_ZLIKW ZL WHERE ZL.S_ID = ST.S_ID )
                AND SDN.SDN_TYP_DATY = 'O'
                AND SYSDATE BETWEEN STS.STS_DATA_OD AND STS.STS_DATA_DO
        ) S
        JOIN ZKT_ZALACZNIKI Z ON S.S_ID = Z.ZAL_S_ID
)
WHERE RN = 1
ORDER BY NR_INWENTARZOWY, NAZWA_PLIKU
;

