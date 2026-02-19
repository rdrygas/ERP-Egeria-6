/*
    Zapytanie SQL do pobierania numerów seryjnych środków trwałych dłuższych niż 18 znaków,
    z wykluczeniem środków trwałych, które zostały zlikwidowane.
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
    ST.S_ID AS ID,
    ST.S_NUMER_INW AS NR_INWENTARZOWY,
    TRIM( REGEXP_REPLACE( SDN.SDN_NAZWA, '\s+', ' ' ) ) AS NAZWA, -- Usunięcie nadmiarowych spacji
    TRIM( REGEXP_REPLACE( SDN.SDN_NR_FABRYCZNY, '\s+', ' ' ) ) AS NR_SERYJNY -- Usunięcie nadmiarowych spacji
    -- LENGTH( TRIM( REGEXP_REPLACE( SDN.SDN_NR_FABRYCZNY, '\s+', ' ' ) ) ) AS DLUGOSC_NR_SERYJNEGO -- Długość numeru seryjnego bez nadmiarowych spacji
FROM 
    STT_SRODKI ST
    JOIN STT_SRODKI_DANE SDN ON ST.S_ID = SDN.SDN_S_ID
    JOIN STT_STANY_SRODKA STS ON STS.STS_SDN_S_ID = SDN.SDN_S_ID AND STS.STS_SDN_ID = SDN.SDN_ID
WHERE 
    NOT EXISTS ( SELECT 1 FROM SDN_ZLIKW ZL WHERE ZL.S_ID = ST.S_ID ) -- Wykluczenie zlikwidowanych środków trwałych
    AND SDN.SDN_TYP_DATY = 'O' -- Data operacji
    AND SYSDATE BETWEEN STS.STS_DATA_OD AND STS.STS_DATA_DO -- Aktywne środki trwałe
    AND LENGTH( TRIM( REGEXP_REPLACE( SDN.SDN_NR_FABRYCZNY, '\s+', ' ' ) ) ) > 18 -- Numery seryjne dłuższe niż 18 znaków (bez nadmiarowych spacji)
    AND SUBSTR( TRIM( REGEXP_REPLACE( SDN.SDN_NR_FABRYCZNY, '\s+', ' ' ) ) , 1, 3 ) NOT IN ( '---' ) -- Wykluczenie numerów seryjnych zaczynających się od '---'
ORDER BY 
    NR_INWENTARZOWY
;
