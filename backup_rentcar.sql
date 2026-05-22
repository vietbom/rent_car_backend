--
-- PostgreSQL database dump
--

\restrict yAo8ztlvqxT7UX0PBIRxBpN1909ZE2HB0iuCSPpKpreaiQbGgU7jwE74F1vCNnB

-- Dumped from database version 14.20 (Ubuntu 14.20-0ubuntu0.22.04.1)
-- Dumped by pg_dump version 14.20 (Ubuntu 14.20-0ubuntu0.22.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: BookingStatus; Type: TYPE; Schema: public; Owner: ducviet
--

CREATE TYPE public."BookingStatus" AS ENUM (
    'pending',
    'confirmed',
    'cancelled',
    'rented',
    'completed',
    'overdue',
    'returned'
);


ALTER TYPE public."BookingStatus" OWNER TO ducviet;

--
-- Name: PaymentStatus; Type: TYPE; Schema: public; Owner: ducviet
--

CREATE TYPE public."PaymentStatus" AS ENUM (
    'pending',
    'successful',
    'failed'
);


ALTER TYPE public."PaymentStatus" OWNER TO ducviet;

--
-- Name: PaymentType; Type: TYPE; Schema: public; Owner: ducviet
--

CREATE TYPE public."PaymentType" AS ENUM (
    'BOOKING_DEPOSIT',
    'RENTAL_DEPOSIT',
    'RENTAL_FEE',
    'SURCHARGE',
    'REFUND'
);


ALTER TYPE public."PaymentType" OWNER TO ducviet;

--
-- Name: Role; Type: TYPE; Schema: public; Owner: ducviet
--

CREATE TYPE public."Role" AS ENUM (
    'customer',
    'admin'
);


ALTER TYPE public."Role" OWNER TO ducviet;

--
-- Name: VehicleStatus; Type: TYPE; Schema: public; Owner: ducviet
--

CREATE TYPE public."VehicleStatus" AS ENUM (
    'available',
    'under_maintenance',
    'rented',
    'decommissioned'
);


ALTER TYPE public."VehicleStatus" OWNER TO ducviet;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: bookings; Type: TABLE; Schema: public; Owner: ducviet
--

CREATE TABLE public.bookings (
    id integer NOT NULL,
    user_id uuid,
    vehicle_id integer,
    start_datetime timestamp without time zone NOT NULL,
    end_datetime timestamp without time zone NOT NULL,
    pickup_location_id integer,
    dropoff_location_id integer,
    total_price numeric(10,2),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    confirmed_at timestamp(6) without time zone,
    confirmed_by uuid,
    actual_end_datetime timestamp(6) without time zone,
    actual_start_datetime timestamp(6) without time zone,
    base_price numeric(10,2) NOT NULL,
    booking_deposit_paid numeric(10,2) DEFAULT 0,
    cleaning_fee numeric(10,2) DEFAULT 0,
    compensation_fee numeric(10,2) DEFAULT 0,
    discount_amount numeric(10,2) DEFAULT 0,
    extension_fee numeric(10,2) DEFAULT 0,
    late_fee numeric(10,2) DEFAULT 0,
    original_end_datetime timestamp(6) without time zone,
    other_surcharges numeric(10,2) DEFAULT 0,
    rental_deposit_paid numeric(12,2) DEFAULT 0,
    rental_package_id integer NOT NULL,
    total_surcharges numeric(10,2) DEFAULT 0,
    status public."BookingStatus" DEFAULT 'pending'::public."BookingStatus"
);


ALTER TABLE public.bookings OWNER TO ducviet;

--
-- Name: bookings_id_seq; Type: SEQUENCE; Schema: public; Owner: ducviet
--

CREATE SEQUENCE public.bookings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.bookings_id_seq OWNER TO ducviet;

--
-- Name: bookings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ducviet
--

ALTER SEQUENCE public.bookings_id_seq OWNED BY public.bookings.id;


--
-- Name: invoices; Type: TABLE; Schema: public; Owner: ducviet
--

CREATE TABLE public.invoices (
    id integer NOT NULL,
    invoice_number character varying(50) NOT NULL,
    booking_id integer NOT NULL,
    payment_id integer,
    user_id uuid,
    tax_rate numeric(5,2) DEFAULT 0.08,
    total_amount numeric(10,2),
    issued_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    issued_by uuid,
    notes text,
    pdf_url text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    base_amount numeric(10,2) NOT NULL,
    surcharges_amount numeric(10,2) DEFAULT 0,
    tax_amount numeric(10,2)
);


ALTER TABLE public.invoices OWNER TO ducviet;

--
-- Name: invoices_id_seq; Type: SEQUENCE; Schema: public; Owner: ducviet
--

CREATE SEQUENCE public.invoices_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.invoices_id_seq OWNER TO ducviet;

--
-- Name: invoices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ducviet
--

ALTER SEQUENCE public.invoices_id_seq OWNED BY public.invoices.id;


--
-- Name: locations; Type: TABLE; Schema: public; Owner: ducviet
--

CREATE TABLE public.locations (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    address text,
    lat numeric(9,6),
    lng numeric(9,6)
);


ALTER TABLE public.locations OWNER TO ducviet;

--
-- Name: location_id_seq; Type: SEQUENCE; Schema: public; Owner: ducviet
--

CREATE SEQUENCE public.location_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.location_id_seq OWNER TO ducviet;

--
-- Name: location_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ducviet
--

ALTER SEQUENCE public.location_id_seq OWNED BY public.locations.id;


--
-- Name: logs; Type: TABLE; Schema: public; Owner: ducviet
--

CREATE TABLE public.logs (
    id integer NOT NULL,
    user_id uuid,
    action character varying(50),
    object_type character varying(50),
    object_id character varying(50),
    meta jsonb,
    "timestamp" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.logs OWNER TO ducviet;

--
-- Name: logs_id_seq; Type: SEQUENCE; Schema: public; Owner: ducviet
--

CREATE SEQUENCE public.logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.logs_id_seq OWNER TO ducviet;

--
-- Name: logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ducviet
--

ALTER SEQUENCE public.logs_id_seq OWNED BY public.logs.id;


--
-- Name: payments; Type: TABLE; Schema: public; Owner: ducviet
--

CREATE TABLE public.payments (
    id integer NOT NULL,
    booking_id integer,
    provider character varying(50),
    provider_payment_id character varying(100),
    amount numeric(12,2),
    currency character varying(10) DEFAULT 'VND'::character varying,
    paid_at timestamp without time zone,
    user_id uuid,
    status public."PaymentStatus" DEFAULT 'pending'::public."PaymentStatus",
    type public."PaymentType"
);


ALTER TABLE public.payments OWNER TO ducviet;

--
-- Name: payments_id_seq; Type: SEQUENCE; Schema: public; Owner: ducviet
--

CREATE SEQUENCE public.payments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.payments_id_seq OWNER TO ducviet;

--
-- Name: payments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ducviet
--

ALTER SEQUENCE public.payments_id_seq OWNED BY public.payments.id;


--
-- Name: refresh_tokens; Type: TABLE; Schema: public; Owner: ducviet
--

CREATE TABLE public.refresh_tokens (
    id integer NOT NULL,
    user_id uuid,
    token_hash text NOT NULL,
    expires_at timestamp without time zone,
    revoked boolean DEFAULT false
);


ALTER TABLE public.refresh_tokens OWNER TO ducviet;

--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: ducviet
--

CREATE SEQUENCE public.refresh_tokens_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.refresh_tokens_id_seq OWNER TO ducviet;

--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ducviet
--

ALTER SEQUENCE public.refresh_tokens_id_seq OWNED BY public.refresh_tokens.id;


--
-- Name: rental_packages; Type: TABLE; Schema: public; Owner: ducviet
--

CREATE TABLE public.rental_packages (
    id integer NOT NULL,
    vehicle_type_id integer NOT NULL,
    duration_hours integer NOT NULL,
    price numeric(10,2) NOT NULL
);


ALTER TABLE public.rental_packages OWNER TO ducviet;

--
-- Name: rental_packages_id_seq; Type: SEQUENCE; Schema: public; Owner: ducviet
--

CREATE SEQUENCE public.rental_packages_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.rental_packages_id_seq OWNER TO ducviet;

--
-- Name: rental_packages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ducviet
--

ALTER SEQUENCE public.rental_packages_id_seq OWNED BY public.rental_packages.id;


--
-- Name: reviews; Type: TABLE; Schema: public; Owner: ducviet
--

CREATE TABLE public.reviews (
    id integer NOT NULL,
    booking_id integer,
    user_id uuid,
    rating integer,
    comment text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT reviews_rating_check CHECK (((rating >= 1) AND (rating <= 5)))
);


ALTER TABLE public.reviews OWNER TO ducviet;

--
-- Name: reviews_id_seq; Type: SEQUENCE; Schema: public; Owner: ducviet
--

CREATE SEQUENCE public.reviews_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.reviews_id_seq OWNER TO ducviet;

--
-- Name: reviews_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ducviet
--

ALTER SEQUENCE public.reviews_id_seq OWNED BY public.reviews.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: ducviet
--

CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    email character varying(255) NOT NULL,
    password_hash text NOT NULL,
    name character varying(100),
    phone character varying(15),
    is_verified boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    role public."Role" DEFAULT 'customer'::public."Role"
);


ALTER TABLE public.users OWNER TO ducviet;

--
-- Name: vehicle_types; Type: TABLE; Schema: public; Owner: ducviet
--

CREATE TABLE public.vehicle_types (
    id integer NOT NULL,
    name text NOT NULL,
    seats integer NOT NULL,
    deposit_amount numeric(12,2) NOT NULL
);


ALTER TABLE public.vehicle_types OWNER TO ducviet;

--
-- Name: vehicle_types_id_seq; Type: SEQUENCE; Schema: public; Owner: ducviet
--

CREATE SEQUENCE public.vehicle_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.vehicle_types_id_seq OWNER TO ducviet;

--
-- Name: vehicle_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ducviet
--

ALTER SEQUENCE public.vehicle_types_id_seq OWNED BY public.vehicle_types.id;


--
-- Name: vehicles; Type: TABLE; Schema: public; Owner: ducviet
--

CREATE TABLE public.vehicles (
    id integer NOT NULL,
    title character varying(100) NOT NULL,
    brand character varying(50),
    model character varying(50),
    year integer,
    plate_number character varying(20) NOT NULL,
    location_id integer,
    images text[],
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    vehicle_type_id integer NOT NULL,
    status public."VehicleStatus" DEFAULT 'available'::public."VehicleStatus"
);


ALTER TABLE public.vehicles OWNER TO ducviet;

--
-- Name: vehicles_id_seq; Type: SEQUENCE; Schema: public; Owner: ducviet
--

CREATE SEQUENCE public.vehicles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.vehicles_id_seq OWNER TO ducviet;

--
-- Name: vehicles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ducviet
--

ALTER SEQUENCE public.vehicles_id_seq OWNED BY public.vehicles.id;


--
-- Name: bookings id; Type: DEFAULT; Schema: public; Owner: ducviet
--

ALTER TABLE ONLY public.bookings ALTER COLUMN id SET DEFAULT nextval('public.bookings_id_seq'::regclass);


--
-- Name: invoices id; Type: DEFAULT; Schema: public; Owner: ducviet
--

ALTER TABLE ONLY public.invoices ALTER COLUMN id SET DEFAULT nextval('public.invoices_id_seq'::regclass);


--
-- Name: locations id; Type: DEFAULT; Schema: public; Owner: ducviet
--

ALTER TABLE ONLY public.locations ALTER COLUMN id SET DEFAULT nextval('public.location_id_seq'::regclass);


--
-- Name: logs id; Type: DEFAULT; Schema: public; Owner: ducviet
--

ALTER TABLE ONLY public.logs ALTER COLUMN id SET DEFAULT nextval('public.logs_id_seq'::regclass);


--
-- Name: payments id; Type: DEFAULT; Schema: public; Owner: ducviet
--

ALTER TABLE ONLY public.payments ALTER COLUMN id SET DEFAULT nextval('public.payments_id_seq'::regclass);


--
-- Name: refresh_tokens id; Type: DEFAULT; Schema: public; Owner: ducviet
--

ALTER TABLE ONLY public.refresh_tokens ALTER COLUMN id SET DEFAULT nextval('public.refresh_tokens_id_seq'::regclass);


--
-- Name: rental_packages id; Type: DEFAULT; Schema: public; Owner: ducviet
--

ALTER TABLE ONLY public.rental_packages ALTER COLUMN id SET DEFAULT nextval('public.rental_packages_id_seq'::regclass);


--
-- Name: reviews id; Type: DEFAULT; Schema: public; Owner: ducviet
--

ALTER TABLE ONLY public.reviews ALTER COLUMN id SET DEFAULT nextval('public.reviews_id_seq'::regclass);


--
-- Name: vehicle_types id; Type: DEFAULT; Schema: public; Owner: ducviet
--

ALTER TABLE ONLY public.vehicle_types ALTER COLUMN id SET DEFAULT nextval('public.vehicle_types_id_seq'::regclass);


--
-- Name: vehicles id; Type: DEFAULT; Schema: public; Owner: ducviet
--

ALTER TABLE ONLY public.vehicles ALTER COLUMN id SET DEFAULT nextval('public.vehicles_id_seq'::regclass);


--
-- Data for Name: bookings; Type: TABLE DATA; Schema: public; Owner: ducviet
--

COPY public.bookings (id, user_id, vehicle_id, start_datetime, end_datetime, pickup_location_id, dropoff_location_id, total_price, created_at, updated_at, confirmed_at, confirmed_by, actual_end_datetime, actual_start_datetime, base_price, booking_deposit_paid, cleaning_fee, compensation_fee, discount_amount, extension_fee, late_fee, original_end_datetime, other_surcharges, rental_deposit_paid, rental_package_id, total_surcharges, status) FROM stdin;
23	9520c430-201b-4444-98eb-bd848e07bac4	13	2025-11-22 22:30:00	2025-11-23 10:30:00	2	2	1000000.00	2025-11-21 17:37:58.127	2025-11-21 17:38:43.4	2025-11-21 17:38:00.643	\N	2025-11-21 17:38:43.4	2025-11-21 17:38:28.2	800000.00	500000.00	200000.00	0.00	0.00	0.00	0.00	\N	0.00	20000000.00	17	200000.00	completed
16	9520c430-201b-4444-98eb-bd848e07bac4	13	2025-11-23 06:00:00	2025-11-23 14:00:00	2	2	550000.00	2025-11-21 14:59:35.652	2025-11-21 15:02:39.715	2025-11-21 14:59:39.845	\N	2025-11-21 15:02:39.715	2025-11-21 15:02:11.543	550000.00	500000.00	0.00	0.00	0.00	0.00	0.00	\N	0.00	20000000.00	18	0.00	completed
38	9520c430-201b-4444-98eb-bd848e07bac4	6	2025-11-25 15:00:00	2025-11-26 03:00:00	2	2	450000.00	2025-11-25 07:51:54.323	2025-11-25 07:51:54.323	\N	\N	\N	\N	450000.00	0.00	0.00	0.00	0.00	0.00	0.00	\N	0.00	0.00	2	0.00	cancelled
17	9520c430-201b-4444-98eb-bd848e07bac4	13	2025-11-22 07:04:00	2025-11-22 15:04:00	2	2	550000.00	2025-11-21 15:04:34.654	2025-11-21 15:04:59.177	2025-11-21 15:04:41.95	\N	2025-11-21 15:04:59.177	2025-11-21 15:04:53.951	550000.00	500000.00	0.00	0.00	0.00	0.00	0.00	\N	0.00	20000000.00	18	0.00	completed
24	9520c430-201b-4444-98eb-bd848e07bac4	11	2025-11-22 01:00:00	2025-11-23 01:00:00	2	2	700000.00	2025-11-21 17:53:39.866	2025-11-21 17:53:55.19	2025-11-21 17:53:43.141	\N	2025-11-21 17:53:55.19	2025-11-21 17:53:49.283	700000.00	500000.00	0.00	0.00	0.00	0.00	0.00	\N	0.00	8000000.00	13	0.00	completed
18	9520c430-201b-4444-98eb-bd848e07bac4	13	2025-11-22 08:00:00	2025-11-22 16:00:00	2	2	550000.00	2025-11-21 16:06:29.715	2025-11-21 16:07:08.01	2025-11-21 16:06:45.359	\N	2025-11-21 16:07:08.01	2025-11-21 16:06:57.284	550000.00	500000.00	0.00	0.00	0.00	0.00	0.00	\N	0.00	20000000.00	18	0.00	completed
32	9520c430-201b-4444-98eb-bd848e07bac4	10	2025-11-21 23:30:00	2025-11-22 23:30:00	1	1	1800000.00	2025-11-21 19:22:22.067	2025-11-21 19:23:00.303	2025-11-21 19:22:24.229	\N	2025-11-21 19:23:00.303	2025-11-21 19:22:37.273	1500000.00	500000.00	100000.00	0.00	0.00	0.00	0.00	\N	200000.00	25000000.00	15	300000.00	completed
19	9520c430-201b-4444-98eb-bd848e07bac4	12	2025-11-22 08:30:00	2025-11-23 08:30:00	1	2	900000.00	2025-11-21 16:24:27.291	2025-11-21 16:24:59.165	2025-11-21 16:24:30.828	\N	2025-11-21 16:24:59.165	2025-11-21 16:24:54.605	900000.00	500000.00	0.00	0.00	0.00	0.00	0.00	\N	0.00	12000000.00	14	0.00	completed
25	9520c430-201b-4444-98eb-bd848e07bac4	11	2025-11-22 11:30:00	2025-11-23 11:30:00	1	1	750000.00	2025-11-21 18:22:22.667	2025-11-21 18:22:53.351	2025-11-21 18:22:24.881	\N	2025-11-21 18:22:53.351	2025-11-21 18:22:39.837	700000.00	500000.00	50000.00	0.00	0.00	0.00	0.00	\N	0.00	8000000.00	13	50000.00	completed
20	9520c430-201b-4444-98eb-bd848e07bac4	13	2025-11-22 03:30:00	2025-11-22 11:30:00	1	1	550000.00	2025-11-21 16:36:34.642	2025-11-21 16:37:08.919	2025-11-21 16:36:39.149	\N	2025-11-21 16:37:08.919	2025-11-21 16:36:56.531	550000.00	500000.00	0.00	0.00	0.00	0.00	0.00	\N	0.00	20000000.00	18	0.00	completed
21	9520c430-201b-4444-98eb-bd848e07bac4	12	2025-11-23 09:30:00	2025-11-24 09:30:00	2	2	900000.00	2025-11-21 17:14:19.654	2025-11-21 17:17:33.912	2025-11-21 17:14:23.43	\N	2025-11-21 17:17:33.912	2025-11-21 17:14:31.698	900000.00	500000.00	0.00	0.00	0.00	0.00	0.00	\N	0.00	12000000.00	14	0.00	completed
49	9520c430-201b-4444-98eb-bd848e07bac4	13	2025-12-23 22:30:00	2025-12-24 06:30:00	1	1	1100000.00	2025-12-23 08:32:13.997	2025-12-30 06:08:13.893	2025-12-23 08:32:17.409	\N	2025-12-30 06:08:40.822	2025-12-30 06:08:10.159	550000.00	500000.00	0.00	0.00	0.00	0.00	550000.00	\N	0.00	20000000.00	18	550000.00	completed
26	9520c430-201b-4444-98eb-bd848e07bac4	11	2025-11-22 23:28:00	2025-11-23 23:28:00	2	1	1000000.00	2025-11-21 18:28:13.662	2025-11-21 18:28:54.137	2025-11-21 18:28:16.694	\N	2025-11-21 18:28:54.137	2025-11-21 18:28:31.397	700000.00	500000.00	100000.00	0.00	0.00	0.00	0.00	\N	200000.00	8000000.00	13	300000.00	completed
22	9520c430-201b-4444-98eb-bd848e07bac4	11	2025-11-22 11:30:00	2025-11-23 11:30:00	2	2	700000.00	2025-11-21 17:26:59.077	2025-11-21 17:34:51.937	2025-11-21 17:27:02.708	\N	2025-11-21 17:34:51.937	2025-11-21 17:27:16.057	700000.00	500000.00	0.00	0.00	0.00	0.00	0.00	\N	0.00	8000000.00	13	0.00	returned
33	9520c430-201b-4444-98eb-bd848e07bac4	10	2025-11-22 12:30:00	2025-11-23 13:30:00	1	2	1700000.00	2025-11-22 08:17:28.153	2025-11-22 08:18:23.424	2025-11-22 08:17:39.84	\N	2025-11-22 08:18:23.424	2025-11-22 08:18:02.748	1500000.00	500000.00	200000.00	0.00	0.00	0.00	0.00	\N	0.00	25000000.00	15	200000.00	completed
39	9520c430-201b-4444-98eb-bd848e07bac4	4	2025-11-25 23:00:00	2025-11-26 07:00:00	1	1	920000.00	2025-11-25 09:06:39.099	2025-11-25 09:07:37.478	2025-11-25 09:06:40.976	\N	2025-11-26 09:07:00	2025-11-25 09:06:58.091	600000.00	500000.00	200000.00	0.00	0.00	0.00	120000.00	\N	0.00	12000000.00	10	320000.00	completed
27	9520c430-201b-4444-98eb-bd848e07bac4	11	2025-11-23 23:32:00	2025-11-24 23:32:00	2	1	700000.00	2025-11-21 18:32:14.074	2025-11-21 18:32:31.475	2025-11-21 18:32:16.371	\N	2025-11-21 18:32:31.475	2025-11-21 18:32:26.403	700000.00	500000.00	0.00	0.00	0.00	0.00	0.00	\N	0.00	8000000.00	13	0.00	completed
34	9520c430-201b-4444-98eb-bd848e07bac4	9	2025-11-22 23:30:00	2025-11-23 13:00:00	2	1	650000.00	2025-11-22 08:27:47.129	2025-11-22 08:35:20.799	2025-11-22 08:27:58.083	\N	2025-11-22 08:35:20.799	2025-11-22 08:28:12.797	600000.00	500000.00	50000.00	0.00	0.00	0.00	0.00	\N	0.00	15000000.00	5	50000.00	completed
28	9520c430-201b-4444-98eb-bd848e07bac4	13	2025-11-22 22:38:00	2025-11-23 06:38:00	1	1	900000.00	2025-11-21 18:38:42.945	2025-11-21 18:41:31.028	2025-11-21 18:38:45.149	\N	2025-11-21 18:41:31.028	2025-11-21 18:39:00.499	550000.00	500000.00	150000.00	0.00	0.00	0.00	0.00	\N	200000.00	20000000.00	18	350000.00	completed
29	9520c430-201b-4444-98eb-bd848e07bac4	12	2025-11-22 23:30:00	2025-11-23 23:30:00	2	2	1150000.00	2025-11-21 18:46:23.319	2025-11-21 18:47:02.601	2025-11-21 18:46:26.132	\N	2025-11-21 18:47:02.601	2025-11-21 18:46:37.447	900000.00	500000.00	200000.00	0.00	0.00	0.00	0.00	\N	50000.00	12000000.00	14	250000.00	completed
43	5ebc8dee-6716-4f41-aada-be40329a2f08	3	2025-11-27 23:30:00	2025-11-28 11:30:00	1	1	950000.00	2025-11-27 04:20:40.933	2025-11-27 04:22:33.087	2025-11-27 04:20:49.726	\N	2025-11-27 04:22:35.728	2025-11-27 04:21:21.654	750000.00	500000.00	200000.00	0.00	0.00	0.00	0.00	\N	0.00	8000000.00	8	200000.00	completed
35	9520c430-201b-4444-98eb-bd848e07bac4	6	2025-11-23 11:36:00	2025-11-23 19:36:00	2	2	300000.00	2025-11-22 08:36:35.618	2025-11-22 08:40:24.795	2025-11-22 08:36:38.385	\N	2025-11-22 08:40:24.795	2025-11-22 08:40:17.913	300000.00	500000.00	0.00	0.00	0.00	0.00	0.00	\N	0.00	10000000.00	1	0.00	completed
30	9520c430-201b-4444-98eb-bd848e07bac4	10	2025-11-22 11:05:00	2025-11-23 11:05:00	1	1	1500000.00	2025-11-21 19:05:26.413	2025-11-21 19:05:49.76	2025-11-21 19:05:29.164	\N	2025-11-21 19:05:49.76	2025-11-21 19:05:45.118	1500000.00	500000.00	0.00	0.00	0.00	0.00	0.00	\N	0.00	25000000.00	15	0.00	completed
40	5ebc8dee-6716-4f41-aada-be40329a2f08	7	2025-11-27 23:30:00	2025-11-28 11:30:00	2	2	600000.00	2025-11-27 03:01:10.998	2025-11-27 03:08:28.44	2025-11-27 03:01:19.888	\N	2025-11-27 03:08:43.124	2025-11-27 03:01:49.988	600000.00	500000.00	0.00	0.00	0.00	0.00	0.00	\N	0.00	15000000.00	5	0.00	completed
31	9520c430-201b-4444-98eb-bd848e07bac4	9	2025-11-21 23:30:00	2025-11-22 11:30:00	2	1	900000.00	2025-11-21 19:13:29.351	2025-11-21 19:14:04.234	2025-11-21 19:13:31.834	\N	2025-11-21 19:14:04.234	2025-11-21 19:13:51.101	600000.00	500000.00	100000.00	0.00	0.00	0.00	0.00	\N	200000.00	15000000.00	5	300000.00	completed
36	9520c430-201b-4444-98eb-bd848e07bac4	6	2025-11-25 23:30:00	2025-11-26 11:30:00	1	1	450000.00	2025-11-25 06:30:37.114	2025-11-25 06:31:44.251	2025-11-25 06:30:41.844	\N	2025-11-26 12:30:00	2025-11-25 06:31:12.062	450000.00	500000.00	0.00	0.00	0.00	0.00	0.00	\N	0.00	10000000.00	2	0.00	completed
46	1b7dfc8a-519b-451a-9061-c35e0bdf32e2	3	2025-11-27 22:30:00	2025-11-28 06:30:00	1	1	800000.00	2025-11-27 14:58:32.518	2025-11-27 15:04:19.022	2025-11-27 14:59:17.594	\N	2025-11-28 07:30:00	2025-11-27 15:01:37.374	500000.00	500000.00	200000.00	0.00	0.00	0.00	0.00	\N	100000.00	8000000.00	7	300000.00	completed
37	9520c430-201b-4444-98eb-bd848e07bac4	11	2025-11-25 15:30:00	2025-11-26 15:30:00	2	2	900000.00	2025-11-25 07:38:08.96	2025-11-25 07:56:00.379	2025-11-25 07:38:11.163	\N	2025-11-25 07:56:08.495	2025-11-25 07:55:35.801	700000.00	500000.00	200000.00	0.00	0.00	0.00	0.00	\N	0.00	8000000.00	13	200000.00	completed
41	5ebc8dee-6716-4f41-aada-be40329a2f08	8	2025-11-28 05:30:00	2025-11-28 17:30:00	2	2	1100000.00	2025-11-27 03:26:28.195	2025-11-27 03:30:05.864	2025-11-27 03:26:40.398	\N	2025-11-28 00:30:00	2025-11-27 03:28:18.399	900000.00	500000.00	200000.00	0.00	0.00	0.00	0.00	\N	0.00	12000000.00	11	200000.00	completed
44	84f94b4f-fdf6-4898-80c4-7abcf7d5d100	6	2025-11-27 12:30:00	2025-11-28 00:30:00	2	2	650000.00	2025-11-27 04:42:31.123	2025-11-27 04:43:54.617	2025-11-27 04:42:38.637	\N	2025-11-28 00:30:00	2025-11-27 04:43:04.766	450000.00	500000.00	200000.00	0.00	0.00	0.00	0.00	\N	0.00	10000000.00	2	200000.00	completed
50	1b7dfc8a-519b-451a-9061-c35e0bdf32e2	13	2025-12-24 10:30:00	2025-12-24 22:30:00	1	1	800000.00	2025-12-23 08:33:18.938	2025-12-23 08:33:18.938	\N	\N	\N	\N	800000.00	0.00	0.00	0.00	0.00	0.00	0.00	\N	0.00	0.00	17	0.00	cancelled
42	5ebc8dee-6716-4f41-aada-be40329a2f08	11	2025-11-28 05:30:00	2025-11-29 05:30:00	2	2	700000.00	2025-11-27 03:49:58.737	2025-11-27 03:50:53.532	2025-11-27 03:50:03.287	\N	2025-11-27 03:51:07.927	2025-11-27 03:50:45.985	700000.00	500000.00	0.00	0.00	0.00	0.00	0.00	\N	0.00	8000000.00	13	0.00	completed
47	1b7dfc8a-519b-451a-9061-c35e0bdf32e2	6	2025-11-27 22:30:00	2025-11-28 22:30:00	2	2	700000.00	2025-11-27 15:06:19.084	2025-11-27 15:15:55.605	2025-11-27 15:06:21.751	\N	2025-11-28 11:00:00	2025-11-27 15:15:35.665	700000.00	500000.00	0.00	0.00	0.00	0.00	0.00	\N	0.00	10000000.00	3	0.00	completed
45	84f94b4f-fdf6-4898-80c4-7abcf7d5d100	9	2025-11-27 12:30:00	2025-11-28 00:30:00	2	2	800000.00	2025-11-27 04:47:33.455	2025-11-27 04:49:42.173	2025-11-27 04:47:43.953	\N	2025-11-28 00:30:00	2025-11-27 04:48:56.762	600000.00	500000.00	200000.00	0.00	0.00	0.00	0.00	\N	0.00	15000000.00	5	200000.00	completed
48	1b7dfc8a-519b-451a-9061-c35e0bdf32e2	12	2025-11-27 23:30:00	2025-11-28 23:30:00	2	2	900000.00	2025-11-27 15:16:31.153	2025-11-27 15:16:31.153	\N	\N	\N	\N	900000.00	0.00	0.00	0.00	0.00	0.00	0.00	\N	0.00	0.00	14	0.00	cancelled
52	84f94b4f-fdf6-4898-80c4-7abcf7d5d100	10	2025-12-23 12:40:00	2025-12-24 12:40:00	1	1	3000000.00	2025-12-23 08:37:41.572	2025-12-30 06:09:29.693	2025-12-23 08:37:44.321	\N	2025-12-30 06:09:56.395	2025-12-23 11:00:00.151	1500000.00	500000.00	0.00	0.00	0.00	0.00	1500000.00	\N	0.00	25000000.00	15	1500000.00	completed
53	5ebc8dee-6716-4f41-aada-be40329a2f08	13	2025-12-25 22:30:00	2025-12-26 10:30:00	1	1	800000.00	2025-12-23 09:28:42.936	2025-12-23 09:28:42.936	\N	\N	\N	\N	800000.00	0.00	0.00	0.00	0.00	0.00	0.00	\N	0.00	0.00	17	0.00	cancelled
54	5ebc8dee-6716-4f41-aada-be40329a2f08	12	2025-12-23 22:00:00	2025-12-24 22:00:00	2	2	900000.00	2025-12-23 10:18:01.722	2025-12-23 10:18:01.722	\N	\N	\N	\N	900000.00	0.00	0.00	0.00	0.00	0.00	0.00	\N	0.00	0.00	14	0.00	cancelled
51	1b7dfc8a-519b-451a-9061-c35e0bdf32e2	13	2025-12-24 10:30:00	2025-12-24 22:30:00	1	1	1600000.00	2025-12-23 08:34:42.352	2025-12-30 06:09:39.173	2025-12-23 08:34:44.553	\N	2025-12-30 06:10:06.13	2025-12-30 06:07:47.305	800000.00	500000.00	0.00	0.00	0.00	0.00	800000.00	\N	0.00	20000000.00	17	800000.00	completed
\.


--
-- Data for Name: invoices; Type: TABLE DATA; Schema: public; Owner: ducviet
--

COPY public.invoices (id, invoice_number, booking_id, payment_id, user_id, tax_rate, total_amount, issued_at, issued_by, notes, pdf_url, created_at, updated_at, base_amount, surcharges_amount, tax_amount) FROM stdin;
1	INV-RENT-1763737331562	16	2	9520c430-201b-4444-98eb-bd848e07bac4	0.08	594000.00	2025-11-21 15:02:11.601	8a33cd42-e569-47c1-8216-2a43103129cb	Thanh toán phần tiền thuê (bao gồm VAT) khi nhận xe	\N	2025-11-21 15:02:11.601	2025-11-21 15:02:11.601	550000.00	0.00	44000.00
2	INV-RENT-1763737493959	17	6	9520c430-201b-4444-98eb-bd848e07bac4	0.08	594000.00	2025-11-21 15:04:53.974	8a33cd42-e569-47c1-8216-2a43103129cb	Thanh toán phần tiền thuê (bao gồm VAT) khi nhận xe	\N	2025-11-21 15:04:53.974	2025-11-21 15:04:53.974	550000.00	0.00	44000.00
3	INV-RENT-1763741217296	18	10	9520c430-201b-4444-98eb-bd848e07bac4	0.08	594000.00	2025-11-21 16:06:57.318	8a33cd42-e569-47c1-8216-2a43103129cb	Thanh toán phần tiền thuê (bao gồm VAT) khi nhận xe	\N	2025-11-21 16:06:57.318	2025-11-21 16:06:57.318	550000.00	0.00	44000.00
4	INV-RENT-1763742294615	19	14	9520c430-201b-4444-98eb-bd848e07bac4	0.08	972000.00	2025-11-21 16:24:54.634	8a33cd42-e569-47c1-8216-2a43103129cb	Thanh toán phần tiền thuê (bao gồm VAT) khi nhận xe	\N	2025-11-21 16:24:54.634	2025-11-21 16:24:54.634	900000.00	0.00	72000.00
5	INV-RENT-1763743016538	20	18	9520c430-201b-4444-98eb-bd848e07bac4	0.08	594000.00	2025-11-21 16:36:56.553	8a33cd42-e569-47c1-8216-2a43103129cb	Thanh toán phần tiền thuê (bao gồm VAT) khi nhận xe	\N	2025-11-21 16:36:56.553	2025-11-21 16:36:56.553	550000.00	0.00	44000.00
6	INV-RENT-1763745271704	21	22	9520c430-201b-4444-98eb-bd848e07bac4	0.08	972000.00	2025-11-21 17:14:31.721	8a33cd42-e569-47c1-8216-2a43103129cb	Thanh toán phần tiền thuê (bao gồm VAT) khi nhận xe	\N	2025-11-21 17:14:31.721	2025-11-21 17:14:31.721	900000.00	0.00	72000.00
7	INV-RENT-1763746036072	22	26	9520c430-201b-4444-98eb-bd848e07bac4	0.08	756000.00	2025-11-21 17:27:16.104	8a33cd42-e569-47c1-8216-2a43103129cb	Thanh toán phần tiền thuê (bao gồm VAT) khi nhận xe	\N	2025-11-21 17:27:16.104	2025-11-21 17:27:16.104	700000.00	0.00	56000.00
8	INV-RENT-1763746708210	23	30	9520c430-201b-4444-98eb-bd848e07bac4	0.08	864000.00	2025-11-21 17:38:28.234	8a33cd42-e569-47c1-8216-2a43103129cb	Thanh toán phần tiền thuê (bao gồm VAT) khi nhận xe	\N	2025-11-21 17:38:28.234	2025-11-21 17:38:28.234	800000.00	0.00	64000.00
9	INV-RENT-1763747629291	24	34	9520c430-201b-4444-98eb-bd848e07bac4	0.08	756000.00	2025-11-21 17:53:49.316	8a33cd42-e569-47c1-8216-2a43103129cb	Thanh toán phần tiền thuê (bao gồm VAT) khi nhận xe	\N	2025-11-21 17:53:49.316	2025-11-21 17:53:49.316	700000.00	0.00	56000.00
10	INV-RENT-1763749359844	25	38	9520c430-201b-4444-98eb-bd848e07bac4	0.08	756000.00	2025-11-21 18:22:39.864	8a33cd42-e569-47c1-8216-2a43103129cb	Thanh toán phần tiền thuê (bao gồm VAT) khi nhận xe	invoices/INV-RENT-1763749359844.pdf	2025-11-21 18:22:39.864	2025-11-21 18:22:53.914	700000.00	0.00	56000.00
11	INV-RENT-1763749711425	26	42	9520c430-201b-4444-98eb-bd848e07bac4	0.08	756000.00	2025-11-21 18:28:31.453	8a33cd42-e569-47c1-8216-2a43103129cb	Thanh toán phần tiền thuê (bao gồm VAT) khi nhận xe	\N	2025-11-21 18:28:31.453	2025-11-21 18:28:31.453	700000.00	0.00	56000.00
12	INV-RENT-1763749946415	27	46	9520c430-201b-4444-98eb-bd848e07bac4	0.08	756000.00	2025-11-21 18:32:26.44	8a33cd42-e569-47c1-8216-2a43103129cb	Thanh toán phần tiền thuê (bao gồm VAT) khi nhận xe	\N	2025-11-21 18:32:26.44	2025-11-21 18:32:26.44	700000.00	0.00	56000.00
13	INV-RENT-1763750340518	28	50	9520c430-201b-4444-98eb-bd848e07bac4	0.08	594000.00	2025-11-21 18:39:00.57	8a33cd42-e569-47c1-8216-2a43103129cb	Thanh toán phần tiền thuê (bao gồm VAT) khi nhận xe	\N	2025-11-21 18:39:00.57	2025-11-21 18:39:00.57	550000.00	0.00	44000.00
14	INV-RENT-1763750797458	29	54	9520c430-201b-4444-98eb-bd848e07bac4	0.08	972000.00	2025-11-21 18:46:37.49	8a33cd42-e569-47c1-8216-2a43103129cb	Thanh toán phần tiền thuê (bao gồm VAT) khi nhận xe	\N	2025-11-21 18:46:37.49	2025-11-21 18:46:37.49	900000.00	0.00	72000.00
15	INV-RENT-1763751945127	30	58	9520c430-201b-4444-98eb-bd848e07bac4	0.08	1620000.00	2025-11-21 19:05:45.153	8a33cd42-e569-47c1-8216-2a43103129cb	Thanh toán phần tiền thuê (bao gồm VAT) khi nhận xe	invoices/INV-RENT-1763751945127.pdf	2025-11-21 19:05:45.153	2025-11-21 19:05:50.442	1500000.00	0.00	120000.00
16	INV-RENT-1763752431109	31	62	9520c430-201b-4444-98eb-bd848e07bac4	0.08	648000.00	2025-11-21 19:13:51.127	8a33cd42-e569-47c1-8216-2a43103129cb	Thanh toán phần tiền thuê (bao gồm VAT) khi nhận xe	\N	2025-11-21 19:13:51.127	2025-11-21 19:13:51.127	600000.00	0.00	48000.00
17	INV-RENT-1763752957280	32	66	9520c430-201b-4444-98eb-bd848e07bac4	0.08	1620000.00	2025-11-21 19:22:37.304	8a33cd42-e569-47c1-8216-2a43103129cb	Thanh toán phần tiền thuê (bao gồm VAT) khi nhận xe	invoices/INV-RENT-1763752957280.pdf	2025-11-21 19:22:37.304	2025-11-21 19:23:01.374	1500000.00	0.00	120000.00
18	INV-RENT-1763799482753	33	70	9520c430-201b-4444-98eb-bd848e07bac4	0.08	1682500.00	2025-11-22 08:18:02.775	8a33cd42-e569-47c1-8216-2a43103129cb	Thanh toán phần tiền thuê (bao gồm VAT) khi nhận xe	invoices/INV-RENT-1763799482753.pdf	2025-11-22 08:18:02.775	2025-11-22 08:18:24.193	1500000.00	62500.00	120000.00
19	INV-RENT-1763800092810	34	74	9520c430-201b-4444-98eb-bd848e07bac4	0.08	748000.00	2025-11-22 08:28:12.831	8a33cd42-e569-47c1-8216-2a43103129cb	Thanh toán phần tiền thuê (bao gồm VAT) khi nhận xe	invoices/INV-RENT-1763800092810.pdf	2025-11-22 08:28:12.831	2025-11-22 08:35:21.237	600000.00	100000.00	48000.00
20	INV-RENT-1763800817922	35	78	9520c430-201b-4444-98eb-bd848e07bac4	0.08	324000.00	2025-11-22 08:40:17.962	8a33cd42-e569-47c1-8216-2a43103129cb	Thanh toán phần tiền thuê (bao gồm VAT) khi nhận xe	invoices/INV-RENT-1763800817922.pdf	2025-11-22 08:40:17.962	2025-11-22 08:40:25.131	300000.00	0.00	24000.00
21	INV-RENT-1764052272074	36	82	9520c430-201b-4444-98eb-bd848e07bac4	0.08	486000.00	2025-11-25 06:31:12.095	8a33cd42-e569-47c1-8216-2a43103129cb	Thanh toán phần tiền thuê (bao gồm VAT) khi nhận xe	\N	2025-11-25 06:31:12.095	2025-11-25 06:31:12.095	450000.00	0.00	36000.00
22	INV-RENT-1764057335812	37	86	9520c430-201b-4444-98eb-bd848e07bac4	0.08	756000.00	2025-11-25 07:55:35.843	8a33cd42-e569-47c1-8216-2a43103129cb	Thanh toán phần tiền thuê (bao gồm VAT) khi nhận xe	\N	2025-11-25 07:55:35.843	2025-11-25 07:55:35.843	700000.00	0.00	56000.00
23	INV-RENT-1764061618099	39	90	9520c430-201b-4444-98eb-bd848e07bac4	0.08	648000.00	2025-11-25 09:06:58.123	8a33cd42-e569-47c1-8216-2a43103129cb	Thanh toán phần tiền thuê (bao gồm VAT) khi nhận xe	\N	2025-11-25 09:06:58.123	2025-11-25 09:06:58.123	600000.00	0.00	48000.00
24	INV-RENT-1764212510002	40	94	5ebc8dee-6716-4f41-aada-be40329a2f08	0.08	648000.00	2025-11-27 03:01:50.042	8a33cd42-e569-47c1-8216-2a43103129cb	Thanh toán phần tiền thuê (bao gồm VAT) khi nhận xe	\N	2025-11-27 03:01:50.042	2025-11-27 03:01:50.042	600000.00	0.00	48000.00
25	INV-RENT-1764214098415	41	98	5ebc8dee-6716-4f41-aada-be40329a2f08	0.08	972000.00	2025-11-27 03:28:18.448	8a33cd42-e569-47c1-8216-2a43103129cb	Thanh toán phần tiền thuê (bao gồm VAT) khi nhận xe	\N	2025-11-27 03:28:18.448	2025-11-27 03:28:18.448	900000.00	0.00	72000.00
26	INV-RENT-1764215445990	42	102	5ebc8dee-6716-4f41-aada-be40329a2f08	0.08	756000.00	2025-11-27 03:50:46.019	8a33cd42-e569-47c1-8216-2a43103129cb	Thanh toán phần tiền thuê (bao gồm VAT) khi nhận xe	\N	2025-11-27 03:50:46.019	2025-11-27 03:50:46.019	700000.00	0.00	56000.00
27	INV-RENT-1764217281668	43	106	5ebc8dee-6716-4f41-aada-be40329a2f08	0.08	810000.00	2025-11-27 04:21:21.699	8a33cd42-e569-47c1-8216-2a43103129cb	Thanh toán phần tiền thuê (bao gồm VAT) khi nhận xe	\N	2025-11-27 04:21:21.699	2025-11-27 04:21:21.699	750000.00	0.00	60000.00
28	INV-RENT-1764218584777	44	110	84f94b4f-fdf6-4898-80c4-7abcf7d5d100	0.08	486000.00	2025-11-27 04:43:04.807	8a33cd42-e569-47c1-8216-2a43103129cb	Thanh toán phần tiền thuê (bao gồm VAT) khi nhận xe	\N	2025-11-27 04:43:04.807	2025-11-27 04:43:04.807	450000.00	0.00	36000.00
29	INV-RENT-1764218936929	45	114	84f94b4f-fdf6-4898-80c4-7abcf7d5d100	0.08	648000.00	2025-11-27 04:48:56.982	8a33cd42-e569-47c1-8216-2a43103129cb	Thanh toán phần tiền thuê (bao gồm VAT) khi nhận xe	\N	2025-11-27 04:48:56.982	2025-11-27 04:48:56.982	600000.00	0.00	48000.00
30	INV-RENT-1764255697384	46	118	1b7dfc8a-519b-451a-9061-c35e0bdf32e2	0.08	540000.00	2025-11-27 15:01:37.466	8a33cd42-e569-47c1-8216-2a43103129cb	Thanh toán phần tiền thuê (bao gồm VAT) khi nhận xe	\N	2025-11-27 15:01:37.466	2025-11-27 15:01:37.466	500000.00	0.00	40000.00
31	INV-RENT-1764256535675	47	122	1b7dfc8a-519b-451a-9061-c35e0bdf32e2	0.08	756000.00	2025-11-27 15:15:35.696	8a33cd42-e569-47c1-8216-2a43103129cb	Thanh toán phần tiền thuê (bao gồm VAT) khi nhận xe	\N	2025-11-27 15:15:35.696	2025-11-27 15:15:35.696	700000.00	0.00	56000.00
32	INV-RENT-1766487600156	52	128	84f94b4f-fdf6-4898-80c4-7abcf7d5d100	0.08	1620000.00	2025-12-23 11:00:00.186	8a33cd42-e569-47c1-8216-2a43103129cb	Thanh toán phần tiền thuê (bao gồm VAT) khi nhận xe	\N	2025-12-23 11:00:00.186	2025-12-23 11:00:00.186	1500000.00	0.00	120000.00
33	INV-RENT-1767074867308	51	130	1b7dfc8a-519b-451a-9061-c35e0bdf32e2	0.08	864000.00	2025-12-30 06:07:47.325	8a33cd42-e569-47c1-8216-2a43103129cb	Thanh toán phần tiền thuê (bao gồm VAT) khi nhận xe	\N	2025-12-30 06:07:47.325	2025-12-30 06:07:47.325	800000.00	0.00	64000.00
34	INV-RENT-1767074890160	49	132	9520c430-201b-4444-98eb-bd848e07bac4	0.08	594000.00	2025-12-30 06:08:10.166	8a33cd42-e569-47c1-8216-2a43103129cb	Thanh toán phần tiền thuê (bao gồm VAT) khi nhận xe	\N	2025-12-30 06:08:10.166	2025-12-30 06:08:10.166	550000.00	0.00	44000.00
\.


--
-- Data for Name: locations; Type: TABLE DATA; Schema: public; Owner: ducviet
--

COPY public.locations (id, name, address, lat, lng) FROM stdin;
1	Văn Minh CORPORATION	Số 143 Trần Phú, Hà Đông	20.987819	105.806443
2	Nam Bình TOURIST	15 Phạm Hùng, Từ Liêm, Hà Nội	21.029049	105.779860
\.


--
-- Data for Name: logs; Type: TABLE DATA; Schema: public; Owner: ducviet
--

COPY public.logs (id, user_id, action, object_type, object_id, meta, "timestamp") FROM stdin;
1	8a33cd42-e569-47c1-8216-2a43103129cb	CONFIRM_PAYMENT	Payment	3	{"amount": 400000, "invoice": false}	2025-10-29 14:31:08.93
2	8a33cd42-e569-47c1-8216-2a43103129cb	CONFIRM_PAYMENT	Payment	7	{"amount": 2360000, "invoice": true}	2025-11-10 15:27:26.898
3	8a33cd42-e569-47c1-8216-2a43103129cb	CONFIRM_PAYMENT	Payment	5	{"amount": 1440000, "invoice": true}	2025-11-10 15:27:57.5
4	8a33cd42-e569-47c1-8216-2a43103129cb	CONFIRM_PAYMENT	Payment	9	{"amount": 2700000, "invoice": true}	2025-11-10 15:42:27.194
5	8a33cd42-e569-47c1-8216-2a43103129cb	CONFIRM_PAYMENT	Payment	18	{"amount": 1800000, "invoice": true}	2025-11-10 19:13:47.967
6	8a33cd42-e569-47c1-8216-2a43103129cb	CONFIRM_PAYMENT	Payment	20	{"amount": 530000, "invoice": true}	2025-11-10 19:23:37.268
7	8a33cd42-e569-47c1-8216-2a43103129cb	CONFIRM_PAYMENT	Payment	22	{"amount": 1860000, "invoice": true}	2025-11-11 09:41:07.697
8	8a33cd42-e569-47c1-8216-2a43103129cb	CONFIRM_PAYMENT	Payment	28	{"amount": 480000, "invoice": true}	2025-11-11 10:25:31.194
9	8a33cd42-e569-47c1-8216-2a43103129cb	CONFIRM_PAYMENT	Payment	27	{"amount": 720000, "invoice": true}	2025-11-11 10:25:44.41
10	8a33cd42-e569-47c1-8216-2a43103129cb	CONFIRM_PAYMENT	Payment	24	{"amount": 900000, "invoice": true}	2025-11-11 15:02:50.35
11	8a33cd42-e569-47c1-8216-2a43103129cb	CONFIRM_PAYMENT	Payment	31	{"amount": 1800000, "invoice": true}	2025-11-11 16:46:48.289
12	8a33cd42-e569-47c1-8216-2a43103129cb	CONFIRM_PAYMENT	Payment	33	{"amount": 720000, "invoice": true}	2025-11-11 17:50:37.581
13	8a33cd42-e569-47c1-8216-2a43103129cb	CONFIRM_PAYMENT	Payment	35	{"amount": 720000, "invoice": true}	2025-11-17 15:47:58.023
14	8a33cd42-e569-47c1-8216-2a43103129cb	CONFIRM_PAYMENT	Payment	37	{"amount": 720000, "invoice": true}	2025-11-17 16:22:35.301
15	8a33cd42-e569-47c1-8216-2a43103129cb	CONFIRM_PAYMENT	Payment	39	{"amount": 960000, "invoice": true}	2025-11-17 17:59:20.614
16	8a33cd42-e569-47c1-8216-2a43103129cb	CONFIRM_PAYMENT	Payment	41	{"amount": 900000, "invoice": true}	2025-11-17 18:13:34.178
17	8a33cd42-e569-47c1-8216-2a43103129cb	CONFIRM_PAYMENT	Payment	43	{"amount": 1440000, "invoice": true}	2025-11-17 18:18:43.318
18	\N	LOGIN_FAILURE	Auth	\N	{"email": "test@gmail.com", "message": "Password/User incorrect"}	2025-11-25 14:30:10.224
19	\N	LOGIN_FAILURE	Auth	\N	{"email": "test@gmail.com", "message": "Password/User incorrect"}	2025-11-25 14:30:18.326
20	\N	LOGIN_FAILURE	Auth	\N	{"email": "test@gmail.com", "message": "Password/User incorrect"}	2025-11-25 14:30:24.559
21	\N	LOGIN_FAILURE	Auth	\N	{"email": "test@gmail.com", "message": "Password/User incorrect"}	2025-11-25 14:30:29.537
22	\N	LOGIN_FAILURE	Auth	\N	{"email": "test@gmail.com", "message": "Password/User incorrect"}	2025-11-25 14:30:32.981
23	\N	LOGIN_FAILURE	Auth	\N	{"email": "test@gmail.com", "message": "Password/User incorrect"}	2025-11-25 14:30:37.097
24	\N	LOGIN_FAILURE	Auth	\N	{"ip": "192.168.210.126", "email": "test@gmail.com", "message": "Password/User incorrect"}	2025-11-25 14:51:17.473
25	\N	LOGIN_FAILURE	Auth	\N	{"ip": "192.168.210.126", "email": "test@gmail.com", "message": "Password/User incorrect"}	2025-11-25 14:51:22.532
26	\N	LOGIN_FAILURE	Auth	\N	{"ip": "192.168.210.126", "email": "test@gmail.com", "message": "Password/User incorrect"}	2025-11-25 14:51:25.381
27	\N	LOGIN_FAILURE	Auth	\N	{"ip": "192.168.210.126", "email": "test@gmail.com", "message": "Password/User incorrect"}	2025-11-25 14:51:29.108
28	\N	LOGIN_FAILURE	Auth	\N	{"ip": "192.168.210.126", "email": "test@gmail.com", "message": "Password/User incorrect"}	2025-11-25 14:51:32.488
29	\N	LOGIN_FAILURE	Auth	\N	{"ip": "192.168.210.126", "email": "admin@rentcar.com", "message": "Password/User incorrect"}	2025-11-27 04:18:57.231
30	\N	LOGIN_FAILURE	Auth	\N	{"ip": "192.168.210.126", "email": "test@gmail.com", "message": "Password/User incorrect"}	2025-11-27 17:09:24.232
31	\N	LOGIN_FAILURE	Auth	\N	{"ip": "192.168.210.126", "email": "test@gmail.com", "message": "Password/User incorrect"}	2025-11-27 17:09:32.573
32	\N	LOGIN_FAILURE	Auth	\N	{"ip": "192.168.210.126", "email": "test@gmail.com", "message": "Password/User incorrect"}	2025-11-27 17:09:39.12
33	\N	LOGIN_FAILURE	Auth	\N	{"ip": "192.168.210.126", "email": "test@gmail.com", "message": "Password/User incorrect"}	2025-11-27 17:09:44.31
34	\N	LOGIN_FAILURE	Auth	\N	{"ip": "192.168.210.126", "email": "test@gmail.com", "message": "Password/User incorrect"}	2025-11-27 17:09:52.909
35	8a33cd42-e569-47c1-8216-2a43103129cb	CANCEL_BOOKING	bookings	50	\N	2025-12-23 08:33:53.032
36	\N	LOGIN_FAILURE	Auth	\N	{"ip": "192.168.210.103", "email": "vietnho2004@gmail.com", "message": "Password/User incorrect"}	2025-12-30 05:18:40.689
37	\N	LOGIN_FAILURE	Auth	\N	{"ip": "192.168.210.103", "email": "vietnho2004@gmail.com", "message": "Password/User incorrect"}	2025-12-30 05:18:54.051
38	\N	LOGIN_FAILURE	Auth	\N	{"ip": "192.168.210.103", "email": "vietnho2004@gmail.com", "message": "Password/User incorrect"}	2025-12-30 05:18:57.211
39	\N	LOGIN_FAILURE	Auth	\N	{"ip": "192.168.210.103", "email": "vietnho2004@gmail.com", "message": "Password/User incorrect"}	2025-12-30 05:18:59.517
40	\N	LOGIN_FAILURE	Auth	\N	{"ip": "192.168.210.103", "email": "vietnho2004@gmail.com", "message": "Password/User incorrect"}	2025-12-30 05:19:01.806
41	\N	LOGIN_FAILURE	Auth	\N	{"ip": "192.168.210.103", "email": "vietnho2004@gmail.com", "message": "Password/User incorrect"}	2025-12-30 05:19:55.964
42	\N	LOGIN_FAILURE	Auth	\N	{"ip": "192.168.210.103", "email": "vietnho2004@gmail.com", "message": "Password/User incorrect"}	2025-12-30 05:22:13.871
43	\N	LOGIN_FAILURE	Auth	\N	{"ip": "192.168.210.103", "email": "vietnho2004@gmail.com", "message": "Password/User incorrect"}	2025-12-30 05:45:16.588
44	\N	LOGIN_FAILURE	Auth	\N	{"ip": "192.168.210.103", "email": "vietnho2004@gmail.com", "message": "Password/User incorrect"}	2025-12-30 05:45:53.258
45	\N	LOGIN_FAILURE	Auth	\N	{"ip": "192.168.210.103", "email": "vietnho2004@gmail.com", "message": "Password/User incorrect"}	2025-12-30 05:45:55.761
46	\N	LOGIN_FAILURE	Auth	\N	{"ip": "192.168.210.103", "email": "vietnho2004@gmail.com", "message": "Password/User incorrect"}	2025-12-30 05:45:57.99
47	\N	LOGIN_FAILURE	Auth	\N	{"ip": "192.168.210.103", "email": "vietnho2004@gmail.com", "message": "Password/User incorrect"}	2025-12-30 05:46:00.157
48	\N	LOGIN_FAILURE	Auth	\N	{"ip": "192.168.210.103", "email": "admin@rentcar.com", "message": "Password/User incorrect"}	2025-12-30 06:07:09.225
\.


--
-- Data for Name: payments; Type: TABLE DATA; Schema: public; Owner: ducviet
--

COPY public.payments (id, booking_id, provider, provider_payment_id, amount, currency, paid_at, user_id, status, type) FROM stdin;
1	16	VNPAY_MOCK	MOCK_TRX_1763737179365	500000.00	VND	2025-11-21 14:59:39.875	9520c430-201b-4444-98eb-bd848e07bac4	successful	BOOKING_DEPOSIT
2	16	cash	\N	594000.00	VND	2025-11-21 15:02:11.543	9520c430-201b-4444-98eb-bd848e07bac4	successful	RENTAL_FEE
3	16	cash	\N	20000000.00	VND	2025-11-21 15:02:11.543	9520c430-201b-4444-98eb-bd848e07bac4	successful	RENTAL_DEPOSIT
4	16	cash	\N	20000000.00	VND	2025-11-21 15:02:39.715	9520c430-201b-4444-98eb-bd848e07bac4	successful	REFUND
5	17	VNPAY_MOCK	MOCK_TRX_1763737481841	500000.00	VND	2025-11-21 15:04:41.973	9520c430-201b-4444-98eb-bd848e07bac4	successful	BOOKING_DEPOSIT
6	17	cash	\N	594000.00	VND	2025-11-21 15:04:53.951	9520c430-201b-4444-98eb-bd848e07bac4	successful	RENTAL_FEE
7	17	cash	\N	20000000.00	VND	2025-11-21 15:04:53.951	9520c430-201b-4444-98eb-bd848e07bac4	successful	RENTAL_DEPOSIT
8	17	cash	\N	20000000.00	VND	2025-11-21 15:04:59.177	9520c430-201b-4444-98eb-bd848e07bac4	successful	REFUND
9	18	VNPAY_MOCK	MOCK_TRX_1763741205327	500000.00	VND	2025-11-21 16:06:45.387	9520c430-201b-4444-98eb-bd848e07bac4	successful	BOOKING_DEPOSIT
10	18	cash	\N	594000.00	VND	2025-11-21 16:06:57.284	9520c430-201b-4444-98eb-bd848e07bac4	successful	RENTAL_FEE
11	18	cash	\N	20000000.00	VND	2025-11-21 16:06:57.284	9520c430-201b-4444-98eb-bd848e07bac4	successful	RENTAL_DEPOSIT
12	18	cash	\N	20000000.00	VND	2025-11-21 16:07:08.01	9520c430-201b-4444-98eb-bd848e07bac4	successful	REFUND
13	19	VNPAY_MOCK	MOCK_TRX_1763742270029	500000.00	VND	2025-11-21 16:24:30.848	9520c430-201b-4444-98eb-bd848e07bac4	successful	BOOKING_DEPOSIT
14	19	cash	\N	972000.00	VND	2025-11-21 16:24:54.605	9520c430-201b-4444-98eb-bd848e07bac4	successful	RENTAL_FEE
15	19	cash	\N	12000000.00	VND	2025-11-21 16:24:54.605	9520c430-201b-4444-98eb-bd848e07bac4	successful	RENTAL_DEPOSIT
16	19	cash	\N	12000000.00	VND	2025-11-21 16:24:59.165	9520c430-201b-4444-98eb-bd848e07bac4	successful	REFUND
17	20	VNPAY_MOCK	MOCK_TRX_1763742999113	500000.00	VND	2025-11-21 16:36:39.179	9520c430-201b-4444-98eb-bd848e07bac4	successful	BOOKING_DEPOSIT
18	20	cash	\N	594000.00	VND	2025-11-21 16:36:56.531	9520c430-201b-4444-98eb-bd848e07bac4	successful	RENTAL_FEE
19	20	cash	\N	20000000.00	VND	2025-11-21 16:36:56.531	9520c430-201b-4444-98eb-bd848e07bac4	successful	RENTAL_DEPOSIT
20	20	cash	\N	20000000.00	VND	2025-11-21 16:37:08.919	9520c430-201b-4444-98eb-bd848e07bac4	successful	REFUND
21	21	VNPAY_MOCK	MOCK_TRX_1763745263523	500000.00	VND	2025-11-21 17:14:23.452	9520c430-201b-4444-98eb-bd848e07bac4	successful	BOOKING_DEPOSIT
22	21	cash	\N	972000.00	VND	2025-11-21 17:14:31.698	9520c430-201b-4444-98eb-bd848e07bac4	successful	RENTAL_FEE
23	21	cash	\N	12000000.00	VND	2025-11-21 17:14:31.698	9520c430-201b-4444-98eb-bd848e07bac4	successful	RENTAL_DEPOSIT
24	21	cash	\N	12000000.00	VND	2025-11-21 17:17:33.912	9520c430-201b-4444-98eb-bd848e07bac4	successful	REFUND
25	22	VNPAY_MOCK	MOCK_TRX_1763746022354	500000.00	VND	2025-11-21 17:27:02.754	9520c430-201b-4444-98eb-bd848e07bac4	successful	BOOKING_DEPOSIT
26	22	cash	\N	756000.00	VND	2025-11-21 17:27:16.057	9520c430-201b-4444-98eb-bd848e07bac4	successful	RENTAL_FEE
27	22	cash	\N	8000000.00	VND	2025-11-21 17:27:16.057	9520c430-201b-4444-98eb-bd848e07bac4	successful	RENTAL_DEPOSIT
28	22	cash	\N	8000000.00	VND	\N	9520c430-201b-4444-98eb-bd848e07bac4	pending	REFUND
29	23	VNPAY_MOCK	MOCK_TRX_1763746680118	500000.00	VND	2025-11-21 17:38:00.681	9520c430-201b-4444-98eb-bd848e07bac4	successful	BOOKING_DEPOSIT
30	23	cash	\N	864000.00	VND	2025-11-21 17:38:28.2	9520c430-201b-4444-98eb-bd848e07bac4	successful	RENTAL_FEE
31	23	cash	\N	20000000.00	VND	2025-11-21 17:38:28.2	9520c430-201b-4444-98eb-bd848e07bac4	successful	RENTAL_DEPOSIT
32	23	cash	\N	19800000.00	VND	2025-11-21 17:38:43.4	9520c430-201b-4444-98eb-bd848e07bac4	successful	REFUND
33	24	VNPAY_MOCK	MOCK_TRX_1763747622164	500000.00	VND	2025-11-21 17:53:43.231	9520c430-201b-4444-98eb-bd848e07bac4	successful	BOOKING_DEPOSIT
34	24	cash	\N	756000.00	VND	2025-11-21 17:53:49.283	9520c430-201b-4444-98eb-bd848e07bac4	successful	RENTAL_FEE
35	24	cash	\N	8000000.00	VND	2025-11-21 17:53:49.283	9520c430-201b-4444-98eb-bd848e07bac4	successful	RENTAL_DEPOSIT
36	24	cash	\N	8000000.00	VND	2025-11-21 17:53:55.19	9520c430-201b-4444-98eb-bd848e07bac4	successful	REFUND
37	25	VNPAY_MOCK	MOCK_TRX_1763749344564	500000.00	VND	2025-11-21 18:22:24.904	9520c430-201b-4444-98eb-bd848e07bac4	successful	BOOKING_DEPOSIT
38	25	cash	\N	756000.00	VND	2025-11-21 18:22:39.837	9520c430-201b-4444-98eb-bd848e07bac4	successful	RENTAL_FEE
39	25	cash	\N	8000000.00	VND	2025-11-21 18:22:39.837	9520c430-201b-4444-98eb-bd848e07bac4	successful	RENTAL_DEPOSIT
40	25	cash	\N	7950000.00	VND	2025-11-21 18:22:53.351	9520c430-201b-4444-98eb-bd848e07bac4	successful	REFUND
41	26	VNPAY_MOCK	MOCK_TRX_1763749696491	500000.00	VND	2025-11-21 18:28:16.768	9520c430-201b-4444-98eb-bd848e07bac4	successful	BOOKING_DEPOSIT
42	26	cash	\N	756000.00	VND	2025-11-21 18:28:31.397	9520c430-201b-4444-98eb-bd848e07bac4	successful	RENTAL_FEE
43	26	cash	\N	8000000.00	VND	2025-11-21 18:28:31.397	9520c430-201b-4444-98eb-bd848e07bac4	successful	RENTAL_DEPOSIT
44	26	cash	\N	7700000.00	VND	2025-11-21 18:28:54.137	9520c430-201b-4444-98eb-bd848e07bac4	successful	REFUND
45	27	VNPAY_MOCK	MOCK_TRX_1763749936106	500000.00	VND	2025-11-21 18:32:16.394	9520c430-201b-4444-98eb-bd848e07bac4	successful	BOOKING_DEPOSIT
46	27	cash	\N	756000.00	VND	2025-11-21 18:32:26.403	9520c430-201b-4444-98eb-bd848e07bac4	successful	RENTAL_FEE
47	27	cash	\N	8000000.00	VND	2025-11-21 18:32:26.403	9520c430-201b-4444-98eb-bd848e07bac4	successful	RENTAL_DEPOSIT
48	27	cash	\N	8000000.00	VND	2025-11-21 18:32:31.475	9520c430-201b-4444-98eb-bd848e07bac4	successful	REFUND
49	28	VNPAY_MOCK	MOCK_TRX_1763750324940	500000.00	VND	2025-11-21 18:38:45.171	9520c430-201b-4444-98eb-bd848e07bac4	successful	BOOKING_DEPOSIT
50	28	cash	\N	594000.00	VND	2025-11-21 18:39:00.499	9520c430-201b-4444-98eb-bd848e07bac4	successful	RENTAL_FEE
51	28	cash	\N	20000000.00	VND	2025-11-21 18:39:00.499	9520c430-201b-4444-98eb-bd848e07bac4	successful	RENTAL_DEPOSIT
52	28	cash	\N	19650000.00	VND	2025-11-21 18:41:31.028	9520c430-201b-4444-98eb-bd848e07bac4	successful	REFUND
53	29	VNPAY_MOCK	MOCK_TRX_1763750785687	500000.00	VND	2025-11-21 18:46:26.152	9520c430-201b-4444-98eb-bd848e07bac4	successful	BOOKING_DEPOSIT
54	29	cash	\N	972000.00	VND	2025-11-21 18:46:37.447	9520c430-201b-4444-98eb-bd848e07bac4	successful	RENTAL_FEE
55	29	cash	\N	12000000.00	VND	2025-11-21 18:46:37.447	9520c430-201b-4444-98eb-bd848e07bac4	successful	RENTAL_DEPOSIT
56	29	cash	\N	11750000.00	VND	2025-11-21 18:47:02.601	9520c430-201b-4444-98eb-bd848e07bac4	successful	REFUND
57	30	VNPAY_MOCK	MOCK_TRX_1763751928834	500000.00	VND	2025-11-21 19:05:29.184	9520c430-201b-4444-98eb-bd848e07bac4	successful	BOOKING_DEPOSIT
58	30	cash	\N	1620000.00	VND	2025-11-21 19:05:45.118	9520c430-201b-4444-98eb-bd848e07bac4	successful	RENTAL_FEE
59	30	cash	\N	25000000.00	VND	2025-11-21 19:05:45.118	9520c430-201b-4444-98eb-bd848e07bac4	successful	RENTAL_DEPOSIT
60	30	cash	\N	25000000.00	VND	2025-11-21 19:05:49.76	9520c430-201b-4444-98eb-bd848e07bac4	successful	REFUND
61	31	VNPAY_MOCK	MOCK_TRX_1763752411687	500000.00	VND	2025-11-21 19:13:31.873	9520c430-201b-4444-98eb-bd848e07bac4	successful	BOOKING_DEPOSIT
62	31	cash	\N	648000.00	VND	2025-11-21 19:13:51.101	9520c430-201b-4444-98eb-bd848e07bac4	successful	RENTAL_FEE
63	31	cash	\N	15000000.00	VND	2025-11-21 19:13:51.101	9520c430-201b-4444-98eb-bd848e07bac4	successful	RENTAL_DEPOSIT
64	31	cash	\N	14700000.00	VND	2025-11-21 19:14:04.234	9520c430-201b-4444-98eb-bd848e07bac4	successful	REFUND
65	32	VNPAY_MOCK	MOCK_TRX_1763752944144	500000.00	VND	2025-11-21 19:22:24.262	9520c430-201b-4444-98eb-bd848e07bac4	successful	BOOKING_DEPOSIT
66	32	cash	\N	1620000.00	VND	2025-11-21 19:22:37.273	9520c430-201b-4444-98eb-bd848e07bac4	successful	RENTAL_FEE
67	32	cash	\N	25000000.00	VND	2025-11-21 19:22:37.273	9520c430-201b-4444-98eb-bd848e07bac4	successful	RENTAL_DEPOSIT
68	32	cash	\N	24700000.00	VND	2025-11-21 19:23:00.303	9520c430-201b-4444-98eb-bd848e07bac4	successful	REFUND
69	33	VNPAY_MOCK	MOCK_TRX_1763799459404	500000.00	VND	2025-11-22 08:17:39.859	9520c430-201b-4444-98eb-bd848e07bac4	successful	BOOKING_DEPOSIT
70	33	cash	\N	1620000.00	VND	2025-11-22 08:18:02.748	9520c430-201b-4444-98eb-bd848e07bac4	successful	RENTAL_FEE
71	33	cash	\N	25000000.00	VND	2025-11-22 08:18:02.748	9520c430-201b-4444-98eb-bd848e07bac4	successful	RENTAL_DEPOSIT
72	33	cash	\N	24800000.00	VND	2025-11-22 08:18:23.424	9520c430-201b-4444-98eb-bd848e07bac4	successful	REFUND
73	34	VNPAY_MOCK	MOCK_TRX_1763800077970	500000.00	VND	2025-11-22 08:27:58.11	9520c430-201b-4444-98eb-bd848e07bac4	successful	BOOKING_DEPOSIT
74	34	cash	\N	648000.00	VND	2025-11-22 08:28:12.797	9520c430-201b-4444-98eb-bd848e07bac4	successful	RENTAL_FEE
75	34	cash	\N	15000000.00	VND	2025-11-22 08:28:12.797	9520c430-201b-4444-98eb-bd848e07bac4	successful	RENTAL_DEPOSIT
76	34	cash	\N	14950000.00	VND	2025-11-22 08:35:20.799	9520c430-201b-4444-98eb-bd848e07bac4	successful	REFUND
77	35	VNPAY_MOCK	MOCK_TRX_1763800598329	500000.00	VND	2025-11-22 08:36:38.402	9520c430-201b-4444-98eb-bd848e07bac4	successful	BOOKING_DEPOSIT
78	35	cash	\N	324000.00	VND	2025-11-22 08:40:17.913	9520c430-201b-4444-98eb-bd848e07bac4	successful	RENTAL_FEE
79	35	cash	\N	10000000.00	VND	2025-11-22 08:40:17.913	9520c430-201b-4444-98eb-bd848e07bac4	successful	RENTAL_DEPOSIT
80	35	cash	\N	10000000.00	VND	2025-11-22 08:40:24.795	9520c430-201b-4444-98eb-bd848e07bac4	successful	REFUND
81	36	VNPAY_MOCK	MOCK_TRX_1764052253565	500000.00	VND	2025-11-25 06:30:41.865	9520c430-201b-4444-98eb-bd848e07bac4	successful	BOOKING_DEPOSIT
82	36	cash	\N	486000.00	VND	2025-11-25 06:31:12.062	9520c430-201b-4444-98eb-bd848e07bac4	successful	RENTAL_FEE
83	36	cash	\N	10000000.00	VND	2025-11-25 06:31:12.062	9520c430-201b-4444-98eb-bd848e07bac4	successful	RENTAL_DEPOSIT
84	36	cash	\N	10000000.00	VND	2025-11-25 06:31:44.251	9520c430-201b-4444-98eb-bd848e07bac4	successful	REFUND
85	37	VNPAY_MOCK	MOCK_TRX_1764056302799	500000.00	VND	2025-11-25 07:38:11.191	9520c430-201b-4444-98eb-bd848e07bac4	successful	BOOKING_DEPOSIT
86	37	cash	\N	756000.00	VND	2025-11-25 07:55:35.801	9520c430-201b-4444-98eb-bd848e07bac4	successful	RENTAL_FEE
87	37	cash	\N	8000000.00	VND	2025-11-25 07:55:35.801	9520c430-201b-4444-98eb-bd848e07bac4	successful	RENTAL_DEPOSIT
88	37	cash	\N	7800000.00	VND	2025-11-25 07:56:00.379	9520c430-201b-4444-98eb-bd848e07bac4	successful	REFUND
89	39	VNPAY_MOCK	MOCK_TRX_1764061612839	500000.00	VND	2025-11-25 09:06:41.039	9520c430-201b-4444-98eb-bd848e07bac4	successful	BOOKING_DEPOSIT
90	39	cash	\N	648000.00	VND	2025-11-25 09:06:58.091	9520c430-201b-4444-98eb-bd848e07bac4	successful	RENTAL_FEE
91	39	cash	\N	12000000.00	VND	2025-11-25 09:06:58.091	9520c430-201b-4444-98eb-bd848e07bac4	successful	RENTAL_DEPOSIT
92	39	cash	\N	11680000.00	VND	2025-11-25 09:07:37.478	9520c430-201b-4444-98eb-bd848e07bac4	successful	REFUND
93	40	VNPAY_MOCK	MOCK_TRX_1764212490693	500000.00	VND	2025-11-27 03:01:19.972	5ebc8dee-6716-4f41-aada-be40329a2f08	successful	BOOKING_DEPOSIT
94	40	cash	\N	648000.00	VND	2025-11-27 03:01:49.988	5ebc8dee-6716-4f41-aada-be40329a2f08	successful	RENTAL_FEE
95	40	cash	\N	15000000.00	VND	2025-11-27 03:01:49.988	5ebc8dee-6716-4f41-aada-be40329a2f08	successful	RENTAL_DEPOSIT
96	40	cash	\N	15000000.00	VND	2025-11-27 03:08:28.44	5ebc8dee-6716-4f41-aada-be40329a2f08	successful	REFUND
97	41	VNPAY_MOCK	MOCK_TRX_1764214011161	500000.00	VND	2025-11-27 03:26:40.421	5ebc8dee-6716-4f41-aada-be40329a2f08	successful	BOOKING_DEPOSIT
98	41	cash	\N	972000.00	VND	2025-11-27 03:28:18.399	5ebc8dee-6716-4f41-aada-be40329a2f08	successful	RENTAL_FEE
99	41	cash	\N	12000000.00	VND	2025-11-27 03:28:18.399	5ebc8dee-6716-4f41-aada-be40329a2f08	successful	RENTAL_DEPOSIT
100	41	cash	\N	11800000.00	VND	2025-11-27 03:30:05.864	5ebc8dee-6716-4f41-aada-be40329a2f08	successful	REFUND
101	42	VNPAY_MOCK	MOCK_TRX_1764215414351	500000.00	VND	2025-11-27 03:50:03.326	5ebc8dee-6716-4f41-aada-be40329a2f08	successful	BOOKING_DEPOSIT
102	42	cash	\N	756000.00	VND	2025-11-27 03:50:45.985	5ebc8dee-6716-4f41-aada-be40329a2f08	successful	RENTAL_FEE
103	42	cash	\N	8000000.00	VND	2025-11-27 03:50:45.985	5ebc8dee-6716-4f41-aada-be40329a2f08	successful	RENTAL_DEPOSIT
104	42	cash	\N	8000000.00	VND	2025-11-27 03:50:53.532	5ebc8dee-6716-4f41-aada-be40329a2f08	successful	REFUND
105	43	VNPAY_MOCK	MOCK_TRX_1764217260563	500000.00	VND	2025-11-27 04:20:49.769	5ebc8dee-6716-4f41-aada-be40329a2f08	successful	BOOKING_DEPOSIT
106	43	cash	\N	810000.00	VND	2025-11-27 04:21:21.654	5ebc8dee-6716-4f41-aada-be40329a2f08	successful	RENTAL_FEE
107	43	cash	\N	8000000.00	VND	2025-11-27 04:21:21.654	5ebc8dee-6716-4f41-aada-be40329a2f08	successful	RENTAL_DEPOSIT
108	43	cash	\N	7800000.00	VND	2025-11-27 04:22:33.087	5ebc8dee-6716-4f41-aada-be40329a2f08	successful	REFUND
109	44	VNPAY_MOCK	MOCK_TRX_1764218569261	500000.00	VND	2025-11-27 04:42:38.671	84f94b4f-fdf6-4898-80c4-7abcf7d5d100	successful	BOOKING_DEPOSIT
110	44	cash	\N	486000.00	VND	2025-11-27 04:43:04.766	84f94b4f-fdf6-4898-80c4-7abcf7d5d100	successful	RENTAL_FEE
111	44	cash	\N	10000000.00	VND	2025-11-27 04:43:04.766	84f94b4f-fdf6-4898-80c4-7abcf7d5d100	successful	RENTAL_DEPOSIT
112	44	cash	\N	9800000.00	VND	2025-11-27 04:43:54.617	84f94b4f-fdf6-4898-80c4-7abcf7d5d100	successful	REFUND
113	45	VNPAY_MOCK	MOCK_TRX_1764218874784	500000.00	VND	2025-11-27 04:47:44.004	84f94b4f-fdf6-4898-80c4-7abcf7d5d100	successful	BOOKING_DEPOSIT
114	45	cash	\N	648000.00	VND	2025-11-27 04:48:56.762	84f94b4f-fdf6-4898-80c4-7abcf7d5d100	successful	RENTAL_FEE
115	45	cash	\N	15000000.00	VND	2025-11-27 04:48:56.762	84f94b4f-fdf6-4898-80c4-7abcf7d5d100	successful	RENTAL_DEPOSIT
116	45	cash	\N	14800000.00	VND	2025-11-27 04:49:42.173	84f94b4f-fdf6-4898-80c4-7abcf7d5d100	successful	REFUND
117	46	VNPAY_MOCK	MOCK_TRX_1764255564670	500000.00	VND	2025-11-27 14:59:17.654	1b7dfc8a-519b-451a-9061-c35e0bdf32e2	successful	BOOKING_DEPOSIT
118	46	cash	\N	540000.00	VND	2025-11-27 15:01:37.374	1b7dfc8a-519b-451a-9061-c35e0bdf32e2	successful	RENTAL_FEE
119	46	cash	\N	8000000.00	VND	2025-11-27 15:01:37.374	1b7dfc8a-519b-451a-9061-c35e0bdf32e2	successful	RENTAL_DEPOSIT
120	46	cash	\N	7700000.00	VND	2025-11-27 15:04:19.022	1b7dfc8a-519b-451a-9061-c35e0bdf32e2	successful	REFUND
121	47	VNPAY_MOCK	MOCK_TRX_1764255988170	500000.00	VND	2025-11-27 15:06:21.885	1b7dfc8a-519b-451a-9061-c35e0bdf32e2	successful	BOOKING_DEPOSIT
122	47	cash	\N	756000.00	VND	2025-11-27 15:15:35.665	1b7dfc8a-519b-451a-9061-c35e0bdf32e2	successful	RENTAL_FEE
123	47	cash	\N	10000000.00	VND	2025-11-27 15:15:35.665	1b7dfc8a-519b-451a-9061-c35e0bdf32e2	successful	RENTAL_DEPOSIT
124	47	cash	\N	10000000.00	VND	2025-11-27 15:15:55.605	1b7dfc8a-519b-451a-9061-c35e0bdf32e2	successful	REFUND
125	49	VNPAY_MOCK	MOCK_TRX_1766478737072	500000.00	VND	2025-12-23 08:32:17.422	9520c430-201b-4444-98eb-bd848e07bac4	successful	BOOKING_DEPOSIT
126	51	VNPAY_MOCK	MOCK_TRX_1766478884510	500000.00	VND	2025-12-23 08:34:44.561	1b7dfc8a-519b-451a-9061-c35e0bdf32e2	successful	BOOKING_DEPOSIT
127	52	VNPAY_MOCK	MOCK_TRX_1766479064146	500000.00	VND	2025-12-23 08:37:44.343	84f94b4f-fdf6-4898-80c4-7abcf7d5d100	successful	BOOKING_DEPOSIT
128	52	cash	\N	1620000.00	VND	2025-12-23 11:00:00.151	84f94b4f-fdf6-4898-80c4-7abcf7d5d100	successful	RENTAL_FEE
129	52	cash	\N	25000000.00	VND	2025-12-23 11:00:00.151	84f94b4f-fdf6-4898-80c4-7abcf7d5d100	successful	RENTAL_DEPOSIT
130	51	cash	\N	864000.00	VND	2025-12-30 06:07:47.305	1b7dfc8a-519b-451a-9061-c35e0bdf32e2	successful	RENTAL_FEE
131	51	cash	\N	20000000.00	VND	2025-12-30 06:07:47.305	1b7dfc8a-519b-451a-9061-c35e0bdf32e2	successful	RENTAL_DEPOSIT
132	49	cash	\N	594000.00	VND	2025-12-30 06:08:10.159	9520c430-201b-4444-98eb-bd848e07bac4	successful	RENTAL_FEE
133	49	cash	\N	20000000.00	VND	2025-12-30 06:08:10.159	9520c430-201b-4444-98eb-bd848e07bac4	successful	RENTAL_DEPOSIT
134	49	cash	\N	19450000.00	VND	2025-12-30 06:08:13.893	9520c430-201b-4444-98eb-bd848e07bac4	successful	REFUND
135	52	cash	\N	23500000.00	VND	2025-12-30 06:09:29.693	84f94b4f-fdf6-4898-80c4-7abcf7d5d100	successful	REFUND
136	51	cash	\N	19200000.00	VND	2025-12-30 06:09:39.173	1b7dfc8a-519b-451a-9061-c35e0bdf32e2	successful	REFUND
\.


--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: public; Owner: ducviet
--

COPY public.refresh_tokens (id, user_id, token_hash, expires_at, revoked) FROM stdin;
1	c66f8005-2f0c-4eb5-927d-6efdb85ef53a	$2b$10$r2S1VJw07rtGk5stSouqbeUOH2CrnGEHjf49PTWwGrz0NuOKw86fy	2025-11-02 14:21:39.976	t
3	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$/44vrrUEuFiPLFSL6o1NEuN1NYhxmTaSXBkOpZNqh9G7FZSae0xcq	2025-11-05 14:07:53.104	t
4	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$eVit2SUw84YUaGWmfjlE.u03gns3zzKHRE0q5bkSssB4uJSt4WLtO	2025-11-09 13:59:33.299	t
5	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$MViXJF6ieeXuBL6TImEOJumAQUdNZMcoTItkKszM04b4OmX.a3D/2	2025-11-09 13:59:55.043	t
6	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$6LcYX4ZKbWuXL50Xun2QIOuXYiXY/5/skwKXzbZ8lpSEthxOQVtl6	2025-11-09 14:00:16.879	t
7	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$1.rtlr4gP.xYEh5RiHpWTOOWQPiSIguDJC7katyIoS0tonU1R.Ara	2025-11-09 14:02:36.882	t
8	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$mlrqrqohvzj6M81bOrV80eK.1lV81DsCLOfbjn0wACJneTXvLH/PW	2025-11-09 14:03:08.75	t
9	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$v2KfRlpa0kcfoiarHfPS/Oz66xoWXSwA1v5n8vwwflH.Yk8J3yTMC	2025-11-09 14:04:27.776	t
10	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$HjY/5VYjL7xGbDZ9W.nSee1puH9WoGjpVpQC8wBxzOHvX/puYX4Wi	2025-11-09 14:06:30.949	t
11	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$S1HX8qQdqbANrc4dxsZQJupLmSHPP4rNBEBt2T4gKikhfLlV4UHB6	2025-11-09 14:10:43.577	t
12	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$l0.lCnjQzgriN91jmfNwF.zex9KBojnUx.4oGNVB/sCrZUggIQGeq	2025-11-09 14:27:23.548	t
13	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$rD3MaPyyrDgHLoOJlfWVUuO2TqkkvoDBywVtYSoTeZLR6iAEM3maO	2025-11-09 14:43:22.162	t
14	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$OnvGjZhQwqOJQvINz8zW8eOZGXLvVRVUzHxRiEu4WaCYTSyaVPcja	2025-11-09 14:58:49.483	t
15	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$Jn./nBrCATmweLO7iT59ZuKB7NA9yOhuYJUyx24VJy.oEXQHTgjJi	2025-11-09 15:23:48.597	t
16	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$jTSb/eOrFZ4UALsoOIpVPusv3sTqijnbJ9OzhRcB9oMTGFvAT4iba	2025-11-09 15:42:07.39	t
17	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$yK9NKD6l7zqSwdgIRixI8evfTe1Ig7yfcH9s8krJZwVGF1CmZsfTO	2025-11-09 15:58:53.425	t
18	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$Cpr/Z52kM8Hy.2A6DlUl8uALR3CH1fCxG3ul4aT7yjsJPWZQnCO1q	2025-11-09 16:07:13.136	t
19	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$nYkYjEEGAepoVsQo1cq6PO/CRoiBkVYpdIkEvBQajrWEWljlhYpey	2025-11-09 16:47:01.361	t
20	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$YlVFjupjRkDnKZMqFi3/TuuqHzFZlevh9vreTjdLUhOCfTBthfwve	2025-11-09 17:28:20.408	t
21	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$vmcZ6FsWFdfB2BQE/JrsrumPBW6M8KlN8duPyQoN9TWls.RPKwcW6	2025-11-09 18:15:15.976	t
22	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$zRhroRCP2gpQL3PUoOkZROAhgabgOAgzRQzCmmdAhQ6e/PY/fJjki	2025-11-09 18:59:47.168	t
23	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$0hpRp6LqhtKoHOjgsvxNo.2UM8bg17aCVZN4G0AKW/fJkl2AHpuiG	2025-11-10 03:28:17.555	t
24	5ebc8dee-6716-4f41-aada-be40329a2f08	$2b$10$MCZuOfSCdZ.Gki8PDcnuve//4YUei.jdejC20HeS03eXXDhjueIbO	2025-11-10 03:44:58.959	t
25	5ebc8dee-6716-4f41-aada-be40329a2f08	$2b$10$XwAK635PhhmePZBvaixebu/DAZoUgz9Dnyt71pXbpuM.FKB6RF5ua	2025-11-10 03:48:10.535	t
26	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$PE2Qjfvlp2ahUVsbTOxDbO73yr5smg0oUYlXFI1gUUKhCdmXc8tYO	2025-11-10 03:49:14.204	t
27	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$vV5shp70DafdRAQ7DZKe.O8nlJgH72GJi7DyqvT48J8muuASQCcZO	2025-11-10 03:55:47.802	t
28	5ebc8dee-6716-4f41-aada-be40329a2f08	$2b$10$14w.kWTlGavlVgTICyUbZudRYklZ/WTX6PkO/AewTs8j4XAfsxszK	2025-11-10 03:57:16.313	t
29	5ebc8dee-6716-4f41-aada-be40329a2f08	$2b$10$tGSySGCCNhRFzqKmsb6yEugQhFyNEi/7BgukyY8I.ONbC6qvczFVa	2025-11-10 04:01:40.732	t
30	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$OHk2KjBCde3ZSlvMrKmYKunRVFROD4HZIeu..8fln5RTqvOywSw6i	2025-11-10 04:02:44.993	t
31	5ebc8dee-6716-4f41-aada-be40329a2f08	$2b$10$7i1xX.quGiT4fMtznqNtXON/r9ojyDoXohc.a4RwDR.s1Xy6SveAu	2025-11-10 04:03:49.197	t
32	5ebc8dee-6716-4f41-aada-be40329a2f08	$2b$10$7/u3yyqqdt.a4H6aSbW1TO.BWJl1UUSKrY3LFwOuB4pGYLTlM7O9K	2025-11-10 04:08:36.685	t
33	5ebc8dee-6716-4f41-aada-be40329a2f08	$2b$10$7C1VNXw.PvxAk8Ar02su5eTYPQoFm9RgAZYV7Tg5DNfM66trfGEP.	2025-11-10 04:11:59.67	t
34	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$0wJLVnFpV76g.OM.2mp80OF0LgSCBHzxAo7hHJuLA4fuZYzoqTq9.	2025-11-10 04:12:49.328	t
35	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$coU9Z7YyEN/1aBT3cJgOqu52RGsz0UsZGFL0btjCgpTf8sz/ikGOq	2025-11-10 04:42:50.627	t
36	5ebc8dee-6716-4f41-aada-be40329a2f08	$2b$10$hQxQ6zBi37iQmpF5SR2uOeIiqvjdQMj2AmJOENth6rJwNcNCu2Equ	2025-11-10 04:44:20.728	t
38	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$FEgVF4YAGORZdfN57ipLT.CGGO6OqigQ/if2mhljlu2U3Akb2H8Tu	2025-11-10 14:30:48.909	t
39	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$kJitqg5AwwNv7OWm8.hmuuqevKbREClAztbkH6YFEa9rM25xDxCpu	2025-11-10 14:55:50.571	t
40	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$o3qlRBcj8eNJVL0KjbTISOZqbihgdlaWa88kK2qUTRLZMs/Zb2xt6	2025-11-10 15:11:17.321	t
41	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$h30EdIcROcFl0ZCxzuRt0OyYdDP9PZEscp/MwLo3OTUuIjMimK9uG	2025-11-10 15:19:17.546	t
42	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$Nm3Qx1.e5wPdXXCFvfrGQ.GV49ZwqCi2bfSPP5uO6/qvFwqG1VR2y	2025-11-10 15:31:34.027	t
43	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$tdExatjSGc48mP9cYjp9Ae/oIWglDKqmmBett1pfmzQRoBMcSrchC	2025-11-10 16:17:52.561	t
44	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$WHCsdUfy9KXbhPZIsfOdG.lZ6n4lqvYYA7SnIhBnGw5TRx2omcRAC	2025-11-10 16:29:18.151	t
45	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$.IrZfyoaT5A6Nki9zT3mUOPNjVA8L6x3Rka6aNMxuVRerqEOapBsO	2025-11-10 16:37:14.665	t
46	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$B70B7DO78vFfQxfb9Mz8cOWlWJai7OyCoZ4t8qhL.xske/CVrICbG	2025-11-10 16:46:16.909	t
47	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$/rszKPXkLogmWoeSiacsb.Kkj9VFwSNRPWsd8TaP2O01SiGh2wkAm	2025-11-10 16:57:03.238	t
48	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$nYFrtQaWvpiwTHI0gttCPeayzQlu3Ds2LmSC8Q8QaTs2ipKgb1/NC	2025-11-10 17:10:58.251	t
49	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$nwY.PO.NWZG8q.NmDxFxr.RzZp.Mz8c75tZNiCdhQ7S3VO6AWmw3G	2025-11-10 17:13:41.311	t
50	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$xPK.LGgJ6QRQ7SYYbCzJq.kHwabh7OCOvbkGEDMxT1d/YJC7kMwkK	2025-11-10 17:21:25.672	t
51	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$5eWvlZJkOQWYkL8oEgGnuOZMDPfLaPyXJl6dhCYxhDT93oIgJgWgm	2025-11-10 17:43:42.448	t
52	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$4RBujZPuKn0TNjvlASn1LuG1TpbW15gKlUjiizBavajZdA0KhR8iu	2025-11-10 17:56:31.935	t
53	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$Zk9fJVoxRckajL0DJQkf2e77QhamaRPR4pF.j7Tj/myEZjTUQLqQG	2025-11-10 18:09:02.385	t
54	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$.FCJVyrduuHnzek3IQwaUOIe/b.xNMPhaXc6aTmp3ZxrJWxEuXVVW	2025-11-10 18:18:25.678	t
55	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$gTylUEuWKjl2BH.EdoyO0Om.sr4FRd0zHl.x5CjtU0F0swxHNuvC2	2025-11-10 18:24:20.56	t
56	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$5/b8n33z9hVhPL6kHX4ine/e7gF76TCaViSkFqjSbpIxbmNKiwMkO	2025-11-10 18:29:19.283	t
57	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$XRdmSWdLEOgdCAjG.hkTx..dgQ4OZKNPJgMhZqxwpvac6tExtjMjS	2025-11-10 18:54:45.207	t
58	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$s28ta4eT2mbP6gntjYDZ1uQftq8XM3lYdobyiBS8n5l.58GwGDQa.	2025-11-10 19:10:46.149	t
59	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$7Wdf/2jx9NpxaertxweZwuuS67EV.vnErmGz2K46D5tSriuxB64nG	2025-11-10 19:32:14.697	t
37	5ebc8dee-6716-4f41-aada-be40329a2f08	$2b$10$u5j7RTQAoSPeq.3uiLlFp.AZ/tGyv.d78vxEOTkt3LfW4croM60t.	2025-11-10 14:23:32.212	t
2	84f94b4f-fdf6-4898-80c4-7abcf7d5d100	$2b$10$Gsex3JLzNUXH0njbHhRGS.m74QMn5rkiJ0DYEmXjOGR9q6PHCMsli	2025-11-02 16:14:11.498	t
60	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$y8T2DJy.ho0K8ghfEIsZl.a6S3ulx9HiT24sUQFnax8Y6OHMbN8Du	2025-11-10 19:53:02.303	t
61	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$cZcGt62JjKmVQaaYF0oYu.aJyZhOeF4HbVRKbBTqmQNmq00SuiPEW	2025-11-10 20:01:35.496	t
62	5ebc8dee-6716-4f41-aada-be40329a2f08	$2b$10$19CINhKAJCQaXvgK/uo1wuz.aBiJo6sAyHBR8CoeU7O0/78utHoRi	2025-11-10 20:03:50.609	t
63	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$pPhXkV1vamnwcq6UdmhuYuUmnfYa1X5GfJ4pMclJTkLadu/xZt8iC	2025-11-10 20:05:01.417	t
64	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$UCzbDCNrazaVryMCC87Y.uZHKX2/Y/mDt23KxlLoz27tZL8sh5h66	2025-11-10 20:10:05.77	t
65	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$Q3k9AYlxSaXKKSuuqNfemuU6H8qe3g5G7ooHJoWzsJd2n5.mCcKF2	2025-11-10 20:26:11.004	t
66	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$27zNlICmC3q0LoIdZQNPQuYWIYIo0q4IBoAJOtWPil3eIVYclHctG	2025-11-10 20:30:36.329	t
67	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$zXg6dYzxIMz9hlVnxrN2ZOJoK6hje6zyZmo0rNoX.dg.ItTcJYCXK	2025-11-10 21:24:00.639	t
68	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$4ncFbyPAqDVOTfTRq59I7OVFw0FzTPzWwEDyppah2jrJ9soicobkO	2025-11-10 21:26:21.574	t
69	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$AOdcELTZVu.gCtPIG7f5SeWzGCdrQLGLxYd2MMSOotKBuV347ipjO	2025-11-15 12:45:49.949	t
70	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$nIq4R5zduF1/s2AeVuVM8OFx8Rf4P6xE8.mrSINjSf8eVxS9xsJdy	2025-11-15 15:38:28.325	t
71	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$402w8WvBk4nFOb5Xwlykve51E8ML/n/ucETL1PmL3Ra5xJsZ/BY5W	2025-11-15 15:44:26.877	t
72	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$DYvKe/sHYzMpPmpJyORFweiaYDnIrlPQ7Nh22Y2FdpHrPGaCzobfe	2025-11-15 15:54:54.988	t
73	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$DsnW.WIkTb59V.y97szkSesRvTN504vv0QfiglvGoVQJC3S5x4yEu	2025-11-15 16:01:21.921	t
74	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$M1UPP68cIQ6wFms.DSvhIu2ov/ET850HMwa9naiH.80Yq1/3pyR/.	2025-11-15 16:12:26.088	t
75	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$GnedMLlQjT5ZBWoHIbbWquvDn0pKrhNGNJJaX2xLiVBHA4HwEw9iK	2025-11-15 16:22:31.732	t
76	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$43nmW8rNsrMZmVKKZj03beRukAyJon/o7WtWz/KTdan7FpFrEYyJi	2025-11-15 16:28:23.268	t
77	5ebc8dee-6716-4f41-aada-be40329a2f08	$2b$10$yKF65EevlXQSTMImCEhR6uvbOWJeaFtow6StH8FnmitrP6T0QaDYi	2025-11-15 16:33:36.647	t
78	5ebc8dee-6716-4f41-aada-be40329a2f08	$2b$10$H.b89iAO4sP0voZMkWXwU.A8lH0f4vuab7w4ykM6hx/bsx8UDIyMq	2025-11-15 16:37:35.682	t
79	5ebc8dee-6716-4f41-aada-be40329a2f08	$2b$10$INfVS.LuboL0xjMU/7aAi.Wj4dhQeJFN2O4pNVBawAluEMgjWMIGa	2025-11-15 16:39:08.141	t
80	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$Tg.huVYRmA2SrEoyTL81AOivDoR14mXWNo7ft8Xqa9960GiTfVt5O	2025-11-15 16:39:36.217	t
81	5ebc8dee-6716-4f41-aada-be40329a2f08	$2b$10$KK2t6J0pBc3J7pTKvtV3Xug5MHDA1/eQxB3PMA13QTZJdgvh/ctpi	2025-11-15 16:40:31.065	t
82	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$1qrblswJ7iLyXDzkpvna1.LjXK3cnnJfHUtkPrPlQyrzBgPzsfLpG	2025-11-15 16:41:13.499	t
83	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$4Dk9eB7i.L6mY19doJ3w1uuNWvWkKuMIoyF5Zgo582IROQlDtMUmW	2025-11-15 16:43:38.514	t
84	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$DQwsa/uldFEpQkc5zTtIyu4havxuleDuThUy72vyIkLnrJlO69fji	2025-11-15 17:04:15.586	t
85	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$JNEwdNmK7aedc7YnaWwQjO0VnOw1uQSaT82fpAesdvNO8WVUEfJw2	2025-11-15 17:05:17.405	t
86	5ebc8dee-6716-4f41-aada-be40329a2f08	$2b$10$lp/QPRNi./nmUO56caCqUeE6n3n4j/LFmYQ9.rNvNF4ckXuKSr8wu	2025-11-15 17:06:01.559	t
87	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$9bSoOazBX09dABpCTvtXfu/EddsymeUDR/3NWdzjvaa1ZaYUhcY4W	2025-11-15 17:07:09.482	t
88	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$.l91kw78uKHI4SyD2y/pQ.HY0DM0ZW1LyLDQAa3.MjPX/dSTNLjCi	2025-11-15 17:21:25.167	t
89	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$zZYH9Mh0xUx6weD0GSSI9OdYEImNpGT1kcZhapEMtDTcJoL7NbXO6	2025-11-15 17:22:27.784	t
90	5ebc8dee-6716-4f41-aada-be40329a2f08	$2b$10$5G9zz0RjyMqYP/4zRE2d1.zGPy5iFHluMcJSJcXGvktweXKRWO6AS	2025-11-15 17:23:41.681	t
91	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$OI/pBTeZFfDJcZd2AjXpXepBGtqAgxJCpGBA.jaw0ql4fWWoO43sy	2025-11-15 17:25:32.253	t
92	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$ZgB.uX30wiYW1G1uSF7Fv.CITCvb0bMQQeM5tmhaPUM65YtXXsn5W	2025-11-15 17:26:40.07	t
93	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$kg.sxeyljl/Q1uO8TqGxSOIFoyVpOBH8q5WnJQWjwirRju96yS7ia	2025-11-15 17:30:04.061	t
94	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$8h56sQYFRxp9irstNNPh6.2V63Nq4qwdziDZ.J4wvfdPPqPYsVWfS	2025-11-15 17:31:50.852	t
95	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$OddihWJKaM851DwMKIkwA.hO0FlE0iubH5umy9ntkE/1Wo.6W1JXa	2025-11-17 15:04:28.85	t
96	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$hqzFLgHtIChEjNtMb7NGpuS8anSj1wSkkQ187vra4WOuRKN57E9HG	2025-11-17 15:27:10.303	t
97	5ebc8dee-6716-4f41-aada-be40329a2f08	$2b$10$xyW18uxMzECQzrJYMWt9iOjyZDqIp3OJjbHWtgCmee3Aw00M8WSWS	2025-11-17 15:29:07.896	t
98	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$PqGNhOBRK5k3gI.I6ZZ6yeHGt4TLx1O/8EZwxEcp9qo5yg48FaAwK	2025-11-17 15:30:46.513	t
100	5ebc8dee-6716-4f41-aada-be40329a2f08	$2b$10$KoUM.sTgQg2mketXNgUTSucqMOCn0YHFxxTIk8cVB8iyGyNgF5W7C	2025-11-17 15:39:32.143	t
99	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$CRUBhsYyGLCxgeIktcBEDO4F83ZbbhtzKlLGRld7uBVnKaqLnxhCO	2025-11-17 15:31:44.325	t
101	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$fEo/NBnsJPsGMKZ4zXM/LO8arYXXxV5.9.FfuWbseoT0mpWn0memi	2025-11-17 15:41:32.275	t
102	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$W8OTeBNYdrHYUqsJArZJ1ui9rDRmnazDNeRHhJaDz1vXVP90E3Bdi	2025-11-17 16:48:31.777	t
103	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$hLKkwvsyrfPdtAcSh8/lAe.1s.NrDeteEvsckEzEuVlh7863qmFve	2025-11-17 16:51:46.185	t
104	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$ZbEtaQxeLqx79gi/s9pRUOMaleLDhH7kQdkuyd6CufWHUrqI35EoS	2025-11-17 16:55:45.954	t
105	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$qP7GnoGtVWaxNteGl6yv7u62YAKWeR2isSXKoKSRkcNO4BWhIDqgy	2025-11-17 17:23:47.653	t
106	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$QfuLVh7YVFrKb23EbfcOI.laW6mUMv7jg0N5yyb9L1asZu.o2/G8a	2025-11-17 17:33:29.684	t
107	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$Sm8sWELGnif1TvvFH0O6zezsIEYk5uJn5f44XXqK7.CaqZ1oD.MZG	2025-11-17 17:41:42.18	t
109	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$sZNRa32DC.rGfaPRV6BpQOK35UiwVp4jubtkBE7W7z16eKZH8YqeS	2025-11-17 17:45:50.919	t
110	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$UjRoRTnc6a6JW3lUWtx2zuEfc4Su4fyc4y2N7J8mZF8CFOBjQLx3q	2025-11-17 17:47:12	t
108	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$g3GHNxdkarUCPh/mmyUice9eoIRM2L6npeUcwd4A6yzmZulTHKg2a	2025-11-17 17:42:47.916	t
111	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$dIJi99r.0vrbtyaTm6meL.oJCm9StZBhPdmGADeYD61WnTEsl06na	2025-11-17 17:48:08.455	t
112	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$/ifYb3OTJK2cpTIMD6cdfuLbKwkFCiXtnVElYiV/UguNlFGZVOOwO	2025-11-17 17:49:12.071	t
113	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$NDUkdWEHlcOgSHlmPFNw1Om1WZUbu4iGtfsPlAw3iWJG9uqunLQeO	2025-11-17 17:50:10.178	t
116	5ebc8dee-6716-4f41-aada-be40329a2f08	$2b$10$tXidF3xD5TSfXVK2.9el/uLhqqqKa/DZVRz15Mzk9PjbYuqDlwsJO	2025-11-17 19:08:57.102	t
115	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$gK/OF1eVLViMmIrkrBDQK.bMc7pdFdWE.j3AAFRYZ7ilLdqBUysAC	2025-11-17 18:26:39.766	t
117	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$F302CWAf93.N60c03p/fjOTySYKiUTxyY4mgzqBSZFycYCCTQyAVq	2025-11-17 19:10:33.83	t
118	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$xedhE5u1tZK.8n.Rr2Zg9u46QUZWijQ6yF86v.o8Yt7XhcLJrjXOu	2025-11-17 19:12:04.225	t
114	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$8dYg.DJRB3mbuQEwEqjFfumcCeoD5iwwtILo2acPKjzJBlbASYYam	2025-11-17 18:00:30.65	t
119	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$i2D5gnYa15Zu8GCBSh9Q7O2PbndmiMGq6CHRAkzdIrqSTLz3XAEDi	2025-11-17 19:13:11.444	t
120	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$WGVxC/KhREDuLR2zvgIbxOQ2gDFZY4cidK0LhuITel/xggqbhrxPq	2025-11-17 19:17:15.567	t
121	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$xkBzf99mMaTlUuKfCk5VqOJ.c3xLeEoxW28FfRB/FklTGqVWNFVQK	2025-11-17 19:18:29.097	t
122	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$8boQ0TrDpGFOjkV88UtaAevOm4.IJVucIJsNctwbpMOLtcldOmmz.	2025-11-17 19:19:50.633	t
123	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$z2ST42N6e9wuNen71CNtCuQIYwRZI5Ejb5FmIE9//920I4WhSO/E.	2025-11-17 19:21:45.269	t
124	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$PXsTy9mXPPQaMUw79JueduujHLwzhsC2bR8tb/MFCt2eBe0fOcC26	2025-11-17 19:23:04.322	t
125	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$iu7aLcfZ.f6NbuuynNI6weOdhypE.GaAOiWa96Ftxrst61VDLI0b6	2025-11-18 09:21:25.164	t
126	5ebc8dee-6716-4f41-aada-be40329a2f08	$2b$10$G5vxcNbJY/fNRUVaCP1Mi.N/xlFY0prlRAhlU6MMosCeSLqF5ap96	2025-11-18 09:22:24.86	t
127	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$ru1Vv848Tw8lAUU4Emhg9.DB4TUkb0K/rJki6uAeIYq978SWRkWDq	2025-11-18 09:23:13.375	t
128	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$U5T5FFc70K.smluqKlXgPuFTbqrlRkcWaqpkZ05rkbBggpirwQyvC	2025-11-18 09:24:29.24	t
129	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$0CvxnrBk7jhT5WwWTWn1POSP9WAhkM6FAnpQauOHfLcbr.FZNjF.m	2025-11-18 09:26:56.969	t
130	84f94b4f-fdf6-4898-80c4-7abcf7d5d100	$2b$10$ZB3yjBtVy9cUxDBOhBBTge6ygSWKw1A8..k9tDRPavrgm03WENK7q	2025-11-18 09:30:29.707	t
131	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$B07hyH5.qwrG9dqXrn/3c.L.h2hISpZbvVijOr7v.GMG5rN1cHICm	2025-11-18 09:33:29.624	t
132	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$BBIuuyad.lLjt4N1bbIz/OgGQpPezt3R/LCxo0k442l787ABgjcNC	2025-11-18 09:40:32.069	t
133	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$Z7L8cvtzFDreQuTSWu6gweuHXt2sufTDFIQ5CIw8cRjr4b/kNjdNy	2025-11-18 09:54:51.31	t
134	5ebc8dee-6716-4f41-aada-be40329a2f08	$2b$10$3wH1SKVCNJGkjNcaaljBZexiMGY6jkf1o3M0Up/9gSlHzdMGda/EW	2025-11-18 09:56:58.889	t
135	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$EX48ad4E4KXwqBVDLsTfleIH811kfDCaJ/H1cY0YD4guMNwyDrpSu	2025-11-18 10:01:15.784	t
136	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$XFvozO8IE1QxOpN2fLuJteadjU8IqouKDre6X77IPEgzY.ixfHo46	2025-11-18 10:06:07.293	t
137	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$3W22Uwh/KRTskmC.LRT9ROd6OPVjZOHeOE5IBxpu431qS0LaFhPb2	2025-11-18 10:06:56.558	t
138	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$bJWeR5Txme/ZVk3GT6NA4uKL9RrKtcMDz3k50zGh9kXr.GjcDylTm	2025-11-18 10:12:57.334	t
139	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$TqfbimVnUaNeFstU47Zw9u2y1nMR0xHjxfUd9lYToerLEK2CqU5jm	2025-11-18 10:15:00.184	t
140	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$u8Jv/7A/IFcVUKULiRPz1.vfw7OMVHBjT.kuq2I3CTOkrRul3E6kK	2025-11-18 10:25:17.843	t
141	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$R.aYqdo5cUU4YkgoG6xtku46hRFqomyle5O785pEeszm7PRAoqp.2	2025-11-18 10:30:40.536	t
142	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$7ygIrD/1iShzAskR0uqZSOhUsHUBabzhGW/1RPdzq8G4OSCZLS9oe	2025-11-18 10:33:03.601	t
144	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$m4lFsHtjSTsarNOiOHYc.Oz/AF9kFiWQ74162/k/ZpPswEy7cpDgi	2025-11-18 10:47:15.322	t
145	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$mshFSFKeswwXUhBM8aadX.mOgOBrc9KcIkRvJ4Zp74CCdi.PRVNfi	2025-11-18 11:13:42.8	t
146	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$PiY1pMxDok5w9HALucV9ROcXoTVKYPgfWTUm0X8OtBMeMi2eNf/Nm	2025-11-18 15:01:27.252	t
147	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$GrdWTNQJocZZPOHUGZ1JQuzjH3FQFxsT8qUEPbyHn9h68vnNVQ6pu	2025-11-18 15:16:06.642	t
148	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$ljitkmrotUd1nQQSeyDdsO2MWYpxBbIhfd3.Q95bYu1/gXYrCbnfa	2025-11-18 15:38:52.502	t
149	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$X7EO6kD43mLUUQKFksgsEeNL2TBS8r/9NAgk4HOcqLLGBlH2LzF2.	2025-11-18 15:52:43.329	t
150	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$zmj0a02uuSmq/Li3b/K5weHC7B4thZrrb.YZxF0In6D/A/fDoQngG	2025-11-18 16:08:59.022	t
151	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$MpHfbumrfXxHh4zdOprSZuTm1Q2UjhiPAmBa3peKRjFPtyVqcDNze	2025-11-18 16:10:06.147	t
152	84f94b4f-fdf6-4898-80c4-7abcf7d5d100	$2b$10$.ayxHZX0h3Za/uhE1nDPduD9sg1QO4Rxfanm2eTIRhZnkr5bOnkeC	2025-11-18 16:11:21.318	t
154	84f94b4f-fdf6-4898-80c4-7abcf7d5d100	$2b$10$GJhj6M9xTgV6/Cd60lINH.WgGgC0kqI7taOTxWSrApZxw8CttDvNS	2025-11-18 16:18:34.319	t
153	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$SGVg2cSJ5hGEG9h7BO7cK.mGfqxShbe3ZQEjABudEvu.4/wXu34Y.	2025-11-18 16:12:14.77	t
155	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$Gmpi29E0w1CvwrSTD7i7runLmougrN0IS95iRmUOKAUP5dF/q22Zm	2025-11-18 16:20:28.55	t
156	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$n1cQkS0yXpYf/zKJUYxAger2YhQMgXUJcPH6ZlRnSmjXaSpcCu4.K	2025-11-18 16:34:38.781	t
157	84f94b4f-fdf6-4898-80c4-7abcf7d5d100	$2b$10$NPRTNJa2UMKXmempqkSfweTC3HxI7c4fX5.CtJxhTIDzYYUImFGR.	2025-11-18 16:36:59.026	t
158	84f94b4f-fdf6-4898-80c4-7abcf7d5d100	$2b$10$sa56CWS9yOxoO9HqITxal.6lnYGDZKWCnJUvR9sqQY0z2XRLteOjy	2025-11-18 16:38:15.607	t
159	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$sJ1KivxvsfCdmV6Qt/RzIOLwL5swgDiJOz8yi/ezDY9k9Dgt9lG02	2025-11-18 16:38:46.024	t
160	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$7fV6QfsCB6yHQ8M3S8/kw.GLRNr//PWScumnC3Dfw11MW.p.WDHuW	2025-11-18 16:42:02.532	t
161	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$xCorqyyyTKq2tbzBniv5quWV2PcIbEtVCahqpw1bB/XyyVS/e4v3m	2025-11-18 16:46:05.562	t
162	84f94b4f-fdf6-4898-80c4-7abcf7d5d100	$2b$10$b/jWgpOxIcgapJWBS3kpmeC7r9mNG3cgda/zYMg.sZPI4g1cRoJRa	2025-11-18 16:47:37.615	t
163	5ebc8dee-6716-4f41-aada-be40329a2f08	$2b$10$7Q3dFERItwQ8YTA8qDa7uedZjCnwblBJsuVTmU1M5M66DtFXRSdd.	2025-11-18 16:49:07.862	t
164	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$UAlWYgXui.z2s6US790afebqDjmoq8RhaWkvDlJxQVYo5nJSXc7dS	2025-11-18 16:51:26.061	t
165	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$oTyo3yAKOFjIWf24daPPlOHZ2sANfg/C5Zd601yfR.ZPSKkY.SENi	2025-11-18 16:54:31.305	t
143	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$kRY/uUy1QCiNRtwWZZKwWOpx.sK4jCFCS7oTJcukYqRCalWAhgfT.	2025-11-18 10:36:22.979	t
166	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$MLvF5ocRkBAFxiNiykigrOGNmJnMwt4TkYLRDD5bE3xkjRzekNUjy	2025-11-18 17:02:30.807	t
167	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$mKWM6pW5BXP5BNGZiYeQ8ez92PWx1Wj.9HGUC0cmmdnluCLA0/Aua	2025-11-18 17:04:19.578	t
168	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$6uaDTuuBVIf8.5knvpQeqeGiEoNwQNm83id/fZ97L9jjQ4pALa5He	2025-11-18 17:25:42.434	t
169	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$t7TNYadA1RNiiI.l59IWbePdh0EOJKfTCrChw9cMh2hOK2KJ73dNu	2025-11-18 17:27:57.738	t
170	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$32Y.hEG7jwwye3MS.aH8HOZugNAu2t.utEi6eB3SPeXA1xl24AyHK	2025-11-18 17:28:49.189	t
171	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$kopLWrh.rx3T0XvOyU6YTeBbiQlNfKyDnjuqxWtRm0LSmI5Nz5Mr.	2025-11-18 17:29:34.75	t
172	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$9SfoFROr12PNzEHMbbaQBOZ002wYX2TA0vIXwIdgJqqEBsNdTKV.u	2025-11-18 17:49:17.408	t
173	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$2MxbxnXn4FHMUKBIrV.6TO53DecVbwtpDzLtQcK9yNecvgXbOhZHq	2025-11-18 17:54:32.464	t
174	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$seWUQH1lvLmGtvPWrA6ofePIYCCMUkTW/ssDp0XjPXb/07OPff5UG	2025-11-18 18:11:50.754	t
176	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$Wtw3KWiorwa7GN1F8Nqry.Ba343eKEBtJSAqAX0Oc/BVGIaFLPzTu	2025-11-24 14:35:25.874	t
175	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$I4pUHYhhV20mvU3WaB71Kul32LIobbaO76f63MmsPgolVBMY3kCXS	2025-11-18 18:12:19.048	t
177	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$o3EgIYQCZBi4C.B6s/4bguasbGR8Y6hHIdeQDlqqk.rL04LxAI3ly	2025-11-24 14:36:57.635	t
178	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$3O357/PFZr.hW2oOP10laOj8POdbaEgsSNRLStHnIhw0SChk3NK5.	2025-11-24 14:38:00.59	t
179	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$OJwtRaaA8autfqX.WwHw9eqhTfApAMJuSkMN3NwIc/ijPWXyYQtG2	2025-11-24 14:42:36.589	t
180	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$l26R/lBgFdLXzoLGoGWu1.wfAFBKRlNLRDMPmBWMwwo1Zu66W82ei	2025-11-24 14:49:05.29	t
181	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$mef5N2dkuxDMoGPAwYG7BuY17Cm/TxEFpcDw3K6VMeRbiDxD9o7r6	2025-11-24 15:12:29.485	t
182	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$TfPgCb5za51AF27LJ8.WdOUuyeYvAn10TbmJOlqZxnXZGFh3pfZOO	2025-11-24 15:14:58.782	t
183	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$4q6BcDbJclICfppF5KyKt.OihkLXB6Wjq1WOWFZzK7IObxXxJYXlu	2025-11-24 15:20:49.75	t
184	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$Dxr.sncglzQlTO1KWqIOCubNb6QYUSQf5zU8BriuJBIhnyAtpg4YC	2025-11-24 15:28:09.108	t
185	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$mF9B31TT9.HHoYCga7FbXug5ZuxWxeupFeCi2vSAbBknEJ6KPs6Uy	2025-11-24 15:40:40.3	t
186	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$yuN84VnDbvr552VGcNezsuPE4pWjNvprorVVpvxlLuw6q/AfCPAqO	2025-11-24 15:43:59.095	t
188	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$WhELY6Maqaf2J1RGkGVvKeGWvNNtP99YndJHBbPIud8y086.Qp2K.	2025-11-24 15:47:33.794	t
187	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$zDCTnPW/qT2DGOfKjgrW1uBZsNNWIToCA9qtMSElZ2igDU6p6N5k6	2025-11-24 15:45:31.493	t
190	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$HU2tDjnTA//E4LU6LvlIKu7KWMOE3tavKVdBhWHCB1nOM7niZ.nRK	2025-11-24 15:49:45.807	t
189	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$t/NhOqjCLRuvN7ZnlmfIo.oahmq9zQD0S2zWSnyDAHL8dilHcf/0C	2025-11-24 15:48:52.313	t
192	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$J8EVGHlti7WBh8mjTZUGXOdIJHDBtOPQb3oLd7NR4TZMLRUHixLyy	2025-11-24 15:51:54.946	t
193	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$BNgC5XFIKOkp4e0DArh4MuCsx7vbX3EE2AhAIRrhmQmnZzMLlc.ki	2025-11-24 15:59:13.959	t
191	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$ErvNvCf8vp5Ao19aVYwqau7SD.fCqAlxyw1PXQs3iFcypdD306gu2	2025-11-24 15:51:25.065	t
194	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$..Nw1ZvKALU5l.VLb5DtgufGcTrkqQA324UdkIxLIwzP7nuJv/gZy	2025-11-24 16:16:57.572	t
196	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$TgDy4U0TSjjYcaekDX697eP203URH4U.L5WLNP0HTzy0YHJFfV5cy	2025-11-24 16:20:54.644	t
195	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$6U6zJBhbWUp.JGy5yTdZWO/y8NXk7GGi.1Jh7k5.k5OWLC5dPEn7u	2025-11-24 16:18:55.999	t
197	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$e2bNo3EkeIzoHFrSl47ZNe5mmxVuS/cfo4rT0B5PgL/EnruyXP80u	2025-11-24 16:22:07.545	t
199	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$ENtvw3XvO2w2TJ/flYYK..YcnVzL34wQ0kHVngnzlN6TlaFEaRMZe	2025-11-24 16:30:33.426	t
200	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$pAaNzSNiCehWq584Stz1ie0b2tx1Ugcf.b/vAjDxqE2UGEMHcVGGC	2025-11-24 16:32:57.186	t
198	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$xVcIqWCM0qEf8h3o4s2D2OiyV7f85a18glOvL2pGlKH3WXrbAmJmK	2025-11-24 16:23:16.763	t
202	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$v7V6VTyXRgl5xgaeTCNZKOnlFaJdwcxQaR4N6.IkjMWa2Ohd06P2u	2025-11-24 17:09:16.78	t
201	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$iaCcKRUMSwtgnoV5FBVyn.uei1V4zpL2lTHP/EKURTOpOuqgbvWeW	2025-11-24 16:38:34.548	t
203	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$U3TOgmOC58Pob1J1FmB/Y.Imtcigx/qwIaMB1tk/yWyZFXAPJGeJS	2025-11-24 17:12:21.092	t
204	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$IxJFolFI3y6gSGngzQ3NbOdubSr2OjwnYsWdiVLP5S2CCjkCyDZ0.	2025-11-24 17:17:23.848	t
206	5ebc8dee-6716-4f41-aada-be40329a2f08	$2b$10$NjZfXYxPjSyfxW4m9DiOMeWAYoRShlEf8W3QoLIfBPXmBJqQcK/CO	2025-11-24 17:44:52.095	t
205	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$K1HEyOfL6ucr0RAgqk9TQObfT9jx7HSD2UAI6S2CnL6vDhEOXYfB2	2025-11-24 17:39:56.978	t
208	5ebc8dee-6716-4f41-aada-be40329a2f08	$2b$10$oj4RpzoJEIUXF/QOFOVMI.1b2K5bD3q3v/mdNNUs53.u0olCIdjvO	2025-11-24 18:00:01.18	t
207	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$NyaoJudkw2z3saKYB12Zt.2Ktg67w5r5PsMmXabazyBEmDmyqO8cy	2025-11-24 17:59:10.516	t
209	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$1wgEiO.D/Vqu.1enC9ikbuq4aCbCEq2JJOxlMI4KYW0VQ/V9hvkYm	2025-11-24 18:04:23.454	t
210	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$slSd.9HOZ8FdV0iPD68qwuia0FlGQk5X16PfUVEO1JzskIqHGpF8G	2025-11-24 18:13:09.09	t
212	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$FVlFSnPxZHf4HUKeCK1EuuTBEJom6dM.zv68CShPV877RRQBoeWfC	2025-11-24 18:17:33.873	t
213	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$SCEMva6YEw7DsAnzxvXxiuAT5.WkPUF1VVidr41Jd2NlSON0CD0iW	2025-11-25 17:44:04.8	t
214	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$PcFJLSP.7XAXs4I6yE.9T.5Bq2mycRrNwYNarbkmiuZQrpb.EBhia	2025-11-25 17:44:30.113	t
216	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$/MtO4R3CSLPRrfMGzJbApuznFm4n6bqXTgomDPmSsqr9nEn82Lz3m	2025-11-25 18:02:29.044	t
215	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$v8z4ka4n/zGw573ivW0q8uaWJqCPW3DQHCEhqTxmm.h1RTyJC6Xma	2025-11-25 17:59:27.8	t
218	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$6QHRtXWv9LicoT1mOjVktOtO6ttr5KcwFdF2uZUO/n5hH0DSSwaJC	2025-11-25 18:34:57.29	t
219	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$PlJlzwxBVI4ggfQi/i2QpOtPHB.AwpvVWG9c4pcxzbr9abN4ZB3pG	2025-11-25 18:54:06.92	t
211	84f94b4f-fdf6-4898-80c4-7abcf7d5d100	$2b$10$RnHo6QaXtEwUSFtYrcJDIOzsVgEbhKN9yr8OquOdpgG8MICcdbcwa	2025-11-24 18:14:32.4	t
220	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$RCRXUmuCunE185nH2KtfEereBSU9K6l575gfxrR6g5TPs7k6rmM.G	2025-11-26 10:08:08.054	t
222	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$9FEi4kl78B5yPDNorWPq2ukIcpDBS2LLZU.87AfsZ5aVT9EVOwSDK	2025-11-26 10:36:19.846	t
223	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$k/651GehdElZnEvrYGjjoO.MXMFvkZ2dIwvIy6MpTrmGk7NamOvQC	2025-11-26 10:39:20.518	t
224	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$IFuLYqlhffM6Kw3BQMdjf.jyyKLjVS3vl2tyrobkjYUonB./AIfkm	2025-11-26 10:53:55.423	t
225	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$t6MDxHnKyTmtDwoktFqSDe4ehMEga/S1IJndMeKOOZdeopN2IHNFK	2025-11-26 11:04:24.722	t
226	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$hHqNF6VJMcAMtp5NT90Bi.wXFytkqL5FQAjnOHpP2c/Ubw3NOwamu	2025-11-26 11:14:05.028	t
227	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$d5CVClt1lsk.NJADYLAzy.ZqENIrdEejVUUjePyyf1oGYqecW0Puu	2025-11-26 13:18:32.563	t
228	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$f03n.RrFXxcx21rChQAMvOzO6n9H.e8QWV6XSYCNI4RoW1o/wTt3G	2025-11-26 13:41:18.104	t
229	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$7TwYityo5R0OKNL/GV1X4uMCauhR.d4Y07rYMNk6hqVKVuD1ELrK2	2025-11-26 13:43:15.065	t
230	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$F8TG7wgMZ86fJmdgV77phumlomWu9dG98s21wxXhpcskM4VwmosF2	2025-11-26 13:49:01.506	t
231	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$lyaRIrAFZ8q6l661gWftGerZO96vitAWYZz.onxIdRaGWsULSYz9y	2025-11-26 13:55:44.444	t
232	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$1FaGtlj8PlpoU53Dv9micuO1DKHYuE0gqzhA.KIfwJoebYjgkvErq	2025-11-26 14:01:51.601	t
233	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$2Vz4Cq9XbOxFVusSr98IwOcO7B6IgYM.yFaGTWcLShrIVUP4HEVSa	2025-11-26 14:12:19.787	t
234	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$IE3xYzA2eVHTU.geCjb.NOP68ukAc6KngQfXP./0.VhZqZbyoipxm	2025-11-26 14:18:36.366	t
235	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$BfKNOZlejs2a6EvPL5umyOKD8Czfy1f2t/oXCUiOzzhMu3KiAGUR2	2025-11-26 14:33:50.431	t
236	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$6sL0bzFfn2SROIYXOf9cR.0RNR4T5ElAZmqMKo/IJ/vqBLnCois/.	2025-11-26 15:06:59.679	t
221	84f94b4f-fdf6-4898-80c4-7abcf7d5d100	$2b$10$5N2Dn47kGANyNhX/Vx3fiOh6RYfigeFZl.UxgK52/0.dgeKkB/KLS	2025-11-26 10:10:56.136	t
217	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$xmRy/giwlpMPlQEC91ce9e8tch9nIOcnFP5.FkinO1TJSpWl5pSfq	2025-11-25 18:28:30.661	t
237	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$lFf5V/2S4nkvFA8nvgAAqu5iRv1SLxcuzhZPJt0g/rCcpz3B3pByG	2025-11-26 15:34:52.319	t
238	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$q5qsjsLkTt4L5BqaeGZTduj5fLgn/r6o/o5fahth.rNE5xfE8pcky	2025-11-26 15:48:19.969	t
239	84f94b4f-fdf6-4898-80c4-7abcf7d5d100	$2b$10$P5NW7clty/sKDh9WO5KDvOB0azlGJSNIbaGj4cnreB2IJylxYSir6	2025-11-26 16:07:21.689	t
240	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$dog0gKb3PgzJuWNd.vSwiOPt.p40ojgck1BffzqP1/xpEw5GnWS4m	2025-11-26 16:08:21.459	t
241	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$ZfcVBEtkkk7pDWjJ8y8hEu/ARIWQJf4nVm3nWnsPjOdlHlY7KygQe	2025-11-26 18:24:53.016	t
242	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$JXTDIGCAIr0KGjZXgUDYte1jGykpKLru9bO1EV5HVOlYwjnftq9sq	2025-11-26 18:25:25.151	t
244	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$YngThRf27ZbEWh8ks2w.wO4inZmpekXVkfzStVwEL.rZm.aJtZ0z.	2025-11-26 18:51:11.144	t
243	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$q8YkYpSNOmgwvX18neeuouJIMPqKlYpC./9yuR2sDuxh17Qo8OEqK	2025-11-26 18:34:42.925	t
245	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$JCbp0qNyPY38uM4yFDoQTOPImtxPCkE6CqIzm7XDh4.Gf1h9s4Fd6	2025-11-26 18:51:13.224	t
247	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$1EjPnYEQLkZgZi7ezaH8De/NA3AFHb1deNuEH8gxs0CE468C3kNz.	2025-11-26 19:36:32.648	t
246	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$Nbh/upN4VBiJJpFOK57Kv.XTGteDQLXnDGAgmCxe15eqGSPtV/MoS	2025-11-26 19:34:44.894	t
249	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$wpW6e1gQFNF7cbOdi3jLtuHMl5oQnOVMP.5uZnVVMwTINn.Q9NzdK	2025-11-26 19:54:55.063	t
250	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$lHIYyRhg1Hnv18JeKRKpSe.LbnrEpph6BXHClisSZZhnUiE2n5AQi	2025-11-27 07:06:12.854	t
261	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$LZXZP2o/C1fkvTYbbntlguy6KocXHXx2kmwQLx3NNVtg4b8FASiaS	2025-11-27 09:15:56.552	t
248	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$Fmd31.FeP6T9qjM5wTNRLuE7HTFS59HXGvko.BZpDwhuI5N91.Uei	2025-11-26 19:54:18.547	t
265	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$weqN4kEo/RcurGpCAORkqen/MEr3xbyf8SpKiMtl7QXdj.sWPr3pm	2025-11-27 10:22:15.022	t
251	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$/ih/9TVQ3FsOGA5OZyhFEuSTRo5FxX8GKe.qg1Gs8LaDg76tD502S	2025-11-27 07:22:13.746	t
252	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$Da6hMxpYUPfYynxniSLi1OF/lFYCnYpI1rv4OmBXCkshKWTovdNOm	2025-11-27 08:07:08.124	t
253	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$bkU0zPe./lzu.NhpBlLKxOc45VIdGHsAbTFRV3w46R1q.sxT5rw06	2025-11-27 08:07:08.27	t
254	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$Dpq42VVdXnyAUG9qIQASEudEw0pH05BrIJpafIJ6dq9TSUGh79Y3S	2025-11-27 08:07:08.368	t
255	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$AT6JJnVQ1UFfptU5CvVqw.ll8WufXK/V/AZ/MkJIlw3U.1oEuSTUK	2025-11-27 08:07:08.489	t
256	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$1PQUXpaccV86LZHAIEero.Ex5c.e7oHzab//9FmTNo4cRt.y/W7Pe	2025-11-27 08:07:08.595	t
257	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$2M6UYKqaubT6HxqQ4rS0jeiIBsdg2ZD5yJ3ngBfZuZb50Cc4HzDZq	2025-11-27 08:07:08.736	t
258	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$VYJ1aCfERRzTQ5V8Np25MOQamjfU4fytEmcD7a4VNTwXDWa5clyuq	2025-11-27 08:09:07.464	t
259	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$oxOVHu.HnuV9siYX87h.ueHoGrGJ0D9B7Ivm0pJbiFkAja.sZc8Se	2025-11-27 08:27:24.199	t
260	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$ne1Jq7PPUkpfGcDNCUC.JeQibbnnDg1T.8K5GsWmYwLpuLuDfStcS	2025-11-27 08:43:01.999	t
262	5ebc8dee-6716-4f41-aada-be40329a2f08	$2b$10$XlGCEiG/l3pxMgsHIjJwY.OsV80.G5gcwXTYEVbqpj43.L7Eaql4i	2025-11-27 10:20:59.234	t
266	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$wTvucAPqscmmTqt3/R0r0eRqJKSs5dJ0JtW96H.Vk1tgpDV7YMPSW	2025-11-27 10:23:45.917	t
267	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$KOSFNyY.TYICFaKbu7qeROcGxvSvKEtdISnVRCQWkrP0YGuE2JF8C	2025-11-27 10:24:41.855	t
268	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$a8xZGqdluMWBWu4TNNf/K.TZx3fNnYve/iN/7o/yLT9bhxEM7HjS6	2025-11-27 10:30:42.049	t
269	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$eq1opP82ImdSxp9/JRhmOuQecOi636q3aRGuStlAt58DOGQ8pN/4y	2025-11-27 10:48:36.706	t
263	5ebc8dee-6716-4f41-aada-be40329a2f08	$2b$10$m6tVl9J7EH.ioHaafUPb..zE/6/wJYFphcGYarVuTO6tLzYNT8ojS	2025-11-27 10:21:20.43	t
264	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$ZrFkc5QjBSboeH1NpbwSE.E7LvprnOB2sUoAWkOqv.AJd0nqg0x8G	2025-11-27 10:21:49.52	t
270	5ebc8dee-6716-4f41-aada-be40329a2f08	$2b$10$d9Ldko.VaQ5Ip.KUXze38e39CredQPweiNdM1uhCBDzZb/OKLNfim	2025-11-27 10:50:47.234	t
271	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$8HYNgAD/ROG3wFsMraPpp.Q3pDpMU39ouJ3KMtdPZ2XfyK5l3dOEy	2025-11-27 11:04:44.045	t
273	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$nwzziYcP56OkwKd0oFn.jebEeeZulzn/7PunvAXopdvqdabQCZhTq	2025-11-27 13:53:19.987	t
272	5ebc8dee-6716-4f41-aada-be40329a2f08	$2b$10$KAFJeBwk/yIgW2sFN.Gq7udtB1oCiJSR7c97aD2zz8hx5o57NNnFK	2025-11-27 11:07:36.444	t
275	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$Wq02VvRBKyWKzuA/dOq8Wefs6M/Fc4Ivkb6w3FT7OgR55eSR/VlNO	2025-11-27 13:59:08.707	t
274	5ebc8dee-6716-4f41-aada-be40329a2f08	$2b$10$yhLd.1F/kCdvoWKGKGHq4eATK8Idw7tJyw4z6EXpBLjjhSiNyHe62	2025-11-27 13:54:30.61	t
277	5ebc8dee-6716-4f41-aada-be40329a2f08	$2b$10$/8VZyg26QElW8NJX0E1SZuC4K2FwprJJQ7M.ehJ0jwWwioQWryiLa	2025-11-27 14:47:01.984	t
278	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$86sMs17VtI8KskKhPJLvjufmnM6Rb74M8ecLAi/W2NOG3xYN2qc.e	2025-11-27 15:08:26.247	t
276	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$V4YYAI4bqPV5JHfljAftKOkhUOrv/T9d8Vh0lbKoAzjqP0upJgGaG	2025-11-27 14:46:03.883	t
280	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$onJdq7KCOTtipKX3SOBD6ukTwj7OsNYqTsRAirL8tEQuIcTkqVKIe	2025-11-27 15:28:39.191	t
279	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$wcZqXBAahaXdinG5vtyrvOUv5j1Qt6Y.lymQf/36S83a/1LrjR/9G	2025-11-27 15:27:02.695	t
281	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$noIbG8pljqYRIwNO9klOrudp5qpLTTRMhzeaqLZ301v3Bm/vZDeBO	2025-11-27 15:48:30.6	t
282	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$yFRUAgt22Fbhx35.XlBtceB.SFWdcXa07dYN18O14ON56mB4taryu	2025-11-27 16:14:27.177	t
283	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$1aycw.ldeXHKj7pL1VJH1eNUJRj21jLRXpMlf96.JwzlG..P3Ld7W	2025-11-27 16:14:27.424	t
285	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$h2pbtDHXFYPTBLqf4PPdzOyeUsVgsEHE0V3kkMCtva0nQgOgPopum	2025-11-27 16:53:54.344	t
286	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$uEcSs4ibXzEgvQi5oZH0D.Td096emXS./HgqxaeUWwahkiIDwVQEe	2025-11-27 16:59:55.912	t
287	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$krolQf3Gg5fzHvfDqryV.e58G5ahczNI0TVrm1DUAQvK6GrFthTeS	2025-11-27 17:22:34.037	t
288	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$K4z/EVa/ECPh/GglJGDeiutvmxGmCgZqNpf/XvSj0RAzl8mXi1gb.	2025-11-27 17:29:22.401	t
289	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$HTYURavBCwrmeUQ7fhTd/.IC8fj6vavm7LWoaR22QoDfjhxj47BpO	2025-11-27 17:50:20.228	t
284	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$4BXPruBKowhAjE1KvXLdIuCZFRY4Z6VNQd8amOacjZk.TONiH1My6	2025-11-27 16:14:50.585	t
291	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$d7FXGOHrPeH4Y3yidYrJ4ekI9BmVUqPV0AoYI8pdrIOGevnPIeR2C	2025-11-27 18:03:20.98	t
290	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$Kt8W4ao34dMW.FX69hz1meWarHtyL4z2YFAGTulHxVggkhPjYL5ZC	2025-11-27 17:53:10.185	t
292	5ebc8dee-6716-4f41-aada-be40329a2f08	$2b$10$37Sqmk8TACsn9jnjvEM1PuVX0feYuqc7/czGHpbIy2oH7udy3Xb.u	2025-11-27 18:05:29.193	t
294	5ebc8dee-6716-4f41-aada-be40329a2f08	$2b$10$hFb/X8cAQVZ5xiJne7rJYe1UMkqfydmxgPpgF2qe7uXUTvH4ljJQu	2025-11-27 18:17:47.873	t
295	5ebc8dee-6716-4f41-aada-be40329a2f08	$2b$10$fo9xWSv3Y66Ye/JeyBHr/uz91IWE6c3SdcPrALC3taG/1CVmHZAYa	2025-11-27 18:32:59.005	t
293	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$ljHHCvlNTMtI4UAFrMKR6u7EI4BYBMYnsF90jr7ACN0G6hVcD73h6	2025-11-27 18:06:31.735	t
297	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$ypRE8BVfTLrT2JXdoDpaX.wXMOe7H0FRHQAAvFVrFwbTr7FkTytP2	2025-11-27 20:03:02.731	t
298	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$Yx5eQrFbv4kJ1ztOPbH5iecHJHP3TSioooRw2FlF58D3rQL46Oqim	2025-11-28 04:15:06.269	t
299	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$rB5s4t3.TwIp0uvxX2Yfn.T0Z2PwzAJzpNJ9zUrWPepLmvEcDqv2u	2025-11-28 04:54:13.857	t
300	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$ET37kbSv8oIYzoboqo2e7.clEpdKGBQKc4csy0JTOiUxLrD.U696O	2025-11-28 05:06:00.355	t
301	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$dVO8qb16d0o31WCER5ukFeRvr1M0vbGm6L647/a8irav4u5dEbJpu	2025-11-28 05:24:36.87	t
302	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$RE6g2E1A7i91OXPHDdikduV1w.dcM8uW7grN6/rjIIphBI/Ibtn6a	2025-11-28 05:36:37.693	t
303	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$G3AqmXIDi56U0P8CnvbA4erau88JLXkQ0Es60McVwH0RkJMVLn946	2025-11-28 06:07:04.071	t
304	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$frtB/d9GK61m5xatL0WPGeMgnzICkaXqVpV/dI0nyd9Hy5vcJwLam	2025-11-28 06:22:18.21	t
305	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$wTxEh2JByZx5mZwADuoVtO4ZLWa3CGSvFeCHfZuZ8W19aFq4aouVm	2025-11-28 06:24:25.942	t
306	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$EUYt/Bn96Rd/nA2Yfc1sK.5TChnh6OFhjLg.MLyCMX3ECa82EB2Ce	2025-11-28 06:40:41.404	t
307	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$on.EBvKu0arPLitLl5jju.qo9GdvmjC2vIOlpFeM4enaEEfPq3G/O	2025-11-28 08:18:20.785	t
308	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$cHco39TBFAKUuUT1.9X6ZOI8V3BVQ4PLcd5qGS8I4nlEloF9V0rti	2025-11-28 09:00:08.527	t
309	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$EEAGoYX8EIKppreZN4fXZuA8su29AA//9V2CRJfWB4ChDMiisuiO.	2025-11-28 10:06:19.845	t
310	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$EnvuMkGmd0DeOFiokgf4teALFho7DfBMfy5WuHUYNoJBsBjJjqmku	2025-11-28 10:29:09.965	t
296	5ebc8dee-6716-4f41-aada-be40329a2f08	$2b$10$j/wwMwKPkb.vgx69h5p2Be00t9wbxuMgbHei7QCNrdDzPwzC37Mxq	2025-11-27 20:02:33.758	t
311	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$fRCrRFjrOFNv0bpLQbryC.ELt6GStCsg0Tv2Z7MZKRAS.n/AaKaFW	2025-11-28 10:29:50.885	t
313	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$CK18po7mxmHzadqIh1Jm1OYdWsrofODOqIgxJO4myoVb5fSJdYLim	2025-11-28 10:55:08.708	t
312	5ebc8dee-6716-4f41-aada-be40329a2f08	$2b$10$iQROopsBCsYZWFLDtd9Bs.hWnVgtud8a3JPei3LXhQhX7hf5yXlDS	2025-11-28 10:49:58.285	t
315	5ebc8dee-6716-4f41-aada-be40329a2f08	$2b$10$j/RBHSbB/BgzJTgM/2TIMeEDQzDH.j67edV4Fr2tcooRYRKRX/1v2	2025-11-28 14:03:11.571	t
314	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$BJ2HZYxwqP0Chxh/BwdGy.x2p1OLjLzgWaGU/Cg6LvHYlnY1.h5xC	2025-11-28 14:02:14.634	t
316	84f94b4f-fdf6-4898-80c4-7abcf7d5d100	$2b$10$xfu52QYi8tAQqKW7ue0bNuycZYYJy6.zTPyl8/AaBUE0zrhIXUrHO	2025-11-28 14:10:52.287	t
318	84f94b4f-fdf6-4898-80c4-7abcf7d5d100	$2b$10$tnt3IZGlxb2z1zvKCe2fD.xoayYeJSLU/Pwa6rJdTId0tbELx9qMe	2025-11-28 14:24:50.718	t
319	84f94b4f-fdf6-4898-80c4-7abcf7d5d100	$2b$10$r9QkKApX4YRY2xB2h6gjV.rzMDpYdPdCmVqenLTQ8CqVp9dYCKLIm	2025-11-28 14:34:51.627	t
317	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$W7Sx7QHQMfAivB8j0/GMFOWr9zTR2pH5elfj79VIjxK/.DyO.8ydS	2025-11-28 14:19:05.322	t
320	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$B971ENqJlgdyKZGgeZnAC.AmUQjuf46X962kFayAdsWpyqiYfFL3G	2025-11-28 14:49:48.271	t
321	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$aNXtqxf5/JPibbfDmlmKLetiJdGZkBAYtQIHFgpPAPTEcK3rHqawi	2025-11-28 15:01:57.813	t
323	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$gm2Nyx00wXZBVnZ0zbSbIOtcQpbFy/fDUM5Zh1qrt/mofoFuJvuvq	2025-11-28 15:31:26.82	t
324	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$lJMZY91VJqvj0.oLVz7ag.BUnICF.0ZBzKvVHrrmAXJw8TD.w9Gvm	2025-11-28 15:51:20.28	t
322	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$50zXo0Lc1Y5k6XEvL1ZiB./l32ewDa7/9vDEVybC2BVLjKMSFc8P2	2025-11-28 15:05:00.036	t
326	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$Pl8zrjCbIUFmWuuLWUG/T.UvjcAx93VtHsHBOj86KReelm8OI8DzW	2025-11-28 16:06:05.409	t
336	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$zglxjMRIP6CtsHuYKlCEi.KE1fMpyZ/dqq4glL8OD5mbHx3O.LfrK	2025-11-28 17:34:53.36	t
344	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$ntXEYW1RnuOLKEdf62i9B.FCCUxZAxcCDGj3uO.0tqeof0g.qKnLK	2025-11-28 18:22:34.534	t
325	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$AFWuORzsANaRO7YZPv3Jw.vfcsZfhpz3KE/WJ8e3Q7lyjyPR1hjNi	2025-11-28 15:56:44.948	t
327	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$CxmRgi6pqxCR3T1bskvcj.yYqFyTLR.j03ouNrEe4IP12k8v0O0OC	2025-11-28 16:23:42.37	t
332	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$uSfnmivjhAIkGTWaD/0Fs.UtiPFTH7xCbWaBO5PWZ/IhMhYInW4e6	2025-11-28 16:35:53.887	t
328	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$6piNYfO052KIk/53S9aqz.CJ2FzobO8X.El4p3BchDyRLpxyJGwwG	2025-11-28 16:24:46.266	t
329	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$LBa8LtfbjAbHywXGzyqZCeiICY48nEa7KF5hVYDgz39lXpUXEtm2i	2025-11-28 16:24:46.728	t
330	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$lpNh.Qk2Qf.kUQljkzgbc./P2pNDj7TqZGK3Kd0iDK4EY6tChk8g6	2025-11-28 16:24:46.888	t
331	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$My5akZRfTRlXjcWX26vBZOZJbcDNF71MovOCBivZcGZAs192sPagS	2025-11-28 16:24:47.134	t
334	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$gm3o527GZ6d9TCz0dijkrOnx0Q8qHfSXqRfQP57VEbACvUT8UamSe	2025-11-28 17:13:52.506	t
333	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$DRjVWX3ngQCr794P5XlNUef8Rn/zVSiJOrwlTaQ40jTjO3luZXu1e	2025-11-28 17:13:04.199	t
335	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$hKjkMLUjvJlt.py3rBRoP.rkl3xQUwdADtOQfYvDevwsZQZbn2aoe	2025-11-28 17:29:43.879	t
337	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$V11.VYlVLIKnlKE8QZdwauBJRYY.M3PjpEX8b/P8R9010pLdncc52	2025-11-28 17:53:06.982	t
338	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$myxH52WxgAtUCalat8lnYu.VIfP.ln4bj/UxyUheFW/L7Dow8CL9y	2025-11-28 17:53:41.766	t
342	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$i6MO9.oVOWfpWeoOB8p2cOrp9i3iBIj9w9/JPie4TpwKbDbzk7P5q	2025-11-28 18:22:00.929	t
347	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$NdBawpjRvH.nmEfTy2tLTOlR9g4HCFNYX869HQpiEhYACq3f18hq6	2025-11-28 18:38:41.775	t
352	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$UrCxVO26N8CoUhZlc.dxF.tIT1bEIvajRObW5VSCt1YYTUWCLoOHu	2025-11-28 19:05:08.183	t
340	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$vCYh.EUr9pFJgqjuWwNOP.Jclu5qftY/boVuQK6FQXih6wtxt/9qa	2025-11-28 17:53:42.183	t
348	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$6pSq0EJaOm5eps.ZMW8Y0eXcBSaj49EnhAUbL6mDStokRaUWzwIna	2025-11-28 18:38:51.617	t
339	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$WDfHhWF8G4YnOpgd0DgrvOr9TDkzBIyikIBpIX4F590MZaSetuQ36	2025-11-28 17:53:42.025	t
341	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$SJ3tS0dvppkMEr1ksbGvJePqmROeQNQIgaia0HqrbvJ7xPmrTL6je	2025-11-28 17:53:42.554	t
357	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$ExV2DO.dahnVvOmm6zMQJumRisUDI19w6FqZ/YMCviCbyW.0Da9C.	2025-11-28 19:21:49.961	t
349	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$UA5BXgz4zXdk6y/F/SayV.OHcvHkrWdsD6EmQdxWRVLhH9D.d/M7a	2025-11-28 18:38:51.877	t
343	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$CDaWnaqwjb.LzO7eRfjvwuFXgLVykio2WTXd2zYBdMwhdVdtIz67q	2025-11-28 18:22:34.334	t
345	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$f9kAqmFDXL.Dkb8isIOTUOIMpUNl7IaaQN7fjFwbjMp6NQ1Qy7DTm	2025-11-28 18:22:34.733	t
346	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$CEuRWbfglWtwnCV3WFB2b.k.6UydmJoYgOIybvBZ39RW7sSjjOroC	2025-11-28 18:22:34.859	t
350	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$AIdEBkCROF0w4dyGckM6NOS17vOT/xssOwX8MONvOtIof2nMqJOHe	2025-11-28 18:38:51.992	t
351	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$5fIT34/LLwL9rdDeasw03OD6ApNZ9oppnXv9dlhDElKwev1/Sp3K2	2025-11-28 18:38:52.696	t
353	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$0iynOBqtFXwgysoIqUClJufvApL7IDBC8HY/.SdoauWguQeqFfbrq	2025-11-28 19:05:36.76	t
354	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$fGadv0nBodaVtauUraX4kOMrKxgP7G91kPMSWuk.TOPj6xTP1e10q	2025-11-28 19:05:36.889	t
355	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$54u0rcFrQ2eIRE5JSoQbUOe9zAGb3HSfiI18BlplpdIQU4lbhbtWy	2025-11-28 19:05:37.038	t
356	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$rPdpUt9KeqpcJpsi3..FBOKXGqzr10r/BTLQgRzDTbGYy7FpTFHcq	2025-11-28 19:05:37.228	t
358	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$7zMNXvPpsj/K6H8hBqPTUeW2yNVbjg7vnJHiyAYomM3nQM9bd3aGy	2025-11-28 19:22:29.296	t
359	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$uqxWTMi7ZcfiZHMqVBkNvefaGhxST5I0yGjGD/.Jp7.SsPEFkAxy6	2025-11-28 19:22:29.835	t
360	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$HhRWg3Pq8N98hhNZz3inbuUG6sKQF2FQ0WaZisnHp//82vcIKhRny	2025-11-28 19:22:30.045	t
361	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$0gjU2TsLmnMEDGRROzeyJu516LrkZSLyTNdbNfLAZ6IJlNdeF6ao2	2025-11-28 19:22:30.203	t
362	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$DYqAP9LzsRpF9HZqTfEDHeF0EKNIxLb2g72Pat3WjA64TBfGSauDe	2025-11-28 19:23:59.341	t
363	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$W.T/7819a12cTSq3AUfUQOaV1JCo777EYk7LVBfqq96ItaMZD9qQe	2025-11-29 08:08:07.889	t
364	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$UL6dsrjER5hLmF86rnbkWOGmaezidLjCtLF0co68g51bNAfep87yG	2025-11-29 08:08:23.809	t
365	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$y3jCQehs0DrPhmQ31UolkeoM4UWinFG8oyuuNLsPFtkk2YBBgBfwW	2025-11-29 08:26:30.672	t
367	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$eEuyj0/vV5ueNLTX358LXO1DEVvU70//wxab6tskxCIZsjcwzg9f2	2025-11-29 08:30:29.673	t
366	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$ZiB9NOTmkspYHa2ZjF0Nxeq5gxwTc4rBnmwHDqLgMOA9iHfhrOAEe	2025-11-29 08:26:47.134	t
368	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$.9dP2VECH5OS9rgMV6TK..y0w1nvZUxvspNHdeMkgw7J7uB2srbiS	2025-11-29 08:35:03.932	t
369	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$xNk4q5XHGWgBjsxT2Yw0LOXqsXTy0ZDO7WF7PQlsIK/CevClenyrS	2025-11-29 08:57:27.729	t
370	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$jX5idYpDbeJ9JRpxZFj4vOTRDluZIydZFubUQrtPhrAKITWn2L1S.	2025-11-29 09:03:18.959	t
372	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$Zbdm3U/fEjSyJ5cTTZjxOO7.yA77LOsmCF6wE6Yuym/16FXidabrq	2025-11-29 09:15:44.765	t
371	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$dO6KkYWOCj1hBBt29LYClOpM4nh9ZL7V5V0sBTEg/2zyQVOCJVDSS	2025-11-29 09:10:38.619	t
374	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$kZFJjoYE4kgsv6RAT/YJNOwtBYWp748RohMi7h/7mO3h4/mGv8gsm	2025-11-29 09:36:32.179	t
373	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$PpDwkGGxt7lEkmsw8M7H4eA7WOQpD9yM1n/38N3gPV3OLXBfE7Oju	2025-11-29 09:22:24.652	t
375	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$wDQGfz3SYYxxbPbJ54GCrO0qpus6iomQKzq5pbQog1d6PJi/tuCZK	2025-11-29 09:40:09.243	t
377	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$9JMsKZnpMyXgbCZQF98Mh.ue3a5uT.z.QKAhXUx78hiY7asLgRZk2	2025-12-02 06:29:44.041	t
376	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$H/.jMXl0lI4JL6e/dgS2Ue.45FBCGx63cmFX9BAWfnIYCWPPq./ZW	2025-12-02 06:29:33.601	t
379	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$fts/.NyoaaSxfwgLdx2uAuotoyHoqbUjs8kDTbm4SxpVVaJLDlWK.	2025-12-02 06:55:53.074	t
380	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$5RO41ThVYDY/fZkx3xk6keHpsMq.MlwDBvG2QGLJYWcI4hlbn/mnG	2025-12-02 07:03:30.936	t
378	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$kc6ayg4iF0J0EJm9qA80xefOnaHApEtgnHQH66Me8pf4ReoQp30We	2025-12-02 06:55:48.261	t
382	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$ZVjVS4G/TqoUpnR93d015uGIjsXEn9dfxHjC6q.osdU7V1SNu11ai	2025-12-02 07:18:40.168	t
391	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$BlIJj4UrKfhTJrmgXj1AC..C7.clSaZT5Vtaiahy4yz8fMYxWy6e.	2025-12-02 08:09:48.53	t
381	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$ke0dasM0vl.GwGsKPmuRuenUynqBwNoGOCsEeVnLRMu5lcb9FVr32	2025-12-02 07:12:15.694	t
384	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$/vojub2RlJqpTtdNC2U94eE4YMzemGMYVj8ki/esDb3GU96QBSgNm	2025-12-02 07:39:29.957	t
385	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$M9HrrSQgAPWBMDAUQFZpj.ou6O.A/PJdWVK6EP9jRJiHpi9j2Ehse	2025-12-02 07:39:30.15	t
386	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$jlJ2xfMqiE013K4Cmbtq1OqPqJrFQleMVr1o2UTFhggZvpJuy6Oba	2025-12-02 07:39:30.296	t
387	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$9rhTMJezofb6bh2G6QtHPO5rD6yNEKMQFa9b2/ktEfbxFPAz6Z0EC	2025-12-02 07:39:30.423	t
383	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$NV0XCI88NoMWIV979eKfY.Ua0bYZ0Xz8rZwy8g.EGcwyHFcgUvOcq	2025-12-02 07:35:32.779	t
396	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$PNbb/XjN78vvj9TUSJj4s.MlJp5O0KNsdBPDXcy./pKAJ8BV4oYHC	2025-12-02 08:47:47.14	t
388	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$9TnCpZ6mqbsh7RGtdj/W9u.vWsgRSLIXqMLfF8FA3PZTjOsOsVkmS	2025-12-02 07:50:34.359	t
390	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$aBElRIua8J7.FPF.XgA7OurDyTQiDhcFhnRxv0t8Y3C1rWiix5IZC	2025-12-02 08:09:48.338	t
389	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$65MkQO2r1m.4xD0K1a6cy.X7weD7uZgmTSof99jXxCu8.A96RArZi	2025-12-02 07:50:56.776	t
392	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$d.138sbDJZcBvlH8qb8c1u6Tqvuv80U6aQwdDEM7FlbpMwzSiao7O	2025-12-02 08:09:48.723	t
393	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$JuAOMa67x8HAni2H0wCQ3eHZQ1zZrapMUdAU1lUPA8WnNPKOlUOtG	2025-12-02 08:09:48.873	t
394	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$H70.xXxN.nk.WOvRRegoO.UbhbLe7AeE8V27fIImCKKLbk.DKTSG.	2025-12-02 08:31:50.814	t
395	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$NyrMXg9gE3oORPADZ3aaxO4ChsBq1LNb31FBwPpGjmej0KOtUtvDS	2025-12-02 08:32:21.98	t
398	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$DOFrs72EWuIemKaXnC31keeDosla7CATt4H7jprRl.soqS2zVYHs.	2025-12-02 09:06:22.614	t
397	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$hIzef5VayCzM0NXoS9vj5OFpwbv2lzX35uNLa0L3hc4ZwqLP57Ezy	2025-12-02 08:59:33.385	t
400	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$GzD7KSYM8nKnVAVm.flvDeQcqLeRZP4dUoVKII.xrWhqI0NK4RUsm	2025-12-02 09:45:33.761	t
401	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$i2D8flz2wg9oFQKReF0JQeSNPYWSL0veU613P8/0lCMdZlCZIoSyS	2025-12-02 09:53:33.724	t
402	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$lnoJblULSOgt.rvTHdyxkuv88uVN4huM2RXqMwQmOxOJrPPm14dRG	2025-12-02 10:04:26.016	t
403	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$YP9pojY4M2oztCUOjtf40OtMLrDmqj7xhwLa2jDOvjLfbIBu3mFqi	2025-12-02 10:12:49.634	t
404	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$UPW9zmh62OTPuwYPgRKZyOEgopoHYT7WuRoGDDgfv4ewyUl3wwlIC	2025-12-02 10:19:05.995	t
405	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$lTZKL7HGwYjNHjdnnF9nJuOn1dyTRBXNZFLv/R8hVQq..LMCepb3W	2025-12-02 10:33:53.874	t
399	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$PlajpUyfuTcyudQGEoeuMOi31XxqgvTvC2YmRO.dtLx5ukGLG2Qa.	2025-12-02 09:44:17.352	t
406	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$9Sku0d3snTmWxkwisolsOeC.pBkOeseoJP/1VnTMXrACI4KCJTXGq	2025-12-02 10:40:25.011	t
408	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$du7ZoCmnlG3ZOSbxgcCLaO3wx35EBSYsXYkP2v3XH/ihY7tTSYRyO	2025-12-04 02:58:09.102	t
407	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$xJ3NEUnjKsKG1CJKBtwSReKGIpd9fzQD9caQM1qTGVHBHjY2Zx6eS	2025-12-02 10:46:36.497	t
410	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$6HEkf61K.0u8OZGPGV3aj.E60WaAb7XL1ucW73zP6fMG3xO77AOkC	2025-12-04 03:00:19.118	t
409	5ebc8dee-6716-4f41-aada-be40329a2f08	$2b$10$mkAMgse4fpxHQGQY3/OEvOJhkKVYKuw2gTYY4h4ddvXPQ098Wah7S	2025-12-04 02:59:53.48	t
430	5ebc8dee-6716-4f41-aada-be40329a2f08	$2b$10$Ud4i6UBtqU1/cjwDdTpoyOk4sIWk3/maQXEXPyPX45rQ9n7BlY/82	2025-12-04 04:40:19.002	t
428	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$sqqx7e0RfOvTTR64ccb7AO6ThqXgfnt5drryauM7mtBf5pWKbYWem	2025-12-04 04:40:15.445	t
411	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$bO2fLX5pClRzs27FXnI3DOEDRyBbNRW5i5bbuLoFzf9BiChXMF18O	2025-12-04 03:16:36.803	t
412	5ebc8dee-6716-4f41-aada-be40329a2f08	$2b$10$834DGM1/7lRZl.jPcjGBIeNTYaA8RvxGO6Y0ha67BaJzUZB3NuJ4.	2025-12-04 03:24:50.6	t
431	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$ivJ.6dDes0NZU3gwDboeUOlhHWzArVzphIhftrvAr43n2qB9sgX3G	2025-12-04 04:41:26.604	t
432	84f94b4f-fdf6-4898-80c4-7abcf7d5d100	$2b$10$AQJ2UhuYrXT.FXLZRy4Nyepfp5v9Si/gcIRHQ6xQ0eX.w9cJFiTJi	2025-12-04 04:41:50.659	t
413	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$o1dJVKBm1Mo007BlympJt.5AscfKeaDOPqw7Y8BSC4YYGFd9Lu5Le	2025-12-04 03:49:34.248	t
414	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$//0Lg16PemG0NqDXdRJuX.qy38Aftj.Bw/S4T/Mlhqtr6gDoqz3GC	2025-12-04 03:49:34.486	t
415	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$TLOIxRshaiEY5056R3Hhgu2c82NVZbqzwelB1urGZZmZJOmTPiNB2	2025-12-04 03:49:34.71	t
417	5ebc8dee-6716-4f41-aada-be40329a2f08	$2b$10$YQGds83SVumBbba5VPhaCuf4vb.EINr1kfrox64s9mHBnWnMZCUFe	2025-12-04 03:49:45.62	t
424	5ebc8dee-6716-4f41-aada-be40329a2f08	$2b$10$RbEl6kLP9h3RXepnuwxgJusKIMbSjYitaunEfPOS7o7X1zfUQjfzu	2025-12-04 04:15:26.767	t
416	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$jmHg4ub5SY9s92vugg9FFeJx6VzgZFY.KpbfDApq4OL659k4YqYAi	2025-12-04 03:49:34.941	t
418	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$tl.Yc8sINb24dMf/EhMM0eKYB9AiK4N2R45QgPz/UG7TzpeMpg6H2	2025-12-04 04:15:20.239	t
419	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$fdbh8A.dsa.g6sou//uI4.ydDpBmZsWUZlv1uINGWLNfYuPLo5n6i	2025-12-04 04:15:20.577	t
420	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$CIUXBVhGsSoOjuhpDBu2ueMtQ0Vk0tnDJaQ.XJRrNhWqEWnJE5bfa	2025-12-04 04:15:20.76	t
421	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$K6CPMxo.G37wYSRHqDE0mOyMh9tZurpaGYLUk.mUHbdYt6o5wpK7a	2025-12-04 04:15:20.935	t
422	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$Hbu0UxpUXP/il95Kj1O7hewpJgX.OotrQ89Bqvl5uOhqN/cC2lljy	2025-12-04 04:15:24.416	t
423	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$cww.YwdkHvbwlOfhHWgICeqOHVA3kb19YApNvuClQ7ostpO1rYbUe	2025-12-04 04:15:24.561	t
425	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$a1OG9ifCcB69lkreXGGNbuY8PHAcJzBss1HVXsPd6gGQvpj2FFK0S	2025-12-04 04:19:20.763	t
427	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$EM5318Ho90ZDXpopqTmKvesE7y0iY//nGticM5sRlRtx.LjDrx2P6	2025-12-04 04:40:14.636	t
426	5ebc8dee-6716-4f41-aada-be40329a2f08	$2b$10$DGvSHanp2zzduhke3skeOeiBerHQLEwMFzm1kdKqasIHn6TfrFI1m	2025-12-04 04:19:45.254	t
429	5ebc8dee-6716-4f41-aada-be40329a2f08	$2b$10$/yen2end8uwLFqFzMFTmi.v2NbZfnC6DSQ00LbunIFsOJoptWCz5q	2025-12-04 04:40:18.094	t
433	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$n//wIboRXLz7KAxLAtQZT.20IuLWtrOCEUyN73lziTINN7xFMSVD6	2025-12-04 04:46:40.391	t
443	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$ztm5v0UBhGw/1zyLfp.MJ.owjz0nxQe3127rKcx7x2j2BIE8zGhvG	2025-12-04 15:37:15.376	t
435	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$U.ztXWihS1mFBlxYSJgdk.w7EsCYzkNsR1JOtuhUBOch9wFCUlddu	2025-12-04 06:50:11.041	t
436	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$llCJUT1Le4VRQ4G0esGSfu7iVd9J7J7j5VQG048E8kpWwcljTChVm	2025-12-04 08:07:24.777	t
437	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$LCFeIQg7wQ8X/dG/23nyUeZ/HQcVgj/lVJiWpMri8BNfLdiqpJbfy	2025-12-04 08:07:26.821	t
438	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$ISMsoDbyX4shOlJu/1Md3.PcOPPLsot1JuACK7uuak1riF6ACs0fK	2025-12-04 08:07:59.285	t
440	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$ytxcJvVGIIjXaJMWibqrVO8OkkUhN8Rd0geis32uCZYkiVRqeumNS	2025-12-04 14:58:56.271	t
439	1b7dfc8a-519b-451a-9061-c35e0bdf32e2	$2b$10$ZO4RCJ7fyVHYGUxZDdK78.1L6TRDHN9IrjgxAgu8Kj7.KO4euJVOK	2025-12-04 14:55:14.855	t
441	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$7t25.yEpWAxlm2cjf60Joegp9jH3umTfUAhJHRtPEvH/hZlFLQ7ZG	2025-12-04 15:15:21.179	t
442	1b7dfc8a-519b-451a-9061-c35e0bdf32e2	$2b$10$U2BTgcdReu1fL.nHTq.IX.zbF8pKx5.vPgH.QiC.0KDKBsHSE8e9a	2025-12-04 15:15:38.593	t
444	1b7dfc8a-519b-451a-9061-c35e0bdf32e2	$2b$10$MAYyZwaV1H2JfmYgXlVrb.RvJn9qc6icT9nP0qLWg/MN1LEqPWBI6	2025-12-04 16:02:12.492	t
445	1b7dfc8a-519b-451a-9061-c35e0bdf32e2	$2b$10$EIi0w9.tRteAOlrXLmiv2usfqXcQHGtfh6SkusfhOXle6QUuNE5NG	2025-12-04 16:14:34.435	t
447	1b7dfc8a-519b-451a-9061-c35e0bdf32e2	$2b$10$e9uOi5iSrsX1ykwCt1kZw.xOKwyNjayuwrMKMfrR.NRTo3LwkK2a.	2025-12-04 16:41:10.897	t
446	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$NUwJxZj3hhz6JQi3hxrpl.2V8Qq4/ULaZzAEbTFRA4dlc6WaOSG7O	2025-12-04 16:40:37.959	t
448	1b7dfc8a-519b-451a-9061-c35e0bdf32e2	$2b$10$8aThMVSTxN6SbB/ixYCn7uYJtG2QZcwg9LKlBlS/6MyUBXdy/3WzC	2025-12-04 16:41:25.585	t
450	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$HBeH20dd8L0EWrTfXWC9Pewo3V3jsj62QCoH.Noo.ecFYZC6equqS	2025-12-04 18:23:50.948	t
452	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$0/OPhA/WDYcpFYneGR6bQ.jBaq1e4KklxuAIOy6DJPgW6jSLyR.m2	2025-12-05 08:06:12.642	t
453	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$w.xeS6mQILV7zfaGcnANj.aGbnMAAZkwx2yBn..Z1Tb.tGmPuTp7u	2025-12-05 08:07:08.897	t
454	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$Jx7.soNOb4fTtS85B9Fge.wVzFcF1FnvLHtjwDtu9bp1CFtEM58V.	2025-12-05 08:09:44.372	t
455	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$XeaRTRi2.HBJHY5eA3UX.euyyfwA0X/UMpeHPK44qKJJcFsr0KZr2	2025-12-05 08:10:34.252	t
456	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$LQhlnuOQaYlXu2L.qgWLb.vji6UZMU/fyuayAkwDnLhA3XURaiuZK	2025-12-05 08:31:37.613	t
457	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$ICHsNkTNUOailIXiWh4o.uH6HdrJU6NX.xzUQ7dVYRP4TamHSRrsW	2025-12-05 08:36:54.356	t
458	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$mGVk2j2obvg.Xm5BvaCOqeIncmN7JaWegpoO/yBpIIf93QS7Btd6e	2025-12-05 13:36:22.322	t
459	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$uQ7ootHJcevpPIOFU3Y12u3zDwLE8BJzub85UcadYB4dEEYkT1I0e	2025-12-05 13:58:45.319	t
460	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$M7Wmx8IfYo0yi4r.1KlNIOVgyApfEx4KzcrdrQA0lPzth5WvMsG62	2025-12-05 14:20:48.707	t
461	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$Xn4YQAo.0fUxdTOfe34Vs.t5UJC.IHr94KFVH17FSUSvv/EDDTcBC	2025-12-05 14:41:50.917	t
462	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$U8aJB/4MD90sGPxfcPU0SuIAIAN3MWBZ25Yq4BU1gEtnj.cwxquwW	2025-12-05 15:09:37.026	t
463	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$UjFkxC6FC6GNUIB8TTglEeXpwqF6/fItFwupDHhDGeandjyyStke6	2025-12-05 17:33:58.524	t
464	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$KuaGTleDuHGXdW6IrFcVRu0w2rux6VjDmiUxVp/Kjei0JhxOLqZRW	2025-12-05 17:38:37.233	t
449	1b7dfc8a-519b-451a-9061-c35e0bdf32e2	$2b$10$Xcl.0fAC2C/SB5w8WgS/D.6pWefIWSzBTdhshQF7b95m2d5XKHuPa	2025-12-04 17:40:58.854	t
451	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$Ggoc9p2D0ERL8RbRdTSOre4Y2gWp/12oyFTn2sH.xmyQq/73YJmsK	2025-12-04 18:35:55.473	t
434	84f94b4f-fdf6-4898-80c4-7abcf7d5d100	$2b$10$xZnP19dBkhpqQb9zHED3ROajAv.wUJy1dXjx2UIu2/Txj7AYjo4r2	2025-12-04 04:46:58.217	t
465	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$bOVczmbS1d5rnbOcpxqWpeIuV6Qfhur3iVZZdYBwPtpBcJ1BLIZD6	2025-12-05 17:38:39.608	t
466	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$YO0TS6TMuCE8aVB3VqddnOQgusyXB4gZEuGIQBPMx8.nY.W8DM536	2025-12-05 17:44:19.345	t
467	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$oPz821AS3PYgdZSSsAvWX.vw9ZFgrdhUg0IcC6hNjrqjufLhOHlae	2025-12-05 18:22:25.055	t
468	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$Hf.T6BG5x/GkfD0OknZg3OecYye/jHbF.6IWZJEBEp.6auBMpovU2	2025-12-05 18:46:08.85	t
469	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$bVs7UsNjSD32mYVovTfqfOK4rMvxpETXq1ZiqK/f3diytMeDBndZK	2025-12-05 19:10:02.698	t
470	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$eE5I9poE7uVVeOep.CLcbOY0SvHZ.hR0NNY9M3CPOInR.4fYTv0a2	2025-12-05 19:16:37.751	t
471	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$pmpPvXc/LmUML3cFHUWkh..xV7QOnA6Xj8FI3x5tFpBxF0BiWnq9S	2025-12-06 06:44:41.139	t
472	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$iwjprdvt0cwpmFUseJVkmu9ckDRmXB0udfxtPAZUaNbg5Owpc3mKW	2025-12-06 07:00:20.452	t
473	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$Mrg.XP.15X5nNIdz37noUe6mLV7WRxfiWG94i4aH1dk7PpBS934j6	2025-12-06 07:22:27.627	t
474	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$K8hKZx4TxuRUkphl9QxRRutBGkcK0sk/Dopn/38VJKgC26daB9xje	2025-12-06 08:01:14.036	t
475	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$EXFScIiGexPU1R1YoKVWV..bnwucRT3TGh1bNkQtaVBhFyeya14bG	2025-12-06 08:20:38.603	t
476	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$FMWv8R3w6CTdano6vXbLC.Aueyypx60UxWQ/rSEHONTMhkVSa9Gcy	2025-12-07 16:17:13.288	t
477	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$MTh9/ucWazxDEhEU7w1ILewjZJCdOPfX/UCFfPnm9Usg0TPB5B8Lm	2025-12-07 16:29:46.822	t
478	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$jczMnYwcnH9lq8Zbl2SCI.6T5SYFsk2pdpn.jowtoT0oUYa1jaPV.	2025-12-07 16:38:46.785	t
479	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$z3OC/0NFJtSXSNmAcYZ8Z.G1XU2MDSZtkRrY07UhjBqS5zWmx.jni	2025-12-07 16:47:39.093	t
480	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$iDiSw2wnRzLDjoy8ZXX/G.MBfS.pfmJtOiriDv.RXcrJawTEQBYBe	2025-12-07 17:00:31.306	t
481	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$rBx0k9sS2gNNbIb/0ShGSu2FZ5T1KqhdB0Drho8BNECqWtp6rXciW	2025-12-07 17:12:09.83	t
483	1b7dfc8a-519b-451a-9061-c35e0bdf32e2	$2b$10$QNL/.WkdO8LzeYcZs.G6J.1DDc/uBt3VgGuN0do5dITbMKckgvUKy	2025-12-30 08:06:51.043	t
484	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$kL6OB8gzsTkQZuXLJdQRWe6muqTgEcQmnLiPe4hmyFaNQ1ulJVhiG	2025-12-30 08:10:23.371	t
482	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$0QrnnAhIugQXjJYNcZ06a.kOcQgFZmauS2kTY4gJFF.k88XATx9zq	2025-12-30 08:06:04.25	t
485	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$NofcP8rO0sL8hjYko7PkSu75MyrV156twT2Lp8N1N/nM0Ju0VJbyu	2025-12-30 08:18:31.373	t
487	9520c430-201b-4444-98eb-bd848e07bac4	$2b$10$HvlqgfRuda21UP/UjtHUweyC0uh3.9qS.bp77aPsziD0J3.WKLfPq	2025-12-30 08:30:10.052	t
488	1b7dfc8a-519b-451a-9061-c35e0bdf32e2	$2b$10$xM46139wfyj0XmnYZi8ABOmZmLOP23R2rHi15tAGkba3SzZQ6kNDi	2025-12-30 08:32:55.02	t
489	84f94b4f-fdf6-4898-80c4-7abcf7d5d100	$2b$10$Jg1PO/iiHxcxzPeTIeZ24.IdZn7aPK1XXouySmMQRx.R9NyAdfZa.	2025-12-30 08:36:33.867	t
490	84f94b4f-fdf6-4898-80c4-7abcf7d5d100	$2b$10$abkZjz3igsW/XfW0IMbateigUzQMlI1y46sevUkJnNUTecHZDeYHK	2025-12-30 09:19:19.335	t
491	5ebc8dee-6716-4f41-aada-be40329a2f08	$2b$10$8.Dfu8SjMIFTzDkdyzOIEOOwrhRzMkO2BlE6lXNxSzIdM2QBkzfq.	2025-12-30 09:24:27.3	t
504	5ebc8dee-6716-4f41-aada-be40329a2f08	$2b$10$tMuLUfqEU9wxw4wVrNZdL.lmFxU3359NN1Z2W11kGp82CsboUyW0y	2025-12-30 10:49:01.493	t
486	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$OE.tBXGEmICI/Tg/LkA/PuNzjsAQwUizMK1XQLU1Spq7K2eppXTJ6	2025-12-30 08:23:02.351	t
493	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$mHHUx95fVHxDvasQP64NeOI573rAi3dyvB9Ko11H/sNc5OdUY0Bf.	2025-12-30 09:28:44.252	t
492	5ebc8dee-6716-4f41-aada-be40329a2f08	$2b$10$jTvQ/MBcb1EWTUku.vJ7rOZ/H2/raH/zXi0gZlfHiF.xdU.OnjNAK	2025-12-30 09:27:03.654	t
494	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$oxUq/WcZenn7//R2nJb8G..zMHt4KmXBhov9cq9QBmfW7WCfq669O	2025-12-30 09:28:44.416	t
495	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$48KMp4QCieweOQSTZTxz0eQOc6GMCYseUWekmhPkD5wjO1xu.JVHG	2025-12-30 09:28:44.585	t
496	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$NNFDoaht1vbDMxojid7jEulU6kFR0DcKrJIbSZExoo4NZRTRPHf26	2025-12-30 09:28:44.745	t
497	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$aMRRV/ufkjowmv/KFu9Q0ef0DE0XOTOnRM1/6.45aVzyD0motP1FO	2025-12-30 09:46:12.279	t
499	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$M9HQSo4xW9g5a2F1PAQFM.6UuJaPXsk/nIm3LmFXThUvX4f5U8Tqy	2025-12-30 10:14:03.325	t
498	5ebc8dee-6716-4f41-aada-be40329a2f08	$2b$10$RMOKT0Kj0RAbt6xWkE8O2.x1cS5/LIBlXVtYc7/lT3JHziCipCegW	2025-12-30 09:55:41.847	t
500	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$9RtK4dxoEVxjcaHxON5GIOolo2ufDHDlb91OmOgIPnOU27J2a8iUS	2025-12-30 10:16:14.495	t
502	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$ZtN5rib1BmQ3oIuCvqtQ5O6fT0d5IgRUaAROzJgMd95VDUwnAhzMq	2025-12-30 10:33:47.958	t
501	5ebc8dee-6716-4f41-aada-be40329a2f08	$2b$10$CDfll4qjVbuLtKQxLJ9qSupVVZ.UNn8DsDxXq/xwZ4uWryRhIyzyC	2025-12-30 10:16:59.421	t
503	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$pd0jxs86P6nTvY9JproBau58RoXE/cxWGZqoaY23rqO0KmHvHrMXG	2025-12-30 10:41:53.33	t
506	84f94b4f-fdf6-4898-80c4-7abcf7d5d100	$2b$10$V9Crb4/l4l23NLa1rK7BtODkwA/6hUFkPUyH301hrta8FL7.n7vcC	2025-12-30 10:59:21.971	t
505	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$eDPE5Mg3Cl8IH7M.nLmMbeB5TaFAvc7SLnCBed0tKoTlMWGWJFNc.	2025-12-30 10:54:48.095	t
507	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$mDTy.yyPzlS2M26whSoslOlRqPsKItJDdqFEue4A884HSO8kakawe	2026-01-06 05:42:51.216	t
508	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$l9Wyd/M7w6/WFbM.41X2N.vMR/0QC05lBjkXBgzzt9dsUnwYs2eOe	2026-01-06 05:45:07.437	t
509	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$AcyTTuQS0/AbWT9iu1skWuYVgsVHBvaQgIVGdewvDd5RStdoE3AWe	2026-01-06 06:07:35.63	t
510	8a33cd42-e569-47c1-8216-2a43103129cb	$2b$10$sUdu2eIhqtUrcIbROji0ROJXqfImIpxltWBo0lNpsSffc7TnHpB3W	2026-05-29 02:24:41.22	f
\.


--
-- Data for Name: rental_packages; Type: TABLE DATA; Schema: public; Owner: ducviet
--

COPY public.rental_packages (id, vehicle_type_id, duration_hours, price) FROM stdin;
1	1	8	300000.00
2	1	12	450000.00
3	1	24	700000.00
4	2	8	400000.00
5	2	12	600000.00
6	2	24	900000.00
7	3	8	500000.00
8	3	12	750000.00
9	3	24	1200000.00
10	4	8	600000.00
11	4	12	900000.00
12	4	24	1500000.00
13	5	24	700000.00
14	6	24	900000.00
15	7	24	1500000.00
16	8	24	1300000.00
17	8	12	800000.00
18	8	8	550000.00
\.


--
-- Data for Name: reviews; Type: TABLE DATA; Schema: public; Owner: ducviet
--

COPY public.reviews (id, booking_id, user_id, rating, comment, created_at) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: ducviet
--

COPY public.users (id, email, password_hash, name, phone, is_verified, created_at, updated_at, role) FROM stdin;
c66f8005-2f0c-4eb5-927d-6efdb85ef53a	testuser@gmail.com	$2b$10$iVVIFg..p.1EknSluZHUyeHaF6QrOtuO.7Z4pbIzmcXSvc/umuZPi	Test User2	0123456789	f	2025-10-26 14:21:39.859	2025-10-26 14:21:39.859	customer
84f94b4f-fdf6-4898-80c4-7abcf7d5d100	vietnho2004@gmail.com	$2b$12$BTYYJ7coefViqHgw0er30OPvYp1GntuZMaORLg.zKRLj5u1qHe7sa	Duc Viet	0987382464	f	2025-10-26 16:14:11.326	2025-10-26 16:14:11.326	customer
9520c430-201b-4444-98eb-bd848e07bac4	test@gmail.com	$2b$12$kGrQr9v9cDUwh6.0lAQsB.WFuVCmhXyNgsg.nkepThmxYz4QJPL7a	Test	0967245723	f	2025-10-29 14:07:52.901	2025-10-29 14:07:52.901	customer
5ebc8dee-6716-4f41-aada-be40329a2f08	hanguyen@gmail.com	$2b$12$4T6HSamWbL9wTPjG.6f1v.eH2HYbgjVPejpq8hOtlPpO8F665qJea	Nguyen Thi Ha	098123765	f	2025-11-03 03:44:58.741	2025-11-03 03:44:58.741	customer
8a33cd42-e569-47c1-8216-2a43103129cb	admin@rentcar.com	$2b$10$D0qmhTXFk19Z9YZGF7KnXO/XylbM0g0wE/k0pFxKtWSRdOkEbknG6	Super Admin	000000001	t	2025-10-26 17:21:51.677	2025-10-26 17:21:51.677	admin
1b7dfc8a-519b-451a-9061-c35e0bdf32e2	toannguyen@gmail.com	$2b$10$iJOCcqgGY5GtaKV5RgFeDONWXMuKgxhWRLSRi4zHUVK.0W4urJZPK	Nguyen Van Toan	092463485	f	2025-11-27 14:55:14.118	2025-11-27 14:55:14.118	customer
\.


--
-- Data for Name: vehicle_types; Type: TABLE DATA; Schema: public; Owner: ducviet
--

COPY public.vehicle_types (id, name, seats, deposit_amount) FROM stdin;
1	Sedan 4 chỗ	4	10000000.00
2	SUV 7 chỗ	7	15000000.00
3	Hatchback 5 chỗ	5	8000000.00
4	MPV 7 chỗ	7	12000000.00
5	VF 5 Plus	5	8000000.00
6	VinFast VF 6	5	12000000.00
7	Vinfast VF 9	7	25000000.00
8	VinFast VF 8	7	20000000.00
\.


--
-- Data for Name: vehicles; Type: TABLE DATA; Schema: public; Owner: ducviet
--

COPY public.vehicles (id, title, brand, model, year, plate_number, location_id, images, created_at, updated_at, vehicle_type_id, status) FROM stdin;
9	Mazda CX-5 2020	Mazda	CX-5	2020	89K-923.43	2	{b63e221e-632f-49b1-93fa-3b1c2bc84086.jpg}	2025-11-21 06:36:59.073	2025-11-27 04:49:42.232	2	available
12	VinFast VF 6 – Bản Eco 2024	Vinfast	VF 6	2024	75K-421.83	2	{b60ad382-9e0e-471b-98cd-f9dcc5262ff8.jpg}	2025-11-21 06:48:11.292	2025-11-27 06:51:49.334	6	available
3	Honda City Hatchback RS 2021	Honda	City RS	2021	29A-943.56	1	{6930457b-043d-484a-8fcb-f3996e0d1774.jpg,4c2f236e-50f3-401d-898c-cb948ac87fa4.jpg}	2025-11-21 06:27:34.575	2025-11-27 15:04:19.086	3	available
6	Mazda 3 Sedan Premium 2021	Mazda	Mazda 3 Sedan Premium	2021	30A-745.24	2	{56566117-e24c-4588-8cdd-3df6bcc55b07.jpg}	2025-11-21 06:33:54.34	2025-11-27 15:15:55.651	1	available
11	VinFast VF 5 Plus – Bản Tiêu Chuẩn 2024	Vinfast	VF 5 Plus	2024	37A-897.37	2	{43950b76-7e2d-49e9-89d1-e3b9511072f8.jpg}	2025-11-21 06:47:08.451	2025-11-27 18:26:26.899	5	available
10	VinFast VF 9 Plus 2024	Vinfast	VF 9	2024	51K-742.56	1	{9f9957ad-e023-474f-9c39-898fa97c6185.jpg,3bc50ac7-78a5-442e-b596-e16c650dac9e.jpg}	2025-11-21 06:45:22.484	2025-12-30 06:09:29.702	7	available
13	VinFast VF 8 Eco - 2024	Vinfast	VF 8 Eco	2024	99H-432.49	1	{a4ae778c-31b5-40bf-85de-b2849096dbe9.jpg}	2025-11-21 08:22:31.402	2025-12-30 06:09:39.184	8	available
2	Toyota Fortuner 2022 - Máy dầu	Toyota	Fortuner Diesel	2022	30H-456.78	1	{74b40066-2d51-4b37-83bb-4caec2ce0239.jpg}	2025-11-21 06:26:47.201	2025-11-21 10:42:51.827	2	available
1	Toyota Vios 2020 - Bản G	Toyota	Vios G	2020	30G-123.45	1	{0ec6a89d-632e-400b-9753-18749b65bfa5.jpg,6b4801b4-9451-4bde-8345-8539bbb861db.jpg}	2025-11-21 06:25:34.384	2025-11-21 10:43:59.052	1	available
5	Hyundai Elantra 2018	Hyundai	Elantra	2018	30E-348.65	2	{d43f0498-0bae-4268-a2cf-7e4dcbfd7874.jpg}	2025-11-21 06:32:53.563	2025-11-22 09:23:03.254	1	available
4	Mitsubishi Xpander 2023 - Bản AT	Mitsubishi	Xpander AT	2023	34A-746.78	1	{16339311-1782-45eb-adb2-dbd930ee63eb.jpg,9cad7d86-bf2f-46ee-a760-b48efb2b930a.jpg}	2025-11-21 06:28:36.204	2025-11-25 09:07:37.513	4	available
7	Ford Everest Titanium 2023	Ford	Everest Titanium	2023	30K-342.93	2	{13689135-a074-4f40-a6cc-a464536ff63c.jpg}	2025-11-21 06:34:49.569	2025-11-27 03:08:28.491	2	available
8	Toyota Innova Venturer 2020	Toyota	Innova Venturer	2020	38A-478.68	2	{4170bc2c-a388-4b27-8e8f-502c37facc94.jpg}	2025-11-21 06:35:57.184	2025-11-27 03:30:05.899	4	available
\.


--
-- Name: bookings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ducviet
--

SELECT pg_catalog.setval('public.bookings_id_seq', 54, true);


--
-- Name: invoices_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ducviet
--

SELECT pg_catalog.setval('public.invoices_id_seq', 34, true);


--
-- Name: location_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ducviet
--

SELECT pg_catalog.setval('public.location_id_seq', 2, true);


--
-- Name: logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ducviet
--

SELECT pg_catalog.setval('public.logs_id_seq', 48, true);


--
-- Name: payments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ducviet
--

SELECT pg_catalog.setval('public.payments_id_seq', 136, true);


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ducviet
--

SELECT pg_catalog.setval('public.refresh_tokens_id_seq', 510, true);


--
-- Name: rental_packages_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ducviet
--

SELECT pg_catalog.setval('public.rental_packages_id_seq', 18, true);


--
-- Name: reviews_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ducviet
--

SELECT pg_catalog.setval('public.reviews_id_seq', 1, false);


--
-- Name: vehicle_types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ducviet
--

SELECT pg_catalog.setval('public.vehicle_types_id_seq', 8, true);


--
-- Name: vehicles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ducviet
--

SELECT pg_catalog.setval('public.vehicles_id_seq', 13, true);


--
-- Name: bookings bookings_pkey; Type: CONSTRAINT; Schema: public; Owner: ducviet
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_pkey PRIMARY KEY (id);


--
-- Name: invoices invoices_pkey; Type: CONSTRAINT; Schema: public; Owner: ducviet
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_pkey PRIMARY KEY (id);


--
-- Name: locations location_pkey; Type: CONSTRAINT; Schema: public; Owner: ducviet
--

ALTER TABLE ONLY public.locations
    ADD CONSTRAINT location_pkey PRIMARY KEY (id);


--
-- Name: logs logs_pkey; Type: CONSTRAINT; Schema: public; Owner: ducviet
--

ALTER TABLE ONLY public.logs
    ADD CONSTRAINT logs_pkey PRIMARY KEY (id);


--
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: ducviet
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: ducviet
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);


--
-- Name: rental_packages rental_packages_pkey; Type: CONSTRAINT; Schema: public; Owner: ducviet
--

ALTER TABLE ONLY public.rental_packages
    ADD CONSTRAINT rental_packages_pkey PRIMARY KEY (id);


--
-- Name: reviews reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: ducviet
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_pkey PRIMARY KEY (id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: ducviet
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: ducviet
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: vehicle_types vehicle_types_pkey; Type: CONSTRAINT; Schema: public; Owner: ducviet
--

ALTER TABLE ONLY public.vehicle_types
    ADD CONSTRAINT vehicle_types_pkey PRIMARY KEY (id);


--
-- Name: vehicles vehicles_pkey; Type: CONSTRAINT; Schema: public; Owner: ducviet
--

ALTER TABLE ONLY public.vehicles
    ADD CONSTRAINT vehicles_pkey PRIMARY KEY (id);


--
-- Name: vehicles vehicles_plate_number_key; Type: CONSTRAINT; Schema: public; Owner: ducviet
--

ALTER TABLE ONLY public.vehicles
    ADD CONSTRAINT vehicles_plate_number_key UNIQUE (plate_number);


--
-- Name: invoices_invoice_number_key; Type: INDEX; Schema: public; Owner: ducviet
--

CREATE UNIQUE INDEX invoices_invoice_number_key ON public.invoices USING btree (invoice_number);


--
-- Name: rental_packages_vehicle_type_id_duration_hours_key; Type: INDEX; Schema: public; Owner: ducviet
--

CREATE UNIQUE INDEX rental_packages_vehicle_type_id_duration_hours_key ON public.rental_packages USING btree (vehicle_type_id, duration_hours);


--
-- Name: vehicle_types_name_key; Type: INDEX; Schema: public; Owner: ducviet
--

CREATE UNIQUE INDEX vehicle_types_name_key ON public.vehicle_types USING btree (name);


--
-- Name: bookings bookings_dropoff_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ducviet
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_dropoff_location_id_fkey FOREIGN KEY (dropoff_location_id) REFERENCES public.locations(id);


--
-- Name: bookings bookings_pickup_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ducviet
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_pickup_location_id_fkey FOREIGN KEY (pickup_location_id) REFERENCES public.locations(id);


--
-- Name: bookings bookings_rental_package_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ducviet
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_rental_package_id_fkey FOREIGN KEY (rental_package_id) REFERENCES public.rental_packages(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: bookings bookings_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ducviet
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: bookings bookings_vehicle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ducviet
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_vehicle_id_fkey FOREIGN KEY (vehicle_id) REFERENCES public.vehicles(id) ON DELETE CASCADE;


--
-- Name: invoices invoices_booking_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ducviet
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_booking_id_fkey FOREIGN KEY (booking_id) REFERENCES public.bookings(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: invoices invoices_payment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ducviet
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_payment_id_fkey FOREIGN KEY (payment_id) REFERENCES public.payments(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: invoices invoices_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ducviet
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: logs logs_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ducviet
--

ALTER TABLE ONLY public.logs
    ADD CONSTRAINT logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: payments payments_booking_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ducviet
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_booking_id_fkey FOREIGN KEY (booking_id) REFERENCES public.bookings(id) ON DELETE CASCADE;


--
-- Name: payments payments_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ducviet
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: refresh_tokens refresh_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ducviet
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: rental_packages rental_packages_vehicle_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ducviet
--

ALTER TABLE ONLY public.rental_packages
    ADD CONSTRAINT rental_packages_vehicle_type_id_fkey FOREIGN KEY (vehicle_type_id) REFERENCES public.vehicle_types(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: reviews reviews_booking_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ducviet
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_booking_id_fkey FOREIGN KEY (booking_id) REFERENCES public.bookings(id) ON DELETE CASCADE;


--
-- Name: reviews reviews_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ducviet
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: vehicles vehicles_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ducviet
--

ALTER TABLE ONLY public.vehicles
    ADD CONSTRAINT vehicles_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.locations(id) ON DELETE SET NULL;


--
-- Name: vehicles vehicles_vehicle_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ducviet
--

ALTER TABLE ONLY public.vehicles
    ADD CONSTRAINT vehicles_vehicle_type_id_fkey FOREIGN KEY (vehicle_type_id) REFERENCES public.vehicle_types(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

GRANT ALL ON SCHEMA public TO ducviet;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES  TO ducviet;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES  TO ducviet;


--
-- PostgreSQL database dump complete
--

\unrestrict yAo8ztlvqxT7UX0PBIRxBpN1909ZE2HB0iuCSPpKpreaiQbGgU7jwE74F1vCNnB

