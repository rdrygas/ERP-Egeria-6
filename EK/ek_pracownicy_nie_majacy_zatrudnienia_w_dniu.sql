/*
    Zapytanie zwraca wszystkich pracowników, którzy nie mają zatrudnienia na umowę o pracę w dniu 2025-07-01.
*/

SELECT
    *
FROM
    EK_PRACOWNICY PRC
WHERE
    NOT EXISTS
        ( 
            SELECT
                1
            FROM
                EK_ZATRUDNIENIE ZAT
            WHERE
                ZAT.ZAT_TYP_UMOWY = 0 -- umowa o pracę
                AND ZAT.ZAT_PRC_ID = PRC.PRC_ID
                AND ZAT.ZAT_DATA_ZMIANY <= TO_DATE( '2025-07-01', 'YYYY-MM-DD' )
                AND NVL( ZAT.ZAT_DATA_DO, TO_DATE( '2025-07-01', 'YYYY-MM-DD' )) >= TO_DATE( '2025-07-01', 'YYYY-MM-DD' )
        )
;
