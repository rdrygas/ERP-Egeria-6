/*
    Zapytanie zwracające wszystkich pracowników zatrudnionych w okresie od 2025-01-01 do 2025-12-31 na umowę o pracę.
*/

SELECT
    *
FROM
    EK_PRACOWNICY PRC,
    EK_ZATRUDNIENIE ZAT
WHERE
    ZAT.ZAT_TYP_UMOWY = 0 -- umowa o pracę
    AND ZAT.ZAT_PRC_ID = PRC.PRC_ID
    AND ZAT.ZAT_DATA_ZMIANY <= TO_DATE( '2025-12-31', 'YYYY-MM-DD' )
    AND NVL( ZAT.ZAT_DATA_DO, TO_DATE( '2025-01-01', 'YYYY-MM-DD' )) >= TO_DATE( '2025-01-01', 'YYYY-MM-DD' );