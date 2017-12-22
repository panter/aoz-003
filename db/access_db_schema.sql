--
-- PostgreSQL database dump
--

-- Dumped from database version 10.1
-- Dumped by pg_dump version 10.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: tbl_Ausbildungen; Type: TABLE; Schema: public; Owner: kaspi
--

CREATE TABLE "tbl_Ausbildungen" (
    "pk_Ausbildung" integer NOT NULL,
    "fk_Hauptperson" integer DEFAULT 0,
    "fk_AusbildungsTyp" integer DEFAULT 0,
    "t_Bezeichnung" character varying(255),
    "m_Bemerkungen" text,
    "t_Mutation" character varying(30),
    "d_MutDatum" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE "tbl_Ausbildungen" OWNER TO kaspi;

--
-- Name: tbl_Ausbildungen_pk_Ausbildung_seq; Type: SEQUENCE; Schema: public; Owner: kaspi
--

CREATE SEQUENCE "tbl_Ausbildungen_pk_Ausbildung_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "tbl_Ausbildungen_pk_Ausbildung_seq" OWNER TO kaspi;

--
-- Name: tbl_Ausbildungen_pk_Ausbildung_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kaspi
--

ALTER SEQUENCE "tbl_Ausbildungen_pk_Ausbildung_seq" OWNED BY "tbl_Ausbildungen"."pk_Ausbildung";


--
-- Name: tbl_AusbildungsTypen; Type: TABLE; Schema: public; Owner: kaspi
--

CREATE TABLE "tbl_AusbildungsTypen" (
    "pk_AusbildungsTyp" integer NOT NULL,
    "t_AusbildungsTyp" character varying(50),
    "t_Mutation" character varying(30),
    "d_MutDatum" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE "tbl_AusbildungsTypen" OWNER TO kaspi;

--
-- Name: tbl_AusbildungsTypen_pk_AusbildungsTyp_seq; Type: SEQUENCE; Schema: public; Owner: kaspi
--

CREATE SEQUENCE "tbl_AusbildungsTypen_pk_AusbildungsTyp_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "tbl_AusbildungsTypen_pk_AusbildungsTyp_seq" OWNER TO kaspi;

--
-- Name: tbl_AusbildungsTypen_pk_AusbildungsTyp_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kaspi
--

ALTER SEQUENCE "tbl_AusbildungsTypen_pk_AusbildungsTyp_seq" OWNED BY "tbl_AusbildungsTypen"."pk_AusbildungsTyp";


--
-- Name: tbl_AuswVorlagen; Type: TABLE; Schema: public; Owner: kaspi
--

CREATE TABLE "tbl_AuswVorlagen" (
    "pk_Vorlage" integer NOT NULL,
    "t_VorlagenName" character varying(50),
    "t_Vorlage" character varying(5),
    "t_Mutation" character varying(30),
    "d_MutDatum" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE "tbl_AuswVorlagen" OWNER TO kaspi;

--
-- Name: tbl_AuswVorlagen_pk_Vorlage_seq; Type: SEQUENCE; Schema: public; Owner: kaspi
--

CREATE SEQUENCE "tbl_AuswVorlagen_pk_Vorlage_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "tbl_AuswVorlagen_pk_Vorlage_seq" OWNER TO kaspi;

--
-- Name: tbl_AuswVorlagen_pk_Vorlage_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kaspi
--

ALTER SEQUENCE "tbl_AuswVorlagen_pk_Vorlage_seq" OWNED BY "tbl_AuswVorlagen"."pk_Vorlage";


--
-- Name: tbl_Begleitete; Type: TABLE; Schema: public; Owner: kaspi
--

CREATE TABLE "tbl_Begleitete" (
    "pk_Begleitete" integer NOT NULL,
    "fk_PersonenRolle" integer DEFAULT 0,
    "fk_FamilienRolle" integer DEFAULT 0,
    "t_Name" character varying(50),
    "t_Vorname" character varying(50),
    "t_Geschlecht" character varying(12),
    "z_Jahrgang" integer DEFAULT 0,
    "m_Bemerkung" text,
    "t_Mutation" character varying(30),
    "d_MutDatum" timestamp without time zone
);


ALTER TABLE "tbl_Begleitete" OWNER TO kaspi;

--
-- Name: tbl_Begleitete_pk_Begleitete_seq; Type: SEQUENCE; Schema: public; Owner: kaspi
--

CREATE SEQUENCE "tbl_Begleitete_pk_Begleitete_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "tbl_Begleitete_pk_Begleitete_seq" OWNER TO kaspi;

--
-- Name: tbl_Begleitete_pk_Begleitete_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kaspi
--

ALTER SEQUENCE "tbl_Begleitete_pk_Begleitete_seq" OWNED BY "tbl_Begleitete"."pk_Begleitete";


--
-- Name: tbl_EinsatzOrte; Type: TABLE; Schema: public; Owner: kaspi
--

CREATE TABLE "tbl_EinsatzOrte" (
    "pk_EinsatzOrt" integer NOT NULL,
    "fk_PlzOrt" integer DEFAULT 0,
    "t_EinsatzOrt" character varying(50),
    "t_Adresse1" character varying(255),
    "t_Adresse2" character varying(255),
    "t_Mutation" character varying(30),
    "d_MutDatum" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE "tbl_EinsatzOrte" OWNER TO kaspi;

--
-- Name: tbl_EinsatzOrteProEinsatzFunktion; Type: TABLE; Schema: public; Owner: kaspi
--

CREATE TABLE "tbl_EinsatzOrteProEinsatzFunktion" (
    "pk_EinsatzOrtProEinsatzFunktion" integer NOT NULL,
    "fk_EinsatzOrt" integer DEFAULT 0,
    "fk_EinsatzFunktion" integer DEFAULT 0,
    "t_Mutation" character varying(30),
    "d_MutDatum" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE "tbl_EinsatzOrteProEinsatzFunktion" OWNER TO kaspi;

--
-- Name: tbl_EinsatzOrteProEinsatzFunk_pk_EinsatzOrtProEinsatzFunkti_seq; Type: SEQUENCE; Schema: public; Owner: kaspi
--

CREATE SEQUENCE "tbl_EinsatzOrteProEinsatzFunk_pk_EinsatzOrtProEinsatzFunkti_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "tbl_EinsatzOrteProEinsatzFunk_pk_EinsatzOrtProEinsatzFunkti_seq" OWNER TO kaspi;

--
-- Name: tbl_EinsatzOrteProEinsatzFunk_pk_EinsatzOrtProEinsatzFunkti_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kaspi
--

ALTER SEQUENCE "tbl_EinsatzOrteProEinsatzFunk_pk_EinsatzOrtProEinsatzFunkti_seq" OWNED BY "tbl_EinsatzOrteProEinsatzFunktion"."pk_EinsatzOrtProEinsatzFunktion";


--
-- Name: tbl_EinsatzOrte_pk_EinsatzOrt_seq; Type: SEQUENCE; Schema: public; Owner: kaspi
--

CREATE SEQUENCE "tbl_EinsatzOrte_pk_EinsatzOrt_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "tbl_EinsatzOrte_pk_EinsatzOrt_seq" OWNER TO kaspi;

--
-- Name: tbl_EinsatzOrte_pk_EinsatzOrt_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kaspi
--

ALTER SEQUENCE "tbl_EinsatzOrte_pk_EinsatzOrt_seq" OWNED BY "tbl_EinsatzOrte"."pk_EinsatzOrt";


--
-- Name: tbl_FallStelleProTeilnehmer; Type: TABLE; Schema: public; Owner: kaspi
--

CREATE TABLE "tbl_FallStelleProTeilnehmer" (
    "pk_FallStelleProTeilnehmer" integer NOT NULL,
    "fk_PersonenRolle" integer DEFAULT 0,
    "fk_Fallstelle" integer DEFAULT 0,
    "fk_Kontaktperson" integer DEFAULT 0,
    "m_Zusatzinfos" text,
    "t_Mutation" character varying(30),
    "d_MutDatum" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE "tbl_FallStelleProTeilnehmer" OWNER TO kaspi;

--
-- Name: tbl_FallStelleProTeilnehmer_pk_FallStelleProTeilnehmer_seq; Type: SEQUENCE; Schema: public; Owner: kaspi
--

CREATE SEQUENCE "tbl_FallStelleProTeilnehmer_pk_FallStelleProTeilnehmer_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "tbl_FallStelleProTeilnehmer_pk_FallStelleProTeilnehmer_seq" OWNER TO kaspi;

--
-- Name: tbl_FallStelleProTeilnehmer_pk_FallStelleProTeilnehmer_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kaspi
--

ALTER SEQUENCE "tbl_FallStelleProTeilnehmer_pk_FallStelleProTeilnehmer_seq" OWNED BY "tbl_FallStelleProTeilnehmer"."pk_FallStelleProTeilnehmer";


--
-- Name: tbl_FallStellen; Type: TABLE; Schema: public; Owner: kaspi
--

CREATE TABLE "tbl_FallStellen" (
    "pk_FallStelle" integer NOT NULL,
    "t_Organisation" character varying(255),
    "t_Organisation2" character varying(255),
    "t_Adresszeile1" character varying(255),
    "t_Adresszeile2" character varying(255),
    "fk_PLZ" integer,
    "t_Land" character varying(50) DEFAULT 'Schweiz'::character varying,
    "t_Telefon" character varying(20),
    "h_Email" text,
    "m_Bemerkungen" text,
    "b_Status" boolean,
    "t_Mutation" character varying(30),
    "d_MutDatum" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE "tbl_FallStellen" OWNER TO kaspi;

--
-- Name: tbl_FallStellen_pk_FallStelle_seq; Type: SEQUENCE; Schema: public; Owner: kaspi
--

CREATE SEQUENCE "tbl_FallStellen_pk_FallStelle_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "tbl_FallStellen_pk_FallStelle_seq" OWNER TO kaspi;

--
-- Name: tbl_FallStellen_pk_FallStelle_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kaspi
--

ALTER SEQUENCE "tbl_FallStellen_pk_FallStelle_seq" OWNED BY "tbl_FallStellen"."pk_FallStelle";


--
-- Name: tbl_FamilienRollen; Type: TABLE; Schema: public; Owner: kaspi
--

CREATE TABLE "tbl_FamilienRollen" (
    "pk_FamilienRolle" integer NOT NULL,
    "t_RollenBezeichnung" character varying(50),
    "t_Mutation" character varying(30),
    "d_MutDatum" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE "tbl_FamilienRollen" OWNER TO kaspi;

--
-- Name: tbl_FamilienRollen_pk_FamilienRolle_seq; Type: SEQUENCE; Schema: public; Owner: kaspi
--

CREATE SEQUENCE "tbl_FamilienRollen_pk_FamilienRolle_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "tbl_FamilienRollen_pk_FamilienRolle_seq" OWNER TO kaspi;

--
-- Name: tbl_FamilienRollen_pk_FamilienRolle_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kaspi
--

ALTER SEQUENCE "tbl_FamilienRollen_pk_FamilienRolle_seq" OWNED BY "tbl_FamilienRollen"."pk_FamilienRolle";


--
-- Name: tbl_FreiwilligenEinsätze; Type: TABLE; Schema: public; Owner: kaspi
--

CREATE TABLE "tbl_FreiwilligenEinsätze" (
    "pk_FreiwilligenEinsatz" integer NOT NULL,
    "fk_PersonenRolle" integer DEFAULT 0,
    "fk_FreiwilligenFunktion" integer DEFAULT 0,
    "fk_Kostenträger" integer DEFAULT 0,
    "fk_EinsatzOrt" integer DEFAULT 0,
    "fk_Begleitete" integer DEFAULT 0,
    "fk_Kurs" integer DEFAULT 0,
    "fk_Semester" integer DEFAULT 0,
    "fk_Lehrmittel" integer DEFAULT 0,
    "d_EinsatzVon" timestamp without time zone,
    "d_EinsatzBis" timestamp without time zone,
    "t_Kurzbezeichnung" character varying(100),
    "t_EinsatzOrt" character varying(100),
    "t_EinsatzAdresse" character varying(255),
    "z_FamilienBegleitung" integer DEFAULT 0,
    "m_Einstiegsthematik" text,
    "m_Zielsetzung" text,
    "m_ErreichteZiele" text,
    "m_Beschreibung" text,
    "b_Probezeitbericht" boolean DEFAULT false,
    "z_Spesen" double precision DEFAULT 0,
    "b_LP1" boolean DEFAULT false,
    "b_LP2" boolean DEFAULT false,
    "b_Bücher" boolean DEFAULT false,
    "d_Probezeit" timestamp without time zone,
    "d_Hausbesuch" timestamp without time zone,
    "d_ErstUnterricht" timestamp without time zone,
    "d_Standortgespräch" timestamp without time zone,
    "t_Mutation" character varying(30),
    "d_MutDatum" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE "tbl_FreiwilligenEinsätze" OWNER TO kaspi;

--
-- Name: tbl_FreiwilligenEinsätze_pk_FreiwilligenEinsatz_seq; Type: SEQUENCE; Schema: public; Owner: kaspi
--

CREATE SEQUENCE "tbl_FreiwilligenEinsätze_pk_FreiwilligenEinsatz_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "tbl_FreiwilligenEinsätze_pk_FreiwilligenEinsatz_seq" OWNER TO kaspi;

--
-- Name: tbl_FreiwilligenEinsätze_pk_FreiwilligenEinsatz_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kaspi
--

ALTER SEQUENCE "tbl_FreiwilligenEinsätze_pk_FreiwilligenEinsatz_seq" OWNED BY "tbl_FreiwilligenEinsätze"."pk_FreiwilligenEinsatz";


--
-- Name: tbl_FreiwilligenEntschädigung; Type: TABLE; Schema: public; Owner: kaspi
--

CREATE TABLE "tbl_FreiwilligenEntschädigung" (
    "pk_FreiwilligenEntschädigung" integer NOT NULL,
    "fk_PersonenRolle" integer DEFAULT 0,
    "fk_Semester" integer DEFAULT 0,
    "z_Semesterjahr" integer DEFAULT 0,
    "t_Monat" character varying(50),
    "z_Jahr" integer,
    "d_Datum" timestamp without time zone,
    "z_Einsätze" integer DEFAULT 0,
    "z_Stunden" integer DEFAULT 0,
    "z_Betrag" integer DEFAULT 0,
    "z_Spesen" integer DEFAULT 0,
    "z_Total" numeric(19,4) DEFAULT 0,
    "t_Empfängerkonto" character varying(250),
    "z_KST" integer DEFAULT 0,
    "z_AOZKonto" integer DEFAULT 0,
    "t_Bemerkung" character varying(200),
    "t_Mutation" character varying(30),
    "d_MutDatum" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE "tbl_FreiwilligenEntschädigung" OWNER TO kaspi;

--
-- Name: tbl_FreiwilligenEntschädigun_pk_FreiwilligenEntschädigung_seq; Type: SEQUENCE; Schema: public; Owner: kaspi
--

CREATE SEQUENCE "tbl_FreiwilligenEntschädigun_pk_FreiwilligenEntschädigung_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "tbl_FreiwilligenEntschädigun_pk_FreiwilligenEntschädigung_seq" OWNER TO kaspi;

--
-- Name: tbl_FreiwilligenEntschädigun_pk_FreiwilligenEntschädigung_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kaspi
--

ALTER SEQUENCE "tbl_FreiwilligenEntschädigun_pk_FreiwilligenEntschädigung_seq" OWNED BY "tbl_FreiwilligenEntschädigung"."pk_FreiwilligenEntschädigung";


--
-- Name: tbl_FreiwilligenFunktionen; Type: TABLE; Schema: public; Owner: kaspi
--

CREATE TABLE "tbl_FreiwilligenFunktionen" (
    "pk_FreiwilligenFunktion" integer NOT NULL,
    "fk_Rolle" integer DEFAULT 0,
    "t_Bezeichnung" character varying(50),
    "m_Beschreibung" text,
    "b_Status" boolean,
    "t_Mutation" character varying(30),
    "d_MutDatum" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE "tbl_FreiwilligenFunktionen" OWNER TO kaspi;

--
-- Name: tbl_FreiwilligenFunktionen_pk_FreiwilligenFunktion_seq; Type: SEQUENCE; Schema: public; Owner: kaspi
--

CREATE SEQUENCE "tbl_FreiwilligenFunktionen_pk_FreiwilligenFunktion_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "tbl_FreiwilligenFunktionen_pk_FreiwilligenFunktion_seq" OWNER TO kaspi;

--
-- Name: tbl_FreiwilligenFunktionen_pk_FreiwilligenFunktion_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kaspi
--

ALTER SEQUENCE "tbl_FreiwilligenFunktionen_pk_FreiwilligenFunktion_seq" OWNED BY "tbl_FreiwilligenFunktionen"."pk_FreiwilligenFunktion";


--
-- Name: tbl_FreiwilligenVeranstaltungen; Type: TABLE; Schema: public; Owner: kaspi
--

CREATE TABLE "tbl_FreiwilligenVeranstaltungen" (
    "pk_FreiwilligenVeranstaltung" integer NOT NULL,
    "t_Bezeichnung" character varying(50),
    "m_Beschreibung" text,
    "b_Status" boolean,
    "t_Mutation" character varying(30),
    "d_MutDatum" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE "tbl_FreiwilligenVeranstaltungen" OWNER TO kaspi;

--
-- Name: tbl_FreiwilligenVeranstaltunge_pk_FreiwilligenVeranstaltung_seq; Type: SEQUENCE; Schema: public; Owner: kaspi
--

CREATE SEQUENCE "tbl_FreiwilligenVeranstaltunge_pk_FreiwilligenVeranstaltung_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "tbl_FreiwilligenVeranstaltunge_pk_FreiwilligenVeranstaltung_seq" OWNER TO kaspi;

--
-- Name: tbl_FreiwilligenVeranstaltunge_pk_FreiwilligenVeranstaltung_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kaspi
--

ALTER SEQUENCE "tbl_FreiwilligenVeranstaltunge_pk_FreiwilligenVeranstaltung_seq" OWNED BY "tbl_FreiwilligenVeranstaltungen"."pk_FreiwilligenVeranstaltung";


--
-- Name: tbl_Hauptpersonen; Type: TABLE; Schema: public; Owner: kaspi
--

CREATE TABLE "tbl_Hauptpersonen" (
    "pk_Hauptperson" integer NOT NULL,
    "t_Anrede" character varying(10),
    "t_Nachname" character varying(50),
    "t_Vorname" character varying(50),
    "t_Adresszeile1" character varying(255),
    "t_Adresszeile2" character varying(255),
    "fk_PLZ" integer,
    "t_Land" character varying(50) DEFAULT '0'::character varying,
    "t_Telefon1" character varying(20),
    "t_Telefon2" character varying(20),
    "t_BemTel1" character varying(255),
    "t_BemTel2" character varying(255),
    "h_Email" text,
    "d_Geburtsdatum" timestamp without time zone,
    "t_Geschlecht" character varying(12),
    "fk_Land" integer DEFAULT 0,
    "t_NNummer" character varying(50),
    "d_EintrittCH" timestamp without time zone,
    "t_Beruf" character varying(50),
    "m_Bemerkungen" text,
    "b_KlientAOZ" boolean,
    "t_Mutation" character varying(30),
    "d_MutDatum" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE "tbl_Hauptpersonen" OWNER TO kaspi;

--
-- Name: tbl_Hauptpersonen_pk_Hauptperson_seq; Type: SEQUENCE; Schema: public; Owner: kaspi
--

CREATE SEQUENCE "tbl_Hauptpersonen_pk_Hauptperson_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "tbl_Hauptpersonen_pk_Hauptperson_seq" OWNER TO kaspi;

--
-- Name: tbl_Hauptpersonen_pk_Hauptperson_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kaspi
--

ALTER SEQUENCE "tbl_Hauptpersonen_pk_Hauptperson_seq" OWNED BY "tbl_Hauptpersonen"."pk_Hauptperson";


--
-- Name: tbl_Journal; Type: TABLE; Schema: public; Owner: kaspi
--

CREATE TABLE "tbl_Journal" (
    "pk_Journal" integer NOT NULL,
    "fk_Hauptperson" integer DEFAULT 0,
    "fk_JournalKategorie" integer DEFAULT 0,
    "fk_FreiwilligenEinsatz" integer DEFAULT 0,
    "t_Dateiname" character varying(255),
    "t_Pfad" character varying(255),
    "m_Text" text,
    "t_Erfasst" character varying(50),
    "d_ErfDatum" timestamp without time zone,
    "t_Mutation" character varying(30),
    "d_MutDatum" timestamp without time zone
);


ALTER TABLE "tbl_Journal" OWNER TO kaspi;

--
-- Name: tbl_JournalKategorien; Type: TABLE; Schema: public; Owner: kaspi
--

CREATE TABLE "tbl_JournalKategorien" (
    "pk_JournalKategorie" integer NOT NULL,
    "t_Kategorie" character varying(50),
    "t_Mutation" character varying(30),
    "d_MutDatum" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE "tbl_JournalKategorien" OWNER TO kaspi;

--
-- Name: tbl_JournalKategorien_pk_JournalKategorie_seq; Type: SEQUENCE; Schema: public; Owner: kaspi
--

CREATE SEQUENCE "tbl_JournalKategorien_pk_JournalKategorie_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "tbl_JournalKategorien_pk_JournalKategorie_seq" OWNER TO kaspi;

--
-- Name: tbl_JournalKategorien_pk_JournalKategorie_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kaspi
--

ALTER SEQUENCE "tbl_JournalKategorien_pk_JournalKategorie_seq" OWNED BY "tbl_JournalKategorien"."pk_JournalKategorie";


--
-- Name: tbl_Journal_pk_Journal_seq; Type: SEQUENCE; Schema: public; Owner: kaspi
--

CREATE SEQUENCE "tbl_Journal_pk_Journal_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "tbl_Journal_pk_Journal_seq" OWNER TO kaspi;

--
-- Name: tbl_Journal_pk_Journal_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kaspi
--

ALTER SEQUENCE "tbl_Journal_pk_Journal_seq" OWNED BY "tbl_Journal"."pk_Journal";


--
-- Name: tbl_Kantone; Type: TABLE; Schema: public; Owner: kaspi
--

CREATE TABLE "tbl_Kantone" (
    "pk_Kanton" integer NOT NULL,
    "t_Kanton" character varying(30),
    "t_KantonsKürzel" character varying(11),
    "t_Mutation" character varying(30),
    "d_MutDatum" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE "tbl_Kantone" OWNER TO kaspi;

--
-- Name: tbl_Kantone_pk_Kanton_seq; Type: SEQUENCE; Schema: public; Owner: kaspi
--

CREATE SEQUENCE "tbl_Kantone_pk_Kanton_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "tbl_Kantone_pk_Kanton_seq" OWNER TO kaspi;

--
-- Name: tbl_Kantone_pk_Kanton_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kaspi
--

ALTER SEQUENCE "tbl_Kantone_pk_Kanton_seq" OWNED BY "tbl_Kantone"."pk_Kanton";


--
-- Name: tbl_KontaktPersonen; Type: TABLE; Schema: public; Owner: kaspi
--

CREATE TABLE "tbl_KontaktPersonen" (
    "pk_Kontaktperson" integer NOT NULL,
    "fk_FallStelle" integer DEFAULT 0,
    "t_Anrede" character varying(10),
    "t_Nachname" character varying(255),
    "t_Vorname" character varying(255),
    "t_Funktion" character varying(50),
    "t_Telefon" character varying(20),
    "h_Email" text,
    "m_Bemerkungen" text,
    "b_Status" boolean,
    "t_Mutation" character varying(30),
    "d_MutDatum" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE "tbl_KontaktPersonen" OWNER TO kaspi;

--
-- Name: tbl_KontaktPersonen_pk_Kontaktperson_seq; Type: SEQUENCE; Schema: public; Owner: kaspi
--

CREATE SEQUENCE "tbl_KontaktPersonen_pk_Kontaktperson_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "tbl_KontaktPersonen_pk_Kontaktperson_seq" OWNER TO kaspi;

--
-- Name: tbl_KontaktPersonen_pk_Kontaktperson_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kaspi
--

ALTER SEQUENCE "tbl_KontaktPersonen_pk_Kontaktperson_seq" OWNED BY "tbl_KontaktPersonen"."pk_Kontaktperson";


--
-- Name: tbl_Kontoangaben; Type: TABLE; Schema: public; Owner: kaspi
--

CREATE TABLE "tbl_Kontoangaben" (
    "pk_Kontoangabe" integer NOT NULL,
    "fk_Hauptperson" integer DEFAULT 0,
    "z_KontoArt" integer,
    "t_PCKonto" character varying(20),
    "t_Bankkonto" character varying(50),
    "t_BankenName" character varying(50),
    "fk_PlzOrt" integer DEFAULT 0,
    "z_ClearingNummer" integer,
    "t_IBAN" character varying(50),
    "m_Bemerkung" text,
    "t_Mutation" character varying(30),
    "d_MutDatum" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE "tbl_Kontoangaben" OWNER TO kaspi;

--
-- Name: tbl_Kontoangaben_pk_Kontoangabe_seq; Type: SEQUENCE; Schema: public; Owner: kaspi
--

CREATE SEQUENCE "tbl_Kontoangaben_pk_Kontoangabe_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "tbl_Kontoangaben_pk_Kontoangabe_seq" OWNER TO kaspi;

--
-- Name: tbl_Kontoangaben_pk_Kontoangabe_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kaspi
--

ALTER SEQUENCE "tbl_Kontoangaben_pk_Kontoangabe_seq" OWNED BY "tbl_Kontoangaben"."pk_Kontoangabe";


--
-- Name: tbl_Kostenträger; Type: TABLE; Schema: public; Owner: kaspi
--

CREATE TABLE "tbl_Kostenträger" (
    "pk_Kostenträger" integer NOT NULL,
    "t_Kostenträger" character varying(50),
    "m_Bemerkung" text,
    "b_Status" boolean DEFAULT false,
    "t_Mutation" character varying(30),
    "d_MutDatum" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE "tbl_Kostenträger" OWNER TO kaspi;

--
-- Name: tbl_Kostenträger_pk_Kostenträger_seq; Type: SEQUENCE; Schema: public; Owner: kaspi
--

CREATE SEQUENCE "tbl_Kostenträger_pk_Kostenträger_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "tbl_Kostenträger_pk_Kostenträger_seq" OWNER TO kaspi;

--
-- Name: tbl_Kostenträger_pk_Kostenträger_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kaspi
--

ALTER SEQUENCE "tbl_Kostenträger_pk_Kostenträger_seq" OWNED BY "tbl_Kostenträger"."pk_Kostenträger";


--
-- Name: tbl_Kursarten; Type: TABLE; Schema: public; Owner: kaspi
--

CREATE TABLE "tbl_Kursarten" (
    "pk_Kursart" integer NOT NULL,
    "t_Bezeichnung" character varying(50),
    "m_Beschreibung" text,
    "b_Status" boolean,
    "t_Mutation" character varying(30),
    "d_MutDatum" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE "tbl_Kursarten" OWNER TO kaspi;

--
-- Name: tbl_Kursarten_pk_Kursart_seq; Type: SEQUENCE; Schema: public; Owner: kaspi
--

CREATE SEQUENCE "tbl_Kursarten_pk_Kursart_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "tbl_Kursarten_pk_Kursart_seq" OWNER TO kaspi;

--
-- Name: tbl_Kursarten_pk_Kursart_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kaspi
--

ALTER SEQUENCE "tbl_Kursarten_pk_Kursart_seq" OWNED BY "tbl_Kursarten"."pk_Kursart";


--
-- Name: tbl_Kurse; Type: TABLE; Schema: public; Owner: kaspi
--

CREATE TABLE "tbl_Kurse" (
    "pk_Kurs" integer NOT NULL,
    "fk_Kursart" integer DEFAULT 0,
    "t_KursBezeichnung" character varying(50),
    "t_Ort" character varying(50),
    "t_KursAdresse" character varying(255),
    "t_Zeitraum" character varying(50),
    "m_Beschreibung" text,
    "b_Status" boolean,
    "t_Mutation" character varying(30),
    "d_MutDatum" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE "tbl_Kurse" OWNER TO kaspi;

--
-- Name: tbl_Kurse_pk_Kurs_seq; Type: SEQUENCE; Schema: public; Owner: kaspi
--

CREATE SEQUENCE "tbl_Kurse_pk_Kurs_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "tbl_Kurse_pk_Kurs_seq" OWNER TO kaspi;

--
-- Name: tbl_Kurse_pk_Kurs_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kaspi
--

ALTER SEQUENCE "tbl_Kurse_pk_Kurs_seq" OWNED BY "tbl_Kurse"."pk_Kurs";


--
-- Name: tbl_Kurspräsenzen; Type: TABLE; Schema: public; Owner: kaspi
--

CREATE TABLE "tbl_Kurspräsenzen" (
    "pk_Kurspräsenz" integer NOT NULL,
    "fk_Kurs" integer DEFAULT 0,
    "d_Datum" timestamp without time zone,
    "fk_Kursteilnehmer" integer DEFAULT 0,
    "fk_Begleitete" integer DEFAULT 0,
    "b_Präsenz" boolean,
    "t_Mutation" character varying(30),
    "d_MutDatum" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE "tbl_Kurspräsenzen" OWNER TO kaspi;

--
-- Name: tbl_Kurspräsenzen_pk_Kurspräsenz_seq; Type: SEQUENCE; Schema: public; Owner: kaspi
--

CREATE SEQUENCE "tbl_Kurspräsenzen_pk_Kurspräsenz_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "tbl_Kurspräsenzen_pk_Kurspräsenz_seq" OWNER TO kaspi;

--
-- Name: tbl_Kurspräsenzen_pk_Kurspräsenz_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kaspi
--

ALTER SEQUENCE "tbl_Kurspräsenzen_pk_Kurspräsenz_seq" OWNED BY "tbl_Kurspräsenzen"."pk_Kurspräsenz";


--
-- Name: tbl_Kursteilnehmer; Type: TABLE; Schema: public; Owner: kaspi
--

CREATE TABLE "tbl_Kursteilnehmer" (
    "pk_Kursteilnehmer" integer NOT NULL,
    "fk_Kurs" integer DEFAULT 0,
    "fk_Begleitete" integer DEFAULT 0,
    "t_Nachname" character varying(50),
    "t_Vorname" character varying(50),
    "z_Jahrgang" integer
);


ALTER TABLE "tbl_Kursteilnehmer" OWNER TO kaspi;

--
-- Name: tbl_Kursteilnehmer_pk_Kursteilnehmer_seq; Type: SEQUENCE; Schema: public; Owner: kaspi
--

CREATE SEQUENCE "tbl_Kursteilnehmer_pk_Kursteilnehmer_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "tbl_Kursteilnehmer_pk_Kursteilnehmer_seq" OWNER TO kaspi;

--
-- Name: tbl_Kursteilnehmer_pk_Kursteilnehmer_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kaspi
--

ALTER SEQUENCE "tbl_Kursteilnehmer_pk_Kursteilnehmer_seq" OWNED BY "tbl_Kursteilnehmer"."pk_Kursteilnehmer";


--
-- Name: tbl_Lehrmittel; Type: TABLE; Schema: public; Owner: kaspi
--

CREATE TABLE "tbl_Lehrmittel" (
    "pk_Lehrmittel" integer NOT NULL,
    "t_Lehrmittel" character varying(50),
    "t_Verlag" character varying(50),
    "b_Status" boolean,
    "t_Mutation" character varying(30),
    "d_MutDatum" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE "tbl_Lehrmittel" OWNER TO kaspi;

--
-- Name: tbl_Lehrmittel_pk_Lehrmittel_seq; Type: SEQUENCE; Schema: public; Owner: kaspi
--

CREATE SEQUENCE "tbl_Lehrmittel_pk_Lehrmittel_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "tbl_Lehrmittel_pk_Lehrmittel_seq" OWNER TO kaspi;

--
-- Name: tbl_Lehrmittel_pk_Lehrmittel_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kaspi
--

ALTER SEQUENCE "tbl_Lehrmittel_pk_Lehrmittel_seq" OWNED BY "tbl_Lehrmittel"."pk_Lehrmittel";


--
-- Name: tbl_Länder; Type: TABLE; Schema: public; Owner: kaspi
--

CREATE TABLE "tbl_Länder" (
    "pk_Land" integer NOT NULL,
    "t_Land" character varying(50),
    "t_LandKurzform" character varying(5),
    "t_Mutation" character varying(30),
    "d_MutDatum" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE "tbl_Länder" OWNER TO kaspi;

--
-- Name: tbl_Länder_pk_Land_seq; Type: SEQUENCE; Schema: public; Owner: kaspi
--

CREATE SEQUENCE "tbl_Länder_pk_Land_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "tbl_Länder_pk_Land_seq" OWNER TO kaspi;

--
-- Name: tbl_Länder_pk_Land_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kaspi
--

ALTER SEQUENCE "tbl_Länder_pk_Land_seq" OWNED BY "tbl_Länder"."pk_Land";


--
-- Name: tbl_ParameterT; Type: TABLE; Schema: public; Owner: kaspi
--

CREATE TABLE "tbl_ParameterT" (
    "pk_Parameter" integer NOT NULL,
    "t_ParamBez" character varying(50),
    "t_ParamWert" character varying(200),
    "t_ParamBeschreibung" character varying(200),
    "t_Mutation" character varying(30),
    "d_MutDatum" timestamp without time zone
);


ALTER TABLE "tbl_ParameterT" OWNER TO kaspi;

--
-- Name: tbl_ParameterT_pk_Parameter_seq; Type: SEQUENCE; Schema: public; Owner: kaspi
--

CREATE SEQUENCE "tbl_ParameterT_pk_Parameter_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "tbl_ParameterT_pk_Parameter_seq" OWNER TO kaspi;

--
-- Name: tbl_ParameterT_pk_Parameter_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kaspi
--

ALTER SEQUENCE "tbl_ParameterT_pk_Parameter_seq" OWNED BY "tbl_ParameterT"."pk_Parameter";


--
-- Name: tbl_ParameterZ; Type: TABLE; Schema: public; Owner: kaspi
--

CREATE TABLE "tbl_ParameterZ" (
    "pk_Parameter" integer NOT NULL,
    "t_ParamBez" character varying(50),
    "t_ParamWert" double precision DEFAULT 0,
    "t_ParamBeschreibung" character varying(200),
    "t_Mutation" character varying(30),
    "d_MutDatum" timestamp without time zone
);


ALTER TABLE "tbl_ParameterZ" OWNER TO kaspi;

--
-- Name: tbl_ParameterZ_pk_Parameter_seq; Type: SEQUENCE; Schema: public; Owner: kaspi
--

CREATE SEQUENCE "tbl_ParameterZ_pk_Parameter_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "tbl_ParameterZ_pk_Parameter_seq" OWNER TO kaspi;

--
-- Name: tbl_ParameterZ_pk_Parameter_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kaspi
--

ALTER SEQUENCE "tbl_ParameterZ_pk_Parameter_seq" OWNED BY "tbl_ParameterZ"."pk_Parameter";


--
-- Name: tbl_Personenrollen; Type: TABLE; Schema: public; Owner: kaspi
--

CREATE TABLE "tbl_Personenrollen" (
    "pk_PersonenRolle" integer NOT NULL,
    "fk_Hauptperson" integer DEFAULT 0,
    "fk_Kostenträger" integer DEFAULT 0,
    "z_Rolle" integer DEFAULT 0,
    "d_Rollenbeginn" timestamp without time zone,
    "d_Rollenende" timestamp without time zone,
    "z_Familienverband" integer DEFAULT 0,
    "z_AnzErw" integer,
    "z_AnzKind" integer,
    "m_Bemerkungen" text,
    "b_Interesse" boolean DEFAULT false,
    "b_EinführungsKurs" boolean DEFAULT false,
    "b_SpesenVerzicht" boolean DEFAULT false,
    "t_Mutation" character varying(30),
    "d_MutDatum" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE "tbl_Personenrollen" OWNER TO kaspi;

--
-- Name: tbl_Personenrollen_pk_PersonenRolle_seq; Type: SEQUENCE; Schema: public; Owner: kaspi
--

CREATE SEQUENCE "tbl_Personenrollen_pk_PersonenRolle_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "tbl_Personenrollen_pk_PersonenRolle_seq" OWNER TO kaspi;

--
-- Name: tbl_Personenrollen_pk_PersonenRolle_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kaspi
--

ALTER SEQUENCE "tbl_Personenrollen_pk_PersonenRolle_seq" OWNED BY "tbl_Personenrollen"."pk_PersonenRolle";


--
-- Name: tbl_PlzOrt; Type: TABLE; Schema: public; Owner: kaspi
--

CREATE TABLE "tbl_PlzOrt" (
    "pk_PlzOrt" integer NOT NULL,
    "fk_Kanton Bundesland" integer DEFAULT 0,
    "fk_Land" integer DEFAULT 0,
    "z_PLZ" integer DEFAULT 0,
    "t_PLZ" character varying(10),
    "t_Ort" character varying(255),
    "t_Mutation" character varying(30),
    "d_MutDatum" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE "tbl_PlzOrt" OWNER TO kaspi;

--
-- Name: tbl_PlzOrt_pk_PlzOrt_seq; Type: SEQUENCE; Schema: public; Owner: kaspi
--

CREATE SEQUENCE "tbl_PlzOrt_pk_PlzOrt_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "tbl_PlzOrt_pk_PlzOrt_seq" OWNER TO kaspi;

--
-- Name: tbl_PlzOrt_pk_PlzOrt_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kaspi
--

ALTER SEQUENCE "tbl_PlzOrt_pk_PlzOrt_seq" OWNED BY "tbl_PlzOrt"."pk_PlzOrt";


--
-- Name: tbl_Rollen; Type: TABLE; Schema: public; Owner: kaspi
--

CREATE TABLE "tbl_Rollen" (
    "pk_Rolle" integer NOT NULL,
    "t_RollenBezeichnung" character varying(50),
    "t_Kürzel" character varying(50),
    "t_Mutation" character varying(30),
    "d_MutDatum" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE "tbl_Rollen" OWNER TO kaspi;

--
-- Name: tbl_Rollen_pk_Rolle_seq; Type: SEQUENCE; Schema: public; Owner: kaspi
--

CREATE SEQUENCE "tbl_Rollen_pk_Rolle_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "tbl_Rollen_pk_Rolle_seq" OWNER TO kaspi;

--
-- Name: tbl_Rollen_pk_Rolle_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kaspi
--

ALTER SEQUENCE "tbl_Rollen_pk_Rolle_seq" OWNED BY "tbl_Rollen"."pk_Rolle";


--
-- Name: tbl_Semester; Type: TABLE; Schema: public; Owner: kaspi
--

CREATE TABLE "tbl_Semester" (
    "pk_Semester" integer NOT NULL,
    "fk_Rolle" integer DEFAULT 0,
    "t_Semster" character varying(50)
);


ALTER TABLE "tbl_Semester" OWNER TO kaspi;

--
-- Name: tbl_Semester_pk_Semester_seq; Type: SEQUENCE; Schema: public; Owner: kaspi
--

CREATE SEQUENCE "tbl_Semester_pk_Semester_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "tbl_Semester_pk_Semester_seq" OWNER TO kaspi;

--
-- Name: tbl_Semester_pk_Semester_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kaspi
--

ALTER SEQUENCE "tbl_Semester_pk_Semester_seq" OWNED BY "tbl_Semester"."pk_Semester";


--
-- Name: tbl_Spesenansätze; Type: TABLE; Schema: public; Owner: kaspi
--

CREATE TABLE "tbl_Spesenansätze" (
    "pk_Spesenansatz" integer NOT NULL,
    "fk_Personenrolle" integer DEFAULT 0,
    "t_Faktor" character varying(50),
    "z_Vergleich" double precision DEFAULT 0,
    "z_Betrag" double precision DEFAULT 0,
    "m_Bemerkung" text,
    "t_Mutation" character varying(30),
    "d_MutDatum" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE "tbl_Spesenansätze" OWNER TO kaspi;

--
-- Name: tbl_Spesenansätze_pk_Spesenansatz_seq; Type: SEQUENCE; Schema: public; Owner: kaspi
--

CREATE SEQUENCE "tbl_Spesenansätze_pk_Spesenansatz_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "tbl_Spesenansätze_pk_Spesenansatz_seq" OWNER TO kaspi;

--
-- Name: tbl_Spesenansätze_pk_Spesenansatz_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kaspi
--

ALTER SEQUENCE "tbl_Spesenansätze_pk_Spesenansatz_seq" OWNED BY "tbl_Spesenansätze"."pk_Spesenansatz";


--
-- Name: tbl_SpracheProHauptperson; Type: TABLE; Schema: public; Owner: kaspi
--

CREATE TABLE "tbl_SpracheProHauptperson" (
    "pk_SpracheProPerson" integer NOT NULL,
    "fk_Hauptperson" integer DEFAULT 0,
    "fk_Sprache" integer DEFAULT 0,
    "fk_KenntnisstufeVe" integer DEFAULT 0,
    "fk_KenntnisstufeLe" integer DEFAULT 0,
    "fk_KenntnisstufeSp" integer DEFAULT 0,
    "fk_KenntnisstufeSc" integer DEFAULT 0,
    "t_Mutation" character varying(30),
    "d_MutDatum" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE "tbl_SpracheProHauptperson" OWNER TO kaspi;

--
-- Name: tbl_SpracheProHauptperson_pk_SpracheProPerson_seq; Type: SEQUENCE; Schema: public; Owner: kaspi
--

CREATE SEQUENCE "tbl_SpracheProHauptperson_pk_SpracheProPerson_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "tbl_SpracheProHauptperson_pk_SpracheProPerson_seq" OWNER TO kaspi;

--
-- Name: tbl_SpracheProHauptperson_pk_SpracheProPerson_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kaspi
--

ALTER SEQUENCE "tbl_SpracheProHauptperson_pk_SpracheProPerson_seq" OWNED BY "tbl_SpracheProHauptperson"."pk_SpracheProPerson";


--
-- Name: tbl_Sprachen; Type: TABLE; Schema: public; Owner: kaspi
--

CREATE TABLE "tbl_Sprachen" (
    "pk_Sprache" integer NOT NULL,
    "t_Sprache" character varying(50),
    "t_Mutation" character varying(30),
    "d_MutDatum" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE "tbl_Sprachen" OWNER TO kaspi;

--
-- Name: tbl_Sprachen_pk_Sprache_seq; Type: SEQUENCE; Schema: public; Owner: kaspi
--

CREATE SEQUENCE "tbl_Sprachen_pk_Sprache_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "tbl_Sprachen_pk_Sprache_seq" OWNER TO kaspi;

--
-- Name: tbl_Sprachen_pk_Sprache_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kaspi
--

ALTER SEQUENCE "tbl_Sprachen_pk_Sprache_seq" OWNED BY "tbl_Sprachen"."pk_Sprache";


--
-- Name: tbl_Sprachkenntnisse; Type: TABLE; Schema: public; Owner: kaspi
--

CREATE TABLE "tbl_Sprachkenntnisse" (
    "pk_Sprachkenntnis" integer NOT NULL,
    "t_SprachAttribut" character varying(50),
    "m_Beschreibung" text,
    "t_Mutation" character varying(30),
    "d_MutDatum" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE "tbl_Sprachkenntnisse" OWNER TO kaspi;

--
-- Name: tbl_Sprachkenntnisse_pk_Sprachkenntnis_seq; Type: SEQUENCE; Schema: public; Owner: kaspi
--

CREATE SEQUENCE "tbl_Sprachkenntnisse_pk_Sprachkenntnis_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "tbl_Sprachkenntnisse_pk_Sprachkenntnis_seq" OWNER TO kaspi;

--
-- Name: tbl_Sprachkenntnisse_pk_Sprachkenntnis_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kaspi
--

ALTER SEQUENCE "tbl_Sprachkenntnisse_pk_Sprachkenntnis_seq" OWNED BY "tbl_Sprachkenntnisse"."pk_Sprachkenntnis";


--
-- Name: tbl_Stundenerfassung; Type: TABLE; Schema: public; Owner: kaspi
--

CREATE TABLE "tbl_Stundenerfassung" (
    "pk_Stundenerfassung" integer NOT NULL,
    "fk_PersonenRolle" integer DEFAULT 0,
    "fk_FreiwilligenEinsatz" integer DEFAULT 0,
    "fk_Semester" integer,
    "z_Quartal" integer,
    "z_Jahr" integer,
    "z_Einsatzzahl" integer DEFAULT 0,
    "z_Stundenzahl" double precision DEFAULT 0,
    "z_Spesen" double precision DEFAULT 0,
    "t_Mutation" character varying(30),
    "d_MutDatum" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE "tbl_Stundenerfassung" OWNER TO kaspi;

--
-- Name: tbl_Stundenerfassung_pk_Stundenerfassung_seq; Type: SEQUENCE; Schema: public; Owner: kaspi
--

CREATE SEQUENCE "tbl_Stundenerfassung_pk_Stundenerfassung_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "tbl_Stundenerfassung_pk_Stundenerfassung_seq" OWNER TO kaspi;

--
-- Name: tbl_Stundenerfassung_pk_Stundenerfassung_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kaspi
--

ALTER SEQUENCE "tbl_Stundenerfassung_pk_Stundenerfassung_seq" OWNED BY "tbl_Stundenerfassung"."pk_Stundenerfassung";


--
-- Name: tbl_Veranstaltungen; Type: TABLE; Schema: public; Owner: kaspi
--

CREATE TABLE "tbl_Veranstaltungen" (
    "pk_Veranstaltung" integer NOT NULL,
    "fk_FreiwilligenVeranstaltung" integer DEFAULT 0,
    "d_Datum" timestamp without time zone,
    "t_Zeitraum" character varying(50),
    "t_VeranstaltungsName" character varying(50),
    "t_Ort" character varying(50),
    "m_Beschreibung" text,
    "t_Mutation" character varying(30),
    "d_MutDatum" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE "tbl_Veranstaltungen" OWNER TO kaspi;

--
-- Name: tbl_Veranstaltungen_pk_Veranstaltung_seq; Type: SEQUENCE; Schema: public; Owner: kaspi
--

CREATE SEQUENCE "tbl_Veranstaltungen_pk_Veranstaltung_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "tbl_Veranstaltungen_pk_Veranstaltung_seq" OWNER TO kaspi;

--
-- Name: tbl_Veranstaltungen_pk_Veranstaltung_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kaspi
--

ALTER SEQUENCE "tbl_Veranstaltungen_pk_Veranstaltung_seq" OWNED BY "tbl_Veranstaltungen"."pk_Veranstaltung";


--
-- Name: tbl_Veranstaltungsteilnehmer; Type: TABLE; Schema: public; Owner: kaspi
--

CREATE TABLE "tbl_Veranstaltungsteilnehmer" (
    "pk_Veranstaltungsteilnehmer" integer NOT NULL,
    "fk_Veranstaltung" integer DEFAULT 0,
    "fk_PersonenRolle" integer DEFAULT 0,
    "m_Bemerkungen" text,
    "t_Mutation" character varying(30),
    "d_MutDatum" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE "tbl_Veranstaltungsteilnehmer" OWNER TO kaspi;

--
-- Name: tbl_Veranstaltungsteilnehmer_pk_Veranstaltungsteilnehmer_seq; Type: SEQUENCE; Schema: public; Owner: kaspi
--

CREATE SEQUENCE "tbl_Veranstaltungsteilnehmer_pk_Veranstaltungsteilnehmer_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "tbl_Veranstaltungsteilnehmer_pk_Veranstaltungsteilnehmer_seq" OWNER TO kaspi;

--
-- Name: tbl_Veranstaltungsteilnehmer_pk_Veranstaltungsteilnehmer_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kaspi
--

ALTER SEQUENCE "tbl_Veranstaltungsteilnehmer_pk_Veranstaltungsteilnehmer_seq" OWNED BY "tbl_Veranstaltungsteilnehmer"."pk_Veranstaltungsteilnehmer";


--
-- Name: tbl_VerfahrensHistory; Type: TABLE; Schema: public; Owner: kaspi
--

CREATE TABLE "tbl_VerfahrensHistory" (
    "pk_VerfahrensHistory" integer NOT NULL,
    "fk_Hauptperson" integer DEFAULT 0,
    "fk_VerfahrensStatus" integer DEFAULT 0,
    "fk_FamilienRolle" integer DEFAULT 0,
    "d_PerDatum" timestamp without time zone,
    "m_Bemerkungen" text,
    "t_Mutation" character varying(30),
    "d_MutDatum" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE "tbl_VerfahrensHistory" OWNER TO kaspi;

--
-- Name: tbl_VerfahrensHistory_pk_VerfahrensHistory_seq; Type: SEQUENCE; Schema: public; Owner: kaspi
--

CREATE SEQUENCE "tbl_VerfahrensHistory_pk_VerfahrensHistory_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "tbl_VerfahrensHistory_pk_VerfahrensHistory_seq" OWNER TO kaspi;

--
-- Name: tbl_VerfahrensHistory_pk_VerfahrensHistory_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kaspi
--

ALTER SEQUENCE "tbl_VerfahrensHistory_pk_VerfahrensHistory_seq" OWNED BY "tbl_VerfahrensHistory"."pk_VerfahrensHistory";


--
-- Name: tbl_Verfahrensstati; Type: TABLE; Schema: public; Owner: kaspi
--

CREATE TABLE "tbl_Verfahrensstati" (
    "pk_Verfahrensstatus" integer NOT NULL,
    "t_Verfahrensstatus" character varying(50),
    "t_Abkürzung" character varying(5),
    "m_Beschreibung" text,
    "b_Status" boolean DEFAULT false,
    "t_Mutation" character varying(30),
    "d_MutDatum" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE "tbl_Verfahrensstati" OWNER TO kaspi;

--
-- Name: tbl_Verfahrensstati_pk_Verfahrensstatus_seq; Type: SEQUENCE; Schema: public; Owner: kaspi
--

CREATE SEQUENCE "tbl_Verfahrensstati_pk_Verfahrensstatus_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "tbl_Verfahrensstati_pk_Verfahrensstatus_seq" OWNER TO kaspi;

--
-- Name: tbl_Verfahrensstati_pk_Verfahrensstatus_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kaspi
--

ALTER SEQUENCE "tbl_Verfahrensstati_pk_Verfahrensstatus_seq" OWNED BY "tbl_Verfahrensstati"."pk_Verfahrensstatus";


--
-- Name: tbl_VersionData; Type: TABLE; Schema: public; Owner: kaspi
--

CREATE TABLE "tbl_VersionData" (
    "pk_VersionD" integer NOT NULL,
    "d_VDatumD" timestamp without time zone,
    "z_VersionsnummerD" double precision DEFAULT 0,
    "b_Update" boolean,
    "t_Mutation" character varying(30),
    "d_MutDatum" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE "tbl_VersionData" OWNER TO kaspi;

--
-- Name: tbl_VersionData_pk_VersionD_seq; Type: SEQUENCE; Schema: public; Owner: kaspi
--

CREATE SEQUENCE "tbl_VersionData_pk_VersionD_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "tbl_VersionData_pk_VersionD_seq" OWNER TO kaspi;

--
-- Name: tbl_VersionData_pk_VersionD_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kaspi
--

ALTER SEQUENCE "tbl_VersionData_pk_VersionD_seq" OWNED BY "tbl_VersionData"."pk_VersionD";


--
-- Name: tbl_Ausbildungen pk_Ausbildung; Type: DEFAULT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_Ausbildungen" ALTER COLUMN "pk_Ausbildung" SET DEFAULT nextval('"tbl_Ausbildungen_pk_Ausbildung_seq"'::regclass);


--
-- Name: tbl_AusbildungsTypen pk_AusbildungsTyp; Type: DEFAULT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_AusbildungsTypen" ALTER COLUMN "pk_AusbildungsTyp" SET DEFAULT nextval('"tbl_AusbildungsTypen_pk_AusbildungsTyp_seq"'::regclass);


--
-- Name: tbl_AuswVorlagen pk_Vorlage; Type: DEFAULT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_AuswVorlagen" ALTER COLUMN "pk_Vorlage" SET DEFAULT nextval('"tbl_AuswVorlagen_pk_Vorlage_seq"'::regclass);


--
-- Name: tbl_Begleitete pk_Begleitete; Type: DEFAULT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_Begleitete" ALTER COLUMN "pk_Begleitete" SET DEFAULT nextval('"tbl_Begleitete_pk_Begleitete_seq"'::regclass);


--
-- Name: tbl_EinsatzOrte pk_EinsatzOrt; Type: DEFAULT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_EinsatzOrte" ALTER COLUMN "pk_EinsatzOrt" SET DEFAULT nextval('"tbl_EinsatzOrte_pk_EinsatzOrt_seq"'::regclass);


--
-- Name: tbl_EinsatzOrteProEinsatzFunktion pk_EinsatzOrtProEinsatzFunktion; Type: DEFAULT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_EinsatzOrteProEinsatzFunktion" ALTER COLUMN "pk_EinsatzOrtProEinsatzFunktion" SET DEFAULT nextval('"tbl_EinsatzOrteProEinsatzFunk_pk_EinsatzOrtProEinsatzFunkti_seq"'::regclass);


--
-- Name: tbl_FallStelleProTeilnehmer pk_FallStelleProTeilnehmer; Type: DEFAULT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_FallStelleProTeilnehmer" ALTER COLUMN "pk_FallStelleProTeilnehmer" SET DEFAULT nextval('"tbl_FallStelleProTeilnehmer_pk_FallStelleProTeilnehmer_seq"'::regclass);


--
-- Name: tbl_FallStellen pk_FallStelle; Type: DEFAULT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_FallStellen" ALTER COLUMN "pk_FallStelle" SET DEFAULT nextval('"tbl_FallStellen_pk_FallStelle_seq"'::regclass);


--
-- Name: tbl_FamilienRollen pk_FamilienRolle; Type: DEFAULT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_FamilienRollen" ALTER COLUMN "pk_FamilienRolle" SET DEFAULT nextval('"tbl_FamilienRollen_pk_FamilienRolle_seq"'::regclass);


--
-- Name: tbl_FreiwilligenEinsätze pk_FreiwilligenEinsatz; Type: DEFAULT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_FreiwilligenEinsätze" ALTER COLUMN "pk_FreiwilligenEinsatz" SET DEFAULT nextval('"tbl_FreiwilligenEinsätze_pk_FreiwilligenEinsatz_seq"'::regclass);


--
-- Name: tbl_FreiwilligenEntschädigung pk_FreiwilligenEntschädigung; Type: DEFAULT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_FreiwilligenEntschädigung" ALTER COLUMN "pk_FreiwilligenEntschädigung" SET DEFAULT nextval('"tbl_FreiwilligenEntschädigun_pk_FreiwilligenEntschädigung_seq"'::regclass);


--
-- Name: tbl_FreiwilligenFunktionen pk_FreiwilligenFunktion; Type: DEFAULT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_FreiwilligenFunktionen" ALTER COLUMN "pk_FreiwilligenFunktion" SET DEFAULT nextval('"tbl_FreiwilligenFunktionen_pk_FreiwilligenFunktion_seq"'::regclass);


--
-- Name: tbl_FreiwilligenVeranstaltungen pk_FreiwilligenVeranstaltung; Type: DEFAULT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_FreiwilligenVeranstaltungen" ALTER COLUMN "pk_FreiwilligenVeranstaltung" SET DEFAULT nextval('"tbl_FreiwilligenVeranstaltunge_pk_FreiwilligenVeranstaltung_seq"'::regclass);


--
-- Name: tbl_Hauptpersonen pk_Hauptperson; Type: DEFAULT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_Hauptpersonen" ALTER COLUMN "pk_Hauptperson" SET DEFAULT nextval('"tbl_Hauptpersonen_pk_Hauptperson_seq"'::regclass);


--
-- Name: tbl_Journal pk_Journal; Type: DEFAULT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_Journal" ALTER COLUMN "pk_Journal" SET DEFAULT nextval('"tbl_Journal_pk_Journal_seq"'::regclass);


--
-- Name: tbl_JournalKategorien pk_JournalKategorie; Type: DEFAULT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_JournalKategorien" ALTER COLUMN "pk_JournalKategorie" SET DEFAULT nextval('"tbl_JournalKategorien_pk_JournalKategorie_seq"'::regclass);


--
-- Name: tbl_Kantone pk_Kanton; Type: DEFAULT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_Kantone" ALTER COLUMN "pk_Kanton" SET DEFAULT nextval('"tbl_Kantone_pk_Kanton_seq"'::regclass);


--
-- Name: tbl_KontaktPersonen pk_Kontaktperson; Type: DEFAULT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_KontaktPersonen" ALTER COLUMN "pk_Kontaktperson" SET DEFAULT nextval('"tbl_KontaktPersonen_pk_Kontaktperson_seq"'::regclass);


--
-- Name: tbl_Kontoangaben pk_Kontoangabe; Type: DEFAULT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_Kontoangaben" ALTER COLUMN "pk_Kontoangabe" SET DEFAULT nextval('"tbl_Kontoangaben_pk_Kontoangabe_seq"'::regclass);


--
-- Name: tbl_Kostenträger pk_Kostenträger; Type: DEFAULT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_Kostenträger" ALTER COLUMN "pk_Kostenträger" SET DEFAULT nextval('"tbl_Kostenträger_pk_Kostenträger_seq"'::regclass);


--
-- Name: tbl_Kursarten pk_Kursart; Type: DEFAULT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_Kursarten" ALTER COLUMN "pk_Kursart" SET DEFAULT nextval('"tbl_Kursarten_pk_Kursart_seq"'::regclass);


--
-- Name: tbl_Kurse pk_Kurs; Type: DEFAULT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_Kurse" ALTER COLUMN "pk_Kurs" SET DEFAULT nextval('"tbl_Kurse_pk_Kurs_seq"'::regclass);


--
-- Name: tbl_Kurspräsenzen pk_Kurspräsenz; Type: DEFAULT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_Kurspräsenzen" ALTER COLUMN "pk_Kurspräsenz" SET DEFAULT nextval('"tbl_Kurspräsenzen_pk_Kurspräsenz_seq"'::regclass);


--
-- Name: tbl_Kursteilnehmer pk_Kursteilnehmer; Type: DEFAULT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_Kursteilnehmer" ALTER COLUMN "pk_Kursteilnehmer" SET DEFAULT nextval('"tbl_Kursteilnehmer_pk_Kursteilnehmer_seq"'::regclass);


--
-- Name: tbl_Lehrmittel pk_Lehrmittel; Type: DEFAULT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_Lehrmittel" ALTER COLUMN "pk_Lehrmittel" SET DEFAULT nextval('"tbl_Lehrmittel_pk_Lehrmittel_seq"'::regclass);


--
-- Name: tbl_Länder pk_Land; Type: DEFAULT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_Länder" ALTER COLUMN "pk_Land" SET DEFAULT nextval('"tbl_Länder_pk_Land_seq"'::regclass);


--
-- Name: tbl_ParameterT pk_Parameter; Type: DEFAULT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_ParameterT" ALTER COLUMN "pk_Parameter" SET DEFAULT nextval('"tbl_ParameterT_pk_Parameter_seq"'::regclass);


--
-- Name: tbl_ParameterZ pk_Parameter; Type: DEFAULT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_ParameterZ" ALTER COLUMN "pk_Parameter" SET DEFAULT nextval('"tbl_ParameterZ_pk_Parameter_seq"'::regclass);


--
-- Name: tbl_Personenrollen pk_PersonenRolle; Type: DEFAULT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_Personenrollen" ALTER COLUMN "pk_PersonenRolle" SET DEFAULT nextval('"tbl_Personenrollen_pk_PersonenRolle_seq"'::regclass);


--
-- Name: tbl_PlzOrt pk_PlzOrt; Type: DEFAULT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_PlzOrt" ALTER COLUMN "pk_PlzOrt" SET DEFAULT nextval('"tbl_PlzOrt_pk_PlzOrt_seq"'::regclass);


--
-- Name: tbl_Rollen pk_Rolle; Type: DEFAULT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_Rollen" ALTER COLUMN "pk_Rolle" SET DEFAULT nextval('"tbl_Rollen_pk_Rolle_seq"'::regclass);


--
-- Name: tbl_Semester pk_Semester; Type: DEFAULT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_Semester" ALTER COLUMN "pk_Semester" SET DEFAULT nextval('"tbl_Semester_pk_Semester_seq"'::regclass);


--
-- Name: tbl_Spesenansätze pk_Spesenansatz; Type: DEFAULT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_Spesenansätze" ALTER COLUMN "pk_Spesenansatz" SET DEFAULT nextval('"tbl_Spesenansätze_pk_Spesenansatz_seq"'::regclass);


--
-- Name: tbl_SpracheProHauptperson pk_SpracheProPerson; Type: DEFAULT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_SpracheProHauptperson" ALTER COLUMN "pk_SpracheProPerson" SET DEFAULT nextval('"tbl_SpracheProHauptperson_pk_SpracheProPerson_seq"'::regclass);


--
-- Name: tbl_Sprachen pk_Sprache; Type: DEFAULT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_Sprachen" ALTER COLUMN "pk_Sprache" SET DEFAULT nextval('"tbl_Sprachen_pk_Sprache_seq"'::regclass);


--
-- Name: tbl_Sprachkenntnisse pk_Sprachkenntnis; Type: DEFAULT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_Sprachkenntnisse" ALTER COLUMN "pk_Sprachkenntnis" SET DEFAULT nextval('"tbl_Sprachkenntnisse_pk_Sprachkenntnis_seq"'::regclass);


--
-- Name: tbl_Stundenerfassung pk_Stundenerfassung; Type: DEFAULT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_Stundenerfassung" ALTER COLUMN "pk_Stundenerfassung" SET DEFAULT nextval('"tbl_Stundenerfassung_pk_Stundenerfassung_seq"'::regclass);


--
-- Name: tbl_Veranstaltungen pk_Veranstaltung; Type: DEFAULT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_Veranstaltungen" ALTER COLUMN "pk_Veranstaltung" SET DEFAULT nextval('"tbl_Veranstaltungen_pk_Veranstaltung_seq"'::regclass);


--
-- Name: tbl_Veranstaltungsteilnehmer pk_Veranstaltungsteilnehmer; Type: DEFAULT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_Veranstaltungsteilnehmer" ALTER COLUMN "pk_Veranstaltungsteilnehmer" SET DEFAULT nextval('"tbl_Veranstaltungsteilnehmer_pk_Veranstaltungsteilnehmer_seq"'::regclass);


--
-- Name: tbl_VerfahrensHistory pk_VerfahrensHistory; Type: DEFAULT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_VerfahrensHistory" ALTER COLUMN "pk_VerfahrensHistory" SET DEFAULT nextval('"tbl_VerfahrensHistory_pk_VerfahrensHistory_seq"'::regclass);


--
-- Name: tbl_Verfahrensstati pk_Verfahrensstatus; Type: DEFAULT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_Verfahrensstati" ALTER COLUMN "pk_Verfahrensstatus" SET DEFAULT nextval('"tbl_Verfahrensstati_pk_Verfahrensstatus_seq"'::regclass);


--
-- Name: tbl_VersionData pk_VersionD; Type: DEFAULT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_VersionData" ALTER COLUMN "pk_VersionD" SET DEFAULT nextval('"tbl_VersionData_pk_VersionD_seq"'::regclass);


--
-- Name: tbl_Ausbildungen tbl_Ausbildungen_pkey; Type: CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_Ausbildungen"
    ADD CONSTRAINT "tbl_Ausbildungen_pkey" PRIMARY KEY ("pk_Ausbildung");


--
-- Name: tbl_AusbildungsTypen tbl_AusbildungsTypen_pkey; Type: CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_AusbildungsTypen"
    ADD CONSTRAINT "tbl_AusbildungsTypen_pkey" PRIMARY KEY ("pk_AusbildungsTyp");


--
-- Name: tbl_AuswVorlagen tbl_AuswVorlagen_pkey; Type: CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_AuswVorlagen"
    ADD CONSTRAINT "tbl_AuswVorlagen_pkey" PRIMARY KEY ("pk_Vorlage");


--
-- Name: tbl_Begleitete tbl_Begleitete_pkey; Type: CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_Begleitete"
    ADD CONSTRAINT "tbl_Begleitete_pkey" PRIMARY KEY ("pk_Begleitete");


--
-- Name: tbl_EinsatzOrteProEinsatzFunktion tbl_EinsatzOrteProEinsatzFunktion_pkey; Type: CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_EinsatzOrteProEinsatzFunktion"
    ADD CONSTRAINT "tbl_EinsatzOrteProEinsatzFunktion_pkey" PRIMARY KEY ("pk_EinsatzOrtProEinsatzFunktion");


--
-- Name: tbl_EinsatzOrte tbl_EinsatzOrte_pkey; Type: CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_EinsatzOrte"
    ADD CONSTRAINT "tbl_EinsatzOrte_pkey" PRIMARY KEY ("pk_EinsatzOrt");


--
-- Name: tbl_FallStelleProTeilnehmer tbl_FallStelleProTeilnehmer_pkey; Type: CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_FallStelleProTeilnehmer"
    ADD CONSTRAINT "tbl_FallStelleProTeilnehmer_pkey" PRIMARY KEY ("pk_FallStelleProTeilnehmer");


--
-- Name: tbl_FallStellen tbl_FallStellen_pkey; Type: CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_FallStellen"
    ADD CONSTRAINT "tbl_FallStellen_pkey" PRIMARY KEY ("pk_FallStelle");


--
-- Name: tbl_FamilienRollen tbl_FamilienRollen_pkey; Type: CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_FamilienRollen"
    ADD CONSTRAINT "tbl_FamilienRollen_pkey" PRIMARY KEY ("pk_FamilienRolle");


--
-- Name: tbl_FreiwilligenEinsätze tbl_FreiwilligenEinsätze_pkey; Type: CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_FreiwilligenEinsätze"
    ADD CONSTRAINT "tbl_FreiwilligenEinsätze_pkey" PRIMARY KEY ("pk_FreiwilligenEinsatz");


--
-- Name: tbl_FreiwilligenEntschädigung tbl_FreiwilligenEntschädigung_pkey; Type: CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_FreiwilligenEntschädigung"
    ADD CONSTRAINT "tbl_FreiwilligenEntschädigung_pkey" PRIMARY KEY ("pk_FreiwilligenEntschädigung");


--
-- Name: tbl_FreiwilligenFunktionen tbl_FreiwilligenFunktionen_pkey; Type: CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_FreiwilligenFunktionen"
    ADD CONSTRAINT "tbl_FreiwilligenFunktionen_pkey" PRIMARY KEY ("pk_FreiwilligenFunktion");


--
-- Name: tbl_FreiwilligenVeranstaltungen tbl_FreiwilligenVeranstaltungen_pkey; Type: CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_FreiwilligenVeranstaltungen"
    ADD CONSTRAINT "tbl_FreiwilligenVeranstaltungen_pkey" PRIMARY KEY ("pk_FreiwilligenVeranstaltung");


--
-- Name: tbl_Hauptpersonen tbl_Hauptpersonen_pkey; Type: CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_Hauptpersonen"
    ADD CONSTRAINT "tbl_Hauptpersonen_pkey" PRIMARY KEY ("pk_Hauptperson");


--
-- Name: tbl_JournalKategorien tbl_JournalKategorien_pkey; Type: CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_JournalKategorien"
    ADD CONSTRAINT "tbl_JournalKategorien_pkey" PRIMARY KEY ("pk_JournalKategorie");


--
-- Name: tbl_Journal tbl_Journal_pkey; Type: CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_Journal"
    ADD CONSTRAINT "tbl_Journal_pkey" PRIMARY KEY ("pk_Journal");


--
-- Name: tbl_Kantone tbl_Kantone_pkey; Type: CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_Kantone"
    ADD CONSTRAINT "tbl_Kantone_pkey" PRIMARY KEY ("pk_Kanton");


--
-- Name: tbl_KontaktPersonen tbl_KontaktPersonen_pkey; Type: CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_KontaktPersonen"
    ADD CONSTRAINT "tbl_KontaktPersonen_pkey" PRIMARY KEY ("pk_Kontaktperson");


--
-- Name: tbl_Kontoangaben tbl_Kontoangaben_pkey; Type: CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_Kontoangaben"
    ADD CONSTRAINT "tbl_Kontoangaben_pkey" PRIMARY KEY ("pk_Kontoangabe");


--
-- Name: tbl_Kostenträger tbl_Kostenträger_pkey; Type: CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_Kostenträger"
    ADD CONSTRAINT "tbl_Kostenträger_pkey" PRIMARY KEY ("pk_Kostenträger");


--
-- Name: tbl_Kursarten tbl_Kursarten_pkey; Type: CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_Kursarten"
    ADD CONSTRAINT "tbl_Kursarten_pkey" PRIMARY KEY ("pk_Kursart");


--
-- Name: tbl_Kurse tbl_Kurse_pkey; Type: CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_Kurse"
    ADD CONSTRAINT "tbl_Kurse_pkey" PRIMARY KEY ("pk_Kurs");


--
-- Name: tbl_Kurspräsenzen tbl_Kurspräsenzen_pkey; Type: CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_Kurspräsenzen"
    ADD CONSTRAINT "tbl_Kurspräsenzen_pkey" PRIMARY KEY ("pk_Kurspräsenz");


--
-- Name: tbl_Kursteilnehmer tbl_Kursteilnehmer_pkey; Type: CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_Kursteilnehmer"
    ADD CONSTRAINT "tbl_Kursteilnehmer_pkey" PRIMARY KEY ("pk_Kursteilnehmer");


--
-- Name: tbl_Lehrmittel tbl_Lehrmittel_pkey; Type: CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_Lehrmittel"
    ADD CONSTRAINT "tbl_Lehrmittel_pkey" PRIMARY KEY ("pk_Lehrmittel");


--
-- Name: tbl_Länder tbl_Länder_pkey; Type: CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_Länder"
    ADD CONSTRAINT "tbl_Länder_pkey" PRIMARY KEY ("pk_Land");


--
-- Name: tbl_ParameterT tbl_ParameterT_pkey; Type: CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_ParameterT"
    ADD CONSTRAINT "tbl_ParameterT_pkey" PRIMARY KEY ("pk_Parameter");


--
-- Name: tbl_ParameterZ tbl_ParameterZ_pkey; Type: CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_ParameterZ"
    ADD CONSTRAINT "tbl_ParameterZ_pkey" PRIMARY KEY ("pk_Parameter");


--
-- Name: tbl_Personenrollen tbl_Personenrollen_pkey; Type: CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_Personenrollen"
    ADD CONSTRAINT "tbl_Personenrollen_pkey" PRIMARY KEY ("pk_PersonenRolle");


--
-- Name: tbl_PlzOrt tbl_PlzOrt_pkey; Type: CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_PlzOrt"
    ADD CONSTRAINT "tbl_PlzOrt_pkey" PRIMARY KEY ("pk_PlzOrt");


--
-- Name: tbl_Rollen tbl_Rollen_pkey; Type: CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_Rollen"
    ADD CONSTRAINT "tbl_Rollen_pkey" PRIMARY KEY ("pk_Rolle");


--
-- Name: tbl_Semester tbl_Semester_pkey; Type: CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_Semester"
    ADD CONSTRAINT "tbl_Semester_pkey" PRIMARY KEY ("pk_Semester");


--
-- Name: tbl_Spesenansätze tbl_Spesenansätze_pkey; Type: CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_Spesenansätze"
    ADD CONSTRAINT "tbl_Spesenansätze_pkey" PRIMARY KEY ("pk_Spesenansatz");


--
-- Name: tbl_SpracheProHauptperson tbl_SpracheProHauptperson_pkey; Type: CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_SpracheProHauptperson"
    ADD CONSTRAINT "tbl_SpracheProHauptperson_pkey" PRIMARY KEY ("pk_SpracheProPerson");


--
-- Name: tbl_Sprachen tbl_Sprachen_pkey; Type: CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_Sprachen"
    ADD CONSTRAINT "tbl_Sprachen_pkey" PRIMARY KEY ("pk_Sprache");


--
-- Name: tbl_Sprachkenntnisse tbl_Sprachkenntnisse_pkey; Type: CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_Sprachkenntnisse"
    ADD CONSTRAINT "tbl_Sprachkenntnisse_pkey" PRIMARY KEY ("pk_Sprachkenntnis");


--
-- Name: tbl_Stundenerfassung tbl_Stundenerfassung_pkey; Type: CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_Stundenerfassung"
    ADD CONSTRAINT "tbl_Stundenerfassung_pkey" PRIMARY KEY ("pk_Stundenerfassung");


--
-- Name: tbl_Veranstaltungen tbl_Veranstaltungen_pkey; Type: CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_Veranstaltungen"
    ADD CONSTRAINT "tbl_Veranstaltungen_pkey" PRIMARY KEY ("pk_Veranstaltung");


--
-- Name: tbl_Veranstaltungsteilnehmer tbl_Veranstaltungsteilnehmer_pkey; Type: CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_Veranstaltungsteilnehmer"
    ADD CONSTRAINT "tbl_Veranstaltungsteilnehmer_pkey" PRIMARY KEY ("pk_Veranstaltungsteilnehmer");


--
-- Name: tbl_VerfahrensHistory tbl_VerfahrensHistory_pkey; Type: CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_VerfahrensHistory"
    ADD CONSTRAINT "tbl_VerfahrensHistory_pkey" PRIMARY KEY ("pk_VerfahrensHistory");


--
-- Name: tbl_Verfahrensstati tbl_Verfahrensstati_pkey; Type: CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_Verfahrensstati"
    ADD CONSTRAINT "tbl_Verfahrensstati_pkey" PRIMARY KEY ("pk_Verfahrensstatus");


--
-- Name: tbl_VersionData tbl_VersionData_pkey; Type: CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_VersionData"
    ADD CONSTRAINT "tbl_VersionData_pkey" PRIMARY KEY ("pk_VersionD");


--
-- Name: tbl_VersionData tbl_VersionData_z_VersionsnummerD_key; Type: CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_VersionData"
    ADD CONSTRAINT "tbl_VersionData_z_VersionsnummerD_key" UNIQUE ("z_VersionsnummerD");


--
-- Name: tbl_Kontoangaben_z_ClearingNummer; Type: INDEX; Schema: public; Owner: kaspi
--

CREATE INDEX "tbl_Kontoangaben_z_ClearingNummer" ON "tbl_Kontoangaben" USING btree ("z_ClearingNummer");


--
-- Name: tbl_Ausbildungen tbl_Ausbildungen_fk_AusbildungsTyp_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_Ausbildungen"
    ADD CONSTRAINT "tbl_Ausbildungen_fk_AusbildungsTyp_fkey" FOREIGN KEY ("fk_AusbildungsTyp") REFERENCES "tbl_AusbildungsTypen"("pk_AusbildungsTyp");


--
-- Name: tbl_Ausbildungen tbl_Ausbildungen_fk_Hauptperson_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_Ausbildungen"
    ADD CONSTRAINT "tbl_Ausbildungen_fk_Hauptperson_fkey" FOREIGN KEY ("fk_Hauptperson") REFERENCES "tbl_Hauptpersonen"("pk_Hauptperson");


--
-- Name: tbl_Begleitete tbl_Begleitete_fk_FamilienRolle_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_Begleitete"
    ADD CONSTRAINT "tbl_Begleitete_fk_FamilienRolle_fkey" FOREIGN KEY ("fk_FamilienRolle") REFERENCES "tbl_FamilienRollen"("pk_FamilienRolle");


--
-- Name: tbl_Begleitete tbl_Begleitete_fk_PersonenRolle_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_Begleitete"
    ADD CONSTRAINT "tbl_Begleitete_fk_PersonenRolle_fkey" FOREIGN KEY ("fk_PersonenRolle") REFERENCES "tbl_Personenrollen"("pk_PersonenRolle");


--
-- Name: tbl_EinsatzOrteProEinsatzFunktion tbl_EinsatzOrteProEinsatzFunktion_fk_EinsatzFunktion_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_EinsatzOrteProEinsatzFunktion"
    ADD CONSTRAINT "tbl_EinsatzOrteProEinsatzFunktion_fk_EinsatzFunktion_fkey" FOREIGN KEY ("fk_EinsatzFunktion") REFERENCES "tbl_FreiwilligenFunktionen"("pk_FreiwilligenFunktion");


--
-- Name: tbl_EinsatzOrteProEinsatzFunktion tbl_EinsatzOrteProEinsatzFunktion_fk_EinsatzOrt_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_EinsatzOrteProEinsatzFunktion"
    ADD CONSTRAINT "tbl_EinsatzOrteProEinsatzFunktion_fk_EinsatzOrt_fkey" FOREIGN KEY ("fk_EinsatzOrt") REFERENCES "tbl_EinsatzOrte"("pk_EinsatzOrt");


--
-- Name: tbl_EinsatzOrte tbl_EinsatzOrte_fk_PlzOrt_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_EinsatzOrte"
    ADD CONSTRAINT "tbl_EinsatzOrte_fk_PlzOrt_fkey" FOREIGN KEY ("fk_PlzOrt") REFERENCES "tbl_PlzOrt"("pk_PlzOrt");


--
-- Name: tbl_FallStelleProTeilnehmer tbl_FallStelleProTeilnehmer_fk_Fallstelle_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_FallStelleProTeilnehmer"
    ADD CONSTRAINT "tbl_FallStelleProTeilnehmer_fk_Fallstelle_fkey" FOREIGN KEY ("fk_Fallstelle") REFERENCES "tbl_FallStellen"("pk_FallStelle");


--
-- Name: tbl_FallStelleProTeilnehmer tbl_FallStelleProTeilnehmer_fk_Kontaktperson_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_FallStelleProTeilnehmer"
    ADD CONSTRAINT "tbl_FallStelleProTeilnehmer_fk_Kontaktperson_fkey" FOREIGN KEY ("fk_Kontaktperson") REFERENCES "tbl_KontaktPersonen"("pk_Kontaktperson");


--
-- Name: tbl_FallStelleProTeilnehmer tbl_FallStelleProTeilnehmer_fk_PersonenRolle_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_FallStelleProTeilnehmer"
    ADD CONSTRAINT "tbl_FallStelleProTeilnehmer_fk_PersonenRolle_fkey" FOREIGN KEY ("fk_PersonenRolle") REFERENCES "tbl_Personenrollen"("pk_PersonenRolle");


--
-- Name: tbl_FallStellen tbl_FallStellen_fk_PLZ_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_FallStellen"
    ADD CONSTRAINT "tbl_FallStellen_fk_PLZ_fkey" FOREIGN KEY ("fk_PLZ") REFERENCES "tbl_PlzOrt"("pk_PlzOrt");


--
-- Name: tbl_FreiwilligenEinsätze tbl_FreiwilligenEinsätze_fk_Begleitete_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_FreiwilligenEinsätze"
    ADD CONSTRAINT "tbl_FreiwilligenEinsätze_fk_Begleitete_fkey" FOREIGN KEY ("fk_Begleitete") REFERENCES "tbl_Begleitete"("pk_Begleitete");


--
-- Name: tbl_FreiwilligenEinsätze tbl_FreiwilligenEinsätze_fk_EinsatzOrt_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_FreiwilligenEinsätze"
    ADD CONSTRAINT "tbl_FreiwilligenEinsätze_fk_EinsatzOrt_fkey" FOREIGN KEY ("fk_EinsatzOrt") REFERENCES "tbl_EinsatzOrte"("pk_EinsatzOrt");


--
-- Name: tbl_FreiwilligenEinsätze tbl_FreiwilligenEinsätze_fk_FreiwilligenFunktion_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_FreiwilligenEinsätze"
    ADD CONSTRAINT "tbl_FreiwilligenEinsätze_fk_FreiwilligenFunktion_fkey" FOREIGN KEY ("fk_FreiwilligenFunktion") REFERENCES "tbl_FreiwilligenFunktionen"("pk_FreiwilligenFunktion");


--
-- Name: tbl_FreiwilligenEinsätze tbl_FreiwilligenEinsätze_fk_Kostenträger_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_FreiwilligenEinsätze"
    ADD CONSTRAINT "tbl_FreiwilligenEinsätze_fk_Kostenträger_fkey" FOREIGN KEY ("fk_Kostenträger") REFERENCES "tbl_Kostenträger"("pk_Kostenträger");


--
-- Name: tbl_FreiwilligenEinsätze tbl_FreiwilligenEinsätze_fk_Kurs_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_FreiwilligenEinsätze"
    ADD CONSTRAINT "tbl_FreiwilligenEinsätze_fk_Kurs_fkey" FOREIGN KEY ("fk_Kurs") REFERENCES "tbl_Kurse"("pk_Kurs");


--
-- Name: tbl_FreiwilligenEinsätze tbl_FreiwilligenEinsätze_fk_Lehrmittel_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_FreiwilligenEinsätze"
    ADD CONSTRAINT "tbl_FreiwilligenEinsätze_fk_Lehrmittel_fkey" FOREIGN KEY ("fk_Lehrmittel") REFERENCES "tbl_Lehrmittel"("pk_Lehrmittel");


--
-- Name: tbl_FreiwilligenEinsätze tbl_FreiwilligenEinsätze_fk_PersonenRolle_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_FreiwilligenEinsätze"
    ADD CONSTRAINT "tbl_FreiwilligenEinsätze_fk_PersonenRolle_fkey" FOREIGN KEY ("fk_PersonenRolle") REFERENCES "tbl_Personenrollen"("pk_PersonenRolle");


--
-- Name: tbl_FreiwilligenEinsätze tbl_FreiwilligenEinsätze_fk_Semester_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_FreiwilligenEinsätze"
    ADD CONSTRAINT "tbl_FreiwilligenEinsätze_fk_Semester_fkey" FOREIGN KEY ("fk_Semester") REFERENCES "tbl_Semester"("pk_Semester");


--
-- Name: tbl_FreiwilligenEntschädigung tbl_FreiwilligenEntschädigung_fk_PersonenRolle_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_FreiwilligenEntschädigung"
    ADD CONSTRAINT "tbl_FreiwilligenEntschädigung_fk_PersonenRolle_fkey" FOREIGN KEY ("fk_PersonenRolle") REFERENCES "tbl_Personenrollen"("pk_PersonenRolle");


--
-- Name: tbl_FreiwilligenEntschädigung tbl_FreiwilligenEntschädigung_fk_Semester_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_FreiwilligenEntschädigung"
    ADD CONSTRAINT "tbl_FreiwilligenEntschädigung_fk_Semester_fkey" FOREIGN KEY ("fk_Semester") REFERENCES "tbl_Semester"("pk_Semester");


--
-- Name: tbl_FreiwilligenFunktionen tbl_FreiwilligenFunktionen_fk_Rolle_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_FreiwilligenFunktionen"
    ADD CONSTRAINT "tbl_FreiwilligenFunktionen_fk_Rolle_fkey" FOREIGN KEY ("fk_Rolle") REFERENCES "tbl_Rollen"("pk_Rolle");


--
-- Name: tbl_Hauptpersonen tbl_Hauptpersonen_fk_PLZ_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_Hauptpersonen"
    ADD CONSTRAINT "tbl_Hauptpersonen_fk_PLZ_fkey" FOREIGN KEY ("fk_PLZ") REFERENCES "tbl_PlzOrt"("pk_PlzOrt");


--
-- Name: tbl_Journal tbl_Journal_fk_FreiwilligenEinsatz_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_Journal"
    ADD CONSTRAINT "tbl_Journal_fk_FreiwilligenEinsatz_fkey" FOREIGN KEY ("fk_FreiwilligenEinsatz") REFERENCES "tbl_FreiwilligenEinsätze"("pk_FreiwilligenEinsatz");


--
-- Name: tbl_Journal tbl_Journal_fk_Hauptperson_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_Journal"
    ADD CONSTRAINT "tbl_Journal_fk_Hauptperson_fkey" FOREIGN KEY ("fk_Hauptperson") REFERENCES "tbl_Hauptpersonen"("pk_Hauptperson");


--
-- Name: tbl_Journal tbl_Journal_fk_JournalKategorie_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_Journal"
    ADD CONSTRAINT "tbl_Journal_fk_JournalKategorie_fkey" FOREIGN KEY ("fk_JournalKategorie") REFERENCES "tbl_JournalKategorien"("pk_JournalKategorie");


--
-- Name: tbl_KontaktPersonen tbl_KontaktPersonen_fk_FallStelle_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_KontaktPersonen"
    ADD CONSTRAINT "tbl_KontaktPersonen_fk_FallStelle_fkey" FOREIGN KEY ("fk_FallStelle") REFERENCES "tbl_FallStellen"("pk_FallStelle");


--
-- Name: tbl_Kontoangaben tbl_Kontoangaben_fk_Hauptperson_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_Kontoangaben"
    ADD CONSTRAINT "tbl_Kontoangaben_fk_Hauptperson_fkey" FOREIGN KEY ("fk_Hauptperson") REFERENCES "tbl_Hauptpersonen"("pk_Hauptperson");


--
-- Name: tbl_Kontoangaben tbl_Kontoangaben_fk_PlzOrt_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_Kontoangaben"
    ADD CONSTRAINT "tbl_Kontoangaben_fk_PlzOrt_fkey" FOREIGN KEY ("fk_PlzOrt") REFERENCES "tbl_PlzOrt"("pk_PlzOrt");


--
-- Name: tbl_Kurse tbl_Kurse_fk_Kursart_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_Kurse"
    ADD CONSTRAINT "tbl_Kurse_fk_Kursart_fkey" FOREIGN KEY ("fk_Kursart") REFERENCES "tbl_Kursarten"("pk_Kursart");


--
-- Name: tbl_Kurspräsenzen tbl_Kurspräsenzen_fk_Begleitete_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_Kurspräsenzen"
    ADD CONSTRAINT "tbl_Kurspräsenzen_fk_Begleitete_fkey" FOREIGN KEY ("fk_Begleitete") REFERENCES "tbl_Begleitete"("pk_Begleitete");


--
-- Name: tbl_Kurspräsenzen tbl_Kurspräsenzen_fk_Kurs_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_Kurspräsenzen"
    ADD CONSTRAINT "tbl_Kurspräsenzen_fk_Kurs_fkey" FOREIGN KEY ("fk_Kurs") REFERENCES "tbl_Kurse"("pk_Kurs");


--
-- Name: tbl_Kurspräsenzen tbl_Kurspräsenzen_fk_Kursteilnehmer_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_Kurspräsenzen"
    ADD CONSTRAINT "tbl_Kurspräsenzen_fk_Kursteilnehmer_fkey" FOREIGN KEY ("fk_Kursteilnehmer") REFERENCES "tbl_Kursteilnehmer"("pk_Kursteilnehmer");


--
-- Name: tbl_Kursteilnehmer tbl_Kursteilnehmer_fk_Begleitete_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_Kursteilnehmer"
    ADD CONSTRAINT "tbl_Kursteilnehmer_fk_Begleitete_fkey" FOREIGN KEY ("fk_Begleitete") REFERENCES "tbl_Begleitete"("pk_Begleitete");


--
-- Name: tbl_Kursteilnehmer tbl_Kursteilnehmer_fk_Kurs_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_Kursteilnehmer"
    ADD CONSTRAINT "tbl_Kursteilnehmer_fk_Kurs_fkey" FOREIGN KEY ("fk_Kurs") REFERENCES "tbl_Kurse"("pk_Kurs");


--
-- Name: tbl_Personenrollen tbl_Personenrollen_fk_Hauptperson_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_Personenrollen"
    ADD CONSTRAINT "tbl_Personenrollen_fk_Hauptperson_fkey" FOREIGN KEY ("fk_Hauptperson") REFERENCES "tbl_Hauptpersonen"("pk_Hauptperson");


--
-- Name: tbl_Personenrollen tbl_Personenrollen_fk_Kostenträger_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_Personenrollen"
    ADD CONSTRAINT "tbl_Personenrollen_fk_Kostenträger_fkey" FOREIGN KEY ("fk_Kostenträger") REFERENCES "tbl_Kostenträger"("pk_Kostenträger");


--
-- Name: tbl_Personenrollen tbl_Personenrollen_z_Rolle_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_Personenrollen"
    ADD CONSTRAINT "tbl_Personenrollen_z_Rolle_fkey" FOREIGN KEY ("z_Rolle") REFERENCES "tbl_Rollen"("pk_Rolle");


--
-- Name: tbl_PlzOrt tbl_PlzOrt_fk_Land_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_PlzOrt"
    ADD CONSTRAINT "tbl_PlzOrt_fk_Land_fkey" FOREIGN KEY ("fk_Land") REFERENCES "tbl_Länder"("pk_Land");


--
-- Name: tbl_Semester tbl_Semester_fk_Rolle_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_Semester"
    ADD CONSTRAINT "tbl_Semester_fk_Rolle_fkey" FOREIGN KEY ("fk_Rolle") REFERENCES "tbl_Rollen"("pk_Rolle");


--
-- Name: tbl_Spesenansätze tbl_Spesenansätze_fk_Personenrolle_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_Spesenansätze"
    ADD CONSTRAINT "tbl_Spesenansätze_fk_Personenrolle_fkey" FOREIGN KEY ("fk_Personenrolle") REFERENCES "tbl_Personenrollen"("pk_PersonenRolle");


--
-- Name: tbl_SpracheProHauptperson tbl_SpracheProHauptperson_fk_Hauptperson_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_SpracheProHauptperson"
    ADD CONSTRAINT "tbl_SpracheProHauptperson_fk_Hauptperson_fkey" FOREIGN KEY ("fk_Hauptperson") REFERENCES "tbl_Hauptpersonen"("pk_Hauptperson");


--
-- Name: tbl_SpracheProHauptperson tbl_SpracheProHauptperson_fk_KenntnisstufeLe_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_SpracheProHauptperson"
    ADD CONSTRAINT "tbl_SpracheProHauptperson_fk_KenntnisstufeLe_fkey" FOREIGN KEY ("fk_KenntnisstufeLe") REFERENCES "tbl_Sprachkenntnisse"("pk_Sprachkenntnis");


--
-- Name: tbl_SpracheProHauptperson tbl_SpracheProHauptperson_fk_KenntnisstufeSc_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_SpracheProHauptperson"
    ADD CONSTRAINT "tbl_SpracheProHauptperson_fk_KenntnisstufeSc_fkey" FOREIGN KEY ("fk_KenntnisstufeSc") REFERENCES "tbl_Sprachkenntnisse"("pk_Sprachkenntnis");


--
-- Name: tbl_SpracheProHauptperson tbl_SpracheProHauptperson_fk_KenntnisstufeSp_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_SpracheProHauptperson"
    ADD CONSTRAINT "tbl_SpracheProHauptperson_fk_KenntnisstufeSp_fkey" FOREIGN KEY ("fk_KenntnisstufeSp") REFERENCES "tbl_Sprachkenntnisse"("pk_Sprachkenntnis");


--
-- Name: tbl_SpracheProHauptperson tbl_SpracheProHauptperson_fk_KenntnisstufeVe_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_SpracheProHauptperson"
    ADD CONSTRAINT "tbl_SpracheProHauptperson_fk_KenntnisstufeVe_fkey" FOREIGN KEY ("fk_KenntnisstufeVe") REFERENCES "tbl_Sprachkenntnisse"("pk_Sprachkenntnis");


--
-- Name: tbl_SpracheProHauptperson tbl_SpracheProHauptperson_fk_Sprache_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_SpracheProHauptperson"
    ADD CONSTRAINT "tbl_SpracheProHauptperson_fk_Sprache_fkey" FOREIGN KEY ("fk_Sprache") REFERENCES "tbl_Sprachen"("pk_Sprache");


--
-- Name: tbl_Stundenerfassung tbl_Stundenerfassung_fk_FreiwilligenEinsatz_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_Stundenerfassung"
    ADD CONSTRAINT "tbl_Stundenerfassung_fk_FreiwilligenEinsatz_fkey" FOREIGN KEY ("fk_FreiwilligenEinsatz") REFERENCES "tbl_FreiwilligenEinsätze"("pk_FreiwilligenEinsatz");


--
-- Name: tbl_Stundenerfassung tbl_Stundenerfassung_fk_PersonenRolle_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_Stundenerfassung"
    ADD CONSTRAINT "tbl_Stundenerfassung_fk_PersonenRolle_fkey" FOREIGN KEY ("fk_PersonenRolle") REFERENCES "tbl_Personenrollen"("pk_PersonenRolle");


--
-- Name: tbl_Stundenerfassung tbl_Stundenerfassung_fk_Semester_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_Stundenerfassung"
    ADD CONSTRAINT "tbl_Stundenerfassung_fk_Semester_fkey" FOREIGN KEY ("fk_Semester") REFERENCES "tbl_Semester"("pk_Semester");


--
-- Name: tbl_Veranstaltungen tbl_Veranstaltungen_fk_FreiwilligenVeranstaltung_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_Veranstaltungen"
    ADD CONSTRAINT "tbl_Veranstaltungen_fk_FreiwilligenVeranstaltung_fkey" FOREIGN KEY ("fk_FreiwilligenVeranstaltung") REFERENCES "tbl_FreiwilligenVeranstaltungen"("pk_FreiwilligenVeranstaltung");


--
-- Name: tbl_Veranstaltungsteilnehmer tbl_Veranstaltungsteilnehmer_fk_Veranstaltung_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_Veranstaltungsteilnehmer"
    ADD CONSTRAINT "tbl_Veranstaltungsteilnehmer_fk_Veranstaltung_fkey" FOREIGN KEY ("fk_Veranstaltung") REFERENCES "tbl_Veranstaltungen"("pk_Veranstaltung");


--
-- Name: tbl_VerfahrensHistory tbl_VerfahrensHistory_fk_FamilienRolle_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_VerfahrensHistory"
    ADD CONSTRAINT "tbl_VerfahrensHistory_fk_FamilienRolle_fkey" FOREIGN KEY ("fk_FamilienRolle") REFERENCES "tbl_FamilienRollen"("pk_FamilienRolle");


--
-- Name: tbl_VerfahrensHistory tbl_VerfahrensHistory_fk_Hauptperson_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_VerfahrensHistory"
    ADD CONSTRAINT "tbl_VerfahrensHistory_fk_Hauptperson_fkey" FOREIGN KEY ("fk_Hauptperson") REFERENCES "tbl_Hauptpersonen"("pk_Hauptperson");


--
-- Name: tbl_VerfahrensHistory tbl_VerfahrensHistory_fk_VerfahrensStatus_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kaspi
--

ALTER TABLE ONLY "tbl_VerfahrensHistory"
    ADD CONSTRAINT "tbl_VerfahrensHistory_fk_VerfahrensStatus_fkey" FOREIGN KEY ("fk_VerfahrensStatus") REFERENCES "tbl_Verfahrensstati"("pk_Verfahrensstatus");


--
-- PostgreSQL database dump complete
--

