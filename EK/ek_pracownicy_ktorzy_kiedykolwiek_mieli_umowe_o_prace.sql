/*
    Zapytanie zwraca wszystkich pracowników, którzy kiedykolwiek mieli umowę o pracę, ale nie byli zatrudnieni na umowę o pracę w dniu 2021-07-01.
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
                EK_ZATRUDNIENIE ZAT1
            WHERE
                ZAT1.ZAT_TYP_UMOWY = 0 -- umowa o pracę
                AND ZAT1.ZAT_PRC_ID = PRC.PRC_ID
                AND ZAT1.ZAT_DATA_ZMIANY <= TO_DATE( '2021-07-01', 'YYYY-MM-DD' )
                AND NVL( ZAT1.ZAT_DATA_DO, TO_DATE( '2021-07-01', 'YYYY-MM-DD' )) >= TO_DATE( '2021-07-01', 'YYYY-MM-DD' )
        )
    AND EXISTS
        ( 
            SELECT
                1
            FROM
                EK_ZATRUDNIENIE ZAT2
            WHERE
                ZAT2.ZAT_TYP_UMOWY = 0 -- umowa o pracę
                AND ZAT2.ZAT_PRC_ID = PRC.PRC_ID
        )
;