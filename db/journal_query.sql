SELECT * FROM "tbl_Journal" WHERE "fk_FreiwilligenEinsatz" = 0;

UPDATE "tbl_Journal" SET "fk_FreiwilligenEinsatz" = NULL WHERE "fk_FreiwilligenEinsatz" = 0;


UPDATE "tbl_Journal" SET "fk_FreiwilligenEinsatz" = NULL WHERE "pk_Journal" IN (
SELECT j."pk_Journal" FROM "tbl_Journal" AS j
LEFT JOIN "tbl_FreiwilligenEinsätze" AS e ON e."pk_FreiwilligenEinsatz" = j."fk_FreiwilligenEinsatz"
WHERE e."fk_PersonenRolle" IS NULL
);

SELECT j."pk_Journal" FROM "tbl_Journal" AS j
LEFT JOIN "tbl_FreiwilligenEinsätze" AS e ON e."pk_FreiwilligenEinsatz" = j."fk_FreiwilligenEinsatz"
WHERE e."fk_PersonenRolle" IS NULL;

-- count journal record relation count
SELECT COUNT(ro."t_RollenBezeichnung"), ro."t_RollenBezeichnung" FROM "tbl_Journal" AS j
LEFT JOIN "tbl_JournalKategorien" AS jk ON jk."pk_JournalKategorie" = j."fk_JournalKategorie"
LEFT JOIN "tbl_FreiwilligenEinsätze" AS fe ON fe."pk_FreiwilligenEinsatz" = j."fk_FreiwilligenEinsatz"
LEFT JOIN "tbl_Hauptpersonen" AS hp ON j."fk_Hauptperson" = hp."pk_Hauptperson"
LEFT JOIN "tbl_Personenrollen" AS pr ON pr."fk_Hauptperson" = hp."pk_Hauptperson"
LEFT JOIN "tbl_Rollen" AS ro ON ro."pk_Rolle" = pr."z_Rolle"
GROUP BY ro."t_RollenBezeichnung";
