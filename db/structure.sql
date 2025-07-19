SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA public;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_stat_statements IS 'track planning and execution statistics of all SQL statements executed';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: boundary_set_general_election_party_performances; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.boundary_set_general_election_party_performances (
    id integer NOT NULL,
    constituency_contested_count integer NOT NULL,
    constituency_won_count integer NOT NULL,
    cumulative_vote_count integer NOT NULL,
    general_election_id integer NOT NULL,
    political_party_id integer NOT NULL,
    boundary_set_id integer NOT NULL
);


--
-- Name: boundary_set_general_election_party_performances_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.boundary_set_general_election_party_performances_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: boundary_set_general_election_party_performances_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.boundary_set_general_election_party_performances_id_seq OWNED BY public.boundary_set_general_election_party_performances.id;


--
-- Name: boundary_set_legislation_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.boundary_set_legislation_items (
    id integer NOT NULL,
    boundary_set_id integer NOT NULL,
    legislation_item_id integer NOT NULL
);


--
-- Name: boundary_set_legislation_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.boundary_set_legislation_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: boundary_set_legislation_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.boundary_set_legislation_items_id_seq OWNED BY public.boundary_set_legislation_items.id;


--
-- Name: boundary_sets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.boundary_sets (
    id integer NOT NULL,
    start_on date,
    end_on date,
    country_id integer NOT NULL
);


--
-- Name: boundary_sets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.boundary_sets_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: boundary_sets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.boundary_sets_id_seq OWNED BY public.boundary_sets.id;


--
-- Name: candidacies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.candidacies (
    id integer NOT NULL,
    candidate_given_name character varying(255),
    candidate_family_name character varying(255),
    candidate_is_sitting_mp boolean DEFAULT false,
    candidate_is_former_mp boolean DEFAULT false,
    is_standing_as_commons_speaker boolean DEFAULT false,
    is_standing_as_independent boolean DEFAULT false,
    is_notional boolean DEFAULT false,
    result_position integer,
    is_winning_candidacy boolean DEFAULT false,
    vote_count integer,
    vote_share real,
    vote_change real,
    candidate_gender_id integer,
    election_id integer NOT NULL,
    member_id integer,
    democracy_club_person_identifier integer
);


--
-- Name: candidacies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.candidacies_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: candidacies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.candidacies_id_seq OWNED BY public.candidacies.id;


--
-- Name: certifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.certifications (
    id integer NOT NULL,
    candidacy_id integer NOT NULL,
    political_party_id integer NOT NULL,
    adjunct_to_certification_id integer
);


--
-- Name: certifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.certifications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: certifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.certifications_id_seq OWNED BY public.certifications.id;


--
-- Name: commons_library_dashboard_countries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.commons_library_dashboard_countries (
    id integer NOT NULL,
    commons_library_dashboard_id integer NOT NULL,
    country_id integer NOT NULL
);


--
-- Name: commons_library_dashboard_countries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.commons_library_dashboard_countries_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: commons_library_dashboard_countries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.commons_library_dashboard_countries_id_seq OWNED BY public.commons_library_dashboard_countries.id;


--
-- Name: commons_library_dashboards; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.commons_library_dashboards (
    id integer NOT NULL,
    title character varying(255) NOT NULL,
    url character varying(255) NOT NULL
);


--
-- Name: commons_library_dashboards_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.commons_library_dashboards_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: commons_library_dashboards_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.commons_library_dashboards_id_seq OWNED BY public.commons_library_dashboards.id;


--
-- Name: constituency_area_overlaps; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.constituency_area_overlaps (
    id integer NOT NULL,
    from_constituency_residential real NOT NULL,
    to_constituency_residential real NOT NULL,
    from_constituency_geographical real NOT NULL,
    to_constituency_geographical real NOT NULL,
    from_constituency_population real NOT NULL,
    to_constituency_population real NOT NULL,
    from_constituency_area_id integer NOT NULL,
    to_constituency_area_id integer NOT NULL,
    formed_from_whole_of boolean DEFAULT false,
    forms_whole_of boolean DEFAULT false
);


--
-- Name: constituency_area_overlaps_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.constituency_area_overlaps_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: constituency_area_overlaps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.constituency_area_overlaps_id_seq OWNED BY public.constituency_area_overlaps.id;


--
-- Name: constituency_area_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.constituency_area_types (
    id integer NOT NULL,
    area_type character varying(20) NOT NULL
);


--
-- Name: constituency_area_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.constituency_area_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: constituency_area_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.constituency_area_types_id_seq OWNED BY public.constituency_area_types.id;


--
-- Name: constituency_areas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.constituency_areas (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    geographic_code character varying(255) NOT NULL,
    english_region_id integer,
    country_id integer NOT NULL,
    constituency_area_type_id integer NOT NULL,
    boundary_set_id integer,
    mnis_id integer,
    is_geographic_code_issued_by_ons boolean DEFAULT true
);


--
-- Name: constituency_areas_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.constituency_areas_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: constituency_areas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.constituency_areas_id_seq OWNED BY public.constituency_areas.id;


--
-- Name: constituency_group_set_legislation_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.constituency_group_set_legislation_items (
    id integer NOT NULL,
    constituency_group_set_id integer NOT NULL,
    legislation_item_id integer NOT NULL
);


--
-- Name: constituency_group_set_legislation_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.constituency_group_set_legislation_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: constituency_group_set_legislation_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.constituency_group_set_legislation_items_id_seq OWNED BY public.constituency_group_set_legislation_items.id;


--
-- Name: constituency_group_sets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.constituency_group_sets (
    id integer NOT NULL,
    start_on date,
    end_on date,
    country_id integer NOT NULL
);


--
-- Name: constituency_group_sets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.constituency_group_sets_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: constituency_group_sets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.constituency_group_sets_id_seq OWNED BY public.constituency_group_sets.id;


--
-- Name: constituency_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.constituency_groups (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    constituency_area_id integer,
    constituency_group_set_id integer
);


--
-- Name: constituency_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.constituency_groups_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: constituency_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.constituency_groups_id_seq OWNED BY public.constituency_groups.id;


--
-- Name: countries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.countries (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    geographic_code character varying(255),
    ons_linked boolean DEFAULT false,
    parent_country_id integer
);


--
-- Name: countries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.countries_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: countries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.countries_id_seq OWNED BY public.countries.id;


--
-- Name: country_general_election_party_performances; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.country_general_election_party_performances (
    id integer NOT NULL,
    constituency_contested_count integer NOT NULL,
    constituency_won_count integer NOT NULL,
    cumulative_vote_count integer NOT NULL,
    general_election_id integer NOT NULL,
    political_party_id integer NOT NULL,
    country_id integer NOT NULL
);


--
-- Name: country_general_election_party_performances_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.country_general_election_party_performances_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: country_general_election_party_performances_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.country_general_election_party_performances_id_seq OWNED BY public.country_general_election_party_performances.id;


--
-- Name: elections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.elections (
    id integer NOT NULL,
    polling_on date NOT NULL,
    is_notional boolean DEFAULT false,
    valid_vote_count integer,
    invalid_vote_count integer,
    majority integer,
    declaration_at timestamp without time zone,
    constituency_group_id integer NOT NULL,
    general_election_id integer,
    result_summary_id integer,
    electorate_id integer,
    parliament_period_id integer NOT NULL,
    writ_issued_on date
);


--
-- Name: elections_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.elections_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: elections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.elections_id_seq OWNED BY public.elections.id;


--
-- Name: electorates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.electorates (
    id integer NOT NULL,
    population_count integer NOT NULL,
    constituency_group_id integer NOT NULL
);


--
-- Name: electorates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.electorates_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: electorates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.electorates_id_seq OWNED BY public.electorates.id;


--
-- Name: enablings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.enablings (
    id integer NOT NULL,
    enabling_legislation_id integer NOT NULL,
    enabled_legislation_id integer NOT NULL
);


--
-- Name: enablings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.enablings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: enablings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.enablings_id_seq OWNED BY public.enablings.id;


--
-- Name: english_region_general_election_party_performances; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.english_region_general_election_party_performances (
    id integer NOT NULL,
    constituency_contested_count integer NOT NULL,
    constituency_won_count integer NOT NULL,
    cumulative_vote_count integer NOT NULL,
    general_election_id integer NOT NULL,
    political_party_id integer NOT NULL,
    english_region_id integer NOT NULL
);


--
-- Name: english_region_general_election_party_performances_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.english_region_general_election_party_performances_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: english_region_general_election_party_performances_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.english_region_general_election_party_performances_id_seq OWNED BY public.english_region_general_election_party_performances.id;


--
-- Name: english_regions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.english_regions (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    geographic_code character varying(255) NOT NULL,
    country_id integer NOT NULL
);


--
-- Name: english_regions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.english_regions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: english_regions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.english_regions_id_seq OWNED BY public.english_regions.id;


--
-- Name: genders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.genders (
    id integer NOT NULL,
    gender character varying(20) NOT NULL
);


--
-- Name: genders_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.genders_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: genders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.genders_id_seq OWNED BY public.genders.id;


--
-- Name: general_election_in_boundary_sets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.general_election_in_boundary_sets (
    id integer NOT NULL,
    ordinality integer NOT NULL,
    general_election_id integer NOT NULL,
    boundary_set_id integer NOT NULL
);


--
-- Name: general_election_in_boundary_sets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.general_election_in_boundary_sets_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: general_election_in_boundary_sets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.general_election_in_boundary_sets_id_seq OWNED BY public.general_election_in_boundary_sets.id;


--
-- Name: general_election_party_performances; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.general_election_party_performances (
    id integer NOT NULL,
    constituency_contested_count integer NOT NULL,
    constituency_won_count integer NOT NULL,
    cumulative_vote_count integer NOT NULL,
    cumulative_valid_vote_count integer NOT NULL,
    general_election_id integer NOT NULL,
    political_party_id integer NOT NULL
);


--
-- Name: general_election_party_performances_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.general_election_party_performances_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: general_election_party_performances_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.general_election_party_performances_id_seq OWNED BY public.general_election_party_performances.id;


--
-- Name: general_elections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.general_elections (
    id integer NOT NULL,
    polling_on date NOT NULL,
    is_notional boolean DEFAULT false,
    commons_library_briefing_url character varying(255),
    valid_vote_count integer,
    invalid_vote_count integer,
    electorate_population_count integer,
    parliament_period_id integer NOT NULL
);


--
-- Name: general_elections_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.general_elections_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: general_elections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.general_elections_id_seq OWNED BY public.general_elections.id;


--
-- Name: legislation_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.legislation_items (
    id integer NOT NULL,
    title character varying(255) NOT NULL,
    uri character varying(255),
    url_key character varying(20) NOT NULL,
    made_on date,
    royal_assent_on date,
    statute_book_on date NOT NULL,
    legislation_type_id integer NOT NULL
);


--
-- Name: legislation_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.legislation_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: legislation_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.legislation_items_id_seq OWNED BY public.legislation_items.id;


--
-- Name: legislation_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.legislation_types (
    id integer NOT NULL,
    label character varying(255) NOT NULL,
    abbreviation character varying(10) NOT NULL
);


--
-- Name: legislation_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.legislation_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: legislation_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.legislation_types_id_seq OWNED BY public.legislation_types.id;


--
-- Name: maiden_speeches; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.maiden_speeches (
    id integer NOT NULL,
    made_on date NOT NULL,
    session_number integer NOT NULL,
    hansard_reference character varying(255) NOT NULL,
    hansard_url character varying(255) NOT NULL,
    member_id integer NOT NULL,
    constituency_group_id integer NOT NULL,
    parliament_period_id integer NOT NULL
);


--
-- Name: maiden_speeches_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.maiden_speeches_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: maiden_speeches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.maiden_speeches_id_seq OWNED BY public.maiden_speeches.id;


--
-- Name: members; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.members (
    id integer NOT NULL,
    given_name character varying(255) NOT NULL,
    family_name character varying(255) NOT NULL,
    mnis_id integer NOT NULL
);


--
-- Name: members_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.members_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: members_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.members_id_seq OWNED BY public.members.id;


--
-- Name: parliament_periods; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.parliament_periods (
    id integer NOT NULL,
    number integer NOT NULL,
    summoned_on date NOT NULL,
    state_opening_on date,
    dissolved_on date,
    wikidata_id character varying(20),
    london_gazette character varying(30),
    commons_library_briefing_by_election_briefing_url character varying(255)
);


--
-- Name: parliament_periods_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.parliament_periods_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: parliament_periods_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.parliament_periods_id_seq OWNED BY public.parliament_periods.id;


--
-- Name: political_parties; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.political_parties (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    abbreviation character varying(255) NOT NULL,
    mnis_id integer,
    has_been_parliamentary_party boolean DEFAULT false,
    disclaimer character varying(500)
);


--
-- Name: political_parties_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.political_parties_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: political_parties_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.political_parties_id_seq OWNED BY public.political_parties.id;


--
-- Name: political_party_registrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.political_party_registrations (
    id integer NOT NULL,
    electoral_commission_id character varying(20) NOT NULL,
    start_on date NOT NULL,
    end_on date,
    political_party_name_last_updated_on date,
    political_party_id integer NOT NULL,
    country_id integer NOT NULL
);


--
-- Name: political_party_registrations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.political_party_registrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: political_party_registrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.political_party_registrations_id_seq OWNED BY public.political_party_registrations.id;


--
-- Name: result_summaries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.result_summaries (
    id integer NOT NULL,
    short_summary character varying(50) NOT NULL,
    summary character varying(255),
    is_from_commons_speaker boolean DEFAULT false,
    is_from_independent boolean DEFAULT false,
    is_to_commons_speaker boolean DEFAULT false,
    is_to_independent boolean DEFAULT false,
    from_political_party_id integer,
    to_political_party_id integer
);


--
-- Name: result_summaries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.result_summaries_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: result_summaries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.result_summaries_id_seq OWNED BY public.result_summaries.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: boundary_set_general_election_party_performances id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.boundary_set_general_election_party_performances ALTER COLUMN id SET DEFAULT nextval('public.boundary_set_general_election_party_performances_id_seq'::regclass);


--
-- Name: boundary_set_legislation_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.boundary_set_legislation_items ALTER COLUMN id SET DEFAULT nextval('public.boundary_set_legislation_items_id_seq'::regclass);


--
-- Name: boundary_sets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.boundary_sets ALTER COLUMN id SET DEFAULT nextval('public.boundary_sets_id_seq'::regclass);


--
-- Name: candidacies id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.candidacies ALTER COLUMN id SET DEFAULT nextval('public.candidacies_id_seq'::regclass);


--
-- Name: certifications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.certifications ALTER COLUMN id SET DEFAULT nextval('public.certifications_id_seq'::regclass);


--
-- Name: commons_library_dashboard_countries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.commons_library_dashboard_countries ALTER COLUMN id SET DEFAULT nextval('public.commons_library_dashboard_countries_id_seq'::regclass);


--
-- Name: commons_library_dashboards id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.commons_library_dashboards ALTER COLUMN id SET DEFAULT nextval('public.commons_library_dashboards_id_seq'::regclass);


--
-- Name: constituency_area_overlaps id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.constituency_area_overlaps ALTER COLUMN id SET DEFAULT nextval('public.constituency_area_overlaps_id_seq'::regclass);


--
-- Name: constituency_area_types id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.constituency_area_types ALTER COLUMN id SET DEFAULT nextval('public.constituency_area_types_id_seq'::regclass);


--
-- Name: constituency_areas id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.constituency_areas ALTER COLUMN id SET DEFAULT nextval('public.constituency_areas_id_seq'::regclass);


--
-- Name: constituency_group_set_legislation_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.constituency_group_set_legislation_items ALTER COLUMN id SET DEFAULT nextval('public.constituency_group_set_legislation_items_id_seq'::regclass);


--
-- Name: constituency_group_sets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.constituency_group_sets ALTER COLUMN id SET DEFAULT nextval('public.constituency_group_sets_id_seq'::regclass);


--
-- Name: constituency_groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.constituency_groups ALTER COLUMN id SET DEFAULT nextval('public.constituency_groups_id_seq'::regclass);


--
-- Name: countries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.countries ALTER COLUMN id SET DEFAULT nextval('public.countries_id_seq'::regclass);


--
-- Name: country_general_election_party_performances id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.country_general_election_party_performances ALTER COLUMN id SET DEFAULT nextval('public.country_general_election_party_performances_id_seq'::regclass);


--
-- Name: elections id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.elections ALTER COLUMN id SET DEFAULT nextval('public.elections_id_seq'::regclass);


--
-- Name: electorates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.electorates ALTER COLUMN id SET DEFAULT nextval('public.electorates_id_seq'::regclass);


--
-- Name: enablings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.enablings ALTER COLUMN id SET DEFAULT nextval('public.enablings_id_seq'::regclass);


--
-- Name: english_region_general_election_party_performances id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.english_region_general_election_party_performances ALTER COLUMN id SET DEFAULT nextval('public.english_region_general_election_party_performances_id_seq'::regclass);


--
-- Name: english_regions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.english_regions ALTER COLUMN id SET DEFAULT nextval('public.english_regions_id_seq'::regclass);


--
-- Name: genders id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.genders ALTER COLUMN id SET DEFAULT nextval('public.genders_id_seq'::regclass);


--
-- Name: general_election_in_boundary_sets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.general_election_in_boundary_sets ALTER COLUMN id SET DEFAULT nextval('public.general_election_in_boundary_sets_id_seq'::regclass);


--
-- Name: general_election_party_performances id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.general_election_party_performances ALTER COLUMN id SET DEFAULT nextval('public.general_election_party_performances_id_seq'::regclass);


--
-- Name: general_elections id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.general_elections ALTER COLUMN id SET DEFAULT nextval('public.general_elections_id_seq'::regclass);


--
-- Name: legislation_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legislation_items ALTER COLUMN id SET DEFAULT nextval('public.legislation_items_id_seq'::regclass);


--
-- Name: legislation_types id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legislation_types ALTER COLUMN id SET DEFAULT nextval('public.legislation_types_id_seq'::regclass);


--
-- Name: maiden_speeches id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maiden_speeches ALTER COLUMN id SET DEFAULT nextval('public.maiden_speeches_id_seq'::regclass);


--
-- Name: members id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.members ALTER COLUMN id SET DEFAULT nextval('public.members_id_seq'::regclass);


--
-- Name: parliament_periods id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parliament_periods ALTER COLUMN id SET DEFAULT nextval('public.parliament_periods_id_seq'::regclass);


--
-- Name: political_parties id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.political_parties ALTER COLUMN id SET DEFAULT nextval('public.political_parties_id_seq'::regclass);


--
-- Name: political_party_registrations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.political_party_registrations ALTER COLUMN id SET DEFAULT nextval('public.political_party_registrations_id_seq'::regclass);


--
-- Name: result_summaries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.result_summaries ALTER COLUMN id SET DEFAULT nextval('public.result_summaries_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: boundary_set_general_election_party_performances boundary_set_general_election_party_performances_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.boundary_set_general_election_party_performances
    ADD CONSTRAINT boundary_set_general_election_party_performances_pkey PRIMARY KEY (id);


--
-- Name: boundary_set_legislation_items boundary_set_legislation_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.boundary_set_legislation_items
    ADD CONSTRAINT boundary_set_legislation_items_pkey PRIMARY KEY (id);


--
-- Name: boundary_sets boundary_sets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.boundary_sets
    ADD CONSTRAINT boundary_sets_pkey PRIMARY KEY (id);


--
-- Name: candidacies candidacies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.candidacies
    ADD CONSTRAINT candidacies_pkey PRIMARY KEY (id);


--
-- Name: certifications certifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.certifications
    ADD CONSTRAINT certifications_pkey PRIMARY KEY (id);


--
-- Name: commons_library_dashboard_countries commons_library_dashboard_countries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.commons_library_dashboard_countries
    ADD CONSTRAINT commons_library_dashboard_countries_pkey PRIMARY KEY (id);


--
-- Name: commons_library_dashboards commons_library_dashboards_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.commons_library_dashboards
    ADD CONSTRAINT commons_library_dashboards_pkey PRIMARY KEY (id);


--
-- Name: constituency_area_overlaps constituency_area_overlaps_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.constituency_area_overlaps
    ADD CONSTRAINT constituency_area_overlaps_pkey PRIMARY KEY (id);


--
-- Name: constituency_area_types constituency_area_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.constituency_area_types
    ADD CONSTRAINT constituency_area_types_pkey PRIMARY KEY (id);


--
-- Name: constituency_areas constituency_areas_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.constituency_areas
    ADD CONSTRAINT constituency_areas_pkey PRIMARY KEY (id);


--
-- Name: constituency_group_set_legislation_items constituency_group_set_legislation_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.constituency_group_set_legislation_items
    ADD CONSTRAINT constituency_group_set_legislation_items_pkey PRIMARY KEY (id);


--
-- Name: constituency_group_sets constituency_group_sets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.constituency_group_sets
    ADD CONSTRAINT constituency_group_sets_pkey PRIMARY KEY (id);


--
-- Name: constituency_groups constituency_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.constituency_groups
    ADD CONSTRAINT constituency_groups_pkey PRIMARY KEY (id);


--
-- Name: countries countries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.countries
    ADD CONSTRAINT countries_pkey PRIMARY KEY (id);


--
-- Name: country_general_election_party_performances country_general_election_party_performances_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.country_general_election_party_performances
    ADD CONSTRAINT country_general_election_party_performances_pkey PRIMARY KEY (id);


--
-- Name: elections elections_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.elections
    ADD CONSTRAINT elections_pkey PRIMARY KEY (id);


--
-- Name: electorates electorates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.electorates
    ADD CONSTRAINT electorates_pkey PRIMARY KEY (id);


--
-- Name: enablings enablings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.enablings
    ADD CONSTRAINT enablings_pkey PRIMARY KEY (id);


--
-- Name: english_region_general_election_party_performances english_region_general_election_party_performances_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.english_region_general_election_party_performances
    ADD CONSTRAINT english_region_general_election_party_performances_pkey PRIMARY KEY (id);


--
-- Name: english_regions english_regions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.english_regions
    ADD CONSTRAINT english_regions_pkey PRIMARY KEY (id);


--
-- Name: genders genders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.genders
    ADD CONSTRAINT genders_pkey PRIMARY KEY (id);


--
-- Name: general_election_in_boundary_sets general_election_in_boundary_sets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.general_election_in_boundary_sets
    ADD CONSTRAINT general_election_in_boundary_sets_pkey PRIMARY KEY (id);


--
-- Name: general_election_party_performances general_election_party_performances_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.general_election_party_performances
    ADD CONSTRAINT general_election_party_performances_pkey PRIMARY KEY (id);


--
-- Name: general_elections general_elections_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.general_elections
    ADD CONSTRAINT general_elections_pkey PRIMARY KEY (id);


--
-- Name: legislation_items legislation_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legislation_items
    ADD CONSTRAINT legislation_items_pkey PRIMARY KEY (id);


--
-- Name: legislation_types legislation_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legislation_types
    ADD CONSTRAINT legislation_types_pkey PRIMARY KEY (id);


--
-- Name: maiden_speeches maiden_speeches_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maiden_speeches
    ADD CONSTRAINT maiden_speeches_pkey PRIMARY KEY (id);


--
-- Name: members members_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.members
    ADD CONSTRAINT members_pkey PRIMARY KEY (id);


--
-- Name: parliament_periods parliament_periods_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parliament_periods
    ADD CONSTRAINT parliament_periods_pkey PRIMARY KEY (id);


--
-- Name: political_parties political_parties_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.political_parties
    ADD CONSTRAINT political_parties_pkey PRIMARY KEY (id);


--
-- Name: political_party_registrations political_party_registrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.political_party_registrations
    ADD CONSTRAINT political_party_registrations_pkey PRIMARY KEY (id);


--
-- Name: result_summaries result_summaries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.result_summaries
    ADD CONSTRAINT result_summaries_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: index_boundary_set_legislation_items_on_boundary_set_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_boundary_set_legislation_items_on_boundary_set_id ON public.boundary_set_legislation_items USING btree (boundary_set_id);


--
-- Name: index_boundary_set_legislation_items_on_legislation_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_boundary_set_legislation_items_on_legislation_item_id ON public.boundary_set_legislation_items USING btree (legislation_item_id);


--
-- Name: index_boundary_sets_on_country_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_boundary_sets_on_country_id ON public.boundary_sets USING btree (country_id);


--
-- Name: index_candidacies_on_candidate_gender_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_candidacies_on_candidate_gender_id ON public.candidacies USING btree (candidate_gender_id);


--
-- Name: index_candidacies_on_election_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_candidacies_on_election_id ON public.candidacies USING btree (election_id);


--
-- Name: index_candidacies_on_member_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_candidacies_on_member_id ON public.candidacies USING btree (member_id);


--
-- Name: index_certifications_on_candidacy_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_certifications_on_candidacy_id ON public.certifications USING btree (candidacy_id);


--
-- Name: index_certifications_on_political_party_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_certifications_on_political_party_id ON public.certifications USING btree (political_party_id);


--
-- Name: index_constituency_areas_on_boundary_set_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_constituency_areas_on_boundary_set_id ON public.constituency_areas USING btree (boundary_set_id);


--
-- Name: index_constituency_areas_on_constituency_area_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_constituency_areas_on_constituency_area_type_id ON public.constituency_areas USING btree (constituency_area_type_id);


--
-- Name: index_constituency_areas_on_country_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_constituency_areas_on_country_id ON public.constituency_areas USING btree (country_id);


--
-- Name: index_constituency_areas_on_english_region_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_constituency_areas_on_english_region_id ON public.constituency_areas USING btree (english_region_id);


--
-- Name: index_constituency_group_sets_on_country_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_constituency_group_sets_on_country_id ON public.constituency_group_sets USING btree (country_id);


--
-- Name: index_constituency_groups_on_constituency_area_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_constituency_groups_on_constituency_area_id ON public.constituency_groups USING btree (constituency_area_id);


--
-- Name: index_constituency_groups_on_constituency_group_set_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_constituency_groups_on_constituency_group_set_id ON public.constituency_groups USING btree (constituency_group_set_id);


--
-- Name: index_country_general_election_party_performances_on_country_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_country_general_election_party_performances_on_country_id ON public.country_general_election_party_performances USING btree (country_id);


--
-- Name: index_elections_on_constituency_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_elections_on_constituency_group_id ON public.elections USING btree (constituency_group_id);


--
-- Name: index_elections_on_electorate_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_elections_on_electorate_id ON public.elections USING btree (electorate_id);


--
-- Name: index_elections_on_general_election_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_elections_on_general_election_id ON public.elections USING btree (general_election_id);


--
-- Name: index_elections_on_parliament_period_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_elections_on_parliament_period_id ON public.elections USING btree (parliament_period_id);


--
-- Name: index_elections_on_result_summary_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_elections_on_result_summary_id ON public.elections USING btree (result_summary_id);


--
-- Name: index_electorates_on_constituency_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_electorates_on_constituency_group_id ON public.electorates USING btree (constituency_group_id);


--
-- Name: index_english_regions_on_country_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_english_regions_on_country_id ON public.english_regions USING btree (country_id);


--
-- Name: index_general_election_in_boundary_sets_on_boundary_set_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_general_election_in_boundary_sets_on_boundary_set_id ON public.general_election_in_boundary_sets USING btree (boundary_set_id);


--
-- Name: index_general_elections_on_parliament_period_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_general_elections_on_parliament_period_id ON public.general_elections USING btree (parliament_period_id);


--
-- Name: index_legislation_items_on_legislation_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_legislation_items_on_legislation_type_id ON public.legislation_items USING btree (legislation_type_id);


--
-- Name: certifications fk_adjunct_to_certification; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.certifications
    ADD CONSTRAINT fk_adjunct_to_certification FOREIGN KEY (adjunct_to_certification_id) REFERENCES public.certifications(id);


--
-- Name: constituency_areas fk_boundary_set; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.constituency_areas
    ADD CONSTRAINT fk_boundary_set FOREIGN KEY (boundary_set_id) REFERENCES public.boundary_sets(id);


--
-- Name: boundary_set_general_election_party_performances fk_boundary_set; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.boundary_set_general_election_party_performances
    ADD CONSTRAINT fk_boundary_set FOREIGN KEY (boundary_set_id) REFERENCES public.boundary_sets(id);


--
-- Name: boundary_set_legislation_items fk_boundary_set; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.boundary_set_legislation_items
    ADD CONSTRAINT fk_boundary_set FOREIGN KEY (boundary_set_id) REFERENCES public.boundary_sets(id);


--
-- Name: certifications fk_candidacy; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.certifications
    ADD CONSTRAINT fk_candidacy FOREIGN KEY (candidacy_id) REFERENCES public.candidacies(id);


--
-- Name: candidacies fk_candidate_gender; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.candidacies
    ADD CONSTRAINT fk_candidate_gender FOREIGN KEY (candidate_gender_id) REFERENCES public.genders(id);


--
-- Name: commons_library_dashboard_countries fk_commons_library_dashboard; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.commons_library_dashboard_countries
    ADD CONSTRAINT fk_commons_library_dashboard FOREIGN KEY (commons_library_dashboard_id) REFERENCES public.commons_library_dashboards(id);


--
-- Name: constituency_groups fk_constituency_area; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.constituency_groups
    ADD CONSTRAINT fk_constituency_area FOREIGN KEY (constituency_area_id) REFERENCES public.constituency_areas(id);


--
-- Name: constituency_areas fk_constituency_area_type; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.constituency_areas
    ADD CONSTRAINT fk_constituency_area_type FOREIGN KEY (constituency_area_type_id) REFERENCES public.constituency_area_types(id);


--
-- Name: electorates fk_constituency_group; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.electorates
    ADD CONSTRAINT fk_constituency_group FOREIGN KEY (constituency_group_id) REFERENCES public.constituency_groups(id);


--
-- Name: elections fk_constituency_group; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.elections
    ADD CONSTRAINT fk_constituency_group FOREIGN KEY (constituency_group_id) REFERENCES public.constituency_groups(id);


--
-- Name: maiden_speeches fk_constituency_group; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maiden_speeches
    ADD CONSTRAINT fk_constituency_group FOREIGN KEY (constituency_group_id) REFERENCES public.constituency_groups(id);


--
-- Name: constituency_groups fk_constituency_group_set; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.constituency_groups
    ADD CONSTRAINT fk_constituency_group_set FOREIGN KEY (constituency_group_set_id) REFERENCES public.constituency_group_sets(id);


--
-- Name: constituency_group_set_legislation_items fk_constituency_group_set; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.constituency_group_set_legislation_items
    ADD CONSTRAINT fk_constituency_group_set FOREIGN KEY (constituency_group_set_id) REFERENCES public.constituency_group_sets(id);


--
-- Name: commons_library_dashboard_countries fk_country; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.commons_library_dashboard_countries
    ADD CONSTRAINT fk_country FOREIGN KEY (country_id) REFERENCES public.countries(id);


--
-- Name: english_regions fk_country; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.english_regions
    ADD CONSTRAINT fk_country FOREIGN KEY (country_id) REFERENCES public.countries(id);


--
-- Name: boundary_sets fk_country; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.boundary_sets
    ADD CONSTRAINT fk_country FOREIGN KEY (country_id) REFERENCES public.countries(id);


--
-- Name: constituency_group_sets fk_country; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.constituency_group_sets
    ADD CONSTRAINT fk_country FOREIGN KEY (country_id) REFERENCES public.countries(id);


--
-- Name: constituency_areas fk_country; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.constituency_areas
    ADD CONSTRAINT fk_country FOREIGN KEY (country_id) REFERENCES public.countries(id);


--
-- Name: country_general_election_party_performances fk_country; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.country_general_election_party_performances
    ADD CONSTRAINT fk_country FOREIGN KEY (country_id) REFERENCES public.countries(id);


--
-- Name: political_party_registrations fk_country; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.political_party_registrations
    ADD CONSTRAINT fk_country FOREIGN KEY (country_id) REFERENCES public.countries(id);


--
-- Name: candidacies fk_election; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.candidacies
    ADD CONSTRAINT fk_election FOREIGN KEY (election_id) REFERENCES public.elections(id);


--
-- Name: elections fk_electorate; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.elections
    ADD CONSTRAINT fk_electorate FOREIGN KEY (electorate_id) REFERENCES public.electorates(id);


--
-- Name: enablings fk_enabled_legislation; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.enablings
    ADD CONSTRAINT fk_enabled_legislation FOREIGN KEY (enabled_legislation_id) REFERENCES public.legislation_items(id);


--
-- Name: enablings fk_enabling_legislation; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.enablings
    ADD CONSTRAINT fk_enabling_legislation FOREIGN KEY (enabling_legislation_id) REFERENCES public.legislation_items(id);


--
-- Name: constituency_areas fk_english_region; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.constituency_areas
    ADD CONSTRAINT fk_english_region FOREIGN KEY (english_region_id) REFERENCES public.english_regions(id);


--
-- Name: english_region_general_election_party_performances fk_english_region; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.english_region_general_election_party_performances
    ADD CONSTRAINT fk_english_region FOREIGN KEY (english_region_id) REFERENCES public.english_regions(id);


--
-- Name: constituency_area_overlaps fk_from_constituency_area; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.constituency_area_overlaps
    ADD CONSTRAINT fk_from_constituency_area FOREIGN KEY (from_constituency_area_id) REFERENCES public.constituency_areas(id);


--
-- Name: result_summaries fk_from_political_party; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.result_summaries
    ADD CONSTRAINT fk_from_political_party FOREIGN KEY (from_political_party_id) REFERENCES public.political_parties(id);


--
-- Name: elections fk_general_election; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.elections
    ADD CONSTRAINT fk_general_election FOREIGN KEY (general_election_id) REFERENCES public.general_elections(id);


--
-- Name: general_election_party_performances fk_general_election; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.general_election_party_performances
    ADD CONSTRAINT fk_general_election FOREIGN KEY (general_election_id) REFERENCES public.general_elections(id);


--
-- Name: boundary_set_general_election_party_performances fk_general_election; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.boundary_set_general_election_party_performances
    ADD CONSTRAINT fk_general_election FOREIGN KEY (general_election_id) REFERENCES public.general_elections(id);


--
-- Name: english_region_general_election_party_performances fk_general_election; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.english_region_general_election_party_performances
    ADD CONSTRAINT fk_general_election FOREIGN KEY (general_election_id) REFERENCES public.general_elections(id);


--
-- Name: country_general_election_party_performances fk_general_election; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.country_general_election_party_performances
    ADD CONSTRAINT fk_general_election FOREIGN KEY (general_election_id) REFERENCES public.general_elections(id);


--
-- Name: boundary_set_legislation_items fk_legislation_item; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.boundary_set_legislation_items
    ADD CONSTRAINT fk_legislation_item FOREIGN KEY (legislation_item_id) REFERENCES public.legislation_items(id);


--
-- Name: constituency_group_set_legislation_items fk_legislation_item; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.constituency_group_set_legislation_items
    ADD CONSTRAINT fk_legislation_item FOREIGN KEY (legislation_item_id) REFERENCES public.legislation_items(id);


--
-- Name: legislation_items fk_legislation_type; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legislation_items
    ADD CONSTRAINT fk_legislation_type FOREIGN KEY (legislation_type_id) REFERENCES public.legislation_types(id);


--
-- Name: candidacies fk_member; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.candidacies
    ADD CONSTRAINT fk_member FOREIGN KEY (member_id) REFERENCES public.members(id);


--
-- Name: maiden_speeches fk_member; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maiden_speeches
    ADD CONSTRAINT fk_member FOREIGN KEY (member_id) REFERENCES public.members(id);


--
-- Name: general_election_in_boundary_sets fk_parent_boundary_set; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.general_election_in_boundary_sets
    ADD CONSTRAINT fk_parent_boundary_set FOREIGN KEY (boundary_set_id) REFERENCES public.boundary_sets(id);


--
-- Name: countries fk_parent_country; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.countries
    ADD CONSTRAINT fk_parent_country FOREIGN KEY (parent_country_id) REFERENCES public.countries(id);


--
-- Name: general_election_in_boundary_sets fk_parent_general_election; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.general_election_in_boundary_sets
    ADD CONSTRAINT fk_parent_general_election FOREIGN KEY (general_election_id) REFERENCES public.general_elections(id);


--
-- Name: general_elections fk_parliament_period; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.general_elections
    ADD CONSTRAINT fk_parliament_period FOREIGN KEY (parliament_period_id) REFERENCES public.parliament_periods(id);


--
-- Name: elections fk_parliament_period; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.elections
    ADD CONSTRAINT fk_parliament_period FOREIGN KEY (parliament_period_id) REFERENCES public.parliament_periods(id);


--
-- Name: maiden_speeches fk_parliament_period; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maiden_speeches
    ADD CONSTRAINT fk_parliament_period FOREIGN KEY (parliament_period_id) REFERENCES public.parliament_periods(id);


--
-- Name: political_party_registrations fk_political_parties; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.political_party_registrations
    ADD CONSTRAINT fk_political_parties FOREIGN KEY (political_party_id) REFERENCES public.political_parties(id);


--
-- Name: certifications fk_political_party; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.certifications
    ADD CONSTRAINT fk_political_party FOREIGN KEY (political_party_id) REFERENCES public.political_parties(id);


--
-- Name: general_election_party_performances fk_political_party; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.general_election_party_performances
    ADD CONSTRAINT fk_political_party FOREIGN KEY (political_party_id) REFERENCES public.political_parties(id);


--
-- Name: boundary_set_general_election_party_performances fk_political_party; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.boundary_set_general_election_party_performances
    ADD CONSTRAINT fk_political_party FOREIGN KEY (political_party_id) REFERENCES public.political_parties(id);


--
-- Name: english_region_general_election_party_performances fk_political_party; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.english_region_general_election_party_performances
    ADD CONSTRAINT fk_political_party FOREIGN KEY (political_party_id) REFERENCES public.political_parties(id);


--
-- Name: country_general_election_party_performances fk_political_party; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.country_general_election_party_performances
    ADD CONSTRAINT fk_political_party FOREIGN KEY (political_party_id) REFERENCES public.political_parties(id);


--
-- Name: general_election_party_performances fk_rails_04362dd9c7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.general_election_party_performances
    ADD CONSTRAINT fk_rails_04362dd9c7 FOREIGN KEY (general_election_id) REFERENCES public.general_elections(id) ON DELETE CASCADE;


--
-- Name: elections fk_rails_5df3ee16cb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.elections
    ADD CONSTRAINT fk_rails_5df3ee16cb FOREIGN KEY (general_election_id) REFERENCES public.general_elections(id) ON DELETE CASCADE;


--
-- Name: english_region_general_election_party_performances fk_rails_5f22c935f7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.english_region_general_election_party_performances
    ADD CONSTRAINT fk_rails_5f22c935f7 FOREIGN KEY (general_election_id) REFERENCES public.general_elections(id) ON DELETE CASCADE;


--
-- Name: general_election_in_boundary_sets fk_rails_6909cacca3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.general_election_in_boundary_sets
    ADD CONSTRAINT fk_rails_6909cacca3 FOREIGN KEY (general_election_id) REFERENCES public.general_elections(id) ON DELETE CASCADE;


--
-- Name: boundary_set_general_election_party_performances fk_rails_7b4a6c8811; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.boundary_set_general_election_party_performances
    ADD CONSTRAINT fk_rails_7b4a6c8811 FOREIGN KEY (general_election_id) REFERENCES public.general_elections(id) ON DELETE CASCADE;


--
-- Name: candidacies fk_rails_83a7e565e2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.candidacies
    ADD CONSTRAINT fk_rails_83a7e565e2 FOREIGN KEY (election_id) REFERENCES public.elections(id) ON DELETE CASCADE;


--
-- Name: country_general_election_party_performances fk_rails_c00ed8a882; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.country_general_election_party_performances
    ADD CONSTRAINT fk_rails_c00ed8a882 FOREIGN KEY (general_election_id) REFERENCES public.general_elections(id) ON DELETE CASCADE;


--
-- Name: certifications fk_rails_e2d166b33e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.certifications
    ADD CONSTRAINT fk_rails_e2d166b33e FOREIGN KEY (candidacy_id) REFERENCES public.candidacies(id) ON DELETE CASCADE;


--
-- Name: elections fk_result_summary; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.elections
    ADD CONSTRAINT fk_result_summary FOREIGN KEY (result_summary_id) REFERENCES public.result_summaries(id);


--
-- Name: constituency_area_overlaps fk_to_constituency_area; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.constituency_area_overlaps
    ADD CONSTRAINT fk_to_constituency_area FOREIGN KEY (to_constituency_area_id) REFERENCES public.constituency_areas(id);


--
-- Name: result_summaries fk_to_political_party; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.result_summaries
    ADD CONSTRAINT fk_to_political_party FOREIGN KEY (to_political_party_id) REFERENCES public.political_parties(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20250318124410');

