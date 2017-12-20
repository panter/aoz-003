UPDATE "tbl_Ausbildungen" SET "fk_AusbildungsTyp" = NULL WHERE "fk_AusbildungsTyp" = 0;

ALTER TABLE ONLY "tbl_Ausbildungen" ADD CONSTRAINT "tbl_Ausbildungen_fk_AusbildungsTyp_fkey" FOREIGN KEY ("fk_AusbildungsTyp") REFERENCES "tbl_AusbildungsTypen"("pk_AusbildungsTyp");

ALTER TABLE ONLY "tbl_Ausbildungen" ADD CONSTRAINT "tbl_Ausbildungen_fk_Hauptperson_fkey" FOREIGN KEY ("fk_Hauptperson") REFERENCES "tbl_Hauptpersonen"("pk_Hauptperson");

ALTER TABLE ONLY "tbl_Begleitete" ADD CONSTRAINT "tbl_Begleitete_fk_FamilienRolle_fkey" FOREIGN KEY ("fk_FamilienRolle") REFERENCES "tbl_FamilienRollen"("pk_FamilienRolle");

ALTER TABLE ONLY "tbl_Begleitete" ADD CONSTRAINT "tbl_Begleitete_fk_PersonenRolle_fkey" FOREIGN KEY ("fk_PersonenRolle") REFERENCES "tbl_Personenrollen"("pk_PersonenRolle");

ALTER TABLE ONLY "tbl_EinsatzOrteProEinsatzFunktion" ADD CONSTRAINT "tbl_EinsatzOrteProEinsatzFunktion_fk_EinsatzFunktion_fkey" FOREIGN KEY ("fk_EinsatzFunktion") REFERENCES "tbl_FreiwilligenFunktionen"("pk_FreiwilligenFunktion");

ALTER TABLE ONLY "tbl_EinsatzOrteProEinsatzFunktion" ADD CONSTRAINT "tbl_EinsatzOrteProEinsatzFunktion_fk_EinsatzOrt_fkey" FOREIGN KEY ("fk_EinsatzOrt") REFERENCES "tbl_EinsatzOrte"("pk_EinsatzOrt");

UPDATE "tbl_EinsatzOrte" SET "fk_PlzOrt" = NULL WHERE "fk_PlzOrt" = 0;
ALTER TABLE ONLY "tbl_EinsatzOrte" ADD CONSTRAINT "tbl_EinsatzOrte_fk_PlzOrt_fkey" FOREIGN KEY ("fk_PlzOrt") REFERENCES "tbl_PlzOrt"("pk_PlzOrt");

ALTER TABLE ONLY "tbl_FallStelleProTeilnehmer" ADD CONSTRAINT "tbl_FallStelleProTeilnehmer_fk_Fallstelle_fkey" FOREIGN KEY ("fk_Fallstelle") REFERENCES "tbl_FallStellen"("pk_FallStelle");

ALTER TABLE ONLY "tbl_FallStelleProTeilnehmer" ADD CONSTRAINT "tbl_FallStelleProTeilnehmer_fk_Kontaktperson_fkey" FOREIGN KEY ("fk_Kontaktperson") REFERENCES "tbl_KontaktPersonen"("pk_Kontaktperson");

ALTER TABLE ONLY "tbl_FallStelleProTeilnehmer" ADD CONSTRAINT "tbl_FallStelleProTeilnehmer_fk_PersonenRolle_fkey" FOREIGN KEY ("fk_PersonenRolle") REFERENCES "tbl_Personenrollen"("pk_PersonenRolle");

ALTER TABLE ONLY "tbl_FallStellen" ADD CONSTRAINT "tbl_FallStellen_fk_PLZ_fkey" FOREIGN KEY ("fk_PLZ") REFERENCES "tbl_PlzOrt"("pk_PlzOrt");

UPDATE "tbl_FreiwilligenEinsätze" SET "fk_Begleitete" = NULL WHERE "fk_Begleitete" IN (
		SELECT "tbl_FreiwilligenEinsätze"."fk_Begleitete" FROM "tbl_FreiwilligenEinsätze"	LEFT OUTER JOIN "tbl_Begleitete" ON "tbl_Begleitete"."pk_Begleitete" = "tbl_FreiwilligenEinsätze"."fk_Begleitete" WHERE "tbl_Begleitete"."pk_Begleitete" IS NULL AND "tbl_FreiwilligenEinsätze"."fk_Begleitete" IS NOT NULL);

ALTER TABLE ONLY "tbl_FreiwilligenEinsätze" ADD CONSTRAINT "tbl_FreiwilligenEinsätze_fk_Begleitete_fkey" FOREIGN KEY ("fk_Begleitete") REFERENCES "tbl_Begleitete"("pk_Begleitete");

ALTER TABLE ONLY "tbl_FreiwilligenEinsätze" ADD CONSTRAINT "tbl_FreiwilligenEinsätze_fk_EinsatzOrt_fkey" FOREIGN KEY ("fk_EinsatzOrt") REFERENCES "tbl_EinsatzOrte"("pk_EinsatzOrt");

ALTER TABLE ONLY "tbl_FreiwilligenEinsätze" ADD CONSTRAINT "tbl_FreiwilligenEinsätze_fk_FreiwilligenFunktion_fkey" FOREIGN KEY ("fk_FreiwilligenFunktion") REFERENCES "tbl_FreiwilligenFunktionen"("pk_FreiwilligenFunktion");

ALTER TABLE ONLY "tbl_FreiwilligenEinsätze" ADD CONSTRAINT "tbl_FreiwilligenEinsätze_fk_Kostenträger_fkey" FOREIGN KEY ("fk_Kostenträger") REFERENCES "tbl_Kostenträger"("pk_Kostenträger");

UPDATE "tbl_FreiwilligenEinsätze" SET "fk_Kurs" = NULL
	WHERE "fk_Kurs" IN (
		SELECT "tbl_FreiwilligenEinsätze"."fk_Kurs" FROM "tbl_FreiwilligenEinsätze"	LEFT OUTER JOIN "tbl_Kurse" ON "tbl_Kurse"."pk_Kurs" = "tbl_FreiwilligenEinsätze"."fk_Begleitete" WHERE "tbl_Kurse"."pk_Kurs" IS NULL AND "tbl_FreiwilligenEinsätze"."fk_Kurs" IS NOT NULL);

ALTER TABLE ONLY "tbl_FreiwilligenEinsätze" ADD CONSTRAINT "tbl_FreiwilligenEinsätze_fk_Kurs_fkey" FOREIGN KEY ("fk_Kurs") REFERENCES "tbl_Kurse"("pk_Kurs");

UPDATE "tbl_FreiwilligenEinsätze" SET "fk_Lehrmittel" = NULL WHERE "fk_Lehrmittel" IN (
  SELECT "tbl_FreiwilligenEinsätze"."fk_Lehrmittel" FROM "tbl_FreiwilligenEinsätze" LEFT OUTER JOIN "tbl_Lehrmittel" ON "tbl_Lehrmittel"."pk_Lehrmittel" = "tbl_FreiwilligenEinsätze"."fk_Begleitete"
WHERE "tbl_Lehrmittel"."pk_Lehrmittel" IS NULL AND "tbl_FreiwilligenEinsätze"."fk_Lehrmittel" IS NOT NULL);

ALTER TABLE ONLY "tbl_FreiwilligenEinsätze" ADD CONSTRAINT "tbl_FreiwilligenEinsätze_fk_Lehrmittel_fkey" FOREIGN KEY ("fk_Lehrmittel") REFERENCES "tbl_Lehrmittel"("pk_Lehrmittel");

ALTER TABLE ONLY "tbl_FreiwilligenEinsätze" ADD CONSTRAINT "tbl_FreiwilligenEinsätze_fk_PersonenRolle_fkey" FOREIGN KEY ("fk_PersonenRolle") REFERENCES "tbl_Personenrollen"("pk_PersonenRolle");

UPDATE "tbl_FreiwilligenEinsätze" SET "fk_Semester" = NULL WHERE "fk_Semester" IN (
  SELECT "tbl_FreiwilligenEinsätze"."fk_Semester" FROM "tbl_FreiwilligenEinsätze" LEFT OUTER JOIN "tbl_Semester" ON "tbl_Semester"."pk_Semester" = "tbl_FreiwilligenEinsätze"."fk_Begleitete"
WHERE "tbl_Semester"."pk_Semester" IS NULL AND "tbl_FreiwilligenEinsätze"."fk_Semester" IS NOT NULL);

ALTER TABLE ONLY "tbl_FreiwilligenEinsätze" ADD CONSTRAINT "tbl_FreiwilligenEinsätze_fk_Semester_fkey" FOREIGN KEY ("fk_Semester") REFERENCES "tbl_Semester"("pk_Semester");


ALTER TABLE ONLY "tbl_FreiwilligenEntschädigung" ADD CONSTRAINT "tbl_FreiwilligenEntschädigung_fk_PersonenRolle_fkey" FOREIGN KEY ("fk_PersonenRolle") REFERENCES "tbl_Personenrollen"("pk_PersonenRolle");

ALTER TABLE ONLY "tbl_FreiwilligenEntschädigung" ADD CONSTRAINT "tbl_FreiwilligenEntschädigung_fk_Semester_fkey" FOREIGN KEY ("fk_Semester") REFERENCES "tbl_Semester"("pk_Semester");

ALTER TABLE ONLY "tbl_FreiwilligenFunktionen" ADD CONSTRAINT "tbl_FreiwilligenFunktionen_fk_Rolle_fkey" FOREIGN KEY ("fk_Rolle") REFERENCES "tbl_Rollen"("pk_Rolle");

ALTER TABLE ONLY "tbl_Hauptpersonen" ADD CONSTRAINT "tbl_Hauptpersonen_fk_PLZ_fkey" FOREIGN KEY ("fk_PLZ") REFERENCES "tbl_PlzOrt"("pk_PlzOrt");

UPDATE "tbl_Journal" SET "fk_FreiwilligenEinsatz" = NULL WHERE "fk_FreiwilligenEinsatz" IN (
  SELECT "tbl_Journal"."fk_FreiwilligenEinsatz" FROM "tbl_Journal" LEFT OUTER JOIN "tbl_FreiwilligenEinsätze" ON "tbl_FreiwilligenEinsätze"."pk_FreiwilligenEinsatz" = "tbl_Journal"."fk_FreiwilligenEinsatz"
WHERE "tbl_FreiwilligenEinsätze"."pk_FreiwilligenEinsatz" IS NULL AND "tbl_Journal"."fk_FreiwilligenEinsatz" IS NOT NULL);

ALTER TABLE ONLY "tbl_Journal" ADD CONSTRAINT "tbl_Journal_fk_FreiwilligenEinsatz_fkey" FOREIGN KEY ("fk_FreiwilligenEinsatz") REFERENCES "tbl_FreiwilligenEinsätze"("pk_FreiwilligenEinsatz");

ALTER TABLE ONLY "tbl_Journal" ADD CONSTRAINT "tbl_Journal_fk_Hauptperson_fkey" FOREIGN KEY ("fk_Hauptperson") REFERENCES "tbl_Hauptpersonen"("pk_Hauptperson");

ALTER TABLE ONLY "tbl_Journal" ADD CONSTRAINT "tbl_Journal_fk_JournalKategorie_fkey" FOREIGN KEY ("fk_JournalKategorie") REFERENCES "tbl_JournalKategorien"("pk_JournalKategorie");

ALTER TABLE ONLY "tbl_KontaktPersonen" ADD CONSTRAINT "tbl_KontaktPersonen_fk_FallStelle_fkey" FOREIGN KEY ("fk_FallStelle") REFERENCES "tbl_FallStellen"("pk_FallStelle");

ALTER TABLE ONLY "tbl_Kontoangaben" ADD CONSTRAINT "tbl_Kontoangaben_fk_Hauptperson_fkey" FOREIGN KEY ("fk_Hauptperson") REFERENCES "tbl_Hauptpersonen"("pk_Hauptperson");

UPDATE "tbl_Kontoangaben" SET "fk_PlzOrt" = NULL WHERE "fk_PlzOrt" IN (
  SELECT "tbl_Kontoangaben"."fk_PlzOrt" FROM "tbl_Kontoangaben" LEFT OUTER JOIN "tbl_PlzOrt" ON "tbl_PlzOrt"."pk_PlzOrt" = "tbl_Kontoangaben"."fk_PlzOrt"
WHERE "tbl_PlzOrt"."pk_PlzOrt" IS NULL AND "tbl_Kontoangaben"."fk_PlzOrt" IS NOT NULL);

ALTER TABLE ONLY "tbl_Kontoangaben" ADD CONSTRAINT "tbl_Kontoangaben_fk_PlzOrt_fkey" FOREIGN KEY ("fk_PlzOrt") REFERENCES "tbl_PlzOrt"("pk_PlzOrt");

ALTER TABLE ONLY "tbl_Kurse" ADD CONSTRAINT "tbl_Kurse_fk_Kursart_fkey" FOREIGN KEY ("fk_Kursart") REFERENCES "tbl_Kursarten"("pk_Kursart");

ALTER TABLE ONLY "tbl_Kurspräsenzen" ADD CONSTRAINT "tbl_Kurspräsenzen_fk_Begleitete_fkey" FOREIGN KEY ("fk_Begleitete") REFERENCES "tbl_Begleitete"("pk_Begleitete");

ALTER TABLE ONLY "tbl_Kurspräsenzen" ADD CONSTRAINT "tbl_Kurspräsenzen_fk_Kurs_fkey" FOREIGN KEY ("fk_Kurs") REFERENCES "tbl_Kurse"("pk_Kurs");

ALTER TABLE ONLY "tbl_Kurspräsenzen" ADD CONSTRAINT "tbl_Kurspräsenzen_fk_Kursteilnehmer_fkey" FOREIGN KEY ("fk_Kursteilnehmer") REFERENCES "tbl_Kursteilnehmer"("pk_Kursteilnehmer");

ALTER TABLE ONLY "tbl_Kursteilnehmer" ADD CONSTRAINT "tbl_Kursteilnehmer_fk_Begleitete_fkey" FOREIGN KEY ("fk_Begleitete") REFERENCES "tbl_Begleitete"("pk_Begleitete");

ALTER TABLE ONLY "tbl_Kursteilnehmer" ADD CONSTRAINT "tbl_Kursteilnehmer_fk_Kurs_fkey" FOREIGN KEY ("fk_Kurs") REFERENCES "tbl_Kurse"("pk_Kurs");

ALTER TABLE ONLY "tbl_Personenrollen" ADD CONSTRAINT "tbl_Personenrollen_fk_Hauptperson_fkey" FOREIGN KEY ("fk_Hauptperson") REFERENCES "tbl_Hauptpersonen"("pk_Hauptperson");

UPDATE "tbl_Personenrollen" SET "fk_Kostenträger" = NULL WHERE "fk_Kostenträger" IN (
  SELECT "tbl_Personenrollen"."fk_Kostenträger" FROM "tbl_Personenrollen" LEFT OUTER JOIN "tbl_Kostenträger" ON "tbl_Kostenträger"."pk_Kostenträger" = "tbl_Personenrollen"."fk_Kostenträger"
WHERE "tbl_Kostenträger"."pk_Kostenträger" IS NULL AND "tbl_Personenrollen"."fk_Kostenträger" IS NOT NULL);

ALTER TABLE ONLY "tbl_Personenrollen" ADD CONSTRAINT "tbl_Personenrollen_fk_Kostenträger_fkey" FOREIGN KEY ("fk_Kostenträger") REFERENCES "tbl_Kostenträger"("pk_Kostenträger");

ALTER TABLE ONLY "tbl_Personenrollen" ADD CONSTRAINT "tbl_Personenrollen_z_Rolle_fkey" FOREIGN KEY ("z_Rolle") REFERENCES "tbl_Rollen"("pk_Rolle");

ALTER TABLE ONLY "tbl_PlzOrt" ADD CONSTRAINT "tbl_PlzOrt_fk_Land_fkey" FOREIGN KEY ("fk_Land") REFERENCES "tbl_Länder"("pk_Land");

ALTER TABLE ONLY "tbl_Semester" ADD CONSTRAINT "tbl_Semester_fk_Rolle_fkey" FOREIGN KEY ("fk_Rolle") REFERENCES "tbl_Rollen"("pk_Rolle");

UPDATE "tbl_Spesenansätze" SET "fk_Personenrolle" = NULL WHERE "fk_Personenrolle" IN (
  SELECT "tbl_Spesenansätze"."fk_Personenrolle" FROM "tbl_Spesenansätze" LEFT OUTER JOIN "tbl_Personenrollen" ON "tbl_Personenrollen"."pk_PersonenRolle" = "tbl_Spesenansätze"."fk_Personenrolle"
WHERE "tbl_Personenrollen"."pk_PersonenRolle" IS NULL AND "tbl_Spesenansätze"."fk_Personenrolle" IS NOT NULL);

ALTER TABLE ONLY "tbl_Spesenansätze" ADD CONSTRAINT "tbl_Spesenansätze_fk_Personenrolle_fkey" FOREIGN KEY ("fk_Personenrolle") REFERENCES "tbl_Personenrollen"("pk_PersonenRolle");

ALTER TABLE ONLY "tbl_SpracheProHauptperson" ADD CONSTRAINT "tbl_SpracheProHauptperson_fk_Hauptperson_fkey" FOREIGN KEY ("fk_Hauptperson") REFERENCES "tbl_Hauptpersonen"("pk_Hauptperson");

ALTER TABLE ONLY "tbl_SpracheProHauptperson" ADD CONSTRAINT "tbl_SpracheProHauptperson_fk_KenntnisstufeLe_fkey" FOREIGN KEY ("fk_KenntnisstufeLe") REFERENCES "tbl_Sprachkenntnisse"("pk_Sprachkenntnis");

ALTER TABLE ONLY "tbl_SpracheProHauptperson" ADD CONSTRAINT "tbl_SpracheProHauptperson_fk_KenntnisstufeSc_fkey" FOREIGN KEY ("fk_KenntnisstufeSc") REFERENCES "tbl_Sprachkenntnisse"("pk_Sprachkenntnis");

ALTER TABLE ONLY "tbl_SpracheProHauptperson" ADD CONSTRAINT "tbl_SpracheProHauptperson_fk_KenntnisstufeSp_fkey" FOREIGN KEY ("fk_KenntnisstufeSp") REFERENCES "tbl_Sprachkenntnisse"("pk_Sprachkenntnis");

ALTER TABLE ONLY "tbl_SpracheProHauptperson" ADD CONSTRAINT "tbl_SpracheProHauptperson_fk_KenntnisstufeVe_fkey" FOREIGN KEY ("fk_KenntnisstufeVe") REFERENCES "tbl_Sprachkenntnisse"("pk_Sprachkenntnis");

ALTER TABLE ONLY "tbl_SpracheProHauptperson" ADD CONSTRAINT "tbl_SpracheProHauptperson_fk_Sprache_fkey" FOREIGN KEY ("fk_Sprache") REFERENCES "tbl_Sprachen"("pk_Sprache");

UPDATE "tbl_Stundenerfassung" SET "fk_FreiwilligenEinsatz" = NULL WHERE "fk_FreiwilligenEinsatz" IN (
  SELECT "tbl_Stundenerfassung"."fk_FreiwilligenEinsatz" FROM "tbl_Stundenerfassung" LEFT OUTER JOIN "tbl_FreiwilligenEinsätze" ON "tbl_FreiwilligenEinsätze"."pk_FreiwilligenEinsatz" = "tbl_Stundenerfassung"."fk_FreiwilligenEinsatz"
WHERE "tbl_FreiwilligenEinsätze"."pk_FreiwilligenEinsatz" IS NULL AND "tbl_Stundenerfassung"."fk_FreiwilligenEinsatz" IS NOT NULL);

ALTER TABLE ONLY "tbl_Stundenerfassung" ADD CONSTRAINT "tbl_Stundenerfassung_fk_FreiwilligenEinsatz_fkey" FOREIGN KEY ("fk_FreiwilligenEinsatz") REFERENCES "tbl_FreiwilligenEinsätze"("pk_FreiwilligenEinsatz");

ALTER TABLE ONLY "tbl_Stundenerfassung" ADD CONSTRAINT "tbl_Stundenerfassung_fk_PersonenRolle_fkey" FOREIGN KEY ("fk_PersonenRolle") REFERENCES "tbl_Personenrollen"("pk_PersonenRolle");

ALTER TABLE ONLY "tbl_Stundenerfassung" ADD CONSTRAINT "tbl_Stundenerfassung_fk_Semester_fkey" FOREIGN KEY ("fk_Semester") REFERENCES "tbl_Semester"("pk_Semester");

ALTER TABLE ONLY "tbl_Veranstaltungen" ADD CONSTRAINT "tbl_Veranstaltungen_fk_FreiwilligenVeranstaltung_fkey" FOREIGN KEY ("fk_FreiwilligenVeranstaltung") REFERENCES "tbl_FreiwilligenVeranstaltungen"("pk_FreiwilligenVeranstaltung");

UPDATE "tbl_Veranstaltungsteilnehmer" SET "fk_Veranstaltung" = NULL WHERE "fk_Veranstaltung" IN (
  SELECT "tbl_Veranstaltungsteilnehmer"."fk_Veranstaltung" FROM "tbl_Veranstaltungsteilnehmer" LEFT OUTER JOIN "tbl_Veranstaltungen" ON "tbl_Veranstaltungen"."pk_Veranstaltung" = "tbl_Veranstaltungsteilnehmer"."fk_Veranstaltung" WHERE "tbl_Veranstaltungen"."pk_Veranstaltung" IS NULL AND "tbl_Veranstaltungsteilnehmer"."fk_Veranstaltung" IS NOT NULL);

ALTER TABLE ONLY "tbl_Veranstaltungsteilnehmer" ADD CONSTRAINT "tbl_Veranstaltungsteilnehmer_fk_Veranstaltung_fkey" FOREIGN KEY ("fk_Veranstaltung") REFERENCES "tbl_Veranstaltung"("pk_Veranstaltung");

UPDATE "tbl_VerfahrensHistory" SET "fk_FamilienRolle" = NULL WHERE "fk_FamilienRolle" IN (
  SELECT "tbl_VerfahrensHistory"."fk_FamilienRolle" FROM "tbl_VerfahrensHistory" LEFT OUTER JOIN "tbl_FamilienRollen" ON "tbl_FamilienRollen"."pk_FamilienRolle" = "tbl_VerfahrensHistory"."fk_FamilienRolle"
WHERE "tbl_FamilienRollen"."pk_FamilienRolle" IS NULL AND "tbl_VerfahrensHistory"."fk_FamilienRolle" IS NOT NULL);

ALTER TABLE ONLY "tbl_VerfahrensHistory" ADD CONSTRAINT "tbl_VerfahrensHistory_fk_FamilienRolle_fkey" FOREIGN KEY ("fk_FamilienRolle") REFERENCES "tbl_FamilienRollen"("pk_FamilienRolle");

ALTER TABLE ONLY "tbl_VerfahrensHistory" ADD CONSTRAINT "tbl_VerfahrensHistory_fk_Hauptperson_fkey" FOREIGN KEY ("fk_Hauptperson") REFERENCES "tbl_Hauptpersonen"("pk_Hauptperson");

ALTER TABLE ONLY "tbl_VerfahrensHistory" ADD CONSTRAINT "tbl_VerfahrensHistory_fk_VerfahrensStatus_fkey" FOREIGN KEY ("fk_VerfahrensStatus") REFERENCES "tbl_Verfahrensstati"("pk_Verfahrensstatus");
