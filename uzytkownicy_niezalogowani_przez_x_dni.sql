/*
    Użytkownicy, którzy nie logowali się przez ostatnie X dni
*/

SELECT
    UZT.UZT_NAZWA AS NAZWA_UZYTKOWNIKA,
    UZT.UZT_IMIE AS IMIE,
    UZT.UZT_NAZWISKO1 AS NAZWISKO,
    UZT.UZT_BIURO AS BIURO,
    UZT.UZT_F_ADMINISTRATOR AS ADMINISTRATOR,
    UZT.UZT_F_ZABLOKOWANY AS ZABLOKOWANY,
    UZT.UZT_F_USUNIETY AS USUNIETY,
    PRC.PRC_NUMER AS NR_PRACOWNIKA 
FROM
    EAADM.EAT_UZYTKOWNICY UZT
    LEFT JOIN EGADM1.EK_PRACOWNICY PRC ON UZT.UZT_PRC_ID = PRC.PRC_ID
WHERE
    UZT.UZT_NAZWA NOT IN -- Wykluczenie użytkowników, którzy nie mają przypisanego pracownika lub imienia/nazwiska
    (  
        SELECT UZT_NAZWA
        FROM EAT_UZYTKOWNICY
        WHERE UZT_PRC_ID IS NULL OR UZT_IMIE IS NULL OR UZT_NAZWISKO1 IS NULL
    )
    AND UZT.UZT_NAZWA IN -- Wykluczenie użytkowników, którzy logowali się w ciągu ostatnich X dni (np. 180 dni)
    (
        SELECT DISTINCT SES_UZT_NAZWA
        FROM EAT_SESJE
        WHERE SES_DATA_ROZPOCZECIA BETWEEN ( SYSDATE - 180 ) AND SYSDATE
    )
    AND UZT.UZT_F_USUNIETY = 'N' -- Wykluczenie użytkowników oznaczonych jako usunięci
    AND UZT.UZT_F_ZABLOKOWANY = 'N' -- Wykluczenie użytkowników oznaczonych jako zablokowani
ORDER BY
    NAZWISKO
;
