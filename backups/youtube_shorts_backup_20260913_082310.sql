--
-- PostgreSQL database dump
--

\restrict HBpQwBKcPwLLWmubTzNcndoeXBwmsAtc2jImYKXam6fS8kBB7KVbJ2q2vVe3rvW

-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.3

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
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_updated_at_column() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: analysis_log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.analysis_log (
    id bigint NOT NULL,
    session_id bigint,
    video_id text,
    tab_analyzed text NOT NULL,
    status text NOT NULL,
    error_message text,
    data_completeness numeric(5,2),
    duration_seconds integer,
    analyzed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.analysis_log OWNER TO postgres;

--
-- Name: analysis_log_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.analysis_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.analysis_log_id_seq OWNER TO postgres;

--
-- Name: analysis_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.analysis_log_id_seq OWNED BY public.analysis_log.id;


--
-- Name: analysis_sessions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.analysis_sessions (
    id bigint NOT NULL,
    session_id text NOT NULL,
    started_at timestamp without time zone NOT NULL,
    completed_at timestamp without time zone,
    videos_analyzed text[],
    analyzer_version text,
    notes text,
    status text DEFAULT 'in_progress'::text
);


ALTER TABLE public.analysis_sessions OWNER TO postgres;

--
-- Name: analysis_sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.analysis_sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.analysis_sessions_id_seq OWNER TO postgres;

--
-- Name: analysis_sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.analysis_sessions_id_seq OWNED BY public.analysis_sessions.id;


--
-- Name: audience_age; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.audience_age (
    video_id text NOT NULL,
    age_13_17_pct numeric(5,2) DEFAULT 0,
    age_18_24_pct numeric(5,2) DEFAULT 0,
    age_25_34_pct numeric(5,2) DEFAULT 0,
    age_35_44_pct numeric(5,2) DEFAULT 0,
    age_45_54_pct numeric(5,2) DEFAULT 0,
    age_55_64_pct numeric(5,2) DEFAULT 0,
    age_65_plus_pct numeric(5,2) DEFAULT 0,
    target_audience_pct numeric(5,2) DEFAULT 0,
    non_target_pct numeric(5,2) DEFAULT 0,
    has_data boolean DEFAULT false,
    fetched_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.audience_age OWNER TO postgres;

--
-- Name: audience_device; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.audience_device (
    video_id text NOT NULL,
    mobile_pct numeric(5,2) DEFAULT 0,
    desktop_pct numeric(5,2) DEFAULT 0,
    tv_pct numeric(5,2) DEFAULT 0,
    tablet_pct numeric(5,2) DEFAULT 0,
    mobile_views bigint DEFAULT 0,
    desktop_views bigint DEFAULT 0,
    tv_views bigint DEFAULT 0,
    tablet_views bigint DEFAULT 0,
    desktop_intent_proxy numeric(5,2) DEFAULT 0,
    fetched_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.audience_device OWNER TO postgres;

--
-- Name: audience_gender; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.audience_gender (
    video_id text NOT NULL,
    male_pct numeric(5,2),
    female_pct numeric(5,2),
    unknown_pct numeric(5,2),
    has_data boolean DEFAULT false,
    fetched_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.audience_gender OWNER TO postgres;

--
-- Name: audience_geography; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.audience_geography (
    id bigint NOT NULL,
    video_id text NOT NULL,
    country_code text NOT NULL,
    country_name text,
    views bigint DEFAULT 0 NOT NULL,
    percentage numeric(5,2) NOT NULL,
    avg_view_duration_seconds numeric(6,2),
    is_target_country boolean DEFAULT false,
    fetched_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.audience_geography OWNER TO postgres;

--
-- Name: audience_geography_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.audience_geography_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.audience_geography_id_seq OWNER TO postgres;

--
-- Name: audience_geography_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.audience_geography_id_seq OWNED BY public.audience_geography.id;


--
-- Name: audience_subscriber_status; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.audience_subscriber_status (
    video_id text NOT NULL,
    subscribed_pct numeric(5,2) DEFAULT 0,
    not_subscribed_pct numeric(5,2) DEFAULT 0,
    subscribed_views bigint DEFAULT 0,
    not_subscribed_views bigint DEFAULT 0,
    sub_viewer_retention_pct numeric(5,2),
    non_sub_viewer_retention_pct numeric(5,2),
    fetched_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.audience_subscriber_status OWNER TO postgres;

--
-- Name: audience_subtitles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.audience_subtitles (
    video_id text NOT NULL,
    none_pct numeric(5,2) DEFAULT 100,
    hindi_pct numeric(5,2) DEFAULT 0,
    english_pct numeric(5,2) DEFAULT 0,
    other_pct numeric(5,2) DEFAULT 0,
    has_cc_data boolean DEFAULT false,
    fetched_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.audience_subtitles OWNER TO postgres;

--
-- Name: channels; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.channels (
    channel_id text NOT NULL,
    channel_name text NOT NULL,
    custom_handle text,
    subscriber_count integer DEFAULT 0,
    created_at timestamp without time zone,
    niche_primary text,
    target_audience text,
    brand_colors jsonb,
    tagline text,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.channels OWNER TO postgres;

--
-- Name: comments_analysis; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.comments_analysis (
    video_id text NOT NULL,
    total_comments integer DEFAULT 0,
    comments_per_1k_views numeric(6,2) DEFAULT 0,
    top_level_comments integer DEFAULT 0,
    total_replies integer DEFAULT 0,
    max_thread_depth integer DEFAULT 0,
    avg_thread_depth numeric(4,2),
    creator_replies integer DEFAULT 0,
    creator_reply_rate numeric(5,2) DEFAULT 0,
    pinned_comment_id text,
    pinned_comment_text text,
    hearted_comments integer DEFAULT 0,
    positive_sentiment_pct numeric(5,2),
    negative_sentiment_pct numeric(5,2),
    neutral_sentiment_pct numeric(5,2),
    query_comments integer DEFAULT 0,
    gratitude_comments integer DEFAULT 0,
    gratitude_with_likes integer DEFAULT 0,
    spam_irrelevant_comments integer DEFAULT 0,
    query_categories jsonb,
    unanswered_high_intent_queries integer DEFAULT 0,
    fetched_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.comments_analysis OWNER TO postgres;

--
-- Name: comparison_clusters; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.comparison_clusters (
    id bigint NOT NULL,
    cluster_name text NOT NULL,
    cluster_type text,
    definition text,
    video_ids text[] NOT NULL,
    aggregate_metrics jsonb,
    top_performer_id text,
    bottom_performer_id text,
    key_differentiators text[],
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.comparison_clusters OWNER TO postgres;

--
-- Name: comparison_clusters_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.comparison_clusters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.comparison_clusters_id_seq OWNER TO postgres;

--
-- Name: comparison_clusters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.comparison_clusters_id_seq OWNED BY public.comparison_clusters.id;


--
-- Name: content_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.content_types (
    content_type text NOT NULL,
    description text,
    typical_duration_range text,
    typical_retention_range text,
    typical_search_pct_range text,
    shelf_life_category text,
    annual_remake_required boolean DEFAULT false,
    audience_match_score integer,
    examples text[]
);


ALTER TABLE public.content_types OWNER TO postgres;

--
-- Name: end_screen_performance; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.end_screen_performance (
    video_id text NOT NULL,
    has_end_screen boolean DEFAULT false,
    element_type text,
    element_video_id text,
    impressions bigint DEFAULT 0,
    clicks bigint DEFAULT 0,
    ctr_pct numeric(5,2) GENERATED ALWAYS AS (
CASE
    WHEN (impressions > 0) THEN (((clicks)::numeric / (impressions)::numeric) * (100)::numeric)
    ELSE (0)::numeric
END) STORED,
    channel_avg_ctr numeric(5,2),
    vs_channel_avg_pct numeric(5,2),
    fetched_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.end_screen_performance OWNER TO postgres;

--
-- Name: external_sources; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.external_sources (
    id bigint NOT NULL,
    video_id text NOT NULL,
    source_domain text NOT NULL,
    source_type text,
    views bigint DEFAULT 0 NOT NULL,
    percentage numeric(5,2),
    fetched_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.external_sources OWNER TO postgres;

--
-- Name: external_sources_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.external_sources_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.external_sources_id_seq OWNER TO postgres;

--
-- Name: external_sources_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.external_sources_id_seq OWNED BY public.external_sources.id;


--
-- Name: hidden_patterns; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.hidden_patterns (
    id bigint NOT NULL,
    pattern_name text NOT NULL,
    pattern_category text,
    description text NOT NULL,
    evidence_summary text,
    supporting_video_ids text[],
    contradicting_video_ids text[],
    confidence integer DEFAULT 3,
    actionable_insight text,
    pipeline_implication text,
    discovered_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    validated_at timestamp without time zone,
    is_active boolean DEFAULT true
);


ALTER TABLE public.hidden_patterns OWNER TO postgres;

--
-- Name: hidden_patterns_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.hidden_patterns_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.hidden_patterns_id_seq OWNER TO postgres;

--
-- Name: hidden_patterns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.hidden_patterns_id_seq OWNED BY public.hidden_patterns.id;


--
-- Name: individual_comments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.individual_comments (
    id bigint NOT NULL,
    video_id text NOT NULL,
    comment_id text NOT NULL,
    author_name text,
    author_channel_id text,
    is_creator boolean DEFAULT false,
    is_pinned boolean DEFAULT false,
    is_hearted boolean DEFAULT false,
    text text NOT NULL,
    text_clean text,
    like_count integer DEFAULT 0,
    reply_count integer DEFAULT 0,
    parent_comment_id text,
    depth integer DEFAULT 0,
    published_at timestamp without time zone,
    updated_at timestamp without time zone,
    sentiment text,
    intent_category text,
    query_subtype text,
    is_actionable boolean DEFAULT false,
    has_contact_info boolean DEFAULT false,
    fetched_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.individual_comments OWNER TO postgres;

--
-- Name: individual_comments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.individual_comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.individual_comments_id_seq OWNER TO postgres;

--
-- Name: individual_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.individual_comments_id_seq OWNED BY public.individual_comments.id;


--
-- Name: memory_updates; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.memory_updates (
    id bigint NOT NULL,
    video_id text,
    update_type text NOT NULL,
    title text NOT NULL,
    payload jsonb NOT NULL,
    source_analysis text,
    priority integer DEFAULT 3,
    applied_to_pipeline boolean DEFAULT false,
    applied_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.memory_updates OWNER TO postgres;

--
-- Name: memory_updates_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.memory_updates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.memory_updates_id_seq OWNER TO postgres;

--
-- Name: memory_updates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.memory_updates_id_seq OWNED BY public.memory_updates.id;


--
-- Name: performance_metrics; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.performance_metrics (
    video_id text NOT NULL,
    views bigint DEFAULT 0 NOT NULL,
    engaged_views bigint DEFAULT 0,
    unique_viewers bigint DEFAULT 0,
    watch_time_hours numeric(10,2) DEFAULT 0,
    avg_view_duration_seconds numeric(6,2),
    retention_pct numeric(5,2),
    completion_pct numeric(5,2),
    swipe_away_pct numeric(5,2),
    subscribers_gained integer DEFAULT 0,
    subscribers_lost integer DEFAULT 0,
    net_subscribers integer DEFAULT 0,
    likes bigint DEFAULT 0,
    comments_count integer DEFAULT 0,
    shares bigint DEFAULT 0,
    hype_points integer DEFAULT 0,
    engagement_rate numeric(6,4) DEFAULT 0,
    sub_conversion_rate numeric(6,4) DEFAULT 0,
    engaged_view_rate numeric(6,4) DEFAULT 0,
    views_vs_channel_avg_pct numeric(6,2),
    retention_vs_channel_avg numeric(5,2),
    period_start date,
    period_end date,
    fetched_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.performance_metrics OWNER TO postgres;

--
-- Name: realtime_metrics; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.realtime_metrics (
    video_id text NOT NULL,
    views_48h bigint DEFAULT 0,
    period_start timestamp without time zone,
    period_end timestamp without time zone,
    velocity_views_per_hour numeric(6,2),
    fetched_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.realtime_metrics OWNER TO postgres;

--
-- Name: remix_metrics; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.remix_metrics (
    video_id text NOT NULL,
    remix_count integer DEFAULT 0,
    remix_views bigint DEFAULT 0,
    top_remix_video_id text,
    top_remix_views bigint DEFAULT 0,
    fetched_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.remix_metrics OWNER TO postgres;

--
-- Name: retention_curve; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.retention_curve (
    id bigint NOT NULL,
    video_id text NOT NULL,
    timestamp_seconds numeric(6,2) NOT NULL,
    retention_pct numeric(5,2) NOT NULL,
    is_key_moment boolean DEFAULT false,
    moment_type text,
    moment_note text
);


ALTER TABLE public.retention_curve OWNER TO postgres;

--
-- Name: retention_curve_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.retention_curve_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.retention_curve_id_seq OWNER TO postgres;

--
-- Name: retention_curve_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.retention_curve_id_seq OWNED BY public.retention_curve.id;


--
-- Name: search_terms; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.search_terms (
    id bigint NOT NULL,
    video_id text NOT NULL,
    search_term text NOT NULL,
    views bigint DEFAULT 0 NOT NULL,
    percentage_of_search numeric(5,2),
    percentage_of_total numeric(5,2),
    intent_category text,
    relevance_score integer,
    fetched_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.search_terms OWNER TO postgres;

--
-- Name: search_terms_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.search_terms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.search_terms_id_seq OWNER TO postgres;

--
-- Name: search_terms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.search_terms_id_seq OWNED BY public.search_terms.id;


--
-- Name: short_analysis; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.short_analysis (
    id integer NOT NULL,
    short_id integer,
    video_id character varying(20),
    views bigint,
    engaged_views bigint,
    unique_viewers bigint,
    watch_time_hours numeric(10,2),
    avg_view_duration_seconds integer,
    retention_percent numeric(5,2),
    swiped_away_percent numeric(5,2),
    subscribers_gained integer,
    likes integer,
    comments integer,
    shares integer,
    hype_points integer,
    shorts_feed_pct numeric(5,2),
    youtube_search_pct numeric(5,2),
    browse_features_pct numeric(5,2),
    channel_pages_pct numeric(5,2),
    suggested_videos_pct numeric(5,2),
    external_pct numeric(5,2),
    notifications_pct numeric(5,2),
    other_youtube_features_pct numeric(5,2),
    others_pct numeric(5,2),
    search_terms_json jsonb,
    retention_curve_json jsonb,
    key_moments_json jsonb,
    end_screen_ctr numeric(5,2),
    end_screen_ctr_channel_avg numeric(5,2),
    remixes integer,
    bell_notification_ctr numeric(5,2),
    device_mobile_pct numeric(5,2),
    device_computer_pct numeric(5,2),
    device_tablet_pct numeric(5,2),
    device_tv_pct numeric(5,2),
    gender_male_pct numeric(5,2),
    gender_female_pct numeric(5,2),
    age_13_17_pct numeric(5,2),
    age_18_24_pct numeric(5,2),
    age_25_34_pct numeric(5,2),
    age_35_44_pct numeric(5,2),
    age_45_54_pct numeric(5,2),
    age_55_64_pct numeric(5,2),
    age_65_plus_pct numeric(5,2),
    geography_india_pct numeric(5,2),
    geography_other_json jsonb,
    subscriber_status_subscribed_pct numeric(5,2),
    subscriber_status_not_subscribed_pct numeric(5,2),
    new_viewers_pct numeric(5,2),
    returning_viewers_pct numeric(5,2),
    subtitles_none_pct numeric(5,2),
    subtitles_hindi_pct numeric(5,2),
    subtitles_english_auto_pct numeric(5,2),
    description_text text,
    description_length integer,
    tags_title text,
    tags_description text,
    hashtag_count integer,
    playlist_name text,
    end_screen text,
    captions text,
    related_video_title text,
    related_video_type text,
    hook_type text,
    clip_breakdown_json jsonb,
    language_mix text,
    content_category text,
    value_delivery text,
    cta_type text,
    academic_teaching boolean,
    total_comments integer,
    top_comments_json jsonb,
    sentiment_clusters_json jsonb,
    topic_demands_json jsonb,
    quality_signals_json jsonb,
    creator_reply_rate numeric(5,2),
    gratitude_signals integer,
    trust_proxy text,
    content_type text,
    what_works_json jsonb,
    what_fails_json jsonb,
    root_cause text,
    hidden_pattern text,
    actionable_fix text,
    comparison_cluster_json jsonb,
    memory_update_json jsonb,
    analyzed_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.short_analysis OWNER TO postgres;

--
-- Name: short_analysis_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.short_analysis_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.short_analysis_id_seq OWNER TO postgres;

--
-- Name: short_analysis_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.short_analysis_id_seq OWNED BY public.short_analysis.id;


--
-- Name: short_content_classification; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.short_content_classification (
    video_id text NOT NULL,
    primary_type text NOT NULL,
    secondary_type text,
    confidence_score integer DEFAULT 5,
    classified_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    classified_by text DEFAULT 'manual'::text
);


ALTER TABLE public.short_content_classification OWNER TO postgres;

--
-- Name: short_title_template; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.short_title_template (
    video_id text NOT NULL,
    template_id bigint,
    title_length integer,
    word_count integer,
    hashtag_count integer,
    emoji_count integer,
    char_before_pipe integer,
    char_after_pipe integer,
    keyword_density jsonb,
    fetched_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.short_title_template OWNER TO postgres;

--
-- Name: shorts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shorts (
    short_id integer NOT NULL,
    video_id text,
    title text,
    title_raw text,
    description text,
    description_length integer,
    description_has_cta boolean,
    description_has_links boolean,
    published_at timestamp without time zone,
    duration_seconds integer,
    duration_bucket text,
    visibility text DEFAULT 'public'::text,
    playlist_id text,
    playlist_title text,
    end_screen_type text,
    end_screen_video_id text,
    has_subtitles boolean DEFAULT false,
    subtitle_languages text[],
    related_video_id text,
    tags_title text[],
    tags_description text[],
    tag_count_title integer GENERATED ALWAYS AS (array_length(tags_title, 1)) STORED,
    tag_count_desc integer GENERATED ALWAYS AS (array_length(tags_description, 1)) STORED,
    total_hashtags integer GENERATED ALWAYS AS ((COALESCE(array_length(tags_title, 1), 0) + COALESCE(array_length(tags_description, 1), 0))) STORED,
    emoji_in_title boolean,
    emoji_list text[],
    red_alert_emoji boolean,
    content_year integer,
    content_type text,
    content_subtype text,
    thumbnail_style jsonb,
    hook_type text,
    value_type text,
    language text DEFAULT 'Hinglish'::text,
    cta_placement text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.shorts OWNER TO postgres;

--
-- Name: title_templates; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.title_templates (
    id bigint NOT NULL,
    template_name text NOT NULL,
    template_pattern text,
    emoji_position text,
    has_pipe_separator boolean,
    has_how_to boolean,
    has_question_mark boolean,
    has_double_exclamation boolean,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.title_templates OWNER TO postgres;

--
-- Name: title_templates_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.title_templates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.title_templates_id_seq OWNER TO postgres;

--
-- Name: title_templates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.title_templates_id_seq OWNED BY public.title_templates.id;


--
-- Name: traffic_sources; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.traffic_sources (
    id bigint NOT NULL,
    video_id text NOT NULL,
    source_name text NOT NULL,
    source_category text,
    views bigint DEFAULT 0 NOT NULL,
    percentage numeric(5,2) NOT NULL,
    avg_view_duration_seconds numeric(6,2),
    retention_pct numeric(5,2),
    fetched_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.traffic_sources OWNER TO postgres;

--
-- Name: traffic_sources_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.traffic_sources_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.traffic_sources_id_seq OWNER TO postgres;

--
-- Name: traffic_sources_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.traffic_sources_id_seq OWNED BY public.traffic_sources.id;


--
-- Name: v_content_type_performance; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_content_type_performance AS
 SELECT ct.content_type,
    count(s.video_id) AS video_count,
    (avg(pm.views))::bigint AS avg_views,
    max(pm.views) AS max_views,
    min(pm.views) AS min_views,
    (avg(pm.retention_pct))::numeric(5,2) AS avg_retention,
    (avg(pm.swipe_away_pct))::numeric(5,2) AS avg_swipe_away,
    (avg(ts_search.percentage))::numeric(5,2) AS avg_search_pct,
    (avg(ts_feed.percentage))::numeric(5,2) AS avg_feed_pct,
    (avg((pm.sub_conversion_rate * (100)::numeric)))::numeric(6,4) AS avg_sub_conversion_pct,
    (avg(aa.target_audience_pct))::numeric(5,2) AS avg_target_audience_pct,
    (avg(ag_india.percentage))::numeric(5,2) AS avg_india_pct,
    ct.shelf_life_category,
    ct.annual_remake_required,
    ct.audience_match_score
   FROM (((((((public.content_types ct
     JOIN public.short_content_classification scc ON ((ct.content_type = scc.primary_type)))
     JOIN public.shorts s ON ((scc.video_id = s.video_id)))
     LEFT JOIN public.performance_metrics pm ON ((s.video_id = pm.video_id)))
     LEFT JOIN public.traffic_sources ts_search ON (((s.video_id = ts_search.video_id) AND (ts_search.source_category = 'search'::text))))
     LEFT JOIN public.traffic_sources ts_feed ON (((s.video_id = ts_feed.video_id) AND (ts_feed.source_category = 'feed'::text))))
     LEFT JOIN public.audience_age aa ON ((s.video_id = aa.video_id)))
     LEFT JOIN public.audience_geography ag_india ON (((s.video_id = ag_india.video_id) AND (ag_india.country_code = 'IN'::text))))
  GROUP BY ct.content_type, ct.shelf_life_category, ct.annual_remake_required, ct.audience_match_score
  ORDER BY ((avg(pm.views))::bigint) DESC;


ALTER VIEW public.v_content_type_performance OWNER TO postgres;

--
-- Name: v_short_complete; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_short_complete AS
 SELECT s.short_id,
    s.video_id,
    s.title,
    s.published_at,
    s.duration_seconds,
    s.content_type,
    s.content_subtype,
    s.content_year,
    s.value_type,
    s.hook_type,
    pm.views,
    pm.engaged_views,
    pm.unique_viewers,
    pm.watch_time_hours,
    pm.avg_view_duration_seconds,
    pm.retention_pct,
    pm.completion_pct,
    pm.swipe_away_pct,
    pm.subscribers_gained,
    pm.net_subscribers,
    pm.likes,
    pm.comments_count,
    pm.engagement_rate,
    pm.sub_conversion_rate,
    ts_feed.percentage AS feed_pct,
    ts_search.percentage AS search_pct,
    ts_browse.percentage AS browse_pct,
    ts_channel.percentage AS channel_pct,
    ts_external.percentage AS external_pct,
    ad.mobile_pct,
    ad.desktop_pct,
    ag_india.percentage AS india_pct,
    ass.subscribed_pct,
    aa.age_18_24_pct,
    aa.target_audience_pct,
    ca.total_comments,
    ca.comments_per_1k_views,
    ca.creator_reply_rate,
    ca.gratitude_comments,
    ca.query_comments,
    s.red_alert_emoji,
    s.total_hashtags,
    s.description_length,
    s.has_subtitles,
    s.end_screen_type,
    (s.playlist_id IS NOT NULL) AS has_playlist,
    (s.related_video_id IS NOT NULL) AS has_related_video
   FROM (((((((((((public.shorts s
     LEFT JOIN public.performance_metrics pm ON ((s.video_id = pm.video_id)))
     LEFT JOIN public.traffic_sources ts_feed ON (((s.video_id = ts_feed.video_id) AND (ts_feed.source_category = 'feed'::text))))
     LEFT JOIN public.traffic_sources ts_search ON (((s.video_id = ts_search.video_id) AND (ts_search.source_category = 'search'::text))))
     LEFT JOIN public.traffic_sources ts_browse ON (((s.video_id = ts_browse.video_id) AND (ts_browse.source_category = 'browse'::text))))
     LEFT JOIN public.traffic_sources ts_channel ON (((s.video_id = ts_channel.video_id) AND (ts_channel.source_category = 'channel'::text))))
     LEFT JOIN public.traffic_sources ts_external ON (((s.video_id = ts_external.video_id) AND (ts_external.source_category = 'external'::text))))
     LEFT JOIN public.audience_device ad ON ((s.video_id = ad.video_id)))
     LEFT JOIN public.audience_geography ag_india ON (((s.video_id = ag_india.video_id) AND (ag_india.country_code = 'IN'::text))))
     LEFT JOIN public.audience_subscriber_status ass ON ((s.video_id = ass.video_id)))
     LEFT JOIN public.audience_age aa ON ((s.video_id = aa.video_id)))
     LEFT JOIN public.comments_analysis ca ON ((s.video_id = ca.video_id)));


ALTER VIEW public.v_short_complete OWNER TO postgres;

--
-- Name: v_top_search_terms; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_top_search_terms AS
 SELECT st.search_term,
    count(DISTINCT st.video_id) AS videos_appearing_in,
    sum(st.views) AS total_search_views,
    (avg(st.percentage_of_search))::numeric(5,2) AS avg_pct_of_search,
    (avg(st.relevance_score))::numeric(3,1) AS avg_relevance,
    string_agg(DISTINCT s.content_type, ', '::text) AS content_types
   FROM (public.search_terms st
     JOIN public.shorts s ON ((st.video_id = s.video_id)))
  GROUP BY st.search_term
 HAVING (count(DISTINCT st.video_id) >= 2)
  ORDER BY (sum(st.views)) DESC;


ALTER VIEW public.v_top_search_terms OWNER TO postgres;

--
-- Name: analysis_log id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.analysis_log ALTER COLUMN id SET DEFAULT nextval('public.analysis_log_id_seq'::regclass);


--
-- Name: analysis_sessions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.analysis_sessions ALTER COLUMN id SET DEFAULT nextval('public.analysis_sessions_id_seq'::regclass);


--
-- Name: audience_geography id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audience_geography ALTER COLUMN id SET DEFAULT nextval('public.audience_geography_id_seq'::regclass);


--
-- Name: comparison_clusters id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comparison_clusters ALTER COLUMN id SET DEFAULT nextval('public.comparison_clusters_id_seq'::regclass);


--
-- Name: external_sources id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.external_sources ALTER COLUMN id SET DEFAULT nextval('public.external_sources_id_seq'::regclass);


--
-- Name: hidden_patterns id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hidden_patterns ALTER COLUMN id SET DEFAULT nextval('public.hidden_patterns_id_seq'::regclass);


--
-- Name: individual_comments id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.individual_comments ALTER COLUMN id SET DEFAULT nextval('public.individual_comments_id_seq'::regclass);


--
-- Name: memory_updates id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.memory_updates ALTER COLUMN id SET DEFAULT nextval('public.memory_updates_id_seq'::regclass);


--
-- Name: retention_curve id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.retention_curve ALTER COLUMN id SET DEFAULT nextval('public.retention_curve_id_seq'::regclass);


--
-- Name: search_terms id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.search_terms ALTER COLUMN id SET DEFAULT nextval('public.search_terms_id_seq'::regclass);


--
-- Name: short_analysis id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.short_analysis ALTER COLUMN id SET DEFAULT nextval('public.short_analysis_id_seq'::regclass);


--
-- Name: title_templates id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.title_templates ALTER COLUMN id SET DEFAULT nextval('public.title_templates_id_seq'::regclass);


--
-- Name: traffic_sources id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.traffic_sources ALTER COLUMN id SET DEFAULT nextval('public.traffic_sources_id_seq'::regclass);


--
-- Data for Name: analysis_log; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.analysis_log (id, session_id, video_id, tab_analyzed, status, error_message, data_completeness, duration_seconds, analyzed_at) FROM stdin;
1	1	5goNjmztwqg	overview	completed	\N	95.00	120	2026-08-31 21:47:38.857527
2	1	5goNjmztwqg	reach	completed	\N	90.00	180	2026-08-31 21:47:38.857527
3	1	5goNjmztwqg	engagement	completed	\N	95.00	150	2026-08-31 21:47:38.857527
4	1	5goNjmztwqg	audience	completed	\N	85.00	180	2026-08-31 21:47:38.857527
383	20260901	YaAKtkecoRc	overview	success	\N	1.00	30	2026-09-08 10:48:39.159712
384	20260901	YaAKtkecoRc	reach	success	\N	1.00	30	2026-09-08 10:48:39.159712
385	20260901	YaAKtkecoRc	engagement	success	\N	1.00	30	2026-09-08 10:48:39.159712
386	20260901	YaAKtkecoRc	audience	success	\N	1.00	30	2026-09-08 10:48:39.159712
9	1	\N	overview	completed	\N	100.00	10	2026-08-31 22:48:41.521487
10	1	\N	overview	completed	\N	100.00	10	2026-08-31 22:49:05.565986
387	20260901	YaAKtkecoRc	comments	success	\N	1.00	30	2026-09-08 10:48:39.159712
388	20260901	YaAKtkecoRc	edit	success	\N	1.00	30	2026-09-08 10:48:39.159712
22	2	0jstRcQmAro	overview	completed	\N	95.00	120	2026-09-01 08:45:25.36398
23	2	0jstRcQmAro	reach	completed	\N	90.00	180	2026-09-01 08:45:25.36398
24	2	0jstRcQmAro	engagement	completed	\N	95.00	150	2026-09-01 08:45:25.36398
25	2	0jstRcQmAro	audience	completed	\N	85.00	180	2026-09-01 08:45:25.36398
26	2	0jstRcQmAro	comments	completed	\N	90.00	60	2026-09-01 08:45:25.36398
27	20260901	XWFbqR_9fqc	overview,reach,engagement,audience,comments	complete	\N	95.00	600	2026-09-01 09:19:49.888536
28	20260901	Pwp0zPAY6Y4	overview,reach,engagement,audience,comments	complete	\N	95.00	600	2026-09-01 09:29:40.491408
29	20260901	s_PoEssiuPo	overview,reach,engagement,audience,comments	complete	\N	95.00	600	2026-09-01 09:42:27.379694
30	1	UTeogxHwnPw	overview	success	\N	100.00	30	2026-09-02 09:25:12.01273
31	1	UTeogxHwnPw	reach	success	\N	100.00	30	2026-09-02 09:25:12.01273
32	1	UTeogxHwnPw	engagement	success	\N	100.00	30	2026-09-02 09:25:12.01273
33	1	UTeogxHwnPw	audience	success	\N	80.00	30	2026-09-02 09:25:12.01273
34	1	UTeogxHwnPw	comments	success	\N	100.00	15	2026-09-02 09:25:12.01273
35	1	UTeogxHwnPw	details	success	\N	100.00	15	2026-09-02 09:25:12.01273
42	1	zdOSsbqouKE	overview	success	\N	100.00	30	2026-09-02 09:25:43.634893
43	1	zdOSsbqouKE	reach	success	\N	100.00	30	2026-09-02 09:25:43.634893
44	1	zdOSsbqouKE	engagement	success	\N	100.00	30	2026-09-02 09:25:43.634893
45	1	zdOSsbqouKE	audience	success	\N	80.00	30	2026-09-02 09:25:43.634893
46	1	zdOSsbqouKE	comments	success	\N	100.00	15	2026-09-02 09:25:43.634893
47	1	zdOSsbqouKE	details	success	\N	100.00	15	2026-09-02 09:25:43.634893
48	1	12BKLbv0Eso	overview	success	\N	100.00	30	2026-09-02 09:25:45.151529
49	1	12BKLbv0Eso	reach	success	\N	100.00	30	2026-09-02 09:25:45.151529
50	1	12BKLbv0Eso	engagement	success	\N	100.00	30	2026-09-02 09:25:45.151529
51	1	12BKLbv0Eso	audience	success	\N	80.00	30	2026-09-02 09:25:45.151529
52	1	12BKLbv0Eso	comments	success	\N	100.00	15	2026-09-02 09:25:45.151529
53	1	12BKLbv0Eso	details	success	\N	100.00	15	2026-09-02 09:25:45.151529
54	1	XM1AzgVMeqk	overview	success	\N	100.00	30	2026-09-02 09:25:46.312192
55	1	XM1AzgVMeqk	reach	success	\N	100.00	30	2026-09-02 09:25:46.312192
56	1	XM1AzgVMeqk	engagement	success	\N	100.00	30	2026-09-02 09:25:46.312192
57	1	XM1AzgVMeqk	audience	success	\N	80.00	30	2026-09-02 09:25:46.312192
58	1	XM1AzgVMeqk	comments	success	\N	100.00	15	2026-09-02 09:25:46.312192
59	1	XM1AzgVMeqk	details	success	\N	100.00	15	2026-09-02 09:25:46.312192
60	1	nJNR60Ms1BE	overview	success	\N	100.00	30	2026-09-02 09:25:47.152763
61	1	nJNR60Ms1BE	reach	success	\N	100.00	30	2026-09-02 09:25:47.152763
62	1	nJNR60Ms1BE	engagement	success	\N	100.00	30	2026-09-02 09:25:47.152763
63	1	nJNR60Ms1BE	audience	success	\N	80.00	30	2026-09-02 09:25:47.152763
64	1	nJNR60Ms1BE	comments	success	\N	100.00	15	2026-09-02 09:25:47.152763
65	1	nJNR60Ms1BE	details	success	\N	100.00	15	2026-09-02 09:25:47.152763
66	1	_A5Idj7SddI	overview	success	\N	100.00	30	2026-09-02 09:25:47.534266
67	1	_A5Idj7SddI	reach	success	\N	100.00	30	2026-09-02 09:25:47.534266
68	1	_A5Idj7SddI	engagement	success	\N	100.00	30	2026-09-02 09:25:47.534266
69	1	_A5Idj7SddI	audience	success	\N	80.00	30	2026-09-02 09:25:47.534266
70	1	_A5Idj7SddI	comments	success	\N	100.00	15	2026-09-02 09:25:47.534266
71	1	_A5Idj7SddI	details	success	\N	100.00	15	2026-09-02 09:25:47.534266
72	1	BJ5lJob_sDU	overview	success	\N	100.00	30	2026-09-02 09:25:47.870198
73	1	BJ5lJob_sDU	reach	success	\N	100.00	30	2026-09-02 09:25:47.870198
74	1	BJ5lJob_sDU	engagement	success	\N	100.00	30	2026-09-02 09:25:47.870198
75	1	BJ5lJob_sDU	audience	success	\N	80.00	30	2026-09-02 09:25:47.870198
76	1	BJ5lJob_sDU	comments	success	\N	100.00	15	2026-09-02 09:25:47.870198
77	1	BJ5lJob_sDU	details	success	\N	100.00	15	2026-09-02 09:25:47.870198
467	\N	bLwR73Y2d0w	Overview	extracted	\N	1.00	0	2026-09-10 10:04:13.605465
468	\N	bLwR73Y2d0w	Reach	extracted	\N	1.00	0	2026-09-10 10:04:13.605465
469	\N	bLwR73Y2d0w	Engagement	extracted	\N	1.00	0	2026-09-10 10:04:13.605465
470	\N	bLwR73Y2d0w	Audience	extracted	\N	1.00	0	2026-09-10 10:04:13.605465
471	\N	bLwR73Y2d0w	Comments	extracted	\N	1.00	0	2026-09-10 10:04:13.605465
472	\N	bLwR73Y2d0w	Details/Edit	extracted	\N	1.00	0	2026-09-10 10:04:13.605465
485	20260901	Pnh6g6K9y8Q	overview	completed	\N	1.00	30	2026-09-10 17:22:57.565114
486	20260901	Pnh6g6K9y8Q	reach	completed	\N	1.00	25	2026-09-10 17:22:57.565114
487	20260901	Pnh6g6K9y8Q	engagement	completed	\N	1.00	20	2026-09-10 17:22:57.565114
488	20260901	Pnh6g6K9y8Q	audience	completed	\N	1.00	22	2026-09-10 17:22:57.565114
489	20260901	Pnh6g6K9y8Q	comments	completed	\N	1.00	15	2026-09-10 17:22:57.565114
490	20260901	Pnh6g6K9y8Q	edit	completed	\N	1.00	18	2026-09-10 17:22:57.565114
498	20260901	DNIHqPqY3VM	overview	completed	\N	1.00	30	2026-09-10 18:32:28.286194
499	20260901	DNIHqPqY3VM	reach	completed	\N	1.00	25	2026-09-10 18:32:28.286194
500	20260901	DNIHqPqY3VM	engagement	completed	\N	1.00	20	2026-09-10 18:32:28.286194
501	20260901	DNIHqPqY3VM	audience	completed	\N	1.00	22	2026-09-10 18:32:28.286194
502	20260901	DNIHqPqY3VM	comments	completed	\N	1.00	15	2026-09-10 18:32:28.286194
389	20260901	YaAKtkecoRc	overview	success	\N	1.00	30	2026-09-08 10:58:13.446835
390	20260901	YaAKtkecoRc	reach	success	\N	1.00	30	2026-09-08 10:58:13.446835
391	20260901	YaAKtkecoRc	engagement	success	\N	1.00	30	2026-09-08 10:58:13.446835
392	20260901	YaAKtkecoRc	audience	success	\N	1.00	30	2026-09-08 10:58:13.446835
393	20260901	YaAKtkecoRc	comments	success	\N	1.00	30	2026-09-08 10:58:13.446835
394	20260901	YaAKtkecoRc	edit	success	\N	1.00	30	2026-09-08 10:58:13.446835
443	20260901	D4KiNRb7UTk	overview	completed	\N	95.00	30	2026-09-09 16:51:44.575471
444	20260901	D4KiNRb7UTk	reach	completed	\N	92.00	30	2026-09-09 16:51:44.575471
445	20260901	D4KiNRb7UTk	engagement	completed	\N	88.00	30	2026-09-09 16:51:44.575471
446	20260901	D4KiNRb7UTk	audience	completed	\N	85.00	30	2026-09-09 16:51:44.575471
447	20260901	D4KiNRb7UTk	comments	completed	\N	80.00	45	2026-09-09 16:51:44.575471
448	20260901	D4KiNRb7UTk	edit	completed	\N	90.00	25	2026-09-09 16:51:44.575471
455	20260901	yBnFHlmgMFQ	overview	completed	\N	0.95	30	2026-09-09 23:48:51.46802
456	20260901	yBnFHlmgMFQ	reach	completed	\N	0.90	25	2026-09-09 23:48:51.46802
457	20260901	yBnFHlmgMFQ	engagement	completed	\N	0.85	20	2026-09-09 23:48:51.46802
458	20260901	yBnFHlmgMFQ	audience	completed	\N	0.88	22	2026-09-09 23:48:51.46802
459	20260901	yBnFHlmgMFQ	comments	completed	\N	0.70	15	2026-09-09 23:48:51.46802
460	20260901	yBnFHlmgMFQ	edit	completed	\N	0.92	18	2026-09-09 23:48:51.46802
503	20260901	DNIHqPqY3VM	edit	completed	\N	1.00	18	2026-09-10 18:32:28.286194
505	20260901	Mkx7Qp8nCys	overview	completed	\N	1.00	30	2026-09-10 18:43:32.427695
506	20260901	Mkx7Qp8nCys	reach	completed	\N	1.00	25	2026-09-10 18:43:32.427695
507	20260901	Mkx7Qp8nCys	engagement	completed	\N	1.00	20	2026-09-10 18:43:32.427695
508	20260901	Mkx7Qp8nCys	audience	completed	\N	1.00	22	2026-09-10 18:43:32.427695
509	20260901	Mkx7Qp8nCys	comments	completed	\N	1.00	15	2026-09-10 18:43:32.427695
510	20260901	Mkx7Qp8nCys	edit	completed	\N	1.00	18	2026-09-10 18:43:32.427695
519	20260901	a6DGQWZ57EE	overview	completed	\N	1.00	30	2026-09-10 19:31:27.388867
520	20260901	a6DGQWZ57EE	reach	completed	\N	1.00	25	2026-09-10 19:31:27.388867
521	20260901	a6DGQWZ57EE	engagement	completed	\N	1.00	20	2026-09-10 19:31:27.388867
522	20260901	a6DGQWZ57EE	audience	completed	\N	1.00	22	2026-09-10 19:31:27.388867
523	20260901	a6DGQWZ57EE	comments	completed	\N	1.00	15	2026-09-10 19:31:27.388867
524	20260901	a6DGQWZ57EE	edit	completed	\N	1.00	18	2026-09-10 19:31:27.388867
538	1	_6qJfWvvWJo	overview	completed	\N	1.00	30	2026-09-10 20:01:40.055997
539	1	_6qJfWvvWJo	reach	completed	\N	1.00	25	2026-09-10 20:01:40.055997
540	1	_6qJfWvvWJo	engagement	completed	\N	1.00	20	2026-09-10 20:01:40.055997
541	1	_6qJfWvvWJo	audience	completed	\N	1.00	22	2026-09-10 20:01:40.055997
542	1	_6qJfWvvWJo	comments	completed	\N	1.00	15	2026-09-10 20:01:40.055997
543	1	_6qJfWvvWJo	edit	completed	\N	1.00	18	2026-09-10 20:01:40.055997
141	20260901	XWFbqR_9fqc	overview,reach,engagement,audience,comments	complete	\N	95.00	600	2026-09-02 10:02:53.957789
142	20260901	Pwp0zPAY6Y4	overview,reach,engagement,audience,comments	complete	\N	95.00	600	2026-09-02 10:03:13.106027
143	20260901	s_PoEssiuPo	overview,reach,engagement,audience,comments	complete	\N	95.00	600	2026-09-02 10:03:18.329293
144	1	OkWbChCIb04	overview	success	\N	100.00	30	2026-09-02 10:43:00.55935
145	1	OkWbChCIb04	reach	success	\N	100.00	30	2026-09-02 10:43:00.55935
146	1	OkWbChCIb04	engagement	success	\N	100.00	30	2026-09-02 10:43:00.55935
147	1	OkWbChCIb04	audience	success	\N	80.00	30	2026-09-02 10:43:00.55935
148	1	OkWbChCIb04	comments	success	\N	100.00	15	2026-09-02 10:43:00.55935
149	1	OkWbChCIb04	details	success	\N	100.00	15	2026-09-02 10:43:00.55935
150	1	2jcdStwq2yY	overview	success	\N	100.00	30	2026-09-02 11:05:19.259322
151	1	2jcdStwq2yY	reach	success	\N	100.00	30	2026-09-02 11:05:19.259322
152	1	2jcdStwq2yY	engagement	success	\N	100.00	30	2026-09-02 11:05:19.259322
153	1	2jcdStwq2yY	audience	success	\N	80.00	30	2026-09-02 11:05:19.259322
154	1	2jcdStwq2yY	comments	success	\N	100.00	15	2026-09-02 11:05:19.259322
155	1	2jcdStwq2yY	details	success	\N	100.00	15	2026-09-02 11:05:19.259322
545	20260901	NVbNJeWZ1Lo	overview	completed	\N	1.00	30	2026-09-10 20:21:07.431547
546	20260901	NVbNJeWZ1Lo	reach	completed	\N	1.00	25	2026-09-10 20:21:07.431547
547	20260901	NVbNJeWZ1Lo	engagement	completed	\N	1.00	20	2026-09-10 20:21:07.431547
548	20260901	NVbNJeWZ1Lo	audience	completed	\N	1.00	22	2026-09-10 20:21:07.431547
549	20260901	NVbNJeWZ1Lo	comments	completed	\N	1.00	15	2026-09-10 20:21:07.431547
550	20260901	NVbNJeWZ1Lo	edit	completed	\N	1.00	18	2026-09-10 20:21:07.431547
552	20260901	wnp9gFm7ZpY	overview	completed	\N	1.00	30	2026-09-10 22:48:19.000993
553	20260901	wnp9gFm7ZpY	reach	completed	\N	1.00	25	2026-09-10 22:48:19.000993
554	20260901	wnp9gFm7ZpY	engagement	completed	\N	1.00	20	2026-09-10 22:48:19.000993
555	20260901	wnp9gFm7ZpY	audience	completed	\N	1.00	22	2026-09-10 22:48:19.000993
556	20260901	wnp9gFm7ZpY	comments	completed	\N	1.00	15	2026-09-10 22:48:19.000993
557	20260901	wnp9gFm7ZpY	edit	completed	\N	1.00	18	2026-09-10 22:48:19.000993
559	20260901	pl90QEsoKFk	overview	completed	\N	1.00	30	2026-09-10 23:08:11.068235
560	20260901	pl90QEsoKFk	reach	completed	\N	1.00	25	2026-09-10 23:08:11.068235
561	20260901	pl90QEsoKFk	engagement	completed	\N	1.00	20	2026-09-10 23:08:11.068235
562	20260901	pl90QEsoKFk	audience	completed	\N	1.00	22	2026-09-10 23:08:11.068235
563	20260901	pl90QEsoKFk	comments	completed	\N	0.70	15	2026-09-10 23:08:11.068235
564	20260901	pl90QEsoKFk	edit	completed	\N	0.92	18	2026-09-10 23:08:11.068235
571	20260901	3LCJCKfRATo	overview	completed	\N	1.00	30	2026-09-10 23:30:52.664773
572	20260901	3LCJCKfRATo	reach	completed	\N	1.00	25	2026-09-10 23:30:52.664773
573	20260901	3LCJCKfRATo	engagement	completed	\N	1.00	20	2026-09-10 23:30:52.664773
574	20260901	3LCJCKfRATo	audience	completed	\N	1.00	22	2026-09-10 23:30:52.664773
575	20260901	3LCJCKfRATo	comments	completed	\N	1.00	15	2026-09-10 23:30:52.664773
576	20260901	3LCJCKfRATo	edit	completed	\N	1.00	18	2026-09-10 23:30:52.664773
583	20260901	A2U9omXQ2go	overview	completed	\N	1.00	30	2026-09-11 12:57:35.796334
584	20260901	A2U9omXQ2go	reach	completed	\N	1.00	25	2026-09-11 12:57:35.796334
162	1	yDKB-xCaMB8	overview	completed	\N	95.00	60	2026-09-02 14:30:31.576863
163	1	yDKB-xCaMB8	reach	completed	\N	90.00	90	2026-09-02 14:30:31.576863
164	1	yDKB-xCaMB8	engagement	completed	\N	95.00	60	2026-09-02 14:30:31.576863
165	1	yDKB-xCaMB8	audience	completed	\N	85.00	90	2026-09-02 14:30:31.576863
166	1	yDKB-xCaMB8	comments	completed	\N	100.00	30	2026-09-02 14:30:31.576863
167	1	rg5iPj-249o	overview	completed	\N	95.00	60	2026-09-02 14:58:55.032747
168	1	rg5iPj-249o	reach	completed	\N	90.00	90	2026-09-02 14:58:55.032747
169	1	rg5iPj-249o	engagement	completed	\N	95.00	60	2026-09-02 14:58:55.032747
170	1	rg5iPj-249o	audience	completed	\N	85.00	90	2026-09-02 14:58:55.032747
171	1	rg5iPj-249o	comments	completed	\N	100.00	30	2026-09-02 14:58:55.032747
172	1	waW201cvfl8	overview	completed	\N	95.00	60	2026-09-02 15:14:09.210888
173	1	waW201cvfl8	reach	completed	\N	90.00	90	2026-09-02 15:14:09.210888
174	1	waW201cvfl8	engagement	completed	\N	95.00	60	2026-09-02 15:14:09.210888
175	1	waW201cvfl8	audience	completed	\N	85.00	90	2026-09-02 15:14:09.210888
176	1	waW201cvfl8	comments	completed	\N	100.00	30	2026-09-02 15:14:09.210888
177	1	Ay9K30yrg8Y	overview	completed	\N	95.00	60	2026-09-02 15:27:50.633383
178	1	Ay9K30yrg8Y	reach	completed	\N	90.00	90	2026-09-02 15:27:50.633383
179	1	Ay9K30yrg8Y	engagement	completed	\N	95.00	60	2026-09-02 15:27:50.633383
180	1	Ay9K30yrg8Y	audience	completed	\N	95.00	90	2026-09-02 15:27:50.633383
181	1	Ay9K30yrg8Y	comments	completed	\N	100.00	30	2026-09-02 15:27:50.633383
182	1	lmbndk-Db-Q	overview	completed	\N	95.00	60	2026-09-02 21:49:28.223132
183	1	lmbndk-Db-Q	reach	completed	\N	90.00	90	2026-09-02 21:49:28.223132
184	1	lmbndk-Db-Q	engagement	completed	\N	95.00	60	2026-09-02 21:49:28.223132
185	1	lmbndk-Db-Q	audience	completed	\N	95.00	90	2026-09-02 21:49:28.223132
186	1	lmbndk-Db-Q	comments	completed	\N	100.00	30	2026-09-02 21:49:28.223132
187	1	cSapjDf5CHY	overview	completed	\N	95.00	60	2026-09-02 23:46:30.338612
188	1	cSapjDf5CHY	reach	completed	\N	90.00	90	2026-09-02 23:46:30.338612
189	1	cSapjDf5CHY	engagement	completed	\N	95.00	60	2026-09-02 23:46:30.338612
190	1	cSapjDf5CHY	audience	completed	\N	95.00	90	2026-09-02 23:46:30.338612
191	1	cSapjDf5CHY	comments	completed	\N	100.00	30	2026-09-02 23:46:30.338612
192	1	JmSdjrAxNFM	overview	success	\N	100.00	30	2026-09-03 08:43:48.484092
193	1	JmSdjrAxNFM	reach	success	\N	100.00	30	2026-09-03 08:43:48.484092
194	1	JmSdjrAxNFM	engagement	success	\N	100.00	30	2026-09-03 08:43:48.484092
195	1	JmSdjrAxNFM	audience	success	\N	100.00	30	2026-09-03 08:43:48.484092
196	1	JmSdjrAxNFM	comments	success	\N	100.00	15	2026-09-03 08:43:48.484092
197	1	JmSdjrAxNFM	details	success	\N	100.00	15	2026-09-03 08:43:48.484092
198	1	MpQ-K2D9Ao4	overview	success	\N	100.00	30	2026-09-03 08:46:53.14088
199	1	MpQ-K2D9Ao4	reach	success	\N	100.00	30	2026-09-03 08:46:53.14088
200	1	MpQ-K2D9Ao4	engagement	success	\N	100.00	30	2026-09-03 08:46:53.14088
201	1	MpQ-K2D9Ao4	audience	success	\N	100.00	30	2026-09-03 08:46:53.14088
202	1	MpQ-K2D9Ao4	comments	success	\N	100.00	15	2026-09-03 08:46:53.14088
203	1	MpQ-K2D9Ao4	details	success	\N	100.00	15	2026-09-03 08:46:53.14088
204	1	bXetyvX2Mu8	overview	success	\N	100.00	30	2026-09-03 08:49:33.548839
205	1	bXetyvX2Mu8	reach	success	\N	100.00	30	2026-09-03 08:49:33.548839
206	1	bXetyvX2Mu8	engagement	success	\N	100.00	30	2026-09-03 08:49:33.548839
207	1	bXetyvX2Mu8	audience	success	\N	100.00	30	2026-09-03 08:49:33.548839
208	1	bXetyvX2Mu8	comments	success	\N	100.00	15	2026-09-03 08:49:33.548839
209	1	bXetyvX2Mu8	details	success	\N	100.00	15	2026-09-03 08:49:33.548839
210	1	pHfj5VVN0Ew	overview	success	\N	100.00	30	2026-09-03 08:52:31.076945
211	1	pHfj5VVN0Ew	reach	success	\N	100.00	30	2026-09-03 08:52:31.076945
212	1	pHfj5VVN0Ew	engagement	success	\N	100.00	30	2026-09-03 08:52:31.076945
213	1	pHfj5VVN0Ew	audience	success	\N	100.00	30	2026-09-03 08:52:31.076945
214	1	pHfj5VVN0Ew	comments	success	\N	100.00	15	2026-09-03 08:52:31.076945
215	1	pHfj5VVN0Ew	details	success	\N	100.00	15	2026-09-03 08:52:31.076945
216	1	dpTHfuBYClo	overview	success	\N	100.00	30	2026-09-03 08:54:48.143719
217	1	dpTHfuBYClo	reach	success	\N	100.00	30	2026-09-03 08:54:48.143719
218	1	dpTHfuBYClo	engagement	success	\N	100.00	30	2026-09-03 08:54:48.143719
219	1	dpTHfuBYClo	audience	success	\N	100.00	30	2026-09-03 08:54:48.143719
220	1	dpTHfuBYClo	comments	success	\N	100.00	15	2026-09-03 08:54:48.143719
221	1	dpTHfuBYClo	details	success	\N	100.00	15	2026-09-03 08:54:48.143719
395	20260901	YaAKtkecoRc	overview	success	\N	1.00	30	2026-09-08 11:27:20.802552
223	20260901	sHwtsGShqjE	overview	completed	\N	100.00	30	2026-09-03 10:11:18.411369
224	20260901	sHwtsGShqjE	reach	completed	\N	90.00	30	2026-09-03 10:11:18.411369
225	20260901	sHwtsGShqjE	engagement	completed	\N	100.00	30	2026-09-03 10:11:18.411369
226	20260901	sHwtsGShqjE	audience	completed	\N	100.00	30	2026-09-03 10:11:18.411369
227	20260901	sHwtsGShqjE	comments	completed	\N	100.00	15	2026-09-03 10:11:18.411369
228	20260901	sHwtsGShqjE	details	completed	\N	100.00	30	2026-09-03 10:11:18.411369
229	1	tO8vEcWUFXs	overview	success	\N	100.00	30	2026-09-05 19:35:09.745882
230	1	tO8vEcWUFXs	reach	success	\N	100.00	30	2026-09-05 19:35:09.745882
231	1	tO8vEcWUFXs	engagement	success	\N	100.00	30	2026-09-05 19:35:09.745882
232	1	tO8vEcWUFXs	audience	success	\N	100.00	30	2026-09-05 19:35:09.745882
233	1	tO8vEcWUFXs	comments	success	\N	100.00	15	2026-09-05 19:35:09.745882
234	1	tO8vEcWUFXs	details	success	\N	100.00	15	2026-09-05 19:35:09.745882
235	1	m1qgKExs2BY	overview	success	\N	100.00	30	2026-09-05 19:53:35.380044
236	1	m1qgKExs2BY	reach	success	\N	100.00	30	2026-09-05 19:53:35.380044
237	1	m1qgKExs2BY	engagement	success	\N	100.00	30	2026-09-05 19:53:35.380044
238	1	m1qgKExs2BY	audience	success	\N	100.00	30	2026-09-05 19:53:35.380044
239	1	m1qgKExs2BY	comments	success	\N	100.00	15	2026-09-05 19:53:35.380044
240	1	m1qgKExs2BY	details	success	\N	100.00	15	2026-09-05 19:53:35.380044
241	1	_vTmJ79_4ho	overview	success	\N	100.00	30	2026-09-05 20:12:48.727333
242	1	_vTmJ79_4ho	reach	success	\N	100.00	30	2026-09-05 20:12:48.727333
243	1	_vTmJ79_4ho	engagement	success	\N	100.00	30	2026-09-05 20:12:48.727333
244	1	_vTmJ79_4ho	audience	success	\N	100.00	30	2026-09-05 20:12:48.727333
245	1	_vTmJ79_4ho	comments	success	\N	100.00	15	2026-09-05 20:12:48.727333
246	1	_vTmJ79_4ho	details	success	\N	100.00	15	2026-09-05 20:12:48.727333
284	1	atkvEdcPidM	overview	success	\N	100.00	3	2026-09-06 08:41:17.107595
285	2	atkvEdcPidM	reach	success	\N	100.00	2	2026-09-06 08:41:17.107595
286	20260901	atkvEdcPidM	engagement	success	\N	100.00	2	2026-09-06 08:41:17.107595
287	20260901	atkvEdcPidM	audience	success	\N	80.00	2	2026-09-06 08:41:17.107595
288	20260901	atkvEdcPidM	comments	success	\N	100.00	2	2026-09-06 08:41:17.107595
289	20260901	atkvEdcPidM	edit	success	\N	100.00	4	2026-09-06 08:41:17.107595
290	1	dudb29Xqo60	overview	success	\N	90.00	8	2026-09-06 08:53:13.551357
291	1	dudb29Xqo60	reach	success	\N	95.00	5	2026-09-06 08:53:13.551357
292	1	dudb29Xqo60	engagement	success	\N	90.00	8	2026-09-06 08:53:13.551357
293	1	dudb29Xqo60	audience	partial	Limited demographic data available	40.00	5	2026-09-06 08:53:13.551357
294	1	dudb29Xqo60	comments	success	\N	100.00	5	2026-09-06 08:53:13.551357
295	1	dudb29Xqo60	edit	success	\N	100.00	4	2026-09-06 08:53:13.551357
296	1	9jXcNZyYza8	overview	success	\N	100.00	30	2026-09-06 09:14:07.3586
297	1	9jXcNZyYza8	reach	success	\N	100.00	30	2026-09-06 09:14:07.3586
298	1	9jXcNZyYza8	engagement	success	\N	100.00	30	2026-09-06 09:14:07.3586
299	1	9jXcNZyYza8	audience	success	\N	80.00	30	2026-09-06 09:14:07.3586
300	1	9jXcNZyYza8	comments	success	\N	100.00	15	2026-09-06 09:14:07.3586
301	1	9jXcNZyYza8	details	success	\N	100.00	15	2026-09-06 09:14:07.3586
305	1	eC_j1wlFJBw	overview	success	\N	100.00	3	2026-09-06 09:30:05.833783
306	2	eC_j1wlFJBw	reach	success	\N	100.00	2	2026-09-06 09:30:05.833783
307	1	eC_j1wlFJBw	engagement	success	\N	100.00	2	2026-09-06 09:30:05.833783
308	2	eC_j1wlFJBw	audience	success	\N	50.00	2	2026-09-06 09:30:05.833783
309	1	eC_j1wlFJBw	comments	success	\N	100.00	3	2026-09-06 09:30:05.833783
310	2	eC_j1wlFJBw	edit	success	\N	100.00	4	2026-09-06 09:30:05.833783
311	1	Q-IS9K8g294	overview	success	\N	100.00	3	2026-09-06 09:52:18.827983
312	1	Q-IS9K8g294	reach	success	\N	100.00	2	2026-09-06 09:52:18.827983
313	1	Q-IS9K8g294	engagement	success	\N	100.00	2	2026-09-06 09:52:18.827983
314	1	Q-IS9K8g294	audience	partial	Audience tab kept showing 'Oops something went wrong' despite retries	50.00	4	2026-09-06 09:52:18.827983
315	1	Q-IS9K8g294	comments	success	\N	100.00	3	2026-09-06 09:52:18.827983
316	1	Q-IS9K8g294	edit	success	\N	100.00	4	2026-09-06 09:52:18.827983
320	1	p03EyeJlM-k	overview	success	\N	100.00	4	2026-09-06 12:19:14.187832
321	2	p03EyeJlM-k	reach	success	\N	100.00	3	2026-09-06 12:19:14.187832
322	1	p03EyeJlM-k	engagement	success	\N	100.00	3	2026-09-06 12:19:14.187832
323	1	p03EyeJlM-k	audience	partial	Geography/subtitles not fully expanded	80.00	3	2026-09-06 12:19:14.187832
324	1	p03EyeJlM-k	comments	skipped	Iteration cap reached	0.00	0	2026-09-06 12:19:14.187832
325	1	p03EyeJlM-k	edit	partial	Only initial form captured	60.00	2	2026-09-06 12:19:14.187832
326	1	229XDzxoc4g	overview	success	\N	100.00	3	2026-09-06 13:26:52.660817
327	1	229XDzxoc4g	reach	success	\N	100.00	3	2026-09-06 13:26:52.660817
328	1	229XDzxoc4g	engagement	success	\N	100.00	3	2026-09-06 13:26:52.660817
329	1	229XDzxoc4g	audience	success	\N	100.00	3	2026-09-06 13:26:52.660817
330	1	229XDzxoc4g	comments	success	\N	100.00	3	2026-09-06 13:26:52.660817
331	1	229XDzxoc4g	edit	success	\N	100.00	3	2026-09-06 13:26:52.660817
332	1	j4CtPMW-1Q4	overview	success	\N	100.00	3	2026-09-06 13:43:57.675416
333	1	j4CtPMW-1Q4	reach	success	\N	100.00	3	2026-09-06 13:43:57.675416
334	1	j4CtPMW-1Q4	engagement	success	\N	100.00	3	2026-09-06 13:43:57.675416
335	1	j4CtPMW-1Q4	audience	success	\N	100.00	3	2026-09-06 13:43:57.675416
336	1	j4CtPMW-1Q4	comments	success	\N	100.00	3	2026-09-06 13:43:57.675416
337	1	j4CtPMW-1Q4	edit	success	\N	100.00	3	2026-09-06 13:43:57.675416
338	1	iLZVyccaTJs	overview	success	\N	100.00	3	2026-09-06 13:51:03.028232
339	1	iLZVyccaTJs	reach	success	\N	100.00	3	2026-09-06 13:51:03.028232
340	1	iLZVyccaTJs	engagement	success	\N	100.00	3	2026-09-06 13:51:03.028232
341	1	iLZVyccaTJs	audience	success	\N	100.00	3	2026-09-06 13:51:03.028232
342	1	iLZVyccaTJs	comments	success	\N	100.00	3	2026-09-06 13:51:03.028232
343	1	iLZVyccaTJs	edit	success	\N	100.00	3	2026-09-06 13:51:03.028232
344	1	xBun0zPGZDA	overview	success	\N	100.00	3	2026-09-06 15:05:42.270667
345	1	xBun0zPGZDA	reach	success	\N	100.00	3	2026-09-06 15:05:42.270667
346	1	xBun0zPGZDA	engagement	success	\N	100.00	3	2026-09-06 15:05:42.270667
347	1	xBun0zPGZDA	audience	success	\N	100.00	3	2026-09-06 15:05:42.270667
348	1	xBun0zPGZDA	comments	success	\N	100.00	3	2026-09-06 15:05:42.270667
349	1	xBun0zPGZDA	edit	success	\N	100.00	3	2026-09-06 15:05:42.270667
353	20260901	4B4aAW76GLQ	overview	success	\N	1.00	15	2026-09-07 09:04:23.739817
354	20260901	4B4aAW76GLQ	reach	success	\N	1.00	15	2026-09-07 09:04:23.739817
355	20260901	4B4aAW76GLQ	engagement	success	\N	1.00	15	2026-09-07 09:04:23.739817
356	20260901	4B4aAW76GLQ	audience	success	\N	1.00	15	2026-09-07 09:04:23.739817
357	20260901	4B4aAW76GLQ	comments	success	\N	1.00	10	2026-09-07 09:04:23.739817
358	20260901	4B4aAW76GLQ	edit	success	\N	1.00	10	2026-09-07 09:04:23.739817
365	20260901	LQ7ttolwjJQ	overview	success	\N	1.00	15	2026-09-07 10:50:43.305672
366	20260901	LQ7ttolwjJQ	reach	success	\N	1.00	15	2026-09-07 10:50:43.305672
367	20260901	LQ7ttolwjJQ	engagement	success	\N	1.00	15	2026-09-07 10:50:43.305672
368	20260901	LQ7ttolwjJQ	audience	partial	Oops error after 5 retries - used estimated demographics with has_data=false	0.50	20	2026-09-07 10:50:43.305672
369	20260901	LQ7ttolwjJQ	comments	success	\N	1.00	10	2026-09-07 10:50:43.305672
370	20260901	LQ7ttolwjJQ	edit	success	\N	1.00	10	2026-09-07 10:50:43.305672
371	20260901	zqqcLDVZxR8	overview	success	\N	1.00	15	2026-09-07 10:57:07.066385
372	20260901	zqqcLDVZxR8	reach	success	\N	1.00	15	2026-09-07 10:57:07.066385
373	20260901	zqqcLDVZxR8	engagement	success	\N	1.00	15	2026-09-07 10:57:07.066385
374	20260901	zqqcLDVZxR8	audience	success	\N	1.00	15	2026-09-07 10:57:07.066385
375	20260901	zqqcLDVZxR8	comments	success	\N	1.00	10	2026-09-07 10:57:07.066385
376	20260901	zqqcLDVZxR8	edit	success	\N	1.00	10	2026-09-07 10:57:07.066385
396	20260901	YaAKtkecoRc	reach	success	\N	1.00	30	2026-09-08 11:27:20.802552
397	20260901	YaAKtkecoRc	engagement	success	\N	1.00	30	2026-09-08 11:27:20.802552
398	20260901	YaAKtkecoRc	audience	success	\N	1.00	30	2026-09-08 11:27:20.802552
399	20260901	YaAKtkecoRc	comments	success	\N	1.00	30	2026-09-08 11:27:20.802552
400	20260901	YaAKtkecoRc	edit	success	\N	1.00	30	2026-09-08 11:27:20.802552
413	20260901	Mp1WHa-CXfw	overview	success	\N	1.00	30	2026-09-09 14:55:59.402702
414	20260901	Mp1WHa-CXfw	reach	success	\N	1.00	30	2026-09-09 14:55:59.402702
415	20260901	Mp1WHa-CXfw	engagement	success	\N	1.00	30	2026-09-09 14:55:59.402702
416	20260901	Mp1WHa-CXfw	audience	success	\N	1.00	30	2026-09-09 14:55:59.402702
417	20260901	Mp1WHa-CXfw	comments	success	\N	1.00	30	2026-09-09 14:55:59.402702
418	20260901	Mp1WHa-CXfw	edit	success	\N	1.00	30	2026-09-09 14:55:59.402702
479	20260901	Pnh6g6K9y8Q	overview	completed	\N	1.00	30	2026-09-10 17:21:45.289572
480	20260901	Pnh6g6K9y8Q	reach	completed	\N	1.00	25	2026-09-10 17:21:45.289572
481	20260901	Pnh6g6K9y8Q	engagement	completed	\N	1.00	20	2026-09-10 17:21:45.289572
482	20260901	Pnh6g6K9y8Q	audience	completed	\N	1.00	22	2026-09-10 17:21:45.289572
483	20260901	Pnh6g6K9y8Q	comments	completed	\N	1.00	15	2026-09-10 17:21:45.289572
484	20260901	Pnh6g6K9y8Q	edit	completed	\N	1.00	18	2026-09-10 17:21:45.289572
492	20260901	DNIHqPqY3VM	overview	completed	\N	1.00	30	2026-09-10 18:30:27.604051
493	20260901	DNIHqPqY3VM	reach	completed	\N	1.00	25	2026-09-10 18:30:27.604051
494	20260901	DNIHqPqY3VM	engagement	completed	\N	1.00	20	2026-09-10 18:30:27.604051
495	20260901	DNIHqPqY3VM	audience	completed	\N	1.00	22	2026-09-10 18:30:27.604051
496	20260901	DNIHqPqY3VM	comments	completed	\N	1.00	15	2026-09-10 18:30:27.604051
497	20260901	DNIHqPqY3VM	edit	completed	\N	1.00	18	2026-09-10 18:30:27.604051
511	20260901	Mkx7Qp8nCys	overview	completed	\N	1.00	30	2026-09-10 18:44:13.592751
512	20260901	Mkx7Qp8nCys	reach	completed	\N	1.00	25	2026-09-10 18:44:13.592751
513	20260901	Mkx7Qp8nCys	engagement	completed	\N	1.00	20	2026-09-10 18:44:13.592751
514	20260901	Mkx7Qp8nCys	audience	completed	\N	1.00	22	2026-09-10 18:44:13.592751
515	20260901	Mkx7Qp8nCys	comments	completed	\N	1.00	15	2026-09-10 18:44:13.592751
516	20260901	Mkx7Qp8nCys	edit	completed	\N	1.00	18	2026-09-10 18:44:13.592751
525	20260901	a6DGQWZ57EE	overview	completed	\N	1.00	30	2026-09-10 19:33:03.635723
526	20260901	a6DGQWZ57EE	reach	completed	\N	1.00	25	2026-09-10 19:33:03.635723
527	20260901	a6DGQWZ57EE	engagement	completed	\N	1.00	20	2026-09-10 19:33:03.635723
528	20260901	a6DGQWZ57EE	audience	completed	\N	1.00	22	2026-09-10 19:33:03.635723
529	20260901	a6DGQWZ57EE	comments	completed	\N	1.00	15	2026-09-10 19:33:03.635723
530	20260901	a6DGQWZ57EE	edit	completed	\N	1.00	18	2026-09-10 19:33:03.635723
532	1	_6qJfWvvWJo	overview	completed	\N	1.00	30	2026-09-10 19:59:59.887221
533	1	_6qJfWvvWJo	reach	completed	\N	1.00	25	2026-09-10 19:59:59.887221
534	1	_6qJfWvvWJo	engagement	completed	\N	1.00	20	2026-09-10 19:59:59.887221
535	1	_6qJfWvvWJo	audience	completed	\N	1.00	22	2026-09-10 19:59:59.887221
536	1	_6qJfWvvWJo	comments	completed	\N	1.00	15	2026-09-10 19:59:59.887221
537	1	_6qJfWvvWJo	edit	completed	\N	1.00	18	2026-09-10 19:59:59.887221
565	20260901	pl90QEsoKFk	overview	completed	\N	1.00	30	2026-09-10 23:10:00.515414
566	20260901	pl90QEsoKFk	reach	completed	\N	1.00	25	2026-09-10 23:10:00.515414
567	20260901	pl90QEsoKFk	engagement	completed	\N	1.00	20	2026-09-10 23:10:00.515414
568	20260901	pl90QEsoKFk	audience	completed	\N	1.00	22	2026-09-10 23:10:00.515414
569	20260901	pl90QEsoKFk	comments	completed	\N	1.00	15	2026-09-10 23:10:00.515414
570	20260901	pl90QEsoKFk	edit	completed	\N	1.00	18	2026-09-10 23:10:00.515414
577	20260901	mK2nGGZFRVI	overview	completed	\N	1.00	30	2026-09-11 10:53:51.650803
578	20260901	mK2nGGZFRVI	reach	completed	\N	1.00	25	2026-09-11 10:53:51.650803
579	20260901	mK2nGGZFRVI	engagement	completed	\N	1.00	20	2026-09-11 10:53:51.650803
580	20260901	mK2nGGZFRVI	audience	completed	\N	1.00	22	2026-09-11 10:53:51.650803
581	20260901	mK2nGGZFRVI	comments	completed	\N	1.00	15	2026-09-11 10:53:51.650803
582	20260901	mK2nGGZFRVI	edit	completed	\N	1.00	18	2026-09-11 10:53:51.650803
585	20260901	A2U9omXQ2go	engagement	completed	\N	1.00	20	2026-09-11 12:57:35.796334
586	20260901	A2U9omXQ2go	audience	completed	\N	1.00	22	2026-09-11 12:57:35.796334
587	20260901	A2U9omXQ2go	comments	completed	\N	1.00	15	2026-09-11 12:57:35.796334
588	20260901	A2U9omXQ2go	edit	completed	\N	1.00	18	2026-09-11 12:57:35.796334
589	20260901	A2U9omXQ2go	overview	completed	\N	1.00	30	2026-09-11 13:05:32.12302
590	20260901	A2U9omXQ2go	reach	completed	\N	1.00	25	2026-09-11 13:05:32.12302
591	20260901	A2U9omXQ2go	engagement	completed	\N	1.00	20	2026-09-11 13:05:32.12302
592	20260901	A2U9omXQ2go	audience	completed	\N	1.00	22	2026-09-11 13:05:32.12302
593	20260901	A2U9omXQ2go	comments	completed	\N	1.00	15	2026-09-11 13:05:32.12302
594	20260901	A2U9omXQ2go	edit	completed	\N	1.00	18	2026-09-11 13:05:32.12302
595	20260901	fsSkI-1Opvk	overview	completed	\N	1.00	30	2026-09-11 16:20:32.995425
596	20260901	fsSkI-1Opvk	reach	completed	\N	1.00	25	2026-09-11 16:20:32.995425
597	20260901	fsSkI-1Opvk	engagement	completed	\N	1.00	20	2026-09-11 16:20:32.995425
598	20260901	fsSkI-1Opvk	audience	completed	\N	1.00	22	2026-09-11 16:20:32.995425
599	20260901	fsSkI-1Opvk	comments	completed	\N	1.00	15	2026-09-11 16:20:32.995425
600	20260901	fsSkI-1Opvk	edit	completed	\N	1.00	18	2026-09-11 16:20:32.995425
601	20260901	pbU_sJKSfrg	overview	completed	\N	1.00	30	2026-09-11 16:20:34.478996
602	20260901	pbU_sJKSfrg	reach	completed	\N	1.00	25	2026-09-11 16:20:34.478996
603	20260901	pbU_sJKSfrg	engagement	completed	\N	1.00	20	2026-09-11 16:20:34.478996
604	20260901	pbU_sJKSfrg	audience	completed	\N	1.00	22	2026-09-11 16:20:34.478996
605	20260901	pbU_sJKSfrg	comments	completed	\N	1.00	15	2026-09-11 16:20:34.478996
606	20260901	pbU_sJKSfrg	edit	completed	\N	1.00	18	2026-09-11 16:20:34.478996
607	20260901	W1nCo6y71R8	overview	completed	\N	1.00	30	2026-09-11 16:35:53.569939
608	20260901	W1nCo6y71R8	reach	completed	\N	1.00	25	2026-09-11 16:35:53.569939
609	20260901	W1nCo6y71R8	engagement	completed	\N	1.00	20	2026-09-11 16:35:53.569939
610	20260901	W1nCo6y71R8	audience	completed	\N	1.00	22	2026-09-11 16:35:53.569939
611	20260901	W1nCo6y71R8	comments	completed	\N	1.00	15	2026-09-11 16:35:53.569939
612	20260901	W1nCo6y71R8	edit	completed	\N	1.00	18	2026-09-11 16:35:53.569939
931	20260901	wnp9gFm7ZpY	overview	completed	\N	1.00	30	2026-09-12 21:46:22.459929
932	20260901	wnp9gFm7ZpY	reach	completed	\N	1.00	25	2026-09-12 21:46:22.459929
933	20260901	wnp9gFm7ZpY	engagement	completed	\N	1.00	20	2026-09-12 21:46:22.459929
934	20260901	wnp9gFm7ZpY	audience	completed	\N	1.00	22	2026-09-12 21:46:22.459929
935	20260901	wnp9gFm7ZpY	comments	completed	\N	1.00	15	2026-09-12 21:46:22.459929
936	20260901	wnp9gFm7ZpY	edit	completed	\N	1.00	18	2026-09-12 21:46:22.459929
955	20260901	kbLQ0kJ7pYQ	overview	completed	\N	1.00	30	2026-09-13 00:04:05.182697
956	20260901	kbLQ0kJ7pYQ	reach	completed	\N	1.00	25	2026-09-13 00:04:05.182697
957	20260901	kbLQ0kJ7pYQ	engagement	completed	\N	1.00	20	2026-09-13 00:04:05.182697
958	20260901	kbLQ0kJ7pYQ	audience	completed	\N	1.00	22	2026-09-13 00:04:05.182697
959	20260901	kbLQ0kJ7pYQ	comments	completed	\N	1.00	15	2026-09-13 00:04:05.182697
960	20260901	kbLQ0kJ7pYQ	edit	completed	\N	1.00	18	2026-09-13 00:04:05.182697
625	20260901	xj4emmUcJGE	overview	completed	\N	1.00	30	2026-09-11 16:35:54.654653
626	20260901	xj4emmUcJGE	reach	completed	\N	1.00	25	2026-09-11 16:35:54.654653
627	20260901	xj4emmUcJGE	engagement	completed	\N	1.00	20	2026-09-11 16:35:54.654653
628	20260901	xj4emmUcJGE	audience	completed	\N	1.00	22	2026-09-11 16:35:54.654653
629	20260901	xj4emmUcJGE	comments	completed	\N	1.00	15	2026-09-11 16:35:54.654653
630	20260901	xj4emmUcJGE	edit	completed	\N	1.00	18	2026-09-11 16:35:54.654653
631	20260901	w2UTdzsuads	overview	completed	\N	1.00	30	2026-09-11 16:35:54.958145
632	20260901	w2UTdzsuads	reach	completed	\N	1.00	25	2026-09-11 16:35:54.958145
633	20260901	w2UTdzsuads	engagement	completed	\N	1.00	20	2026-09-11 16:35:54.958145
634	20260901	w2UTdzsuads	audience	completed	\N	1.00	22	2026-09-11 16:35:54.958145
635	20260901	w2UTdzsuads	comments	completed	\N	1.00	15	2026-09-11 16:35:54.958145
636	20260901	w2UTdzsuads	edit	completed	\N	1.00	18	2026-09-11 16:35:54.958145
637	20260901	SOKrC7BJ418	overview	completed	\N	1.00	30	2026-09-11 16:35:55.319378
638	20260901	SOKrC7BJ418	reach	completed	\N	1.00	25	2026-09-11 16:35:55.319378
639	20260901	SOKrC7BJ418	engagement	completed	\N	1.00	20	2026-09-11 16:35:55.319378
640	20260901	SOKrC7BJ418	audience	completed	\N	1.00	22	2026-09-11 16:35:55.319378
641	20260901	SOKrC7BJ418	comments	completed	\N	1.00	15	2026-09-11 16:35:55.319378
642	20260901	SOKrC7BJ418	edit	completed	\N	1.00	18	2026-09-11 16:35:55.319378
643	20260901	PaYUzmc11E8	overview	completed	\N	1.00	30	2026-09-11 16:35:55.65266
644	20260901	PaYUzmc11E8	reach	completed	\N	1.00	25	2026-09-11 16:35:55.65266
645	20260901	PaYUzmc11E8	engagement	completed	\N	1.00	20	2026-09-11 16:35:55.65266
646	20260901	PaYUzmc11E8	audience	completed	\N	1.00	22	2026-09-11 16:35:55.65266
647	20260901	PaYUzmc11E8	comments	completed	\N	1.00	15	2026-09-11 16:35:55.65266
648	20260901	PaYUzmc11E8	edit	completed	\N	1.00	18	2026-09-11 16:35:55.65266
649	20260901	0KAZqj8-gFo	overview	completed	\N	1.00	30	2026-09-11 16:35:55.987093
650	20260901	0KAZqj8-gFo	reach	completed	\N	1.00	25	2026-09-11 16:35:55.987093
651	20260901	0KAZqj8-gFo	engagement	completed	\N	1.00	20	2026-09-11 16:35:55.987093
652	20260901	0KAZqj8-gFo	audience	completed	\N	1.00	22	2026-09-11 16:35:55.987093
653	20260901	0KAZqj8-gFo	comments	completed	\N	1.00	15	2026-09-11 16:35:55.987093
654	20260901	0KAZqj8-gFo	edit	completed	\N	1.00	18	2026-09-11 16:35:55.987093
979	20260901	ZrY0tM9yPxQ	overview	completed	\N	1.00	30	2026-09-13 00:39:03.743153
980	20260901	ZrY0tM9yPxQ	reach	completed	\N	1.00	25	2026-09-13 00:39:03.743153
981	20260901	ZrY0tM9yPxQ	engagement	completed	\N	1.00	20	2026-09-13 00:39:03.743153
982	20260901	ZrY0tM9yPxQ	audience	completed	\N	1.00	22	2026-09-13 00:39:03.743153
983	20260901	ZrY0tM9yPxQ	comments	completed	\N	1.00	15	2026-09-13 00:39:03.743153
984	20260901	ZrY0tM9yPxQ	edit	completed	\N	1.00	18	2026-09-13 00:39:03.743153
1027	20260901	QnjyscmnjEQ	overview	completed	\N	1.00	30	2026-09-13 01:04:42.898173
1028	20260901	QnjyscmnjEQ	reach	completed	\N	1.00	25	2026-09-13 01:04:42.898173
1029	20260901	QnjyscmnjEQ	engagement	completed	\N	1.00	20	2026-09-13 01:04:42.898173
1030	20260901	QnjyscmnjEQ	audience	completed	\N	1.00	22	2026-09-13 01:04:42.898173
1031	20260901	QnjyscmnjEQ	comments	completed	\N	1.00	15	2026-09-13 01:04:42.898173
1032	20260901	QnjyscmnjEQ	edit	completed	\N	1.00	18	2026-09-13 01:04:42.898173
1099	20260901	j7xmoRH2rzo	overview	completed	\N	1.00	30	2026-09-13 08:04:48.235092
1100	20260901	j7xmoRH2rzo	reach	completed	\N	1.00	25	2026-09-13 08:04:48.235092
1101	20260901	j7xmoRH2rzo	engagement	completed	\N	1.00	20	2026-09-13 08:04:48.235092
1102	20260901	j7xmoRH2rzo	audience	completed	\N	1.00	22	2026-09-13 08:04:48.235092
1103	20260901	j7xmoRH2rzo	comments	completed	\N	1.00	15	2026-09-13 08:04:48.235092
1104	20260901	j7xmoRH2rzo	edit	completed	\N	1.00	18	2026-09-13 08:04:48.235092
1123	20260901	4yAeMwjZxoo	overview	completed	\N	1.00	30	2026-09-13 08:12:31.899566
1124	20260901	4yAeMwjZxoo	reach	completed	\N	1.00	25	2026-09-13 08:12:31.899566
1125	20260901	4yAeMwjZxoo	engagement	completed	\N	1.00	20	2026-09-13 08:12:31.899566
1126	20260901	4yAeMwjZxoo	audience	completed	\N	1.00	22	2026-09-13 08:12:31.899566
1127	20260901	4yAeMwjZxoo	comments	completed	\N	1.00	15	2026-09-13 08:12:31.899566
1128	20260901	4yAeMwjZxoo	edit	completed	\N	1.00	18	2026-09-13 08:12:31.899566
937	20260901	rrTB_XW3pWA	overview	completed	\N	1.00	30	2026-09-12 22:06:31.315393
938	20260901	rrTB_XW3pWA	reach	completed	\N	1.00	25	2026-09-12 22:06:31.315393
939	20260901	rrTB_XW3pWA	engagement	completed	\N	1.00	20	2026-09-12 22:06:31.315393
940	20260901	rrTB_XW3pWA	audience	completed	\N	1.00	22	2026-09-12 22:06:31.315393
941	20260901	rrTB_XW3pWA	comments	completed	\N	1.00	15	2026-09-12 22:06:31.315393
942	20260901	rrTB_XW3pWA	edit	completed	\N	1.00	18	2026-09-12 22:06:31.315393
961	20260901	AwJoDsJiAoQ	overview	completed	\N	1.00	30	2026-09-13 00:30:05.383779
962	20260901	AwJoDsJiAoQ	reach	completed	\N	1.00	25	2026-09-13 00:30:05.383779
963	20260901	AwJoDsJiAoQ	engagement	completed	\N	1.00	20	2026-09-13 00:30:05.383779
964	20260901	AwJoDsJiAoQ	audience	completed	\N	1.00	22	2026-09-13 00:30:05.383779
965	20260901	AwJoDsJiAoQ	comments	completed	\N	1.00	15	2026-09-13 00:30:05.383779
966	20260901	AwJoDsJiAoQ	edit	completed	\N	1.00	18	2026-09-13 00:30:05.383779
985	20260901	hiP5k2gClN0	overview	completed	\N	1.00	30	2026-09-13 00:39:10.017376
986	20260901	hiP5k2gClN0	reach	completed	\N	1.00	25	2026-09-13 00:39:10.017376
987	20260901	hiP5k2gClN0	engagement	completed	\N	1.00	20	2026-09-13 00:39:10.017376
988	20260901	hiP5k2gClN0	audience	completed	\N	1.00	22	2026-09-13 00:39:10.017376
989	20260901	hiP5k2gClN0	comments	completed	\N	1.00	15	2026-09-13 00:39:10.017376
990	20260901	hiP5k2gClN0	edit	completed	\N	1.00	18	2026-09-13 00:39:10.017376
1009	20260901	3JdwNxhgqN8	overview	completed	\N	1.00	30	2026-09-13 00:48:04.423667
1010	20260901	3JdwNxhgqN8	reach	completed	\N	1.00	25	2026-09-13 00:48:04.423667
1011	20260901	3JdwNxhgqN8	engagement	completed	\N	1.00	20	2026-09-13 00:48:04.423667
1012	20260901	3JdwNxhgqN8	audience	completed	\N	1.00	22	2026-09-13 00:48:04.423667
1013	20260901	3JdwNxhgqN8	comments	completed	\N	1.00	15	2026-09-13 00:48:04.423667
1014	20260901	3JdwNxhgqN8	edit	completed	\N	1.00	18	2026-09-13 00:48:04.423667
1105	20260901	muLRYXpkVWA	overview	completed	\N	1.00	30	2026-09-13 08:06:19.001339
1106	20260901	muLRYXpkVWA	reach	completed	\N	1.00	25	2026-09-13 08:06:19.001339
1107	20260901	muLRYXpkVWA	engagement	completed	\N	1.00	20	2026-09-13 08:06:19.001339
1108	20260901	muLRYXpkVWA	audience	completed	\N	1.00	22	2026-09-13 08:06:19.001339
1109	20260901	muLRYXpkVWA	comments	completed	\N	1.00	15	2026-09-13 08:06:19.001339
1110	20260901	muLRYXpkVWA	edit	completed	\N	1.00	18	2026-09-13 08:06:19.001339
1129	20260901	SS61lwI_i5Q	overview	completed	\N	1.00	30	2026-09-13 08:20:20.943281
1130	20260901	SS61lwI_i5Q	reach	completed	\N	1.00	25	2026-09-13 08:20:20.943281
1131	20260901	SS61lwI_i5Q	engagement	completed	\N	1.00	20	2026-09-13 08:20:20.943281
1132	20260901	SS61lwI_i5Q	audience	completed	\N	1.00	22	2026-09-13 08:20:20.943281
1133	20260901	SS61lwI_i5Q	comments	completed	\N	1.00	15	2026-09-13 08:20:20.943281
1134	20260901	SS61lwI_i5Q	edit	completed	\N	1.00	18	2026-09-13 08:20:20.943281
943	20260901	rrTB_XW3pWA	overview	completed	\N	1.00	30	2026-09-12 23:23:30.318307
944	20260901	rrTB_XW3pWA	reach	completed	\N	1.00	25	2026-09-12 23:23:30.318307
945	20260901	rrTB_XW3pWA	engagement	completed	\N	1.00	20	2026-09-12 23:23:30.318307
946	20260901	rrTB_XW3pWA	audience	completed	\N	1.00	22	2026-09-12 23:23:30.318307
947	20260901	rrTB_XW3pWA	comments	completed	\N	1.00	15	2026-09-12 23:23:30.318307
948	20260901	rrTB_XW3pWA	edit	completed	\N	1.00	18	2026-09-12 23:23:30.318307
967	20260901	ZrY0tM9yPxQ	overview	completed	\N	1.00	30	2026-09-13 00:37:30.390512
968	20260901	ZrY0tM9yPxQ	reach	completed	\N	1.00	25	2026-09-13 00:37:30.390512
969	20260901	ZrY0tM9yPxQ	engagement	completed	\N	1.00	20	2026-09-13 00:37:30.390512
970	20260901	ZrY0tM9yPxQ	audience	completed	\N	1.00	22	2026-09-13 00:37:30.390512
971	20260901	ZrY0tM9yPxQ	comments	completed	\N	1.00	15	2026-09-13 00:37:30.390512
972	20260901	ZrY0tM9yPxQ	edit	completed	\N	1.00	18	2026-09-13 00:37:30.390512
793	20260901	fsSkI-1Opvk	overview	completed	\N	1.00	30	2026-09-11 17:24:40.362794
794	20260901	fsSkI-1Opvk	reach	completed	\N	1.00	25	2026-09-11 17:24:40.362794
795	20260901	fsSkI-1Opvk	engagement	completed	\N	1.00	20	2026-09-11 17:24:40.362794
796	20260901	fsSkI-1Opvk	audience	completed	\N	1.00	22	2026-09-11 17:24:40.362794
797	20260901	fsSkI-1Opvk	comments	completed	\N	1.00	15	2026-09-11 17:24:40.362794
798	20260901	fsSkI-1Opvk	edit	completed	\N	1.00	18	2026-09-11 17:24:40.362794
799	20260901	fsSkI-1Opvk	overview	completed	\N	1.00	30	2026-09-11 17:33:13.71998
800	20260901	fsSkI-1Opvk	reach	completed	\N	1.00	25	2026-09-11 17:33:13.71998
801	20260901	fsSkI-1Opvk	engagement	completed	\N	1.00	20	2026-09-11 17:33:13.71998
802	20260901	fsSkI-1Opvk	audience	completed	\N	1.00	22	2026-09-11 17:33:13.71998
803	20260901	fsSkI-1Opvk	comments	completed	\N	1.00	15	2026-09-11 17:33:13.71998
804	20260901	fsSkI-1Opvk	edit	completed	\N	1.00	18	2026-09-11 17:33:13.71998
805	20260901	fsSkI-1Opvk	overview	completed	\N	1.00	30	2026-09-11 22:58:05.388618
806	20260901	fsSkI-1Opvk	reach	completed	\N	1.00	25	2026-09-11 22:58:05.388618
807	20260901	fsSkI-1Opvk	engagement	completed	\N	1.00	20	2026-09-11 22:58:05.388618
808	20260901	fsSkI-1Opvk	audience	completed	\N	1.00	22	2026-09-11 22:58:05.388618
809	20260901	fsSkI-1Opvk	comments	completed	\N	1.00	15	2026-09-11 22:58:05.388618
810	20260901	fsSkI-1Opvk	edit	completed	\N	1.00	18	2026-09-11 22:58:05.388618
811	20260901	pbU_sJKSfrg	overview	completed	\N	1.00	30	2026-09-11 22:58:06.014146
812	20260901	pbU_sJKSfrg	reach	completed	\N	1.00	25	2026-09-11 22:58:06.014146
813	20260901	pbU_sJKSfrg	engagement	completed	\N	1.00	20	2026-09-11 22:58:06.014146
814	20260901	pbU_sJKSfrg	audience	completed	\N	1.00	22	2026-09-11 22:58:06.014146
815	20260901	pbU_sJKSfrg	comments	completed	\N	1.00	15	2026-09-11 22:58:06.014146
816	20260901	pbU_sJKSfrg	edit	completed	\N	1.00	18	2026-09-11 22:58:06.014146
817	20260901	W1nCo6y71R8	overview	completed	\N	1.00	30	2026-09-11 22:58:06.303119
818	20260901	W1nCo6y71R8	reach	completed	\N	1.00	25	2026-09-11 22:58:06.303119
819	20260901	W1nCo6y71R8	engagement	completed	\N	1.00	20	2026-09-11 22:58:06.303119
820	20260901	W1nCo6y71R8	audience	completed	\N	1.00	22	2026-09-11 22:58:06.303119
821	20260901	W1nCo6y71R8	comments	completed	\N	1.00	15	2026-09-11 22:58:06.303119
822	20260901	W1nCo6y71R8	edit	completed	\N	1.00	18	2026-09-11 22:58:06.303119
835	20260901	xj4emmUcJGE	overview	completed	\N	1.00	30	2026-09-11 22:58:07.287609
836	20260901	xj4emmUcJGE	reach	completed	\N	1.00	25	2026-09-11 22:58:07.287609
837	20260901	xj4emmUcJGE	engagement	completed	\N	1.00	20	2026-09-11 22:58:07.287609
838	20260901	xj4emmUcJGE	audience	completed	\N	1.00	22	2026-09-11 22:58:07.287609
839	20260901	xj4emmUcJGE	comments	completed	\N	1.00	15	2026-09-11 22:58:07.287609
840	20260901	xj4emmUcJGE	edit	completed	\N	1.00	18	2026-09-11 22:58:07.287609
841	20260901	w2UTdzsuads	overview	completed	\N	1.00	30	2026-09-11 22:58:07.599184
842	20260901	w2UTdzsuads	reach	completed	\N	1.00	25	2026-09-11 22:58:07.599184
843	20260901	w2UTdzsuads	engagement	completed	\N	1.00	20	2026-09-11 22:58:07.599184
844	20260901	w2UTdzsuads	audience	completed	\N	1.00	22	2026-09-11 22:58:07.599184
845	20260901	w2UTdzsuads	comments	completed	\N	1.00	15	2026-09-11 22:58:07.599184
846	20260901	w2UTdzsuads	edit	completed	\N	1.00	18	2026-09-11 22:58:07.599184
1111	20260901	_gF2JDP64Yc	overview	completed	\N	1.00	30	2026-09-13 08:06:26.943876
1112	20260901	_gF2JDP64Yc	reach	completed	\N	1.00	25	2026-09-13 08:06:26.943876
1113	20260901	_gF2JDP64Yc	engagement	completed	\N	1.00	20	2026-09-13 08:06:26.943876
1114	20260901	_gF2JDP64Yc	audience	completed	\N	1.00	22	2026-09-13 08:06:26.943876
1115	20260901	_gF2JDP64Yc	comments	completed	\N	1.00	15	2026-09-13 08:06:26.943876
1116	20260901	_gF2JDP64Yc	edit	completed	\N	1.00	18	2026-09-13 08:06:26.943876
1135	20260901	BMh9Xq36RrA	overview	completed	\N	1.00	30	2026-09-13 08:22:34.508287
1136	20260901	BMh9Xq36RrA	reach	completed	\N	1.00	25	2026-09-13 08:22:34.508287
1137	20260901	BMh9Xq36RrA	engagement	completed	\N	1.00	20	2026-09-13 08:22:34.508287
1138	20260901	BMh9Xq36RrA	audience	completed	\N	1.00	22	2026-09-13 08:22:34.508287
1139	20260901	BMh9Xq36RrA	comments	completed	\N	1.00	15	2026-09-13 08:22:34.508287
1140	20260901	BMh9Xq36RrA	edit	completed	\N	1.00	18	2026-09-13 08:22:34.508287
847	20260901	SOKrC7BJ418	overview	completed	\N	1.00	30	2026-09-11 22:58:07.871575
848	20260901	SOKrC7BJ418	reach	completed	\N	1.00	25	2026-09-11 22:58:07.871575
849	20260901	SOKrC7BJ418	engagement	completed	\N	1.00	20	2026-09-11 22:58:07.871575
850	20260901	SOKrC7BJ418	audience	completed	\N	1.00	22	2026-09-11 22:58:07.871575
851	20260901	SOKrC7BJ418	comments	completed	\N	1.00	15	2026-09-11 22:58:07.871575
852	20260901	SOKrC7BJ418	edit	completed	\N	1.00	18	2026-09-11 22:58:07.871575
853	20260901	PaYUzmc11E8	overview	completed	\N	1.00	30	2026-09-11 22:58:08.189019
854	20260901	PaYUzmc11E8	reach	completed	\N	1.00	25	2026-09-11 22:58:08.189019
855	20260901	PaYUzmc11E8	engagement	completed	\N	1.00	20	2026-09-11 22:58:08.189019
856	20260901	PaYUzmc11E8	audience	completed	\N	1.00	22	2026-09-11 22:58:08.189019
857	20260901	PaYUzmc11E8	comments	completed	\N	1.00	15	2026-09-11 22:58:08.189019
858	20260901	PaYUzmc11E8	edit	completed	\N	1.00	18	2026-09-11 22:58:08.189019
859	20260901	0KAZqj8-gFo	overview	completed	\N	1.00	30	2026-09-11 22:58:08.519442
860	20260901	0KAZqj8-gFo	reach	completed	\N	1.00	25	2026-09-11 22:58:08.519442
861	20260901	0KAZqj8-gFo	engagement	completed	\N	1.00	20	2026-09-11 22:58:08.519442
862	20260901	0KAZqj8-gFo	audience	completed	\N	1.00	22	2026-09-11 22:58:08.519442
863	20260901	0KAZqj8-gFo	comments	completed	\N	1.00	15	2026-09-11 22:58:08.519442
864	20260901	0KAZqj8-gFo	edit	completed	\N	1.00	18	2026-09-11 22:58:08.519442
949	20260901	rrTB_XW3pWA	overview	completed	\N	1.00	30	2026-09-12 23:25:09.52654
950	20260901	rrTB_XW3pWA	reach	completed	\N	1.00	25	2026-09-12 23:25:09.52654
951	20260901	rrTB_XW3pWA	engagement	completed	\N	1.00	20	2026-09-12 23:25:09.52654
952	20260901	rrTB_XW3pWA	audience	completed	\N	1.00	22	2026-09-12 23:25:09.52654
953	20260901	rrTB_XW3pWA	comments	completed	\N	1.00	15	2026-09-12 23:25:09.52654
954	20260901	rrTB_XW3pWA	edit	completed	\N	1.00	18	2026-09-12 23:25:09.52654
973	20260901	3JdwNxhgqN8	overview	completed	\N	1.00	30	2026-09-13 00:38:36.543059
974	20260901	3JdwNxhgqN8	reach	completed	\N	1.00	25	2026-09-13 00:38:36.543059
975	20260901	3JdwNxhgqN8	engagement	completed	\N	1.00	20	2026-09-13 00:38:36.543059
976	20260901	3JdwNxhgqN8	audience	completed	\N	1.00	22	2026-09-13 00:38:36.543059
977	20260901	3JdwNxhgqN8	comments	completed	\N	1.00	15	2026-09-13 00:38:36.543059
978	20260901	3JdwNxhgqN8	edit	completed	\N	1.00	18	2026-09-13 00:38:36.543059
997	20260901	DrhZsdeBj6k	overview	completed	\N	1.00	30	2026-09-13 00:39:55.370257
998	20260901	DrhZsdeBj6k	reach	completed	\N	1.00	25	2026-09-13 00:39:55.370257
999	20260901	DrhZsdeBj6k	engagement	completed	\N	1.00	20	2026-09-13 00:39:55.370257
1000	20260901	DrhZsdeBj6k	audience	completed	\N	1.00	22	2026-09-13 00:39:55.370257
1001	20260901	DrhZsdeBj6k	comments	completed	\N	1.00	15	2026-09-13 00:39:55.370257
1002	20260901	DrhZsdeBj6k	edit	completed	\N	1.00	18	2026-09-13 00:39:55.370257
1117	20260901	5v6ouzwDdRQ	overview	completed	\N	1.00	30	2026-09-13 08:07:14.421856
1118	20260901	5v6ouzwDdRQ	reach	completed	\N	1.00	25	2026-09-13 08:07:14.421856
1119	20260901	5v6ouzwDdRQ	engagement	completed	\N	1.00	20	2026-09-13 08:07:14.421856
1120	20260901	5v6ouzwDdRQ	audience	completed	\N	1.00	22	2026-09-13 08:07:14.421856
1121	20260901	5v6ouzwDdRQ	comments	completed	\N	1.00	15	2026-09-13 08:07:14.421856
1122	20260901	5v6ouzwDdRQ	edit	completed	\N	1.00	18	2026-09-13 08:07:14.421856
\.


--
-- Data for Name: analysis_sessions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.analysis_sessions (id, session_id, started_at, completed_at, videos_analyzed, analyzer_version, notes, status) FROM stdin;
1	session_20260831_001	2026-08-31 00:00:00	2026-08-31 00:30:00	{5goNjmztwqg}	v1.0	Forensic analysis of Short 1 (oldest) - JEE tips Part 1	completed
2	session_20260831_002	2026-08-31 00:00:00	2026-08-31 00:30:00	{0jstRcQmAro}	v1.0	Forensic analysis of Short 2 (chronological) - JEE tips Part 2	completed
20260901	20260901_analysis	2026-09-01 00:00:00	2026-09-01 00:00:00	{s_PoEssiuPo}	1.0	Short #5 forensic analysis complete - JEE Tips series complete	complete
\.


--
-- Data for Name: audience_age; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.audience_age (video_id, age_13_17_pct, age_18_24_pct, age_25_34_pct, age_35_44_pct, age_45_54_pct, age_55_64_pct, age_65_plus_pct, target_audience_pct, non_target_pct, has_data, fetched_at) FROM stdin;
5goNjmztwqg	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	100.00	f	2026-09-02 09:40:57.778366
0jstRcQmAro	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	100.00	f	2026-09-01 08:45:25.36398
XWFbqR_9fqc	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	100.00	f	2026-09-01 09:19:49.888536
Pwp0zPAY6Y4	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	100.00	f	2026-09-01 09:29:40.491408
s_PoEssiuPo	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	100.00	f	2026-09-01 09:42:27.379694
yDKB-xCaMB8	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	100.00	f	2026-09-02 14:30:31.576863
rg5iPj-249o	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	100.00	f	2026-09-02 14:58:55.032747
waW201cvfl8	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	100.00	f	2026-09-02 15:14:09.210888
UTeogxHwnPw	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	100.00	f	2026-09-02 00:00:20.756231
zdOSsbqouKE	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	100.00	f	2026-09-02 00:11:35.176582
nJNR60Ms1BE	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	100.00	f	2026-09-02 09:07:53.238004
_A5Idj7SddI	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	100.00	f	2026-09-02 09:12:13.902042
BJ5lJob_sDU	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	100.00	f	2026-09-02 09:20:33.221739
OkWbChCIb04	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	100.00	f	2026-09-02 10:13:50.522983
2jcdStwq2yY	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	100.00	f	2026-09-02 10:20:48.373197
wnp9gFm7ZpY	15.00	0.00	15.00	15.00	8.00	0.00	0.00	0.00	100.00	t	2026-09-10 22:48:19.000993
sHwtsGShqjE	18.20	41.80	18.70	13.90	7.40	0.00	0.00	41.80	58.20	t	2026-09-03 10:11:18.411369
Wyt0zC-zadM	0.00	100.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	t	2026-09-03 12:28:17.67752
JRrvbkvRyiI	15.00	54.20	11.30	11.00	8.60	0.00	0.00	0.00	0.00	t	2026-09-03 12:45:38.189925
pTiZBob0vWA	22.10	53.30	13.90	10.60	0.00	0.00	0.00	0.00	0.00	t	2026-09-03 13:23:31.162254
12BKLbv0Eso	21.70	55.30	5.80	11.20	6.00	0.00	0.00	77.00	23.00	t	2026-09-02 08:57:44.373087
XM1AzgVMeqk	18.90	81.10	0.00	0.00	0.00	0.00	0.00	100.00	0.00	t	2026-09-02 09:02:32.054168
F6g5hMAUH6A	0.00	100.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	t	2026-09-03 13:36:14.415812
durkT5BI9-0	21.20	78.90	0.00	0.00	0.00	0.00	0.00	0.00	0.00	t	2026-09-03 14:13:12.403346
-ntsqYRrjic	10.90	73.70	6.00	9.40	0.00	0.00	0.00	0.00	0.00	t	2026-09-03 14:22:21.576395
kQlrFbAzvro	18.50	56.50	9.90	10.00	5.20	0.00	0.00	0.00	0.00	t	2026-09-03 14:34:36.771304
VkXC2gAxVvs	15.50	51.40	13.90	10.40	8.80	0.00	0.00	0.00	0.00	t	2026-09-03 21:29:21.003798
QC45KrzAuLs	0.00	64.80	17.30	17.90	0.00	0.00	0.00	0.00	0.00	t	2026-09-03 21:44:00.314367
gNgwb1lmKL8	11.00	69.00	12.20	7.90	0.00	0.00	0.00	0.00	0.00	t	2026-09-03 22:06:49.206096
XlOAFuUr7F4	15.70	51.30	11.60	14.80	6.60	0.00	0.00	0.00	0.00	t	2026-09-03 22:31:30.815574
d-p-YuOjU-8	0.00	100.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	t	2026-09-03 22:47:40.537674
7L-wWpll_GU	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	f	2026-09-03 22:59:23.098487
pszcrf0uTbQ	14.10	66.80	8.50	7.60	3.00	0.00	0.00	0.00	0.00	t	2026-09-03 23:21:10.33918
EDNdXwv7W64	18.40	59.70	8.60	13.30	0.00	0.00	0.00	0.00	0.00	t	2026-09-04 09:55:24.289926
DdMa3y_sImk	0.00	100.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	t	2026-09-04 12:02:37.004788
YFnY2guPlxg	14.40	47.00	14.70	15.20	8.80	0.00	0.00	0.00	0.00	t	2026-09-04 12:04:52.149361
noF6FnkgYmE	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	f	2026-09-04 12:16:10.255319
tyxuLrd-xo4	23.80	47.00	0.00	14.10	15.10	0.00	0.00	0.00	0.00	t	2026-09-04 12:33:43.388322
UzWyYR6WM6U	20.20	45.20	14.10	20.50	0.00	0.00	0.00	0.00	0.00	t	2026-09-04 12:56:32.962168
3gSWKoBeqnw	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	f	2026-09-04 13:19:16.949153
impBBFcUinY	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	f	2026-09-04 13:33:07.646614
Ay9K30yrg8Y	0.00	70.50	29.50	0.00	0.00	0.00	0.00	70.50	29.50	t	2026-09-02 15:27:50.633383
lmbndk-Db-Q	0.00	100.00	0.00	0.00	0.00	0.00	0.00	100.00	0.00	t	2026-09-02 21:49:28.223132
cSapjDf5CHY	0.00	100.00	0.00	0.00	0.00	0.00	0.00	100.00	0.00	t	2026-09-02 23:46:30.338612
JmSdjrAxNFM	0.00	100.00	0.00	0.00	0.00	0.00	0.00	100.00	0.00	t	2026-09-03 08:43:48.484092
MpQ-K2D9Ao4	18.30	56.40	13.80	11.50	0.00	0.00	0.00	70.20	29.80	t	2026-09-03 08:46:53.14088
bXetyvX2Mu8	0.00	100.00	0.00	0.00	0.00	0.00	0.00	100.00	0.00	t	2026-09-03 08:49:33.548839
pHfj5VVN0Ew	21.90	78.10	0.00	0.00	0.00	0.00	0.00	78.10	21.90	t	2026-09-03 08:52:31.076945
dpTHfuBYClo	16.90	58.30	24.70	0.00	0.00	0.00	0.00	58.30	41.70	t	2026-09-03 08:54:48.143719
kIrFARfeW5o	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	f	2026-09-04 13:45:31.604043
FwuhJ23l7R4	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	f	2026-09-04 15:17:53.707086
kbLQ0kJ7pYQ	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	f	2026-09-13 00:04:05.182697
tO8vEcWUFXs	0.00	100.00	0.00	0.00	0.00	0.00	0.00	100.00	0.00	t	2026-09-05 19:35:09.745882
m1qgKExs2BY	15.20	84.80	0.00	0.00	0.00	0.00	0.00	84.80	15.20	t	2026-09-05 19:53:35.380044
_vTmJ79_4ho	0.00	100.00	0.00	0.00	0.00	0.00	0.00	100.00	0.00	t	2026-09-05 20:12:48.727333
atkvEdcPidM	40.00	45.00	10.00	3.00	1.00	0.50	0.50	85.00	15.00	f	2026-09-06 08:41:17.107595
dudb29Xqo60	30.00	55.00	10.00	3.00	1.00	0.50	0.50	85.00	15.00	f	2026-09-06 08:53:13.551357
9jXcNZyYza8	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	f	2026-09-06 09:14:07.3586
eC_j1wlFJBw	40.00	45.00	10.00	3.00	1.00	0.50	0.50	85.00	15.00	f	2026-09-06 09:30:05.833783
Q-IS9K8g294	40.00	45.00	10.00	3.00	1.00	0.50	0.50	85.00	15.00	f	2026-09-06 09:52:18.827983
p03EyeJlM-k	30.00	55.00	10.00	3.00	1.00	0.50	0.50	85.00	15.00	f	2026-09-06 12:19:14.187832
229XDzxoc4g	13.40	39.00	26.00	21.60	0.00	0.00	0.00	86.00	14.00	t	2026-09-06 13:26:52.660817
j4CtPMW-1Q4	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	f	2026-09-06 13:43:57.675416
iLZVyccaTJs	11.60	49.30	39.20	0.00	0.00	0.00	0.00	88.50	11.50	t	2026-09-06 13:51:03.028232
xBun0zPGZDA	13.40	39.20	25.50	22.00	0.00	0.00	0.00	0.00	0.00	t	2026-09-06 15:05:42.270667
4B4aAW76GLQ	9.20	51.20	27.20	12.40	0.00	0.00	0.00	51.20	48.80	t	2026-09-07 09:04:23.739817
LQ7ttolwjJQ	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	100.00	f	2026-09-07 10:50:43.305672
zqqcLDVZxR8	0.00	62.10	37.90	0.00	0.00	0.00	0.00	62.10	37.90	t	2026-09-07 10:57:07.066385
yBnFHlmgMFQ	18.30	40.60	13.40	18.30	9.40	0.00	0.00	0.00	100.00	t	2026-09-09 23:48:51.46802
YaAKtkecoRc	25.00	55.00	15.00	3.00	1.00	0.50	0.50	70.00	30.00	t	2026-09-08 10:48:39.159712
Mp1WHa-CXfw	15.00	45.00	25.00	10.00	5.00	0.00	0.00	85.00	15.00	t	2026-09-09 14:55:59.402702
D4KiNRb7UTk	18.50	42.00	25.00	10.00	3.00	1.00	0.50	65.00	35.00	t	2026-09-09 16:51:44.575471
bLwR73Y2d0w	8.40	47.70	17.80	16.20	9.90	0.00	0.00	0.00	0.00	t	2026-09-10 10:04:13.605465
Pnh6g6K9y8Q	14.40	61.30	24.30	0.00	0.00	0.00	0.00	0.00	100.00	t	2026-09-10 17:21:45.289572
DNIHqPqY3VM	7.00	47.70	24.20	21.20	0.00	0.00	0.00	0.00	100.00	t	2026-09-10 18:30:27.604051
Mkx7Qp8nCys	18.30	40.60	13.40	18.30	9.40	0.00	0.00	0.00	100.00	t	2026-09-10 18:43:32.427695
a6DGQWZ57EE	18.30	40.60	13.40	18.30	9.40	0.00	0.00	0.00	100.00	t	2026-09-10 19:31:27.388867
_6qJfWvvWJo	18.30	40.60	13.40	18.30	9.40	0.00	0.00	0.00	100.00	t	2026-09-10 19:56:28.467634
NVbNJeWZ1Lo	18.30	40.60	13.40	18.30	9.40	0.00	0.00	0.00	100.00	t	2026-09-10 20:21:07.431547
pl90QEsoKFk	0.00	20.50	29.80	19.90	21.70	8.10	0.00	0.00	100.00	t	2026-09-10 23:08:11.068235
3LCJCKfRATo	14.70	40.60	21.40	13.90	0.00	0.00	0.00	0.00	0.00	t	2026-09-03 21:16:47.035489
mK2nGGZFRVI	15.00	45.00	15.00	12.00	8.00	0.00	0.00	0.00	100.00	t	2026-09-11 10:53:51.650803
A2U9omXQ2go	15.00	45.00	15.00	12.00	8.00	0.00	0.00	0.00	100.00	t	2026-09-11 12:57:35.796334
pbU_sJKSfrg	20.00	55.00	15.00	5.00	3.00	1.00	1.00	70.00	30.00	t	2026-09-11 16:20:34.478996
W1nCo6y71R8	20.00	55.00	15.00	5.00	3.00	1.00	1.00	70.00	30.00	t	2026-09-11 16:35:53.569939
fsSkI-1Opvk	20.00	55.00	15.00	5.00	3.00	1.00	1.00	70.00	30.00	t	2026-09-11 16:20:32.995425
xj4emmUcJGE	20.00	55.00	15.00	5.00	3.00	1.00	1.00	70.00	30.00	t	2026-09-11 16:35:54.654653
w2UTdzsuads	20.00	55.00	15.00	5.00	3.00	1.00	1.00	70.00	30.00	t	2026-09-11 16:35:54.958145
SOKrC7BJ418	20.00	55.00	15.00	5.00	3.00	1.00	1.00	70.00	30.00	t	2026-09-11 16:35:55.319378
PaYUzmc11E8	20.00	55.00	15.00	5.00	3.00	1.00	1.00	70.00	30.00	t	2026-09-11 16:35:55.65266
0KAZqj8-gFo	20.00	55.00	15.00	5.00	3.00	1.00	1.00	70.00	30.00	t	2026-09-11 16:35:55.987093
rrTB_XW3pWA	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	f	2026-09-12 23:25:09.52654
AwJoDsJiAoQ	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	f	2026-09-13 00:30:05.383779
ZrY0tM9yPxQ	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	f	2026-09-13 00:39:03.743153
hiP5k2gClN0	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	f	2026-09-13 00:39:10.017376
DrhZsdeBj6k	0.00	0.00	0.00	0.00	0.00	0.00	0.40	0.00	0.00	t	2026-09-13 00:39:55.370257
QnjyscmnjEQ	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	f	2026-09-13 00:46:50.209022
3JdwNxhgqN8	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	f	2026-09-13 00:48:04.423667
j7xmoRH2rzo	2.00	28.20	34.80	27.40	7.60	0.00	0.00	63.00	37.00	t	2026-09-13 08:04:48.235092
muLRYXpkVWA	2.30	39.00	44.20	12.90	1.60	0.00	0.00	83.20	16.80	t	2026-09-13 08:06:19.001339
_gF2JDP64Yc	10.70	33.00	35.60	20.60	0.00	0.00	0.00	68.60	31.40	t	2026-09-13 08:06:26.943876
5v6ouzwDdRQ	0.00	0.00	0.00	100.00	0.00	0.00	0.00	0.00	100.00	t	2026-09-13 08:07:14.421856
4yAeMwjZxoo	0.00	31.80	37.30	30.90	0.00	0.00	0.00	69.10	30.90	t	2026-09-13 08:12:31.899566
BMh9Xq36RrA	0.00	44.30	42.10	13.70	0.00	0.00	0.00	86.40	13.60	t	2026-09-13 08:22:34.508287
\.


--
-- Data for Name: audience_device; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.audience_device (video_id, mobile_pct, desktop_pct, tv_pct, tablet_pct, mobile_views, desktop_views, tv_views, tablet_views, desktop_intent_proxy, fetched_at) FROM stdin;
3LCJCKfRATo	88.10	16.60	1.30	5.50	366	80	6	27	16.60	2026-09-03 21:16:47.035489
mK2nGGZFRVI	87.90	9.10	0.00	2.60	147	17	0	4	0.00	2026-09-11 10:53:51.650803
sHwtsGShqjE	86.50	6.30	3.00	4.20	429	31	15	21	6.30	2026-09-03 10:11:18.411369
Wyt0zC-zadM	92.70	0.90	0.70	5.70	129	1	1	8	0.90	2026-09-03 12:28:17.67752
W1nCo6y71R8	94.50	4.00	0.80	0.70	0	0	0	0	0.00	2026-09-11 16:35:53.569939
w2UTdzsuads	94.50	4.00	0.80	0.70	0	0	0	0	0.00	2026-09-11 16:35:54.958145
JRrvbkvRyiI	91.00	5.20	0.70	3.10	416	24	3	14	5.20	2026-09-03 12:45:38.189925
pTiZBob0vWA	81.40	9.10	0.60	8.80	383	43	3	42	9.10	2026-09-03 13:23:31.162254
F6g5hMAUH6A	92.40	4.60	0.00	2.70	176	9	0	5	4.60	2026-09-03 13:36:14.415812
UTeogxHwnPw	93.80	0.50	0.80	4.40	75	0	1	3	0.50	2026-09-02 00:00:20.756231
zdOSsbqouKE	92.40	6.80	0.40	0.40	76	6	0	0	6.80	2026-09-02 00:11:35.176582
12BKLbv0Eso	76.30	17.60	0.10	6.00	1305	301	2	103	17.60	2026-09-02 08:57:44.373087
XM1AzgVMeqk	89.20	6.90	0.10	3.80	431	33	0	18	6.90	2026-09-02 09:02:32.054168
nJNR60Ms1BE	87.30	7.50	0.00	5.30	84	7	0	5	7.50	2026-09-02 09:07:53.238004
_A5Idj7SddI	92.90	2.80	0.00	4.30	25	1	0	1	2.80	2026-09-02 09:12:13.902042
BJ5lJob_sDU	83.20	14.70	2.10	0.00	26	5	1	0	14.70	2026-09-02 09:20:33.221739
durkT5BI9-0	87.50	4.10	3.30	5.10	233	11	9	13	4.10	2026-09-03 14:13:12.403346
-ntsqYRrjic	85.00	8.90	0.50	5.60	668	70	4	44	8.90	2026-09-03 14:22:21.576395
kQlrFbAzvro	81.90	12.50	0.10	5.50	3007	459	4	202	12.50	2026-09-03 14:34:36.771304
VkXC2gAxVvs	91.70	4.00	0.00	4.30	372	16	0	18	4.00	2026-09-03 21:29:21.003798
5goNjmztwqg	82.30	17.70	0.00	0.00	35	8	0	0	0.00	2026-09-02 09:40:57.778366
0jstRcQmAro	80.30	15.50	0.00	4.30	24	5	0	1	15.50	2026-09-01 08:45:25.36398
QC45KrzAuLs	92.30	4.40	0.40	2.90	476	23	2	15	4.40	2026-09-03 21:44:00.314367
gNgwb1lmKL8	90.40	4.20	1.10	4.30	888	41	11	42	4.20	2026-09-03 22:06:49.206096
XlOAFuUr7F4	88.30	5.90	0.90	5.00	426	28	4	24	5.90	2026-09-03 22:31:30.815574
d-p-YuOjU-8	91.40	3.40	0.60	4.50	275	10	2	14	3.40	2026-09-03 22:47:40.537674
XWFbqR_9fqc	71.10	28.90	0.00	0.00	11	5	0	0	28.90	2026-09-01 09:19:49.888536
Pwp0zPAY6Y4	76.40	20.60	0.00	3.00	18	5	0	0	20.60	2026-09-01 09:29:40.491408
s_PoEssiuPo	87.50	12.50	0.00	0.00	30	4	0	0	12.50	2026-09-01 09:42:27.379694
7L-wWpll_GU	82.70	5.70	1.10	10.60	81	6	1	10	5.70	2026-09-03 22:59:23.098487
OkWbChCIb04	95.30	4.00	0.00	0.80	47	2	0	0	4.00	2026-09-02 10:13:50.522983
2jcdStwq2yY	42.60	49.50	0.00	7.80	31	36	0	6	49.50	2026-09-02 10:20:48.373197
yDKB-xCaMB8	91.90	8.10	0.00	0.00	40	3	0	0	0.00	2026-09-02 14:30:31.576863
rg5iPj-249o	90.20	2.80	0.30	6.80	82	3	0	6	0.00	2026-09-02 14:58:55.032747
waW201cvfl8	89.60	5.10	0.90	4.40	94	5	1	5	0.00	2026-09-02 15:14:09.210888
Ay9K30yrg8Y	92.30	5.40	0.30	2.00	405	24	1	9	0.00	2026-09-02 15:27:50.633383
lmbndk-Db-Q	87.80	6.40	0.00	5.90	129	9	0	9	0.00	2026-09-02 21:49:28.223132
cSapjDf5CHY	84.70	10.10	0.80	3.90	335	40	3	15	0.00	2026-09-02 23:46:30.338612
JmSdjrAxNFM	76.50	14.80	4.50	4.30	93	18	5	5	14.80	2026-09-03 08:43:48.484092
MpQ-K2D9Ao4	87.20	7.30	0.20	5.40	470	39	1	29	7.30	2026-09-03 08:46:53.14088
bXetyvX2Mu8	92.40	3.00	0.10	4.50	365	12	0	18	3.00	2026-09-03 08:49:33.548839
pHfj5VVN0Ew	94.00	4.60	0.60	0.60	291	14	2	2	4.60	2026-09-03 08:52:31.076945
dpTHfuBYClo	73.90	22.70	0.60	2.90	372	114	3	15	22.70	2026-09-03 08:54:48.143719
pszcrf0uTbQ	85.30	10.30	0.10	4.20	6032	728	7	297	10.30	2026-09-03 23:21:10.33918
EDNdXwv7W64	88.40	6.70	0.20	4.70	1112	84	3	59	6.70	2026-09-04 09:55:24.289926
DdMa3y_sImk	93.90	2.90	0.00	3.30	303	9	0	11	2.90	2026-09-04 12:02:37.004788
YFnY2guPlxg	90.70	5.20	0.60	3.50	405	23	3	16	5.20	2026-09-04 12:04:52.149361
noF6FnkgYmE	85.50	8.30	2.30	3.90	87	8	2	4	8.30	2026-09-04 12:16:10.255319
tyxuLrd-xo4	81.20	2.10	10.50	6.20	188	5	24	14	2.10	2026-09-04 12:33:43.388322
UzWyYR6WM6U	90.70	3.50	2.30	3.50	369	14	9	14	3.50	2026-09-04 12:56:32.962168
3gSWKoBeqnw	90.00	3.50	2.50	4.00	305	12	8	14	3.50	2026-09-04 13:19:16.949153
impBBFcUinY	90.00	3.50	2.50	4.00	432	17	12	19	3.50	2026-09-04 13:33:07.646614
kIrFARfeW5o	90.00	3.50	2.50	4.00	468	18	13	21	3.50	2026-09-04 13:45:31.604043
FwuhJ23l7R4	85.80	10.40	0.80	3.00	274	33	3	9	10.40	2026-09-04 15:17:53.707086
tO8vEcWUFXs	95.90	0.30	2.60	1.20	189	1	5	2	0.30	2026-09-05 19:35:09.745882
m1qgKExs2BY	74.90	15.30	0.00	9.80	192	39	0	25	15.30	2026-09-05 19:53:35.380044
_vTmJ79_4ho	87.50	8.40	0.70	3.50	80	8	1	3	8.40	2026-09-05 20:12:48.727333
atkvEdcPidM	86.70	8.00	1.30	3.60	179	17	3	7	0.00	2026-09-06 08:41:17.107595
dudb29Xqo60	95.00	4.00	0.50	0.50	664	28	3	3	0.00	2026-09-06 08:53:13.551357
9jXcNZyYza8	93.20	3.20	2.00	1.60	67	2	1	1	3.20	2026-09-06 09:14:07.3586
eC_j1wlFJBw	94.70	0.00	0.00	5.30	27	0	0	2	0.00	2026-09-06 09:30:05.833783
Q-IS9K8g294	95.00	4.00	0.50	0.50	230	10	1	1	0.00	2026-09-06 09:52:18.827983
p03EyeJlM-k	78.30	18.20	0.40	3.10	129	30	1	5	0.00	2026-09-06 12:19:14.187832
229XDzxoc4g	85.30	5.60	4.50	4.50	283	19	15	15	0.00	2026-09-06 13:26:52.660817
j4CtPMW-1Q4	86.90	7.30	1.90	3.90	107	9	2	5	0.00	2026-09-06 13:43:57.675416
iLZVyccaTJs	93.50	3.30	0.30	3.00	286	10	1	9	0.00	2026-09-06 13:51:03.028232
xBun0zPGZDA	91.90	2.50	1.70	3.70	465	12	8	18	0.00	2026-09-06 15:05:42.270667
A2U9omXQ2go	87.90	9.10	0.00	2.60	147	17	0	4	0.00	2026-09-11 12:57:35.796334
4B4aAW76GLQ	93.50	3.40	0.60	2.50	386	14	2	11	3.40	2026-09-07 09:04:23.739817
LQ7ttolwjJQ	98.00	1.00	0.50	0.50	68	1	0	0	1.00	2026-09-07 10:50:43.305672
zqqcLDVZxR8	91.50	3.70	1.70	3.20	296	12	5	11	3.70	2026-09-07 10:57:07.066385
YaAKtkecoRc	94.50	4.20	0.80	0.50	384	17	3	2	0.00	2026-09-08 10:48:39.159712
Mp1WHa-CXfw	72.50	19.00	2.40	4.60	52	14	2	3	0.00	2026-09-09 14:55:59.402702
pl90QEsoKFk	94.00	3.20	0.40	2.50	468	16	2	12	0.00	2026-09-10 23:08:11.068235
D4KiNRb7UTk	68.50	30.00	0.50	1.00	382	133	4	7	0.80	2026-09-09 16:51:44.575471
yBnFHlmgMFQ	88.10	5.30	3.40	3.20	503	30	19	18	0.00	2026-09-09 23:48:51.46802
fsSkI-1Opvk	94.50	4.00	0.80	0.70	0	0	0	0	0.00	2026-09-11 16:20:32.995425
bLwR73Y2d0w	91.40	4.60	0.80	3.10	\N	\N	\N	\N	0.00	2026-09-10 10:04:13.605465
pbU_sJKSfrg	94.50	4.00	0.80	0.70	0	0	0	0	0.00	2026-09-11 16:20:34.478996
Pnh6g6K9y8Q	88.10	5.30	3.40	3.20	376	23	14	14	0.00	2026-09-10 17:21:45.289572
DNIHqPqY3VM	85.90	4.90	3.40	5.80	375	21	15	25	0.00	2026-09-10 18:30:27.604051
xj4emmUcJGE	94.50	4.00	0.80	0.70	0	0	0	0	0.00	2026-09-11 16:35:54.654653
Mkx7Qp8nCys	74.90	23.10	1.30	0.70	54	17	1	0	0.00	2026-09-10 18:43:32.427695
SOKrC7BJ418	94.50	4.00	0.80	0.70	0	0	0	0	0.00	2026-09-11 16:35:55.319378
PaYUzmc11E8	94.50	4.00	0.80	0.70	0	0	0	0	0.00	2026-09-11 16:35:55.65266
a6DGQWZ57EE	83.10	11.20	0.20	5.50	161	22	0	11	0.00	2026-09-10 19:31:27.388867
0KAZqj8-gFo	94.50	4.00	0.80	0.70	0	0	0	0	0.00	2026-09-11 16:35:55.987093
_6qJfWvvWJo	88.10	5.30	3.40	3.20	384	23	15	14	0.00	2026-09-10 19:56:28.467634
NVbNJeWZ1Lo	88.10	5.30	3.40	3.20	503	30	19	18	0.00	2026-09-10 20:21:07.431547
j7xmoRH2rzo	95.60	1.70	1.60	1.00	2035	36	34	21	1.70	2026-09-13 08:04:48.235092
muLRYXpkVWA	89.80	5.90	1.60	2.70	2345	154	42	70	5.90	2026-09-13 08:06:19.001339
_gF2JDP64Yc	82.20	7.10	4.50	6.10	478	41	26	35	7.10	2026-09-13 08:06:26.943876
5v6ouzwDdRQ	79.50	5.10	13.30	2.10	483	31	81	13	5.10	2026-09-13 08:07:14.421856
4yAeMwjZxoo	76.60	13.80	6.40	3.00	352	63	29	14	13.80	2026-09-13 08:12:31.899566
SS61lwI_i5Q	83.10	13.90	0.00	3.00	156	26	0	6	13.90	2026-09-13 08:20:20.943281
BMh9Xq36RrA	81.60	11.10	4.70	2.10	902	123	52	23	11.10	2026-09-13 08:22:34.508287
wnp9gFm7ZpY	0.00	8.70	2.00	3.70	111	11	2	5	0.00	2026-09-10 22:48:19.000993
rrTB_XW3pWA	79.60	12.80	0.50	7.10	50	8	0	4	12.80	2026-09-12 23:25:09.52654
kbLQ0kJ7pYQ	86.20	10.10	0.00	3.70	49	6	0	2	10.10	2026-09-13 00:04:05.182697
AwJoDsJiAoQ	95.00	5.00	0.00	0.00	45	2	0	0	5.00	2026-09-13 00:30:05.383779
ZrY0tM9yPxQ	92.40	4.10	0.10	3.40	336	15	0	12	4.10	2026-09-13 00:39:03.743153
hiP5k2gClN0	84.10	12.10	0.50	2.90	600	86	4	21	12.10	2026-09-13 00:39:10.017376
DrhZsdeBj6k	85.80	11.10	0.00	3.00	25843	3343	0	904	11.10	2026-09-13 00:39:55.370257
3JdwNxhgqN8	87.30	8.80	1.40	2.20	1164	117	19	29	8.80	2026-09-13 00:48:04.423667
QnjyscmnjEQ	93.20	4.40	0.50	1.90	655	31	4	13	4.40	2026-09-13 01:04:42.898173
\.


--
-- Data for Name: audience_gender; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.audience_gender (video_id, male_pct, female_pct, unknown_pct, has_data, fetched_at) FROM stdin;
wnp9gFm7ZpY	0.00	40.00	0.00	t	2026-09-10 22:48:19.000993
sHwtsGShqjE	74.40	25.60	0.00	t	2026-09-03 10:11:18.411369
Wyt0zC-zadM	100.00	0.00	0.00	t	2026-09-03 12:28:17.67752
JRrvbkvRyiI	80.20	19.80	0.00	t	2026-09-03 12:45:38.189925
pTiZBob0vWA	86.30	13.70	0.00	t	2026-09-03 13:23:31.162254
F6g5hMAUH6A	82.60	17.40	0.00	t	2026-09-03 13:36:14.415812
durkT5BI9-0	100.00	0.00	0.00	t	2026-09-03 14:13:12.403346
-ntsqYRrjic	84.30	15.70	0.00	t	2026-09-03 14:22:21.576395
kQlrFbAzvro	70.40	29.60	0.00	t	2026-09-03 14:34:36.771304
VkXC2gAxVvs	83.30	16.70	0.00	t	2026-09-03 21:29:21.003798
QC45KrzAuLs	87.00	13.00	0.00	t	2026-09-03 21:44:00.314367
gNgwb1lmKL8	88.20	11.80	0.00	t	2026-09-03 22:06:49.206096
XlOAFuUr7F4	83.70	16.40	0.00	t	2026-09-03 22:31:30.815574
d-p-YuOjU-8	100.00	0.00	0.00	t	2026-09-03 22:47:40.537674
7L-wWpll_GU	0.00	0.00	100.00	f	2026-09-03 22:59:23.098487
pszcrf0uTbQ	82.10	17.90	0.00	t	2026-09-03 23:21:10.33918
EDNdXwv7W64	75.60	24.40	0.00	t	2026-09-04 09:55:24.289926
DdMa3y_sImk	75.60	24.40	0.00	t	2026-09-04 12:02:37.004788
12BKLbv0Eso	77.70	22.30	0.00	t	2026-09-02 08:57:44.373087
XM1AzgVMeqk	82.50	17.50	0.00	t	2026-09-02 09:02:32.054168
YFnY2guPlxg	61.60	38.40	0.00	t	2026-09-04 12:04:52.149361
noF6FnkgYmE	0.00	0.00	100.00	f	2026-09-04 12:16:10.255319
tyxuLrd-xo4	56.80	43.30	0.00	t	2026-09-04 12:33:43.388322
UzWyYR6WM6U	60.40	39.60	0.00	t	2026-09-04 12:56:32.962168
3gSWKoBeqnw	0.00	0.00	100.00	f	2026-09-04 13:19:16.949153
impBBFcUinY	0.00	0.00	100.00	f	2026-09-04 13:33:07.646614
kIrFARfeW5o	0.00	0.00	100.00	f	2026-09-04 13:45:31.604043
FwuhJ23l7R4	0.00	0.00	100.00	f	2026-09-04 15:17:53.707086
tO8vEcWUFXs	82.00	18.00	0.00	t	2026-09-05 19:35:09.745882
m1qgKExs2BY	92.00	8.00	0.00	t	2026-09-05 19:53:35.380044
_vTmJ79_4ho	62.50	37.50	0.00	t	2026-09-05 20:12:48.727333
rrTB_XW3pWA	0.00	0.00	0.00	f	2026-09-12 23:25:09.52654
XWFbqR_9fqc	0.00	0.00	100.00	f	2026-09-01 09:19:49.888536
Pwp0zPAY6Y4	0.00	0.00	100.00	f	2026-09-01 09:29:40.491408
s_PoEssiuPo	0.00	0.00	100.00	f	2026-09-01 09:42:27.379694
kbLQ0kJ7pYQ	0.00	0.00	0.00	f	2026-09-13 00:04:05.182697
AwJoDsJiAoQ	0.00	0.00	0.00	f	2026-09-13 00:30:05.383779
Ay9K30yrg8Y	92.70	7.30	0.00	t	2026-09-02 15:27:50.633383
lmbndk-Db-Q	100.00	0.00	0.00	t	2026-09-02 21:49:28.223132
cSapjDf5CHY	87.50	12.50	0.00	t	2026-09-02 23:46:30.338612
JmSdjrAxNFM	75.60	24.40	0.00	t	2026-09-03 08:43:48.484092
MpQ-K2D9Ao4	83.70	16.40	0.00	t	2026-09-03 08:46:53.14088
bXetyvX2Mu8	80.30	19.70	0.00	t	2026-09-03 08:49:33.548839
pHfj5VVN0Ew	86.90	13.10	0.00	t	2026-09-03 08:52:31.076945
dpTHfuBYClo	82.00	18.10	0.00	t	2026-09-03 08:54:48.143719
UTeogxHwnPw	0.00	0.00	100.00	f	2026-09-02 00:00:20.756231
zdOSsbqouKE	0.00	0.00	100.00	f	2026-09-02 00:11:35.176582
nJNR60Ms1BE	0.00	0.00	100.00	f	2026-09-02 09:07:53.238004
_A5Idj7SddI	0.00	0.00	100.00	f	2026-09-02 09:12:13.902042
BJ5lJob_sDU	0.00	0.00	100.00	f	2026-09-02 09:20:33.221739
5goNjmztwqg	0.00	0.00	100.00	f	2026-09-02 09:40:57.778366
0jstRcQmAro	0.00	0.00	100.00	f	2026-09-01 08:45:25.36398
OkWbChCIb04	0.00	0.00	100.00	f	2026-09-02 10:13:50.522983
2jcdStwq2yY	0.00	0.00	100.00	f	2026-09-02 10:20:48.373197
yDKB-xCaMB8	0.00	0.00	100.00	f	2026-09-02 14:30:31.576863
rg5iPj-249o	0.00	0.00	100.00	f	2026-09-02 14:58:55.032747
waW201cvfl8	0.00	0.00	100.00	f	2026-09-02 15:14:09.210888
ZrY0tM9yPxQ	52.80	47.20	0.00	t	2026-09-13 00:39:03.743153
hiP5k2gClN0	75.50	24.50	0.00	t	2026-09-13 00:39:10.017376
DrhZsdeBj6k	67.10	32.90	0.00	t	2026-09-13 00:39:55.370257
3JdwNxhgqN8	72.40	27.50	0.00	t	2026-09-13 00:48:04.423667
atkvEdcPidM	55.00	45.00	0.00	f	2026-09-06 08:41:17.107595
dudb29Xqo60	55.00	45.00	0.00	f	2026-09-06 08:53:13.551357
9jXcNZyYza8	0.00	0.00	100.00	f	2026-09-06 09:14:07.3586
eC_j1wlFJBw	55.00	45.00	0.00	f	2026-09-06 09:30:05.833783
Q-IS9K8g294	55.00	45.00	0.00	f	2026-09-06 09:52:18.827983
p03EyeJlM-k	55.00	45.00	0.00	f	2026-09-06 12:19:14.187832
229XDzxoc4g	90.50	9.50	0.00	t	2026-09-06 13:26:52.660817
j4CtPMW-1Q4	0.00	0.00	0.00	f	2026-09-06 13:43:57.675416
QnjyscmnjEQ	71.40	28.60	0.00	t	2026-09-13 01:04:42.898173
iLZVyccaTJs	100.00	0.00	0.00	t	2026-09-06 13:51:03.028232
xBun0zPGZDA	61.10	38.90	0.00	t	2026-09-06 15:05:42.270667
j7xmoRH2rzo	47.50	52.50	0.00	t	2026-09-13 08:04:48.235092
muLRYXpkVWA	89.60	10.40	0.00	t	2026-09-13 08:06:19.001339
_gF2JDP64Yc	73.40	26.60	0.00	t	2026-09-13 08:06:26.943876
5v6ouzwDdRQ	100.00	0.00	0.00	t	2026-09-13 08:07:14.421856
4B4aAW76GLQ	89.10	11.00	0.00	t	2026-09-07 09:04:23.739817
4yAeMwjZxoo	78.20	21.80	0.00	t	2026-09-13 08:12:31.899566
BMh9Xq36RrA	92.90	7.10	0.00	t	2026-09-13 08:22:34.508287
LQ7ttolwjJQ	0.00	0.00	100.00	f	2026-09-07 10:50:43.305672
zqqcLDVZxR8	92.30	7.70	0.00	t	2026-09-07 10:57:07.066385
YaAKtkecoRc	65.00	35.00	0.00	t	2026-09-08 10:48:39.159712
A2U9omXQ2go	60.00	40.00	0.00	t	2026-09-11 12:57:35.796334
Mp1WHa-CXfw	55.00	45.00	0.00	t	2026-09-09 14:55:59.402702
D4KiNRb7UTk	52.30	45.70	2.00	t	2026-09-09 16:51:44.575471
yBnFHlmgMFQ	64.10	35.90	0.00	t	2026-09-09 23:48:51.46802
bLwR73Y2d0w	55.40	44.60	0.00	t	2026-09-10 10:04:13.605465
Pnh6g6K9y8Q	88.10	11.90	0.00	t	2026-09-10 17:21:45.289572
DNIHqPqY3VM	75.50	24.50	0.00	t	2026-09-10 18:30:27.604051
Mkx7Qp8nCys	64.10	35.90	0.00	t	2026-09-10 18:43:32.427695
a6DGQWZ57EE	64.10	35.90	0.00	t	2026-09-10 19:31:27.388867
_6qJfWvvWJo	64.10	35.90	0.00	t	2026-09-10 19:56:28.467634
NVbNJeWZ1Lo	64.10	35.90	0.00	t	2026-09-10 20:21:07.431547
pl90QEsoKFk	90.50	9.50	0.00	t	2026-09-10 23:08:11.068235
3LCJCKfRATo	64.10	21.10	0.00	t	2026-09-03 21:16:47.035489
mK2nGGZFRVI	60.00	40.00	0.00	t	2026-09-11 10:53:51.650803
fsSkI-1Opvk	65.00	35.00	0.00	t	2026-09-11 16:20:32.995425
pbU_sJKSfrg	65.00	35.00	0.00	t	2026-09-11 16:20:34.478996
W1nCo6y71R8	65.00	35.00	0.00	t	2026-09-11 16:35:53.569939
xj4emmUcJGE	65.00	35.00	0.00	t	2026-09-11 16:35:54.654653
w2UTdzsuads	65.00	35.00	0.00	t	2026-09-11 16:35:54.958145
SOKrC7BJ418	65.00	35.00	0.00	t	2026-09-11 16:35:55.319378
PaYUzmc11E8	65.00	35.00	0.00	t	2026-09-11 16:35:55.65266
0KAZqj8-gFo	65.00	35.00	0.00	t	2026-09-11 16:35:55.987093
\.


--
-- Data for Name: audience_geography; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.audience_geography (id, video_id, country_code, country_name, views, percentage, avg_view_duration_seconds, is_target_country, fetched_at) FROM stdin;
74	yDKB-xCaMB8	IN	India	26	60.50	16.00	t	2026-09-02 14:30:31.576863
75	rg5iPj-249o	IN	India	55	60.40	25.00	t	2026-09-02 14:58:55.032747
76	waW201cvfl8	IN	India	59	56.20	15.00	t	2026-09-02 15:14:09.210888
77	Ay9K30yrg8Y	IN	India	358	81.60	10.00	t	2026-09-02 15:27:50.633383
78	Ay9K30yrg8Y	US	United States	11	2.50	10.00	f	2026-09-02 15:27:50.633383
79	Ay9K30yrg8Y	BD	Bangladesh	0	0.00	10.00	f	2026-09-02 15:27:50.633383
80	lmbndk-Db-Q	IN	India	132	89.80	13.00	t	2026-09-02 21:49:28.223132
81	cSapjDf5CHY	IN	India	326	82.50	13.00	t	2026-09-02 23:46:30.338612
82	JmSdjrAxNFM	IN	India	103	84.40	11.00	t	2026-09-03 08:43:48.484092
83	JmSdjrAxNFM	OTHER	Other Countries	19	15.60	11.00	f	2026-09-03 08:43:48.484092
84	MpQ-K2D9Ao4	IN	India	432	80.20	16.00	t	2026-09-03 08:46:53.14088
85	MpQ-K2D9Ao4	OTHER	Other Countries	107	19.80	16.00	f	2026-09-03 08:46:53.14088
86	bXetyvX2Mu8	IN	India	326	82.50	16.00	t	2026-09-03 08:49:33.548839
87	bXetyvX2Mu8	OTHER	Other Countries	69	17.50	16.00	f	2026-09-03 08:49:33.548839
88	pHfj5VVN0Ew	IN	India	285	91.90	17.00	t	2026-09-03 08:52:31.076945
89	pHfj5VVN0Ew	OTHER	Other Countries	25	8.10	17.00	f	2026-09-03 08:52:31.076945
90	dpTHfuBYClo	IN	India	456	90.50	18.00	t	2026-09-03 08:54:48.143719
91	dpTHfuBYClo	OTHER	Other Countries	48	9.50	18.00	f	2026-09-03 08:54:48.143719
92	s_PoEssiuPo	OTHER	Other Countries	0	61.80	0.00	f	2026-09-03 09:22:54.381413
93	5goNjmztwqg	OTHER	Other Countries	0	72.10	0.00	f	2026-09-03 09:22:54.381413
94	waW201cvfl8	OTHER	Other Countries	0	43.80	0.00	f	2026-09-03 09:22:54.381413
95	rg5iPj-249o	OTHER	Other Countries	0	39.60	0.00	f	2026-09-03 09:22:54.381413
96	lmbndk-Db-Q	OTHER	Other Countries	0	10.20	0.00	f	2026-09-03 09:22:54.381413
98	Pwp0zPAY6Y4	OTHER	Other Countries	0	100.00	0.00	f	2026-09-03 09:22:54.381413
99	0jstRcQmAro	OTHER	Other Countries	0	100.00	0.00	f	2026-09-03 09:22:54.381413
100	XWFbqR_9fqc	OTHER	Other Countries	0	100.00	0.00	f	2026-09-03 09:22:54.381413
101	yDKB-xCaMB8	OTHER	Other Countries	0	39.50	0.00	f	2026-09-03 09:22:54.381413
102	cSapjDf5CHY	OTHER	Other Countries	0	17.50	0.00	f	2026-09-03 09:22:54.381413
97	Ay9K30yrg8Y	OTHER	Other Countries	0	15.90	0.00	f	2026-09-03 09:22:54.381413
332	yBnFHlmgMFQ	IN	India	516	90.40	16.00	t	2026-09-09 23:48:51.46802
593	wnp9gFm7ZpY	IN	India	0	59.20	\N	t	2026-09-12 21:46:22.459929
603	DrhZsdeBj6k	IN	India	28825	95.70	\N	t	2026-09-13 00:39:55.370257
107	sHwtsGShqjE	IN	India	452	91.10	13.00	t	2026-09-03 10:11:18.411369
108	sHwtsGShqjE	OTHER	Other Countries	44	8.90	10.00	f	2026-09-03 10:11:18.411369
109	Wyt0zC-zadM	IN	India	77	55.40	\N	t	2026-09-03 12:28:17.67752
38	UTeogxHwnPw	IN	India	61	76.30	17.00	t	2026-09-02 09:25:42.138615
39	UTeogxHwnPw	OTHER	Other Countries	19	23.70	17.00	f	2026-09-02 09:25:42.138615
40	zdOSsbqouKE	IN	India	57	69.50	14.00	t	2026-09-02 09:25:43.634893
41	zdOSsbqouKE	OTHER	Other Countries	25	30.50	14.00	f	2026-09-02 09:25:43.634893
42	12BKLbv0Eso	IN	India	1548	90.50	28.00	t	2026-09-02 09:25:45.151529
43	12BKLbv0Eso	OTHER	Other Countries	163	9.50	28.00	f	2026-09-02 09:25:45.151529
44	XM1AzgVMeqk	IN	India	364	75.40	24.00	t	2026-09-02 09:25:46.312192
45	XM1AzgVMeqk	OTHER	Other Countries	119	24.60	24.00	f	2026-09-02 09:25:46.312192
46	nJNR60Ms1BE	IN	India	54	56.30	24.00	t	2026-09-02 09:25:47.152763
47	nJNR60Ms1BE	OTHER	Other Countries	42	43.80	24.00	f	2026-09-02 09:25:47.152763
110	JRrvbkvRyiI	IN	India	421	92.10	\N	t	2026-09-03 12:45:38.189925
111	pTiZBob0vWA	IN	India	451	95.80	\N	t	2026-09-03 13:23:31.162254
112	F6g5hMAUH6A	IN	India	179	93.70	\N	t	2026-09-03 13:36:14.415812
113	durkT5BI9-0	IN	India	245	92.10	\N	t	2026-09-03 14:13:12.403346
114	-ntsqYRrjic	IN	India	708	90.10	\N	t	2026-09-03 14:22:21.576395
53	5goNjmztwqg	IN	India	12	27.90	\N	t	2026-09-02 09:45:39.987643
54	0jstRcQmAro	IN	India	0	0.00	\N	t	2026-09-02 09:46:02.751285
115	kQlrFbAzvro	IN	India	3260	88.80	\N	t	2026-09-03 14:34:36.771304
117	VkXC2gAxVvs	IN	India	387	95.30	\N	t	2026-09-03 21:29:21.003798
118	QC45KrzAuLs	IN	India	473	91.70	\N	t	2026-09-03 21:44:00.314367
59	XWFbqR_9fqc	IN	India	0	0.00	27.00	t	2026-09-02 10:02:53.957789
60	Pwp0zPAY6Y4	IN	India	0	0.00	20.00	t	2026-09-02 10:03:13.106027
61	s_PoEssiuPo	IN	India	13	38.20	20.00	t	2026-09-02 10:03:18.329293
119	gNgwb1lmKL8	IN	India	914	93.10	\N	t	2026-09-03 22:06:49.206096
120	XlOAFuUr7F4	IN	India	413	85.70	\N	t	2026-09-03 22:31:30.815574
121	d-p-YuOjU-8	IN	India	200	66.50	\N	t	2026-09-03 22:47:40.537674
122	7L-wWpll_GU	IN	India	48	49.00	\N	t	2026-09-03 22:59:23.098487
124	pszcrf0uTbQ	IN	India	6576	93.00	\N	t	2026-09-04 09:31:55.178282
68	OkWbChCIb04	IN	India	35	71.40	16.00	t	2026-09-02 10:43:00.55935
69	OkWbChCIb04	OTHER	Other Countries	14	28.60	16.00	f	2026-09-02 10:43:00.55935
125	EDNdXwv7W64	IN	India	1118	88.90	\N	t	2026-09-04 09:55:24.289926
126	DdMa3y_sImk	IN	India	280	86.70	\N	t	2026-09-04 12:02:37.004788
72	2jcdStwq2yY	IN	India	55	71.40	22.00	t	2026-09-02 11:22:03.546173
73	2jcdStwq2yY	OTHER	Other Countries	22	28.60	22.00	f	2026-09-02 11:22:03.546173
127	YFnY2guPlxg	IN	India	437	97.80	\N	t	2026-09-04 12:04:52.149361
128	noF6FnkgYmE	IN	India	66	64.70	\N	t	2026-09-04 12:16:10.255319
129	tyxuLrd-xo4	IN	India	222	95.70	\N	t	2026-09-04 12:33:43.388322
130	UzWyYR6WM6U	IN	India	394	96.80	\N	t	2026-09-04 12:56:32.962168
131	3gSWKoBeqnw	IN	India	339	100.00	\N	t	2026-09-04 13:19:16.949153
132	impBBFcUinY	IN	India	480	100.00	\N	t	2026-09-04 13:33:07.646614
134	kIrFARfeW5o	IN	India	520	100.00	\N	t	2026-09-04 13:52:08.871339
135	FwuhJ23l7R4	IN	India	12	3.80	\N	t	2026-09-04 15:17:53.707086
137	tO8vEcWUFXs	IN	India	173	87.80	12.00	t	2026-09-05 19:35:09.745882
138	tO8vEcWUFXs	OTHER	Other Countries	24	12.20	12.00	f	2026-09-05 19:35:09.745882
139	m1qgKExs2BY	IN	India	240	93.80	16.00	t	2026-09-05 19:53:35.380044
140	m1qgKExs2BY	OTHER	Other Countries	16	6.20	16.00	f	2026-09-05 19:53:35.380044
141	_vTmJ79_4ho	IN	India	68	73.90	10.00	t	2026-09-05 20:12:48.727333
142	_vTmJ79_4ho	OTHER	Other Countries	24	26.10	10.00	f	2026-09-05 20:12:48.727333
608	QnjyscmnjEQ	IN	India	494	70.30	\N	t	2026-09-13 01:04:42.898173
339	bLwR73Y2d0w	IN	India	956	96.30	0.00	t	2026-09-10 10:04:13.605465
342	Pnh6g6K9y8Q	IN	India	385	90.20	14.00	t	2026-09-10 17:22:57.565114
638	muLRYXpkVWA	IN	India	2201	84.30	\N	t	2026-09-13 08:06:19.001339
345	DNIHqPqY3VM	IN	India	415	95.00	10.00	t	2026-09-10 18:32:28.286194
644	SS61lwI_i5Q	IN	India	76	40.40	\N	t	2026-09-13 08:20:20.943281
348	Mkx7Qp8nCys	IN	India	53	91.20	17.00	t	2026-09-10 18:44:13.592751
249	4B4aAW76GLQ	IN	India	381	92.30	11.50	t	2026-09-07 09:04:23.739817
250	4B4aAW76GLQ	US	United States	8	1.90	8.00	f	2026-09-07 09:04:23.739817
251	4B4aAW76GLQ	PK	Pakistan	5	1.20	6.00	f	2026-09-07 09:04:23.739817
252	4B4aAW76GLQ	BD	Bangladesh	4	1.00	5.00	f	2026-09-07 09:04:23.739817
253	4B4aAW76GLQ	OTHER	Other	15	3.60	7.00	f	2026-09-07 09:04:23.739817
352	a6DGQWZ57EE	IN	India	174	90.40	29.00	t	2026-09-10 19:33:03.635723
258	LQ7ttolwjJQ	IN	India	69	100.00	12.00	t	2026-09-07 10:50:43.305672
259	zqqcLDVZxR8	IN	India	301	92.90	10.00	t	2026-09-07 10:57:07.066385
260	zqqcLDVZxR8	OTHER	Other	23	7.10	8.00	f	2026-09-07 10:57:07.066385
356	_6qJfWvvWJo	IN	India	416	95.60	16.00	t	2026-09-10 20:01:40.055997
358	NVbNJeWZ1Lo	IN	India	516	90.40	23.00	t	2026-09-10 20:21:07.431547
363	pl90QEsoKFk	IN	India	455	91.40	14.00	t	2026-09-10 23:10:00.515414
271	YaAKtkecoRc	IN	India	380	93.60	12.00	t	2026-09-08 11:27:20.802552
272	YaAKtkecoRc	US	United States	10	2.50	11.00	f	2026-09-08 11:27:20.802552
273	YaAKtkecoRc	PK	Pakistan	8	2.00	10.00	f	2026-09-08 11:27:20.802552
274	YaAKtkecoRc	BD	Bangladesh	4	1.00	9.00	f	2026-09-08 11:27:20.802552
275	YaAKtkecoRc	NP	Nepal	4	1.00	9.00	f	2026-09-08 11:27:20.802552
364	3LCJCKfRATo	IN	India	516	90.40	16.00	t	2026-09-10 23:30:52.664773
365	mK2nGGZFRVI	IN	India	87	51.80	20.00	t	2026-09-11 10:53:51.650803
367	A2U9omXQ2go	IN	India	87	51.80	20.00	t	2026-09-11 13:05:32.12302
193	atkvEdcPidM	IN	India	147	71.00	14.00	t	2026-09-06 08:41:17.107595
194	atkvEdcPidM	US	United States	15	7.20	13.00	f	2026-09-06 08:41:17.107595
195	atkvEdcPidM	PK	Pakistan	10	4.80	12.00	f	2026-09-06 08:41:17.107595
196	atkvEdcPidM	BD	Bangladesh	8	3.90	11.00	f	2026-09-06 08:41:17.107595
197	atkvEdcPidM	LK	Sri Lanka	5	2.40	10.00	f	2026-09-06 08:41:17.107595
198	atkvEdcPidM	NP	Nepal	4	1.90	10.00	f	2026-09-06 08:41:17.107595
199	dudb29Xqo60	IN	India	650	93.00	16.00	t	2026-09-06 08:53:13.551357
200	dudb29Xqo60	US	United States	15	2.10	15.00	f	2026-09-06 08:53:13.551357
201	dudb29Xqo60	PK	Pakistan	10	1.40	14.00	f	2026-09-06 08:53:13.551357
202	dudb29Xqo60	BD	Bangladesh	8	1.10	14.00	f	2026-09-06 08:53:13.551357
203	dudb29Xqo60	AE	United Arab Emirates	5	0.70	13.00	f	2026-09-06 08:53:13.551357
204	9jXcNZyYza8	IN	India	39	54.20	14.00	t	2026-09-06 09:14:07.3586
205	9jXcNZyYza8	OTHER	Other Countries	33	45.80	14.00	f	2026-09-06 09:14:07.3586
207	eC_j1wlFJBw	IN	India	12	41.40	11.00	t	2026-09-06 09:30:05.833783
208	Q-IS9K8g294	IN	India	200	82.60	13.00	t	2026-09-06 09:52:18.827983
209	Q-IS9K8g294	US	United States	15	6.20	12.00	f	2026-09-06 09:52:18.827983
210	Q-IS9K8g294	PK	Pakistan	10	4.10	11.00	f	2026-09-06 09:52:18.827983
211	Q-IS9K8g294	BD	Bangladesh	8	3.30	10.00	f	2026-09-06 09:52:18.827983
212	Q-IS9K8g294	LK	Sri Lanka	5	2.10	10.00	f	2026-09-06 09:52:18.827983
213	Q-IS9K8g294	NP	Nepal	4	1.70	9.00	f	2026-09-06 09:52:18.827983
218	p03EyeJlM-k	IN	India	101	61.20	22.00	t	2026-09-06 12:19:14.187832
219	p03EyeJlM-k	US	United States	15	9.10	20.00	f	2026-09-06 12:19:14.187832
220	p03EyeJlM-k	PK	Pakistan	12	7.30	18.00	f	2026-09-06 12:19:14.187832
221	p03EyeJlM-k	BD	Bangladesh	8	4.80	18.00	f	2026-09-06 12:19:14.187832
222	229XDzxoc4g	IN	India	303	92.20	16.00	t	2026-09-06 13:26:52.660817
223	j4CtPMW-1Q4	IN	India	99	80.50	16.00	t	2026-09-06 13:43:57.675416
226	iLZVyccaTJs	IN	India	266	87.00	16.00	t	2026-09-06 13:51:03.028232
227	xBun0zPGZDA	IN	India	0	80.80	\N	t	2026-09-06 15:05:42.270667
291	Mp1WHa-CXfw	IN	India	37	51.40	22.00	t	2026-09-09 14:55:59.402702
292	Mp1WHa-CXfw	US	United States	7	10.00	22.00	f	2026-09-09 14:55:59.402702
293	Mp1WHa-CXfw	CA	Canada	4	5.00	22.00	f	2026-09-09 14:55:59.402702
294	Mp1WHa-CXfw	AE	UAE	2	3.00	22.00	f	2026-09-09 14:55:59.402702
295	Mp1WHa-CXfw	GB	United Kingdom	1	2.00	22.00	f	2026-09-09 14:55:59.402702
324	D4KiNRb7UTk	IN	India	382	68.00	28.50	t	2026-09-09 16:51:44.575471
325	D4KiNRb7UTk	US	United States	89	16.00	25.00	f	2026-09-09 16:51:44.575471
326	D4KiNRb7UTk	CA	Canada	23	4.00	22.00	f	2026-09-09 16:51:44.575471
327	D4KiNRb7UTk	AE	UAE	15	3.00	20.00	f	2026-09-09 16:51:44.575471
328	D4KiNRb7UTk	GB	United Kingdom	12	2.00	18.00	f	2026-09-09 16:51:44.575471
329	D4KiNRb7UTk	AU	Australia	11	2.00	15.00	f	2026-09-09 16:51:44.575471
330	D4KiNRb7UTk	SG	Singapore	9	1.00	12.00	f	2026-09-09 16:51:44.575471
600	ZrY0tM9yPxQ	IN	India	302	83.00	\N	t	2026-09-13 00:39:03.743153
605	3JdwNxhgqN8	IN	India	1001	75.10	\N	t	2026-09-13 00:48:04.423667
639	_gF2JDP64Yc	IN	India	311	53.50	\N	t	2026-09-13 08:06:26.943876
640	_gF2JDP64Yc	US	United States	13	2.20	\N	f	2026-09-13 08:06:26.943876
641	_gF2JDP64Yc	CA	Canada	1	0.00	\N	f	2026-09-13 08:06:26.943876
645	BMh9Xq36RrA	IN	India	488	44.20	\N	t	2026-09-13 08:22:34.508287
646	BMh9Xq36RrA	BD	Bangladesh	12	1.10	\N	f	2026-09-13 08:22:34.508287
647	BMh9Xq36RrA	CA	Canada	12	1.10	\N	f	2026-09-13 08:22:34.508287
648	BMh9Xq36RrA	NP	Nepal	12	1.10	\N	f	2026-09-13 08:22:34.508287
649	BMh9Xq36RrA	US	United States	12	1.10	\N	f	2026-09-13 08:22:34.508287
596	rrTB_XW3pWA	IN	India	28	44.40	\N	t	2026-09-12 23:25:09.52654
601	hiP5k2gClN0	IN	India	418	58.50	\N	t	2026-09-13 00:39:10.017376
642	5v6ouzwDdRQ	IN	India	272	44.80	\N	t	2026-09-13 08:07:14.421856
543	fsSkI-1Opvk	IN	India	0	93.50	\N	t	2026-09-11 22:58:05.388618
544	fsSkI-1Opvk	US	United States	0	2.00	\N	f	2026-09-11 22:58:05.388618
545	fsSkI-1Opvk	PK	Pakistan	0	1.50	\N	f	2026-09-11 22:58:05.388618
546	fsSkI-1Opvk	BD	Bangladesh	0	1.00	\N	f	2026-09-11 22:58:05.388618
547	fsSkI-1Opvk	NP	Nepal	0	1.00	\N	f	2026-09-11 22:58:05.388618
548	pbU_sJKSfrg	IN	India	0	93.50	\N	t	2026-09-11 22:58:06.014146
549	pbU_sJKSfrg	US	United States	0	2.00	\N	f	2026-09-11 22:58:06.014146
550	pbU_sJKSfrg	PK	Pakistan	0	1.50	\N	f	2026-09-11 22:58:06.014146
551	pbU_sJKSfrg	BD	Bangladesh	0	1.00	\N	f	2026-09-11 22:58:06.014146
552	pbU_sJKSfrg	NP	Nepal	0	1.00	\N	f	2026-09-11 22:58:06.014146
553	W1nCo6y71R8	IN	India	0	93.50	\N	t	2026-09-11 22:58:06.303119
554	W1nCo6y71R8	US	United States	0	2.00	\N	f	2026-09-11 22:58:06.303119
555	W1nCo6y71R8	PK	Pakistan	0	1.50	\N	f	2026-09-11 22:58:06.303119
556	W1nCo6y71R8	BD	Bangladesh	0	1.00	\N	f	2026-09-11 22:58:06.303119
557	W1nCo6y71R8	NP	Nepal	0	1.00	\N	f	2026-09-11 22:58:06.303119
568	xj4emmUcJGE	IN	India	0	93.50	\N	t	2026-09-11 22:58:07.287609
569	xj4emmUcJGE	US	United States	0	2.00	\N	f	2026-09-11 22:58:07.287609
570	xj4emmUcJGE	PK	Pakistan	0	1.50	\N	f	2026-09-11 22:58:07.287609
571	xj4emmUcJGE	BD	Bangladesh	0	1.00	\N	f	2026-09-11 22:58:07.287609
572	xj4emmUcJGE	NP	Nepal	0	1.00	\N	f	2026-09-11 22:58:07.287609
573	w2UTdzsuads	IN	India	0	93.50	\N	t	2026-09-11 22:58:07.599184
574	w2UTdzsuads	US	United States	0	2.00	\N	f	2026-09-11 22:58:07.599184
575	w2UTdzsuads	PK	Pakistan	0	1.50	\N	f	2026-09-11 22:58:07.599184
576	w2UTdzsuads	BD	Bangladesh	0	1.00	\N	f	2026-09-11 22:58:07.599184
577	w2UTdzsuads	NP	Nepal	0	1.00	\N	f	2026-09-11 22:58:07.599184
578	SOKrC7BJ418	IN	India	0	93.50	\N	t	2026-09-11 22:58:07.871575
579	SOKrC7BJ418	US	United States	0	2.00	\N	f	2026-09-11 22:58:07.871575
580	SOKrC7BJ418	PK	Pakistan	0	1.50	\N	f	2026-09-11 22:58:07.871575
581	SOKrC7BJ418	BD	Bangladesh	0	1.00	\N	f	2026-09-11 22:58:07.871575
582	SOKrC7BJ418	NP	Nepal	0	1.00	\N	f	2026-09-11 22:58:07.871575
583	PaYUzmc11E8	IN	India	0	93.50	\N	t	2026-09-11 22:58:08.189019
584	PaYUzmc11E8	US	United States	0	2.00	\N	f	2026-09-11 22:58:08.189019
585	PaYUzmc11E8	PK	Pakistan	0	1.50	\N	f	2026-09-11 22:58:08.189019
586	PaYUzmc11E8	BD	Bangladesh	0	1.00	\N	f	2026-09-11 22:58:08.189019
587	PaYUzmc11E8	NP	Nepal	0	1.00	\N	f	2026-09-11 22:58:08.189019
588	0KAZqj8-gFo	IN	India	0	93.50	\N	t	2026-09-11 22:58:08.519442
589	0KAZqj8-gFo	US	United States	0	2.00	\N	f	2026-09-11 22:58:08.519442
590	0KAZqj8-gFo	PK	Pakistan	0	1.50	\N	f	2026-09-11 22:58:08.519442
591	0KAZqj8-gFo	BD	Bangladesh	0	1.00	\N	f	2026-09-11 22:58:08.519442
592	0KAZqj8-gFo	NP	Nepal	0	1.00	\N	f	2026-09-11 22:58:08.519442
597	kbLQ0kJ7pYQ	IN	India	38	66.70	\N	t	2026-09-13 00:04:05.182697
633	j7xmoRH2rzo	IN	India	1665	78.20	\N	t	2026-09-13 08:04:48.235092
634	j7xmoRH2rzo	PK	Pakistan	47	2.20	\N	f	2026-09-13 08:04:48.235092
635	j7xmoRH2rzo	US	United States	36	1.70	\N	f	2026-09-13 08:04:48.235092
636	j7xmoRH2rzo	GB	United Kingdom	13	0.60	\N	f	2026-09-13 08:04:48.235092
637	j7xmoRH2rzo	BD	Bangladesh	13	0.60	\N	f	2026-09-13 08:04:48.235092
643	4yAeMwjZxoo	IN	India	188	40.90	\N	t	2026-09-13 08:12:31.899566
\.


--
-- Data for Name: audience_subscriber_status; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.audience_subscriber_status (video_id, subscribed_pct, not_subscribed_pct, subscribed_views, not_subscribed_views, sub_viewer_retention_pct, non_sub_viewer_retention_pct, fetched_at) FROM stdin;
9jXcNZyYza8	42.40	57.60	31	41	27.00	27.00	2026-09-06 09:14:07.3586
wnp9gFm7ZpY	43.20	56.80	0	0	0.00	0.00	2026-09-12 21:46:22.459929
AwJoDsJiAoQ	30.10	69.90	14	33	0.00	0.00	2026-09-13 00:30:05.383779
rrTB_XW3pWA	25.70	74.30	16	47	0.00	0.00	2026-09-12 23:25:09.52654
eC_j1wlFJBw	57.20	42.80	17	12	22.00	16.00	2026-09-06 09:30:05.833783
3JdwNxhgqN8	26.20	73.90	349	985	0.00	0.00	2026-09-13 00:48:04.423667
QnjyscmnjEQ	16.20	83.80	114	589	0.00	0.00	2026-09-13 01:04:42.898173
UTeogxHwnPw	0.00	100.00	0	80	\N	\N	2026-09-02 09:25:42.138615
zdOSsbqouKE	0.00	100.00	0	82	\N	\N	2026-09-02 09:25:43.634893
12BKLbv0Eso	0.00	100.00	0	1711	\N	\N	2026-09-02 09:25:45.151529
XM1AzgVMeqk	0.00	100.00	0	483	\N	\N	2026-09-02 09:25:46.312192
nJNR60Ms1BE	0.00	100.00	0	96	\N	\N	2026-09-02 09:25:47.152763
_A5Idj7SddI	0.00	100.00	0	27	\N	\N	2026-09-02 09:25:47.534266
BJ5lJob_sDU	0.00	100.00	0	31	\N	\N	2026-09-02 09:25:47.870198
Q-IS9K8g294	35.00	65.00	85	157	28.00	23.50	2026-09-06 09:52:18.827983
p03EyeJlM-k	17.40	82.60	29	136	30.00	25.50	2026-09-06 12:19:14.187832
229XDzxoc4g	5.50	94.50	18	314	0.00	0.00	2026-09-06 13:26:52.660817
5goNjmztwqg	69.90	30.10	30	13	\N	\N	2026-09-02 09:45:39.987643
0jstRcQmAro	69.50	30.50	21	9	\N	\N	2026-09-02 09:46:02.751285
XWFbqR_9fqc	82.30	17.70	13	3	58.30	58.30	2026-09-02 10:02:53.957789
Pwp0zPAY6Y4	71.10	28.90	16	7	57.90	57.90	2026-09-02 10:03:13.106027
s_PoEssiuPo	28.10	71.90	10	24	50.80	50.80	2026-09-02 10:03:18.329293
OkWbChCIb04	39.50	60.50	19	30	\N	\N	2026-09-02 10:43:00.55935
j4CtPMW-1Q4	16.30	83.70	20	103	25.90	25.90	2026-09-06 13:43:57.675416
2jcdStwq2yY	18.10	81.90	14	63	\N	\N	2026-09-02 11:22:03.546173
yDKB-xCaMB8	25.60	74.40	11	32	\N	\N	2026-09-02 14:30:31.576863
rg5iPj-249o	21.40	78.60	19	72	\N	\N	2026-09-02 14:58:55.032747
waW201cvfl8	23.20	76.90	24	81	\N	\N	2026-09-02 15:14:09.210888
Ay9K30yrg8Y	4.50	95.50	20	419	\N	\N	2026-09-02 15:27:50.633383
lmbndk-Db-Q	11.60	88.40	17	130	\N	\N	2026-09-02 21:49:28.223132
cSapjDf5CHY	4.90	95.10	19	376	\N	\N	2026-09-02 23:46:30.338612
JmSdjrAxNFM	15.20	84.80	19	103	\N	\N	2026-09-03 08:43:48.484092
MpQ-K2D9Ao4	5.50	94.50	30	509	\N	\N	2026-09-03 08:46:53.14088
bXetyvX2Mu8	5.90	94.10	23	372	\N	\N	2026-09-03 08:49:33.548839
pHfj5VVN0Ew	9.80	90.20	30	280	\N	\N	2026-09-03 08:52:31.076945
dpTHfuBYClo	3.80	96.20	19	485	\N	\N	2026-09-03 08:54:48.143719
j7xmoRH2rzo	0.90	99.10	19	2110	0.00	0.00	2026-09-13 08:04:48.235092
sHwtsGShqjE	6.00	94.00	30	466	\N	\N	2026-09-03 10:11:18.411369
Wyt0zC-zadM	14.90	\N	\N	\N	\N	\N	2026-09-03 12:28:17.67752
JRrvbkvRyiI	5.40	\N	\N	\N	\N	\N	2026-09-03 12:45:38.189925
pTiZBob0vWA	4.60	\N	\N	\N	\N	\N	2026-09-03 13:23:31.162254
F6g5hMAUH6A	7.70	\N	\N	\N	\N	\N	2026-09-03 13:36:14.415812
durkT5BI9-0	7.60	\N	\N	\N	\N	\N	2026-09-03 14:13:12.403346
-ntsqYRrjic	1.20	\N	\N	\N	\N	\N	2026-09-03 14:22:21.576395
kQlrFbAzvro	0.20	\N	\N	\N	\N	\N	2026-09-03 14:34:36.771304
VkXC2gAxVvs	4.30	\N	\N	\N	\N	\N	2026-09-03 21:29:21.003798
QC45KrzAuLs	2.70	\N	\N	\N	\N	\N	2026-09-03 21:44:00.314367
gNgwb1lmKL8	2.10	\N	\N	\N	\N	\N	2026-09-03 22:06:49.206096
XlOAFuUr7F4	7.80	\N	\N	\N	\N	\N	2026-09-03 22:31:30.815574
d-p-YuOjU-8	1.50	\N	\N	\N	\N	\N	2026-09-03 22:47:40.537674
7L-wWpll_GU	12.10	\N	\N	\N	\N	\N	2026-09-03 22:59:23.098487
pszcrf0uTbQ	0.30	\N	\N	\N	\N	\N	2026-09-04 09:31:55.178282
EDNdXwv7W64	1.80	\N	\N	\N	\N	\N	2026-09-04 09:55:24.289926
DdMa3y_sImk	7.40	\N	\N	\N	\N	\N	2026-09-04 12:02:37.004788
YFnY2guPlxg	4.60	\N	\N	\N	\N	\N	2026-09-04 12:04:52.149361
noF6FnkgYmE	30.40	\N	\N	\N	\N	\N	2026-09-04 12:16:10.255319
tyxuLrd-xo4	3.70	\N	\N	\N	\N	\N	2026-09-04 12:33:43.388322
UzWyYR6WM6U	1.10	\N	\N	\N	\N	\N	2026-09-04 12:56:32.962168
3gSWKoBeqnw	0.00	\N	\N	\N	\N	\N	2026-09-04 13:19:16.949153
impBBFcUinY	0.00	\N	\N	\N	\N	\N	2026-09-04 13:33:07.646614
kIrFARfeW5o	0.00	\N	\N	\N	\N	\N	2026-09-04 13:52:08.871339
FwuhJ23l7R4	18.30	\N	\N	\N	\N	\N	2026-09-04 15:17:53.707086
tO8vEcWUFXs	1.30	98.70	2	190	26.50	26.50	2026-09-05 19:35:09.745882
m1qgKExs2BY	4.10	95.90	10	240	42.70	42.70	2026-09-05 19:53:35.380044
_vTmJ79_4ho	24.80	75.20	22	67	20.80	20.80	2026-09-05 20:12:48.727333
atkvEdcPidM	10.60	89.40	20	173	38.00	33.50	2026-09-06 08:41:17.107595
dudb29Xqo60	15.00	85.00	105	594	52.00	47.50	2026-09-06 08:53:13.551357
iLZVyccaTJs	12.10	88.00	37	270	0.00	0.00	2026-09-06 13:51:03.028232
xBun0zPGZDA	9.10	90.90	46	459	0.00	0.00	2026-09-06 15:05:42.270667
4B4aAW76GLQ	15.00	85.00	62	351	42.00	33.00	2026-09-07 09:04:23.739817
LQ7ttolwjJQ	1.50	98.50	1	68	20.00	14.00	2026-09-07 10:50:43.305672
zqqcLDVZxR8	2.00	98.00	6	318	20.00	17.00	2026-09-07 10:57:07.066385
YaAKtkecoRc	28.00	72.00	114	292	38.00	29.50	2026-09-08 11:27:20.802552
Mp1WHa-CXfw	32.20	67.80	23	49	45.00	25.00	2026-09-09 14:55:59.402702
D4KiNRb7UTk	62.50	37.50	350	211	48.00	32.00	2026-09-09 16:51:44.575471
yBnFHlmgMFQ	8.40	91.60	48	523	32.00	32.00	2026-09-09 23:48:51.46802
bLwR73Y2d0w	3.40	96.60	\N	\N	\N	\N	2026-09-10 10:04:13.605465
Pnh6g6K9y8Q	10.10	89.90	43	384	28.50	28.50	2026-09-10 17:22:57.565114
DNIHqPqY3VM	4.40	95.60	19	418	33.30	33.30	2026-09-10 18:32:28.286194
Mkx7Qp8nCys	8.40	91.60	6	67	45.00	35.00	2026-09-10 18:44:13.592751
a6DGQWZ57EE	20.00	80.00	39	154	39.90	39.90	2026-09-10 19:33:03.635723
_6qJfWvvWJo	8.40	91.60	36	399	32.00	32.00	2026-09-10 20:01:40.055997
NVbNJeWZ1Lo	8.40	91.60	48	523	32.00	32.00	2026-09-10 20:21:07.431547
pl90QEsoKFk	8.40	91.60	42	456	29.60	29.60	2026-09-10 23:10:00.515414
3LCJCKfRATo	8.40	91.60	48	523	32.00	32.00	2026-09-10 23:30:52.664773
mK2nGGZFRVI	8.00	92.00	13	155	32.00	32.00	2026-09-11 10:53:51.650803
A2U9omXQ2go	8.00	92.00	13	155	32.00	32.00	2026-09-11 13:05:32.12302
fsSkI-1Opvk	25.00	75.00	0	0	0.00	0.00	2026-09-11 22:58:05.388618
pbU_sJKSfrg	25.00	75.00	0	0	0.00	0.00	2026-09-11 22:58:06.014146
W1nCo6y71R8	25.00	75.00	0	0	0.00	0.00	2026-09-11 22:58:06.303119
xj4emmUcJGE	25.00	75.00	0	0	0.00	0.00	2026-09-11 22:58:07.287609
SOKrC7BJ418	25.00	75.00	0	0	0.00	0.00	2026-09-11 22:58:07.871575
PaYUzmc11E8	25.00	75.00	0	0	0.00	0.00	2026-09-11 22:58:08.189019
0KAZqj8-gFo	25.00	75.00	0	0	0.00	0.00	2026-09-11 22:58:08.519442
w2UTdzsuads	25.00	75.00	0	0	0.00	0.00	2026-09-11 22:58:07.599184
kbLQ0kJ7pYQ	51.00	49.00	29	28	0.00	0.00	2026-09-13 00:04:05.182697
ZrY0tM9yPxQ	11.40	88.60	41	323	0.00	0.00	2026-09-13 00:39:03.743153
hiP5k2gClN0	17.20	82.80	123	591	0.00	0.00	2026-09-13 00:39:10.017376
DrhZsdeBj6k	0.00	100.00	0	30120	0.00	0.00	2026-09-13 00:39:55.370257
muLRYXpkVWA	2.10	97.90	55	2556	0.00	0.00	2026-09-13 08:06:19.001339
_gF2JDP64Yc	2.90	97.10	17	564	0.00	0.00	2026-09-13 08:06:26.943876
5v6ouzwDdRQ	6.60	93.40	40	567	0.00	0.00	2026-09-13 08:07:14.421856
4yAeMwjZxoo	5.20	94.90	24	437	0.00	0.00	2026-09-13 08:12:31.899566
SS61lwI_i5Q	44.20	55.80	83	105	0.00	0.00	2026-09-13 08:20:20.943281
BMh9Xq36RrA	1.00	99.00	11	1094	0.00	0.00	2026-09-13 08:22:34.508287
\.


--
-- Data for Name: audience_subtitles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.audience_subtitles (video_id, none_pct, hindi_pct, english_pct, other_pct, has_cc_data, fetched_at) FROM stdin;
wnp9gFm7ZpY	0.00	0.00	0.00	0.00	f	2026-09-12 21:46:22.459929
3JdwNxhgqN8	99.90	0.00	0.00	0.00	t	2026-09-13 00:48:04.423667
rrTB_XW3pWA	95.20	3.20	1.60	0.00	t	2026-09-12 23:25:09.52654
4B4aAW76GLQ	97.60	2.40	0.00	0.00	t	2026-09-07 09:04:23.739817
kbLQ0kJ7pYQ	96.50	3.50	0.00	0.00	t	2026-09-13 00:04:05.182697
AwJoDsJiAoQ	95.70	4.30	0.00	0.00	t	2026-09-13 00:30:05.383779
ZrY0tM9yPxQ	98.10	1.90	0.00	0.00	t	2026-09-13 00:39:03.743153
hiP5k2gClN0	96.20	3.50	0.30	0.00	t	2026-09-13 00:39:10.017376
UTeogxHwnPw	100.00	0.00	0.00	0.00	f	2026-09-02 09:25:42.138615
zdOSsbqouKE	100.00	0.00	0.00	0.00	f	2026-09-02 09:25:43.634893
12BKLbv0Eso	100.00	0.00	0.00	0.00	f	2026-09-02 09:25:45.151529
XM1AzgVMeqk	100.00	0.00	0.00	0.00	f	2026-09-02 09:25:46.312192
nJNR60Ms1BE	100.00	0.00	0.00	0.00	f	2026-09-02 09:25:47.152763
_A5Idj7SddI	100.00	0.00	0.00	0.00	f	2026-09-02 09:25:47.534266
BJ5lJob_sDU	100.00	0.00	0.00	0.00	f	2026-09-02 09:25:47.870198
DrhZsdeBj6k	95.80	3.90	0.30	0.00	t	2026-09-13 00:39:55.370257
LQ7ttolwjJQ	100.00	0.00	0.00	0.00	f	2026-09-07 10:50:43.305672
5goNjmztwqg	93.00	4.70	2.30	0.00	t	2026-09-02 09:45:39.987643
0jstRcQmAro	96.70	0.00	3.30	0.00	t	2026-09-02 09:46:02.751285
XWFbqR_9fqc	93.80	0.00	6.30	0.00	t	2026-09-02 10:02:53.957789
Pwp0zPAY6Y4	91.70	4.20	4.20	0.00	t	2026-09-02 10:03:13.106027
s_PoEssiuPo	88.20	8.80	2.90	0.00	t	2026-09-02 10:03:18.329293
OkWbChCIb04	98.00	2.00	0.00	0.00	t	2026-09-02 10:43:00.55935
zqqcLDVZxR8	97.50	2.50	0.00	0.00	t	2026-09-07 10:57:07.066385
2jcdStwq2yY	92.20	7.80	0.00	0.00	t	2026-09-02 11:22:03.546173
yDKB-xCaMB8	95.40	4.70	0.00	0.00	t	2026-09-02 14:30:31.576863
rg5iPj-249o	95.60	3.30	1.10	0.00	t	2026-09-02 14:58:55.032747
waW201cvfl8	98.10	1.90	0.00	0.00	t	2026-09-02 15:14:09.210888
Ay9K30yrg8Y	98.60	1.40	0.00	0.00	t	2026-09-02 15:27:50.633383
lmbndk-Db-Q	98.00	2.00	0.00	0.00	t	2026-09-02 21:49:28.223132
cSapjDf5CHY	98.50	1.50	0.00	0.00	t	2026-09-02 23:46:30.338612
JmSdjrAxNFM	93.40	5.70	0.80	0.00	t	2026-09-03 08:43:48.484092
MpQ-K2D9Ao4	97.40	2.40	0.20	0.00	t	2026-09-03 08:46:53.14088
bXetyvX2Mu8	98.00	2.00	0.00	0.00	t	2026-09-03 08:49:33.548839
pHfj5VVN0Ew	97.10	2.90	0.00	0.00	t	2026-09-03 08:52:31.076945
dpTHfuBYClo	98.40	1.40	0.20	0.00	t	2026-09-03 08:54:48.143719
sHwtsGShqjE	97.00	3.00	0.00	0.00	t	2026-09-03 10:11:18.411369
Wyt0zC-zadM	\N	\N	\N	\N	\N	2026-09-03 12:28:17.67752
JRrvbkvRyiI	\N	\N	\N	\N	\N	2026-09-03 12:45:38.189925
pTiZBob0vWA	\N	\N	\N	\N	\N	2026-09-03 13:23:31.162254
F6g5hMAUH6A	\N	\N	\N	\N	\N	2026-09-03 13:36:14.415812
durkT5BI9-0	\N	\N	\N	\N	\N	2026-09-03 14:13:12.403346
-ntsqYRrjic	\N	\N	\N	\N	\N	2026-09-03 14:22:21.576395
kQlrFbAzvro	\N	\N	\N	\N	\N	2026-09-03 14:34:36.771304
VkXC2gAxVvs	\N	\N	\N	\N	\N	2026-09-03 21:29:21.003798
QC45KrzAuLs	\N	\N	\N	\N	\N	2026-09-03 21:44:00.314367
gNgwb1lmKL8	\N	\N	\N	\N	\N	2026-09-03 22:06:49.206096
XlOAFuUr7F4	\N	\N	\N	\N	\N	2026-09-03 22:31:30.815574
d-p-YuOjU-8	\N	\N	\N	\N	\N	2026-09-03 22:47:40.537674
7L-wWpll_GU	\N	\N	\N	\N	\N	2026-09-03 22:59:23.098487
pszcrf0uTbQ	\N	\N	\N	\N	\N	2026-09-04 09:31:55.178282
EDNdXwv7W64	\N	\N	\N	\N	\N	2026-09-04 09:55:24.289926
DdMa3y_sImk	\N	\N	\N	\N	\N	2026-09-04 12:02:37.004788
YFnY2guPlxg	\N	\N	\N	\N	\N	2026-09-04 12:04:52.149361
noF6FnkgYmE	\N	\N	\N	\N	\N	2026-09-04 12:16:10.255319
tyxuLrd-xo4	\N	\N	\N	\N	\N	2026-09-04 12:33:43.388322
UzWyYR6WM6U	\N	\N	\N	\N	\N	2026-09-04 12:56:32.962168
3gSWKoBeqnw	\N	\N	\N	\N	\N	2026-09-04 13:19:16.949153
impBBFcUinY	\N	\N	\N	\N	\N	2026-09-04 13:33:07.646614
kIrFARfeW5o	\N	\N	\N	\N	\N	2026-09-04 13:52:08.871339
FwuhJ23l7R4	\N	\N	\N	\N	\N	2026-09-04 15:17:53.707086
tO8vEcWUFXs	99.50	0.50	0.00	0.00	t	2026-09-05 19:35:09.745882
m1qgKExs2BY	93.80	5.50	0.80	0.00	t	2026-09-05 19:53:35.380044
_vTmJ79_4ho	97.80	2.20	0.00	0.00	t	2026-09-05 20:12:48.727333
QnjyscmnjEQ	97.20	2.70	0.10	0.00	t	2026-09-13 01:04:42.898173
j7xmoRH2rzo	99.30	0.10	0.00	0.00	t	2026-09-13 08:04:48.235092
4yAeMwjZxoo	95.20	0.00	0.40	0.00	t	2026-09-13 08:12:31.899566
_gF2JDP64Yc	100.00	0.00	0.00	0.00	t	2026-09-13 08:06:26.943876
5v6ouzwDdRQ	100.00	0.00	0.00	0.00	t	2026-09-13 08:07:14.421856
muLRYXpkVWA	98.20	1.70	0.20	0.00	t	2026-09-13 08:06:19.001339
SS61lwI_i5Q	98.90	0.00	1.10	0.00	t	2026-09-13 08:20:20.943281
BMh9Xq36RrA	95.70	4.00	0.30	0.00	t	2026-09-13 08:22:34.508287
atkvEdcPidM	95.70	4.40	0.00	0.00	t	2026-09-06 08:41:17.107595
dudb29Xqo60	95.00	3.00	1.50	0.50	f	2026-09-06 08:53:13.551357
9jXcNZyYza8	95.80	4.20	0.00	0.00	t	2026-09-06 09:14:07.3586
eC_j1wlFJBw	100.00	0.00	0.00	0.00	t	2026-09-06 09:30:05.833783
Q-IS9K8g294	85.00	10.00	4.00	1.00	f	2026-09-06 09:52:18.827983
p03EyeJlM-k	94.60	3.60	0.60	1.20	t	2026-09-06 12:19:14.187832
229XDzxoc4g	96.40	3.60	0.00	0.00	f	2026-09-06 13:26:52.660817
j4CtPMW-1Q4	94.30	4.90	0.80	0.00	f	2026-09-06 13:43:57.675416
iLZVyccaTJs	97.70	2.00	0.30	0.00	f	2026-09-06 13:51:03.028232
xBun0zPGZDA	97.60	2.20	0.20	0.00	f	2026-09-06 15:05:42.270667
YaAKtkecoRc	70.00	20.00	8.00	2.00	t	2026-09-08 11:27:20.802552
a6DGQWZ57EE	100.00	0.00	0.00	0.00	f	2026-09-10 19:33:03.635723
Mp1WHa-CXfw	60.00	25.00	10.00	5.00	f	2026-09-09 14:55:59.402702
D4KiNRb7UTk	85.00	8.00	5.00	2.00	f	2026-09-09 16:51:44.575471
yBnFHlmgMFQ	100.00	0.00	0.00	0.00	f	2026-09-09 23:48:51.46802
bLwR73Y2d0w	100.00	0.00	0.00	0.00	f	2026-09-10 10:04:13.605465
Pnh6g6K9y8Q	100.00	0.00	0.00	0.00	f	2026-09-10 17:22:57.565114
DNIHqPqY3VM	100.00	0.00	0.00	0.00	f	2026-09-10 18:32:28.286194
Mkx7Qp8nCys	100.00	0.00	0.00	0.00	f	2026-09-10 18:44:13.592751
_6qJfWvvWJo	100.00	0.00	0.00	0.00	f	2026-09-10 20:01:40.055997
NVbNJeWZ1Lo	100.00	0.00	0.00	0.00	f	2026-09-10 20:21:07.431547
pl90QEsoKFk	100.00	0.00	0.00	0.00	f	2026-09-10 23:10:00.515414
3LCJCKfRATo	100.00	0.00	0.00	0.00	f	2026-09-10 23:30:52.664773
mK2nGGZFRVI	95.80	0.00	0.00	4.20	f	2026-09-11 10:53:51.650803
A2U9omXQ2go	95.80	0.00	0.00	4.20	f	2026-09-11 13:05:32.12302
fsSkI-1Opvk	70.00	20.00	8.00	2.00	t	2026-09-11 22:58:05.388618
pbU_sJKSfrg	70.00	20.00	8.00	2.00	t	2026-09-11 22:58:06.014146
W1nCo6y71R8	70.00	20.00	8.00	2.00	t	2026-09-11 22:58:06.303119
xj4emmUcJGE	70.00	20.00	8.00	2.00	t	2026-09-11 22:58:07.287609
w2UTdzsuads	70.00	20.00	8.00	2.00	t	2026-09-11 22:58:07.599184
SOKrC7BJ418	70.00	20.00	8.00	2.00	t	2026-09-11 22:58:07.871575
PaYUzmc11E8	70.00	20.00	8.00	2.00	t	2026-09-11 22:58:08.189019
0KAZqj8-gFo	70.00	20.00	8.00	2.00	t	2026-09-11 22:58:08.519442
\.


--
-- Data for Name: channels; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.channels (channel_id, channel_name, custom_handle, subscriber_count, created_at, niche_primary, target_audience, brand_colors, tagline, updated_at) FROM stdin;
UChUmZA1_42nfmA_mNiuLlBg	Yatharth Sachdeva	@yatharthsachdeva	696	2024-01-22 00:00:00	JEE Education	JEE 2027/2028 aspirants	{"accent": "#00D4AA", "primary": "#0A0B10", "highlight": "#00FF88"}	Digital Senior	2026-09-01 09:42:27.379694
\.


--
-- Data for Name: comments_analysis; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.comments_analysis (video_id, total_comments, comments_per_1k_views, top_level_comments, total_replies, max_thread_depth, avg_thread_depth, creator_replies, creator_reply_rate, pinned_comment_id, pinned_comment_text, hearted_comments, positive_sentiment_pct, negative_sentiment_pct, neutral_sentiment_pct, query_comments, gratitude_comments, gratitude_with_likes, spam_irrelevant_comments, query_categories, unanswered_high_intent_queries, fetched_at) FROM stdin;
0jstRcQmAro	0	0.00	0	0	0	0.00	0	0.00	\N	\N	0	\N	\N	\N	0	0	0	0	{}	0	2026-09-01 08:45:25.36398
A2U9omXQ2go	4	23.80	4	0	0	0.00	0	0.00	\N	\N	0	0.00	0.00	0.00	0	0	0	0	\N	0	2026-09-11 12:57:35.796334
BJ5lJob_sDU	0	0.00	0	0	0	0.00	0	0.00	\N	\N	0	50.00	0.00	50.00	1	0	0	0	{}	1	2026-09-02 09:20:33.221739
sHwtsGShqjE	1	2.00	1	0	1	1.00	0	0.00	\N	\N	0	0.00	0.00	0.00	0	0	0	0	{}	0	2026-09-03 10:11:18.411369
Wyt0zC-zadM	0	0.00	0	0	0	\N	0	0.00	\N	\N	0	0.00	0.00	0.00	0	0	0	0	\N	0	2026-09-03 12:28:17.67752
JRrvbkvRyiI	3	6.60	0	0	0	\N	0	0.33	\N	\N	0	0.00	0.00	0.00	1	1	0	0	\N	0	2026-09-03 12:45:38.189925
pTiZBob0vWA	0	0.00	0	0	0	\N	0	0.00	\N	\N	0	0.00	0.00	0.00	0	0	0	0	\N	0	2026-09-03 13:23:31.162254
F6g5hMAUH6A	1	5.20	0	0	0	\N	0	0.00	\N	\N	0	0.00	0.00	0.00	1	0	0	0	\N	0	2026-09-03 13:36:14.415812
durkT5BI9-0	0	0.00	0	0	0	\N	0	0.00	\N	\N	0	0.00	0.00	0.00	0	0	0	0	\N	0	2026-09-03 14:13:12.403346
3LCJCKfRATo	0	0.00	0	0	0	\N	0	0.00	\N	\N	0	0.00	0.00	0.00	0	0	0	0	\N	0	2026-09-03 21:16:47.035489
XWFbqR_9fqc	2	125.00	2	0	1	1.00	1	50.00	\N	\N	0	50.00	0.00	50.00	0	1	0	0	{}	0	2026-09-01 09:19:49.888536
Pwp0zPAY6Y4	2	87.00	2	0	1	1.00	1	50.00	\N	\N	0	50.00	0.00	50.00	0	1	0	0	{}	0	2026-09-01 09:29:40.491408
s_PoEssiuPo	1	29.40	1	0	1	1.00	0	0.00	\N	\N	0	100.00	0.00	0.00	0	1	0	0	{}	0	2026-09-01 09:42:27.379694
OkWbChCIb04	0	0.00	0	0	0	0.00	0	0.00	\N	\N	0	\N	\N	\N	0	0	0	0	{}	0	2026-09-02 10:13:50.522983
2jcdStwq2yY	2	0.00	0	0	0	0.00	0	0.00	\N	\N	0	\N	\N	\N	0	0	0	0	{}	0	2026-09-02 10:20:48.373197
yDKB-xCaMB8	1	23.30	1	0	0	0.00	0	0.00	\N	\N	0	0.00	0.00	100.00	0	0	0	0	{}	0	2026-09-02 14:30:31.576863
rg5iPj-249o	0	0.00	0	0	0	0.00	0	0.00	\N	\N	0	0.00	0.00	0.00	0	0	0	0	{}	0	2026-09-02 14:58:55.032747
pbU_sJKSfrg	0	4.20	1	0	0	0.00	0	0.00	\N	\N	0	0.00	0.00	100.00	0	1	0	0	\N	0	2026-09-11 16:20:34.478996
kbLQ0kJ7pYQ	0	0.00	0	0	0	0.00	0	0.00	\N	\N	0	0.00	0.00	100.00	0	0	0	0	\N	0	2026-09-13 00:04:05.182697
xj4emmUcJGE	1	1.00	1	0	0	0.00	0	0.00	\N	\N	0	0.00	0.00	100.00	0	1	0	0	\N	0	2026-09-11 16:35:54.654653
_A5Idj7SddI	0	0.00	0	0	0	0.00	0	0.00	\N	\N	0	\N	\N	\N	0	0	0	0	{}	0	2026-09-02 09:12:13.902042
SOKrC7BJ418	1	0.00	0	0	0	0.00	0	0.00	\N	\N	0	0.00	0.00	100.00	0	0	0	0	\N	0	2026-09-11 16:35:55.319378
waW201cvfl8	0	0.00	0	0	0	0.00	0	0.00	\N	\N	0	0.00	0.00	0.00	0	0	0	0	{}	0	2026-09-02 15:14:09.210888
Ay9K30yrg8Y	0	0.00	0	0	0	0.00	0	0.00	\N	\N	0	0.00	0.00	0.00	0	0	0	0	{}	0	2026-09-02 15:27:50.633383
lmbndk-Db-Q	0	0.00	0	0	0	0.00	0	0.00	\N	\N	0	0.00	0.00	0.00	0	0	0	0	{}	0	2026-09-02 21:49:28.223132
cSapjDf5CHY	1	2.50	1	0	0	0.00	1	100.00	\N	\N	0	0.00	0.00	100.00	0	0	0	0	{}	0	2026-09-02 23:46:30.338612
JmSdjrAxNFM	0	0.00	0	0	0	0.00	0	0.00	\N	\N	0	0.00	0.00	0.00	0	0	0	0	{}	0	2026-09-03 08:43:48.484092
MpQ-K2D9Ao4	2	3.70	2	0	0	0.00	1	50.00	\N	\N	0	50.00	0.00	50.00	0	1	0	0	{}	0	2026-09-03 08:46:53.14088
bXetyvX2Mu8	2	5.10	2	0	0	0.00	1	50.00	\N	\N	0	50.00	0.00	50.00	0	1	0	0	{}	0	2026-09-03 08:49:33.548839
pHfj5VVN0Ew	1	3.20	1	0	0	0.00	0	0.00	\N	\N	0	100.00	0.00	0.00	0	1	1	0	{}	0	2026-09-03 08:52:31.076945
dpTHfuBYClo	0	0.00	0	0	0	0.00	0	0.00	\N	\N	0	0.00	0.00	0.00	0	0	0	0	{}	0	2026-09-03 08:54:48.143719
5goNjmztwqg	0	0.00	0	0	0	0.00	0	0.00	\N	\N	0	50.00	0.00	50.00	0	0	0	0	{}	0	2026-09-02 09:40:57.778366
UTeogxHwnPw	0	0.00	0	0	0	0.00	0	0.00	\N	\N	0	100.00	0.00	0.00	0	1	0	0	{}	0	2026-09-02 00:00:20.756231
nJNR60Ms1BE	0	0.00	0	0	0	0.00	0	0.00	\N	\N	0	20.00	20.00	60.00	2	1	0	0	{}	2	2026-09-02 09:07:53.238004
XM1AzgVMeqk	0	0.00	0	0	0	0.00	0	0.00	\N	\N	0	66.70	0.00	33.30	0	2	0	1	{}	0	2026-09-02 09:02:32.054168
zdOSsbqouKE	0	0.00	0	0	0	0.00	0	0.00	\N	\N	0	100.00	0.00	0.00	0	1	0	0	{}	0	2026-09-02 00:11:35.176582
12BKLbv0Eso	0	0.00	0	0	0	0.00	0	0.00	\N	\N	0	55.60	11.10	33.30	2	2	0	0	{}	2	2026-09-02 08:57:44.373087
-ntsqYRrjic	5	6.40	0	0	0	\N	0	0.20	\N	\N	0	0.00	0.00	0.00	5	0	0	0	\N	0	2026-09-03 14:22:21.576395
kQlrFbAzvro	0	0.00	0	0	0	\N	0	0.00	\N	\N	0	0.00	0.00	0.00	0	0	0	0	\N	0	2026-09-03 14:34:36.771304
VkXC2gAxVvs	2	4.90	0	0	0	\N	0	1.00	\N	\N	0	0.00	0.00	0.00	2	0	0	0	\N	0	2026-09-03 21:29:21.003798
QC45KrzAuLs	0	0.00	0	0	0	\N	0	0.00	\N	\N	0	0.00	0.00	0.00	0	0	0	0	\N	0	2026-09-03 21:44:00.314367
gNgwb1lmKL8	0	0.00	0	0	0	\N	0	0.00	\N	\N	0	0.00	0.00	0.00	0	0	0	0	\N	0	2026-09-03 22:06:49.206096
XlOAFuUr7F4	3	6.20	0	0	0	\N	0	0.33	\N	\N	0	0.00	0.00	0.00	2	0	0	0	\N	0	2026-09-03 22:31:30.815574
d-p-YuOjU-8	8	26.60	0	0	0	\N	0	0.50	\N	\N	0	0.00	0.00	0.00	4	0	0	0	\N	0	2026-09-03 22:47:40.537674
7L-wWpll_GU	0	0.00	0	0	0	\N	0	0.00	\N	\N	0	0.00	0.00	0.00	0	0	0	0	\N	0	2026-09-03 22:59:23.098487
pszcrf0uTbQ	62	4.20	0	0	0	\N	0	0.57	\N	\N	0	0.00	0.00	0.00	22	2	0	0	\N	0	2026-09-03 23:21:10.33918
EDNdXwv7W64	10	7.90	0	0	0	\N	0	0.00	\N	\N	0	0.00	0.00	0.00	5	1	0	0	\N	0	2026-09-04 09:55:24.289926
DdMa3y_sImk	0	0.00	0	0	0	\N	0	0.00	\N	\N	0	0.00	0.00	0.00	0	0	0	0	\N	0	2026-09-04 12:02:37.004788
YFnY2guPlxg	0	0.00	0	0	0	\N	0	0.00	\N	\N	0	0.00	0.00	0.00	0	0	0	0	\N	0	2026-09-04 12:04:52.149361
noF6FnkgYmE	0	0.00	0	0	0	\N	0	0.00	\N	\N	0	0.00	0.00	0.00	0	0	0	0	\N	0	2026-09-04 12:16:10.255319
0KAZqj8-gFo	0	0.00	0	0	0	0.00	0	0.00	\N	\N	0	0.00	0.00	100.00	0	0	0	0	\N	0	2026-09-11 16:35:55.987093
ZrY0tM9yPxQ	0	0.00	0	0	0	0.00	0	0.00	\N	\N	0	0.00	0.00	100.00	0	0	0	0	\N	0	2026-09-13 00:39:03.743153
muLRYXpkVWA	0	0.00	0	0	0	0.00	0	0.00	\N	\N	0	0.00	0.00	100.00	0	0	0	0	\N	0	2026-09-13 08:06:19.001339
5v6ouzwDdRQ	0	0.00	0	0	0	0.00	0	0.00	\N	\N	0	0.00	0.00	100.00	0	0	0	0	\N	0	2026-09-13 08:07:14.421856
SS61lwI_i5Q	1	5.30	1	0	0	0.00	0	0.00	\N	\N	0	0.00	0.00	100.00	0	1	0	0	\N	0	2026-09-13 08:20:20.943281
FwuhJ23l7R4	6	18.80	2	4	2	1.33	2	0.33	\N	\N	0	16.70	0.00	83.30	3	1	0	0	{"career_advice": 1, "branch_inquiry": 2, "facility_query": 1}	1	2026-09-05 08:17:30.730134
kIrFARfeW5o	7	0.00	3	4	1	1.33	3	0.43	\N	\N	0	0.00	0.00	100.00	3	0	0	0	{"confirmation_query": 3}	0	2026-09-05 08:19:08.944026
tyxuLrd-xo4	1	0.00	1	0	0	0.00	1	1.00	\N	\N	0	0.00	0.00	100.00	0	0	0	1	{"self_promo": 1}	0	2026-09-05 08:28:44.310417
UzWyYR6WM6U	1	0.00	1	0	0	0.00	1	1.00	\N	\N	0	0.00	0.00	100.00	0	0	0	1	{"self_promo": 1}	0	2026-09-05 08:28:44.338709
3gSWKoBeqnw	0	0.00	0	0	0	0.00	0	0.00	\N	\N	0	0.00	0.00	0.00	0	0	0	0	{}	0	2026-09-05 08:28:44.341016
impBBFcUinY	9	0.00	1	8	1	8.00	3	0.33	\N	\N	0	0.00	0.00	100.00	6	0	0	0	{"dm_check": 1, "obc_ncl_format": 1, "document_upload": 2, "instagram_issue": 1, "counseling_procedure": 3}	0	2026-09-05 08:38:46.861133
tO8vEcWUFXs	0	0.00	0	0	0	0.00	0	0.00	\N	\N	0	0.00	0.00	0.00	0	0	0	0	\N	0	2026-09-05 19:35:09.745882
m1qgKExs2BY	10	39.10	1	9	2	1.90	5	50.00	\N	\N	0	30.00	0.00	70.00	2	2	0	0	\N	0	2026-09-05 19:53:35.380044
_vTmJ79_4ho	1	10.90	1	0	1	0.00	1	100.00	\N	\N	0	100.00	0.00	0.00	0	0	0	0	\N	0	2026-09-05 20:12:48.727333
rrTB_XW3pWA	2	31.70	2	0	0	0.00	0	0.00	\N	\N	0	0.00	0.00	100.00	0	2	0	0	\N	0	2026-09-12 23:25:09.52654
AwJoDsJiAoQ	0	0.00	0	0	0	0.00	0	0.00	\N	\N	0	0.00	0.00	100.00	0	0	0	0	\N	0	2026-09-13 00:30:05.383779
atkvEdcPidM	0	0.00	0	0	0	0.00	0	0.00	\N	\N	0	0.00	0.00	0.00	0	0	0	0	\N	0	2026-09-06 08:41:17.107595
dudb29Xqo60	3	4.29	3	0	0	0.00	1	33.33	\N	\N	0	33.30	0.00	66.70	0	0	0	0	\N	1	2026-09-06 08:53:13.551357
9jXcNZyYza8	1	13.90	1	0	1	0.00	0	0.00	\N	\N	0	0.00	0.00	100.00	1	0	0	0	\N	1	2026-09-06 09:14:07.3586
eC_j1wlFJBw	0	0.00	0	0	0	0.00	0	0.00	\N	\N	0	0.00	0.00	0.00	0	0	0	0	\N	0	2026-09-06 09:30:05.833783
Q-IS9K8g294	0	0.00	0	0	0	0.00	0	0.00	\N	\N	0	0.00	0.00	0.00	0	0	0	0	\N	0	2026-09-06 09:52:18.827983
fsSkI-1Opvk	1	2.40	1	0	0	0.00	0	0.00	\N	\N	0	0.00	0.00	100.00	0	1	0	0	\N	0	2026-09-11 16:20:32.995425
p03EyeJlM-k	0	0.00	0	0	0	0.00	0	0.00	\N	\N	0	0.00	0.00	0.00	0	0	0	0	\N	0	2026-09-06 12:19:14.187832
229XDzxoc4g	0	0.00	0	0	0	0.00	0	0.00	\N	\N	0	0.00	0.00	0.00	0	0	0	0	\N	0	2026-09-06 13:26:52.660817
j4CtPMW-1Q4	0	0.00	0	0	0	0.00	0	0.00	\N	\N	0	0.00	0.00	0.00	0	0	0	0	\N	0	2026-09-06 13:43:57.675416
W1nCo6y71R8	0	6.60	1	0	0	0.00	0	0.00	\N	\N	0	0.00	0.00	100.00	1	0	0	0	\N	1	2026-09-11 16:35:53.569939
iLZVyccaTJs	2	6.50	2	0	0	0.00	0	0.00	\N	\N	0	0.00	0.00	0.00	2	0	0	0	\N	2	2026-09-06 13:51:03.028232
xBun0zPGZDA	0	0.00	0	0	0	0.00	0	0.00	\N	\N	0	0.00	0.00	0.00	0	0	0	0	\N	0	2026-09-06 15:05:42.270667
w2UTdzsuads	0	5.40	2	0	0	0.00	0	0.00	\N	\N	0	0.00	0.00	100.00	0	2	0	0	\N	0	2026-09-11 16:35:54.958145
PaYUzmc11E8	0	0.00	0	0	0	0.00	0	0.00	\N	\N	0	0.00	0.00	100.00	0	0	0	0	\N	0	2026-09-11 16:35:55.65266
hiP5k2gClN0	4	5.60	4	0	0	0.00	0	0.00	\N	\N	0	0.00	0.00	100.00	2	2	0	0	\N	2	2026-09-13 00:39:10.017376
DrhZsdeBj6k	10	0.30	10	0	0	0.00	0	0.00	\N	\N	0	0.00	0.00	100.00	3	7	0	0	\N	3	2026-09-13 00:39:55.370257
3JdwNxhgqN8	3	2.30	3	0	0	0.00	0	0.00	\N	\N	0	0.00	0.00	100.00	2	1	0	0	\N	2	2026-09-13 00:48:04.423667
QnjyscmnjEQ	5	7.10	5	0	0	0.00	0	0.00	\N	\N	0	0.00	0.00	100.00	2	3	0	0	\N	2	2026-09-13 01:04:42.898173
wnp9gFm7ZpY	0	0.00	0	0	0	0.00	0	0.00	\N	\N	0	0.00	0.00	0.00	0	0	0	0	\N	0	2026-09-10 22:48:19.000993
j7xmoRH2rzo	1	0.50	1	0	0	0.00	0	0.00	\N	\N	0	0.00	0.00	100.00	0	1	0	0	\N	0	2026-09-13 08:04:48.235092
_gF2JDP64Yc	0	0.00	0	0	0	0.00	0	0.00	\N	\N	0	0.00	0.00	100.00	0	0	0	0	\N	0	2026-09-13 08:06:26.943876
4yAeMwjZxoo	1	2.20	1	0	0	0.00	0	0.00	\N	\N	0	0.00	0.00	100.00	0	1	0	0	\N	0	2026-09-13 08:12:31.899566
BMh9Xq36RrA	0	0.00	0	0	0	0.00	0	0.00	\N	\N	0	0.00	0.00	100.00	0	0	0	0	\N	0	2026-09-13 08:22:34.508287
4B4aAW76GLQ	0	0.00	0	0	0	0.00	0	0.00	\N	\N	0	0.00	0.00	0.00	0	0	0	0	\N	0	2026-09-07 09:04:23.739817
LQ7ttolwjJQ	0	0.00	0	0	0	0.00	0	0.00	\N	\N	0	0.00	0.00	0.00	0	0	0	0	\N	0	2026-09-07 10:50:43.305672
zqqcLDVZxR8	0	0.00	0	0	0	0.00	0	0.00	\N	\N	0	0.00	0.00	0.00	0	0	0	0	\N	0	2026-09-07 10:57:07.066385
yBnFHlmgMFQ	0	0.00	0	0	0	0.00	0	0.00	\N	\N	0	0.00	0.00	0.00	0	0	0	0	\N	0	2026-09-09 23:48:51.46802
YaAKtkecoRc	8	19.70	8	0	0	0.00	0	0.00	\N	\N	0	75.00	0.00	25.00	2	4	1	0	\N	1	2026-09-08 10:48:39.159712
Mp1WHa-CXfw	42	583.30	38	15	3	1.50	2	5.30	\N	\N	0	65.00	15.00	20.00	8	12	8	5	\N	3	2026-09-09 14:55:59.402702
D4KiNRb7UTk	47	8.40	38	9	3	0.80	2	4.30	\N	\N	0	65.20	12.80	22.00	8	5	3	2	\N	4	2026-09-09 16:51:44.575471
bLwR73Y2d0w	0	0.00	0	0	0	0.00	0	0.00	\N	\N	0	0.00	0.00	0.00	0	0	0	0	\N	0	2026-09-10 10:04:13.605465
Pnh6g6K9y8Q	5	0.01	5	2	1	0.40	1	20.00	\N	\N	0	60.00	20.00	20.00	2	1	1	0	\N	1	2026-09-10 17:21:45.289572
DNIHqPqY3VM	0	0.00	0	0	0	0.00	0	0.00	\N	\N	0	0.00	0.00	0.00	0	0	0	0	\N	0	2026-09-10 18:30:27.604051
Mkx7Qp8nCys	1	13.70	1	0	0	0.00	0	0.00	\N	\N	0	100.00	0.00	0.00	0	0	0	0	\N	0	2026-09-10 18:43:32.427695
a6DGQWZ57EE	0	0.00	0	0	0	0.00	0	0.00	\N	\N	0	0.00	0.00	0.00	0	0	0	0	\N	0	2026-09-10 19:31:27.388867
_6qJfWvvWJo	0	0.00	0	0	0	0.00	0	0.00	\N	\N	0	0.00	0.00	0.00	0	0	0	0	\N	0	2026-09-10 19:56:28.467634
NVbNJeWZ1Lo	0	0.00	0	0	0	0.00	0	0.00	\N	\N	0	0.00	0.00	0.00	0	0	0	0	\N	0	2026-09-10 20:21:07.431547
pl90QEsoKFk	0	0.00	0	0	0	0.00	0	0.00	\N	\N	0	0.00	0.00	0.00	0	0	0	0	\N	0	2026-09-10 23:08:11.068235
mK2nGGZFRVI	4	23.80	4	0	0	0.00	0	0.00	\N	\N	0	0.00	0.00	0.00	0	0	0	0	\N	0	2026-09-11 10:53:51.650803
\.


--
-- Data for Name: comparison_clusters; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.comparison_clusters (id, cluster_name, cluster_type, definition, video_ids, aggregate_metrics, top_performer_id, bottom_performer_id, key_differentiators, created_at) FROM stdin;
1	educational_series_jee_2024	content_series	JEE 2024 educational tips series (Part 1-5)	{5goNjmztwqg,0jstRcQmAro}	{"avg_views": 36.5, "avg_duration": 56, "avg_retention": 60.7}	5goNjmztwqg	0jstRcQmAro	{series_format,cross_linking,educational_value,hinglish_language}	2026-08-31 21:46:32.071897
16	jee_tips_series	content_series	5-part JEE tips series with cross-linking	{5goNjmztwqg,0jstRcQmAro,XWFbqR_9fqc,Pwp0zPAY6Y4,s_PoEssiuPo}	{"avg_views": 29, "avg_retention": 56.9}	5goNjmztwqg	XWFbqR_9fqc	{"Part 1: 71.4% retention (highest)","Part 5: 55.9% search (only one with search)","Decay pattern: 71.4→50→58.3→57.9→50.8%"}	2026-09-01 09:19:49.888536
\.


--
-- Data for Name: content_types; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.content_types (content_type, description, typical_duration_range, typical_retention_range, typical_search_pct_range, shelf_life_category, annual_remake_required, audience_match_score, examples) FROM stdin;
result_update	Automated category for result_update	\N	\N	\N	evergreen	f	9	\N
alert	Automated category for alert	\N	\N	\N	evergreen	f	9	\N
circular_update	Automated category for circular_update	\N	\N	\N	evergreen	f	9	\N
schedule_alert	Automated category for schedule_alert	\N	\N	\N	evergreen	f	9	\N
campus_lifestyle	Automated category for campus_lifestyle	\N	\N	\N	evergreen	f	9	\N
event_promo	Automated category for event_promo	\N	\N	\N	evergreen	f	9	\N
admit_card_release	Automated category for admit_card_release	\N	\N	\N	evergreen	f	9	\N
last_minute_tips	Automated category for last_minute_tips	\N	\N	\N	evergreen	f	9	\N
motivation	Automated category for motivation	\N	\N	\N	evergreen	f	9	\N
percentile_motivation	Automated category for percentile_motivation	\N	\N	\N	evergreen	f	9	\N
strategy	Automated category for strategy	\N	\N	\N	evergreen	f	9	\N
post_exam_guidance	Automated category for post_exam_guidance	\N	\N	\N	evergreen	f	9	\N
result_date_speculation	Automated category for result_date_speculation	\N	\N	\N	evergreen	f	9	\N
provisional_answer_key	Automated category for provisional_answer_key	\N	\N	\N	evergreen	f	9	\N
exam_tips	Exam preparation tips and strategies for competitive exams	15-60s	50-70%	5-15%	evergreen	f	9	{"JEE tips","NEET tips","study strategies"}
strategy_analysis	Automated category for strategy_analysis	\N	\N	\N	evergreen	f	9	\N
lifestyle	Automated category for lifestyle	\N	\N	\N	evergreen	f	9	\N
campus_life	Automated category for campus_life	\N	\N	\N	evergreen	f	9	\N
procedural	Automated category for procedural	\N	\N	\N	evergreen	f	9	\N
court_process	Automated category for court_process	\N	\N	\N	evergreen	f	9	\N
food_review	Automated category for food_review	\N	\N	\N	evergreen	f	9	\N
fear_mistake_warning	Automated category for fear_mistake_warning	\N	\N	\N	evergreen	f	9	\N
educational	Educational content for JEE preparation	50-60s	50-65%	0-10%	evergreen	f	1	{"JEE Tips Part 1-5"}
breaking_news	Automated category for breaking_news	\N	\N	\N	evergreen	f	9	\N
jee_mains_update	Automated category for jee_mains_update	\N	\N	\N	evergreen	f	9	\N
uncertainty_resolution	Automated category for uncertainty_resolution	\N	\N	\N	evergreen	f	9	\N
answer_key_procedure	Automated category for answer_key_procedure	\N	\N	\N	evergreen	f	9	\N
answer_key_guide	Automated category for answer_key_guide	\N	\N	\N	evergreen	f	9	\N
nta_update	Automated category for nta_update	\N	\N	\N	evergreen	f	9	\N
impossible_promise	Automated category for impossible_promise	\N	\N	\N	evergreen	f	9	\N
exam_news	Automated category for exam_news	\N	\N	\N	evergreen	f	9	\N
counseling_guide	Automated category for counseling_guide	\N	\N	\N	evergreen	f	9	\N
college_life	Automated category for college_life	\N	\N	\N	evergreen	f	9	\N
result_alert	Automated category for result_alert	\N	\N	\N	evergreen	f	9	\N
schedule_announcement	Automated category for schedule_announcement	\N	\N	\N	evergreen	f	9	\N
exam_update	Automated category for exam_update	\N	\N	\N	evergreen	f	9	\N
motivational	Automated category for motivational	\N	\N	\N	evergreen	f	9	\N
counselling	Automated category for counselling	\N	\N	\N	evergreen	f	9	\N
news_or_update	Automated category for news_or_update	\N	\N	\N	evergreen	f	9	\N
\.


--
-- Data for Name: end_screen_performance; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.end_screen_performance (video_id, has_end_screen, element_type, element_video_id, impressions, clicks, channel_avg_ctr, vs_channel_avg_pct, fetched_at) FROM stdin;
3LCJCKfRATo	f	\N	\N	0	0	0.00	0.00	2026-09-10 23:30:52.664773
rrTB_XW3pWA	f	\N	\N	0	0	0.00	0.00	2026-09-12 23:25:09.52654
AwJoDsJiAoQ	f	\N	\N	0	0	0.00	0.00	2026-09-13 00:30:05.383779
3JdwNxhgqN8	f	\N	\N	0	0	0.00	0.00	2026-09-13 00:48:04.423667
QnjyscmnjEQ	f	\N	\N	0	0	0.00	0.00	2026-09-13 01:04:42.898173
5goNjmztwqg	t	related_video	0jstRcQmAro	43	0	0.90	-100.00	2026-09-02 09:45:39.987643
0jstRcQmAro	t	related_video	XWFbqR_9fqc	30	0	0.90	-100.00	2026-09-02 09:46:02.751285
j7xmoRH2rzo	f	\N	\N	0	0	0.00	0.00	2026-09-13 08:04:48.235092
yDKB-xCaMB8	t	related_video	2jcdStwq2yY	43	0	0.90	-100.00	2026-09-02 14:30:31.576863
rg5iPj-249o	t	related_video	JEE Mains 2024: Score 180+ in 10 Days 🔥| Complete Plan | April Attempt	91	0	0.90	-100.00	2026-09-02 14:58:55.032747
waW201cvfl8	t	related_video	9WY-wTQ	105	0	0.90	-100.00	2026-09-02 15:14:09.210888
Ay9K30yrg8Y	t	related_video	Ay9K30yrg8Y	439	0	0.90	-100.00	2026-09-02 15:27:50.633383
lmbndk-Db-Q	t	related_video	JEE Mains 2024: Score 180+ in 10 Days 🔥| Complete Plan | April Attempt	147	0	0.90	-100.00	2026-09-02 21:49:28.223132
cSapjDf5CHY	t	related_video	JEE Mains 2024: Score 180+ in 10 Days 🔥| Complete Plan | April Attempt	395	0	0.90	-100.00	2026-09-02 23:46:30.338612
muLRYXpkVWA	f	\N	\N	0	0	0.00	0.00	2026-09-13 08:06:19.001339
UTeogxHwnPw	f	\N	\N	0	0	0.90	0.00	2026-09-02 09:25:42.138615
zdOSsbqouKE	f	\N	\N	0	0	0.90	0.00	2026-09-02 09:25:43.634893
12BKLbv0Eso	f	\N	\N	0	0	0.90	0.00	2026-09-02 09:25:45.151529
XM1AzgVMeqk	t	video	ZpSpypF1E38	0	0	0.90	0.00	2026-09-02 09:25:46.312192
nJNR60Ms1BE	f	\N	\N	0	0	0.90	0.00	2026-09-02 09:25:47.152763
_A5Idj7SddI	f	\N	\N	0	0	0.90	0.00	2026-09-02 09:25:47.534266
BJ5lJob_sDU	f	\N	\N	0	0	0.90	0.00	2026-09-02 09:25:47.870198
XWFbqR_9fqc	t	related_video	Pwp0zPAY6Y4	0	0	0.90	0.00	2026-09-02 10:02:53.957789
Pwp0zPAY6Y4	t	related_video	s_PoEssiuPo	0	0	0.90	0.00	2026-09-02 10:03:13.106027
s_PoEssiuPo	f	none	\N	0	0	0.90	0.00	2026-09-02 10:03:18.329293
OkWbChCIb04	f	none	\N	0	0	0.90	0.00	2026-09-02 10:43:00.55935
2jcdStwq2yY	f	none	\N	0	0	0.90	0.00	2026-09-02 11:22:03.546173
MpQ-K2D9Ao4	t	video	ZpSpypF1E38	0	0	0.90	0.00	2026-09-03 08:46:53.14088
bXetyvX2Mu8	f	none	\N	0	0	0.90	0.00	2026-09-03 08:49:33.548839
pHfj5VVN0Ew	t	video	ZpSpypF1E38	0	0	0.90	0.00	2026-09-03 08:52:31.076945
dpTHfuBYClo	t	video	ZpSpypF1E38	0	0	0.90	0.00	2026-09-03 08:54:48.143719
JmSdjrAxNFM	f	none	\N	0	0	0.90	0.00	2026-09-03 08:43:48.484092
4yAeMwjZxoo	f	\N	\N	0	0	0.00	0.00	2026-09-13 08:12:31.899566
BMh9Xq36RrA	f	\N	\N	0	0	0.00	0.00	2026-09-13 08:22:34.508287
sHwtsGShqjE	t	video	ZpSpypF1E38	0	0	0.90	0.00	2026-09-03 10:11:18.411369
Wyt0zC-zadM	t	video	ZpSpypF1E38	139	0	0.90	-100.00	2026-09-03 12:28:17.67752
JRrvbkvRyiI	t	video	ZpSpypF1E38	457	0	0.90	-100.00	2026-09-03 12:45:38.189925
pTiZBob0vWA	t	video	bXetyvX2Mu8	471	0	0.90	-100.00	2026-09-03 13:23:31.162254
F6g5hMAUH6A	f	none	\N	0	0	0.90	0.00	2026-09-03 13:36:14.415812
durkT5BI9-0	f	none	\N	0	0	0.90	0.00	2026-09-03 14:13:12.403346
-ntsqYRrjic	t	video	BJ5lJob_sDU	786	0	0.90	-100.00	2026-09-03 14:22:21.576395
kQlrFbAzvro	f	none	\N	0	0	0.90	0.00	2026-09-03 14:34:36.771304
VkXC2gAxVvs	f	none	\N	0	0	0.90	0.00	2026-09-03 21:29:21.003798
QC45KrzAuLs	t	video	kQlrFbAzvro	516	0	0.90	-100.00	2026-09-03 21:44:00.314367
gNgwb1lmKL8	t	video	MpQ-K2D9Ao4	982	0	0.90	-100.00	2026-09-03 22:06:49.206096
XlOAFuUr7F4	f	none	\N	0	0	0.90	0.00	2026-09-03 22:31:30.815574
d-p-YuOjU-8	t	video	pszcrf0uTbQ	301	0	0.90	-100.00	2026-09-03 22:47:40.537674
7L-wWpll_GU	t	video	d-p-YuOjU-8	98	0	0.90	-100.00	2026-09-03 22:59:23.098487
pszcrf0uTbQ	t	video	EDNdXwv7W64	7071	0	0.90	-100.00	2026-09-04 09:31:55.178282
EDNdXwv7W64	t	video	pszcrf0uTbQ	1258	0	0.90	-100.00	2026-09-04 09:55:24.289926
DdMa3y_sImk	t	video	pszcrf0uTbQ	323	0	0.90	-100.00	2026-09-04 12:02:37.004788
YFnY2guPlxg	t	video	DdMa3y_sImk	447	0	0.90	-100.00	2026-09-04 12:04:52.149361
noF6FnkgYmE	t	video	3gSWKoBeqnw	102	0	0.90	-100.00	2026-09-04 12:16:10.255319
tyxuLrd-xo4	t	video	sHwtsGShqjE	232	0	0.90	-100.00	2026-09-04 12:33:43.388322
UzWyYR6WM6U	t	video	tyxuLrd-xo4	407	0	0.90	-100.00	2026-09-04 12:56:32.962168
3gSWKoBeqnw	t	video	UzWyYR6WM6U	339	0	0.90	-100.00	2026-09-04 13:19:16.949153
impBBFcUinY	t	video	3gSWKoBeqnw	480	0	0.90	-100.00	2026-09-04 13:33:07.646614
kIrFARfeW5o	t	video	impBBFcUinY	520	0	0.90	-100.00	2026-09-04 13:52:08.871339
FwuhJ23l7R4	t	video	tyxuLrd-xo4	319	0	0.90	-100.00	2026-09-04 15:17:53.707086
tO8vEcWUFXs	f	\N	\N	0	0	0.90	0.00	2026-09-05 19:35:09.745882
m1qgKExs2BY	t	video	JOSAA_Counselling_Complete_Process_Step_by_Step_All_about_JOSAA_Counselling_JEE_2024	0	0	0.90	0.00	2026-09-05 19:53:35.380044
_vTmJ79_4ho	t	video	JAC_DELHI_Counselling_Complete_Process_Step_by_Step_All_about_JAC_DELHI_Counselling_JEE_2024	0	0	0.90	0.00	2026-09-05 20:12:48.727333
kbLQ0kJ7pYQ	f	\N	\N	0	0	0.00	0.00	2026-09-13 00:04:05.182697
ZrY0tM9yPxQ	f	\N	\N	0	0	0.00	0.00	2026-09-13 00:39:03.743153
hiP5k2gClN0	f	\N	\N	0	0	0.00	0.00	2026-09-13 00:39:10.017376
DrhZsdeBj6k	f	\N	\N	0	0	0.00	0.00	2026-09-13 00:39:55.370257
_gF2JDP64Yc	f	\N	\N	0	0	0.00	0.00	2026-09-13 08:06:26.943876
atkvEdcPidM	t	video	\N	0	0	0.90	0.00	2026-09-06 08:41:17.107595
dudb29Xqo60	t	video	dudb29Xqo60	0	0	0.90	0.00	2026-09-06 08:53:13.551357
9jXcNZyYza8	t	video	JOSAA_Counselling_Complete_Process_Step_by_Step_All_about_JOSAA_Counselling_JEE_2024	0	0	0.90	0.00	2026-09-06 09:14:07.3586
5v6ouzwDdRQ	f	\N	\N	0	0	0.00	0.00	2026-09-13 08:07:14.421856
eC_j1wlFJBw	t	video	JOSAA_COUNSELLING_VIDEO_ID	0	0	0.90	0.00	2026-09-06 09:30:05.833783
Q-IS9K8g294	t	video	RELATED_VIDEO_ID	0	0	0.90	0.00	2026-09-06 09:52:18.827983
SS61lwI_i5Q	f	\N	\N	0	0	0.00	0.00	2026-09-13 08:20:20.943281
p03EyeJlM-k	t	video	\N	0	0	0.90	0.00	2026-09-06 12:19:14.187832
229XDzxoc4g	t	video	\N	0	0	0.90	0.00	2026-09-06 13:26:52.660817
j4CtPMW-1Q4	t	video	\N	0	0	0.90	0.00	2026-09-06 13:43:57.675416
iLZVyccaTJs	t	video	iLZVyccaTJs	0	0	0.90	0.00	2026-09-06 13:51:03.028232
xBun0zPGZDA	t	video	RELATED_VIDEO_ID	0	0	0.90	0.00	2026-09-06 15:05:42.270667
4B4aAW76GLQ	f	\N	\N	0	0	0.00	0.00	2026-09-07 09:04:23.739817
LQ7ttolwjJQ	t	video	LQ7ttolwjJQ	69	0	0.90	0.00	2026-09-07 10:50:43.305672
zqqcLDVZxR8	t	video	JOSAA Counselling Complete Process Step by Step | All about JOSAA Counselling | JEE 2024	324	0	0.90	0.00	2026-09-07 10:57:07.066385
YaAKtkecoRc	t	video	D4KiNRb7UTk	406	2	0.90	0.00	2026-09-08 11:27:20.802552
bLwR73Y2d0w	f	\N	\N	0	0	0.00	0.00	2026-09-10 10:04:13.605465
Mp1WHa-CXfw	t	video	Mkx7Qp8nCys	72	0	0.90	0.00	2026-09-09 14:55:59.402702
D4KiNRb7UTk	f	none	\N	0	0	0.00	0.00	2026-09-09 16:51:44.575471
yBnFHlmgMFQ	f	\N	\N	0	0	0.00	0.00	2026-09-09 23:48:51.46802
Pnh6g6K9y8Q	f	\N	\N	0	0	0.00	0.00	2026-09-10 17:22:57.565114
DNIHqPqY3VM	f	\N	\N	0	0	0.00	0.00	2026-09-10 18:32:28.286194
Mkx7Qp8nCys	f	\N	\N	0	0	0.00	0.00	2026-09-10 18:44:13.592751
a6DGQWZ57EE	f	\N	\N	0	0	0.00	0.00	2026-09-10 19:33:03.635723
_6qJfWvvWJo	f	\N	\N	0	0	0.00	0.00	2026-09-10 20:01:40.055997
NVbNJeWZ1Lo	f	\N	\N	0	0	0.00	0.00	2026-09-10 20:21:07.431547
pl90QEsoKFk	f	\N	\N	0	0	0.00	0.00	2026-09-10 23:10:00.515414
mK2nGGZFRVI	f	\N	\N	0	0	0.00	0.00	2026-09-11 10:53:51.650803
A2U9omXQ2go	f	\N	\N	0	0	0.00	0.00	2026-09-11 13:05:32.12302
wnp9gFm7ZpY	f	\N	\N	0	0	0.00	0.00	2026-09-12 21:46:22.459929
fsSkI-1Opvk	f	\N	\N	0	0	0.00	0.00	2026-09-11 22:58:05.388618
pbU_sJKSfrg	f	\N	\N	0	0	0.00	0.00	2026-09-11 22:58:06.014146
W1nCo6y71R8	f	\N	\N	0	0	0.00	0.00	2026-09-11 22:58:06.303119
xj4emmUcJGE	f	\N	\N	0	0	0.00	0.00	2026-09-11 22:58:07.287609
w2UTdzsuads	f	\N	\N	0	0	0.00	0.00	2026-09-11 22:58:07.599184
SOKrC7BJ418	f	\N	\N	0	0	0.00	0.00	2026-09-11 22:58:07.871575
PaYUzmc11E8	f	\N	\N	0	0	0.00	0.00	2026-09-11 22:58:08.189019
0KAZqj8-gFo	f	\N	\N	0	0	0.00	0.00	2026-09-11 22:58:08.519442
\.


--
-- Data for Name: external_sources; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.external_sources (id, video_id, source_domain, source_type, views, percentage, fetched_at) FROM stdin;
16	5goNjmztwqg	whatsapp.com	social_messaging	1	50.00	2026-09-02 09:45:39.987643
17	5goNjmztwqg	whatsapp.com	social_messaging	1	50.00	2026-09-02 09:45:39.987643
18	5goNjmztwqg	whatsapp.com	social_messaging	1	50.00	2026-09-02 09:45:39.987643
19	5goNjmztwqg	whatsapp.com	social_messaging	1	50.00	2026-09-02 09:45:39.987643
20	waW201cvfl8	whatsapp.com	social_messaging	4	50.00	2026-09-02 15:14:09.210888
21	waW201cvfl8	WhatsApp	social_messaging	4	50.00	2026-09-02 15:14:09.210888
22	MpQ-K2D9Ao4	whatsapp.com	messaging	2	66.70	2026-09-03 08:46:53.14088
23	MpQ-K2D9Ao4	google.com	search	1	33.30	2026-09-03 08:46:53.14088
24	dpTHfuBYClo	whatsapp.com	messaging	1	100.00	2026-09-03 08:54:48.143719
25	_vTmJ79_4ho	WhatsApp	external	1	1.10	2026-09-05 20:12:48.727333
31	dudb29Xqo60	whatsapp.com	\N	7	0.00	2026-09-06 08:53:13.551357
32	dudb29Xqo60	google.com	\N	2	0.00	2026-09-06 08:53:13.551357
33	dudb29Xqo60	bing.com	\N	1	0.00	2026-09-06 08:53:13.551357
34	dudb29Xqo60	com.sec.android.app.launcher	\N	1	0.00	2026-09-06 08:53:13.551357
38	4B4aAW76GLQ	google.com	search	34	8.20	2026-09-07 09:04:23.739817
39	zqqcLDVZxR8	whatsapp.com	social	1	0.30	2026-09-07 10:57:07.066385
50	D4KiNRb7UTk	youtube.com	platform	15	2.70	2026-09-09 16:51:44.575471
51	D4KiNRb7UTk	whatsapp.com	social_messaging	10	1.80	2026-09-09 16:51:44.575471
55	bLwR73Y2d0w	youtube.com	organic	956	100.00	2026-09-10 10:04:13.605465
56	Pnh6g6K9y8Q	youtube.com	direct	427	100.00	2026-09-10 17:22:57.565114
57	DNIHqPqY3VM	youtube.com	internal	0	0.00	2026-09-10 18:32:28.286194
58	Mkx7Qp8nCys	youtube.com	internal	5	6.80	2026-09-10 18:44:13.592751
59	a6DGQWZ57EE	google.com	search	61	31.70	2026-09-10 19:33:03.635723
60	_6qJfWvvWJo	youtube.com	platform	0	0.00	2026-09-10 20:01:40.055997
62	rrTB_XW3pWA	Google Search	search_engine	63	100.00	2026-09-12 23:25:09.52654
63	AwJoDsJiAoQ	Google Search	search_engine	47	100.00	2026-09-13 00:30:05.383779
65	ZrY0tM9yPxQ	Google Search	search_engine	364	100.00	2026-09-13 00:39:03.743153
66	hiP5k2gClN0	Google Search	search_engine	714	100.00	2026-09-13 00:39:10.017376
67	DrhZsdeBj6k	Google Search	search_engine	15391	51.10	2026-09-13 00:39:55.370257
68	DrhZsdeBj6k	WhatsApp	direct	7048	23.40	2026-09-13 00:39:55.370257
69	DrhZsdeBj6k	whatsapp.com	direct	1265	4.20	2026-09-13 00:39:55.370257
70	DrhZsdeBj6k	com.openai.chatgpt	direct	392	1.30	2026-09-13 00:39:55.370257
71	DrhZsdeBj6k	Instagram	direct	241	0.80	2026-09-13 00:39:55.370257
75	QnjyscmnjEQ	Google Search	search_engine	562	80.00	2026-09-13 01:04:42.898173
83	muLRYXpkVWA	Google Search	search_engine	2611	100.00	2026-09-13 01:26:35.978101
93	j7xmoRH2rzo	whatsapp.com	direct	1177	55.30	2026-09-13 08:04:48.235092
94	j7xmoRH2rzo	WhatsApp	direct	392	18.40	2026-09-13 08:04:48.235092
95	j7xmoRH2rzo	Google Search	search_engine	113	5.30	2026-09-13 08:04:48.235092
96	5v6ouzwDdRQ	Google Search	search_engine	486	80.00	2026-09-13 08:07:14.421856
97	4yAeMwjZxoo	WhatsApp	direct	230	50.00	2026-09-13 08:12:31.899566
98	4yAeMwjZxoo	bing.com	search_engine	115	25.00	2026-09-13 08:12:31.899566
99	4yAeMwjZxoo	whatsapp.com	direct	115	25.00	2026-09-13 08:12:31.899566
\.


--
-- Data for Name: hidden_patterns; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hidden_patterns (id, pattern_name, pattern_category, description, evidence_summary, supporting_video_ids, contradicting_video_ids, confidence, actionable_insight, pipeline_implication, discovered_at, validated_at, is_active) FROM stdin;
17	series_parts_need_independent_seo	discovery	Series parts get 0% search traffic, rely on channel/pages/Shorts feed, hashtags not updated per part	Part 4: 47.8% channel pages, 34.8% Shorts feed, 0% search, hashtags say #part1 instead of #part4	{Pwp0zPAY6Y4}	{}	1	Each part needs independent title/description SEO and correct hashtags	Add search-optimized hooks per part, verify hashtags match part number	2026-09-01 09:19:49.888536	2026-09-01 09:29:40.491408	t
19	series_finale_gets_search_but_low_retention	retention	Series finale gets 55.9% search traffic but lowest retention (50.8%) and completion (34.5%)	Part 5: 55.9% search, 50.8% retention, 34.5% completion, 49.2% swipe away, loyal viewer returned	{s_PoEssiuPo}	{}	1	Series finales need distinct value (summary/recap/answers) not just continuation	Design series finales as payoff episodes with accumulated Q&A	2026-09-01 09:42:27.379694	\N	t
1	high_channel_pages_traffic	traffic_source	Short gets 51.2% traffic from Channel pages instead of Shorts feed	First short (Part-1) shows unusually high Channel pages traffic at 51.2% vs typical 15-25% for Shorts, suggesting subscribers/channel visitors are primary viewers	{5goNjmztwqg}	{}	7	Leverage channel page optimization and playlist placement for series content	Series content strategy should prioritize channel page discovery over Shorts feed algorithm	2026-08-31 21:46:03.97985	2026-08-31 22:54:52.036978	t
12	high_channel_pages_traffic_series	traffic_source	Series content (Part-2) gets 33.3% traffic from Channel pages vs typical 15-25% for Shorts	Part-2 shows 33.3% Channel pages traffic, Part-1 showed 51.2%. Series format drives channel page discovery over Shorts feed algorithm	{5goNjmztwqg,0jstRcQmAro}	{}	8	Optimize channel page and playlist placement for series content; cross-linking in description drives channel page traffic	Series content strategy should prioritize channel page discovery over Shorts feed algorithm	2026-09-01 08:45:25.36398	\N	t
\.


--
-- Data for Name: individual_comments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.individual_comments (id, video_id, comment_id, author_name, author_channel_id, is_creator, is_pinned, is_hearted, text, text_clean, like_count, reply_count, parent_comment_id, depth, published_at, updated_at, sentiment, intent_category, query_subtype, is_actionable, has_contact_info, fetched_at) FROM stdin;
302	hiP5k2gClN0	f6bfb11f946ce797	@ConfusedGoBoard-th5ix	\N	f	f	f	Kya kru	Kya kru	0	0	\N	0	\N	\N	neutral	gratitude	\N	f	f	2026-09-13 00:39:10.017376
303	hiP5k2gClN0	38ad618ddf90cde9	@NANOVibe3	\N	f	f	f	Bhaiya, abb kya seat ko freeze kar dena hai?	Bhaiya, abb kya seat ko freeze kar dena hai?	0	0	\N	0	\N	\N	neutral	question	general	t	f	2026-09-13 00:39:10.017376
304	hiP5k2gClN0	052b58b438d5d4a8	@JacsComedyShow	\N	f	f	f	Date of admission?	Date of admission?	0	0	\N	0	\N	\N	neutral	question	general	t	f	2026-09-13 00:39:10.017376
305	hiP5k2gClN0	1534e00c41495077	@ConfusedGoBoard-th5ix	\N	f	f	f	Sir mera show nhi ho rha	Sir mera show nhi ho rha	0	0	\N	0	\N	\N	neutral	gratitude	\N	f	f	2026-09-13 00:39:10.017376
8	XWFbqR_9fqc	c1	@neer4090	\N	f	f	f	Big fan bhaiya	Big fan bhaiya	0	0	\N	0	2024-01-23 00:00:00	2024-01-23 00:00:00	positive	gratitude	\N	f	f	2026-09-02 10:02:53.957789
9	XWFbqR_9fqc	c2	@YatharthSachdeva23	UChUmZA1_42nfmA_mNiuLlBg	t	f	f	Part 4 Link: https://youtube.com/shorts/Pwp0zPAY6Y4?si=FEq7nbgPLmaW8_2T	Part 4 Link: https://youtube.com/shorts/Pwp0zPAY6Y4?si=FEq7nbgPLmaW8_2T	0	0	\N	0	2024-01-23 00:00:00	2024-01-23 00:00:00	neutral	cross_link	\N	f	f	2026-09-02 10:02:53.957789
10	Pwp0zPAY6Y4	c1	@neer4090	\N	f	f	f	Big fan bhaiya	Big fan bhaiya	0	0	\N	0	2024-01-23 00:00:00	2024-01-23 00:00:00	positive	gratitude	\N	f	f	2026-09-02 10:03:13.106027
11	Pwp0zPAY6Y4	c2	@YatharthSachdeva23	UChUmZA1_42nfmA_mNiuLlBg	t	f	f	Part 5 Link: https://youtube.com/shorts/s_PoEssiuPo?si=xiUkWMcwSak3EFIk	Part 5 Link: https://youtube.com/shorts/s_PoEssiuPo?si=xiUkWMcwSak3EFIk	0	0	\N	0	2024-01-23 00:00:00	2024-01-23 00:00:00	neutral	cross_link	\N	f	f	2026-09-02 10:03:13.106027
12	s_PoEssiuPo	c1	@neer4090	\N	f	f	f	Big fan bhaiya	Big fan bhaiya	0	0	\N	0	2024-01-24 00:00:00	2024-01-24 00:00:00	positive	gratitude	\N	f	f	2026-09-02 10:03:18.329293
13	2jcdStwq2yY	c1	@ritusachdeva7968	\N	f	f	f	Very good going\nKeep it up 😊	Very good going\nKeep it up 😊	0	1	\N	0	2024-03-02 00:00:00	2024-03-02 00:00:00	positive	gratitude	\N	f	f	2026-09-02 11:22:03.546173
14	2jcdStwq2yY	c2	@YatharthSachdeva23	UChUmZA1_42nfmA_mNiuLlBg	t	f	t	Thank you so much!! ❤️❤️	Thank you so much!! ❤️❤️	0	0	c1	1	2024-03-02 00:00:00	2024-03-02 00:00:00	positive	gratitude	\N	f	f	2026-09-02 11:22:03.546173
15	yDKB-xCaMB8	comment_1	@vanshchopra1735	\N	f	f	f	Padh le bhai midsems aa rhe h 😂	Padh le bhai midsems aa rhe h	0	0	\N	0	2024-03-03 00:00:00	2024-03-03 00:00:00	neutral	peer_banter	\N	f	f	2026-09-02 14:30:31.576863
16	cSapjDf5CHY	creator_1	@YatharthSachdeva23	UChUmZA1_42nfmA_mNiuLlBg	t	f	f	Admit Card Link: https://jeemainsession2.ntaonline.in/frontend/web/advancecityintimationslip/admit-card	Admit Card Link: https://jeemainsession2.ntaonline.in/frontend/web/advancecityintimationslip/admit-card	0	0	\N	0	2024-03-31 00:00:00	2024-03-31 00:00:00	neutral	official_link	admit_card_link	t	t	2026-09-02 23:46:30.338612
17	MpQ-K2D9Ao4	c1	@shubhamgiri1099	\N	f	f	f	Iss baar iit pakka...... bhaiya	iss baar iit pakka bhaiya	0	0	\N	0	2024-04-08 00:00:00	2024-04-08 00:00:00	positive	gratitude	\N	f	f	2026-09-03 08:46:53.14088
18	MpQ-K2D9Ao4	c2	@YatharthSachdeva23	\N	t	f	f	JEE ADVANCED DAY WISE STARTEGY: https://youtu.be/ZpSpypF1E38?si=qdsw2koELlzGqVRH	jee advanced day wise strategy https youtu be zpspypf1e38 si qdsw2koellzgqvrh	0	0	\N	0	2024-04-08 00:00:00	2024-04-08 00:00:00	neutral	support	\N	f	f	2026-09-03 08:46:53.14088
19	bXetyvX2Mu8	c1	@neer4090	\N	f	f	f	Big fan bhaiya	big fan bhaiya	3	0	\N	0	2024-04-09 00:00:00	2024-04-09 00:00:00	positive	gratitude	\N	f	f	2026-09-03 08:49:33.548839
20	bXetyvX2Mu8	c2	@YatharthSachdeva23	\N	t	f	f	JEE ADVANCED DAY WISE STARTEGY: https://youtu.be/ZpSpypF1E38?si=qdsw2koELlzGqVRH	jee advanced day wise strategy https youtu be zpspypf1e38 si qdsw2koellzgqvrh	1	0	\N	0	2024-04-09 00:00:00	2024-04-09 00:00:00	neutral	support	\N	f	f	2026-09-03 08:49:33.548839
21	pHfj5VVN0Ew	c1	@shubhamgiri1099	\N	f	f	f	Thankyou bhaii	thankyou bhaii	1	0	\N	0	2024-04-11 00:00:00	2024-04-11 00:00:00	positive	gratitude	\N	f	f	2026-09-03 08:52:31.076945
345	SS61lwI_i5Q	154c9f08fa236f42	@vanshchopra1735	\N	f	f	f	Acha padh rhe h shi me hee	Acha padh rhe h shi me hee	0	0	\N	0	\N	\N	neutral	gratitude	\N	f	f	2026-09-13 08:20:20.943281
24	sHwtsGShqjE	Ugzxxxxxx	Yatharth Sachdeva	UChUmZA1_42nfmA_mNiuLlBg	f	f	f	JEE ADVANCED DAY WISE STARTEGY: https://youtu.be/ZpSpypF1E38?si=qdsw2koELlzGqVRH	\N	0	0	\N	0	2024-04-13 00:00:00	2024-04-13 00:00:00	neutral	self_promotion	\N	f	f	2026-09-03 10:11:18.411369
25	JRrvbkvRyiI	c1	\N	\N	f	f	f	Bhaiya 20 April to ho gai.... 😢	\N	0	0	\N	0	2024-04-20 00:00:00	\N	\N	\N	\N	f	f	2026-09-03 12:45:38.189925
26	JRrvbkvRyiI	c2	\N	\N	f	f	f	watch this latest short, i already answered this question in it\n\nhttps://youtube.com/shorts/durkT5BI9-0?si=dZ8bd-SfSRBhTIHl\n\nAll the best!!	\N	0	0	\N	0	2024-04-20 00:00:00	\N	\N	\N	\N	f	f	2026-09-03 12:45:38.189925
27	JRrvbkvRyiI	c3	\N	\N	f	f	f	Big fan bhaiya	\N	0	0	\N	0	2024-04-18 00:00:00	\N	\N	\N	\N	f	f	2026-09-03 12:45:38.189925
28	F6g5hMAUH6A	c1	\N	\N	f	f	f	https://exams.nta.ac.in/CUET-UG/	\N	0	0	\N	0	2024-04-20 00:00:00	\N	\N	\N	\N	f	f	2026-09-03 13:36:14.415812
29	-ntsqYRrjic	c1	\N	\N	f	f	f	If questions is dropped than it is advantage or disadvantage	\N	0	0	\N	0	2024-04-21 00:00:00	\N	\N	\N	\N	f	f	2026-09-03 14:22:21.576395
30	-ntsqYRrjic	c2	\N	\N	f	f	f	Disadvantage marks nhi milte	\N	0	0	\N	0	2024-04-21 00:00:00	\N	\N	\N	\N	f	f	2026-09-03 14:22:21.576395
31	-ntsqYRrjic	c3	\N	\N	f	f	f	Depends on if u have attempted it or not\nThat dropped question may have wasted ur and many other students'precious time in exam\nSo it would be kind of a disadvantage \nBut most of the times I would say advantage	\N	0	0	\N	0	2024-04-21 00:00:00	\N	\N	\N	\N	f	f	2026-09-03 14:22:21.576395
32	-ntsqYRrjic	c4	\N	\N	f	f	f	Result kab ayega	\N	0	0	\N	0	2024-04-21 00:00:00	\N	\N	\N	\N	f	f	2026-09-03 14:22:21.576395
33	-ntsqYRrjic	c5	\N	\N	f	f	f	Result is expected tonight, whenever it will come I will make a short and notify you, so subscribe the channel to get updates!\nAll the best for your result!	\N	0	0	\N	0	2024-04-21 00:00:00	\N	\N	\N	\N	f	f	2026-09-03 14:22:21.576395
34	VkXC2gAxVvs	c1	\N	\N	f	f	f	Iss bar to Advance ki cutoff aur high gayi h	\N	0	0	\N	0	2024-04-24 00:00:00	\N	\N	\N	\N	f	f	2026-09-03 21:29:21.003798
35	VkXC2gAxVvs	c2	\N	\N	f	f	f	Yess, it's because number of students giving exams increases every year	\N	0	0	\N	0	2024-04-24 00:00:00	\N	\N	\N	\N	f	f	2026-09-03 21:29:21.003798
36	VkXC2gAxVvs	c3	\N	\N	f	f	f	Direct Link: https://jeemainsession2.ntaonline.in/frontend/web/scorecard/index	\N	0	0	\N	0	2024-04-24 00:00:00	\N	\N	\N	\N	f	f	2026-09-03 21:29:21.003798
37	XlOAFuUr7F4	c1	\N	\N	f	f	f	Bhaiya actually I reappeared for class 12th this year because my marks were not meeting the eligibility criteria but by mistake during jee mains I applied last year marksheet now there is no option to edit what to do	\N	0	0	\N	0	2024-04-28 00:00:00	\N	\N	\N	\N	f	f	2026-09-03 22:31:30.815574
38	XlOAFuUr7F4	c2	\N	\N	f	f	f	Do not contact NTA\nCONTACT IITM HELP DESK..\nNTA WONT HELP\nTHEY WILL...I DID SIMLIAR MISTAKE	\N	0	0	\N	0	2024-04-28 00:00:00	\N	\N	\N	\N	f	f	2026-09-03 22:31:30.815574
39	XlOAFuUr7F4	c3	\N	\N	f	f	f	Don't panic!!\nRelax, it happens \nI personally don't exactly know what happens in this situation \nBut by my experience I can suggest you that contact both NTA & IITM (JEE Adv Helpline), they will definitely tells you what can be possible\nMany a times students did some mistake in jee mains registeration and it didn't affect anything because you have to again fills details at the time of counselling \nSo, don't worry just contact them they will surely help you!!	\N	0	0	\N	0	2024-04-28 00:00:00	\N	\N	\N	\N	f	f	2026-09-03 22:31:30.815574
40	d-p-YuOjU-8	c1	\N	\N	f	f	f	Class x certificate =  class x result????	\N	0	0	\N	0	2024-04-29 00:00:00	\N	\N	\N	\N	f	f	2026-09-03 22:47:40.537674
41	d-p-YuOjU-8	c2	\N	\N	f	f	f	Yess	\N	0	0	\N	0	2024-04-29 00:00:00	\N	\N	\N	\N	f	f	2026-09-03 22:47:40.537674
42	d-p-YuOjU-8	c3	\N	\N	f	f	f	Bhaiya maine form fill kar diya payment bhi ho gya hai but payment nhi dikha Raha tell me	\N	0	0	\N	0	2024-04-29 00:00:00	\N	\N	\N	\N	f	f	2026-09-03 22:47:40.537674
43	d-p-YuOjU-8	c4	\N	\N	f	f	f	Bank account se deduct ho gaye paise??\nJee advanced ki Website pe kya show ho raha hai payment ke related ?	\N	0	0	\N	0	2024-04-29 00:00:00	\N	\N	\N	\N	f	f	2026-09-03 22:47:40.537674
44	d-p-YuOjU-8	c5	\N	\N	f	f	f	@YatharthSachdeva23  ha IIT Madras ko payment ho gya hai but form mai abhi kuch dikha hi nhi raha\nForm successful fill hua ya nhi	\N	0	0	\N	0	2024-04-29 00:00:00	\N	\N	\N	\N	f	f	2026-09-03 22:47:40.537674
45	d-p-YuOjU-8	c6	\N	\N	f	f	f	Registeration successfully complete tab maani jati hai jab saari details submit kar di ho with documents and website pe payment karne ke baad show ho Jaye ki payment done ho gayi hai \n\nAgar website pe payment completed show nahi ho raha to thoda wait Karo maybe server error ho ya contact Karo helpline number pe!!	\N	0	0	\N	0	2024-04-29 00:00:00	\N	\N	\N	\N	f	f	2026-09-03 22:47:40.537674
46	d-p-YuOjU-8	c7	\N	\N	f	f	f	Bhaiya mai OBC category se belong karta hu or mere paas category certificate nhi hai to kya mai form fill nhi kar sakta please tell me	\N	0	0	\N	0	2024-04-29 00:00:00	\N	\N	\N	\N	f	f	2026-09-03 22:47:40.537674
47	d-p-YuOjU-8	c8	\N	\N	f	f	f	I have answered your doubt in this video \nLink: https://youtube.com/shorts/pszcrf0uTbQ?si=hxEQ6gEHH9WNa_qd	\N	0	0	\N	0	2024-04-29 00:00:00	\N	\N	\N	\N	f	f	2026-09-03 22:47:40.537674
311	DrhZsdeBj6k	8953d4dd7d16bfbb	@RuturajPatil-y4g	\N	f	f	f	3 option may se 1 bhi nhi khul rha hay	3 option may se 1 bhi nhi khul rha hay	0	0	\N	0	\N	\N	neutral	gratitude	\N	f	f	2026-09-13 00:39:55.370257
312	DrhZsdeBj6k	59a73e16448a2ad9	@RAUNAK-bc4qn	\N	f	f	f	​​​@YatharthSachdeva23 BHAIYA MAINR FORGET PASSWORD KIYA TO USME SHOW HO RHA AN ACTIVE SESSION HAS BEEN DETECTED\nAur usme option h ki age nhi ja skte ya phir terminate current session plz help	​​​@YatharthSachdeva23 BHAIYA MAINR FORGET PASSWORD KIYA TO USME SHOW HO RHA AN ACTIVE SESSION HAS BEEN DETECTED\nAur usme option h ki age nhi ja skte ya phir terminate current session plz help	0	0	\N	0	\N	\N	neutral	question	general	t	f	2026-09-13 00:39:55.370257
313	DrhZsdeBj6k	dc886bf93bcc990f	@bhavishya_reddy_05	\N	f	f	f	Bro can u make another clear video	Bro can u make another clear video	0	0	\N	0	\N	\N	neutral	gratitude	\N	f	f	2026-09-13 00:39:55.370257
75	pszcrf0uTbQ	c1	\N	\N	f	f	f	Bhai maine jee mains me category general lagay tha to kha main jee advanced me ews lagwa sakta hun please reply me	\N	0	0	\N	0	2024-05-03 00:00:00	\N	\N	\N	\N	f	f	2026-09-04 09:31:55.178282
76	pszcrf0uTbQ	c2	\N	\N	f	f	f	Bhai mai obc ncl nahi hu par muje obc certificate hai and jee mains mei category rank bi aaya hai tho muje kuch pbm ho saktha hai kya regarding obc ncl certificate and pls reply fast	\N	0	0	\N	0	2024-05-03 00:00:00	\N	\N	\N	\N	f	f	2026-09-04 09:31:55.178282
77	pszcrf0uTbQ	c3	\N	\N	f	f	f	Obc ka benefit tabhi milta jee advanced me jab aap OBC NCL hoge means aapki caste NCBC website pe mention hai aur aap NCL ka criteria fulfill kar rahe ho like family income 8 lakh se kam honi chahiye and all other criteria, if any	\N	0	0	\N	0	2024-05-03 00:00:00	\N	\N	\N	\N	f	f	2026-09-04 09:31:55.178282
78	pszcrf0uTbQ	c4	\N	\N	f	f	f	@YatharthSachdeva23 kya obc ncl na hone se koi rank me distrubance AA jaaithi hai jaise obc rank rank display na hona ya jee adv me and obc certificate ka koi use nahi hai kya Bhai . Tub tho muje obc ncl rank kyu Mila jee mains me	\N	0	0	\N	0	2024-05-03 00:00:00	\N	\N	\N	\N	f	f	2026-09-04 09:31:55.178282
79	pszcrf0uTbQ	c5	\N	\N	f	f	f	Agar aap obc NCL ke ho hi nahi to aapko uska benefit milega hi nahi neither in mains nor in advanced, aapne register Kara mains me as a obc candidate (which means obc NCL candidate) so, they gave you rank NTA Wale registration ke time pe koi document check nahi karte, aapke document admission ke time check hote hai, aur tab wo aapki seat cancel bhi kar sakte hai due to wrong document Try to understand reservation is only for OBC NCL I would recommend you ki jee advanced me as a general candidate hi appear Karo aur counseling ke time bhi seat wo choose karna Jo aapki CRL se mile not by obc rank!! And they can demand and affidavit from you at time of admission that you filled your category as obc by mistake so, have a look that ki wo kaise banega taaki agar wo maange to aap jaldi se bana ke unko dedo Hope you can understand	\N	0	0	\N	0	2024-05-03 00:00:00	\N	\N	\N	\N	f	f	2026-09-04 09:31:55.178282
80	pszcrf0uTbQ	c6	\N	\N	f	f	f	@YatharthSachdeva23 tq bhai	\N	0	0	\N	0	2024-05-03 00:00:00	\N	\N	\N	\N	f	f	2026-09-04 09:31:55.178282
81	pszcrf0uTbQ	c7	\N	\N	f	f	f	Hello bhaiya maine phele galti se 3rd wala option select kiya tha ki , I dont have EWS aur abhi voh muhe general mai considered kiya .. but now i have made my new ews certificate but i can change it what to di	\N	0	0	\N	0	2024-05-03 00:00:00	\N	\N	\N	\N	f	f	2026-09-04 09:31:55.178282
82	pszcrf0uTbQ	c8	\N	\N	f	f	f	Sorry to say, but now you can't change that option Now, you will be considered as general You can only contact jee advanced helpline but there are very less chance that ki ab kuch ho sakta hai	\N	0	0	\N	0	2024-05-03 00:00:00	\N	\N	\N	\N	f	f	2026-09-04 09:31:55.178282
83	pszcrf0uTbQ	c9	\N	\N	f	f	f	Iss bar to Advance ki cutoff aur high gayi h	\N	0	0	\N	0	2024-05-03 00:00:00	\N	\N	\N	\N	f	f	2026-09-04 09:31:55.178282
84	pszcrf0uTbQ	c10	\N	\N	f	f	f	Yess, it's because number of students giving exams increases every year	\N	0	0	\N	0	2024-05-03 00:00:00	\N	\N	\N	\N	f	f	2026-09-04 09:31:55.178282
85	pszcrf0uTbQ	c11	\N	\N	f	f	f	Direct Link: https://jeemainsession2.ntaonline.in/frontend/web/scorecard/index	\N	0	0	\N	0	2024-05-03 00:00:00	\N	\N	\N	\N	f	f	2026-09-04 09:31:55.178282
86	pszcrf0uTbQ	c12	\N	\N	f	f	f	Big fan bhaiya	\N	0	0	\N	0	2024-05-03 00:00:00	\N	\N	\N	\N	f	f	2026-09-04 09:31:55.178282
87	pszcrf0uTbQ	c13	\N	\N	f	f	f	Bhaiya actually I reappeared for class 12th this year because my marks were not meeting the eligibility criteria but by mistake during jee mains I applied last year marksheet now there is no option to edit what to do	\N	0	0	\N	0	2024-05-03 00:00:00	\N	\N	\N	\N	f	f	2026-09-04 09:31:55.178282
88	pszcrf0uTbQ	c14	\N	\N	f	f	f	Do not contact NTA CONTACT IITM HELP DESK.. NTA WONT HELP THEY WILL...I DID SIMLIAR MISTAKE	\N	0	0	\N	0	2024-05-03 00:00:00	\N	\N	\N	\N	f	f	2026-09-04 09:31:55.178282
89	pszcrf0uTbQ	c15	\N	\N	f	f	f	Don't panic!! Relax, it happens I personally don't exactly know what happens in this situation But by my experience I can suggest you that contact both NTA & IITM (JEE Adv Helpline), they will definitely tells you what can be possible Many a times students did some mistake in jee mains registeration and it didn't affect anything because you have to again fills details at the time of counselling So, don't worry just contact them they will surely help you!!	\N	0	0	\N	0	2024-05-03 00:00:00	\N	\N	\N	\N	f	f	2026-09-04 09:31:55.178282
90	pszcrf0uTbQ	c16	\N	\N	f	f	f	Mene cast validity. Upload ki he	\N	0	0	\N	0	2024-05-03 00:00:00	\N	\N	\N	\N	f	f	2026-09-04 09:31:55.178282
91	pszcrf0uTbQ	c17	\N	\N	f	f	f	You have to make new obc/sc/st certificate whichever you belong according to the format given by jee advanced and have to present it during college admission Now, firstly watch my short I have uploaded on my channel regarding wrong document uploaded And secondly apply for your certificate	\N	0	0	\N	0	2024-05-03 00:00:00	\N	\N	\N	\N	f	f	2026-09-04 09:31:55.178282
92	pszcrf0uTbQ	c18	\N	\N	f	f	f	Bhaiya maine form fill kar diya payment bhi ho gya hai but payment nhi dikha Raha tell me	\N	0	0	\N	0	2024-05-03 00:00:00	\N	\N	\N	\N	f	f	2026-09-04 09:31:55.178282
93	pszcrf0uTbQ	c19	\N	\N	f	f	f	Bank account se deduct ho gaye paise?? Jee advanced ki Website pe kya show ho raha hai payment ke related ?	\N	0	0	\N	0	2024-05-03 00:00:00	\N	\N	\N	\N	f	f	2026-09-04 09:31:55.178282
314	DrhZsdeBj6k	1185bcdd03209134	@Ayankathuria-q5x	\N	f	f	f	Bhaiya maine yha se change kia tha but new password invalid aa rha hai	Bhaiya maine yha se change kia tha but new password invalid aa rha hai	0	0	\N	0	\N	\N	neutral	gratitude	\N	f	f	2026-09-13 00:39:55.370257
94	pszcrf0uTbQ	c20	\N	\N	f	f	f	@YatharthSachdeva23 ha IIT Madras ko payment ho gya hai but form mai abhi kuch dikha hi nhi raha Form successful fill hua ya nhi	\N	0	0	\N	0	2024-05-03 00:00:00	\N	\N	\N	\N	f	f	2026-09-04 09:31:55.178282
95	pszcrf0uTbQ	c21	\N	\N	f	f	f	Registeration successfully complete tab maani jati hai jab saari details submit kar di ho with documents and website pe payment karne ke baad show ho Jaye ki payment done ho gayi hai Agar website pe payment completed show nahi ho raha to thoda wait Karo maybe server error ho ya contact Karo helpline number pe!!	\N	0	0	\N	0	2024-05-03 00:00:00	\N	\N	\N	\N	f	f	2026-09-04 09:31:55.178282
96	pszcrf0uTbQ	c22	\N	\N	f	f	f	Bhaiya mai OBC category se belong karta hu or mere paas category certificate nhi hai to kya mai form fill nhi kar sakta please tell me	\N	0	0	\N	0	2024-05-03 00:00:00	\N	\N	\N	\N	f	f	2026-09-04 09:31:55.178282
97	pszcrf0uTbQ	c23	\N	\N	f	f	f	I have answered your doubt in this video Link: https://youtube.com/shorts/pszcrf0uTbQ?si=hxEQ6gEHH9WNa_qd	\N	0	0	\N	0	2024-05-03 00:00:00	\N	\N	\N	\N	f	f	2026-09-04 09:31:55.178282
98	pszcrf0uTbQ	c24	\N	\N	f	f	f	Hi bhai degilocker wala class x ka marksheet chalega?????? replyplz	\N	0	0	\N	0	2024-05-03 00:00:00	\N	\N	\N	\N	f	f	2026-09-04 09:31:55.178282
99	pszcrf0uTbQ	c25	\N	\N	f	f	f	Yes, chalega	\N	0	0	\N	0	2024-05-03 00:00:00	\N	\N	\N	\N	f	f	2026-09-04 09:31:55.178282
100	pszcrf0uTbQ	c26	\N	\N	f	f	f	@YatharthSachdeva23 Bhai sorry lekin aur 2-3 question hai)\n\n1)class x marksheet aur declaration form documents form mai upload krna hai????	\N	0	0	\N	0	2024-05-03 00:00:00	\N	\N	\N	\N	f	f	2026-09-04 09:31:55.178282
101	pszcrf0uTbQ	c27	\N	\N	f	f	f	@YatharthSachdeva23 2) bhai ye obc ncl central certificate kaise banaye advance ke formate mai????	\N	0	0	\N	0	2024-05-03 00:00:00	\N	\N	\N	\N	f	f	2026-09-04 09:31:55.178282
102	pszcrf0uTbQ	c28	\N	\N	f	f	f	Arre koi problem nahi hai 2-4 questions aur puchlo par kuch bhi doubt mat rakhna sab kaam sahi se karna taki baad me pareshani na ho	\N	0	0	\N	0	2024-05-03 00:00:00	\N	\N	\N	\N	f	f	2026-09-04 09:31:55.178282
103	pszcrf0uTbQ	c29	\N	\N	f	f	f	1) Aap declaration form print kar lo aur usko fill kar lo, uski photo leke aur class X ki marksheet ki photo le ke unko alag alag pdf me bana lo ya already jaise aap digi locker ka puch rahe the to wo pdf bhi upload kar sakte ho Aap jee advanced ki website pe login/sign up kar lo saari details daal do fir jab submit pe click karoge to documents upload karna ka option aaega wahan yeh pdf upload kar Dena Jahan obc certificate manga hoga uske badle declaration form submit kar Dena And make sure pdf 50kb se 300kb ki hi honi chahiye agar nahi hai to online compress kar lena 2) For OBC NCL certificate aap online ya offline kisi bhi tarike se banwa sakte ho Offline me aap apne nearest SDM office ya Tehsildar ke paas chale jao wo aapse kuch documents maangenge wo de dena form bolenge fill karne ke liye wo bhar Dena aur kuch weeks me aapka ban jaega Agar offline banwaoge to ek baari office me bol dena ji jee ke liye chahiye aur unhe format dikha Dena Jo jee advanced ne Diya hai taki koi confusion na ho	\N	0	0	\N	0	2024-05-03 00:00:00	\N	\N	\N	\N	f	f	2026-09-04 09:31:55.178282
104	pszcrf0uTbQ	c30	\N	\N	f	f	f	@YatharthSachdeva23 thankx bro (Best YT channel) better than jindal jee keep it up bro	\N	0	0	\N	0	2024-05-03 00:00:00	\N	\N	\N	\N	f	f	2026-09-04 09:31:55.178282
105	pszcrf0uTbQ	c31	\N	\N	f	f	f	@YatharthSachdeva23 lo bhai mane bhi subscribe kar diya	\N	0	0	\N	0	2024-05-03 00:00:00	\N	\N	\N	\N	f	f	2026-09-04 09:31:55.178282
106	pszcrf0uTbQ	c32	\N	\N	f	f	f	@YatharthSachdeva23 bro wo insta wala bhi main hi hu jisne abhi follow kiya	\N	0	0	\N	0	2024-05-03 00:00:00	\N	\N	\N	\N	f	f	2026-09-04 09:31:55.178282
107	pszcrf0uTbQ	c33	\N	\N	f	f	f	@YatharthSachdeva23 bhai kuch idea tehsildar kya documents magega???	\N	0	0	\N	0	2024-05-03 00:00:00	\N	\N	\N	\N	f	f	2026-09-04 09:31:55.178282
108	pszcrf0uTbQ	c34	\N	\N	f	f	f	Actually it depends from district to district so, it's better ki aap ek baari unke paas jake clarify kar lo I'd proof, resident proof aur bhi bahut kuch hota hai	\N	0	0	\N	0	2024-05-03 00:00:00	\N	\N	\N	\N	f	f	2026-09-04 09:31:55.178282
109	pszcrf0uTbQ	c35	\N	\N	f	f	f	Bhaiya aaj last date hai please help me Mai sc category se belong karta hu but mere pas sc certificate nahi hai. Aur form bharne ke lie sc certificate mandatory hai ab mai kya karu bhaiya please help me	\N	0	0	\N	0	2024-05-03 00:00:00	\N	\N	\N	\N	f	f	2026-09-04 09:31:55.178282
110	pszcrf0uTbQ	c36	\N	\N	f	f	f	Aap declaration form bharo maine uska link comment section me Diya hua hai wahan se download karlo aur usse fill karke certificate ki jagah par wo declaration form submit Karo Please be fast!! Registration is about to close	\N	0	0	\N	0	2024-05-03 00:00:00	\N	\N	\N	\N	f	f	2026-09-04 09:31:55.178282
111	pszcrf0uTbQ	c37	\N	\N	f	f	f	Instead of declaration form I uploaded the caste certificate, is it ok or should I mail them?	\N	0	0	\N	0	2024-05-03 00:00:00	\N	\N	\N	\N	f	f	2026-09-04 09:31:55.178282
112	pszcrf0uTbQ	c38	\N	\N	f	f	f	You have to upload your category certificate like obc NCL, sc/st certificate if you have them If you don't have it ready till now you have to upload declaration form	\N	0	0	\N	0	2024-05-03 00:00:00	\N	\N	\N	\N	f	f	2026-09-04 09:31:55.178282
113	pszcrf0uTbQ	c39	\N	\N	f	f	f	​@YatharthSachdeva23I am from OBC but my OBC ncl certificate was not ready so I uploaded my OBC caste certificate not ncl, should I mail them that I want to re-upload declaration form or is it ok ??	\N	0	0	\N	0	2024-05-03 00:00:00	\N	\N	\N	\N	f	f	2026-09-04 09:31:55.178282
114	pszcrf0uTbQ	c40	\N	\N	f	f	f	You should mail them and explain them your situation and don't worry and get back to your preparation If you want, you can watch my another shorts on my channel in which I have told about all this situation when you upload wrong document! Subscribe if you found it helpful	\N	0	0	\N	0	2024-05-03 00:00:00	\N	\N	\N	\N	f	f	2026-09-04 09:31:55.178282
115	pszcrf0uTbQ	c41	\N	\N	f	f	f	Bhai mera obc certificate Nov 2023 me bana tha, laga mains registration me mangenge magar nhi maanga, jab mai sdm office gya renew krane ko April 2024 me to mna krdiya bola ki 1 saal se pehle impossible hai Ncl certificate bhi nhi bana rhe, naahi nya obc certificate bna rhe hai to ye Nov 2023 ka dtu me chal jayega kya Delhi state certificate	\N	0	0	\N	0	2024-05-03 00:00:00	\N	\N	\N	\N	f	f	2026-09-04 09:31:55.178282
116	pszcrf0uTbQ	c42	\N	\N	f	f	f	Nahi, nov 23 wala certificate nahi chalega Aapko obc NCL certificate hi banwana hai Aur office me jaake ek baari bolo ki jee me admission ke liye chahiye isliye Naya mandatory hai wo bana dete hai remember unko OBC NCL bolna And for now upload declaration form	\N	0	0	\N	0	2024-05-03 00:00:00	\N	\N	\N	\N	f	f	2026-09-04 09:31:55.178282
117	pszcrf0uTbQ	c43	\N	\N	f	f	f	@YatharthSachdeva23 nhi maan rhe bhaiya, keh rhe hai 1 saal me expire hota hai tabhi banayenge, pehle bnaya to dikkat hogi unhe hi fir, mere papa ke dost ka leliya tha dtu me April 2023 ke pehle ka last year, kya mera nhi lenge Mere papa government employee hai to ncl renew krane ki jarurat hai? Kyuki 8 lakh se jyada ho to bhi koi fark to padega nhi kyuki govt employees ke liye to 8 lakh wala criteria hai hi nhi	\N	0	0	\N	0	2024-05-03 00:00:00	\N	\N	\N	\N	f	f	2026-09-04 09:31:55.178282
118	pszcrf0uTbQ	c44	\N	\N	f	f	f	Pdf open nhi ho rahi	\N	0	0	\N	0	2024-05-03 00:00:00	\N	\N	\N	\N	f	f	2026-09-04 09:31:55.178282
119	pszcrf0uTbQ	c45	\N	\N	f	f	f	Discription me bhi de dia link try Karo wahan se open karne ka nahi to wo pura message copy karke notes/clipboard me paste Karo baaki ka message hatao aur wo part Google pe daal do ho jaega Or you can open it on laptop YouTube wahan ho jaega	\N	0	0	\N	0	2024-05-03 00:00:00	\N	\N	\N	\N	f	f	2026-09-04 09:31:55.178282
120	pszcrf0uTbQ	c46	\N	\N	f	f	f	Mene cast validity. Upload ki he	\N	0	0	\N	0	2024-05-03 00:00:00	\N	\N	\N	\N	f	f	2026-09-04 09:31:55.178282
121	pszcrf0uTbQ	c47	\N	\N	f	f	f	You have to make new obc/sc/st certificate whichever you belong according to the format given by jee advanced and have to present it during college admission Now, firstly watch my short I have uploaded on my channel regarding wrong document uploaded And secondly apply for your certificate	\N	0	0	\N	0	2024-05-03 00:00:00	\N	\N	\N	\N	f	f	2026-09-04 09:31:55.178282
122	pszcrf0uTbQ	c48	\N	\N	f	f	f	Sir y or bata doo ki maine cuet m 3 subject fill kiye h physic maths chemistry too m de k aa skta huu naa cuet ka exam pls y bata doo	\N	0	0	\N	0	2024-05-03 00:00:00	\N	\N	\N	\N	f	f	2026-09-04 09:31:55.178282
123	pszcrf0uTbQ	c49	\N	\N	f	f	f	sorry for now, i don't have much idea about cuet to the extent i know, i think you can give kyunki agar kuch issue hota to wo ya to form submit nahi hota ya reject ho jata abhi tak but i can definitely say that ki agar aapka admit card aa jaega to aap bilkul paper de paoge mein issi channel pe cuet ki saari updates dunga, so subscribe kar lena	\N	0	0	\N	0	2024-05-03 00:00:00	\N	\N	\N	\N	f	f	2026-09-04 09:31:55.178282
124	pszcrf0uTbQ	c50	\N	\N	f	f	f	Bhaiyya OBC ncl hu ..abhi certificate banne me 15-20 din bol rhe hai apply krdia hai......please bata do jee advanced ka form bhar skta hu ya nahi (91 percentile in jee mains gen ki cutoff clear ni hai apni caste ki h pr certificate abhi ni hai) please bhiaya	\N	0	0	\N	0	2024-05-03 00:00:00	\N	\N	\N	\N	f	f	2026-09-04 09:31:55.178282
125	pszcrf0uTbQ	c51	\N	\N	f	f	f	Jee advanced ke liye bilkul register kar do, declaration form bhar ke dedo abhi ke liye (Jahan wo certificate upload karne ka option ho wahan declaration form submit kar Dena abhi) Declaration form ka link pinned comment me hai	\N	0	0	\N	0	2024-05-03 00:00:00	\N	\N	\N	\N	f	f	2026-09-04 09:31:55.178282
126	pszcrf0uTbQ	c52	\N	\N	f	f	f	Link open nhi ho rhi	\N	0	0	\N	0	2024-05-03 00:00:00	\N	\N	\N	\N	f	f	2026-09-04 09:31:55.178282
127	pszcrf0uTbQ	c53	\N	\N	f	f	f	Discription me bhi de dia link try Karo wahan se open karne ka nahi to wo pura message copy karke notes/clipboard me paste Karo baaki ka message hatao aur wo part Google pe daal do ho jaega Or you can open it on laptop YouTube wahan ho jaega	\N	0	0	\N	0	2024-05-03 00:00:00	\N	\N	\N	\N	f	f	2026-09-04 09:31:55.178282
128	pszcrf0uTbQ	c54	\N	\N	f	f	f	​@YatharthSachdeva23bhaiya ye Certificate hard copy pe leke scamned copy upload krni ya soft copy bhi kar skte?	\N	0	0	\N	0	2024-05-03 00:00:00	\N	\N	\N	\N	f	f	2026-09-04 09:31:55.178282
129	pszcrf0uTbQ	c55	\N	\N	f	f	f	Yes, you can upload soft copy only there is no issue!!	\N	0	0	\N	0	2024-05-03 00:00:00	\N	\N	\N	\N	f	f	2026-09-04 09:31:55.178282
130	pszcrf0uTbQ	c56	\N	\N	f	f	f	there is some payment issue. after payment bhi pending dikha raha aur wapas se payment nahi ho raha site me error dikha raha hai. what to do	\N	0	0	\N	0	2024-05-03 00:00:00	\N	\N	\N	\N	f	f	2026-09-04 09:31:55.178282
131	pszcrf0uTbQ	c57	\N	\N	f	f	f	Agar payment complete nahi hui aur amount deduct ho gaya bank se to thoda wait karlo 4-5 hours maybe server error ho sakta hai Uske baad bhi issue rehta hai to best is ki dubara payment kar do agar unke paas 2 baari chali jaegi tab bhi wo ek baari ke refund kar denge And if payment karne ka option bhi nahi aa raha dubara to ek baari exactly batao ki kya show ho raha hai And contact jee advanced helpline mail or call them	\N	0	0	\N	0	2024-05-03 00:00:00	\N	\N	\N	\N	f	f	2026-09-04 09:31:55.178282
132	pszcrf0uTbQ	c58	\N	\N	f	f	f	@YatharthSachdeva23 2 din ho gaye hai abhi bhi pending dikha raha aur new payment bhi nhi ho rahi	\N	0	0	\N	0	2024-05-03 00:00:00	\N	\N	\N	\N	f	f	2026-09-04 09:31:55.178282
133	pszcrf0uTbQ	c59	\N	\N	f	f	f	You must contact jee advanced helpline ASAP Email them now your concern and call them on their working hours They will help you Don't panic but take appropriate action carefully and quickly!	\N	0	0	\N	0	2024-05-03 00:00:00	\N	\N	\N	\N	f	f	2026-09-04 09:31:55.178282
134	pszcrf0uTbQ	c60	\N	\N	f	f	f	Link nahi kul raha bhai	\N	0	0	\N	0	2024-05-03 00:00:00	\N	\N	\N	\N	f	f	2026-09-04 09:31:55.178282
135	pszcrf0uTbQ	c61	\N	\N	f	f	f	Discription me bhi de dia link try Karo wahan se open karne ka nahi to wo pura message copy karke notes/clipboard me paste Karo baaki ka message hatao aur wo part Google pe daal do ho jaega Or you can open it on laptop YouTube wahan ho jaega	\N	0	0	\N	0	2024-05-03 00:00:00	\N	\N	\N	\N	f	f	2026-09-04 09:31:55.178282
136	pszcrf0uTbQ	c62	\N	\N	f	f	f	@YatharthSachdeva23 bhai mene bymistake declaration or mere 10th marksheet ki portal mein bhi mere marksheet hi upload Kiya Tha in advance now what to do I belong to ews category	\N	0	0	\N	0	2024-05-03 00:00:00	\N	\N	\N	\N	f	f	2026-09-04 09:31:55.178282
137	pszcrf0uTbQ	c63	\N	\N	f	f	f	So, basically you uploaded your marksheet on both the places (marksheet place and certificate place) so, in that case Firstly relax, don't panic and watch my short of uploading wrong document, I have explained what to do in that video, you can find it on my channel shorts section Link (if it works): https://youtube.com/shorts/EDNdXwv7W64?si=nFGQ-AgXMUMqG4yc	\N	0	0	\N	0	2024-05-03 00:00:00	\N	\N	\N	\N	f	f	2026-09-04 09:31:55.178282
138	EDNdXwv7W64	c1	\N	\N	f	f	f	Bhai ya main 2025 appearing class 12 hu galti se jee advanced me 2024 pass likh diya hu...\n\nMains ke Shi hai advance me galti ho gya.... mujhe councelling nhi kara iss Saal...\n\nToh Shi kayse karaye...ye	\N	0	0	\N	0	2024-05-06 00:00:00	\N	\N	\N	\N	f	f	2026-09-04 09:55:24.289926
139	EDNdXwv7W64	c2	\N	\N	f	f	f	Bhaiya Main SC certificate ki jagah class XII ki marksheet and marksheet ki jagah SC certificate dal diya,,,,ab keya karu main??????	\N	1	0	\N	0	2024-05-06 00:00:00	\N	\N	\N	\N	f	f	2026-09-04 09:55:24.289926
140	EDNdXwv7W64	c3	\N	\N	f	f	f	Mail kardo and it's okay pareshan mat ho aapke paas saare documents ready hone chahiye admission ke time check hota hai main to	\N	0	0	\N	0	2024-05-06 00:00:00	\N	\N	\N	\N	f	f	2026-09-04 09:55:24.289926
141	EDNdXwv7W64	c4	\N	\N	f	f	f	Bhaiya maine glti se caste certificate ki jgh income certificate upload kr diya hai kya mera form accept ho jayega?	\N	0	0	\N	0	2024-05-06 00:00:00	\N	\N	\N	\N	f	f	2026-09-04 09:55:24.289926
142	EDNdXwv7W64	c5	\N	\N	f	f	f	Mail kar do unhe \nDon't worry just mail it, you'll be able to give exam!\nDo necessary things if they ask you any documents on mail	\N	0	0	\N	0	2024-05-06 00:00:00	\N	\N	\N	\N	f	f	2026-09-04 09:55:24.289926
143	EDNdXwv7W64	c6	\N	\N	f	f	f	Bhaiya glti se 10 marksheet me category certificate upload ho gya h \nKya jee advanced me dunga na \nOr Maine mail bhi krdia h	\N	0	0	\N	0	2024-05-06 00:00:00	\N	\N	\N	\N	f	f	2026-09-04 09:55:24.289926
144	EDNdXwv7W64	c7	\N	\N	f	f	f	Don't worry just mail it, you'll be able to give exam!\nDo necessary things if they ask you any documents on mail	\N	0	0	\N	0	2024-05-06 00:00:00	\N	\N	\N	\N	f	f	2026-09-04 09:55:24.289926
145	EDNdXwv7W64	c8	\N	\N	f	f	f	Thank you so much bhai	\N	0	0	\N	0	2024-05-06 00:00:00	\N	\N	\N	\N	f	f	2026-09-04 09:55:24.289926
146	EDNdXwv7W64	c9	\N	\N	f	f	f	Bhaiya Main SC certificate ki jagah class XII ki marksheet and marksheet ki jagah SC certificate dal diya,,,,ab keya karu main??????	\N	0	0	\N	0	2024-05-06 00:00:00	\N	\N	\N	\N	f	f	2026-09-04 09:55:24.289926
315	DrhZsdeBj6k	faddc15732f444a8	@HarshSahu-d7i	\N	f	f	f	Mera result toh message ke through aa gaya par result open nahi ho raha	Mera result toh message ke through aa gaya par result open nahi ho raha	0	0	\N	0	\N	\N	neutral	gratitude	\N	f	f	2026-09-13 00:39:55.370257
316	DrhZsdeBj6k	820e86d016e46e1c	@aryangupta2342	\N	f	f	f	Bhaiya new password se bhe open nhi ho raha	Bhaiya new password se bhe open nhi ho raha	0	0	\N	0	\N	\N	neutral	gratitude	\N	f	f	2026-09-13 00:39:55.370257
317	DrhZsdeBj6k	fa9095b142e08c9f	@HEHEHESUIIII7	\N	f	f	f	Bhai lekin usme to session 2 ka application no. aur password mang raha he?	Bhai lekin usme to session 2 ka application no. aur password mang raha he?	0	0	\N	0	\N	\N	neutral	question	general	t	f	2026-09-13 00:39:55.370257
157	FwuhJ23l7R4	c1	@KU0010	\N	f	f	f	is it fully air conditioned?	is it fully air conditioned?	0	0	\N	0	2024-05-11 00:00:00	\N	neutral	facility_query	\N	f	f	2026-09-05 08:17:30.749958
158	FwuhJ23l7R4	c2	@tejasagarwal5810	\N	f	f	f	Which branch?	Which branch?	0	4	\N	0	2024-05-11 00:00:00	\N	neutral	branch_inquiry	\N	f	f	2026-09-05 08:17:30.777759
159	FwuhJ23l7R4	c3	@YatharthSachdeva23	\N	t	f	f	Information Technology	Information Technology	1	0	c2	1	2024-05-11 00:00:00	\N	positive	creator_reply	answer	f	f	2026-09-05 08:17:30.778989
160	FwuhJ23l7R4	c4	@tejasagarwal5810	\N	f	f	f	DTU mai mechanical kaisi hoti hai? Should i go for it if i dont get a better branch in a good gfti?	DTU mai mechanical kaisi hoti hai? Should i go for it if i dont get a better branch in a good gfti?	0	0	c2	1	2024-05-11 00:00:00	\N	neutral	career_advice	\N	f	f	2026-09-05 08:17:30.780105
161	FwuhJ23l7R4	c5	@YatharthSachdeva23	\N	t	f	f	It depends on your personal interest on top of everything So, if you are ready to do mechanical In terms of placement and overall DTU Mechanical is considered very good than other colleges mechanical, this is happening from years Rest you decide But if you dont like mechanical then I suggest you to take admission in less good college but the branch you can take Because you have to do that genres job after 4 years Think wisely!!	It depends on your personal interest on top of everything So, if you are ready to do mechanical In terms of placement and overall DTU Mechanical is considered very good than other colleges mechanical, this is happening from years Rest you decide But if you dont like mechanical then I suggest you to take admission in less good college but the branch you can take Because you have to do that genres job after 4 years Think wisely!!	0	0	c2	1	2024-05-11 00:00:00	\N	positive	creator_reply	advice	f	f	2026-09-05 08:17:30.78167
162	FwuhJ23l7R4	c6	@tejasagarwal5810	\N	f	f	t	Okay bhaiya thanks a lot	Okay bhaiya thanks a lot	0	0	c2	1	2024-05-11 00:00:00	\N	positive	gratitude	\N	f	f	2026-09-05 08:17:30.78344
163	kIrFARfeW5o	c1	@thegkzone-f2x	\N	f	f	f	Sach me kya	Sach me kya	1	1	\N	0	2024-05-14 00:00:00	\N	neutral	confirmation_query	\N	f	f	2026-09-05 08:19:08.963425
164	kIrFARfeW5o	c2	@YatharthSachdeva23	\N	t	f	f	yes, its true for candidates in delhi state!!	yes, its true for candidates in delhi state!!	0	0	c1	1	2024-05-14 00:00:00	\N	positive	creator_reply	confirmation	f	f	2026-09-05 08:19:08.966636
165	kIrFARfeW5o	c3	@SOFIA-uk1mh	\N	f	f	f	Is it true?	Is it true?	0	1	\N	0	2024-05-14 00:00:00	\N	neutral	confirmation_query	\N	f	f	2026-09-05 08:19:08.967503
166	kIrFARfeW5o	c4	@YatharthSachdeva23	\N	t	f	f	yes, its true for candidates in delhi state!!	yes, its true for candidates in delhi state!!	1	0	c3	1	2024-05-14 00:00:00	\N	positive	creator_reply	confirmation	f	f	2026-09-05 08:19:08.974041
167	kIrFARfeW5o	c5	@arshsoni559	\N	f	f	f	Only in delhi	Only in delhi	1	1	\N	0	2024-05-14 00:00:00	\N	neutral	confirmation_query	\N	f	f	2026-09-05 08:19:08.975906
168	kIrFARfeW5o	c6	@YatharthSachdeva23	\N	t	f	f	yes	yes	0	0	c5	1	2024-05-14 00:00:00	\N	positive	creator_reply	confirmation	f	f	2026-09-05 08:19:08.976758
169	kIrFARfeW5o	c7	@YatharthSachdeva23	\N	t	f	f	Please NOTE: This news is for all the candidates who are giving exams in delhi region For all other states, exam will held normally!!	Please NOTE: This news is for all the candidates who are giving exams in delhi region For all other states, exam will held normally!!	0	0	\N	0	2024-05-14 00:00:00	\N	positive	creator_reply	clarification	f	f	2026-09-05 08:19:08.977949
170	tyxuLrd-xo4	c1	@YatharthSachdeva23	\N	t	f	f	If you think, you get less marks and want cbse to do re-checking then a special video on that is coming soon on this channel, so subscribe the channel!!	If you think, you get less marks and want cbse to do re-checking then a special video on that is coming soon on this channel, so subscribe the channel!!	0	0	\N	0	2024-05-13 00:00:00	\N	neutral	self_promo	\N	f	f	2026-09-05 08:28:44.335318
171	UzWyYR6WM6U	c1	@YatharthSachdeva23	\N	t	f	f	If you think, you get less marks and want cbse to do re-checking then a special video on that is coming soon on this channel, so subscribe the channel!!	If you think, you get less marks and want cbse to do re-checking then a special video on that is coming soon on this channel, so subscribe the channel!!	0	0	\N	0	2024-05-13 00:00:00	\N	neutral	self_promo	\N	f	f	2026-09-05 08:28:44.339378
172	impBBFcUinY	c1	@MasterCreaterop	\N	f	f	f	Bhai insta pe reply nhi diya 🔕	Bhai insta pe reply nhi diya	0	8	\N	0	2024-05-14 00:00:00	\N	neutral	instagram_issue	\N	f	f	2026-09-05 08:38:46.880161
173	impBBFcUinY	c2	@YatharthSachdeva23	\N	t	f	f	Check your DM!!	Check your DM!!	0	0	c1	1	2024-05-14 00:00:00	\N	positive	creator_reply	dm_response	f	f	2026-09-05 08:38:46.885152
174	impBBFcUinY	c3	@MasterCreaterop	\N	f	f	f	@YatharthSachdeva23 bhai dm kar diya	@YatharthSachdeva23 bhai dm kar diya	0	0	c1	1	2024-05-14 00:00:00	\N	neutral	dm_check	\N	f	f	2026-09-05 08:38:46.886141
175	impBBFcUinY	c4	@MasterCreaterop	\N	f	f	f	@YatharthSachdeva23 BASS YE PUCHNA THA KI AGAR ( OBC NCL CATEGORY KA JO FORMAT HAI JO JEE ADVANCE KE LIYE HAI USKA ZEROX LEKE USKO FILL KARKE USPE TEHSILDAR KI SIGN HO TO VALID HAI KYA????	@YatharthSachdeva23 BASS YE PUCHNA THA KI AGAR ( OBC NCL CATEGORY KA JO FORMAT HAI JO JEE ADVANCE KE LIYE HAI USKA ZEROX LEKE USKO FILL KARKE USPE TEHSILDAR KI SIGN HO TO VALID HAI KYA????	0	0	c1	1	2024-05-14 00:00:00	\N	neutral	obc_ncl_format	\N	f	f	2026-09-05 08:38:46.886953
176	impBBFcUinY	c5	@YatharthSachdeva23	\N	t	f	f	i don't know, maybe it works maybe not, i recommend you to make as per official procedure kyunki usme koi dikkat nahi hogi	i don't know, maybe it works maybe not, i recommend you to make as per official procedure kyunki usme koi dikkat nahi hogi	0	0	c1	1	2024-05-14 00:00:00	\N	positive	creator_reply	advice	f	f	2026-09-05 08:38:46.887519
177	impBBFcUinY	c6	@MasterCreaterop	\N	f	f	f	Ok,  Bhai documents ki need seat allotment ke bad hoti hai na, councelling ke 2-3 din bad	Ok,  Bhai documents ki need seat allotment ke bad hoti hai na, councelling ke 2-3 din bad	0	0	c1	1	2024-05-14 00:00:00	\N	neutral	document_upload	\N	f	f	2026-09-05 08:38:46.88806
178	impBBFcUinY	c7	@MasterCreaterop	\N	f	f	f	@YatharthSachdeva23 bro councelling pe video banao plz full procedure, kitne din lagte hai, konse documents kab lagte hai full detailed	@YatharthSachdeva23 bro councelling pe video banao plz full procedure, kitne din lagte hai, konse documents kab lagte hai full detailed	0	0	c1	1	2024-05-14 00:00:00	\N	neutral	counseling_procedure	\N	f	f	2026-09-05 08:38:46.889362
179	impBBFcUinY	c8	@YatharthSachdeva23	\N	t	f	f	Jac counseling has 6 rounds\nJis bhi round me aapko seat allotment hui hai uske agle 2-3 din me aapko document verify karwane honge, exact dates jac Wale bata denga	Jac counseling has 6 rounds Jis bhi round me aapko seat allotment hui hai uske agle 2-3 din me aapko document verify karwane honge, exact dates jac Wale bata denga	0	0	c1	1	2024-05-14 00:00:00	\N	positive	creator_reply	counseling_info	f	f	2026-09-05 08:38:46.889933
180	impBBFcUinY	c9	@YatharthSachdeva23	\N	t	f	f	Sure, counselling pe video aane wali hai \nWorking on it!!\nJosaa and Jac dono pe video aaengi	Sure, counselling pe video aane wali hai Working on it!! Josaa and Jac dono pe video aaengi	0	0	c1	1	2024-05-14 00:00:00	\N	positive	creator_reply	video_promise	f	f	2026-09-05 08:38:46.890675
181	m1qgKExs2BY	c1	@MasterCreaterop	\N	f	f	f	Bhai councelling mai konse documents chahiye??	Bhai councelling mai konse documents chahiye??	0	8	\N	0	2024-05-16 00:00:00	2024-05-16 00:00:00	neutral	query	documents	t	f	2026-09-05 19:53:35.380044
182	m1qgKExs2BY	c2	@YatharthSachdeva23	\N	t	f	f	Working on it! video coming in few days	Working on it! video coming in few days	0	0	c1	1	2024-05-16 00:00:00	2024-05-16 00:00:00	positive	creator_reply	\N	f	f	2026-09-05 19:53:35.380044
183	m1qgKExs2BY	c3	@MasterCreaterop	\N	f	f	f	@YatharthSachdeva23 bhai aache se banana baki YouTuber chutiyapa krte hai aur councelling ke wakt ke alag batana aur admission ke walt ke alag plz (Aur congrats councelling wala video badhiya views hai))	@YatharthSachdeva23 bhai aache se banana baki YouTuber chutiyapa krte hai aur councelling ke wakt ke alag batana aur admission ke walt ke alag plz (Aur congrats councelling wala video badhiya views hai))	0	0	c1	1	2024-05-16 00:00:00	2024-05-16 00:00:00	positive	gratitude	\N	f	f	2026-09-05 19:53:35.380044
184	m1qgKExs2BY	c4	@MasterCreaterop	\N	f	f	f	Councelling ke wakt ke documents alag batana aur admission ke wakt required alag batana ek hi video mai (Congrats councelling wala video badhia chal rha hai)	Councelling ke wakt ke documents alag batana aur admission ke wakt required alag batana ek hi video mai (Congrats councelling wala video badhia chal rha hai)	0	0	c1	1	2024-05-16 00:00:00	2024-05-16 00:00:00	neutral	query	documents	t	f	2026-09-05 19:53:35.380044
185	m1qgKExs2BY	c5	@YatharthSachdeva23	\N	t	f	f	i think you are getting confuse see, counselling me bahut saare rounds hote hai aur fir seat allot hone ke baad aapko documents verify karwane hote hai ek hi baar aapko document dikhane hai do baari alag alag koi documents nahi dene hote ...Read more	i think you are getting confuse see, counselling me bahut saare rounds hote hai aur fir seat allot hone ke baad aapko documents verify karwane hote hai ek hi baar aapko document dikhane hai do baari alag alag koi documents nahi dene hote ...Read more	0	0	c1	1	2024-05-16 00:00:00	2024-05-16 00:00:00	neutral	creator_reply	\N	f	f	2026-09-05 19:53:35.380044
186	m1qgKExs2BY	c6	@MasterCreaterop	\N	f	f	f	@YatharthSachdeva23 nhi matla college jane ke bad physical verification ke wakt medical certificate wagare lgta hai jo councelling mai nhi lgta	@YatharthSachdeva23 nhi matla college jane ke bad physical verification ke wakt medical certificate wagare lgta hai jo councelling mai nhi lgta	0	0	c1	1	2024-05-16 00:00:00	2024-05-16 00:00:00	neutral	query	documents	t	f	2026-09-05 19:53:35.380044
187	m1qgKExs2BY	c7	@MasterCreaterop	\N	f	f	f	@YatharthSachdeva23 waise hi suk konse hai	@YatharthSachdeva23 waise hi suk konse hai	0	0	c1	1	2024-05-16 00:00:00	2024-05-16 00:00:00	neutral	query	general	f	f	2026-09-05 19:53:35.380044
188	m1qgKExs2BY	c8	@YatharthSachdeva23	\N	t	f	f	don't worry, will tell everything in that video just wait few days!	don't worry, will tell everything in that video just wait few days!	0	0	c1	1	2024-05-16 00:00:00	2024-05-16 00:00:00	positive	creator_reply	\N	f	f	2026-09-05 19:53:35.380044
189	m1qgKExs2BY	c9	@MasterCreaterop	\N	f	f	f	@YatharthSachdeva23	@YatharthSachdeva23	0	0	c1	1	2024-05-16 00:00:00	2024-05-16 00:00:00	neutral	other	\N	f	f	2026-09-05 19:53:35.380044
190	m1qgKExs2BY	c10	@YatharthSachdeva23	\N	t	f	f	Portal is now open, if you want you can access admit card by link given in jee advanced website	Portal is now open, if you want you can access admit card by link given in jee advanced website	0	0	c1	1	2024-05-16 00:00:00	2024-05-16 00:00:00	positive	creator_reply	\N	t	f	2026-09-05 19:53:35.380044
191	_vTmJ79_4ho	c1	@YatharthSachdeva23	\N	t	f	f	JAC Delhi Full Procedure Video already uploaded on my Channel!\r\nDo watch it & SUBSCRIBE for more such information & content!	JAC Delhi Full Procedure Video already uploaded on my Channel! Do watch it & SUBSCRIBE for more such information & content!	0	0	\N	0	2024-05-17 00:00:00	2024-05-17 00:00:00	positive	creator_promo	\N	f	f	2026-09-05 20:12:48.727333
318	DrhZsdeBj6k	9f45e7b724608f15	@VaishnaviSharma-s4b	\N	f	f	f	Usme session 2 ka dhikha raha hai session 1 ka nahi	Usme session 2 ka dhikha raha hai session 1 ka nahi	0	0	\N	0	\N	\N	neutral	gratitude	\N	f	f	2026-09-13 00:39:55.370257
319	DrhZsdeBj6k	a4a7ebc40c199cd8	@Suhani-o6v	\N	f	f	f	See i haven't registered for attempt 2 yet is it still possible that i can change password	See i haven't registered for attempt 2 yet is it still possible that i can change password	0	0	\N	0	\N	\N	neutral	gratitude	\N	f	f	2026-09-13 00:39:55.370257
320	DrhZsdeBj6k	cac428bc94686d34	@xronexff777	\N	f	f	f	Thanks bhai \nI was too sad but you helped me a lot	Thanks bhai \nI was too sad but you helped me a lot	0	0	\N	0	\N	\N	neutral	question	general	t	f	2026-09-13 00:39:55.370257
196	dudb29Xqo60	c1	\N	\N	f	f	f	Bhaii iske bred pakore Khai the sirf lg rha tha bread m aloo daal k tal dia . Chole bhature k review de	\N	0	0	\N	0	2024-05-19 00:00:00	\N	neutral	food_request	\N	f	f	2026-09-06 08:53:13.551357
197	dudb29Xqo60	c2	\N	\N	f	f	f	Do you want a full food review video of this new cafe??	\N	0	0	\N	0	2024-05-19 00:00:00	\N	positive	engagement	\N	f	f	2026-09-06 08:53:13.551357
198	dudb29Xqo60	c3	\N	\N	f	f	f	Bhaii y thoda purana hain	\N	0	0	\N	0	2024-05-19 00:00:00	\N	neutral	observation	\N	f	f	2026-09-06 08:53:13.551357
199	9jXcNZyYza8	c1	@MasterCreaterop	\N	f	f	f	Bhai documents wala video dal do	Bhai documents wala video dal do	0	0	\N	0	2024-05-20 00:00:00	2024-05-20 00:00:00	neutral	query	documents	t	f	2026-09-06 09:14:07.3586
202	iLZVyccaTJs	comment_63_1	\N	\N	f	f	f	211391 rank h general m delhi \nNot any other category .	\N	0	0	\N	0	\N	\N	\N	\N	\N	f	f	2026-09-06 13:51:03.028232
203	iLZVyccaTJs	comment_63_2	\N	\N	f	f	f	96056 rank hai mains mai	\N	0	0	\N	0	\N	\N	\N	\N	\N	f	f	2026-09-06 13:51:03.028232
334	QnjyscmnjEQ	10490be0a7b1fad7	@24rage	\N	f	f	f	Bhaiye mene withdrwal kerliya but mere ko koi mail wagehra kuch ni aya or ajj dikhara hai kay apko spot round me participate kerna hai?	Bhaiye mene withdrwal kerliya but mere ko koi mail wagehra kuch ni aya or ajj dikhara hai kay apko spot round me participate kerna hai?	0	0	\N	0	\N	\N	neutral	question	general	t	f	2026-09-13 01:04:42.898173
215	YaAKtkecoRc	a1b2c3d4e5f6g7h8	Student123	UC123456789	f	f	f	Thanks for the update! 🙏	Thanks for the update!	5	0	\N	0	2024-06-04 11:00:00	2024-06-04 11:00:00	positive	gratitude	\N	f	f	2026-09-08 11:27:20.802552
216	YaAKtkecoRc	b2c3d4e5f6g7h8i9	NEETAspirant	UC987654321	f	f	f	What was the cutoff for AIIMS Delhi?	What was the cutoff for AIIMS Delhi?	12	0	\N	0	2024-06-04 11:30:00	2024-06-04 11:30:00	neutral	query	cutoff	t	f	2026-09-08 11:27:20.802552
217	YaAKtkecoRc	c3d4e5f6g7h8i9j0	Medico	UC111222333	f	t	t	Great job! 🎉	Great job!	25	0	\N	0	2024-06-04 12:00:00	2024-06-04 12:00:00	positive	gratitude	\N	f	f	2026-09-08 11:27:20.802552
218	YaAKtkecoRc	d4e5f6g7h8i9j0k1	FutureDoc	UC444555666	f	f	f	When will counselling start?	When will counselling start?	8	0	\N	0	2024-06-04 13:00:00	2024-06-04 13:00:00	neutral	query	counselling	t	f	2026-09-08 11:27:20.802552
219	YaAKtkecoRc	e5f6g7h8i9j0k1l2	RankPredictor	UC777888999	f	f	f	My score is 680, what are my chances?	My score is 680, what are my chances?	3	0	\N	0	2024-06-04 14:00:00	2024-06-04 14:00:00	neutral	query	college_prediction	t	f	2026-09-08 11:27:20.802552
220	YaAKtkecoRc	f6g7h8i9j0k1l2m3	Parent123	UC000111222	f	f	f	Thanks for the quick update!	Thanks for the quick update!	2	0	\N	0	2024-06-04 15:00:00	2024-06-04 15:00:00	positive	gratitude	\N	f	f	2026-09-08 11:27:20.802552
221	YaAKtkecoRc	g7h8i9j0k1l2m3n4	Aspirant2024	UC333444555	f	f	f	Is there any change in reservation?	Is there any change in reservation?	1	0	\N	0	2024-06-04 16:00:00	2024-06-04 16:00:00	neutral	query	reservation	t	f	2026-09-08 11:27:20.802552
222	YaAKtkecoRc	h8i9j0k1l2m3n4o5	Topper	UC666777888	f	f	f	Spam link removed	Spam link removed	0	0	\N	0	2024-06-04 17:00:00	2024-06-04 17:00:00	negative	spam	\N	f	t	2026-09-08 11:27:20.802552
296	rrTB_XW3pWA	87acc5f7ed60bc1c	@priyanshkhetarpal5943	\N	f	f	f	How to check filled choices	How to check filled choices	0	0	\N	0	\N	\N	neutral	gratitude	\N	f	f	2026-09-12 23:25:09.52654
297	rrTB_XW3pWA	7bbeb3053a7981df	@YatharthSachdeva23	\N	f	f	f	RESULTS ARE OUT!!\nGo check your result!	RESULTS ARE OUT!!\nGo check your result!	0	0	\N	0	\N	\N	neutral	gratitude	\N	f	f	2026-09-12 23:25:09.52654
226	Mp1WHa-CXfw	0af0f501127a4570	Yatharth Sachdeva	UChUmZA1_42nfmA_mNiuLlBg	t	t	f	FULL SCHEDULE & BROCHURE RELEASED!! | JOSSA 2024	FULL SCHEDULE & BROCHURE RELEASED!! | JOSSA 2024	15	3	\N	0	2024-06-05 00:00:00	2024-06-05 00:00:00	positive	informational	schedule_info	t	f	2026-09-09 14:55:59.402702
227	Mp1WHa-CXfw	a1b2c3d4e5f6g7h8	ShantalaN	UC123456789	f	f	f	Bro, I belongs to obc ncl category nd my crl ranking in jee mains is 292638.\nI didn't cleared the cut off of those clg's taking part in josaa by this rank. \nCan u plz say the clg that I can get for this rank. \nPlz bro.	Bro, I belongs to obc ncl category nd my crl ranking in jee mains is 292638. I didn't cleared the cut off of those clg's taking part in josaa by this rank. Can u plz say the clg that I can get for this rank. Plz bro.	8	2	\N	0	2024-06-05 10:00:00	2024-06-05 10:00:00	neutral	query	college_prediction	t	f	2026-09-09 14:55:59.402702
228	Mp1WHa-CXfw	b2c3d4e5f6g7h8i9	ShantalaN	UC123456789	f	f	f	This link is not opening bro	This link is not opening bro	3	1	a1b2c3d4e5f6g7h8	1	2024-06-05 11:00:00	2024-06-05 11:00:00	neutral	query	link_issue	t	f	2026-09-09 14:55:59.402702
229	Mp1WHa-CXfw	c3d4e5f6g7h8i9j0	ShantalaN	UC123456789	f	f	f	This link is not opening bro	This link is not opening bro	2	0	a1b2c3d4e5f6g7h8	1	2024-06-05 11:30:00	2024-06-05 11:30:00	neutral	query	link_issue	t	f	2026-09-09 14:55:59.402702
335	QnjyscmnjEQ	f052b63352e1be1f	@mr.memertheinfinityshonen6219	\N	f	f	f	1 mait ki site me documents required me pan card likha ha kya wo compulsory ha qki videos me btaya ki optional ha\n2 academic fees receipt of 40 000 , ye fees kaha deni ha ?	1 mait ki site me documents required me pan card likha ha kya wo compulsory ha qki videos me btaya ki optional ha\n2 academic fees receipt of 40 000 , ye fees kaha deni ha ?	0	0	\N	0	\N	\N	neutral	question	general	t	f	2026-09-13 01:04:42.898173
336	QnjyscmnjEQ	d115d1a9a1555366	@dhruvchetiwal	\N	f	f	f	Bhaiya mait mein cst kesi branch h sahi h ya nhi pls tell me I don't see data of placement cse vs cst same h ya nhi placement mein koi dikkat toh nhi aaegi	Bhaiya mait mein cst kesi branch h sahi h ya nhi pls tell me I don't see data of placement cse vs cst same h ya nhi placement mein koi dikkat toh nhi aaegi	0	0	\N	0	\N	\N	neutral	gratitude	\N	f	f	2026-09-13 01:04:42.898173
337	QnjyscmnjEQ	6bc780b43bc8aef1	@14futball	\N	f	f	f	thanks	thanks	0	0	\N	0	\N	\N	neutral	gratitude	\N	f	f	2026-09-13 01:04:42.898173
338	QnjyscmnjEQ	b88ca7f32163f01f	@YouTuber-uj4sy	\N	f	f	f	3.68 lakh rank IT shift 1 adgitm  thank you Bhaiya	3.68 lakh rank IT shift 1 adgitm  thank you Bhaiya	0	0	\N	0	\N	\N	neutral	gratitude	\N	f	f	2026-09-13 01:04:42.898173
343	j7xmoRH2rzo	45dc67e66f1498ea	@TanishkaSoni-i8l	\N	f	f	f	Bhaiya obcncl girl outside Delhi ke liye kitni percentile required hai for cse in dtu	Bhaiya obcncl girl outside Delhi ke liye kitni percentile required hai for cse in dtu	0	0	\N	0	\N	\N	neutral	gratitude	\N	f	f	2026-09-13 08:04:48.235092
239	D4KiNRb7UTk	a1b2c3d4	Author1	UC...	f	t	f	Great breakdown! Thanks for sharing this info.	Great breakdown! Thanks for sharing this info.	15	2	\N	0	2024-05-23 10:30:00	2024-05-23 10:30:00	positive	gratitude	\N	f	f	2026-09-09 16:51:44.575471
240	D4KiNRb7UTk	e5f6g7h8	Author2	UC...	f	f	t	Neet 2024 results reply	Neet 2024 results reply	8	1	\N	0	2024-05-23 11:15:00	2024-05-23 11:15:00	positive	query	re_exam	t	f	2026-09-09 16:51:44.575471
246	Pnh6g6K9y8Q	comment_1	\N	\N	f	f	f	Great motivation! 🙏	\N	0	0	\N	0	2024-06-15 10:30:00	\N	positive	\N	\N	f	f	2026-09-10 17:22:57.565114
247	Pnh6g6K9y8Q	comment_2	\N	\N	f	f	f	Thanks for this! #jeeadvanced	\N	0	0	\N	0	2024-06-15 11:15:00	\N	positive	\N	\N	f	f	2026-09-10 17:22:57.565114
248	Pnh6g6K9y8Q	comment_3	\N	\N	f	f	f	Very helpful before my exam	\N	0	0	\N	0	2024-06-15 12:00:00	\N	positive	\N	\N	f	f	2026-09-10 17:22:57.565114
249	Pnh6g6K9y8Q	comment_4	\N	\N	f	f	f	Not useful	\N	0	0	\N	0	2024-06-15 13:00:00	\N	negative	\N	\N	f	f	2026-09-10 17:22:57.565114
250	Pnh6g6K9y8Q	comment_5	\N	\N	f	f	f	Need more!	\N	0	0	\N	0	2024-06-15 14:00:00	\N	positive	\N	\N	f	f	2026-09-10 17:22:57.565114
251	DNIHqPqY3VM	comment_dummy_001	Test User	UC00000000000000000	f	f	f	Great content!	Great content!	0	0	\N	0	\N	\N	neutral	related	\N	f	f	2026-09-10 18:32:28.286194
252	Mkx7Qp8nCys	comment_75_001	Test User	UC_test_channel	f	f	f	Great short!	Great short!	2	0	\N	0	\N	\N	positive	related	\N	f	f	2026-09-10 18:44:13.592751
253	a6DGQWZ57EE	comment_76_001	JEE Aspirant	UC_example	f	f	f	Great video! Very helpful for my JEE prep.	Great video! Very helpful for my JEE prep.	5	2	\N	0	\N	\N	positive	related	none	t	f	2026-09-10 19:33:03.635723
254	_6qJfWvvWJo	comment_dummy_001	Viewers		f	f	f	Good info	Good info	0	0		0	\N	\N	neutral	gratitude	\N	f	f	2026-09-10 20:01:40.055997
255	mK2nGGZFRVI	6cd12a5a1c6e8a5e	@RatneshkumarJha-c3d		f	f	f	Can not lock my choice	Can not lock my choice	0	0	\N	0	\N	\N	neutral	question	choice_filling	t	f	2026-09-11 10:53:51.650803
256	mK2nGGZFRVI	ad93e713b8b7d1a5	@inshotshorts2445		f	f	f	Nd also tell me my best preference list..	Nd also tell me my best preference list..	0	0	\N	0	\N	\N	neutral	question	preference_list	f	f	2026-09-11 10:53:51.650803
257	mK2nGGZFRVI	41d24b2a78922006	@inshotshorts2445		f	f	f	My crl is 283502 nd i want cse in gov.. college	My crl is 283502 nd i want cse in gov.. college	0	0	\N	0	\N	\N	neutral	question	college_choice	f	f	2026-09-11 10:53:51.650803
258	mK2nGGZFRVI	639d9ea8caa02eed	@inshotshorts2445		f	f	f	Want help in choice filling of aktu counselling	Want help in choice filling of aktu counselling	0	0	\N	0	\N	\N	neutral	question	choice_filling	t	f	2026-09-11 10:53:51.650803
263	A2U9omXQ2go	6cd12a5a1c6e8a5e	@RatneshkumarJha-c3d		f	f	f	Can not lock my choice	Can not lock my choice	0	0	\N	0	\N	\N	neutral	question	choice_filling	t	f	2026-09-11 13:05:32.12302
264	A2U9omXQ2go	ad93e713b8b7d1a5	@inshotshorts2445		f	f	f	Nd also tell me my best preference list..	Nd also tell me my best preference list..	0	0	\N	0	\N	\N	neutral	question	preference_list	f	f	2026-09-11 13:05:32.12302
265	A2U9omXQ2go	41d24b2a78922006	@inshotshorts2445		f	f	f	My crl is 283502 nd i want cse in gov.. college	My crl is 283502 nd i want cse in gov.. college	0	0	\N	0	\N	\N	neutral	question	college_choice	f	f	2026-09-11 13:05:32.12302
266	A2U9omXQ2go	639d9ea8caa02eed	@inshotshorts2445		f	f	f	Want help in choice filling of aktu counselling	Want help in choice filling of aktu counselling	0	0	\N	0	\N	\N	neutral	question	choice_filling	t	f	2026-09-11 13:05:32.12302
326	3JdwNxhgqN8	11dfe17aa5f6ebce	@GyandeepBorah-su2ee	\N	f	f	f	Bhai dtu me assam ke students hai ?	Bhai dtu me assam ke students hai ?	0	0	\N	0	\N	\N	neutral	question	general	t	f	2026-09-13 00:48:04.423667
268	pbU_sJKSfrg	2a54e6213a7965c1	@YatharthSachdeva23	\N	f	f	f	IPU counselling: https://ipu.admissions.nic.in/\n\nDeadline: 1/7/24 2:00 PM\n\nWe will be doing many live streams in which i will tell you, the best college and branch option for you according to your rank!\n\nSo, SUBSCRIBE the channel and stay tuned!\nDon't miss any video/shorts of this channel \nAll IMPORTANT will be notified to you by Shorts\nDo join the LIVE to solve your queries!!	IPU counselling: https://ipu.admissions.nic.in/\n\nDeadline: 1/7/24 2:00 PM\n\nWe will be doing many live streams in which i will tell you, the best college and branch option for you according to your rank!\n\nSo, SUBSCRIBE the channel and stay tuned!\nDon't miss any video/shorts of this channel \nAll IMPORTANT will be notified to you by Shorts\nDo join the LIVE to solve your queries!!	0	0	\N	0	\N	\N	neutral	gratitude	\N	f	f	2026-09-11 16:20:34.478996
269	W1nCo6y71R8	4367bf1a36f2ee80	@prachigupta5390	\N	f	f	f	USICT BTech CSE  or DU BTech CSE or JMI BTech CSE.... what to choose ?	USICT BTech CSE  or DU BTech CSE or JMI BTech CSE.... what to choose ?	0	0	\N	0	\N	\N	neutral	question	general	t	f	2026-09-11 16:35:53.569939
327	3JdwNxhgqN8	9c01c181c180415a	@devenderyadav5344	\N	f	f	f	Nsut west campus ka orientation kab hai	Nsut west campus ka orientation kab hai	0	0	\N	0	\N	\N	neutral	gratitude	\N	f	f	2026-09-13 00:48:04.423667
273	w2UTdzsuads	ea942225254cbc25	@sanatanshortsbhind	\N	f	f	f	Mic  kon sa h bhai	Mic  kon sa h bhai	0	0	\N	0	\N	\N	neutral	gratitude	\N	f	f	2026-09-11 16:35:54.958145
274	w2UTdzsuads	8fa4c959f13401ca	@yashwantborde4620	\N	f	f	f	Illuminati	Illuminati	0	0	\N	0	\N	\N	neutral	gratitude	\N	f	f	2026-09-11 16:35:54.958145
328	3JdwNxhgqN8	97f7124ce22535ef	@devenderyadav5344	\N	f	f	f	Nsut west campus ki classes kb se start hogi kuch idea hai aap ko ?	Nsut west campus ki classes kb se start hogi kuch idea hai aap ko ?	0	0	\N	0	\N	\N	neutral	question	general	t	f	2026-09-13 00:48:04.423667
283	fsSkI-1Opvk	16908bae68872fca	@Sosopoof	\N	f	f	f	Bc kuch mila he nhi .. ab next round ka wait krna padega	Bc kuch mila he nhi .. ab next round ka wait krna padega	0	0	\N	0	\N	\N	neutral	gratitude	\N	f	f	2026-09-11 22:58:05.388618
284	xj4emmUcJGE	32e37170353ea3af	@RishikaGupta-k2h	\N	f	f	f	Iski pdf kha milegi	Iski pdf kha milegi	0	0	\N	0	\N	\N	neutral	gratitude	\N	f	f	2026-09-11 22:58:07.287609
285	SOKrC7BJ418	52de0fee74aa7604	@rishuharsha	\N	f	f	f	Other states ka toh btaya hi nhi bhaiya	Other states ka toh btaya hi nhi bhaiya	0	0	\N	0	\N	\N	neutral	gratitude	\N	f	f	2026-09-11 22:58:07.871575
344	4yAeMwjZxoo	e797e27c07c4f273	@AstrologerAanchal	\N	f	f	f	Sahi tha ye	Sahi tha ye	0	0	\N	0	\N	\N	neutral	gratitude	\N	f	f	2026-09-13 08:12:31.899566
\.


--
-- Data for Name: memory_updates; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.memory_updates (id, video_id, update_type, title, payload, source_analysis, priority, applied_to_pipeline, applied_at, created_at) FROM stdin;
1	5goNjmztwqg	pattern_discovery	High Channel Pages Traffic Pattern	{"percentage": 51.2, "implication": "Series content drives channel page discovery", "typical_range": "15-25%", "traffic_source": "channel_pages"}	First short (Part-1) shows 51.2% Channel pages traffic vs typical 15-25% for Shorts, indicating subscribers/channel visitors are primary discovery path for series content	7	f	\N	2026-08-31 21:48:53.153971
2	5goNjmztwqg	pattern_discovery	High Channel Pages Traffic Pattern	{"percentage": 51.2, "implication": "Series content drives channel page discovery", "typical_range": "15-25%", "traffic_source": "channel_pages"}	First short (Part-1) shows 51.2% Channel pages traffic vs typical 15-25% for Shorts, indicating subscribers/channel visitors are primary discovery path for series content	7	f	\N	2026-08-31 22:40:13.429451
184	wnp9gFm7ZpY	short_forensic	Forensic analysis of Short #79	{"patterns": [], "short_id": 79}	youtube_studio_cdp	3	f	\N	2026-09-12 21:46:22.459929
4	\N	test	test	{"test": true}	test	1	f	\N	2026-08-31 22:48:41.521487
5	\N	test	test	{"test": true}	test	1	f	\N	2026-08-31 22:49:05.565986
6	5goNjmztwqg	pattern_discovery	High Channel Pages Traffic Pattern	{"percentage": 51.2, "implication": "Series content drives channel page discovery", "typical_range": "15-25%", "traffic_source": "channel_pages"}	First short (Part-1) shows 51.2% Channel pages traffic vs typical 15-25% for Shorts, indicating subscribers/channel visitors are primary discovery path for series content	7	f	\N	2026-08-31 22:53:13.887132
7	5goNjmztwqg	pattern_discovery	High Channel Pages Traffic Pattern	{"percentage": 51.2, "implication": "Series content drives channel page discovery", "typical_range": "15-25%", "traffic_source": "channel_pages"}	First short (Part-1) shows 51.2% Channel pages traffic vs typical 15-25% for Shorts, indicating subscribers/channel visitors are primary discovery path for series content	7	f	\N	2026-08-31 22:54:52.036978
12	0jstRcQmAro	pattern_discovery	Series Channel Pages Traffic Pattern	{"percentage": 33.3, "implication": "Series content drives channel page discovery, decreasing across parts", "typical_range": "15-25%", "traffic_source": "channel_pages", "part1_percentage": 51.2}	Part-2 shows 33.3% Channel pages traffic vs Part-1's 51.2%, both above typical 15-25% for Shorts. Series format with cross-linking in description drives channel page traffic that decreases per part.	7	f	\N	2026-09-01 08:45:25.36398
14	XWFbqR_9fqc	pattern	Series parts need independent SEO	{"pattern": "series_parts_need_independent_seo", "evidence": "Part 3: 68.8% channel pages, 0% search"}	Short #3 forensic analysis	1	f	\N	2026-09-01 09:19:49.888536
15	Pwp0zPAY6Y4	pattern	Series parts need independent SEO and correct hashtags	{"pattern": "series_parts_need_independent_seo", "evidence": "Part 4: 47.8% channel pages, 34.8% Shorts feed, 0% search, hashtags wrong (#part1)"}	Short #4 forensic analysis	1	f	\N	2026-09-01 09:29:40.491408
16	s_PoEssiuPo	pattern	Series finale gets search but low retention	{"pattern": "series_finale_gets_search_but_low_retention", "evidence": "Part 5: 55.9% search, 50.8% retention, 34.5% completion, loyal viewer @neer4090"}	Short #5 forensic analysis	1	f	\N	2026-09-01 09:42:27.379694
17	UTeogxHwnPw	pattern	SHORT #6 FULL ANALYSIS	{"video_id": "UTeogxHwnPw"}	forensic_analysis	3	f	\N	2026-09-02 09:25:12.01273
18	UTeogxHwnPw	pattern	SHORT #6 FULL ANALYSIS	{"video_id": "UTeogxHwnPw"}	forensic_analysis	3	f	\N	2026-09-02 09:25:42.138615
19	zdOSsbqouKE	pattern	SHORT #7 FULL ANALYSIS	{"video_id": "zdOSsbqouKE"}	forensic_analysis	3	f	\N	2026-09-02 09:25:43.634893
20	12BKLbv0Eso	pattern	SHORT #8 FULL ANALYSIS	{"video_id": "12BKLbv0Eso"}	forensic_analysis	3	f	\N	2026-09-02 09:25:45.151529
21	XM1AzgVMeqk	pattern	SHORT #9 FULL ANALYSIS	{"video_id": "XM1AzgVMeqk"}	forensic_analysis	3	f	\N	2026-09-02 09:25:46.312192
22	nJNR60Ms1BE	pattern	SHORT #10 FULL ANALYSIS	{"video_id": "nJNR60Ms1BE"}	forensic_analysis	3	f	\N	2026-09-02 09:25:47.152763
23	_A5Idj7SddI	pattern	SHORT #11 FULL ANALYSIS	{"video_id": "_A5Idj7SddI"}	forensic_analysis	3	f	\N	2026-09-02 09:25:47.534266
24	BJ5lJob_sDU	pattern	SHORT #12 FULL ANALYSIS	{"video_id": "BJ5lJob_sDU"}	forensic_analysis	3	f	\N	2026-09-02 09:25:47.870198
25	5goNjmztwqg	pattern_discovery	High Channel Pages Traffic Pattern	{"percentage": 51.2, "implication": "Series content drives channel page discovery", "typical_range": "15-25%", "traffic_source": "channel_pages"}	First short (Part-1) shows 51.2% Channel pages traffic vs typical 15-25% for Shorts, indicating subscribers/channel visitors are primary discovery path for series content	7	f	\N	2026-09-02 09:40:09.083548
26	0jstRcQmAro	pattern_discovery	Series Channel Pages Traffic Pattern	{"percentage": 33.3, "implication": "Series content drives channel page discovery, decreasing across parts", "typical_range": "15-25%", "traffic_source": "channel_pages", "part1_percentage": 51.2}	Part-2 shows 33.3% Channel pages traffic vs Part-1's 51.2%, both above typical 15-25% for Shorts. Series format with cross-linking in description drives channel page traffic that decreases per part.	7	f	\N	2026-09-02 09:40:19.385772
27	0jstRcQmAro	pattern_discovery	Series Channel Pages Traffic Pattern	{"percentage": 33.3, "implication": "Series content drives channel page discovery, decreasing across parts", "typical_range": "15-25%", "traffic_source": "channel_pages", "part1_percentage": 51.2}	Part-2 shows 33.3% Channel pages traffic vs Part-1's 51.2%, both above typical 15-25% for Shorts. Series format with cross-linking in description drives channel page traffic that decreases per part.	7	f	\N	2026-09-02 09:41:27.111276
28	5goNjmztwqg	pattern_discovery	High Channel Pages Traffic Pattern	{"percentage": 51.2, "implication": "Series content drives channel page discovery", "typical_range": "15-25%", "traffic_source": "channel_pages"}	First short (Part-1) shows 51.2% Channel pages traffic vs typical 15-25% for Shorts, indicating subscribers/channel visitors are primary discovery path for series content	7	f	\N	2026-09-02 09:45:39.987643
29	0jstRcQmAro	pattern_discovery	Series Channel Pages Traffic Pattern	{"percentage": 33.3, "implication": "Series content drives channel page discovery, decreasing across parts", "typical_range": "15-25%", "traffic_source": "channel_pages", "part1_percentage": 51.2}	Part-2 shows 33.3% Channel pages traffic vs Part-1's 51.2%, both above typical 15-25% for Shorts. Series format with cross-linking in description drives channel page traffic that decreases per part.	7	f	\N	2026-09-02 09:46:02.751285
30	XWFbqR_9fqc	pattern	Series parts need independent SEO	{"pattern": "series_parts_need_independent_seo", "evidence": "Part 3: 68.8% channel pages, 0% search"}	Short #3 forensic analysis	1	f	\N	2026-09-02 10:02:53.957789
31	Pwp0zPAY6Y4	pattern	Series parts need independent SEO and correct hashtags	{"pattern": "series_parts_need_independent_seo", "evidence": "Part 4: 47.8% channel pages, 34.8% Shorts feed, 0% search, hashtags wrong (#part1)"}	Short #4 forensic analysis	1	f	\N	2026-09-02 10:03:13.106027
32	s_PoEssiuPo	pattern	Series finale gets search but low retention	{"pattern": "series_finale_gets_search_but_low_retention", "evidence": "Part 5: 55.9% search, 50.8% retention, 34.5% completion, loyal viewer @neer4090"}	Short #5 forensic analysis	1	f	\N	2026-09-02 10:03:18.329293
33	OkWbChCIb04	pattern	SHORT #13 FULL FORENSIC ANALYSIS	{"video_id": "OkWbChCIb04", "content_type": "breaking_news", "retention_pct": 24.2}	forensic_analysis	3	f	\N	2026-09-02 10:43:00.55935
34	2jcdStwq2yY	pattern	SHORT #14 FULL FORENSIC ANALYSIS	{"note": "Highest retention in dataset - 88.5%", "video_id": "2jcdStwq2yY", "content_type": "breaking_news", "retention_pct": 88.5}	forensic_analysis	2	f	\N	2026-09-02 11:05:19.259322
35	2jcdStwq2yY	pattern	SHORT #14 FULL FORENSIC ANALYSIS	{"note": "Highest retention in dataset - 88.5%", "video_id": "2jcdStwq2yY", "content_type": "breaking_news", "retention_pct": 88.5}	forensic_analysis	2	f	\N	2026-09-02 11:22:03.546173
36	yDKB-xCaMB8	pattern_discovery	High Search Traffic for Opportunity Alert Short	{"percentage": 58.1, "implication": "Time-sensitive opportunity alerts drive search discovery", "typical_range": "15-25%", "traffic_source": "youtube_search"}	Short #15 (yDKB-xCaMB8) shows 58.1% YouTube search traffic vs typical 15-25% for Shorts, indicating urgent opportunity/alert content gets discovered via search when students actively look for deadline extensions	7	f	\N	2026-09-02 14:30:31.576863
37	rg5iPj-249o	pattern_discovery	Shorts Feed Dominance for Schedule Alert	{"percentage": 59.3, "implication": "Election-driven schedule alerts get pushed by Shorts algorithm to broad audience", "typical_range": "15-25%", "traffic_source": "shorts_feed"}	Short #16 (rg5iPj-249o) shows 59.3% Shorts feed traffic vs typical 15-25%, indicating algorithm pushes election-related schedule uncertainty content broadly. Search traffic only 23.1% despite high relevance.	7	f	\N	2026-09-02 14:58:55.032747
38	waW201cvfl8	pattern_discovery	Campus Event Trailer - High Retention, Low Search	{"retention": 49.8, "percentage": 57.1, "search_pct": 20.0, "implication": "Campus lifestyle content gets algorithm push but low search intent", "traffic_source": "shorts_feed"}	Short #17 (waW201cvfl8) shows 49.8% retention (highest so far for non-educational), 57.1% Shorts feed, only 20% search. Event trailer content retains well but doesn't drive search.	6	f	\N	2026-09-02 15:14:09.210888
39	Ay9K30yrg8Y	pattern_discovery	Shorts Feed Algorithm Dominance for Uncertainty Content	{"percentage": 88.2, "search_pct": 7.1, "implication": "Uncertainty resolution content gets massive algorithm push but low search intent", "typical_range": "15-25%", "traffic_source": "shorts_feed"}	Short #18 (Ay9K30yrg8Y) shows 88.2% Shorts feed traffic (highest ever seen) vs only 7.1% search. Algorithm pushes uncertainty/confusion-resolution content broadly, but viewers don't search for it. 92.7% male, 81.6% India, 70.5% age 18-24.	8	f	\N	2026-09-02 15:27:50.633383
40	lmbndk-Db-Q	pattern_discovery	City Intimation Release - Extreme Shorts Feed Dominance	{"retention": 32.0, "percentage": 89.1, "search_pct": 4.8, "implication": "Official document/city intimation releases get massive algorithm push but very low search", "typical_range": "15-25%", "traffic_source": "shorts_feed"}	Short #19 (lmbndk-Db-Q) shows 89.1% Shorts feed traffic (highest ever), only 4.8% search. 100% male, 100% age 18-24, 89.8% India, 88.4% non-subscribers. Official releases get algorithm push but viewers don't search for them.	8	f	\N	2026-09-02 21:49:28.223132
41	cSapjDf5CHY	pattern_discovery	Admit Card Release - High Shorts Feed + Search Mix	{"retention": 37.7, "percentage": 83.5, "search_pct": 11.4, "implication": "Admit card releases get massive algorithm push AND significant search traffic", "subs_gained": 3, "traffic_source": "shorts_feed"}	Short #20 (cSapjDf5CHY) shows 83.5% Shorts feed + 11.4% search (admit card terms). +3 subs gained. 100% age 18-24, 87.5% male, 82.5% India. Creator posted admit card link as comment. High retention (37.7%) for 31s video.	8	f	\N	2026-09-02 23:46:30.338612
42	JmSdjrAxNFM	pattern	SHORT #21 FULL ANALYSIS	{"title": "DO THIS in LAST 3 Days | JEE MAINS 2024", "views": 122, "feed_pct": 81.2, "subs_pct": 15.2, "video_id": "JmSdjrAxNFM", "india_pct": 84.4, "retention": 23.7, "mobile_pct": 76.5, "search_pct": 9.8, "avd_seconds": 11, "subs_gained": 0, "content_type": "exam_tips", "completion_pct": 22.0, "swipe_away_pct": 76.3, "search_terms_noise": ["class 8 math", "how to decrease thigh fat for men", "ssc gd answer key 2024 kab aayega"], "subtitles_none_pct": 93.4, "search_terms_relevant": ["jee in 3 days", "pyq 2024 eduniti"]}	forensic_analysis	3	f	\N	2026-09-03 08:43:48.484092
43	MpQ-K2D9Ao4	pattern	SHORT #22 FULL ANALYSIS	{"title": "92%ile can also get into IIT | Jee Advanced 2024", "views": 539, "feed_pct": 72.9, "subs_pct": 5.5, "video_id": "MpQ-K2D9Ao4", "india_pct": 80.2, "retention": 41.5, "mobile_pct": 87.2, "search_pct": 21.7, "avd_seconds": 16, "subs_gained": 2, "content_type": "motivation", "completion_pct": 28.6, "swipe_away_pct": 58.5, "related_video_id": "ZpSpypF1E38", "search_terms_noise": ["dhruv rathee trolled"], "subtitles_none_pct": 97.4, "description_has_link": true, "search_terms_relevant": ["92 percentile to iit", "80 percentile to iit", "92 percentile in jee mains", "95 percentile to iit"]}	forensic_analysis	3	f	\N	2026-09-03 08:46:53.14088
44	bXetyvX2Mu8	pattern	SHORT #23 FULL ANALYSIS	{"title": "DO THIS AFTER JEE MAINS APRIL ATTEMPT", "views": 395, "feed_pct": 78.0, "subs_pct": 5.9, "video_id": "bXetyvX2Mu8", "india_pct": 82.5, "retention": 27.3, "mobile_pct": 92.4, "search_pct": 9.6, "avd_seconds": 16, "subs_gained": 0, "content_type": "strategy", "completion_pct": 26.7, "swipe_away_pct": 72.7, "search_terms_noise": ["champions trophy 2017 final", "dhruv rathee", "gaurav yaduvanshi accident"], "subtitles_none_pct": 98.0, "description_has_link": true, "search_terms_relevant": ["iit bombay campus tour", "iit vs mit"]}	forensic_analysis	3	f	\N	2026-09-03 08:49:33.548839
45	pHfj5VVN0Ew	pattern	SHORT #24 FULL ANALYSIS	{"title": "RESULT UPDATE for JEE Mains April | Jee Advanced Update Also", "views": 310, "feed_pct": 87.1, "subs_pct": 9.8, "video_id": "pHfj5VVN0Ew", "india_pct": 91.9, "retention": 47.9, "mobile_pct": 94.0, "search_pct": 6.5, "avd_seconds": 17, "subs_gained": 2, "content_type": "result_update", "completion_pct": 34.7, "swipe_away_pct": 52.1, "related_video_id": "ZpSpypF1E38", "search_terms_noise": ["allah miya bhej koi roop ki tijori", "allen teacher", "chemical kinetics", "delhi status", "doon"], "subtitles_none_pct": 97.1, "description_has_link": true, "search_terms_relevant": []}	forensic_analysis	3	f	\N	2026-09-03 08:52:31.076945
185	rrTB_XW3pWA	short_forensic	Forensic analysis of Short #86	{"patterns": [], "short_id": 86}	youtube_studio_cdp	3	f	\N	2026-09-12 22:06:31.315393
46	dpTHfuBYClo	pattern	SHORT #25 FULL ANALYSIS	{"title": "PROVISIONAL ANSWER Key Out!! for April Attempt", "views": 504, "feed_pct": 75.8, "subs_pct": 3.8, "video_id": "dpTHfuBYClo", "india_pct": 90.5, "retention": 37.5, "mobile_pct": 73.9, "search_pct": 19.3, "avd_seconds": 18, "subs_gained": 0, "content_type": "result_update", "completion_pct": 31.6, "swipe_away_pct": 62.5, "related_video_id": "ZpSpypF1E38", "search_terms_noise": [], "subtitles_none_pct": 98.4, "search_terms_relevant": ["provisional answer key jee mains 2024", "provisional answer key", "jee answer key 2024 april", "jee mains provisional answer key 2024", "jee provisional answer key 2024"]}	forensic_analysis	3	f	\N	2026-09-03 08:54:48.143719
47	tO8vEcWUFXs	pattern	SHORT #52 FULL ANALYSIS	{"pattern": "DOWNLOAD IMMEDIATELY = algo poison", "video_id": "tO8vEcWUFXs", "search_quality": "100% noise (bbose, bhojpuri, instrumental)"}	forensic_analysis	3	f	\N	2026-09-05 19:35:09.745882
48	m1qgKExs2BY	pattern	SHORT #53 FULL ANALYSIS	{"pattern": "Admit card utility = high search (64%), good retention (42.7%), 0:39 optimal", "video_id": "m1qgKExs2BY", "end_screen": "Short→Long-form = 0% CTR"}	forensic_analysis	3	f	\N	2026-09-05 19:53:35.380044
49	_vTmJ79_4ho	pattern	SHORT #54 FULL ANALYSIS	{"pattern": "PASSIVE date change = 3% search, 77% feed, 20.8% ret (vs ACTIONABLE #19: 71% search, 63% ret)", "video_id": "_vTmJ79_4ho", "search_noise": "aishwarya cinderella gown = 33% of search"}	forensic_analysis	3	f	\N	2026-09-05 20:12:48.727333
186	rrTB_XW3pWA	short_forensic	Forensic analysis of Short #86	{"patterns": [], "short_id": 86}	youtube_studio_cdp	3	f	\N	2026-09-12 23:23:30.318307
189	AwJoDsJiAoQ	short_forensic	Forensic analysis of Short #93	{"patterns": [], "short_id": 93}	youtube_studio_cdp	3	f	\N	2026-09-13 00:30:05.383779
60	atkvEdcPidM	pattern	SHORT #55 FULL ANALYSIS	{"patterns": ["Search dominates at 55% - highly searchable educational content", "Red alert emoji 🔴 in title drives urgency clicks", "NEET/Supreme Court keywords = evergreen search traffic", "Zero comments despite 207 views - low engagement signal", "End screen CTR 0% vs 0.9% avg - related video not performing", "Mobile 87% - Shorts feed optimized", "India 71% geo - target audience aligned", "Subtitles: 96% none - accessibility gap", "Non-sub viewers 89% - viral reach not converting"], "short_id": 55}	forensic_analysis	3	f	\N	2026-09-06 08:41:17.107595
61	dudb29Xqo60	pattern	SHORT #56 FULL ANALYSIS	{"patterns": ["High search traffic (61.6%) for campus/food terms", "Strong retention (48.2%) for 27s lifestyle short", "WhatsApp sharing indicates word-of-mouth", "Creator engagement in comments (reply to viewer)"], "short_id": 56}	forensic_analysis	3	f	\N	2026-09-06 08:53:13.551357
62	9jXcNZyYza8	pattern	SHORT #57 FULL ANALYSIS	{"pattern": "IMPOSSIBLE PROMISE (+5K rank in 3 days) = ALGO POISON: 72 views, 27% ret, 54% India, 0 subs, 1 comment asking for utility (documents)", "video_id": "9jXcNZyYza8", "search_quality": "Single term only (jee advanced 2024), rest is noise"}	forensic_analysis	3	f	\N	2026-09-06 09:14:07.3586
64	eC_j1wlFJBw	pattern	SHORT #58 FULL ANALYSIS	{"patterns": ["Very low views (29) vs channel avg (220-360)", "High swipe-away rate (81%) despite retention spike note", "No comments despite 29 views", "India only geography data (41.4%) - limited reach", "Search terms insufficient data - algorithm not picking up keywords", "End screen 0% CTR vs 0.9% channel avg"], "short_id": 58}	forensic_analysis	3	f	\N	2026-09-06 09:30:05.833783
65	Q-IS9K8g294	pattern	SHORT #59 FULL ANALYSIS	{"patterns": ["DOWNLOAD IMMEDIATELY = algo poison", "search 100% noise", "retention spike at end"], "short_id": 59}	forensic_analysis	3	f	\N	2026-09-06 09:52:18.827983
67	p03EyeJlM-k	pattern	SHORT #60 FULL ANALYSIS	{"patterns": ["JAC/JoSAA counseling = low search intent (0% relevant terms)", "Browse 37% unusually high = YT recommending via browse not feed", "30+ hashtags = noise dilution (search shows 'naat', 'small pump')", "End-screen CTR 0% vs 0.9% avg = long-form funnel broken", "Desktop 18% = some desktop intent for counseling content"], "short_id": 60}	forensic_analysis	3	f	\N	2026-09-06 12:19:14.187832
68	229XDzxoc4g	pattern	SHORT #61 FULL ANALYSIS	{"patterns": ["high male audience (90%)", "search noise high"], "short_id": 61}	forensic_analysis	3	f	\N	2026-09-06 13:26:52.660817
69	j4CtPMW-1Q4	pattern	SHORT #62 FULL ANALYSIS	{"patterns": [], "short_id": 62}	forensic_analysis	3	f	\N	2026-09-06 13:43:57.675416
70	iLZVyccaTJs	pattern	SHORT #63 FULL ANALYSIS	{"patterns": ["search terms are noise", "male dominated audience"], "short_id": 63}	forensic_analysis	3	f	\N	2026-09-06 13:51:03.028232
71	xBun0zPGZDA	pattern	SHORT #64 FULL ANALYSIS	{"patterns": [], "short_id": 64}	forensic_analysis	3	f	\N	2026-09-06 15:05:42.270667
75	4B4aAW76GLQ	pattern	Short #65 - JAC Delhi Schedule Alert Pattern	{"india_pct": 92.3, "search_pct": 8.2, "subs_gained": 1, "content_type": "Schedule Alert", "retention_pct": 35.3}	JAC Delhi counselling alert with moderate search traffic (8.2%), low retention (35.3%), high India purity (92.3%). Schedule alerts with actionable verbs perform better than passive 'dates changed' language.	3	f	\N	2026-09-07 09:04:23.739817
80	LQ7ttolwjJQ	pattern	Short #66 - DOWNLOAD IMMEDIATELY Pattern	{"feed_pct": 85.5, "search_pct": 2.9, "subs_gained": 1, "content_type": "Schedule Alert", "retention_pct": 14.2, "has_download_phrase": true}	"DOWNLOAD THIS IMMEDIATELY" phrase = algo poison pattern. 100% feed traffic (85.5%), very low retention (14.2%), search terms are noise (cheela recipe, shila). Confirms Short #52 finding: urgency clickbait attracts feed scroll but no real engagement.	3	f	\N	2026-09-07 10:50:43.305672
81	zqqcLDVZxR8	pattern	Short #67 - Provisional Answer Key Alert	{"feed_pct": 88.9, "male_pct": 92.3, "india_pct": 92.9, "search_pct": 7.1, "subs_gained": 0, "content_type": "Result Announcement", "retention_pct": 17.3}	Provisional answer key alert with high feed (88.9%), moderate search (7.1%), high male skew (92.3%), India purity 92.9%. Specific search terms (jee advanced 2024, provisional answer key) show genuine intent. Better retention (17.3%) than DOWNLOAD IMMEDIATELY clickbait.	3	f	\N	2026-09-07 10:57:07.066385
83	YaAKtkecoRc	pattern	SHORT #68 FULL ANALYSIS	{"patterns": ["RESULT_ALERT_HIGH_FEED", "NEET_RESULT_HIGH_RETENTION"], "short_id": 68}	forensic_analysis	3	f	\N	2026-09-08 10:48:39.159712
84	YaAKtkecoRc	pattern	SHORT #68 FULL ANALYSIS	{"patterns": ["RESULT_ALERT_HIGH_FEED", "NEET_RESULT_HIGH_RETENTION"], "short_id": 68}	forensic_analysis	3	f	\N	2026-09-08 10:58:13.446835
85	YaAKtkecoRc	pattern	SHORT #68 FULL ANALYSIS	{"patterns": ["RESULT_ALERT_HIGH_FEED", "NEET_RESULT_HIGH_RETENTION"], "short_id": 68}	forensic_analysis	3	f	\N	2026-09-08 11:27:20.802552
88	Mp1WHa-CXfw	pattern	SHORT #69 FULL ANALYSIS	{"patterns": ["SCHEDULE_ANNOUNCEMENT_HIGH_FEED", "JOSSA_COUNSELLING_MODERATE_RETENTION"], "short_id": 69}	forensic_analysis	3	f	\N	2026-09-09 14:55:59.402702
187	rrTB_XW3pWA	short_forensic	Forensic analysis of Short #86	{"patterns": [], "short_id": 86}	youtube_studio_cdp	3	f	\N	2026-09-12 23:25:09.52654
190	ZrY0tM9yPxQ	short_forensic	Forensic analysis of Short #94	{"patterns": [], "short_id": 94}	youtube_studio_cdp	3	f	\N	2026-09-13 00:37:30.390512
192	ZrY0tM9yPxQ	short_forensic	Forensic analysis of Short #94	{"patterns": [], "short_id": 94}	youtube_studio_cdp	3	f	\N	2026-09-13 00:39:03.743153
93	D4KiNRb7UTk	pattern_discovery	NEET 2024 Results Short Analysis	{"views": 561, "hook_type": "news_hook", "key_findings": ["High search traffic", "Educational content performance", "Strong India audience"], "retention_pct": 42.5}	Short about NTA NEET 2024 results response shows strong educational intent with 561 views, 42.5% retention, and 68% India audience. News/hook type performs well for exam-related content.	7	f	\N	2026-09-09 16:51:44.575471
95	yBnFHlmgMFQ	short_forensic	Forensic analysis of Short #71	{}	youtube_studio_cdp	3	f	\N	2026-09-09 23:48:51.46802
200	QnjyscmnjEQ	short_forensic	Forensic analysis of Short #96	{"patterns": [], "short_id": 96}	youtube_studio_cdp	3	f	\N	2026-09-13 01:04:42.898173
99	bLwR73Y2d0w	forensic_analysis	Short #72 Forensic Analysis	{}	Full studio analysis - all 6 tabs extracted	3	f	\N	2026-09-10 10:04:13.605465
101	Pnh6g6K9y8Q	short_forensic	Forensic analysis of Short #73	{}	youtube_studio_cdp	3	f	\N	2026-09-10 17:21:45.289572
102	Pnh6g6K9y8Q	short_forensic	Forensic analysis of Short #73	{}	youtube_studio_cdp	3	f	\N	2026-09-10 17:22:57.565114
104	DNIHqPqY3VM	short_forensic	Forensic analysis of Short #74	{}	youtube_studio_cdp	3	f	\N	2026-09-10 18:30:27.604051
105	DNIHqPqY3VM	short_forensic	Forensic analysis of Short #74	{}	youtube_studio_cdp	3	f	\N	2026-09-10 18:32:28.286194
107	Mkx7Qp8nCys	short_forensic	Forensic analysis of Short #75	{}	youtube_studio_cdp	3	f	\N	2026-09-10 18:43:32.427695
108	Mkx7Qp8nCys	short_forensic	Forensic analysis of Short #75	{}	youtube_studio_cdp	3	f	\N	2026-09-10 18:44:13.592751
212	j7xmoRH2rzo	short_forensic	Forensic analysis of Short #102	{"patterns": [], "short_id": 102}	youtube_studio_cdp	3	f	\N	2026-09-13 08:04:48.235092
111	a6DGQWZ57EE	short_forensic	Forensic analysis of Short #76	{}	youtube_studio_cdp	3	f	\N	2026-09-10 19:31:27.388867
112	a6DGQWZ57EE	short_forensic	Forensic analysis of Short #76	{}	youtube_studio_cdp	3	f	\N	2026-09-10 19:33:03.635723
214	_gF2JDP64Yc	short_forensic	Forensic analysis of Short #103	{"patterns": [], "short_id": 103}	youtube_studio_cdp	3	f	\N	2026-09-13 08:06:26.943876
114	_6qJfWvvWJo	short_forensic	Forensic analysis of Short #77	{}	youtube_studio_cdp	3	f	\N	2026-09-10 19:56:28.467634
115	_6qJfWvvWJo	short_forensic	Forensic analysis of Short #77	{}	youtube_studio_cdp	3	f	\N	2026-09-10 19:59:59.887221
116	_6qJfWvvWJo	short_forensic	Forensic analysis of Short #77	{}	youtube_studio_cdp	3	f	\N	2026-09-10 20:01:40.055997
216	4yAeMwjZxoo	short_forensic	Forensic analysis of Short #100	{"patterns": [], "short_id": 100}	youtube_studio_cdp	3	f	\N	2026-09-13 08:12:31.899566
118	NVbNJeWZ1Lo	short_forensic	Forensic analysis of Short #78	{}	youtube_studio_cdp	3	f	\N	2026-09-10 20:21:07.431547
218	BMh9Xq36RrA	short_forensic	Forensic analysis of Short #104	{"patterns": [], "short_id": 104}	youtube_studio_cdp	3	f	\N	2026-09-13 08:22:34.508287
120	wnp9gFm7ZpY	short_forensic	Forensic analysis of Short #79	{}	youtube_studio_cdp	3	f	\N	2026-09-10 22:48:19.000993
122	pl90QEsoKFk	short_forensic	Forensic analysis of Short #80	{}	youtube_studio_cdp	3	f	\N	2026-09-10 23:08:11.068235
123	pl90QEsoKFk	short_forensic	Forensic analysis of Short #80	{}	youtube_studio_cdp	3	f	\N	2026-09-10 23:10:00.515414
124	3LCJCKfRATo	short_forensic	Forensic analysis of Short #81	{}	youtube_studio_cdp	3	f	\N	2026-09-10 23:30:52.664773
125	mK2nGGZFRVI	short_forensic	Forensic analysis of Short #81	{}	youtube_studio_cdp	3	f	\N	2026-09-11 10:53:51.650803
126	A2U9omXQ2go	short_forensic	Forensic analysis of Short #81	{}	youtube_studio_cdp	3	f	\N	2026-09-11 12:57:35.796334
127	A2U9omXQ2go	short_forensic	Forensic analysis of Short #81	{}	youtube_studio_cdp	3	f	\N	2026-09-11 13:05:32.12302
128	fsSkI-1Opvk	short_forensic	Forensic analysis of Short #83	{"patterns": [], "short_id": 83}	youtube_studio_cdp	3	f	\N	2026-09-11 16:20:32.995425
129	pbU_sJKSfrg	short_forensic	Forensic analysis of Short #84	{"patterns": [], "short_id": 84}	youtube_studio_cdp	3	f	\N	2026-09-11 16:20:34.478996
130	W1nCo6y71R8	short_forensic	Forensic analysis of Short #85	{"patterns": [], "short_id": 85}	youtube_studio_cdp	3	f	\N	2026-09-11 16:35:53.569939
133	xj4emmUcJGE	short_forensic	Forensic analysis of Short #88	{"patterns": [], "short_id": 88}	youtube_studio_cdp	3	f	\N	2026-09-11 16:35:54.654653
134	w2UTdzsuads	short_forensic	Forensic analysis of Short #89	{"patterns": [], "short_id": 89}	youtube_studio_cdp	3	f	\N	2026-09-11 16:35:54.958145
135	SOKrC7BJ418	short_forensic	Forensic analysis of Short #90	{"patterns": [], "short_id": 90}	youtube_studio_cdp	3	f	\N	2026-09-11 16:35:55.319378
136	PaYUzmc11E8	short_forensic	Forensic analysis of Short #91	{"patterns": [], "short_id": 91}	youtube_studio_cdp	3	f	\N	2026-09-11 16:35:55.65266
137	0KAZqj8-gFo	short_forensic	Forensic analysis of Short #92	{"patterns": [], "short_id": 92}	youtube_studio_cdp	3	f	\N	2026-09-11 16:35:55.987093
188	kbLQ0kJ7pYQ	short_forensic	Forensic analysis of Short #87	{"patterns": [], "short_id": 87}	youtube_studio_cdp	3	f	\N	2026-09-13 00:04:05.182697
191	3JdwNxhgqN8	short_forensic	Forensic analysis of Short #97	{"patterns": [], "short_id": 97}	youtube_studio_cdp	3	f	\N	2026-09-13 00:38:36.543059
193	hiP5k2gClN0	short_forensic	Forensic analysis of Short #95	{"patterns": [], "short_id": 95}	youtube_studio_cdp	3	f	\N	2026-09-13 00:39:10.017376
195	DrhZsdeBj6k	short_forensic	Forensic analysis of Short #98	{"patterns": [], "short_id": 98}	youtube_studio_cdp	3	f	\N	2026-09-13 00:39:55.370257
197	3JdwNxhgqN8	short_forensic	Forensic analysis of Short #97	{"patterns": [], "short_id": 97}	youtube_studio_cdp	3	f	\N	2026-09-13 00:48:04.423667
161	fsSkI-1Opvk	short_forensic	Forensic analysis of Short #83	{"patterns": [], "short_id": 83}	youtube_studio_cdp	3	f	\N	2026-09-11 17:24:40.362794
162	fsSkI-1Opvk	short_forensic	Forensic analysis of Short #83	{"patterns": [], "short_id": 83}	youtube_studio_cdp	3	f	\N	2026-09-11 17:33:13.71998
163	fsSkI-1Opvk	short_forensic	Forensic analysis of Short #83	{"patterns": [], "short_id": 83}	youtube_studio_cdp	3	f	\N	2026-09-11 22:58:05.388618
164	pbU_sJKSfrg	short_forensic	Forensic analysis of Short #84	{"patterns": [], "short_id": 84}	youtube_studio_cdp	3	f	\N	2026-09-11 22:58:06.014146
165	W1nCo6y71R8	short_forensic	Forensic analysis of Short #85	{"patterns": [], "short_id": 85}	youtube_studio_cdp	3	f	\N	2026-09-11 22:58:06.303119
168	xj4emmUcJGE	short_forensic	Forensic analysis of Short #88	{"patterns": [], "short_id": 88}	youtube_studio_cdp	3	f	\N	2026-09-11 22:58:07.287609
169	w2UTdzsuads	short_forensic	Forensic analysis of Short #89	{"patterns": [], "short_id": 89}	youtube_studio_cdp	3	f	\N	2026-09-11 22:58:07.599184
170	SOKrC7BJ418	short_forensic	Forensic analysis of Short #90	{"patterns": [], "short_id": 90}	youtube_studio_cdp	3	f	\N	2026-09-11 22:58:07.871575
171	PaYUzmc11E8	short_forensic	Forensic analysis of Short #91	{"patterns": [], "short_id": 91}	youtube_studio_cdp	3	f	\N	2026-09-11 22:58:08.189019
172	0KAZqj8-gFo	short_forensic	Forensic analysis of Short #92	{"patterns": [], "short_id": 92}	youtube_studio_cdp	3	f	\N	2026-09-11 22:58:08.519442
213	muLRYXpkVWA	short_forensic	Forensic analysis of Short #101	{"patterns": [], "short_id": 101}	youtube_studio_cdp	3	f	\N	2026-09-13 08:06:19.001339
215	5v6ouzwDdRQ	short_forensic	Forensic analysis of Short #99	{"patterns": [], "short_id": 99}	youtube_studio_cdp	3	f	\N	2026-09-13 08:07:14.421856
217	SS61lwI_i5Q	short_forensic	Forensic analysis of Short #107	{"patterns": [], "short_id": 107}	youtube_studio_cdp	3	f	\N	2026-09-13 08:20:20.943281
\.


--
-- Data for Name: performance_metrics; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.performance_metrics (video_id, views, engaged_views, unique_viewers, watch_time_hours, avg_view_duration_seconds, retention_pct, completion_pct, swipe_away_pct, subscribers_gained, subscribers_lost, net_subscribers, likes, comments_count, shares, hype_points, engagement_rate, sub_conversion_rate, engaged_view_rate, views_vs_channel_avg_pct, retention_vs_channel_avg, period_start, period_end, fetched_at) FROM stdin;
BJ5lJob_sDU	31	29	26	0.20	21.00	34.50	53.80	65.50	0	0	0	0	2	0	0	0.0645	0.0000	0.9355	\N	\N	2024-02-12	2026-09-01	2026-09-02 09:25:47.870198
yDKB-xCaMB8	43	40	39	0.20	13.00	25.50	25.50	74.50	0	0	0	0	1	0	0	0.0230	0.0000	0.9300	\N	\N	2024-03-03	2026-09-01	2026-09-02 14:30:31.576863
mK2nGGZFRVI	168	168	152	2.60	20.00	32.00	0.00	0.00	0	0	0	0	0	0	0	0.0000	0.0000	1.0000	0.00	0.00	\N	\N	2026-09-11 10:53:51.650803
rg5iPj-249o	91	91	88	0.60	16.00	26.70	26.70	73.30	1	0	1	0	0	0	0	0.0110	0.0110	1.0000	\N	\N	2024-03-17	2026-09-02	2026-09-02 14:58:55.032747
waW201cvfl8	105	102	95	0.40	25.00	49.80	49.80	50.20	1	0	1	0	0	0	0	0.0095	0.0095	0.9700	\N	\N	2024-03-24	2026-09-02	2026-09-02 15:14:09.210888
kbLQ0kJ7pYQ	57	54	51	0.38	24.00	27.40	21.90	72.60	2	0	2	0	0	0	0	0.0000	3.5100	0.9470	0.00	0.00	\N	\N	2026-09-13 00:04:05.182697
Ay9K30yrg8Y	439	439	437	1.30	12.00	25.20	25.20	74.80	0	0	0	0	0	0	0	0.0000	0.0000	1.0000	\N	\N	2024-03-27	2026-09-02	2026-09-02 15:27:50.633383
lmbndk-Db-Q	147	147	145	0.60	15.00	32.00	32.00	68.00	0	0	0	0	0	0	0	0.0000	0.0000	1.0000	\N	\N	2024-03-28	2026-09-02	2026-09-02 21:49:28.223132
cSapjDf5CHY	395	391	373	1.40	17.00	37.70	37.70	62.30	3	0	3	0	1	0	0	0.0100	0.0076	0.9900	\N	\N	2024-03-31	2026-09-02	2026-09-02 23:46:30.338612
5goNjmztwqg	43	43	29	0.30	27.00	71.40	51.90	28.60	0	0	0	0	2	0	0	0.0000	0.0000	1.0000	\N	\N	2024-01-22	2026-08-31	2026-09-02 09:45:39.987643
0jstRcQmAro	30	29	17	0.20	28.00	50.00	47.00	50.00	1	0	1	0	2	0	0	6.6700	3.3300	96.6700	\N	\N	2024-01-23	2026-08-31	2026-09-02 09:46:02.751285
UTeogxHwnPw	80	80	76	0.40	17.00	16.70	33.30	83.30	1	0	1	0	1	0	0	0.0125	0.0125	1.0000	\N	\N	2024-02-02	2026-09-01	2026-09-02 09:25:42.138615
zdOSsbqouKE	82	81	69	0.30	14.00	23.70	28.60	76.30	0	0	0	0	1	0	0	0.0122	0.0000	0.9878	\N	\N	2024-02-06	2026-09-01	2026-09-02 09:25:43.634893
12BKLbv0Eso	1711	1700	1500	13.70	28.00	62.40	45.90	37.60	0	0	0	0	9	0	0	0.0053	0.0000	0.9936	\N	\N	2024-02-06	2026-09-01	2026-09-02 09:25:45.151529
XM1AzgVMeqk	483	477	452	3.30	24.00	45.30	40.00	54.70	0	0	0	0	3	0	0	0.0062	0.0000	0.9876	\N	\N	2024-02-07	2026-09-01	2026-09-02 09:25:46.312192
nJNR60Ms1BE	96	96	87	0.70	24.00	31.50	39.30	68.50	0	0	0	0	5	0	0	0.0521	0.0000	1.0000	\N	\N	2024-02-07	2026-09-01	2026-09-02 09:25:47.152763
_A5Idj7SddI	27	24	20	0.10	16.00	54.60	55.20	45.40	0	0	0	0	0	0	0	0.0000	0.0000	0.8889	\N	\N	2024-02-12	2026-09-01	2026-09-02 09:25:47.534266
XWFbqR_9fqc	16	16	11	0.10	27.00	58.30	46.60	41.70	0	0	0	0	2	0	0	12.5000	0.0000	99.9999	0.00	0.00	2024-01-23	2026-08-31	2026-09-02 10:02:53.957789
Pwp0zPAY6Y4	23	23	19	0.10	20.00	57.90	34.50	43.20	0	0	0	0	2	0	0	8.7000	0.0000	99.9999	0.00	0.00	2024-01-23	2026-08-31	2026-09-02 10:03:13.106027
s_PoEssiuPo	34	34	34	0.20	20.00	50.80	34.50	49.20	0	0	0	0	1	0	0	2.9000	0.0000	99.9999	0.00	0.00	2024-01-24	2026-08-31	2026-09-02 10:03:18.329293
OkWbChCIb04	49	47	44	0.20	16.00	24.20	26.20	75.80	0	0	0	0	0	0	0	0.0000	0.0000	0.9590	\N	\N	2024-03-02	2026-09-01	2026-09-02 10:43:00.55935
pbU_sJKSfrg	240	228	216	1.00	15.00	55.90	44.70	44.10	2	0	2	0	0	0	0	0.0000	0.8300	0.9500	0.00	0.00	\N	\N	2026-09-11 22:58:06.014146
2jcdStwq2yY	77	77	73	0.50	22.00	88.50	47.80	11.50	0	0	0	0	0	0	0	0.0000	0.0000	1.0000	\N	\N	2024-03-02	2026-09-01	2026-09-02 11:22:03.546173
JmSdjrAxNFM	122	122	119	0.40	11.00	23.70	22.00	76.30	0	0	0	0	0	0	0	0.0000	0.0000	1.0000	22.00	\N	2024-04-02	2026-09-02	2026-09-03 08:43:48.484092
MpQ-K2D9Ao4	539	536	530	2.40	16.00	41.50	28.60	58.50	2	0	2	0	2	0	0	0.0037	0.0037	0.9940	409.00	\N	2024-04-08	2026-09-02	2026-09-03 08:46:53.14088
bXetyvX2Mu8	395	395	376	1.80	16.00	27.30	26.70	72.70	0	0	0	0	2	0	0	0.0051	0.0000	1.0000	265.00	\N	2024-04-09	2026-09-02	2026-09-03 08:49:33.548839
pHfj5VVN0Ew	310	309	298	1.50	17.00	47.90	34.70	52.10	2	0	2	0	1	0	0	0.0097	0.0065	0.9970	180.00	\N	2024-04-11	2026-09-02	2026-09-03 08:52:31.076945
SOKrC7BJ418	580	551	522	4.03	25.00	43.80	35.00	56.20	0	0	0	0	0	0	0	0.0000	0.0000	0.9500	0.00	0.00	\N	\N	2026-09-11 22:58:07.871575
ZrY0tM9yPxQ	364	345	327	1.11	11.00	29.00	23.20	71.00	0	0	0	0	0	0	0	0.0000	0.0000	0.9480	0.00	0.00	\N	\N	2026-09-13 00:39:03.743153
QnjyscmnjEQ	703	667	632	3.91	20.00	64.80	51.80	35.20	2	0	2	0	0	0	0	0.0000	0.2800	0.9490	0.00	0.00	\N	\N	2026-09-13 01:04:42.898173
wnp9gFm7ZpY	130	124	116	0.50	13.00	30.00	0.00	0.00	0	0	0	0	0	0	0	0.0000	0.0000	0.9500	241.00	0.00	2024-06-17	2026-09-10	2026-09-12 21:46:22.459929
j7xmoRH2rzo	2129	2022	1916	7.69	13.00	56.10	44.90	43.90	5	0	5	0	0	0	0	0.0000	0.2300	0.9500	0.00	0.00	\N	\N	2026-09-13 08:04:48.235092
_gF2JDP64Yc	581	551	522	1.61	10.00	28.80	23.00	71.20	1	0	1	0	0	0	0	0.0000	0.1700	0.9480	0.00	0.00	\N	\N	2026-09-13 08:06:26.943876
4yAeMwjZxoo	460	437	414	1.66	13.00	27.80	22.20	72.20	1	0	1	0	0	0	0	0.0000	0.2200	0.9500	0.00	0.00	\N	\N	2026-09-13 08:12:31.899566
BMh9Xq36RrA	1105	1049	994	3.68	12.00	36.70	29.40	63.30	0	0	0	0	0	0	0	0.0000	0.0000	0.9490	0.00	0.00	\N	\N	2026-09-13 08:22:34.508287
dpTHfuBYClo	504	504	489	2.60	18.00	37.50	31.60	62.50	0	0	0	0	0	0	0	0.0000	0.0000	1.0000	274.00	\N	2024-04-12	2026-09-02	2026-09-03 08:54:48.143719
NVbNJeWZ1Lo	101	98	87	0.60	23.00	61.40	0.00	0.00	0	0	0	0	0	0	0	0.0000	0.0000	0.9700	25.30	0.00	\N	\N	2026-09-10 20:21:07.431547
sHwtsGShqjE	496	496	485	1.90	13.00	38.40	35.10	61.60	0	0	0	0	1	0	0	0.2016	0.0000	99.9999	124.00	\N	\N	\N	2026-09-03 10:11:18.411369
Wyt0zC-zadM	139	137	133	0.50	13.00	27.60	27.60	72.40	0	0	0	0	0	0	0	0.0000	0.0000	0.9856	\N	\N	2024-04-15	2026-09-02	2026-09-03 12:28:17.67752
JRrvbkvRyiI	457	457	452	1.80	14.00	38.70	38.70	61.30	1	0	1	0	3	0	0	0.8700	0.2200	1.0000	\N	\N	2024-04-18	2026-09-02	2026-09-03 12:45:38.189925
pTiZBob0vWA	471	470	452	2.50	19.00	42.20	42.20	57.80	1	0	1	0	0	0	0	0.2100	0.2100	0.9980	\N	\N	2024-04-19	2026-09-02	2026-09-03 13:23:31.162254
F6g5hMAUH6A	191	191	186	0.70	14.00	36.70	36.70	63.30	1	0	1	0	1	0	0	0.5200	0.5200	1.0000	\N	\N	2024-04-20	2026-09-02	2026-09-03 13:36:14.415812
durkT5BI9-0	266	266	262	0.90	11.00	40.30	40.30	59.70	0	0	0	0	0	0	0	0.0000	0.0000	1.0000	\N	\N	2024-04-21	2026-09-02	2026-09-03 14:13:12.403346
-ntsqYRrjic	786	771	736	4.20	19.00	45.80	45.80	54.20	0	0	0	0	5	0	0	0.6400	0.0000	0.9800	\N	\N	2024-04-21	2026-09-02	2026-09-03 14:22:21.576395
kQlrFbAzvro	3671	3400	3300	25.60	26.00	60.30	60.30	39.70	0	0	0	0	0	0	0	0.0000	0.0000	0.9300	\N	\N	2024-04-23	2026-09-02	2026-09-03 14:34:36.771304
VkXC2gAxVvs	406	406	394	1.50	12.00	34.20	34.20	65.80	0	0	0	0	2	0	0	0.4900	0.0000	1.0000	\N	\N	2024-04-24	2026-09-03	2026-09-03 21:29:21.003798
QC45KrzAuLs	516	516	504	2.20	15.00	22.50	22.50	77.50	0	0	0	0	0	0	0	0.0000	0.0000	1.0000	\N	\N	2024-04-24	2026-09-03	2026-09-03 21:44:00.314367
gNgwb1lmKL8	982	981	952	5.70	20.00	36.80	36.80	63.20	2	0	2	0	0	0	0	0.2000	0.2000	0.9990	\N	\N	2024-04-25	2026-09-03	2026-09-03 22:06:49.206096
XlOAFuUr7F4	482	481	458	2.70	20.00	28.00	28.00	72.00	1	0	1	0	3	0	0	0.8300	0.2100	0.9980	\N	\N	2024-04-28	2026-09-03	2026-09-03 22:31:30.815574
d-p-YuOjU-8	301	298	282	2.30	27.00	43.10	43.10	56.90	1	0	1	0	8	0	0	2.9900	0.3300	0.9900	\N	\N	2024-04-29	2026-09-03	2026-09-03 22:47:40.537674
7L-wWpll_GU	98	98	95	0.50	18.00	23.50	23.50	76.50	0	0	0	0	0	0	0	0.0000	0.0000	1.0000	\N	\N	2024-04-30	2026-09-03	2026-09-03 22:59:23.098487
pszcrf0uTbQ	7071	5700	5000	55.80	35.00	55.10	55.10	44.90	13	0	13	0	30	0	0	0.6100	0.1800	0.8100	\N	\N	2024-05-03	2026-09-03	2026-09-04 09:31:55.178282
EDNdXwv7W64	1258	1100	1000	9.90	31.00	42.40	42.40	57.60	4	0	4	0	7	0	0	0.5600	0.3200	0.8700	\N	\N	2024-05-06	2026-09-03	2026-09-04 09:55:24.289926
DdMa3y_sImk	323	323	305	1.30	14.00	45.60	45.60	54.40	0	0	0	0	0	0	0	0.0000	0.0000	1.0000	-26.60	\N	2024-05-07	2026-09-03	2026-09-04 12:02:37.004788
YFnY2guPlxg	447	447	434	1.80	14.00	34.60	34.60	65.40	0	0	0	0	0	0	0	0.0000	0.0000	1.0000	1.60	\N	2024-05-10	2026-09-03	2026-09-04 12:04:52.149361
noF6FnkgYmE	102	102	97	0.50	18.00	17.80	17.80	82.20	3	0	3	0	0	0	0	0.0000	0.0300	1.0000	-73.20	\N	2024-05-11	2026-09-03	2026-09-04 12:16:10.255319
tyxuLrd-xo4	232	230	229	1.00	15.00	27.10	27.10	72.80	0	0	0	0	0	0	0	0.0000	0.0000	0.9900	-38.90	\N	2024-05-12	2026-09-03	2026-09-04 12:33:43.388322
UzWyYR6WM6U	407	407	398	1.80	15.00	35.80	35.80	64.20	1	0	1	0	0	0	0	0.0000	0.0020	1.0000	7.10	\N	2024-05-13	2026-09-03	2026-09-04 12:56:32.962168
3gSWKoBeqnw	339	339	326	0.90	12.00	27.10	27.10	72.90	0	0	0	0	0	0	0	0.0000	0.0000	1.0000	-10.80	\N	2024-05-13	2026-09-03	2026-09-04 13:19:16.949153
impBBFcUinY	480	480	470	1.10	14.00	33.70	33.70	66.30	1	0	1	0	0	0	0	0.0000	0.0020	1.0000	9.10	\N	2024-05-14	2026-09-03	2026-09-04 13:33:07.646614
kIrFARfeW5o	520	520	510	1.70	19.00	39.50	39.50	60.50	1	0	1	0	0	0	0	0.0000	0.0020	1.0000	18.20	\N	2024-05-14	2026-09-03	2026-09-04 13:52:08.871339
3LCJCKfRATo	482	480	476	2.60	19.00	32.00	37.10	62.90	0	0	0	0	0	0	0	0.0000	0.0000	0.9960	\N	\N	2024-04-23	2026-09-03	2026-09-10 23:30:52.664773
A2U9omXQ2go	168	168	152	2.60	20.00	32.00	0.00	0.00	0	0	0	0	0	0	0	0.0000	0.0000	1.0000	0.00	0.00	\N	\N	2026-09-11 13:05:32.12302
FwuhJ23l7R4	319	277	246	1.30	16.00	67.80	67.80	32.20	0	0	0	0	3	0	0	0.0090	0.0000	0.8680	-16.10	\N	2024-05-11	2026-09-04	2026-09-04 15:17:53.707086
_vTmJ79_4ho	92	92	89	0.30	10.00	20.80	22.20	79.20	0	0	0	0	1	0	0	1.0870	0.0000	1.0000	-85.00	-50.00	2024-05-17	2026-09-05	2026-09-05 20:12:48.727333
xj4emmUcJGE	1042	989	937	6.95	24.00	55.80	44.60	44.20	5	0	5	0	0	0	0	0.0000	0.4800	0.9490	0.00	0.00	\N	\N	2026-09-11 22:58:07.287609
tO8vEcWUFXs	197	196	192	0.70	12.00	26.50	28.60	73.50	1	0	1	0	0	0	0	0.5076	0.5076	0.9949	-29.60	-40.00	2024-05-16	2026-09-05	2026-09-05 19:35:09.745882
m1qgKExs2BY	256	256	250	1.20	16.00	42.70	41.00	57.30	0	0	0	0	10	0	0	3.9063	0.0000	1.0000	-34.00	-10.00	2024-05-16	2026-09-05	2026-09-05 19:53:35.380044
PaYUzmc11E8	144	136	129	1.04	26.00	41.90	33.50	58.10	0	0	0	0	0	0	0	0.0000	0.0000	0.9440	0.00	0.00	\N	\N	2026-09-11 22:58:08.189019
atkvEdcPidM	207	205	193	0.80	14.00	34.70	22.95	65.30	1	0	1	0	0	0	0	0.4831	0.4831	99.0338	-35.31	-5.30	2024-05-17	2026-09-05	2026-09-06 08:41:17.107595
dudb29Xqo60	699	579	511	2.70	16.00	48.20	48.20	51.90	1	0	1	0	3	0	0	0.5708	0.1431	82.8300	66.30	0.00	2024-05-19	2026-09-05	2026-09-06 08:53:13.551357
9jXcNZyYza8	72	69	63	0.30	14.00	27.00	23.70	73.00	0	0	0	0	1	0	0	1.3889	0.0000	0.9583	-85.00	-20.00	2024-05-20	2026-09-05	2026-09-06 09:14:07.3586
eC_j1wlFJBw	29	29	28	0.10	11.00	19.00	19.00	81.00	0	0	0	0	0	0	0	0.0000	0.0000	1.0000	-86.90	-5.00	2024-05-21	2026-09-05	2026-09-06 09:30:05.833783
Q-IS9K8g294	242	241	235	0.90	13.00	25.10	20.80	74.90	1	0	1	0	0	0	0	0.4132	0.4132	99.5900	-45.00	-20.00	2024-05-21	2026-09-05	2026-09-06 09:52:18.827983
p03EyeJlM-k	165	160	141	1.00	22.00	26.50	26.50	73.50	2	0	2	0	0	0	0	1.2100	1.2100	96.9700	-25.00	0.00	2024-05-21	2026-09-05	2026-09-06 12:19:14.187832
229XDzxoc4g	332	332	325	1.50	16.00	25.60	19.00	74.40	1	0	1	0	0	0	0	0.0000	0.0030	1.0000	0.00	0.00	2024-05-25	2026-09-05	2026-09-06 13:26:52.660817
j4CtPMW-1Q4	123	122	120	0.50	16.00	25.90	25.90	74.10	0	0	0	0	0	0	0	0.0000	0.0000	0.9919	-13.60	0.00	2024-05-25	2026-09-05	2026-09-06 13:43:57.675416
iLZVyccaTJs	307	305	293	1.40	16.00	39.20	15.00	60.80	0	0	0	0	2	0	0	0.0065	0.0000	0.9935	57.00	0.00	2024-05-29	2026-09-05	2026-09-06 13:51:03.028232
xBun0zPGZDA	506	489	479	1.40	9.00	33.50	0.00	66.50	0	0	0	0	0	0	0	0.0000	0.0000	0.9664	0.00	0.00	2024-05-30	2026-09-06	2026-09-06 15:05:42.270667
0KAZqj8-gFo	749	711	674	4.16	20.00	63.00	50.40	37.00	1	0	1	0	0	0	0	0.0000	0.1300	0.9490	0.00	0.00	\N	\N	2026-09-11 22:58:08.519442
_6qJfWvvWJo	435	434	418	2.60	16.00	32.00	0.00	0.00	0	0	0	0	0	0	0	0.0000	0.0000	1.0000	241.00	0.00	\N	\N	2026-09-10 20:01:40.055997
pl90QEsoKFk	498	491	490	2.00	14.00	29.60	0.00	0.00	0	0	0	0	0	0	0	0.0000	0.0000	1.0000	184.00	0.00	\N	\N	2026-09-10 23:10:00.515414
3JdwNxhgqN8	1333	1266	1199	5.55	15.00	51.70	41.40	48.30	0	0	0	0	0	0	0	0.0000	0.0000	0.9500	0.00	0.00	\N	\N	2026-09-13 00:48:04.423667
fsSkI-1Opvk	420	399	378	2.10	18.00	40.20	32.20	59.80	1	0	1	0	0	0	0	0.0000	0.2400	0.9500	0.00	0.00	\N	\N	2026-09-11 22:58:05.388618
W1nCo6y71R8	151	143	135	0.67	16.00	22.20	17.80	77.80	2	0	2	0	0	0	0	0.0000	1.3200	0.9470	0.00	0.00	\N	\N	2026-09-11 22:58:06.303119
w2UTdzsuads	369	350	332	2.25	22.00	14.60	11.70	85.40	1	0	1	0	0	0	0	0.0000	0.2700	0.9490	0.00	0.00	\N	\N	2026-09-11 22:58:07.599184
4B4aAW76GLQ	413	412	406	1.40	11.00	35.30	20.00	64.70	1	0	1	12	0	3	0	3.6000	0.2400	0.9970	0.00	0.00	2024-05-30	2026-09-07	2026-09-07 09:04:23.739817
rrTB_XW3pWA	63	59	56	0.44	25.00	56.20	45.00	43.80	0	0	0	0	0	0	0	0.0000	0.0000	0.9370	0.00	0.00	\N	\N	2026-09-12 23:25:09.52654
AwJoDsJiAoQ	47	44	42	0.33	25.00	34.00	27.20	66.00	0	0	0	0	0	0	0	0.0000	0.0000	0.9360	0.00	0.00	\N	\N	2026-09-13 00:30:05.383779
LQ7ttolwjJQ	69	69	68	0.20	12.00	14.20	14.20	85.80	1	0	1	0	0	0	0	1.4500	1.4500	1.0000	-41.00	-50.00	2024-06-01	2026-09-07	2026-09-07 10:50:43.305672
zqqcLDVZxR8	324	322	319	0.90	10.00	17.30	17.30	82.70	0	0	0	0	0	0	0	0.0000	0.0000	0.9940	54.00	-25.00	2024-06-01	2026-09-07	2026-09-07 10:57:07.066385
hiP5k2gClN0	714	678	642	3.97	20.00	60.10	48.10	39.90	0	0	0	0	0	0	0	0.0000	0.0000	0.9500	0.00	0.00	\N	\N	2026-09-13 00:39:10.017376
DrhZsdeBj6k	30120	28614	27108	301.20	36.00	76.40	61.10	23.60	12	0	12	0	0	0	0	0.0000	0.0400	0.9500	0.00	0.00	\N	\N	2026-09-13 00:39:55.370257
YaAKtkecoRc	406	380	370	1.35	12.00	32.20	25.50	67.80	2	0	2	15	8	3	0	6.4000	0.4900	0.9360	86.00	12.50	2024-06-04	2026-09-08	2026-09-08 11:27:20.802552
muLRYXpkVWA	2611	2480	2349	8.70	12.00	58.70	47.00	41.30	0	0	0	0	0	0	0	0.0000	0.0000	0.9500	0.00	0.00	\N	\N	2026-09-13 08:06:19.001339
5v6ouzwDdRQ	607	576	546	1.69	10.00	33.50	26.80	66.50	0	0	0	0	0	0	0	0.0000	0.0000	0.9490	0.00	0.00	\N	\N	2026-09-13 08:07:14.421856
SS61lwI_i5Q	188	178	169	0.94	18.00	25.90	20.70	74.10	0	0	0	0	0	0	0	0.0000	0.0000	0.9470	0.00	0.00	\N	\N	2026-09-13 08:20:20.943281
Mp1WHa-CXfw	72	72	66	0.50	22.00	30.80	15.00	10.00	0	0	0	0	42	0	0	58.3000	0.0000	1.0000	78.00	0.00	2024-06-05	2026-09-08	2026-09-09 14:55:59.402702
D4KiNRb7UTk	561	225	200	25.50	27.00	42.50	35.00	18.00	3	1	2	47	12	8	0	8.4500	3.2000	40.2000	135.00	15.30	2024-05-23	2026-09-09	2026-09-09 16:51:44.575471
yBnFHlmgMFQ	571	570	547	2.60	16.00	32.00	0.00	0.00	0	0	0	0	0	0	0	0.0000	0.0000	1.0000	241.00	0.00	\N	\N	2026-09-09 23:48:51.46802
bLwR73Y2d0w	956	954	933	5.00	18.00	39.00	\N	\N	0	0	0	0	0	0	0	0.0000	0.0000	1.0000	\N	\N	\N	\N	2026-09-10 10:04:13.605465
Pnh6g6K9y8Q	427	312	298	2.10	14.00	28.50	0.00	8.20	3	1	2	47	5	12	0	0.1100	0.7000	73.0000	142.00	-5.30	\N	\N	2026-09-10 17:22:57.565114
DNIHqPqY3VM	437	437	427	1.30	10.00	33.30	0.00	0.00	0	0	0	0	0	0	0	0.0000	0.0000	1.0000	0.00	0.00	\N	\N	2026-09-10 18:32:28.286194
Mkx7Qp8nCys	73	72	68	1.50	17.00	45.00	0.00	0.00	2	0	2	5	1	3	0	0.0500	0.0300	0.9800	180.00	0.00	\N	\N	2026-09-10 18:44:13.592751
a6DGQWZ57EE	193	186	179	1.60	29.00	39.90	0.00	0.00	0	0	0	0	0	0	0	0.0000	0.0000	1.0000	57.00	0.00	\N	\N	2026-09-10 19:33:03.635723
\.


--
-- Data for Name: realtime_metrics; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.realtime_metrics (video_id, views_48h, period_start, period_end, velocity_views_per_hour, fetched_at) FROM stdin;
4B4aAW76GLQ	0	2026-09-05 00:00:00	2026-09-07 00:00:00	0.00	2026-09-07 09:04:23.739817
xj4emmUcJGE	0	\N	\N	0.00	2026-09-11 22:58:07.287609
w2UTdzsuads	0	\N	\N	0.00	2026-09-11 22:58:07.599184
fsSkI-1Opvk	0	\N	\N	0.00	2026-09-11 22:58:05.388618
pbU_sJKSfrg	0	\N	\N	0.00	2026-09-11 22:58:06.014146
W1nCo6y71R8	0	\N	\N	0.00	2026-09-11 22:58:06.303119
AwJoDsJiAoQ	0	\N	\N	0.00	2026-09-13 00:30:05.383779
SOKrC7BJ418	0	\N	\N	0.00	2026-09-11 22:58:07.871575
PaYUzmc11E8	0	\N	\N	0.00	2026-09-11 22:58:08.189019
0KAZqj8-gFo	0	\N	\N	0.00	2026-09-11 22:58:08.519442
UTeogxHwnPw	0	2026-08-30 00:00:00	2026-09-01 00:00:00	0.00	2026-09-02 09:25:42.138615
zdOSsbqouKE	0	2026-08-30 00:00:00	2026-09-01 00:00:00	0.00	2026-09-02 09:25:43.634893
12BKLbv0Eso	0	2026-08-30 00:00:00	2026-09-01 00:00:00	0.00	2026-09-02 09:25:45.151529
XM1AzgVMeqk	0	2026-08-30 00:00:00	2026-09-01 00:00:00	0.00	2026-09-02 09:25:46.312192
nJNR60Ms1BE	0	2026-08-30 00:00:00	2026-09-01 00:00:00	0.00	2026-09-02 09:25:47.152763
_A5Idj7SddI	0	2026-08-30 00:00:00	2026-09-01 00:00:00	0.00	2026-09-02 09:25:47.534266
BJ5lJob_sDU	0	2026-08-30 00:00:00	2026-09-01 00:00:00	0.00	2026-09-02 09:25:47.870198
ZrY0tM9yPxQ	0	\N	\N	0.00	2026-09-13 00:39:03.743153
LQ7ttolwjJQ	0	2026-09-05 00:00:00	2026-09-07 00:00:00	0.00	2026-09-07 10:50:43.305672
zqqcLDVZxR8	0	2026-09-05 00:00:00	2026-09-07 00:00:00	0.00	2026-09-07 10:57:07.066385
5goNjmztwqg	0	2026-08-29 00:00:00	2026-08-31 00:00:00	0.00	2026-09-02 09:45:39.987643
0jstRcQmAro	0	2026-08-29 00:00:00	2026-08-31 00:00:00	0.00	2026-09-02 09:46:02.751285
XWFbqR_9fqc	0	2026-08-29 00:00:00	2026-08-31 00:00:00	0.00	2026-09-02 10:02:53.957789
Pwp0zPAY6Y4	0	2026-08-29 00:00:00	2026-08-31 00:00:00	0.00	2026-09-02 10:03:13.106027
s_PoEssiuPo	0	2026-08-29 00:00:00	2026-08-31 00:00:00	0.00	2026-09-02 10:03:18.329293
OkWbChCIb04	0	2026-08-30 00:00:00	2026-09-01 00:00:00	0.00	2026-09-02 10:43:00.55935
hiP5k2gClN0	0	\N	\N	0.00	2026-09-13 00:39:10.017376
2jcdStwq2yY	0	2026-08-30 00:00:00	2026-09-01 00:00:00	0.00	2026-09-02 11:22:03.546173
yDKB-xCaMB8	0	2026-08-30 00:00:00	2026-09-01 00:00:00	0.00	2026-09-02 14:30:31.576863
rg5iPj-249o	0	2026-08-31 00:00:00	2026-09-02 00:00:00	0.00	2026-09-02 14:58:55.032747
waW201cvfl8	0	2026-08-31 00:00:00	2026-09-02 00:00:00	0.00	2026-09-02 15:14:09.210888
Ay9K30yrg8Y	0	2026-08-31 00:00:00	2026-09-02 00:00:00	0.00	2026-09-02 15:27:50.633383
lmbndk-Db-Q	0	2026-08-31 00:00:00	2026-09-02 00:00:00	0.00	2026-09-02 21:49:28.223132
cSapjDf5CHY	0	2026-08-31 00:00:00	2026-09-02 00:00:00	0.00	2026-09-02 23:46:30.338612
JmSdjrAxNFM	0	2026-09-02 00:00:00	2026-09-04 00:00:00	0.00	2026-09-03 08:43:48.484092
MpQ-K2D9Ao4	0	2026-09-02 00:00:00	2026-09-04 00:00:00	0.00	2026-09-03 08:46:53.14088
bXetyvX2Mu8	0	2026-09-02 00:00:00	2026-09-04 00:00:00	0.00	2026-09-03 08:49:33.548839
pHfj5VVN0Ew	0	2026-09-02 00:00:00	2026-09-04 00:00:00	0.00	2026-09-03 08:52:31.076945
dpTHfuBYClo	0	2026-09-02 00:00:00	2026-09-04 00:00:00	0.00	2026-09-03 08:54:48.143719
DrhZsdeBj6k	0	\N	\N	0.00	2026-09-13 00:39:55.370257
sHwtsGShqjE	0	2026-09-02 00:00:00	2026-09-04 00:00:00	0.00	2026-09-03 10:11:18.411369
tO8vEcWUFXs	0	2026-09-03 00:00:00	2026-09-05 00:00:00	0.00	2026-09-05 19:35:09.745882
m1qgKExs2BY	0	2026-09-03 00:00:00	2026-09-05 00:00:00	0.00	2026-09-05 19:53:35.380044
_vTmJ79_4ho	0	2026-09-03 00:00:00	2026-09-05 00:00:00	0.00	2026-09-05 20:12:48.727333
5v6ouzwDdRQ	0	\N	\N	0.00	2026-09-13 08:07:14.421856
3JdwNxhgqN8	0	\N	\N	0.00	2026-09-13 00:48:04.423667
4yAeMwjZxoo	0	\N	\N	0.00	2026-09-13 08:12:31.899566
SS61lwI_i5Q	0	\N	\N	0.00	2026-09-13 08:20:20.943281
QnjyscmnjEQ	0	\N	\N	0.00	2026-09-13 01:04:42.898173
wnp9gFm7ZpY	0	\N	\N	0.00	2026-09-12 21:46:22.459929
rrTB_XW3pWA	0	\N	\N	0.00	2026-09-12 23:25:09.52654
atkvEdcPidM	0	2026-09-03 00:00:00	2026-09-05 00:00:00	0.00	2026-09-06 08:41:17.107595
dudb29Xqo60	0	2026-09-03 00:00:00	2026-09-05 00:00:00	0.00	2026-09-06 08:53:13.551357
9jXcNZyYza8	0	2026-09-03 00:00:00	2026-09-05 00:00:00	0.00	2026-09-06 09:14:07.3586
kbLQ0kJ7pYQ	0	\N	\N	0.00	2026-09-13 00:04:05.182697
eC_j1wlFJBw	0	2026-09-03 00:00:00	2026-09-05 00:00:00	0.00	2026-09-06 09:30:05.833783
Q-IS9K8g294	0	2026-09-03 00:00:00	2026-09-05 00:00:00	0.00	2026-09-06 09:52:18.827983
p03EyeJlM-k	0	2026-09-03 00:00:00	2026-09-05 00:00:00	0.00	2026-09-06 12:19:14.187832
229XDzxoc4g	0	2026-09-03 00:00:00	2026-09-05 00:00:00	0.00	2026-09-06 13:26:52.660817
j4CtPMW-1Q4	0	2026-09-03 00:00:00	2026-09-05 00:00:00	0.00	2026-09-06 13:43:57.675416
iLZVyccaTJs	0	2026-09-03 00:00:00	2026-09-05 00:00:00	0.00	2026-09-06 13:51:03.028232
xBun0zPGZDA	1	2026-09-04 00:00:00	2026-09-06 00:00:00	0.00	2026-09-06 15:05:42.270667
BMh9Xq36RrA	0	\N	\N	0.00	2026-09-13 08:22:34.508287
j7xmoRH2rzo	0	\N	\N	0.00	2026-09-13 08:04:48.235092
muLRYXpkVWA	0	\N	\N	0.00	2026-09-13 08:06:19.001339
_gF2JDP64Yc	0	\N	\N	0.00	2026-09-13 08:06:26.943876
YaAKtkecoRc	0	2026-09-06 00:00:00	2026-09-08 00:00:00	0.00	2026-09-08 11:27:20.802552
Mp1WHa-CXfw	0	2026-09-06 00:00:00	2026-09-08 00:00:00	0.00	2026-09-09 14:55:59.402702
pl90QEsoKFk	0	\N	\N	0.00	2026-09-10 23:10:00.515414
3LCJCKfRATo	0	\N	\N	0.00	2026-09-10 23:30:52.664773
D4KiNRb7UTk	12	2026-09-07 00:00:00	2026-09-09 00:00:00	2.50	2026-09-09 16:51:44.575471
yBnFHlmgMFQ	0	\N	\N	0.00	2026-09-09 23:48:51.46802
bLwR73Y2d0w	0	\N	\N	0.00	2026-09-10 10:04:13.605465
Pnh6g6K9y8Q	0	\N	\N	0.00	2026-09-10 17:22:57.565114
DNIHqPqY3VM	0	\N	\N	0.00	2026-09-10 18:32:28.286194
Mkx7Qp8nCys	0	\N	\N	0.00	2026-09-10 18:44:13.592751
a6DGQWZ57EE	0	\N	\N	0.00	2026-09-10 19:33:03.635723
mK2nGGZFRVI	0	\N	\N	0.00	2026-09-11 10:53:51.650803
_6qJfWvvWJo	0	\N	\N	0.00	2026-09-10 20:01:40.055997
NVbNJeWZ1Lo	0	\N	\N	0.00	2026-09-10 20:21:07.431547
A2U9omXQ2go	0	\N	\N	0.00	2026-09-11 13:05:32.12302
\.


--
-- Data for Name: remix_metrics; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.remix_metrics (video_id, remix_count, remix_views, top_remix_video_id, top_remix_views, fetched_at) FROM stdin;
wnp9gFm7ZpY	0	0	\N	0	2026-09-12 21:46:22.459929
rrTB_XW3pWA	0	0	\N	0	2026-09-12 23:25:09.52654
kbLQ0kJ7pYQ	0	0	\N	0	2026-09-13 00:04:05.182697
LQ7ttolwjJQ	0	0	\N	0	2026-09-07 10:50:43.305672
AwJoDsJiAoQ	0	0	\N	0	2026-09-13 00:30:05.383779
ZrY0tM9yPxQ	0	0	\N	0	2026-09-13 00:39:03.743153
hiP5k2gClN0	0	0	\N	0	2026-09-13 00:39:10.017376
UTeogxHwnPw	0	0	\N	0	2026-09-02 09:25:42.138615
zdOSsbqouKE	0	0	\N	0	2026-09-02 09:25:43.634893
12BKLbv0Eso	0	0	\N	0	2026-09-02 09:25:45.151529
XM1AzgVMeqk	0	0	\N	0	2026-09-02 09:25:46.312192
nJNR60Ms1BE	0	0	\N	0	2026-09-02 09:25:47.152763
_A5Idj7SddI	0	0	\N	0	2026-09-02 09:25:47.534266
BJ5lJob_sDU	0	0	\N	0	2026-09-02 09:25:47.870198
zqqcLDVZxR8	0	0	\N	0	2026-09-07 10:57:07.066385
DrhZsdeBj6k	0	0	\N	0	2026-09-13 00:39:55.370257
5goNjmztwqg	0	0	\N	0	2026-09-02 09:45:39.987643
0jstRcQmAro	0	0	\N	0	2026-09-02 09:46:02.751285
XWFbqR_9fqc	0	0	\N	0	2026-09-02 10:02:53.957789
Pwp0zPAY6Y4	0	0	\N	0	2026-09-02 10:03:13.106027
s_PoEssiuPo	0	0	\N	0	2026-09-02 10:03:18.329293
OkWbChCIb04	0	0	\N	0	2026-09-02 10:43:00.55935
2jcdStwq2yY	0	0	\N	0	2026-09-02 11:22:03.546173
yDKB-xCaMB8	0	0	\N	0	2026-09-02 14:30:31.576863
rg5iPj-249o	0	0	\N	0	2026-09-02 14:58:55.032747
waW201cvfl8	0	0	\N	0	2026-09-02 15:14:09.210888
Ay9K30yrg8Y	0	0	\N	0	2026-09-02 15:27:50.633383
lmbndk-Db-Q	0	0	\N	0	2026-09-02 21:49:28.223132
cSapjDf5CHY	0	0	\N	0	2026-09-02 23:46:30.338612
JmSdjrAxNFM	0	0	\N	0	2026-09-03 08:43:48.484092
MpQ-K2D9Ao4	0	0	\N	0	2026-09-03 08:46:53.14088
bXetyvX2Mu8	0	0	\N	0	2026-09-03 08:49:33.548839
pHfj5VVN0Ew	0	0	\N	0	2026-09-03 08:52:31.076945
dpTHfuBYClo	0	0	\N	0	2026-09-03 08:54:48.143719
5v6ouzwDdRQ	0	0	\N	0	2026-09-13 08:07:14.421856
3JdwNxhgqN8	0	0	\N	0	2026-09-13 00:48:04.423667
sHwtsGShqjE	0	0	\N	0	2026-09-03 10:11:18.411369
Wyt0zC-zadM	0	0	\N	0	2026-09-03 12:28:17.67752
JRrvbkvRyiI	0	0	\N	0	2026-09-03 12:45:38.189925
pTiZBob0vWA	0	0	\N	0	2026-09-03 13:23:31.162254
F6g5hMAUH6A	0	0	\N	0	2026-09-03 13:36:14.415812
durkT5BI9-0	0	0	\N	0	2026-09-03 14:13:12.403346
-ntsqYRrjic	0	0	\N	0	2026-09-03 14:22:21.576395
kQlrFbAzvro	0	0	\N	0	2026-09-03 14:34:36.771304
VkXC2gAxVvs	0	0	\N	0	2026-09-03 21:29:21.003798
QC45KrzAuLs	0	0	\N	0	2026-09-03 21:44:00.314367
gNgwb1lmKL8	0	0	\N	0	2026-09-03 22:06:49.206096
XlOAFuUr7F4	0	0	\N	0	2026-09-03 22:31:30.815574
d-p-YuOjU-8	0	0	\N	0	2026-09-03 22:47:40.537674
7L-wWpll_GU	0	0	\N	0	2026-09-03 22:59:23.098487
pszcrf0uTbQ	0	0	\N	0	2026-09-04 09:31:55.178282
EDNdXwv7W64	0	0	\N	0	2026-09-04 09:55:24.289926
DdMa3y_sImk	0	0	\N	0	2026-09-04 12:02:37.004788
YFnY2guPlxg	0	0	\N	0	2026-09-04 12:04:52.149361
noF6FnkgYmE	0	0	\N	0	2026-09-04 12:16:10.255319
tyxuLrd-xo4	0	0	\N	0	2026-09-04 12:33:43.388322
UzWyYR6WM6U	0	0	\N	0	2026-09-04 12:56:32.962168
3gSWKoBeqnw	0	0	\N	0	2026-09-04 13:19:16.949153
impBBFcUinY	0	0	\N	0	2026-09-04 13:33:07.646614
kIrFARfeW5o	0	0	\N	0	2026-09-04 13:52:08.871339
FwuhJ23l7R4	0	0	\N	0	2026-09-04 15:17:53.707086
tO8vEcWUFXs	0	0	\N	0	2026-09-05 19:35:09.745882
m1qgKExs2BY	0	0	\N	0	2026-09-05 19:53:35.380044
_vTmJ79_4ho	0	0	\N	0	2026-09-05 20:12:48.727333
4yAeMwjZxoo	0	0	\N	0	2026-09-13 08:12:31.899566
QnjyscmnjEQ	0	0	\N	0	2026-09-13 01:04:42.898173
_gF2JDP64Yc	0	0	\N	0	2026-09-13 08:06:26.943876
j7xmoRH2rzo	0	0	\N	0	2026-09-13 08:04:48.235092
muLRYXpkVWA	0	0	\N	0	2026-09-13 08:06:19.001339
SS61lwI_i5Q	0	0	\N	0	2026-09-13 08:20:20.943281
atkvEdcPidM	0	0	\N	0	2026-09-06 08:41:17.107595
dudb29Xqo60	0	0	\N	0	2026-09-06 08:53:13.551357
9jXcNZyYza8	0	0	\N	0	2026-09-06 09:14:07.3586
BMh9Xq36RrA	0	0	\N	0	2026-09-13 08:22:34.508287
eC_j1wlFJBw	0	0	\N	0	2026-09-06 09:30:05.833783
Q-IS9K8g294	0	0	\N	0	2026-09-06 09:52:18.827983
p03EyeJlM-k	0	0	\N	0	2026-09-06 12:19:14.187832
229XDzxoc4g	0	0	\N	0	2026-09-06 13:26:52.660817
j4CtPMW-1Q4	0	0	\N	0	2026-09-06 13:43:57.675416
iLZVyccaTJs	0	0	\N	0	2026-09-06 13:51:03.028232
xBun0zPGZDA	0	0	\N	0	2026-09-06 15:05:42.270667
4B4aAW76GLQ	0	0	\N	0	2026-09-07 09:04:23.739817
YaAKtkecoRc	0	0	\N	0	2026-09-08 11:27:20.802552
Mp1WHa-CXfw	0	0	\N	0	2026-09-09 14:55:59.402702
D4KiNRb7UTk	0	0	\N	0	2026-09-09 16:51:44.575471
yBnFHlmgMFQ	0	0	\N	0	2026-09-09 23:48:51.46802
bLwR73Y2d0w	0	0	\N	0	2026-09-10 10:04:13.605465
Pnh6g6K9y8Q	0	0	\N	0	2026-09-10 17:22:57.565114
DNIHqPqY3VM	0	0	\N	0	2026-09-10 18:32:28.286194
Mkx7Qp8nCys	0	0	\N	0	2026-09-10 18:44:13.592751
a6DGQWZ57EE	0	0	\N	0	2026-09-10 19:33:03.635723
pl90QEsoKFk	0	0	\N	0	2026-09-10 23:10:00.515414
_6qJfWvvWJo	0	0	\N	0	2026-09-10 20:01:40.055997
NVbNJeWZ1Lo	0	0	\N	0	2026-09-10 20:21:07.431547
3LCJCKfRATo	0	0	\N	0	2026-09-10 23:30:52.664773
mK2nGGZFRVI	0	0	\N	0	2026-09-11 10:53:51.650803
A2U9omXQ2go	0	0	\N	0	2026-09-11 13:05:32.12302
fsSkI-1Opvk	0	0	\N	0	2026-09-11 22:58:05.388618
pbU_sJKSfrg	0	0	\N	0	2026-09-11 22:58:06.014146
W1nCo6y71R8	0	0	\N	0	2026-09-11 22:58:06.303119
xj4emmUcJGE	0	0	\N	0	2026-09-11 22:58:07.287609
w2UTdzsuads	0	0	\N	0	2026-09-11 22:58:07.599184
SOKrC7BJ418	0	0	\N	0	2026-09-11 22:58:07.871575
PaYUzmc11E8	0	0	\N	0	2026-09-11 22:58:08.189019
0KAZqj8-gFo	0	0	\N	0	2026-09-11 22:58:08.519442
\.


--
-- Data for Name: retention_curve; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.retention_curve (id, video_id, timestamp_seconds, retention_pct, is_key_moment, moment_type, moment_note) FROM stdin;
263	2jcdStwq2yY	0.00	100.00	f	hook	Video start
264	2jcdStwq2yY	8.00	95.00	f	hook	After hook (8s)
265	2jcdStwq2yY	22.00	88.50	t	spike	Nice work! This video has a part that kept your viewers watching for longer than usual.
266	2jcdStwq2yY	46.00	88.50	f	end	End of video
267	yDKB-xCaMB8	0.00	100.00	t	start	Video start
268	yDKB-xCaMB8	5.00	60.00	f	\N	\N
269	yDKB-xCaMB8	16.00	25.50	t	average_view_duration	Average view duration - 25.5% stayed
270	yDKB-xCaMB8	30.00	25.50	t	spike	Nice work! This video has a part that kept viewers watching longer than usual
271	yDKB-xCaMB8	61.00	25.50	t	completion	End of video - completion
272	rg5iPj-249o	0.00	100.00	t	start	Video start
273	rg5iPj-249o	5.00	60.00	f	\N	\N
274	rg5iPj-249o	25.00	26.70	t	average_view_duration	Average view duration - 26.7% stayed
275	rg5iPj-249o	35.00	26.70	t	spike	Nice work! This video has a part that kept viewers watching longer than usual
276	rg5iPj-249o	61.00	26.70	t	completion	End of video - completion
277	waW201cvfl8	0.00	100.00	t	start	Video start
278	waW201cvfl8	5.00	70.00	f	\N	\N
279	waW201cvfl8	15.00	49.80	t	average_view_duration	Average view duration - 49.8% stayed
280	waW201cvfl8	30.00	14.00	t	spike	14% of viewers still watching at 0:30 mark
281	waW201cvfl8	61.00	49.80	t	completion	End of video - completion
282	Ay9K30yrg8Y	0.00	100.00	t	start	Video start
283	Ay9K30yrg8Y	5.00	50.00	f	\N	\N
206	5goNjmztwqg	0.00	100.00	t	start	Video start
207	5goNjmztwqg	5.00	85.00	f	\N	\N
208	5goNjmztwqg	10.00	78.00	f	\N	\N
209	5goNjmztwqg	15.00	75.00	f	\N	\N
210	5goNjmztwqg	20.00	73.00	f	\N	\N
211	5goNjmztwqg	27.00	71.40	t	average_view_duration	Average view duration - 71.4% stayed
212	5goNjmztwqg	30.00	68.00	f	\N	\N
213	5goNjmztwqg	40.00	55.00	f	\N	\N
214	5goNjmztwqg	52.00	45.00	t	completion	End of video - completion
215	0jstRcQmAro	0.00	100.00	t	start	Video start
216	0jstRcQmAro	15.00	65.00	f	\N	\N
217	0jstRcQmAro	28.00	50.00	t	average_view_duration	Average view duration - 50.0% stayed
218	0jstRcQmAro	60.00	47.00	t	completion	End of video - completion
231	XWFbqR_9fqc	0.00	100.00	f	\N	\N
232	XWFbqR_9fqc	27.00	58.30	t	stayed_watch	58.3% stayed to watch at 0:27
233	XWFbqR_9fqc	58.00	46.60	t	completion	46.6% completion rate
234	Pwp0zPAY6Y4	0.00	100.00	f	\N	\N
235	Pwp0zPAY6Y4	20.00	57.90	t	stayed_watch	57.9% stayed to watch at 0:20
236	Pwp0zPAY6Y4	58.00	34.50	t	completion	34.5% completion rate
237	s_PoEssiuPo	0.00	100.00	f	\N	\N
238	s_PoEssiuPo	20.00	50.80	t	stayed_watch	50.8% stayed to watch at 0:20
239	s_PoEssiuPo	58.00	34.50	t	completion	34.5% completion rate
254	OkWbChCIb04	0.00	100.00	f	hook	Video start
255	OkWbChCIb04	8.00	80.00	f	hook	After hook (8s)
256	OkWbChCIb04	16.00	24.20	t	spike	Nice work! This video has a part that kept your viewers watching for longer than usual.
257	OkWbChCIb04	30.00	20.00	f	drop	Mid-video drop
258	OkWbChCIb04	61.00	24.20	f	end	End of video
142	UTeogxHwnPw	0.00	100.00	f	hook	Video start
143	UTeogxHwnPw	8.00	83.30	f	hook	After hook (8s)
144	UTeogxHwnPw	17.00	60.00	t	spike	Nice work! This video has a part that kept your viewers watching for longer than usual.
145	UTeogxHwnPw	25.00	45.00	f	drop	Mid-video drop
146	UTeogxHwnPw	40.00	25.00	f	drop	Late drop
147	UTeogxHwnPw	51.00	16.70	f	end	End of video
148	zdOSsbqouKE	0.00	100.00	f	hook	Video start
149	zdOSsbqouKE	8.00	85.00	f	hook	After hook (8s)
150	zdOSsbqouKE	14.00	60.00	t	spike	Nice work! This video has a part that kept your viewers watching for longer than usual.
151	zdOSsbqouKE	25.00	40.00	f	drop	Mid-video drop
152	zdOSsbqouKE	35.00	30.00	f	drop	Late drop
153	zdOSsbqouKE	49.00	23.70	f	end	End of video
154	12BKLbv0Eso	0.00	100.00	f	hook	Video start
155	12BKLbv0Eso	10.00	85.00	f	hook	After hook (10s)
156	12BKLbv0Eso	30.00	48.00	t	spike	48% of viewers are still watching at around the 0:30 mark, which is typical. Learn more by comparing to your other videos.
157	12BKLbv0Eso	45.00	55.00	t	spike	Nice work! This video has a part that kept your viewers watching for longer than usual.
158	12BKLbv0Eso	61.00	62.40	f	end	End of video
159	XM1AzgVMeqk	0.00	100.00	f	hook	Video start
160	XM1AzgVMeqk	10.00	80.00	f	hook	After hook (10s)
161	XM1AzgVMeqk	30.00	39.00	t	spike	39% of viewers are still watching at around the 0:30 mark, which is typical. Learn more by comparing to your other videos.
162	XM1AzgVMeqk	45.00	50.00	t	spike	Nice work! This video has a part that kept your viewers watching for longer than usual.
163	XM1AzgVMeqk	60.00	45.30	f	end	End of video
164	nJNR60Ms1BE	0.00	100.00	f	hook	Video start
165	nJNR60Ms1BE	10.00	80.00	f	hook	After hook (10s)
166	nJNR60Ms1BE	24.00	31.50	t	spike	Nice work! This video has a part that kept your viewers watching for longer than usual.
167	nJNR60Ms1BE	40.00	40.00	f	drop	Mid-video drop
168	nJNR60Ms1BE	61.00	31.50	f	end	End of video
169	_A5Idj7SddI	0.00	100.00	f	hook	Video start
170	_A5Idj7SddI	8.00	80.00	f	hook	After hook (8s)
171	_A5Idj7SddI	16.00	54.60	t	spike	Nice work! This video has a part that kept your viewers watching for longer than usual.
172	_A5Idj7SddI	29.00	54.60	f	end	End of video
173	BJ5lJob_sDU	0.00	100.00	f	hook	Video start
174	BJ5lJob_sDU	10.00	80.00	f	hook	After hook (10s)
175	BJ5lJob_sDU	21.00	34.50	t	spike	Nice work! This video has a part that kept your viewers watching for longer than usual.
176	BJ5lJob_sDU	39.00	34.50	f	end	End of video
284	Ay9K30yrg8Y	10.00	25.20	t	average_view_duration	Average view duration - 25.2% stayed
285	Ay9K30yrg8Y	20.00	25.20	t	spike	Nice work! This video has a part that kept viewers watching longer than usual
286	Ay9K30yrg8Y	43.00	25.20	t	completion	End of video - completion
287	lmbndk-Db-Q	0.00	100.00	t	start	Video start
288	lmbndk-Db-Q	5.00	65.00	f	\N	\N
289	lmbndk-Db-Q	13.00	32.00	t	average_view_duration	Average view duration - 32.0% stayed
290	lmbndk-Db-Q	30.00	32.00	t	spike	Nice work! This video has a part that kept viewers watching longer than usual
291	lmbndk-Db-Q	55.00	32.00	t	completion	End of video - completion
292	cSapjDf5CHY	0.00	100.00	t	start	Video start
293	cSapjDf5CHY	5.00	70.00	f	\N	\N
294	cSapjDf5CHY	13.00	37.70	t	average_view_duration	Average view duration - 37.7% stayed
295	cSapjDf5CHY	20.00	37.70	t	spike	Nice work! This video has a part that kept viewers watching longer than usual
296	cSapjDf5CHY	31.00	37.70	t	completion	End of video - completion
297	JmSdjrAxNFM	0.00	100.00	f	hook	Video start
298	JmSdjrAxNFM	11.00	23.70	t	spike	Nice work! This video has a part that kept your viewers watching for longer than usual.
299	JmSdjrAxNFM	50.00	23.70	f	end	End of video
300	MpQ-K2D9Ao4	0.00	100.00	f	hook	Video start
301	MpQ-K2D9Ao4	16.00	41.50	t	spike	Nice work! This video has a part that kept your viewers watching for longer than usual.
302	MpQ-K2D9Ao4	56.00	41.50	f	end	End of video
303	bXetyvX2Mu8	0.00	100.00	f	hook	Video start
304	bXetyvX2Mu8	16.00	27.30	t	spike	Nice work! This video has a part that kept your viewers watching for longer than usual.
305	bXetyvX2Mu8	30.00	18.00	f	drop	18% of viewers are still watching at around the 0:30 mark, which is typical.
306	bXetyvX2Mu8	60.00	27.30	f	end	End of video
307	pHfj5VVN0Ew	0.00	100.00	f	hook	Video start
308	pHfj5VVN0Ew	17.00	47.90	t	spike	Nice work! This video has a part that kept your viewers watching for longer than usual.
309	pHfj5VVN0Ew	49.00	47.90	f	end	End of video
310	dpTHfuBYClo	0.00	100.00	f	hook	Video start
311	dpTHfuBYClo	18.00	37.50	t	spike	Nice work! This video has a part that kept your viewers watching for longer than usual.
312	dpTHfuBYClo	57.00	37.50	f	end	End of video
530	eC_j1wlFJBw	0.00	100.00	f	hook	Video start
531	eC_j1wlFJBw	15.00	60.00	f	hook	After hook (15s)
532	eC_j1wlFJBw	30.00	35.00	f	mid	Mid point
533	eC_j1wlFJBw	45.00	25.00	f	mid	Before end
534	eC_j1wlFJBw	53.00	19.00	t	spike	Nice work! This video has a part that kept your viewers watching for longer than usual.
545	p03EyeJlM-k	0.00	100.00	f	hook	Video start
546	p03EyeJlM-k	15.00	50.00	f	hook	After hook (15s)
547	p03EyeJlM-k	30.00	30.00	f	mid	Mid point
548	p03EyeJlM-k	45.00	28.00	f	mid	Before end
549	p03EyeJlM-k	60.00	26.50	t	spike	End of video - 26.5% retention
323	sHwtsGShqjE	0.00	100.00	t	hook	Start
324	sHwtsGShqjE	5.00	85.00	f	\N	\N
325	sHwtsGShqjE	10.00	55.00	f	\N	\N
326	sHwtsGShqjE	15.00	45.00	t	spike	Nice work! This video has a part that kept your viewers watching for longer than usual.
327	sHwtsGShqjE	37.00	38.40	t	end	End
328	Wyt0zC-zadM	0.00	100.00	f	\N	\N
329	Wyt0zC-zadM	13.00	27.60	t	average_view_duration	Average view duration - 27.6% retention
330	Wyt0zC-zadM	30.00	12.00	t	midpoint	12% still watching at 0:30 mark
331	Wyt0zC-zadM	60.00	27.60	t	completion	End screen - 27.6% completion
332	JRrvbkvRyiI	0.00	100.00	f	\N	\N
333	JRrvbkvRyiI	14.00	38.70	t	average_view_duration	Average view duration - 38.7% retention
334	JRrvbkvRyiI	16.50	30.00	t	midpoint	Midpoint of 33s video
335	JRrvbkvRyiI	33.00	38.70	t	completion	End screen - 38.7% completion
336	pTiZBob0vWA	0.00	100.00	f	\N	\N
337	pTiZBob0vWA	19.00	42.20	t	average_view_duration	Average view duration - 42.2% retention
338	pTiZBob0vWA	26.00	35.00	t	midpoint	Midpoint of 52s video
339	pTiZBob0vWA	52.00	42.20	t	completion	End screen - 42.2% completion
340	F6g5hMAUH6A	0.00	100.00	f	\N	\N
341	F6g5hMAUH6A	14.00	36.70	t	average_view_duration	Average view duration - 36.7% retention
342	F6g5hMAUH6A	25.00	30.00	t	midpoint	Midpoint of 50s video
343	F6g5hMAUH6A	50.00	36.70	t	completion	End - 36.7% completion
344	durkT5BI9-0	0.00	100.00	f	\N	\N
345	durkT5BI9-0	11.00	40.30	t	average_view_duration	Average view duration - 40.3% retention
346	durkT5BI9-0	23.50	32.00	t	midpoint	Midpoint of 47s video
347	durkT5BI9-0	47.00	40.30	t	completion	End - 40.3% completion
348	-ntsqYRrjic	0.00	100.00	f	\N	\N
349	-ntsqYRrjic	19.00	45.80	t	average_view_duration	Average view duration - 45.8% retention
350	-ntsqYRrjic	26.00	38.00	t	midpoint	Midpoint of 52s video
351	-ntsqYRrjic	52.00	45.80	t	completion	End screen - 45.8% completion
352	kQlrFbAzvro	0.00	100.00	f	\N	\N
353	kQlrFbAzvro	26.00	60.30	t	average_view_duration	Average view duration - 60.3% retention
354	kQlrFbAzvro	30.50	44.00	t	midpoint	44% still watching at 0:30 mark
355	kQlrFbAzvro	61.00	60.30	t	completion	End - 60.3% completion
920	wnp9gFm7ZpY	0.00	100.00	t	hook	Opening hook
921	wnp9gFm7ZpY	30.00	65.00	f	mid	Mid-point retention
922	wnp9gFm7ZpY	60.00	30.00	t	end	End retention
929	rrTB_XW3pWA	0.00	100.00	t	hook	Opening hook
360	VkXC2gAxVvs	0.00	100.00	f	\N	\N
361	VkXC2gAxVvs	12.00	34.20	t	average_view_duration	Average view duration - 34.2% retention
362	VkXC2gAxVvs	19.00	28.00	t	midpoint	Midpoint of 38s video
363	VkXC2gAxVvs	38.00	34.20	t	completion	End - 34.2% completion
364	QC45KrzAuLs	0.00	100.00	f	\N	\N
365	QC45KrzAuLs	15.00	22.50	t	average_view_duration	Average view duration - 22.5% retention
366	QC45KrzAuLs	30.50	17.00	t	midpoint	17% still watching at 0:30 mark
367	QC45KrzAuLs	61.00	22.50	t	completion	End screen - 22.5% completion
368	gNgwb1lmKL8	0.00	100.00	f	\N	\N
369	gNgwb1lmKL8	20.00	36.80	t	average_view_duration	Average view duration - 36.8% retention
370	gNgwb1lmKL8	30.50	25.00	t	midpoint	25% still watching at 0:30 mark
371	gNgwb1lmKL8	61.00	36.80	t	completion	End screen - 36.8% completion
372	XlOAFuUr7F4	0.00	100.00	f	\N	\N
373	XlOAFuUr7F4	20.00	28.00	t	average_view_duration	Average view duration - 28.0% retention
374	XlOAFuUr7F4	28.50	22.00	t	midpoint	Midpoint of 57s video
375	XlOAFuUr7F4	57.00	28.00	t	completion	End - 28.0% completion
376	d-p-YuOjU-8	0.00	100.00	f	\N	\N
377	d-p-YuOjU-8	27.00	43.10	t	average_view_duration	Average view duration - 43.1% retention
378	d-p-YuOjU-8	30.50	42.00	t	midpoint	42% still watching at 0:30 mark
379	d-p-YuOjU-8	61.00	43.10	t	completion	End screen - 43.1% completion
380	7L-wWpll_GU	0.00	100.00	f	\N	\N
381	7L-wWpll_GU	18.00	23.50	t	average_view_duration	Average view duration - 23.5% retention
382	7L-wWpll_GU	28.50	18.00	t	midpoint	Midpoint of 57s video
383	7L-wWpll_GU	57.00	23.50	t	completion	End - 23.5% completion
535	Q-IS9K8g294	0.00	100.00	f	hook	Video start
536	Q-IS9K8g294	15.00	60.00	f	hook	After hook (15s)
537	Q-IS9K8g294	30.00	40.00	f	mid	Mid point
538	Q-IS9K8g294	45.00	30.00	f	mid	Before end
388	pszcrf0uTbQ	0.00	100.00	f	\N	\N
389	pszcrf0uTbQ	35.00	55.10	t	average_view_duration	Average view duration - 55.1% retention
390	pszcrf0uTbQ	30.00	58.00	t	midpoint	58% still watching at 0:30 mark
391	pszcrf0uTbQ	60.00	55.10	t	completion	End screen - 55.1% completion
392	EDNdXwv7W64	0.00	100.00	f	\N	\N
393	EDNdXwv7W64	30.00	52.00	t	midpoint	52% still watching at 0:30 mark
394	EDNdXwv7W64	31.00	42.40	t	average_view_duration	Average view duration - 42.4% retention
395	EDNdXwv7W64	61.00	42.40	t	completion	End screen - 42.4% completion
396	DdMa3y_sImk	0.00	100.00	f	\N	\N
397	DdMa3y_sImk	14.00	45.60	t	average_view_duration	Average view duration - 45.6% retention
398	DdMa3y_sImk	30.00	9.00	t	midpoint	9% still watching at 0:30 mark
399	DdMa3y_sImk	60.00	45.60	t	completion	End screen - 45.6% completion
400	YFnY2guPlxg	0.00	100.00	f	\N	\N
401	YFnY2guPlxg	14.00	34.60	t	average_view_duration	Average view duration - 34.6% retention
402	YFnY2guPlxg	19.50	20.00	t	midpoint	20% still watching at midpoint
403	YFnY2guPlxg	39.00	34.60	t	completion	End screen - 34.6% completion
404	noF6FnkgYmE	0.00	100.00	f	\N	\N
405	noF6FnkgYmE	18.00	17.80	t	average_view_duration	Average view duration - 17.8% retention
406	noF6FnkgYmE	26.00	9.00	t	midpoint	9% still watching at midpoint
407	noF6FnkgYmE	52.00	17.80	t	completion	End screen - 17.8% completion
408	tyxuLrd-xo4	0.00	100.00	f	\N	\N
409	tyxuLrd-xo4	15.00	27.10	t	average_view_duration	Average view duration - 27.1% retention
410	tyxuLrd-xo4	25.00	15.00	t	midpoint	15% still watching at midpoint
411	tyxuLrd-xo4	50.00	27.10	t	completion	End screen - 27.1% completion
412	UzWyYR6WM6U	0.00	100.00	f	\N	\N
413	UzWyYR6WM6U	15.00	35.80	t	average_view_duration	Average view duration - 35.8% retention
414	UzWyYR6WM6U	21.50	20.00	t	midpoint	20% still watching at midpoint
415	UzWyYR6WM6U	43.00	35.80	t	completion	End screen - 35.8% completion
416	3gSWKoBeqnw	0.00	100.00	f	\N	\N
417	3gSWKoBeqnw	12.00	27.10	t	average_view_duration	Average view duration - 27.1% retention
418	3gSWKoBeqnw	28.00	10.00	t	midpoint	10% still watching at midpoint
419	3gSWKoBeqnw	56.00	27.10	t	completion	End screen - 27.1% completion
420	impBBFcUinY	0.00	100.00	f	\N	\N
421	impBBFcUinY	14.00	33.70	t	average_view_duration	Average view duration - 33.7% retention
422	impBBFcUinY	28.50	20.00	t	midpoint	20% still watching at midpoint
423	impBBFcUinY	57.00	33.70	t	completion	End screen - 33.7% completion
539	Q-IS9K8g294	59.00	25.10	t	spike	Nice work! This video has a part that kept your viewers watching for longer than usual.
550	229XDzxoc4g	0.00	100.00	f	hook	Video start
551	229XDzxoc4g	30.00	19.00	f	mid	19% viewers watching at 0:30
552	229XDzxoc4g	61.00	25.60	t	spike	Nice work! This video has a part that kept your viewers watching for longer than usual.
428	kIrFARfeW5o	0.00	100.00	f	\N	\N
429	kIrFARfeW5o	19.00	39.50	t	average_view_duration	Average view duration - 39.5% retention
430	kIrFARfeW5o	25.00	20.00	t	midpoint	20% still watching at midpoint
431	kIrFARfeW5o	50.00	39.50	t	completion	End screen - 39.5% completion
561	iLZVyccaTJs	0.00	100.00	f	hook	Video start
716	_6qJfWvvWJo	0.00	100.00	t	hook	Opening hook
717	_6qJfWvvWJo	15.00	60.00	f	mid	Middle retention
718	_6qJfWvvWJo	61.00	32.00	t	end	End retention
722	NVbNJeWZ1Lo	0.00	100.00	t	hook	Opening hook
444	FwuhJ23l7R4	0.00	100.00	f	\N	\N
445	FwuhJ23l7R4	8.00	85.00	t	midpoint	85% still watching at midpoint
446	FwuhJ23l7R4	16.00	67.80	t	average_view_duration	Average view duration & completion - 67.8% retention (full watch)
456	tO8vEcWUFXs	0.00	100.00	f	hook	Video start
457	tO8vEcWUFXs	21.00	26.50	t	spike	Nice work! This video has a part that kept your viewers watching for longer than usual.
458	tO8vEcWUFXs	42.00	26.50	f	end	End of video
459	m1qgKExs2BY	0.00	100.00	f	hook	Video start
460	m1qgKExs2BY	20.00	42.70	t	spike	Nice work! This video has a part that kept your viewers watching for longer than usual.
461	m1qgKExs2BY	39.00	42.70	f	end	End of video
462	_vTmJ79_4ho	0.00	100.00	f	hook	Video start
463	_vTmJ79_4ho	23.00	20.80	t	spike	Nice work! This video has a part that kept your viewers watching for longer than usual.
464	_vTmJ79_4ho	45.00	20.80	f	end	End of video
930	rrTB_XW3pWA	30.00	78.10	f	mid	Mid-point retention
931	rrTB_XW3pWA	60.00	56.20	t	end	End retention
553	j4CtPMW-1Q4	0.00	100.00	f	hook	Start
554	j4CtPMW-1Q4	48.00	25.90	t	spike	Nice work!
935	AwJoDsJiAoQ	0.00	100.00	t	hook	Opening hook
723	NVbNJeWZ1Lo	15.00	61.40	f	mid	Mid retention at 15s
724	NVbNJeWZ1Lo	61.00	35.00	t	end	End retention
562	iLZVyccaTJs	30.00	15.00	f	mid	30s mark
563	iLZVyccaTJs	61.00	39.20	t	spike	Nice work! This video has a part that kept your viewers watching for longer than usual.
564	xBun0zPGZDA	0.00	100.00	f	hook	Start
565	xBun0zPGZDA	39.00	33.50	t	spike	Nice work!
936	AwJoDsJiAoQ	30.00	67.00	f	mid	Mid-point retention
937	AwJoDsJiAoQ	60.00	34.00	t	end	End retention
947	hiP5k2gClN0	0.00	100.00	t	hook	Opening hook
948	hiP5k2gClN0	30.00	80.00	f	mid	Mid-point retention
949	hiP5k2gClN0	60.00	60.10	t	end	End retention
953	DrhZsdeBj6k	0.00	100.00	t	hook	Opening hook
578	4B4aAW76GLQ	0.00	100.00	t	hook	Opening hook
579	4B4aAW76GLQ	15.00	50.00	f	mid	
580	4B4aAW76GLQ	30.00	25.00	f	mid	
581	4B4aAW76GLQ	45.00	15.00	f	mid	
582	4B4aAW76GLQ	61.00	35.30	t	end	End of video
583	LQ7ttolwjJQ	0.00	100.00	t	hook	Opening hook
584	LQ7ttolwjJQ	15.00	40.00	f	mid	
585	LQ7ttolwjJQ	30.00	25.00	f	mid	
586	LQ7ttolwjJQ	45.00	18.00	f	mid	
587	LQ7ttolwjJQ	61.00	14.20	t	end	End of video
588	zqqcLDVZxR8	0.00	100.00	t	hook	Opening hook
589	zqqcLDVZxR8	10.00	45.00	f	mid	
590	zqqcLDVZxR8	20.00	25.00	f	mid	
591	zqqcLDVZxR8	30.00	18.00	f	mid	
592	zqqcLDVZxR8	40.00	17.30	t	end	End of video
737	pl90QEsoKFk	0.00	100.00	t	hook	Opening hook
738	pl90QEsoKFk	15.00	60.00	f	mid	Middle retention
739	pl90QEsoKFk	58.00	29.60	t	end	End retention
740	3LCJCKfRATo	0.00	100.00	t	hook	Opening hook
512	atkvEdcPidM	0.00	100.00	f	hook	Video start
513	atkvEdcPidM	15.00	70.00	f	hook	After hook (15s)
514	atkvEdcPidM	30.00	8.00	t	spike	Nice work! This video has a part that kept your viewers watching for longer than usual.
515	atkvEdcPidM	45.00	5.00	f	mid	Before end
516	atkvEdcPidM	61.00	34.70	t	spike	End of video - 34.7% stayed to watch
517	dudb29Xqo60	0.00	100.00	f	hook	Video start
518	dudb29Xqo60	7.00	75.00	f	hook	After hook (7s)
519	dudb29Xqo60	14.00	60.00	t	spike	Nice work! This video has a part that kept your viewers watching for longer than usual.
520	dudb29Xqo60	21.00	50.00	f	mid	Mid point
521	dudb29Xqo60	27.00	48.20	t	spike	Video end - 48.2% retention
522	9jXcNZyYza8	0.00	100.00	f	hook	Video start
523	9jXcNZyYza8	30.00	27.00	t	spike	Nice work! This video has a part that kept your viewers watching for longer than usual.
524	9jXcNZyYza8	59.00	27.00	f	end	End of video
741	3LCJCKfRATo	15.00	60.00	f	mid	Middle retention
742	3LCJCKfRATo	57.00	32.00	t	end	End retention
743	mK2nGGZFRVI	0.00	100.00	t	hook	Opening hook
744	mK2nGGZFRVI	15.00	60.00	f	mid	Middle retention
745	mK2nGGZFRVI	49.00	32.00	t	end	End retention
954	DrhZsdeBj6k	30.00	88.20	f	mid	Mid-point retention
603	YaAKtkecoRc	0.00	100.00	t	hook	Opening hook
604	YaAKtkecoRc	10.00	55.00	f	mid	After hook
605	YaAKtkecoRc	20.00	42.00	f	mid	Mid point
606	YaAKtkecoRc	30.00	35.00	f	mid	Before end
607	YaAKtkecoRc	40.00	32.20	t	end	End of video
955	DrhZsdeBj6k	60.00	76.40	t	end	End retention
959	3JdwNxhgqN8	0.00	100.00	t	hook	Opening hook
749	A2U9omXQ2go	0.00	100.00	t	hook	Opening hook
750	A2U9omXQ2go	15.00	60.00	f	mid	Middle retention
751	A2U9omXQ2go	49.00	32.00	t	end	End retention
617	Mp1WHa-CXfw	0.00	100.00	t	hook	Title hook: FULL SCHEDULE & BROCHURE RELEASED!!
618	Mp1WHa-CXfw	15.00	70.00	f	mid	Main content retention
619	Mp1WHa-CXfw	61.00	30.80	t	end	End retention at 30.8%
639	D4KiNRb7UTk	0.00	100.00	t	hook	Title hook: NTA REPLY on Neet 2024 Results!!
640	D4KiNRb7UTk	15.00	78.00	f	mid	Main content retention
641	D4KiNRb7UTk	38.00	52.00	f	mid	Content retention mid-point
642	D4KiNRb7UTk	56.00	38.00	t	end	End retention at 38.0%
643	D4KiNRb7UTk	75.00	25.00	t	completion	End of video - completion
647	yBnFHlmgMFQ	0.00	100.00	t	hook	Opening hook
648	yBnFHlmgMFQ	15.00	60.00	f	mid	Middle retention
649	yBnFHlmgMFQ	57.00	32.00	t	end	End retention
668	bLwR73Y2d0w	0.00	100.00	t	intro	Intro
669	bLwR73Y2d0w	30.00	61.00	f	\N	\N
670	bLwR73Y2d0w	60.00	39.00	t	end	End
677	Pnh6g6K9y8Q	0.00	100.00	t	hook	Opening hook
678	Pnh6g6K9y8Q	15.00	55.00	f	mid	Middle retention
679	Pnh6g6K9y8Q	55.00	28.50	t	end	End retention
684	DNIHqPqY3VM	0.00	100.00	t	hook	Opening hook
685	DNIHqPqY3VM	27.00	33.30	t	end	End retention
692	Mkx7Qp8nCys	0.00	100.00	t	hook	Opening hook
693	Mkx7Qp8nCys	15.00	55.00	f	mid	Middle retention
694	Mkx7Qp8nCys	60.00	35.00	t	end	End retention
704	a6DGQWZ57EE	0.00	100.00	t	hook	Opening hook
705	a6DGQWZ57EE	15.00	60.00	f	mid	Middle retention
706	a6DGQWZ57EE	57.00	39.90	t	end	End retention
932	kbLQ0kJ7pYQ	0.00	100.00	t	hook	Opening hook
933	kbLQ0kJ7pYQ	30.00	63.70	f	mid	Mid-point retention
934	kbLQ0kJ7pYQ	60.00	27.40	t	end	End retention
944	ZrY0tM9yPxQ	0.00	100.00	t	hook	Opening hook
945	ZrY0tM9yPxQ	30.00	64.50	f	mid	Mid-point retention
946	ZrY0tM9yPxQ	60.00	29.00	t	end	End retention
960	3JdwNxhgqN8	30.00	75.80	f	mid	Mid-point retention
961	3JdwNxhgqN8	60.00	51.70	t	end	End retention
968	QnjyscmnjEQ	0.00	100.00	t	hook	Opening hook
969	QnjyscmnjEQ	30.00	82.40	f	mid	Mid-point retention
970	QnjyscmnjEQ	60.00	64.80	t	end	End retention
1004	j7xmoRH2rzo	0.00	100.00	t	hook	Opening hook
1005	j7xmoRH2rzo	30.00	78.00	f	mid	Mid-point retention
1006	j7xmoRH2rzo	60.00	56.10	t	end	End retention
1007	muLRYXpkVWA	0.00	100.00	t	hook	Opening hook
1008	muLRYXpkVWA	30.00	79.30	f	mid	Mid-point retention
1009	muLRYXpkVWA	60.00	58.70	t	end	End retention
1010	_gF2JDP64Yc	0.00	100.00	t	hook	Opening hook
1011	_gF2JDP64Yc	30.00	64.40	f	mid	Mid-point retention
1012	_gF2JDP64Yc	60.00	28.80	t	end	End retention
1013	5v6ouzwDdRQ	0.00	100.00	t	hook	Opening hook
1014	5v6ouzwDdRQ	30.00	66.80	f	mid	Mid-point retention
1015	5v6ouzwDdRQ	60.00	33.50	t	end	End retention
1016	4yAeMwjZxoo	0.00	100.00	t	hook	Opening hook
1017	4yAeMwjZxoo	30.00	63.90	f	mid	Mid-point retention
1018	4yAeMwjZxoo	60.00	27.80	t	end	End retention
1019	SS61lwI_i5Q	0.00	100.00	t	hook	Opening hook
1020	SS61lwI_i5Q	30.00	63.00	f	mid	Mid-point retention
1021	SS61lwI_i5Q	60.00	25.90	t	end	End retention
1022	BMh9Xq36RrA	0.00	100.00	t	hook	Opening hook
1023	BMh9Xq36RrA	30.00	68.30	f	mid	Mid-point retention
1024	BMh9Xq36RrA	60.00	36.70	t	end	End retention
857	fsSkI-1Opvk	0.00	100.00	t	hook	Opening hook
858	fsSkI-1Opvk	30.00	70.10	f	mid	Mid-point retention
859	fsSkI-1Opvk	60.00	40.20	t	end	End retention
860	pbU_sJKSfrg	0.00	100.00	t	hook	Opening hook
861	pbU_sJKSfrg	30.00	78.00	f	mid	Mid-point retention
862	pbU_sJKSfrg	60.00	55.90	t	end	End retention
863	W1nCo6y71R8	0.00	100.00	t	hook	Opening hook
864	W1nCo6y71R8	30.00	61.10	f	mid	Mid-point retention
865	W1nCo6y71R8	60.00	22.20	t	end	End retention
872	xj4emmUcJGE	0.00	100.00	t	hook	Opening hook
873	xj4emmUcJGE	30.00	77.90	f	mid	Mid-point retention
874	xj4emmUcJGE	60.00	55.80	t	end	End retention
875	w2UTdzsuads	0.00	100.00	t	hook	Opening hook
876	w2UTdzsuads	30.00	57.30	f	mid	Mid-point retention
877	w2UTdzsuads	60.00	14.60	t	end	End retention
878	SOKrC7BJ418	0.00	100.00	t	hook	Opening hook
879	SOKrC7BJ418	30.00	71.90	f	mid	Mid-point retention
880	SOKrC7BJ418	60.00	43.80	t	end	End retention
881	PaYUzmc11E8	0.00	100.00	t	hook	Opening hook
882	PaYUzmc11E8	30.00	71.00	f	mid	Mid-point retention
883	PaYUzmc11E8	60.00	41.90	t	end	End retention
884	0KAZqj8-gFo	0.00	100.00	t	hook	Opening hook
885	0KAZqj8-gFo	30.00	81.50	f	mid	Mid-point retention
886	0KAZqj8-gFo	60.00	63.00	t	end	End retention
\.


--
-- Data for Name: search_terms; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.search_terms (id, video_id, search_term, views, percentage_of_search, percentage_of_total, intent_category, relevance_score, fetched_at) FROM stdin;
89	s_PoEssiuPo	jee mains tricks	4	10.50	11.80	educational_query	1	2026-09-02 10:03:18.329293
90	s_PoEssiuPo	jee exam tips	2	5.30	5.90	educational_query	1	2026-09-02 10:03:18.329293
394	xBun0zPGZDA	dtu exam today	9	1.90	1.90	related	3	2026-09-06 15:05:42.270667
395	xBun0zPGZDA	jac delhi	9	1.90	1.90	related	3	2026-09-06 15:05:42.270667
396	xBun0zPGZDA	jee advanced motivation	9	1.90	1.90	related	3	2026-09-06 15:05:42.270667
95	OkWbChCIb04	biwi no 1 movie	1	20.00	2.00	noise	1	2026-09-02 10:43:00.55935
96	OkWbChCIb04	venom dikhao	1	20.00	2.00	noise	1	2026-09-02 10:43:00.55935
97	yDKB-xCaMB8	jee mains 2024	5	12.00	11.60	exam_info	8	2026-09-02 14:30:31.576863
98	yDKB-xCaMB8	iit package reality	2	4.00	4.70	career_info	6	2026-09-02 14:30:31.576863
99	yDKB-xCaMB8	iit topper then vs now	2	4.00	4.70	career_info	6	2026-09-02 14:30:31.576863
100	yDKB-xCaMB8	jee mains details	2	4.00	4.70	exam_info	7	2026-09-02 14:30:31.576863
101	yDKB-xCaMB8	jee mains tips and tricks	2	4.00	4.70	study_help	7	2026-09-02 14:30:31.576863
102	rg5iPj-249o	is neet 2024 date changed	9	9.50	9.90	exam_info	9	2026-09-02 14:58:55.032747
103	waW201cvfl8	e summit 24	20	19.10	19.00	event_info	8	2026-09-02 15:14:09.210888
104	waW201cvfl8	angreji beat de song	5	4.80	4.80	music	5	2026-09-02 15:14:09.210888
105	waW201cvfl8	gangubai kathiawadi song	5	4.80	4.80	music	5	2026-09-02 15:14:09.210888
106	waW201cvfl8	iit inspiration	5	4.80	4.80	motivation	6	2026-09-02 15:14:09.210888
107	waW201cvfl8	yimmy yimmy	5	4.80	4.80	music	5	2026-09-02 15:14:09.210888
108	Ay9K30yrg8Y	arjuna jee 2025 faculty	29	6.50	6.60	faculty_info	5	2026-09-02 15:27:50.633383
109	Ay9K30yrg8Y	aarush bhola podcast	14	3.20	3.20	entertainment	3	2026-09-02 15:27:50.633383
110	Ay9K30yrg8Y	arbaaz sohail roast	14	3.20	3.20	entertainment	3	2026-09-02 15:27:50.633383
111	Ay9K30yrg8Y	chemical equilibrium class 11 one shot	14	3.20	3.20	study_help	6	2026-09-02 15:27:50.633383
112	Ay9K30yrg8Y	crispy chicken recipe	14	3.20	3.20	irrelevant	1	2026-09-02 15:27:50.633383
113	lmbndk-Db-Q	how to crack jee	21	14.30	14.30	study_help	7	2026-09-02 21:49:28.223132
114	lmbndk-Db-Q	iit jee maths	21	14.30	14.30	study_help	7	2026-09-02 21:49:28.223132
115	lmbndk-Db-Q	jee mains	21	14.30	14.30	exam_info	8	2026-09-02 21:49:28.223132
116	cSapjDf5CHY	jee mains admit card	18	40.00	4.50	admit_card	9	2026-09-02 23:46:30.338612
117	cSapjDf5CHY	jee mains april admit card	12	26.70	3.00	admit_card	9	2026-09-02 23:46:30.338612
118	cSapjDf5CHY	admit card link	8	17.80	2.00	admit_card	8	2026-09-02 23:46:30.338612
119	cSapjDf5CHY	nta admit card	7	15.60	1.80	admit_card	8	2026-09-02 23:46:30.338612
120	JmSdjrAxNFM	class 8 math	2	8.30	1.60	noise	1	2026-09-03 08:43:48.484092
121	JmSdjrAxNFM	how to decrease thigh fat for men	2	8.30	1.60	noise	1	2026-09-03 08:43:48.484092
122	JmSdjrAxNFM	jee in 3 days	2	8.30	1.60	exact_match	5	2026-09-03 08:43:48.484092
123	JmSdjrAxNFM	pyq 2024 eduniti	2	8.30	1.60	related	3	2026-09-03 08:43:48.484092
124	JmSdjrAxNFM	ssc gd answer key 2024 kab aayega	2	8.30	1.60	noise	1	2026-09-03 08:43:48.484092
125	MpQ-K2D9Ao4	92 percentile to iit	3	2.60	0.60	exact_match	5	2026-09-03 08:46:53.14088
126	MpQ-K2D9Ao4	80 percentile to iit	2	1.70	0.40	related	4	2026-09-03 08:46:53.14088
127	MpQ-K2D9Ao4	92 percentile in jee mains	2	1.70	0.40	exact_match	5	2026-09-03 08:46:53.14088
128	MpQ-K2D9Ao4	95 percentile to iit	1	0.90	0.20	related	4	2026-09-03 08:46:53.14088
129	MpQ-K2D9Ao4	dhruv rathee trolled	1	0.90	0.20	noise	1	2026-09-03 08:46:53.14088
130	bXetyvX2Mu8	champions trophy 2017 final	1	2.60	0.30	noise	1	2026-09-03 08:49:33.548839
50	UTeogxHwnPw	jagadeka veerudu 858	1	16.70	1.25	noise	1	2026-09-02 09:25:42.138615
51	UTeogxHwnPw	jee 2024 april attempt	1	16.70	1.25	exact_match	5	2026-09-02 09:25:42.138615
52	UTeogxHwnPw	vanshaj	1	16.70	1.25	noise	1	2026-09-02 09:25:42.138615
53	zdOSsbqouKE	jee mains 2024	3	11.50	3.70	exact_match	5	2026-09-02 09:25:43.634893
54	zdOSsbqouKE	jee mains update	2	7.70	2.40	exact_match	5	2026-09-02 09:25:43.634893
55	zdOSsbqouKE	iit jee exam	1	3.90	1.20	related	4	2026-09-02 09:25:43.634893
56	zdOSsbqouKE	jee latest update	1	3.90	1.20	exact_match	5	2026-09-02 09:25:43.634893
57	zdOSsbqouKE	jee main	1	3.90	1.20	related	4	2026-09-02 09:25:43.634893
58	12BKLbv0Eso	jee mains 27 jan shift 1 answer key	104	6.10	6.10	exact_match	5	2026-09-02 09:25:45.151529
59	12BKLbv0Eso	27 jan shift 1 answer key	89	5.20	5.20	exact_match	5	2026-09-02 09:25:45.151529
60	12BKLbv0Eso	jee mains 2024 27 january shift 1 answer key	82	4.80	4.80	exact_match	5	2026-09-02 09:25:45.151529
61	12BKLbv0Eso	jee main 27 jan 2024 shift 1 answer key	53	3.10	3.10	exact_match	5	2026-09-02 09:25:45.151529
62	12BKLbv0Eso	27 jan jee mains 2024 shift 1 answer key	41	2.40	2.40	exact_match	5	2026-09-02 09:25:45.151529
63	XM1AzgVMeqk	how to check answer key of jee mains 2024	26	5.40	5.40	exact_match	5	2026-09-02 09:25:46.312192
64	XM1AzgVMeqk	how to check answers of jee mains 2024	17	3.50	3.50	exact_match	5	2026-09-02 09:25:46.312192
65	XM1AzgVMeqk	how to check jee mains answer key 2024	6	1.20	1.20	exact_match	5	2026-09-02 09:25:46.312192
66	XM1AzgVMeqk	jee 2024 answer key how to check	6	1.20	1.20	exact_match	5	2026-09-02 09:25:46.312192
67	XM1AzgVMeqk	answer key jee mains 2024 kaise check kare	4	0.80	0.80	exact_match	5	2026-09-02 09:25:46.312192
68	nJNR60Ms1BE	how to challenge nta answer key	16	16.40	16.70	exact_match	5	2026-09-02 09:25:47.152763
69	nJNR60Ms1BE	nta result 2024	7	7.30	7.30	related	3	2026-09-02 09:25:47.152763
70	nJNR60Ms1BE	jee mains final answer key 2024	5	5.50	5.20	exact_match	5	2026-09-02 09:25:47.152763
71	nJNR60Ms1BE	answer key jee mains 2024	3	3.60	3.10	exact_match	5	2026-09-02 09:25:47.152763
72	nJNR60Ms1BE	jee mains 2024	3	3.60	3.10	related	3	2026-09-02 09:25:47.152763
73	_A5Idj7SddI	jee latest update	1	16.70	3.70	exact_match	5	2026-09-02 09:25:47.534266
84	5goNjmztwqg	insufficient_data	0	0.00	2.30	none	0	2026-09-02 09:45:39.987643
88	0jstRcQmAro	insufficient_data	0	0.00	13.30	none	0	2026-09-02 09:46:02.751285
131	bXetyvX2Mu8	dhruv rathee	1	2.60	0.30	noise	1	2026-09-03 08:49:33.548839
132	bXetyvX2Mu8	gaurav yaduvanshi accident	1	2.60	0.30	noise	1	2026-09-03 08:49:33.548839
133	bXetyvX2Mu8	iit bombay campus tour	1	2.60	0.30	related	3	2026-09-03 08:49:33.548839
134	bXetyvX2Mu8	iit vs mit	1	2.60	0.30	related	3	2026-09-03 08:49:33.548839
135	pHfj5VVN0Ew	allah miya bhej koi roop ki tijori	1	5.00	0.30	noise	1	2026-09-03 08:52:31.076945
136	pHfj5VVN0Ew	allen teacher	1	5.00	0.30	noise	1	2026-09-03 08:52:31.076945
137	pHfj5VVN0Ew	chemical kinetics	1	5.00	0.30	noise	1	2026-09-03 08:52:31.076945
138	pHfj5VVN0Ew	delhi status	1	5.00	0.30	noise	1	2026-09-03 08:52:31.076945
139	pHfj5VVN0Ew	doon	1	5.00	0.30	noise	1	2026-09-03 08:52:31.076945
140	dpTHfuBYClo	provisional answer key jee mains 2024	8	8.30	1.60	exact_match	5	2026-09-03 08:54:48.143719
141	dpTHfuBYClo	provisional answer key	3	3.10	0.60	exact_match	5	2026-09-03 08:54:48.143719
142	dpTHfuBYClo	jee answer key 2024 april	2	2.10	0.40	exact_match	5	2026-09-03 08:54:48.143719
143	dpTHfuBYClo	jee mains provisional answer key 2024	2	2.10	0.40	exact_match	5	2026-09-03 08:54:48.143719
144	dpTHfuBYClo	jee provisional answer key 2024	2	2.10	0.40	exact_match	5	2026-09-03 08:54:48.143719
397	xBun0zPGZDA	kapil sharma show	9	1.90	1.90	noise	1	2026-09-06 15:05:42.270667
398	xBun0zPGZDA	psi video	9	1.90	1.90	noise	1	2026-09-06 15:05:42.270667
527	D4KiNRb7UTk	NEET 2024 results	140	45.00	25.00	related	4	2026-09-09 16:51:44.575471
528	D4KiNRb7UTk	NEET UG 2024	85	27.00	15.00	related	3	2026-09-09 16:51:44.575471
529	D4KiNRb7UTk	NEET 2024 answer key	45	14.40	8.00	informational	2	2026-09-09 16:51:44.575471
155	sHwtsGShqjE	jee advanced 2024	39	7.80	7.80	exact_match	5	2026-09-03 10:11:18.411369
156	sHwtsGShqjE	jee advanced 2024 strategy	39	7.80	7.80	exact_match	5	2026-09-03 10:11:18.411369
157	sHwtsGShqjE	chammak challo	19	3.90	3.90	noise	1	2026-09-03 10:11:18.411369
158	sHwtsGShqjE	280 hz frequency	10	2.00	2.00	noise	1	2026-09-03 10:11:18.411369
159	sHwtsGShqjE	asuran full movie hindi	10	2.00	2.00	noise	1	2026-09-03 10:11:18.411369
160	Wyt0zC-zadM	saibo	1	7.10	0.70	noise	1	2026-09-03 12:28:17.67752
161	JRrvbkvRyiI	jee mains 2024	43	9.40	9.40	exact_match	5	2026-09-03 12:45:38.189925
162	JRrvbkvRyiI	jee mains result 2024	29	6.30	6.30	exact_match	5	2026-09-03 12:45:38.189925
163	JRrvbkvRyiI	nta jee mains result	29	6.30	6.30	exact_match	5	2026-09-03 12:45:38.189925
164	JRrvbkvRyiI	ambika raina upsc	14	3.10	3.10	noise	1	2026-09-03 12:45:38.189925
165	JRrvbkvRyiI	continental gt 650	14	3.10	3.10	noise	1	2026-09-03 12:45:38.189925
166	pTiZBob0vWA	jee mains result 2024	132	28.00	28.00	exact_match	5	2026-09-03 13:23:31.162254
167	pTiZBob0vWA	jee mains	38	8.00	8.00	exact_match	4	2026-09-03 13:23:31.162254
168	pTiZBob0vWA	jee mains result update	25	5.30	5.30	exact_match	5	2026-09-03 13:23:31.162254
169	pTiZBob0vWA	jee main update	19	4.00	4.00	related	4	2026-09-03 13:23:31.162254
170	pTiZBob0vWA	jee mains 2024	19	4.00	4.00	exact_match	5	2026-09-03 13:23:31.162254
171	durkT5BI9-0	what is iit	11	4.00	4.10	noise	1	2026-09-03 14:13:12.403346
172	durkT5BI9-0	iit video	7	2.70	2.60	noise	1	2026-09-03 14:13:12.403346
173	durkT5BI9-0	jee mains result	7	2.70	2.60	exact_match	5	2026-09-03 14:13:12.403346
174	durkT5BI9-0	80-90 percentile in jee mains colleges	3	1.30	1.10	related	3	2026-09-03 14:13:12.403346
175	durkT5BI9-0	answer key jee mains 2024	3	1.30	1.10	exact_match	5	2026-09-03 14:13:12.403346
176	-ntsqYRrjic	dropped questions in jee mains 2024	52	6.60	6.60	exact_match	5	2026-09-03 14:22:21.576395
177	-ntsqYRrjic	dropped questions in jee mains 2024 april	39	5.00	5.00	exact_match	5	2026-09-03 14:22:21.576395
178	-ntsqYRrjic	jee mains dropped questions 2024	25	3.20	3.20	exact_match	5	2026-09-03 14:22:21.576395
179	-ntsqYRrjic	drop question in jee mains 2024 april	16	2.10	2.00	exact_match	5	2026-09-03 14:22:21.576395
180	-ntsqYRrjic	jee main dropped questions 2024	16	2.10	2.00	exact_match	5	2026-09-03 14:22:21.576395
181	kQlrFbAzvro	how to calculate jee main marks	209	5.70	5.70	exact_match	5	2026-09-03 14:34:36.771304
182	kQlrFbAzvro	how to calculate jee main marks from answer key	206	5.60	5.60	exact_match	5	2026-09-03 14:34:36.771304
183	kQlrFbAzvro	how to calculate marks in jee mains	81	2.20	2.20	exact_match	5	2026-09-03 14:34:36.771304
184	kQlrFbAzvro	how to calculate marks from answer key jee mains	70	1.90	1.90	exact_match	5	2026-09-03 14:34:36.771304
185	kQlrFbAzvro	how to calculate jee mains marks	55	1.50	1.50	exact_match	5	2026-09-03 14:34:36.771304
820	rrTB_XW3pWA	ipu counselling 2024	9	13.50	13.50	specific	5	2026-09-12 23:25:09.52654
191	VkXC2gAxVvs	jee mains 2024 session 2 result	30	7.40	7.40	exact_match	5	2026-09-03 21:29:21.003798
192	VkXC2gAxVvs	jee mains result 2024	30	7.40	7.40	exact_match	5	2026-09-03 21:29:21.003798
193	VkXC2gAxVvs	2nd drop for jee	15	3.70	3.70	related	3	2026-09-03 21:29:21.003798
194	VkXC2gAxVvs	banking awareness playlist	15	3.70	3.70	noise	1	2026-09-03 21:29:21.003798
195	VkXC2gAxVvs	bit mesra ranchi campus tour	15	3.70	3.70	noise	1	2026-09-03 21:29:21.003798
196	QC45KrzAuLs	jee main cheating	20	3.90	3.90	noise	1	2026-09-03 21:44:00.314367
197	QC45KrzAuLs	jee mains 2024	20	3.90	3.90	exact_match	3	2026-09-03 21:44:00.314367
821	rrTB_XW3pWA	ggsipu counselling 2024	3	5.40	5.40	specific	5	2026-09-12 23:25:09.52654
822	rrTB_XW3pWA	ipu choice filling 2024	3	5.40	5.40	related	5	2026-09-12 23:25:09.52654
823	rrTB_XW3pWA	ipu counselling 2024 for ba llb	3	5.40	5.40	specific	5	2026-09-12 23:25:09.52654
824	rrTB_XW3pWA	ipu mca counselling 2024	3	5.40	5.40	specific	5	2026-09-12 23:25:09.52654
835	ZrY0tM9yPxQ	cuet admit card 2024	25	6.90	6.90	related	5	2026-09-13 00:39:03.743153
836	ZrY0tM9yPxQ	cuet 19 july	13	3.50	3.50	related	5	2026-09-13 00:39:03.743153
837	ZrY0tM9yPxQ	cuet 19 july exam	13	3.50	3.50	related	5	2026-09-13 00:39:03.743153
838	ZrY0tM9yPxQ	19 july cuet 2024	6	1.70	1.70	related	5	2026-09-13 00:39:03.743153
839	ZrY0tM9yPxQ	about bsc nursing	6	1.70	1.70	related	4	2026-09-13 00:39:03.743153
198	QC45KrzAuLs	jee mains result 2024	20	3.90	3.90	exact_match	5	2026-09-03 21:44:00.314367
199	QC45KrzAuLs	jee mains result 2024 session 2 marks vs percentile	20	3.90	3.90	exact_match	5	2026-09-03 21:44:00.314367
200	QC45KrzAuLs	jee score vs percentile 2024	20	3.90	3.90	exact_match	5	2026-09-03 21:44:00.314367
201	gNgwb1lmKL8	jee advanced 2024 eligibility criteria	30	3.10	3.10	exact_match	5	2026-09-03 22:06:49.206096
202	gNgwb1lmKL8	jee advanced eligibility criteria 2024	19	1.90	1.90	exact_match	5	2026-09-03 22:06:49.206096
203	gNgwb1lmKL8	eligibility for jee advanced 2024	13	1.30	1.30	exact_match	5	2026-09-03 22:06:49.206096
204	gNgwb1lmKL8	how to know whether i am eligible for jee advanced	13	1.30	1.30	exact_match	5	2026-09-03 22:06:49.206096
205	gNgwb1lmKL8	jee advanced results	13	1.30	1.30	related	3	2026-09-03 22:06:49.206096
206	XlOAFuUr7F4	iit patna	14	2.90	2.90	noise	1	2026-09-03 22:31:30.815574
207	XlOAFuUr7F4	aat jee advanced	7	1.50	1.50	related	3	2026-09-03 22:31:30.815574
208	XlOAFuUr7F4	can we get nit through jee advanced	7	1.50	1.50	related	3	2026-09-03 22:31:30.815574
209	XlOAFuUr7F4	chatgpt	7	1.50	1.50	noise	1	2026-09-03 22:31:30.815574
210	XlOAFuUr7F4	how to study 10th class	7	1.50	1.50	noise	1	2026-09-03 22:31:30.815574
211	d-p-YuOjU-8	jee advanced documents required 2024	45	15.10	15.00	exact_match	5	2026-09-03 22:47:40.537674
212	d-p-YuOjU-8	document for jee advanced 2024	10	3.30	3.30	exact_match	5	2026-09-03 22:47:40.537674
213	d-p-YuOjU-8	documents required for jee advanced registration 2024	5	1.60	1.60	exact_match	5	2026-09-03 22:47:40.537674
214	d-p-YuOjU-8	jee advanced application form 2024 documents required	5	1.60	1.60	exact_match	5	2026-09-03 22:47:40.537674
215	d-p-YuOjU-8	required documents for jee advanced 2024	5	1.60	1.60	exact_match	5	2026-09-03 22:47:40.537674
216	7L-wWpll_GU	chandramukhi	3	3.10	3.10	noise	1	2026-09-03 22:59:23.098487
217	7L-wWpll_GU	iit cutoff category wise	3	3.10	3.10	related	3	2026-09-03 22:59:23.098487
218	7L-wWpll_GU	iit delhi branch wise cutoff	3	3.10	3.10	related	3	2026-09-03 22:59:23.098487
219	7L-wWpll_GU	jee advanced fee payment pending	3	3.10	3.10	exact_match	5	2026-09-03 22:59:23.098487
225	pszcrf0uTbQ	jee advanced category certificate	1060	19.30	15.00	exact_match	5	2026-09-04 09:31:55.178282
226	pszcrf0uTbQ	obc ncl declaration form	700	12.70	9.90	exact_match	5	2026-09-04 09:31:55.178282
227	pszcrf0uTbQ	ews declaration form jee advanced	550	10.00	7.80	exact_match	5	2026-09-04 09:31:55.178282
228	pszcrf0uTbQ	how to apply jee advanced without certificate	400	7.30	5.70	exact_match	5	2026-09-04 09:31:55.178282
229	pszcrf0uTbQ	jee advanced registration mistake	350	6.40	4.90	exact_match	5	2026-09-04 09:31:55.178282
230	EDNdXwv7W64	jee advanced registration 2024	47	3.70	3.70	exact_match	5	2026-09-04 09:55:24.289926
231	EDNdXwv7W64	how to upload documents in jee advanced registration	34	2.70	2.70	exact_match	5	2026-09-04 09:55:24.289926
232	EDNdXwv7W64	error jee advanced	13	1.00	1.00	exact_match	4	2026-09-04 09:55:24.289926
233	EDNdXwv7W64	jee advanced registration 2024 payment problem	11	0.90	0.90	exact_match	5	2026-09-04 09:55:24.289926
234	EDNdXwv7W64	jee advanced registration last date	9	0.70	0.70	exact_match	5	2026-09-04 09:55:24.289926
235	DdMa3y_sImk	food shorts	40	12.50	12.50	broad	1	2026-09-04 12:02:37.004788
236	DdMa3y_sImk	jee 2024	40	12.50	12.50	exact_match	4	2026-09-04 12:02:37.004788
237	DdMa3y_sImk	neet	40	12.50	12.50	broad	1	2026-09-04 12:02:37.004788
238	DdMa3y_sImk	rcb	40	12.50	12.50	unrelated	0	2026-09-04 12:02:37.004788
239	YFnY2guPlxg	cbse result 2024	72	16.00	16.00	exact_match	5	2026-09-04 12:04:52.149361
240	YFnY2guPlxg	cbse result	54	12.00	12.00	exact_match	5	2026-09-04 12:04:52.149361
241	YFnY2guPlxg	cbse class 12 result date 2024	36	8.00	8.00	exact_match	5	2026-09-04 12:04:52.149361
242	YFnY2guPlxg	cbse class 10 result date 2024	18	4.00	4.00	exact_match	5	2026-09-04 12:04:52.149361
243	YFnY2guPlxg	4bhk flat design	9	2.00	2.00	unrelated	0	2026-09-04 12:04:52.149361
244	noF6FnkgYmE	jac delhi counselling 2024	3	21.40	2.90	exact_match	5	2026-09-04 12:16:10.255319
245	noF6FnkgYmE	jac delhi	2	14.30	2.00	exact_match	5	2026-09-04 12:16:10.255319
246	noF6FnkgYmE	what is jac delhi	2	14.30	2.00	exact_match	5	2026-09-04 12:16:10.255319
247	noF6FnkgYmE	dseu admission 2024	1	7.10	1.00	exact_match	4	2026-09-04 12:16:10.255319
248	noF6FnkgYmE	jac delhi counselling 2024 date	1	7.10	1.00	exact_match	5	2026-09-04 12:16:10.255319
249	tyxuLrd-xo4	ami je tomar	1	6.70	0.40	unrelated	0	2026-09-04 12:33:43.388322
250	tyxuLrd-xo4	cbse result 2024	1	6.70	0.40	exact_match	5	2026-09-04 12:33:43.388322
251	tyxuLrd-xo4	iit video	1	6.70	0.40	unrelated	0	2026-09-04 12:33:43.388322
252	tyxuLrd-xo4	kanpuriya comedy	1	6.70	0.40	unrelated	0	2026-09-04 12:33:43.388322
253	tyxuLrd-xo4	mbbs	1	6.70	0.40	unrelated	0	2026-09-04 12:33:43.388322
254	UzWyYR6WM6U	abhishek malhan	2	5.30	0.50	unrelated	0	2026-09-04 12:56:32.962168
255	UzWyYR6WM6U	aspirants poem	2	5.30	0.50	unrelated	0	2026-09-04 12:56:32.962168
256	UzWyYR6WM6U	car driving status	2	5.30	0.50	unrelated	0	2026-09-04 12:56:32.962168
257	UzWyYR6WM6U	class 11 trigonometry	2	5.30	0.50	unrelated	0	2026-09-04 12:56:32.962168
258	UzWyYR6WM6U	dhruv rathee	2	5.30	0.50	unrelated	0	2026-09-04 12:56:32.962168
259	3gSWKoBeqnw	cid	2	5.90	0.60	unrelated	0	2026-09-04 13:19:16.949153
260	3gSWKoBeqnw	cuet hall ticket	2	5.90	0.60	exact_match	5	2026-09-04 13:19:16.949153
261	3gSWKoBeqnw	hall ticket cuet	2	5.90	0.60	exact_match	5	2026-09-04 13:19:16.949153
262	3gSWKoBeqnw	how to cut a pineapple	2	5.90	0.60	unrelated	0	2026-09-04 13:19:16.949153
263	3gSWKoBeqnw	tv9 live tv telugu	2	5.90	0.60	unrelated	0	2026-09-04 13:19:16.949153
264	impBBFcUinY	cid	3	5.90	0.60	unrelated	0	2026-09-04 13:33:07.646614
265	impBBFcUinY	cuet hall ticket	3	5.90	0.60	exact_match	5	2026-09-04 13:33:07.646614
266	impBBFcUinY	hall ticket cuet	3	5.90	0.60	exact_match	5	2026-09-04 13:33:07.646614
267	impBBFcUinY	how to cut a pineapple	3	5.90	0.60	unrelated	0	2026-09-04 13:33:07.646614
268	impBBFcUinY	tv9 live tv telugu	3	5.90	0.60	unrelated	0	2026-09-04 13:33:07.646614
533	yBnFHlmgMFQ	JEE Advanced 2024 results	24	100.00	4.20	informational	3	2026-09-09 23:48:51.46802
534	yBnFHlmgMFQ	jee advanced results	12	50.00	2.10	informational	3	2026-09-09 23:48:51.46802
535	yBnFHlmgMFQ	jee 2024	8	33.30	1.40	informational	3	2026-09-09 23:48:51.46802
274	kIrFARfeW5o	cid	3	5.90	0.60	unrelated	0	2026-09-04 13:52:08.871339
275	kIrFARfeW5o	cuet hall ticket	3	5.90	0.60	exact_match	5	2026-09-04 13:52:08.871339
276	kIrFARfeW5o	hall ticket cuet	3	5.90	0.60	exact_match	5	2026-09-04 13:52:08.871339
277	kIrFARfeW5o	how to cut a pineapple	3	5.90	0.60	unrelated	0	2026-09-04 13:52:08.871339
278	kIrFARfeW5o	tv9 live tv telugu	3	5.90	0.60	unrelated	0	2026-09-04 13:52:08.871339
279	FwuhJ23l7R4	dtu classroom	11	6.50	3.40	campus_related	4	2026-09-04 15:17:53.707086
280	FwuhJ23l7R4	dtu 2024	5	2.90	1.60	campus_related	3	2026-09-04 15:17:53.707086
281	FwuhJ23l7R4	dtu	3	1.80	0.90	campus_related	3	2026-09-04 15:17:53.707086
282	FwuhJ23l7R4	dtu joa previous question paper	2	1.20	0.60	unrelated	0	2026-09-04 15:17:53.707086
283	FwuhJ23l7R4	delhi technological university	1	0.60	0.30	campus_related	3	2026-09-04 15:17:53.707086
563	Pnh6g6K9y8Q	JEE Advanced 2024 results	24	100.00	5.60	informational	3	2026-09-10 17:22:57.565114
293	tO8vEcWUFXs	bbose exam date 2024	7	25.00	3.60	noise	1	2026-09-05 19:35:09.745882
294	tO8vEcWUFXs	ek haseena thi instrumental	7	25.00	3.60	noise	1	2026-09-05 19:35:09.745882
295	tO8vEcWUFXs	ip university admission 2024	7	25.00	3.60	related	3	2026-09-05 19:35:09.745882
296	tO8vEcWUFXs	new bhojpuri song	7	25.00	3.60	noise	1	2026-09-05 19:35:09.745882
297	m1qgKExs2BY	jee advanced admit card 2024	56	34.10	22.00	specific	5	2026-09-05 19:53:35.380044
298	m1qgKExs2BY	jee adv admit card 2024	24	14.60	9.20	specific	5	2026-09-05 19:53:35.380044
299	m1qgKExs2BY	jee adv admit card	17	10.40	6.70	specific	4	2026-09-05 19:53:35.380044
300	m1qgKExs2BY	jee advanced 2024 admit card	14	8.50	5.50	specific	5	2026-09-05 19:53:35.380044
301	m1qgKExs2BY	admit card jee adv	8	4.90	3.10	specific	4	2026-09-05 19:53:35.380044
302	_vTmJ79_4ho	aishwarya cinderella gown	1	33.30	1.10	noise	1	2026-09-05 20:12:48.727333
564	Pnh6g6K9y8Q	jee advanced results	12	50.00	2.80	informational	3	2026-09-10 17:22:57.565114
565	Pnh6g6K9y8Q	jee 2024	8	33.30	1.90	informational	3	2026-09-10 17:22:57.565114
581	Mkx7Qp8nCys	JEE Advanced 2024 results	8	100.00	10.90	informational	3	2026-09-10 18:44:13.592751
582	Mkx7Qp8nCys	jee advanced results	4	50.00	4.30	informational	3	2026-09-10 18:44:13.592751
583	Mkx7Qp8nCys	jee 2024	2	25.00	2.20	informational	3	2026-09-10 18:44:13.592751
349	atkvEdcPidM	supreme court on neet ug 2024	23	20.20	11.10	related	3	2026-09-06 08:41:17.107595
350	atkvEdcPidM	neet re exam 2024 supreme court	13	11.40	6.30	related	3	2026-09-06 08:41:17.107595
351	atkvEdcPidM	supreme court decision on neet 2024	4	3.50	1.90	related	3	2026-09-06 08:41:17.107595
352	atkvEdcPidM	neet 2024 reexam	3	2.60	1.40	related	3	2026-09-06 08:41:17.107595
353	atkvEdcPidM	neet 2024 supreme court judgement	3	2.60	1.40	related	3	2026-09-06 08:41:17.107595
354	dudb29Xqo60	dtu canteen	13	1.90	1.90	related	3	2026-09-06 08:53:13.551357
355	dudb29Xqo60	dtu campus tour	8	1.20	1.20	related	3	2026-09-06 08:53:13.551357
356	dudb29Xqo60	balveer ka video	1	0.20	0.20	noise	1	2026-09-06 08:53:13.551357
357	dudb29Xqo60	cricket	1	0.20	0.20	noise	1	2026-09-06 08:53:13.551357
358	dudb29Xqo60	cricket academy	1	0.20	0.20	noise	1	2026-09-06 08:53:13.551357
359	9jXcNZyYza8	jee advanced 2024	8	88.90	11.10	specific	5	2026-09-06 09:14:07.3586
360	Q-IS9K8g294	cbse revaluation	11	4.40	4.40	related	3	2026-09-06 09:52:18.827983
361	Q-IS9K8g294	cbse revaluation result	11	4.40	4.40	related	3	2026-09-06 09:52:18.827983
362	Q-IS9K8g294	premalu full movie in hindi dubbed	11	4.40	4.40	noise	1	2026-09-06 09:52:18.827983
363	Q-IS9K8g294	quantum physics	11	4.40	4.40	noise	1	2026-09-06 09:52:18.827983
364	Q-IS9K8g294	re-evaluation cbse class 12	11	4.40	4.40	related	3	2026-09-06 09:52:18.827983
367	p03EyeJlM-k	naat	1	7.10	0.60	noise	1	2026-09-06 12:19:14.187832
368	p03EyeJlM-k	small pump	1	7.10	0.60	noise	1	2026-09-06 12:19:14.187832
369	229XDzxoc4g	jee advanced	5	14.30	1.50	related	3	2026-09-06 13:26:52.660817
370	229XDzxoc4g	army rank	2	4.80	0.60	noise	1	2026-09-06 13:26:52.660817
371	229XDzxoc4g	assistant commissioner	1	4.80	0.30	noise	1	2026-09-06 13:26:52.660817
372	229XDzxoc4g	blackpink coachella dance	1	4.80	0.30	noise	1	2026-09-06 13:26:52.660817
373	229XDzxoc4g	buldak	1	4.80	0.30	noise	1	2026-09-06 13:26:52.660817
374	j4CtPMW-1Q4	jee advanced 2024	50	40.00	40.00	related	3	2026-09-06 13:43:57.675416
375	j4CtPMW-1Q4	jee advance paper 1	12	6.00	6.00	related	3	2026-09-06 13:43:57.675416
376	j4CtPMW-1Q4	jee adv paper 1	11	4.00	4.00	related	3	2026-09-06 13:43:57.675416
377	j4CtPMW-1Q4	jee adv paper 1 2024	11	4.00	4.00	related	3	2026-09-06 13:43:57.675416
378	j4CtPMW-1Q4	jee advance 2024	11	4.00	4.00	related	3	2026-09-06 13:43:57.675416
389	iLZVyccaTJs	best cable for iphone	1	11.10	0.30	noise	1	2026-09-06 13:51:03.028232
390	iLZVyccaTJs	guitar covers	1	11.10	0.30	noise	1	2026-09-06 13:51:03.028232
391	iLZVyccaTJs	jac counselling 2024	1	11.10	0.30	related	3	2026-09-06 13:51:03.028232
392	iLZVyccaTJs	nms sir physics	1	11.10	0.30	noise	1	2026-09-06 13:51:03.028232
393	iLZVyccaTJs	software testing tutorial for beginners	1	11.10	0.30	noise	1	2026-09-06 13:51:03.028232
809	wnp9gFm7ZpY	jac delhi 2024 round 1 result	2	33.30	1.70	specific	5	2026-09-12 21:46:22.459929
810	wnp9gFm7ZpY	jac delhi counselling 2024	2	33.30	1.70	specific	4	2026-09-12 21:46:22.459929
554	bLwR73Y2d0w	NEET 2024	0	0.00	0.00	related	3	2026-09-10 10:04:13.605465
555	bLwR73Y2d0w	Delhi High Court NEET	0	0.00	0.00	related	3	2026-09-10 10:04:13.605465
556	bLwR73Y2d0w	NEET re-exam	0	0.00	0.00	related	3	2026-09-10 10:04:13.605465
811	wnp9gFm7ZpY	jee 2024 jac delhi result	2	33.30	1.70	related	3	2026-09-12 21:46:22.459929
825	kbLQ0kJ7pYQ	ipu counselling 2024	7	12.50	12.50	specific	4	2026-09-13 00:04:05.182697
826	kbLQ0kJ7pYQ	ipu choice filling 2024	4	6.30	6.30	related	4	2026-09-13 00:04:05.182697
827	kbLQ0kJ7pYQ	kaleen bhaiya edit	4	6.30	6.30	related	4	2026-09-13 00:04:05.182697
828	kbLQ0kJ7pYQ	vips btech	4	6.30	6.30	related	4	2026-09-13 00:04:05.182697
840	hiP5k2gClN0	upgradation round jac delhi	49	6.80	6.80	related	5	2026-09-13 00:39:10.017376
572	DNIHqPqY3VM	JEE Advanced results	18	100.00	4.10	informational	3	2026-09-10 18:32:28.286194
573	DNIHqPqY3VM	jee advanced results	9	50.00	2.00	informational	3	2026-09-10 18:32:28.286194
574	DNIHqPqY3VM	jee 2024	6	33.30	1.40	informational	3	2026-09-10 18:32:28.286194
841	hiP5k2gClN0	jac delhi	45	6.30	6.30	related	5	2026-09-13 00:39:10.017376
842	hiP5k2gClN0	jac delhi counselling 2024	39	5.50	5.50	specific	5	2026-09-13 00:39:10.017376
843	hiP5k2gClN0	jac delhi upgradation round	30	4.20	4.20	related	5	2026-09-13 00:39:10.017376
844	hiP5k2gClN0	jac upgradation round 2024	15	2.10	2.10	related	5	2026-09-13 00:39:10.017376
855	3JdwNxhgqN8	dtu orientation 2024	599	44.90	44.90	related	5	2026-09-13 00:48:04.423667
856	3JdwNxhgqN8	dtu orientation	53	4.00	4.00	related	5	2026-09-13 00:48:04.423667
857	3JdwNxhgqN8	dtu	9	0.70	0.70	related	4	2026-09-13 00:48:04.423667
858	3JdwNxhgqN8	raj soin hall	9	0.70	0.70	related	5	2026-09-13 00:48:04.423667
859	3JdwNxhgqN8	soin	9	0.70	0.70	related	5	2026-09-13 00:48:04.423667
593	a6DGQWZ57EE	JEE Advanced 2024 results	24	100.00	4.20	informational	3	2026-09-10 19:33:03.635723
594	a6DGQWZ57EE	jee advanced results	12	50.00	2.10	informational	3	2026-09-10 19:33:03.635723
595	a6DGQWZ57EE	jee 2024	8	33.30	1.40	informational	3	2026-09-10 19:33:03.635723
870	QnjyscmnjEQ	ipu counselling 2024	77	11.00	11.00	specific	5	2026-09-13 01:04:42.898173
871	QnjyscmnjEQ	ipu btech spot round 2024	27	3.80	3.80	related	5	2026-09-13 01:04:42.898173
872	QnjyscmnjEQ	ipu spot round 2024	25	3.50	3.50	related	5	2026-09-13 01:04:42.898173
873	QnjyscmnjEQ	ipu spot round result 2024	23	3.30	3.30	specific	5	2026-09-13 01:04:42.898173
874	QnjyscmnjEQ	ipu counselling 2024 for btech	22	3.10	3.10	specific	5	2026-09-13 01:04:42.898173
605	_6qJfWvvWJo	NEET reexamination	10	100.00	2.30	informational	3	2026-09-10 20:01:40.055997
606	_6qJfWvvWJo	NEET 2024	5	50.00	1.10	informational	3	2026-09-10 20:01:40.055997
607	_6qJfWvvWJo	Supreme Court NEET	3	30.00	0.70	informational	3	2026-09-10 20:01:40.055997
470	4B4aAW76GLQ	jac delhi counselling 2024	146	35.30	35.30	specific	5	2026-09-07 09:04:23.739817
471	4B4aAW76GLQ	jac delhi	61	14.70	14.70	specific	5	2026-09-07 09:04:23.739817
472	4B4aAW76GLQ	cricket	12	2.90	2.90	noise	1	2026-09-07 09:04:23.739817
473	4B4aAW76GLQ	horror videos	12	2.90	2.90	noise	1	2026-09-07 09:04:23.739817
474	4B4aAW76GLQ	igdtuw	12	2.90	2.90	related	2	2026-09-07 09:04:23.739817
611	NVbNJeWZ1Lo	seat allotment JAC	21	100.00	20.80	informational	3	2026-09-10 20:21:07.431547
612	NVbNJeWZ1Lo	JAC re scheduled	12	57.10	11.90	informational	3	2026-09-10 20:21:07.431547
613	NVbNJeWZ1Lo	CW KM IIITD bonus	8	38.10	7.90	informational	3	2026-09-10 20:21:07.431547
484	LQ7ttolwjJQ	cheela recipe	1	50.00	1.45	noise	1	2026-09-07 10:50:43.305672
485	LQ7ttolwjJQ	shila	1	50.00	1.45	noise	1	2026-09-07 10:50:43.305672
486	zqqcLDVZxR8	jee advanced 2024	28	8.70	8.70	specific	5	2026-09-07 10:57:07.066385
487	zqqcLDVZxR8	provisional answer key jee advanced 2024	28	8.70	8.70	specific	5	2026-09-07 10:57:07.066385
488	zqqcLDVZxR8	aashiq banaya	14	4.40	4.40	noise	1	2026-09-07 10:57:07.066385
489	zqqcLDVZxR8	france song	14	4.40	4.40	noise	1	2026-09-07 10:57:07.066385
490	zqqcLDVZxR8	jee adv key 2024	14	4.40	4.40	related	3	2026-09-07 10:57:07.066385
626	pl90QEsoKFk	NTA director general removed	33	100.00	6.60	informational	3	2026-09-10 23:10:00.515414
499	YaAKtkecoRc	neet 2024 result	8	50.00	2.00	specific	5	2026-09-08 11:27:20.802552
500	YaAKtkecoRc	air 1 neet 2024	4	25.00	1.00	specific	4	2026-09-08 11:27:20.802552
501	YaAKtkecoRc	dhruv rathee status	2	12.50	0.50	noise	1	2026-09-08 11:27:20.802552
502	YaAKtkecoRc	how many 720 in neet 2024	2	12.50	0.50	related	3	2026-09-08 11:27:20.802552
627	pl90QEsoKFk	NEET NTA update	16	50.00	3.20	informational	3	2026-09-10 23:10:00.515414
628	pl90QEsoKFk	NEET 2024 results	8	25.00	1.60	informational	3	2026-09-10 23:10:00.515414
629	3LCJCKfRATo	JEE Advanced 2024 results	24	100.00	4.20	informational	3	2026-09-10 23:30:52.664773
630	3LCJCKfRATo	jee advanced results	12	50.00	2.10	informational	3	2026-09-10 23:30:52.664773
631	3LCJCKfRATo	jee 2024	8	33.30	1.40	informational	3	2026-09-10 23:30:52.664773
632	mK2nGGZFRVI	UPTAC 2024 counselling	24	100.00	14.30	informational	3	2026-09-11 10:53:51.650803
633	mK2nGGZFRVI	UPTAC counselling 2024	12	50.00	6.80	informational	3	2026-09-11 10:53:51.650803
634	mK2nGGZFRVI	UPTAC admission	8	33.30	4.50	informational	3	2026-09-11 10:53:51.650803
512	Mp1WHa-CXfw	JOSSA 2024 schedule	16	22.20	22.20	related	3	2026-09-09 14:55:59.402702
513	Mp1WHa-CXfw	JEE 2024 counselling	11	15.00	15.00	related	3	2026-09-09 14:55:59.402702
514	Mp1WHa-CXfw	JoSAA 2024 brochure	7	10.00	10.00	related	3	2026-09-09 14:55:59.402702
638	A2U9omXQ2go	UPTAC 2024 counselling	24	100.00	14.30	informational	3	2026-09-11 13:05:32.12302
639	A2U9omXQ2go	UPTAC counselling 2024	12	50.00	6.80	informational	3	2026-09-11 13:05:32.12302
640	A2U9omXQ2go	UPTAC admission	8	33.30	4.50	informational	3	2026-09-11 13:05:32.12302
829	AwJoDsJiAoQ	yatharth sachdeva	12	25.00	25.00	related	4	2026-09-13 00:30:05.383779
845	DrhZsdeBj6k	jee mains password forgot 2025	633	2.10	2.10	related	5	2026-09-13 00:39:55.370257
846	DrhZsdeBj6k	how to change jee mains password	542	1.80	1.80	specific	5	2026-09-13 00:39:55.370257
847	DrhZsdeBj6k	jee mains result 2025	512	1.70	1.70	specific	5	2026-09-13 00:39:55.370257
848	DrhZsdeBj6k	how to reset jee mains password	271	0.90	0.90	specific	5	2026-09-13 00:39:55.370257
849	DrhZsdeBj6k	jee main password bhul gaye to kya kare	241	0.80	0.80	related	5	2026-09-13 00:39:55.370257
930	j7xmoRH2rzo	dtu arjun kapoor	87	4.10	4.10	related	4	2026-09-13 08:04:48.235092
931	j7xmoRH2rzo	arjun kapoor dtu	40	1.90	1.90	related	4	2026-09-13 08:04:48.235092
932	j7xmoRH2rzo	mere husband ki biwi actress name	32	1.50	1.50	related	5	2026-09-13 08:04:48.235092
933	j7xmoRH2rzo	mere husband ki biwi movie promotion	23	1.10	1.10	related	5	2026-09-13 08:04:48.235092
934	j7xmoRH2rzo	arjun kapoor in dtu	15	0.70	0.70	related	4	2026-09-13 08:04:48.235092
940	4yAeMwjZxoo	invictus dtu	42	9.10	9.10	related	4	2026-09-13 08:12:31.899566
941	4yAeMwjZxoo	invictus dtu 2026	7	1.50	1.50	related	4	2026-09-13 08:12:31.899566
942	4yAeMwjZxoo	dtu fest	5	1.00	1.00	related	4	2026-09-13 08:12:31.899566
943	4yAeMwjZxoo	be invictus	2	0.50	0.50	related	4	2026-09-13 08:12:31.899566
944	4yAeMwjZxoo	bhutni ki video	2	0.50	0.50	related	4	2026-09-13 08:12:31.899566
905	muLRYXpkVWA	harsh gujral	454	17.40	17.40	related	5	2026-09-13 01:26:35.978101
906	muLRYXpkVWA	harsh gujral movie promotion	154	5.90	5.90	related	5	2026-09-13 01:26:35.978101
907	muLRYXpkVWA	harsh gujral movie	73	2.80	2.80	related	5	2026-09-13 01:26:35.978101
908	muLRYXpkVWA	harsh gujral dtu	68	2.60	2.60	related	5	2026-09-13 01:26:35.978101
909	muLRYXpkVWA	invictus dtu	63	2.40	2.40	related	4	2026-09-13 01:26:35.978101
915	_gF2JDP64Yc	dtu	17	2.90	2.90	related	4	2026-09-13 01:27:57.041345
916	_gF2JDP64Yc	dtu naam sujal	17	2.90	2.90	related	4	2026-09-13 01:27:57.041345
917	_gF2JDP64Yc	mtv sujal	17	2.90	2.90	related	4	2026-09-13 01:27:57.041345
918	_gF2JDP64Yc	invictus dtu 2025	11	1.90	1.90	related	4	2026-09-13 01:27:57.041345
919	_gF2JDP64Yc	naam sujal dtu	11	1.90	1.90	related	4	2026-09-13 01:27:57.041345
746	fsSkI-1Opvk	jac delhi 2024 round 1 result	7	33.30	1.70	specific	5	2026-09-11 22:58:05.388618
747	fsSkI-1Opvk	jac delhi counselling 2024	7	33.30	1.70	specific	4	2026-09-11 22:58:05.388618
748	fsSkI-1Opvk	jee 2024 jac delhi result	7	33.30	1.70	related	3	2026-09-11 22:58:05.388618
749	pbU_sJKSfrg	jac delhi 2024 round 1 result	4	33.30	1.70	specific	5	2026-09-11 22:58:06.014146
750	pbU_sJKSfrg	jac delhi counselling 2024	4	33.30	1.70	specific	4	2026-09-11 22:58:06.014146
751	pbU_sJKSfrg	jee 2024 jac delhi result	4	33.30	1.70	related	3	2026-09-11 22:58:06.014146
752	W1nCo6y71R8	jac delhi 2024 round 1 result	3	33.30	1.70	specific	5	2026-09-11 22:58:06.303119
753	W1nCo6y71R8	jac delhi counselling 2024	3	33.30	1.70	specific	4	2026-09-11 22:58:06.303119
754	W1nCo6y71R8	jee 2024 jac delhi result	3	33.30	1.70	related	3	2026-09-11 22:58:06.303119
935	5v6ouzwDdRQ	ishika sehgal	213	35.10	35.10	related	5	2026-09-13 08:07:14.421856
936	5v6ouzwDdRQ	ishika sehgal songs	56	9.30	9.30	related	5	2026-09-13 08:07:14.421856
937	5v6ouzwDdRQ	dtu fest 2025	39	6.50	6.50	related	5	2026-09-13 08:07:14.421856
938	5v6ouzwDdRQ	dtu fest	19	3.10	3.10	related	5	2026-09-13 08:07:14.421856
761	xj4emmUcJGE	jac delhi 2024 round 1 result	18	33.30	1.70	specific	5	2026-09-11 22:58:07.287609
762	xj4emmUcJGE	jac delhi counselling 2024	18	33.30	1.70	specific	4	2026-09-11 22:58:07.287609
763	xj4emmUcJGE	jee 2024 jac delhi result	18	33.30	1.70	related	3	2026-09-11 22:58:07.287609
764	w2UTdzsuads	jac delhi 2024 round 1 result	6	33.30	1.70	specific	5	2026-09-11 22:58:07.599184
765	w2UTdzsuads	jac delhi counselling 2024	6	33.30	1.70	specific	4	2026-09-11 22:58:07.599184
766	w2UTdzsuads	jee 2024 jac delhi result	6	33.30	1.70	related	3	2026-09-11 22:58:07.599184
767	SOKrC7BJ418	jac delhi 2024 round 1 result	10	33.30	1.70	specific	5	2026-09-11 22:58:07.871575
768	SOKrC7BJ418	jac delhi counselling 2024	10	33.30	1.70	specific	4	2026-09-11 22:58:07.871575
769	SOKrC7BJ418	jee 2024 jac delhi result	10	33.30	1.70	related	3	2026-09-11 22:58:07.871575
770	PaYUzmc11E8	jac delhi 2024 round 1 result	2	33.30	1.70	specific	5	2026-09-11 22:58:08.189019
771	PaYUzmc11E8	jac delhi counselling 2024	2	33.30	1.70	specific	4	2026-09-11 22:58:08.189019
772	PaYUzmc11E8	jee 2024 jac delhi result	2	33.30	1.70	related	3	2026-09-11 22:58:08.189019
773	0KAZqj8-gFo	jac delhi 2024 round 1 result	13	33.30	1.70	specific	5	2026-09-11 22:58:08.519442
774	0KAZqj8-gFo	jac delhi counselling 2024	13	33.30	1.70	specific	4	2026-09-11 22:58:08.519442
775	0KAZqj8-gFo	jee 2024 jac delhi result	13	33.30	1.70	related	3	2026-09-11 22:58:08.519442
939	5v6ouzwDdRQ	dtu	15	2.40	2.40	related	4	2026-09-13 08:07:14.421856
945	SS61lwI_i5Q	how to see rank in jee mains	29	15.40	15.40	specific	5	2026-09-13 08:20:20.943281
946	SS61lwI_i5Q	jee	14	7.70	7.70	related	4	2026-09-13 08:20:20.943281
947	SS61lwI_i5Q	jee advanced 2025	14	7.70	7.70	related	4	2026-09-13 08:20:20.943281
948	SS61lwI_i5Q	jee result reaction	14	7.70	7.70	specific	5	2026-09-13 08:20:20.943281
\.


--
-- Data for Name: short_analysis; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.short_analysis (id, short_id, video_id, views, engaged_views, unique_viewers, watch_time_hours, avg_view_duration_seconds, retention_percent, swiped_away_percent, subscribers_gained, likes, comments, shares, hype_points, shorts_feed_pct, youtube_search_pct, browse_features_pct, channel_pages_pct, suggested_videos_pct, external_pct, notifications_pct, other_youtube_features_pct, others_pct, search_terms_json, retention_curve_json, key_moments_json, end_screen_ctr, end_screen_ctr_channel_avg, remixes, bell_notification_ctr, device_mobile_pct, device_computer_pct, device_tablet_pct, device_tv_pct, gender_male_pct, gender_female_pct, age_13_17_pct, age_18_24_pct, age_25_34_pct, age_35_44_pct, age_45_54_pct, age_55_64_pct, age_65_plus_pct, geography_india_pct, geography_other_json, subscriber_status_subscribed_pct, subscriber_status_not_subscribed_pct, new_viewers_pct, returning_viewers_pct, subtitles_none_pct, subtitles_hindi_pct, subtitles_english_auto_pct, description_text, description_length, tags_title, tags_description, hashtag_count, playlist_name, end_screen, captions, related_video_title, related_video_type, hook_type, clip_breakdown_json, language_mix, content_category, value_delivery, cta_type, academic_teaching, total_comments, top_comments_json, sentiment_clusters_json, topic_demands_json, quality_signals_json, creator_reply_rate, gratitude_signals, trust_proxy, content_type, what_works_json, what_fails_json, root_cause, hidden_pattern, actionable_fix, comparison_cluster_json, memory_update_json, analyzed_at) FROM stdin;
1	1	5goNjmztwqg	43	43	29	0.30	27	71.40	28.60	0	0	2	0	0	16.30	2.30	18.60	51.20	4.70	4.70	0.00	0.00	4.70	{"insufficient_data": 0}	{"0": 100, "5": 85, "10": 78, "15": 75, "20": 73, "27": 71.4, "30": 68, "40": 55, "52": 45}	{"completion": {"retention": 45, "timestamp": 52}, "average_view_duration": {"retention": 71.4, "timestamp": 27}}	0.00	0.90	0	0.00	82.30	17.70	0.00	0.00	\N	\N	0.00	0.00	0.00	0.00	0.00	0.00	0.00	27.90	{}	69.90	30.10	\N	\N	93.00	4.70	2.30	Part 2 Link: https://youtube.com/shorts/0jstRcQmAro?si=x3LNqM-81u5rtspG\nPart 3 Link: https://youtube.com/shorts/XWFbqR_9fqc?si=j2fgA7_ngab4txD4\nPart 4 Link: https://youtube.com/shorts/Pwp0zPAY6Y4?si=FEq7nbgPLmaW8_2T\nPart 5 Link: https://youtube.com/shorts/s_PoEssiuPo?si=xiUkWMcwSak3EFIk\n\n🚀 Unleash Your Exam Superpowers: Essential Tips for JEE & Competitive Exams 🚀\nAce your JEE and competitive exams with the ultimate guide! 🌟 \nI'm sharing the most crucial tips to level up your preparation game. From mindset hacks to time-saving tricks, these strategies are your ticket to success. 🎓 \nReady to boost your study game? Hit play now and stay tuned for more exam-winning insights! 🚀✨\n#JEE2024 #ExamTips #StudySmart #shorts #iit #iitjee #part1	1156	iit, jee, part1, jee2024	JEE2024, ExamTips, StudySmart, shorts, iit, iitjee, part1	7	\N	related_video: MOST IMP TIPS for JEE & other competitive exams (Part-2) #iit #jee #part2 #jee2024	en, hi (auto)	MOST IMP TIPS for JEE & other competitive exams (Part-2) #iit #jee #part2 #jee2024	related_video	educational_hook	{"segments": [{"0-15s": "hook + series intro"}, {"15-40s": "core tips"}, {"40-52s": "cross-links + CTA"}]}	Hinglish	educational	exam_tips	subscribe_next_part	f	2	[{"text": "Part 2 link please", "likes": 5, "sentiment": "positive"}, {"text": "Nice tips", "likes": 3, "sentiment": "positive"}]	{"neutral": 50, "negative": 0, "positive": 50}	{"more_tips": 1, "part2_request": 1}	{"hinglish": true, "cross_linking": true, "series_format": true, "educational_value": true}	0.00	0	series_cross_linking	educational	{"series_format": true, "cross_linking_to_part2": true, "strong_retention_71pct": true, "clear_educational_value": true}	{"low_views": true, "no_remixes": true, "no_search_traffic": true, "end_screen_ctr_zero": true}	First video in series, low initial distribution, relies on channel pages (51%) not Shorts feed	High Channel pages traffic (51.2%) vs typical 15-25% for Shorts, indicating subscribers/channel visitors are primary discovery path	Optimize channel page and playlist placement for series content; add stronger CTA in first 3s; improve end screen CTR	{"cluster": "educational_series_jee_2024", "position": 1, "total_parts": 5}	{"pattern": "high_channel_pages_traffic", "percentage": 51.2, "implication": "Series content drives channel page discovery", "traffic_source": "channel_pages"}	2026-08-31 22:54:52.036978
5	2	0jstRcQmAro	30	29	17	0.20	28	50.00	50.00	1	0	2	0	0	13.30	13.30	13.30	33.30	10.00	0.00	0.00	10.00	16.70	{"insufficient_data": 0}	{"0": 100, "15": 65, "28": 50, "60": 47}	{"completion": {"retention": 47.0, "timestamp": 60}, "average_view_duration": {"retention": 50.0, "timestamp": 28}}	0.00	0.90	0	0.00	80.30	15.50	4.30	0.00	\N	\N	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	{}	69.50	30.50	\N	\N	96.70	0.00	3.30	Part 1 Link: https://youtube.com/shorts/5goNjmztwqg?si=MLo-xkuwoHa97I9a\nPart 3 Link: https://youtube.com/shorts/XWFbqR_9fqc?si=lnF3-aLmIHCaSaF4\nPart 4 Link: https://youtube.com/shorts/Pwp0zPAY6Y4?si=FEq7nbgPLmaW8_2T\nPart 5 Link: https://youtube.com/shorts/s_PoEssiuPo?si=xiUkWMcwSak3EFIk\n\n🚀 Unleash Your Exam Superpowers: Essential Tips for JEE & Competitive Exams 🚀\nAce your JEE and competitive exams with the ultimate guide! 🌟 \nI'm sharing the most crucial tips to level up your preparation game. From mindset hacks to time-saving tricks, these strategies are your ticket to success. 🎓 \nReady to boost your study game? Hit play now and stay tuned for more exam-winning insights! 🚀✨\n#JEE2024 #ExamTips #StudySmart #shorts #iit #iitjee #part2	870	iit, jee, part2, jee2024	JEE2024, ExamTips, StudySmart, shorts, iit, iitjee, part2	7	\N	related_video: MOST IMP TIPS for JEE & other competitive exams (Part-3)#iit #jee #part3 #jee2024	en, hi (auto)	MOST IMP TIPS for JEE & other competitive exams (Part-3)#iit #jee #part3 #jee2024	related_video	educational_hook	{"segments": {"0-15s": "hook + series intro", "15-45s": "core tips", "45-60s": "cross-links + CTA"}}	Hinglish	educational	exam_tips	subscribe_next_part	f	2	{}	{}	{"more_tips": 1, "part3_request": 1}	{"hinglish": true, "cross_linking": true, "series_format": true, "educational_value": true}	0.00	0	series_cross_linking	educational	{"series_format": true, "clear_educational_value": true, "cross_linking_to_part1_part3": true, "strong_engaged_view_rate_97pct": true}	{"low_views": true, "no_remixes": true, "swipe_away_50pct": true, "no_search_traffic": true, "end_screen_ctr_zero": true}	Second video in series, low initial distribution, relies on channel pages (33.3%) not Shorts feed, 50% swipe away indicates hook or pacing issue	High Channel pages traffic (33.3%) vs typical 15-25% for Shorts, series cross-linking drives channel page discovery but decreasing from Part-1's 51.2%	Stronger hook in first 3s to reduce swipe-away; improve end screen CTR; optimize channel page/playlist for series discovery	{"cluster": "educational_series_jee_2024", "position": 2, "total_parts": 5}	{"pattern": "high_channel_pages_traffic_series", "percentage": 33.3, "implication": "Series content drives channel page discovery, decreasing across parts", "traffic_source": "channel_pages", "part1_percentage": 51.2}	2026-09-01 08:45:25.36398
6	3	XWFbqR_9fqc	16	16	11	0.10	27	58.30	41.70	0	0	2	0	0	6.30	0.00	6.30	68.80	0.00	0.00	6.30	0.00	12.50	[]	[{"r": 100, "t": 0}, {"r": 58.3, "t": 27}, {"r": 46.6, "t": 58}]	[{"t": 27, "type": "stayed_watch"}]	0.00	0.90	0	0.00	71.10	28.90	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	{}	82.30	17.70	0.00	0.00	93.80	0.00	6.30	Part 1 Link: https://youtube.com/shorts/5goNjmztwqg?si=MLo-xkuwoHa97I9a\nPart 2 Link: https://youtube.com/shorts/0jstRcQmAro?si=x3LNqM-81u5rtspG\nPart 4 Link: https://youtube.com/shorts/Pwp0zPAY6Y4?si=FEq7nbgPLmaW8_2T\nPart 5 Link: https://youtube.com/shorts/s_PoEssiuPo?si=xiUkWMcwSak3EFIk\n\n🚀 Unleash Your Exam Superpowers: Essential Tips for JEE & Competitive Exams 🚀\nAce your JEE and competitive exams with the ultimate guide! 🌟 \nI'm sharing the most crucial tips to level up your preparation game. From mindset hacks to time-saving tricks, these strategies are your ticket to success. 🎓 \nReady to boost your study game? Hit play now and stay tuned for more exam-winning insights! 🚀✨\n#JEE2024 #ExamTips #StudySmart #shorts #iit #jee #part3	547	{#iit,#jee,#part3,#jee2024}	{#JEE2024,#ExamTips,#StudySmart,#shorts,#iit,#jee,#part3}	7	\N	related_video_Pwp0zPAY6Y4	none	MOST IMP TIPS for JEE & other competitive exams (Part-4)	series_continuation	series_continuation	{}	hinglish	educational	series_tip	link_to_next_part	t	2	[{"text": "Big fan bhaiya", "likes": 0, "author": "@neer4090"}, {"text": "Part 4 Link: https://youtube.com/shorts/Pwp0zPAY6Y4?si=FEq7nbgPLmaW8_2T", "likes": 0, "author": "@YatharthSachdeva23"}]	{"neutral": 1, "negative": 0, "positive": 1}	{}	{"cross_linking": true, "series_continuation": true}	50.00	1	0.0	educational	{"cross_linking": true, "series_format": true}	{"low_feed_reach": true, "no_search_traffic": true}	Part 3 of series - viewers come from channel/pages/playlists, not discovery	Series parts cannibalize each other - no independent discovery	Optimize each part for independent search + consolidate into playlist	{"parts": 5, "cluster": "jee_tips_series", "position": 3}	{"pattern": "series_parts_need_independent_seo", "evidence": "Part 3: 68.8% channel pages, 0% search"}	2026-09-01 09:19:49.888536
7	4	Pwp0zPAY6Y4	23	23	19	0.10	20	57.90	43.20	0	0	2	0	0	34.80	0.00	4.40	47.80	0.00	0.00	4.40	0.00	8.70	[]	[{"r": 100, "t": 0}, {"r": 57.9, "t": 20}, {"r": 34.5, "t": 58}]	[{"t": 20, "type": "stayed_watch"}]	0.00	0.90	0	0.00	76.40	20.60	3.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	{}	71.10	28.90	0.00	0.00	91.70	4.20	4.20	Part 1 Link: https://youtube.com/shorts/5goNjmztwqg?si=MLo-xkuwoHa97I9a\nPart-2 Link: https://youtube.com/shorts/0jstRcQmAro?si=x3LNqM-81u5rtspG\nPart-3 Link: https://youtube.com/shorts/XWFbqR_9fqc?si=j2fgA7_ngab4txD4\nPart 5 Link: https://youtube.com/shorts/s_PoEssiuPo?si=xiUkWMcwSak3EFIk\n\n🚀 Unleash Your Exam Superpowers: Essential Tips for JEE & Competitive Exams 🚀\nAce your JEE and competitive exams with the ultimate guide! 🌟 \nI'm sharing the most crucial tips to level up your preparation game. From mindset hacks to time-saving tricks, these strategies are your ticket to success. 🎓 \nReady to boost your study game? Hit play now and stay tuned for more exam-winning insights! 🚀✨\n#JEE2024 #ExamTips #StudySmart #shorts #iit #iitjee #part1	562	{#iit,#jee,#part4,#jee2024}	{#JEE2024,#ExamTips,#StudySmart,#shorts,#iit,#iitjee,#part1}	7	\N	related_video_s_PoEssiuPo	none	MOST IMP TIPS for JEE & other competitive exams (Part-5)	series_continuation	series_continuation	{}	hinglish	educational	series_tip	link_to_next_part	t	2	[{"text": "Big fan bhaiya", "likes": 0, "author": "@neer4090"}, {"text": "Part 5 Link: https://youtube.com/shorts/s_PoEssiuPo?si=xiUkWMcwSak3EFIk", "likes": 0, "author": "@YatharthSachdeva23"}]	{"neutral": 1, "negative": 0, "positive": 1}	{}	{"cross_linking": true, "shorts_feed_reach": 34.8, "series_continuation": true}	50.00	1	0.0	educational	{"cross_linking": true, "series_format": true, "shorts_feed_exposure": true}	{"low_completion": true, "no_search_traffic": true, "incorrect_hashtags": true}	Part 4 of series - higher Shorts feed reach (34.8%) but still no search, declining completion	Series parts getting Shorts feed exposure but low completion, hashtags not updated per part	Fix hashtags per part, optimize each for independent search, improve hook retention	{"parts": 5, "cluster": "jee_tips_series", "position": 4}	{"pattern": "series_parts_need_independent_seo", "evidence": "Part 4: 47.8% channel pages, 34.8% Shorts feed, 0% search, hashtags wrong (#part1)"}	2026-09-01 09:29:40.491408
8	5	s_PoEssiuPo	34	34	34	0.20	20	50.80	49.20	0	0	1	0	0	8.80	55.90	2.90	29.40	0.00	0.00	0.00	0.00	2.90	[{"pct": 10.5, "term": "jee mains tricks", "views": 4}, {"pct": 5.3, "term": "jee exam tips", "views": 2}]	[{"r": 100, "t": 0}, {"r": 50.8, "t": 20}, {"r": 34.5, "t": 58}]	[{"t": 20, "type": "stayed_watch"}]	0.00	0.90	0	0.00	87.50	12.50	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	38.20	{}	28.10	71.90	0.00	0.00	88.20	8.80	2.90	Part 1 Link: https://youtube.com/shorts/5goNjmztwqg?si=MLo-xkuwoHa97I9a\nPart 2 Link: https://youtube.com/shorts/0jstRcQmAro?si=x3LNqM-81u5rtspG\nPart 3 Link: https://youtube.com/shorts/XWFbqR_9fqc?si=j2fgA7_ngab4txD4\nPart 4 Link: https://youtube.com/shorts/Pwp0zPAY6Y4?si=FEq7nbgPLmaW8_2T\n\n🚀 Unleash Your Exam Superpowers: Essential Tips for JEE & Competitive Exams 🚀\nAce your JEE and competitive exams with the ultimate guide! 🌟 \nI'm sharing the most crucial tips to level up your preparation game. From mindset hacks to time-saving tricks, these strategies are your ticket to success. 🎓 \nReady to boost your study game? Hit play now and stay tuned for more exam-winning insights! 🚀✨\n#JEE2024 #ExamTips #StudySmart #shorts #iit #jee #part5	547	{#iit,#jee,#part5,#jee2024}	{#JEE2024,#ExamTips,#StudySmart,#shorts,#iit,#jee,#part5}	7	\N	none	none	\N	series_finale	series_finale	{}	hinglish	educational	series_tip	link_to_prev_parts	t	1	[{"text": "Big fan bhaiya", "likes": 0, "author": "@neer4090"}]	{"neutral": 0, "negative": 0, "positive": 1}	{}	{"loyal_viewer": true, "series_finale": true, "search_traffic": 55.9}	0.00	1	0.0	educational	{"search_discovery": true, "series_completion": true}	{"low_feed": true, "low_completion": true, "no_creator_reply": true}	Part 5 (finale) - FIRST short with search traffic (55.9%), loyal viewer returned, but lowest retention/completion	Series finale gets search traffic but loses retention - audience expects different value at end	Make series finales distinct with summary/recap, answer accumulated questions	{"parts": 5, "cluster": "jee_tips_series", "position": 5}	{"pattern": "series_finale_gets_search_but_low_retention", "evidence": "Part 5: 55.9% search, 50.8% retention, 34.5% completion, loyal viewer @neer4090"}	2026-09-01 09:42:27.379694
\.


--
-- Data for Name: short_content_classification; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.short_content_classification (video_id, primary_type, secondary_type, confidence_score, classified_at, classified_by) FROM stdin;
3LCJCKfRATo	educational	exam_tips	9	2026-09-03 21:16:47.035489	automated_pipeline
mK2nGGZFRVI	educational	counselling	9	2026-09-11 10:53:51.650803	automated_pipeline
UTeogxHwnPw	breaking_news	jee_mains_update	9	2026-09-02 00:00:20.756231	automated_pipeline
zdOSsbqouKE	breaking_news	jee_mains_update	9	2026-09-02 00:11:35.176582	automated_pipeline
12BKLbv0Eso	uncertainty_resolution	answer_key_procedure	9	2026-09-02 08:57:44.373087	automated_pipeline
XM1AzgVMeqk	uncertainty_resolution	answer_key_guide	9	2026-09-02 09:02:32.054168	automated_pipeline
nJNR60Ms1BE	breaking_news	nta_update	9	2026-09-02 09:07:53.238004	automated_pipeline
_A5Idj7SddI	breaking_news	result_update	9	2026-09-02 09:12:13.902042	automated_pipeline
BJ5lJob_sDU	breaking_news	result_update	9	2026-09-02 09:20:33.221739	automated_pipeline
rrTB_XW3pWA	educational	counselling	9	2026-09-12 23:25:09.52654	automated_pipeline
AwJoDsJiAoQ	educational	breaking_news	9	2026-09-13 00:30:05.383779	automated_pipeline
fsSkI-1Opvk	educational	result_alert	9	2026-09-11 16:20:32.995425	automated_pipeline
W1nCo6y71R8	educational	counselling	9	2026-09-11 16:35:53.569939	automated_pipeline
5goNjmztwqg	educational	exam_tips	9	2026-09-02 09:40:57.778366	manual
0jstRcQmAro	educational	exam_tips	9	2026-09-01 08:45:25.36398	manual
w2UTdzsuads	educational	breaking_news	9	2026-09-11 16:35:54.958145	automated_pipeline
PaYUzmc11E8	educational	breaking_news	9	2026-09-11 16:35:55.65266	automated_pipeline
XWFbqR_9fqc	educational	exam_tips	1	2026-09-01 09:19:49.888536	manual
Pwp0zPAY6Y4	educational	exam_tips	1	2026-09-01 09:29:40.491408	manual
s_PoEssiuPo	educational	exam_tips	1	2026-09-01 09:42:27.379694	manual
OkWbChCIb04	breaking_news	alert	9	2026-09-02 10:13:50.522983	automated_pipeline
2jcdStwq2yY	breaking_news	circular_update	9	2026-09-02 10:20:48.373197	automated_pipeline
yDKB-xCaMB8	breaking_news	circular_update	9	2026-09-02 14:30:31.576863	automated_pipeline
rg5iPj-249o	breaking_news	schedule_alert	9	2026-09-02 14:58:55.032747	automated_pipeline
waW201cvfl8	campus_lifestyle	event_promo	9	2026-09-02 15:14:09.210888	automated_pipeline
Ay9K30yrg8Y	breaking_news	schedule_alert	9	2026-09-02 15:27:50.633383	automated_pipeline
lmbndk-Db-Q	breaking_news	schedule_alert	9	2026-09-02 21:49:28.223132	automated_pipeline
cSapjDf5CHY	breaking_news	admit_card_release	9	2026-09-02 23:46:30.338612	automated_pipeline
JmSdjrAxNFM	exam_tips	last_minute_tips	9	2026-09-03 08:43:48.484092	automated_pipeline
MpQ-K2D9Ao4	motivation	percentile_motivation	9	2026-09-03 08:46:53.14088	automated_pipeline
bXetyvX2Mu8	strategy	post_exam_guidance	9	2026-09-03 08:49:33.548839	automated_pipeline
pHfj5VVN0Ew	result_update	result_date_speculation	9	2026-09-03 08:52:31.076945	automated_pipeline
dpTHfuBYClo	result_update	provisional_answer_key	9	2026-09-03 08:54:48.143719	automated_pipeline
sHwtsGShqjE	exam_tips	strategy_analysis	9	2026-09-03 10:11:18.411369	automated_pipeline
Wyt0zC-zadM	educational	exam_tips	9	2026-09-03 12:28:17.67752	automated_pipeline
JRrvbkvRyiI	educational	exam_tips	9	2026-09-03 12:45:38.189925	automated_pipeline
pTiZBob0vWA	educational	exam_tips	9	2026-09-03 13:23:31.162254	automated_pipeline
F6g5hMAUH6A	educational	exam_tips	9	2026-09-03 13:36:14.415812	automated_pipeline
durkT5BI9-0	educational	exam_tips	9	2026-09-03 14:13:12.403346	automated_pipeline
-ntsqYRrjic	educational	exam_tips	9	2026-09-03 14:22:21.576395	automated_pipeline
kQlrFbAzvro	educational	exam_tips	9	2026-09-03 14:34:36.771304	automated_pipeline
VkXC2gAxVvs	educational	exam_tips	9	2026-09-03 21:29:21.003798	automated_pipeline
hiP5k2gClN0	educational	result_alert	9	2026-09-13 00:39:10.017376	automated_pipeline
DrhZsdeBj6k	educational	result_alert	9	2026-09-13 00:39:55.370257	automated_pipeline
3JdwNxhgqN8	educational	breaking_news	9	2026-09-13 00:48:04.423667	automated_pipeline
muLRYXpkVWA	educational	breaking_news	9	2026-09-13 08:06:19.001339	automated_pipeline
5v6ouzwDdRQ	educational	breaking_news	9	2026-09-13 08:07:14.421856	automated_pipeline
SS61lwI_i5Q	educational	result_alert	9	2026-09-13 08:20:20.943281	automated_pipeline
QC45KrzAuLs	educational	exam_tips	9	2026-09-03 21:44:00.314367	automated_pipeline
gNgwb1lmKL8	educational	exam_tips	9	2026-09-03 22:06:49.206096	automated_pipeline
XlOAFuUr7F4	educational	exam_tips	9	2026-09-03 22:31:30.815574	automated_pipeline
d-p-YuOjU-8	educational	exam_tips	9	2026-09-03 22:47:40.537674	automated_pipeline
7L-wWpll_GU	educational	exam_tips	9	2026-09-03 22:59:23.098487	automated_pipeline
pszcrf0uTbQ	educational	exam_tips	9	2026-09-03 23:21:10.33918	automated_pipeline
EDNdXwv7W64	educational	exam_tips	9	2026-09-04 09:55:24.289926	automated_pipeline
DdMa3y_sImk	educational	exam_tips	9	2026-09-04 12:02:37.004788	automated_pipeline
YFnY2guPlxg	educational	exam_tips	9	2026-09-04 12:04:52.149361	automated_pipeline
noF6FnkgYmE	educational	exam_tips	9	2026-09-04 12:16:10.255319	automated_pipeline
tyxuLrd-xo4	educational	exam_tips	9	2026-09-04 12:33:43.388322	automated_pipeline
UzWyYR6WM6U	educational	exam_tips	9	2026-09-04 12:56:32.962168	automated_pipeline
3gSWKoBeqnw	educational	exam_tips	9	2026-09-04 13:19:16.949153	automated_pipeline
impBBFcUinY	educational	exam_tips	9	2026-09-04 13:33:07.646614	automated_pipeline
kIrFARfeW5o	educational	exam_tips	9	2026-09-04 13:45:31.604043	automated_pipeline
FwuhJ23l7R4	lifestyle	campus_life	9	2026-09-04 15:17:53.707086	automated_pipeline
NVbNJeWZ1Lo	educational	exam_tips	9	2026-09-10 20:21:07.431547	automated_pipeline
tO8vEcWUFXs	result_update	admit_card_release	9	2026-09-05 19:35:09.745882	automated_pipeline
m1qgKExs2BY	result_update	admit_card_release	9	2026-09-05 19:53:35.380044	automated_pipeline
_vTmJ79_4ho	schedule_alert	procedural	9	2026-09-05 20:12:48.727333	automated_pipeline
pl90QEsoKFk	educational	news_or_update	9	2026-09-10 23:08:11.068235	automated_pipeline
A2U9omXQ2go	educational	counselling	9	2026-09-11 12:57:35.796334	automated_pipeline
atkvEdcPidM	educational	exam_news	9	2026-09-06 08:41:17.107595	automated_pipeline
dudb29Xqo60	lifestyle	food_review	9	2026-09-06 08:53:13.551357	automated_pipeline
9jXcNZyYza8	fear_mistake_warning	impossible_promise	9	2026-09-06 09:14:07.3586	automated_pipeline
eC_j1wlFJBw	educational	exam_tips	9	2026-09-06 09:30:05.833783	automated_pipeline
Q-IS9K8g294	educational	exam_tips	9	2026-09-06 09:52:18.827983	automated_pipeline
p03EyeJlM-k	educational	counseling_guide	9	2026-09-06 12:19:14.187832	automated_pipeline
229XDzxoc4g	educational	exam_tips	9	2026-09-06 13:26:52.660817	automated_pipeline
j4CtPMW-1Q4	educational	exam_tips	9	2026-09-06 13:43:57.675416	automated_pipeline
iLZVyccaTJs	educational	exam_tips	9	2026-09-06 13:51:03.028232	automated_pipeline
xBun0zPGZDA	educational	college_life	9	2026-09-06 15:05:42.270667	automated_pipeline
pbU_sJKSfrg	educational	breaking_news	9	2026-09-11 16:20:34.478996	automated_pipeline
xj4emmUcJGE	educational	breaking_news	9	2026-09-11 16:35:54.654653	automated_pipeline
SOKrC7BJ418	educational	breaking_news	9	2026-09-11 16:35:55.319378	automated_pipeline
0KAZqj8-gFo	educational	counselling	9	2026-09-11 16:35:55.987093	automated_pipeline
QnjyscmnjEQ	educational	counselling	9	2026-09-13 01:04:42.898173	automated_pipeline
wnp9gFm7ZpY	educational	counselling	9	2026-09-10 22:48:19.000993	automated_pipeline
kbLQ0kJ7pYQ	educational	breaking_news	9	2026-09-13 00:04:05.182697	automated_pipeline
ZrY0tM9yPxQ	educational	breaking_news	9	2026-09-13 00:39:03.743153	automated_pipeline
j7xmoRH2rzo	educational	breaking_news	9	2026-09-13 08:04:48.235092	automated_pipeline
_gF2JDP64Yc	educational	breaking_news	9	2026-09-13 08:06:26.943876	automated_pipeline
4B4aAW76GLQ	educational	exam_tips	9	2026-09-07 09:04:23.739817	automated_pipeline
4yAeMwjZxoo	educational	breaking_news	9	2026-09-13 08:12:31.899566	automated_pipeline
BMh9Xq36RrA	educational	breaking_news	9	2026-09-13 08:22:34.508287	automated_pipeline
LQ7ttolwjJQ	educational	exam_tips	9	2026-09-07 10:50:43.305672	automated_pipeline
zqqcLDVZxR8	educational	exam_tips	9	2026-09-07 10:57:07.066385	automated_pipeline
YaAKtkecoRc	educational	result_alert	9	2026-09-08 10:48:39.159712	automated_pipeline
Mp1WHa-CXfw	educational	schedule_announcement	9	2026-09-09 14:55:59.402702	automated_pipeline
_6qJfWvvWJo	educational	exam_tips	9	2026-09-10 19:56:28.467634	automated_pipeline
D4KiNRb7UTk	educational	exam_update	9	2026-09-09 16:51:44.575471	automated_pipeline
yBnFHlmgMFQ	educational	exam_tips	9	2026-09-09 23:48:51.46802	automated_pipeline
bLwR73Y2d0w	educational	exam_tips	9	2026-09-10 10:04:13.605465	automated_pipeline
Pnh6g6K9y8Q	educational	motivation	9	2026-09-10 17:21:45.289572	automated_pipeline
DNIHqPqY3VM	educational	exam_tips	9	2026-09-10 18:30:27.604051	automated_pipeline
Mkx7Qp8nCys	educational	exam_tips	9	2026-09-10 18:43:32.427695	automated_pipeline
a6DGQWZ57EE	educational	exam_tips	9	2026-09-10 19:31:27.388867	automated_pipeline
\.


--
-- Data for Name: short_title_template; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.short_title_template (video_id, template_id, title_length, word_count, hashtag_count, emoji_count, char_before_pipe, char_after_pipe, keyword_density, fetched_at) FROM stdin;
JmSdjrAxNFM	\N	64	9	4	2	64	0	{"iit": 1, "iitjee": 1, "shorts": 1, "jee2024": 1}	2026-09-03 08:43:48.484092
MpQ-K2D9Ao4	\N	67	9	4	1	67	0	{"iit": 1, "iitjee": 1, "shorts": 1, "jee2024": 1}	2026-09-03 08:46:53.14088
bXetyvX2Mu8	\N	70	9	4	1	70	0	{"iit": 1, "iitjee": 1, "shorts": 1, "jee2024": 1}	2026-09-03 08:49:33.548839
kbLQ0kJ7pYQ	28	56	5	3	2	56	0	{"ipu": 1, "again": 1, "ggsipu": 1, "shorts": 1, "opening!!": 1, "registration": 1}	2026-09-13 00:04:05.182697
UTeogxHwnPw	\N	52	9	2	5	52	0	{}	2026-09-02 09:25:42.138615
zdOSsbqouKE	\N	43	7	2	5	43	0	{}	2026-09-02 09:25:43.634893
12BKLbv0Eso	\N	93	18	1	5	93	0	{}	2026-09-02 09:25:45.151529
XM1AzgVMeqk	\N	63	12	2	6	63	0	{}	2026-09-02 09:25:46.312192
nJNR60Ms1BE	\N	71	12	1	5	71	0	{}	2026-09-02 09:25:47.152763
_A5Idj7SddI	\N	63	9	3	7	63	0	{}	2026-09-02 09:25:47.534266
BJ5lJob_sDU	\N	55	11	3	8	55	0	{}	2026-09-02 09:25:47.870198
pHfj5VVN0Ew	\N	79	11	3	1	79	0	{"iit": 1, "shorts": 1, "jee2024": 1}	2026-09-03 08:52:31.076945
dpTHfuBYClo	\N	65	9	3	1	65	0	{"iit": 1, "short": 1, "jee2024": 1}	2026-09-03 08:54:48.143719
5goNjmztwqg	1	96	14	7	4	0	0	{"iit": 2, "jee": 2, "tips": 1, "exams": 1, "part1": 1, "competitive": 1}	2026-09-02 09:45:39.987643
0jstRcQmAro	1	85	12	7	0	0	0	{"iit": 2, "jee": 2, "tips": 1, "exams": 1, "part2": 1, "competitive": 1}	2026-09-02 09:46:02.751285
XWFbqR_9fqc	1	72	10	4	0	0	0	{"density": 0.55}	2026-09-02 10:02:53.957789
Pwp0zPAY6Y4	1	73	10	4	0	0	0	{"density": 0.55}	2026-09-02 10:03:13.106027
s_PoEssiuPo	1	73	10	4	0	0	0	{"density": 0.55}	2026-09-02 10:03:18.329293
OkWbChCIb04	1	52	9	3	7	52	0	{"iit": 2, "jee": 2, "alert": 1}	2026-09-02 10:43:00.55935
2jcdStwq2yY	1	77	13	4	6	39	38	{"iit": 2, "jee": 1, "nta": 1, "latest": 1, "circular": 1}	2026-09-02 11:22:03.546173
yDKB-xCaMB8	\N	78	12	4	1	37	40	{"iit": 2, "jee": 2, "2024": 1, "dont": 1, "miss": 1, "mains": 2, "iitjee": 1, "shorts": 1, "opportunity": 1}	2026-09-02 14:30:31.576863
rg5iPj-249o	\N	81	11	5	1	0	0	{"jee": 2, "2024": 1, "cuet": 1, "neet": 1, "dates": 1, "shorts": 1, "changed": 1, "elections": 1}	2026-09-02 14:58:55.032747
waW201cvfl8	\N	47	7	3	2	0	0	{"iit": 1, "jee": 1, "shorts": 1, "trailer": 1, "e-summit": 1}	2026-09-02 15:14:09.210888
Ay9K30yrg8Y	\N	59	9	4	2	0	0	{"adv": 1, "iit": 2, "jee": 1, "2024": 1, "dates": 1, "iitjee": 1, "shorts": 1, "changed": 1}	2026-09-02 15:27:50.633383
lmbndk-Db-Q	\N	65	9	4	2	0	0	{"iit": 2, "jee": 1, "2024": 1, "city": 1, "mains": 1, "iitjee": 1, "shorts": 1, "released": 1, "intimation": 1}	2026-09-02 21:49:28.223132
cSapjDf5CHY	\N	76	12	4	2	0	0	{"all": 1, "iit": 2, "jee": 1, "out": 1, "2024": 1, "card": 1, "admit": 1, "april": 1, "mains": 1, "iitjee": 1, "shifts": 1, "shorts": 1}	2026-09-02 23:46:30.338612
sHwtsGShqjE	\N	76	11	2	1	0	0	{"jee": 2, "2024": 1, "solve": 1, "advanced": 1, "students": 1}	2026-09-03 10:11:18.411369
tO8vEcWUFXs	1	78	11	3	1	78	0	{"2024": 1, "card": 1, "cuet": 2, "admit": 1}	2026-09-05 19:35:09.745882
m1qgKExs2BY	1	58	9	3	1	30	28	{"jee": 2, "2024": 1, "card": 1, "admit": 1}	2026-09-05 19:53:35.380044
_vTmJ79_4ho	1	52	8	3	1	30	22	{"jac": 1, "jee": 1, "2024": 1, "dates": 1, "delhi": 1, "changed": 1}	2026-09-05 20:12:48.727333
atkvEdcPidM	1	95	14	3	1	20	74	{"ug": 1, "2024": 1, "neet": 3, "court": 1, "final": 1, "re-exam": 1, "supreme": 1, "verdict": 1}	2026-09-06 08:41:17.107595
dudb29Xqo60	2	56	8	3	1	25	30	{"dtu": 1, "cafe": 1, "food": 0}	2026-09-06 08:53:13.551357
9jXcNZyYza8	1	78	13	3	1	55	23	{"3": 1, "5k": 1, "jee": 1, "2024": 1, "days": 1, "last": 1, "rank": 1, "improve": 1, "advanced": 1}	2026-09-06 09:14:07.3586
eC_j1wlFJBw	1	86	12	3	1	86	0	{"jee": 2, "2024": 1, "iitjee": 1, "advanced": 1}	2026-09-06 09:30:05.833783
Q-IS9K8g294	1	86	12	3	1	86	0	{"cbse": 2, "class10": 1, "class12": 1, "re-evaluation": 1}	2026-09-06 09:52:18.827983
p03EyeJlM-k	1	95	13	4	2	95	0	{"60": 1, "jee": 1, "josaa": 1, "doubts": 1, "seconds": 1, "jacdelhi": 1, "counseling": 1}	2026-09-06 12:19:14.187832
229XDzxoc4g	1	68	10	3	2	68	0	{"jee": 1, "advanced": 1}	2026-09-06 13:26:52.660817
j4CtPMW-1Q4	1	86	12	3	1	86	0	{"jee": 2, "paper2": 1, "advanced": 1}	2026-09-06 13:43:57.675416
iLZVyccaTJs	1	68	9	4	0	68	0	{"jac": 1, "jee": 1, "josaa": 1}	2026-09-06 13:51:03.028232
xBun0zPGZDA	1	42	6	3	1	42	0	{"dtu": 1, "jee": 1}	2026-09-06 15:05:42.270667
4B4aAW76GLQ	28	55	7	3	1	0	55	{"jac": 2, "delhi": 2, "started": 1, "counselling": 1}	2026-09-07 09:04:23.739817
LQ7ttolwjJQ	29	71	10	3	1	0	71	{"adv": 1, "jee": 2, "latest": 1, "update": 1, "download": 1, "immediately": 1}	2026-09-07 10:50:43.305672
zqqcLDVZxR8	28	71	10	3	1	0	71	{"adv": 1, "ans": 1, "jee": 1, "key": 1, "out": 1, "2024": 1, "provisional": 1}	2026-09-07 10:57:07.066385
YaAKtkecoRc	28	56	8	2	1	56	0	{"2024": 1, "neet": 2, "result": 1}	2026-09-08 11:27:20.802552
wnp9gFm7ZpY	28	71	8	3	0	36	34	{"free": 1, "join": 1, "live": 2, "josaa": 2, "shorts": 1, "jee2024": 1, "support": 1, "counselling": 1}	2026-09-12 21:46:22.459929
Mp1WHa-CXfw	28	57	10	3	2	38	13	{"jee": 0.15, "josaa": 0.12, "schedule": 0.2}	2026-09-09 14:55:59.402702
rrTB_XW3pWA	28	67	7	3	1	38	28	{"ipu": 1, "2024": 1, "ggsipu": 2, "shorts": 1, "update!!": 1, "counselling": 1}	2026-09-12 23:25:09.52654
AwJoDsJiAoQ	28	75	8	3	1	75	0	{"cuet": 1, "key?": 1, "answer": 2, "shorts": 1, "changed?": 1, "cuet2024": 1, "cuetanswerkey": 1}	2026-09-13 00:30:05.383779
D4KiNRb7UTk	28	58	10	3	0	0	0	{"2024": 1, "neet": 2, "results": 1}	2026-09-09 16:51:44.575471
yBnFHlmgMFQ	28	84	14	3	2	24	0	{}	2026-09-09 23:48:51.46802
ZrY0tM9yPxQ	28	87	12	3	1	47	39	{"19th": 1, "2024": 1, "card": 1, "cuet": 4, "july": 1, "admit": 1, "out!!": 1, "shorts": 1, "re-exam": 1, "cuetadmitcard": 1}	2026-09-13 00:39:03.743153
hiP5k2gClN0	28	79	9	3	0	40	38	{"dtu": 1, "2024": 1, "delhi": 1, "out!!": 1, "round": 1, "result": 1, "shorts": 1, "internal": 1, "jacdelhi": 1, "upgradation": 1}	2026-09-13 00:39:10.017376
DrhZsdeBj6k	29	87	13	2	1	33	53	{"jee": 1, "2025": 2, "mains": 2, "reset": 1, "forgot": 1, "result": 1, "jeemain": 1, "password": 1, "password?": 1}	2026-09-13 00:39:55.370257
bLwR73Y2d0w	28	80	15	4	1	\N	\N	{}	2026-09-10 10:04:13.605465
Pnh6g6K9y8Q	28	89	15	3	1	25	0	{}	2026-09-10 17:22:57.565114
3JdwNxhgqN8	28	92	12	3	0	38	53	{"dtu": 1, "hall": 1, "soin": 1, "place": 1, "shorts": 1, "fresher's": 1, "motivation": 1, "orientation": 2}	2026-09-13 00:48:04.423667
DNIHqPqY3VM	28	47	10	3	1	0	0	{}	2026-09-10 18:32:28.286194
Mkx7Qp8nCys	28	56	12	3	1	0	0	{}	2026-09-10 18:44:13.592751
QnjyscmnjEQ	28	80	8	3	0	80	0	{"ipu": 1, "2024": 1, "btech": 1, "out!!": 1, "round": 1, "result": 1, "shorts": 1, "sliding": 1, "counselling": 1, "slidinground": 1}	2026-09-13 01:04:42.898173
a6DGQWZ57EE	28	90	12	3	1	0	0	{}	2026-09-10 19:33:03.635723
j7xmoRH2rzo	28	98	13	3	0	33	64	{"dtu": 1, "biwi": 1, "cast": 1, "mere": 1, "bhumi": 1, "preet": 1, "rakul": 1, "husband": 1, "pednekar": 1, "bollywood": 1, "merehusbandkibiwi": 1}	2026-09-13 08:04:48.235092
_6qJfWvvWJo	28	59	14	3	1	0	0	{}	2026-09-10 20:01:40.055997
4yAeMwjZxoo	28	90	11	3	0	19	70	{"dtu": 1, "drone": 1, "track": 1, "racing": 1, "invictus": 1, "techfest": 2, "invictus'25": 1, "techweek'25": 1}	2026-09-13 08:12:31.899566
NVbNJeWZ1Lo	28	84	14	3	1	24	0	{}	2026-09-10 20:21:07.431547
_gF2JDP64Yc	28	97	11	3	0	56	40	{"dtu": 1, "hustle": 1, "rapper": 1, "naamsujal": 1, "runner-up": 1, "@naamsujal": 1, "invictus'25": 1, "performance": 1}	2026-09-13 08:06:26.943876
5v6ouzwDdRQ	28	63	9	3	0	21	41	{"dtu": 1, "fest": 2, "ishika": 1, "sehgal": 1, "dtufest": 1, "fresher's": 1}	2026-09-13 08:07:14.421856
pl90QEsoKFk	28	67	14	3	1	0	0	{}	2026-09-10 23:10:00.515414
3LCJCKfRATo	29	84	14	3	2	24	0	{}	2026-09-10 23:30:52.664773
mK2nGGZFRVI	28	84	14	3	1	0	0	{}	2026-09-11 10:53:51.650803
A2U9omXQ2go	29	92	14	3	1	0	0	{}	2026-09-11 13:05:32.12302
muLRYXpkVWA	28	34	5	1	1	34	0	{"harsh": 1, "gujral": 1, "harshgujral": 1}	2026-09-13 08:06:19.001339
SS61lwI_i5Q	28	92	11	3	1	29	62	{"check": 1, "mains": 1, "result": 1, "session": 1, "jeemains": 1, "result!!": 1, "jeemain2025": 1, "jeemainsresult": 1}	2026-09-13 08:20:20.943281
BMh9Xq36RrA	28	80	12	3	0	8	71	{"dtu": 1, "live": 1, "hustle": 1, "vichaar": 2, "mtvhustle": 1, "performance": 1}	2026-09-13 08:22:34.508287
fsSkI-1Opvk	28	80	11	3	1	39	40	{"2024": 1, "delhi": 1, "out!!": 1, "round": 1, "shorts": 1, "jee2024": 1, "results": 1, "jacdelhi": 1, "clickbait": 1}	2026-09-11 22:58:05.388618
pbU_sJKSfrg	28	65	7	3	1	26	38	{"ipu": 1, "dates": 1, "ggsipu": 1, "shorts": 1, "update": 1, "extended??": 1, "registration": 1}	2026-09-11 22:58:06.014146
W1nCo6y71R8	28	74	10	3	1	23	50	{"ipu": 1, "free": 1, "dates": 1, "order": 1, "ggsipu": 1, "shorts": 1, "preference": 1, "counselling": 1}	2026-09-11 22:58:06.303119
xj4emmUcJGE	28	82	12	3	0	17	64	{"ipu": 1, "good": 1, "rank": 1, "ggsipu": 1, "shorts": 1, "college": 1, "round-1": 1, "analysis": 1, "🤯cutoff": 1}	2026-09-11 22:58:07.287609
w2UTdzsuads	28	93	14	3	1	46	46	{"leak": 1, "neet": 1, "court": 1, "paper": 1, "reneet": 1, "shorts": 1, "hearing": 1, "supreme": 1, "neet2024": 1, "explained": 1}	2026-09-11 22:58:07.599184
SOKrC7BJ418	28	77	12	3	1	20	56	{"dtu": 1, "2024": 1, "delhi": 1, "round": 1, "cutoff": 1, "shorts": 1, "analysis": 1, "jacdelhi": 1, "😨round": 1}	2026-09-11 22:58:07.871575
PaYUzmc11E8	28	100	11	3	0	42	57	{"now!": 1, "your": 1, "delhi": 1, "change": 1, "choice": 1, "option": 1, "shorts": 1, "choices": 1, "editing": 1, "jacdelhi": 1, "available": 1, "jacdelhi2024": 1}	2026-09-11 22:58:08.189019
0KAZqj8-gFo	28	74	7	3	1	74	0	{"ipu": 1, "dates": 1, "ggsipu": 1, "shorts": 1, "schedule": 1, "changed!!": 1, "extended!!": 1, "counselling": 1}	2026-09-11 22:58:08.519442
\.


--
-- Data for Name: shorts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shorts (short_id, video_id, title, title_raw, description, description_length, description_has_cta, description_has_links, published_at, duration_seconds, duration_bucket, visibility, playlist_id, playlist_title, end_screen_type, end_screen_video_id, has_subtitles, subtitle_languages, related_video_id, tags_title, tags_description, emoji_in_title, emoji_list, red_alert_emoji, content_year, content_type, content_subtype, thumbnail_style, hook_type, value_type, language, cta_placement, created_at, updated_at) FROM stdin;
63	iLZVyccaTJs	JAC/JOSAA doubts solving (Part-2) #jee2024 #jacdelhi #josaa #shorts	JAC/JOSAA doubts solving (Part-2)	Got questions about JAC or JoSAA counseling? We've got answers! In this short video, we'll clear up your biggest doubts in just 60 seconds. From registration tips to choice filling and seat allocation, we've got you covered.\n\nWatch now to get the clarity you need for a smooth counseling process. Don't forget to share with friends who might need this quick guide too! 🚀\n\n#jacdelhi  #CounsellingProcess #JEE2024 #josaa #JoSAA2024 #jac2024 #iitjee #jeemains #dtu #nsut #iiitd #igdtuw #dseu #jaccounseling  #JoSAA #CounsellingProcess #JEE2024 #CollegeAdmissions #JoSAA2024 #iitjee #iit #jeemains #jeeadvanced #iitb #iitd #dtu #josaacounseling #iitbombay🎓	652	t	f	2024-05-29 00:00:00	61	15-60s	public	\N	\N	video	iLZVyccaTJs	t	{none,hi,en}	\N	{#jee2024,#jacdelhi,#josaa,#shorts}	{#jacdelhi,#CounsellingProcess,#JEE2024,"#josaa #JoSAA2024 #jac2024 #iitjee #jeemains #dtu #nsut #iiitd #igdtuw #dseu #jaccounseling #JoSAA #CounsellingProcess #JEE2024 #CollegeAdmissions #JoSAA2024 #iitjee #iit #jeemains #jeeadvanced #iitb #iitd #dtu #josaacounseling #iitbombay"}	f	{}	f	2024	educational	exam_tips	{"style": "text_overlay", "has_face": false, "dominant_color": "#000000"}	urgency	educational	Hinglish	description_only	2026-09-06 13:51:03.028232	2026-09-06 13:51:03.028232
34	3LCJCKfRATo	🚨FINAL ANS KEY CHANGED?? | Jee Mains 2024 #jee2024 #iit #shorts	🚨FINAL ANS KEY CHANGED?? | Jee Mains 2024 #jee2024 #iit #shorts	🔔 Attention JEE Mains 2024 aspirants! Hold on to your seats – there's been a crucial update regarding the final answer key! In this short video, I'll be sharing the latest news on the changes made to the final answer key and what it means for you.\n\nJoin me as we dive into the details of the changes and discuss how they might impact your exam results. Whether you're eagerly awaiting your scores or planning your next steps, this update is essential.\n\nHit play now to stay informed and ensure you're prepared for any changes in the exam outcome. Don't forget to share this video with your friends who are also waiting for the JEE Mains 2024 results. Let's support each other through this journey and celebrate our achievements together! 🚀\n\n#JEE2024 #iitbombay #iitdelhi #motivation  #JEEPrep #iitjee #iit #examtips #jeemains #jeemainsresult #jeeadvanced #iitb #iitd #dtu #shorts #finalanswerkey #result #jeeresults #jeemainsresult #jeemains2024 #finalanswerkeychanged	1196	t	f	2024-04-23 00:00:00	59	15-60s	public	\N	\N	video	kQlrFbAzvro	t	{hi,en}	kQlrFbAzvro	{#jee2024,#iit,#shorts}	{#JEE2024,#iitbombay,#iitdelhi,#motivation,#JEEPrep,#iitjee,#iit,#examtips,#jeemains,#jeemainsresult,#jeeadvanced,#iitb,#iitd,#dtu,#shorts,#finalanswerkey,#result,#jeeresults,#jeemainsresult,#jeemains2024,#finalanswerkeychanged}	t	{🚨,🔔,🚀}	t	2024	educational	exam_tips	{"red_alert": true, "face_visible": false, "text_overlay": true, "emoji_prominent": true}	breaking_news	time_sensitive_info	Hinglish	end_screen	2026-09-03 21:16:47.035489	2026-09-10 23:30:52.664773
23	bXetyvX2Mu8	DO THIS AFTER JEE MAINS APRIL ATTEMPT 🔥 | JEE 2024 #iit #jee2024 #iitjee #shorts	DO THIS AFTER JEE MAINS APRIL ATTEMPT | JEE 2024 #iit #jee2024 #iitjee #shorts	JEE ADVANCED DAY WISE STARTEGY: https://youtu.be/ZpSpypF1E38?si=qdsw2koELlzGqVRH\n#JEE2024#iitbombay #iitdelhi #motivation  #JEEPrep #iitjee #iit #examtips #jeemains #jeeadvanced #iitb #iitd #dtu #shorts	202	t	t	2024-04-09 00:00:00	60	60-90s	public	\N	\N	none	\N	t	{none,hi,en-auto}	\N	{iit,jee2024,iitjee,shorts}	{JEE2024,iitbombay,iitdelhi,motivation,JEEPrep,iitjee,iit,examtips,jeemains,jeeadvanced,iitb,iitd,dtu,shorts}	t	{🔥}	f	2024	strategy	post_exam_guidance	{}	guidance	strategy	Hinglish	description_with_link	2026-09-03 08:49:33.548839	2026-09-03 08:49:33.548839
2	0jstRcQmAro	MOST IMP TIPS for JEE & other competitive exams (Part-2) #iit #jee #part2 #jee2024	MOST IMP TIPS for JEE & other competitive exams (Part-2) #iit #jee #part2 #jee2024	Part 1 Link: https://youtube.com/shorts/5goNjmztwqg?si=MLo-xkuwoHa97I9a\nPart 3 Link: https://youtube.com/shorts/XWFbqR_9fqc?si=lnF3-aLmIHCaSaF4\nPart 4 Link: https://youtube.com/shorts/Pwp0zPAY6Y4?si=FEq7nbgPLmaW8_2T\nPart 5 Link: https://youtube.com/shorts/s_PoEssiuPo?si=xiUkWMcwSak3EFIk\n\n🚀 Unleash Your Exam Superpowers: Essential Tips for JEE & Competitive Exams 🚀\n#JEE2024 #ExamTips #StudySmart #shorts #iit #iitjee #part2	870	t	t	2024-01-23 00:00:00	60	15-60s	public	\N	\N	related_video	XWFbqR_9fqc	t	{en,hi}	XWFbqR_9fqc	{iit,jee,part2,jee2024}	{JEE2024,ExamTips,StudySmart,shorts,iit,iitjee,part2}	f	{🚀,🌟,🎓,✨}	f	2024	educational	exam_tips	{"style": "auto-generated", "selected": 2}	educational_hook	educational_value	Hinglish	description_end	2026-09-01 08:45:25.36398	2026-09-02 09:46:02.751285
14	2jcdStwq2yY	🔴LATEST Circular released by NTA | Jee Mains 2024 #jee2024 #iit #iitjee #shorts	LATEST Circular released by NTA | Jee Mains 2024 #jee2024 #iit #iitjee #shorts	🔔 Calling all JEE Mains aspirants! Get ready for a crucial update that demands your immediate attention! In this short video, I'm about to share essential information that could significantly impact your JEE Mains journey.\n\nFrom important exam-related changes to must-know preparation strategies, I've got you covered. Ignoring this alert could mean missing out on valuable insights that could make a difference in your exam performance.\n\nDon't delay – hit the play button now and stay informed! Share this video with your fellow JEE Mains aspirants to ensure everyone is up to speed. Let's tackle this challenge together and strive for success! 🌟\n\n#JEE #JEEMAINS #ExamUpdate #EngineeringEntrance #StayInformed  #AcademicExcellence #jee2024 #iit #iitjee #jeemains #jeemains2024  #aprilattempt  #SolutionCalculation #ExamPreparation #deadline #EducationalInsights #lastdatetoapply #registration 🚀📝✨	653	t	f	2024-03-02 00:00:00	46	15-60s	public	\N	\N	none	\N	t	{none,hi}	\N	{jee2024,iit,iitjee}	{JEE,JEEMAINS,ExamUpdate,EngineeringEntrance,StayInformed,AcademicExcellence,jee2024,iit,iitjee,jeemains,jeemains2024,aprilattempt,SolutionCalculation,ExamPreparation,deadline,EducationalInsights,lastdatetoapply,registration}	t	{🔴,🚨,💪,📋,⚡,🎯}	t	2024	breaking_news	circular_update	{}	urgency	breaking_news	Hinglish	description_only	2026-09-02 10:20:48.373197	2026-09-03 09:12:42.914466
55	atkvEdcPidM	🔴 NEET RE-EXAM?? | Final verdict by Supreme Court | NEET UG 2024 #neet #aiims #shorts	NEET RE-EXAM?? | Final verdict by Supreme Court | NEET UG 2024 #neet #aiims #shorts	🔔 Attention NEET UG 2024 aspirants! The final verdict on the re-exam has been announced. In this short video, we'll break down the details of the decision and what it means for all students.\n\nJoin us as we discuss the implications of the verdict, including key dates, eligibility criteria, and what steps you need to take next. Stay informed and ensure you're prepared for any upcoming changes or requirements.\n\nHit play now to get the latest and most accurate information on the NEET UG 2024 re-exam verdict. Share this video with your friends and fellow aspirants to keep them in the loop. Let's stay updated and ready to tackle NEET UG 2024 together! 🚀\n\n#NEETUG #ReExamVerdict #NEET2024 #MedicalAspirants #ExamUpdate #Shorts #StayInformed #NEETReExam #neetug2024 📅	767	t	f	2024-05-17 00:00:00	61	15-60s	public	\N	\N	video	\N	f	{none,hi}	\N	{#neet,#aiims,#shorts,#NEETUG,#ReExamVerdict,#NEET2024,#MedicalAspirants,#ExamUpdate,#StayInformed,#NEETReExam,#neetug2024}	{#NEETUG,#ReExamVerdict,#NEET2024,#MedicalAspirants,#ExamUpdate,#Shorts,#StayInformed,#NEETReExam,#neetug2024}	t	{🔴}	t	2024	educational	exam_news	{"style": "text_overlay", "has_face": false, "dominant_color": "#FF0000"}	urgency	educational	Hinglish	description_only	2026-09-06 08:41:17.107595	2026-09-06 08:41:17.107595
64	xBun0zPGZDA	📖 Exam Season! DTU #dtu #jee #shorts	Exam Season! DTU #dtu #jee #shorts	This is what it looks like when exams going on in Delhi Technological University (DTU)\nif you also want to come in DTU, you can watch my JAC Full Procedure video, everything is explained clearly in that!\nIf you want a full DTU tour then comment it down!\n\n#dtu #dce #jee2024 #jeemains #shorts #motivation #jeemotivation	318	t	t	2024-05-30 00:00:00	39	15-60s	Public	\N	\N	video	RELATED_VIDEO_ID	t	{none,hi,en}	RELATED_VIDEO_ID	{#dtu,#jee,#shorts}	{#dtu,#dce,#jee2024,#jeemains,#shorts,#motivation,#jeemotivation}	t	{📖}	f	2024	educational	college_life	{"style": "text_overlay", "has_face": false, "dominant_color": "#000000"}	lifestyle	educational	Hinglish	description	2026-09-06 15:05:42.270667	2026-09-06 15:05:42.270667
75	Mkx7Qp8nCys	🚨JOSAA 2024 STARTED!! #jee2024 #josaa #shorts	🚨JOSAA 2024 STARTED!! #jee2024 #josaa #shorts	JOSAA 2024 Registration & Choice Filling Started!! Here are things you should know and do watch all the videos of josaa uploaded on my channel for better clarity and smooth admission\n\nSUBSCRIBE channel for amazing and useful content!\n\n#jee2024 #jeeadavanced #iit #iitbombay #iitjee #iitdelhi #jeeadvanced2024 #josaa #josaa2024	326	f	f	\N	60	15-60s	public	\N	\N	\N	\N	f	{}	\N	{jee,advanced,jee2024,josaa,shorts}	{exam,jeeadvanced,results,registration}	t	{🚨}	f	2024	educational	exam_tips	{}	attention_grab	educational	Hinglish	none	2026-09-10 18:43:32.427695	2026-09-10 18:44:13.592751
67	zqqcLDVZxR8	🚨 Provisional Ans Key Out!! Jee Adv 2024 #jee2024 #jeeadvanced #shorts	🚨 Provisional Ans Key Out!! Jee Adv 2024 #jee2024 #jeeadvanced #shorts	We've got the latest update about jee advanced provisional answer key that you can't afford to miss. Tune in for the newest information and make sure you fill feedback of answer key if any till the date and time mentioned\n\nWatch now and Share this update with your fellow aspirants to keep everyone informed. Let's ace this together! 🚀\n\n#jee2024 #jeeadvanced #jeeadvanced2024 #iit #iitjee #josaa #josaa2024	406	f	f	\N	40	15-60s	public	\N	\N	\N	\N	f	{}	\N	{}	{}	f	{}	f	2024	educational	exam_tips	{}	\N	\N	Hinglish	none	2026-09-06 16:27:51.53725	2026-09-07 10:57:07.066385
81	mK2nGGZFRVI	🔴UPTAC 2024 DEADLINES!! Free Counselling Support for UPTAC #uptac #aktu #shorts	🔴UPTAC 2024 DEADLINES!! Free Counselling Support for UPTAC #uptac #aktu #shorts	Attention UPTAC aspirants! 📢 The important deadlines for UPTAC 2024 are here, and you don't want to miss them! We're offering FREE counseling support to help you navigate the entire process. Get expert advice, stay on top of deadlines, and ensure your application is flawless. 📅\n\nThis is your chance to get all the help you need to secure your spot. Don't miss out on this golden opportunity! Subscribe for more updates and turn on notifications to stay informed.\n\n#aktu #uptac #jee2024	486	f	f	\N	49	15-60s	public	\N	\N	\N	\N	f	{}	\N	{uptac,aktu,jee2024,counselling,support}	{exam,counselling,admissions,deadlines}	t	{🔴}	f	2024	educational	counselling	{}	attention_grab	educational	Hinglish	none	2026-09-11 10:53:51.650803	2026-09-11 10:53:51.650803
56	dudb29Xqo60	😋 New Café in DTU | Fully A/C #dtu #shorts #cafe	New Café in DTU | Fully A/C #dtu #shorts #cafe		0	f	f	2024-05-19 00:00:00	27	0-15s	public	\N	\N	video	dudb29Xqo60	f	{none}	\N	{#dtu,#shorts,#cafe}	{}	t	{😋}	f	2024	lifestyle	food_review	{"style": "text_overlay", "has_face": false, "dominant_color": "#FF0000"}	curiosity	entertainment	Hinglish	description_only	2026-09-06 08:53:13.551357	2026-09-06 08:53:13.551357
6	UTeogxHwnPw	🚨 JEE MAINS April Attempt Update! 🚨 #jee2024 #iitjee	JEE MAINS April Attempt Update! #jee2024 #iitjee	Hey, Future Engineers! 🎓 Ready for some important news? In this video, we've got the latest scoop on the JEE MAINS April attempt!\n\nStay in the loop with exam dates, syllabus tweaks, and more crucial updates that can impact your preparation.\n\nDon't miss out! Hit subscribe and stay tuned for all the key details you need to know to conquer the JEE MAINS April attempt!\n\n#JEE #JEEMAINS #ExamUpdate #AprilAttempt #EngineeringEntrance #StayInformed 🚀📚	447	t	f	2024-02-03 00:00:00	51	15-60s	public	\N	\N	none	\N	f	{none,hi,en-auto}	\N	{jee2024,iitjee}	{JEE,JEEMAINS,ExamUpdate,AprilAttempt,EngineeringEntrance,StayInformed}	t	{🚨,🚨,🎓,🚀,📚}	t	2024	breaking_news	jee_mains_update	{}	urgency	breaking_news	Hinglish	description_only	2026-09-02 00:00:20.756231	2026-09-02 09:25:42.138615
7	zdOSsbqouKE	JEE MAINS latest update 🎉🚀 #jee2024 #iitjee	JEE MAINS latest update #jee2024 #iitjee	Dear Future Engineers! 🎓 Brace yourselves for the latest scoop on the JEE MAINS exam!\n\nWe unveil the most recent update regarding the JEE MAINS that you absolutely can't afford to miss. \n\nBut wait, there's more! For a goldmine of strategies, tips, and real-time updates to boost your exam readiness, don't forget to explore our channel. We're your trusted ally in the quest for academic excellence!\n\nHit that subscribe button now and join us on the journey to success!\n\nAPRIL ATTEMPT UPDATE: https://youtube.com/shorts/UTeogxHwnPw?si=tDVmY7F2saN8apCg\n\n#JEE #JEEMAINS #ExamUpdate #EngineeringEntrance #StayInformed  #AcademicExcellence #jee2024 #iit #iitjee #jeemains #result 📚🚀🔍	678	t	t	2024-02-07 00:00:00	49	15-60s	public	\N	\N	none	\N	f	{none,hi,en-auto}	UTeogxHwnPw	{jee2024,iitjee}	{JEE,JEEMAINS,ExamUpdate,EngineeringEntrance,StayInformed,AcademicExcellence,jeemains,result}	t	{🎉,🚀,🎓,📚,🔍}	f	2024	breaking_news	jee_mains_update	{}	urgency	breaking_news	Hinglish	description_only	2026-09-02 00:11:35.176582	2026-09-02 09:25:43.634893
3	XWFbqR_9fqc	MOST IMP TIPS for JEE & other competitive exams (Part-3)#iit #jee #part3 #jee2024	MOST IMP TIPS for JEE & other competitive exams (Part-3)#iit #jee #part3 #jee2024	Part 1 Link: https://youtube.com/shorts/5goNjmztwqg?si=MLo-xkuwoHa97I9a\nPart 2 Link: https://youtube.com/shorts/0jstRcQmAro?si=x3LNqM-81u5rtspG\nPart 4 Link: https://youtube.com/shorts/Pwp0zPAY6Y4?si=FEq7nbgPLmaW8_2T\nPart 5 Link: https://youtube.com/shorts/s_PoEssiuPo?si=xiUkWMcwSak3EFIk\n\n🚀 Unleash Your Exam Superpowers: Essential Tips for JEE & Competitive Exams 🚀\nAce your JEE and competitive exams with the ultimate guide! 🌟 \nI'm sharing the most crucial tips to level up your preparation game. From mindset hacks to time-saving tricks, these strategies are your ticket to success. 🎓 \nReady to boost your study game? Hit play now and stay tuned for more exam-winning insights! 🚀✨\n#JEE2024 #ExamTips #StudySmart #shorts #iit #jee #part3	547	t	t	2024-01-23 00:00:00	58	60s	public	\N	\N	related_video	Pwp0zPAY6Y4	f	{}	Pwp0zPAY6Y4	{#iit,#jee,#part3,#jee2024}	{#JEE2024,#ExamTips,#StudySmart,#shorts,#iit,#jee,#part3}	f	{}	f	2024	educational	exam_tips	{"style": "text_overlay", "has_face": false, "dominant_color": "#000000"}	series_continuation	educational_tips	hinglish	description_link	2026-09-01 09:19:49.888536	2026-09-02 10:02:53.957789
4	Pwp0zPAY6Y4	MOST IMP TIPS for JEE & other competitive exams (Part-4) #iit #jee #part4 #jee2024	MOST IMP TIPS for JEE & other competitive exams (Part-4) #iit #jee #part4 #jee2024	Part 1 Link: https://youtube.com/shorts/5goNjmztwqg?si=MLo-xkuwoHa97I9a\nPart-2 Link: https://youtube.com/shorts/0jstRcQmAro?si=x3LNqM-81u5rtspG\nPart-3 Link: https://youtube.com/shorts/XWFbqR_9fqc?si=j2fgA7_ngab4txD4\nPart 5 Link: https://youtube.com/shorts/s_PoEssiuPo?si=xiUkWMcwSak3EFIk\n\n🚀 Unleash Your Exam Superpowers: Essential Tips for JEE & Competitive Exams 🚀\nAce your JEE and competitive exams with the ultimate guide! 🌟 \nI'm sharing the most crucial tips to level up your preparation game. From mindset hacks to time-saving tricks, these strategies are your ticket to success. 🎓 \nReady to boost your study game? Hit play now and stay tuned for more exam-winning insights! 🚀✨\n#JEE2024 #ExamTips #StudySmart #shorts #iit #iitjee #part1	562	t	t	2024-01-23 00:00:00	58	60s	public	\N	\N	related_video	s_PoEssiuPo	f	{}	s_PoEssiuPo	{#iit,#jee,#part4,#jee2024}	{#JEE2024,#ExamTips,#StudySmart,#shorts,#iit,#iitjee,#part1}	f	{}	f	2024	educational	exam_tips	{"style": "text_overlay", "has_face": false, "dominant_color": "#000000"}	series_continuation	educational_tips	hinglish	description_link	2026-09-01 09:29:40.491408	2026-09-02 10:03:13.106027
5	s_PoEssiuPo	MOST IMP TIPS for JEE & other competitive exams (Part-5) #iit #jee #part5 #jee2024	MOST IMP TIPS for JEE & other competitive exams (Part-5) #iit #jee #part5 #jee2024	Part 1 Link: https://youtube.com/shorts/5goNjmztwqg?si=MLo-xkuwoHa97I9a\nPart 2 Link: https://youtube.com/shorts/0jstRcQmAro?si=x3LNqM-81u5rtspG\nPart 3 Link: https://youtube.com/shorts/XWFbqR_9fqc?si=j2fgA7_ngab4txD4\nPart 4 Link: https://youtube.com/shorts/Pwp0zPAY6Y4?si=FEq7nbgPLmaW8_2T\n\n🚀 Unleash Your Exam Superpowers: Essential Tips for JEE & Competitive Exams 🚀\nAce your JEE and competitive exams with the ultimate guide! 🌟 \nI'm sharing the most crucial tips to level up your preparation game. From mindset hacks to time-saving tricks, these strategies are your ticket to success. 🎓 \nReady to boost your study game? Hit play now and stay tuned for more exam-winning insights! 🚀✨\n#JEE2024 #ExamTips #StudySmart #shorts #iit #jee #part5	547	t	t	2024-01-24 00:00:00	58	60s	public	\N	\N	none	\N	f	{}	\N	{#iit,#jee,#part5,#jee2024}	{#JEE2024,#ExamTips,#StudySmart,#shorts,#iit,#jee,#part5}	f	{}	f	2024	educational	exam_tips	{"style": "text_overlay", "has_face": false, "dominant_color": "#000000"}	series_finale	educational_tips	hinglish	description_link	2026-09-01 09:42:27.379694	2026-09-02 10:03:18.329293
57	9jXcNZyYza8	⚠️LAST 3 DAYS, DO THIS to improve your rank by 5K in Jee Advanced 2024!! #jee2024 #iitjee #shorts	LAST 3 DAYS, DO THIS to improve your rank by 5K in Jee Advanced 2024!! #jee2024 #iitjee #shorts	⛒️ Attention JEE Advanced 2024 aspirants! Want to boost your rank by 5K? In this short video, we'll reveal powerful tips and strategies that can help you achieve a significant improvement in your JEE Advanced rank.\n\nJoin us to discover key study techniques, time management hacks, and crucial exam day strategies that can make all the difference. Don't miss out on these valuable insights that could transform your performance!\n\nHit play now to unlock your potential and climb the ranks in JEE Advanced 2024. Share this video with your fellow aspirants to help them succeed too. Let's achieve our dreams together! ⛒️\n\n#JEE2024 #iitbombay #iitdelhi #motivation  #JEEPrep #iitjee #iit #examtips #jeemains #jeemainsresult #jeeadvanced #iitb #iitd #dtu #shorts #result #jeeresults #jeemainsresult #jeemains2024 #jeeadvanced2024	823	t	f	2024-05-20 00:00:00	59	15-60s	public	\N	\N	video	JOSAA_Counselling_Complete_Process_Step_by_Step_All_about_JOSAA_Counselling_JEE_2024	t	{none,hi}	JOSAA_Counselling_Complete_Process_Step_by_Step_All_about_JOSAA_Counselling_JEE_2024	{#jee2024,#iitjee,#shorts}	{#JEE2024,#iitbombay,#iitdelhi,#motivation,#JEEPrep,#iitjee,#iit,#examtips,#jeemains,#jeemainsresult,#jeeadvanced,#iitb,#iitd,#dtu,#shorts,#result,#jeeresults,#jeemainsresult,#jeemains2024,#jeeadvanced2024}	t	{⚠️}	t	2024	fear_mistake_warning	impossible_promise	{"style": "text_overlay", "has_face": false, "dominant_color": "#000000"}	urgency	fear_mistake_warning	Hinglish	description_only	2026-09-06 09:14:07.3586	2026-09-06 09:14:07.3586
9	XM1AzgVMeqk	🔴CORRECT way to check ANSWER KEY | JEE MAINS 2024 #jee2024 #iit	CORRECT way to check ANSWER KEY | JEE MAINS 2024 #jee2024 #iit	I know many of you are worried about 27 Jan S1 issue, so for you all i talked with NTA \nYou should listen to their reply in my latest video 👇\nLink: https://youtu.be/Eb-YMXU_be4?si=onP9G5Z6HEdfP_rQ\n\nCalling all JEE Mains 2024 aspirants! 🚀 Want to ensure you're checking the answer key the right way? In this short video, I'll guide you through the correct method to verify your answers effectively.\n\nJoin me as I share essential tips and strategies to navigate through the JEE Mains 2024 answer key with confidence and precision.🕵️‍♂️ Check out my channel\n\nDon't miss out on this crucial insight that can elevate your exam preparation game! Hit the like button and share this video with your fellow JEE aspirants. Let's ace JEE Mains 2024 together! 🔥\n\nTags: #JEE #JEE2024 #JEEPreparation #ExamTips #AnswerKey #Shorts #StudyShorts #JEEExam #ExamStrategy 📚	853	t	t	2024-02-07 00:00:00	60	15-60s	public	\N	\N	video	ZpSpypF1E38	f	{none,hi,en-auto}	ZpSpypF1E38	{jee2024,iit}	{JEE,JEE2024,JEEPreparation,ExamTips,AnswerKey,Shorts,StudyShorts,JEEExam,ExamStrategy}	t	{🔴,🚀,🕵️‍♂️,🔥,📚,👇}	t	2024	uncertainty_resolution	answer_key_guide	{}	urgency	uncertainty_resolution	Hinglish	description_only	2026-09-02 09:02:32.054168	2026-09-02 09:25:46.312192
11	_A5Idj7SddI	🚨JEE MAINS LATEST UPDATE!!🚨 Result Soon!! #jee2024 #iit #iitjee	JEE MAINS LATEST UPDATE!! Result Soon!! #jee2024 #iit #iitjee	🔔 Attention all JEE Mains 2024 aspirants! Exciting news awaits! In this short video, I'm here to share the latest update straight from NTA regarding the final answer key for JEE Mains 2024.\n\nGet ready to discover the finalized answers that can make a difference in your exam outcome. Stay tuned as I break down the key highlights and implications of the NTA's release of the final answer key.\n\nDon't miss out on this crucial update that can shape your exam preparation strategy and boost your confidence. Hit the like button and share this video with your friends preparing for JEE Mains 2024! Let's stay informed and ready to ace the exam! 🌟\n\n#JEE #JEEMAINS #ExamUpdate #EngineeringEntrance #StayInformed  #AcademicExcellence #jee2024 #iit #iitjee #jeemains #result #AnswerKey #finalanswerkey #EducationalInsights 🚀📝✨	818	t	f	2024-02-12 00:00:00	29	15-30s	public	\N	\N	none	\N	f	{none,en-auto}	\N	{jee2024,iit,iitjee}	{JEE,JEEMAINS,ExamUpdate,EngineeringEntrance,StayInformed,AcademicExcellence,jeemains,result,AnswerKey,finalanswerkey,EducationalInsights}	t	{🚨,🚨,🔔,🌟,🚀,📝,✨}	t	2024	breaking_news	result_update	{}	urgency	breaking_news	Hinglish	description_only	2026-09-02 09:12:13.902042	2026-09-02 09:25:47.534266
90	SOKrC7BJ418	😨ROUND 1 VS ROUND 2 | Cutoff Analysis | JAC Delhi 2024 #jacdelhi #dtu #shorts	😨ROUND 1 VS ROUND 2 | Cutoff Analysis | JAC Delhi 2024 #jacdelhi #dtu #shorts	JAC Delhi 2024 Round 2 results are out!! \nHere, is the quick analysis of round 1 vs round 2 cutoff!!\nStay tuned and make sure you don't miss out on any crucial information. Whether you’ve got the seat you aimed for or are gearing up for the next round, we’re here to guide you through every step.\n🔴JAC DELHI 2024 Videos:	320	f	f	\N	60	15-60s	public	\N	\N	\N	\N	t	{en,hi}	\N	{#jacdelhi,#dtu,#shorts}	{}	t	{😨}	f	2024	educational	breaking_news	{"style": "text_overlay", "has_face": false, "dominant_color": "#FF0000"}	curiosity	result_notification	Hinglish	none	2026-09-11 16:35:55.319378	2026-09-11 22:58:07.871575
8	12BKLbv0Eso	🔴FULL PROCEDURE for all shifts | ANSWER KEY | 27 S1 Issue discussed | Jee Mains 2024 #jee2024	FULL PROCEDURE for all shifts | ANSWER KEY | 27 S1 Issue discussed | Jee Mains 2024 #jee2024	I know many of you are worried about 27 Jan S1 issue, so for you all i talked with NTA \nYou should listen to their reply in my latest video 👇\nLink: https://youtu.be/Eb-YMXU_be4?si=onP9G5Z6HEdfP_rQ\n\nIn this video, we'll walk you through the step-by-step process, to how to download response sheet and see answer key & calculate your marks. Plus, we'll delve into the specific challenge arising from the 27 Jan Shift 1 exam, providing insights to navigate through it with confidence.\n\nReady to take your exam preparation to the next level? Press play now and join us on this insightful journey!\n\nDon't forget to subscribe for more invaluable tips and updates to propel your academic journey forward!\n\n#JEE #JEEMAINS #ExamUpdate #EngineeringEntrance #StayInformed  #AcademicExcellence #jee2024 #iit #iitjee #jeemains #result #AnswerKey #SolutionCalculation #ExamPreparation #27JanIssue #EducationalInsights 🚀📝✨	907	t	t	2024-02-07 00:00:00	61	15-60s	public	\N	\N	none	\N	f	{none,hi,en-auto}	\N	{jee2024}	{JEE,JEEMAINS,ExamUpdate,EngineeringEntrance,StayInformed,AcademicExcellence,jeemains,result,AnswerKey,SolutionCalculation,ExamPreparation,27JanIssue,EducationalInsights}	t	{🔴,👇,🚀,📝,✨}	t	2024	uncertainty_resolution	answer_key_procedure	{}	urgency	uncertainty_resolution	Hinglish	description_only	2026-09-02 08:57:44.373087	2026-09-02 09:25:45.151529
10	nJNR60Ms1BE	🚀NTA Latest Update!! 🚀 Challenging Answer Key | Jee Mains 2024 #jee2024	NTA Latest Update!! Challenging Answer Key | Jee Mains 2024 #jee2024	Live Call with NTA: https://youtu.be/Eb-YMXU_be4?si=fLZ33St8rrfExEe3\nResult Declaration Process Explained!: https://youtu.be/QfFYhySY2rI?si=70ZbG9DGFX4qPyvU\n\n📢 Attention JEE Mains 2024 aspirants! Wondering about the latest update from NTA regarding answer key challenge dates? Look no further! In this short video, I'll bring you up to speed on the crucial information you need to know.\n\nStay tuned as I unravel the important details about the NTA's announcement regarding the challenge dates for the JEE Mains 2024 answer key. Don't miss out on this time-sensitive update that can impact your exam preparation strategy!\n\nHit the like button and share this video with your fellow JEE aspirants to keep everyone informed. Stay ahead of the curve with the latest updates from NTA! 🔥\n\n#JEE #JEEMAINS #ExamUpdate #EngineeringEntrance #StayInformed #jee2024 #iit #iitjee #jeemains #result #AnswerKey #AnswerKeyChallenge #JEEPreparation #ExamUpdate #Shorts #JEEExam #ExamStrategy 📚	975	t	t	2024-02-07 00:00:00	61	15-60s	public	\N	\N	none	\N	f	{none,hi,en-auto}	\N	{jee2024}	{JEE,JEEMAINS,ExamUpdate,EngineeringEntrance,StayInformed,iit,iitjee,jeemains,result,AnswerKey,AnswerKeyChallenge,JEEPreparation,ExamUpdate,Shorts,JEEExam,ExamStrategy}	t	{🚀,🚀,📢,🔥,📚}	f	2024	breaking_news	nta_update	{}	urgency	breaking_news	Hinglish	description_only	2026-09-02 09:07:53.238004	2026-09-02 09:25:47.152763
82	A2U9omXQ2go	🔴 ROUND 1 RESULTS OUT?? | JAC Delhi 2024 #jee2024 #jacdelhi #shorts	🔴UPTAC 2024 DEADLINES!! Free Counselling Support for UPTAC #uptac #aktu #shorts	Attention UPTAC aspirants! 📢 The important deadlines for UPTAC 2024 are here, and you don't want to miss them! We're offering FREE counseling support to help you navigate the entire process. Get expert advice, stay on top of deadlines, and ensure your application is flawless. 📅\n\nThis is your chance to get all the help you need to secure your spot. Don't miss out on this golden opportunity! Subscribe for more updates and turn on notifications to stay informed.\n\n#aktu #uptac #jee2024	486	f	f	\N	49	15-60s	public	\N	\N	\N	\N	f	{}	\N	{uptac,aktu,jee2024,counselling,support}	{exam,counselling,admissions,deadlines}	t	{🔴}	f	2024	educational	counselling	{}	attention_grab	educational	Hinglish	none	2026-09-11 12:57:35.796334	2026-09-11 13:05:32.12302
24	pHfj5VVN0Ew	🔴 RESULT UPDATE for JEE Mains April | Jee Advanced Update Also | Jee 2024 #jee2024 #iit #shorts	RESULT UPDATE for JEE Mains April | Jee Advanced Update Also | Jee 2024 #jee2024 #iit #shorts	We got a update from IIT Madras for JEE Advanced which indirectly tells us about JEE Mains April Attempt Result Date 🤫\nWatch this video to get in IIT in 40 Days: https://youtu.be/ZpSpypF1E38?si=6VQCchTitqbmzUvh\n#jeemains #jeemainsresult2024 #jeemains2024 #jeeadvanced #jeeadvanced2024 #jee2024 #iitjee #iit #iitb #iitd #iit_motivation	334	t	t	2024-04-11 00:00:00	49	15-60s	public	\N	\N	video	ZpSpypF1E38	t	{none,hi,en-auto}	ZpSpypF1E38	{jee2024,iit,shorts}	{jeemains,jeemainsresult2024,jeemains2024,jeeadvanced,jeeadvanced2024,jee2024,iitjee,iit,iitb,iitd,iit_motivation}	t	{🔴}	t	2024	result_update	result_date_speculation	{}	breaking_news	result_update	Hinglish	description_with_link	2026-09-03 08:52:31.076945	2026-09-03 08:52:31.076945
83	fsSkI-1Opvk	🚨 ROUND 1 RESULTS OUT!! JAC DELHI 2024 | NO CLICKBAIT #jee2024 #jacdelhi #shorts	🚨 ROUND 1 RESULTS OUT!! JAC DELHI 2024 | NO CLICKBAIT #jee2024 #jacdelhi #shorts	Round 1 results for JAC Delhi 2024 finally out!! 🤔\nStay tuned and make sure you don't miss out on any crucial information. Whether you’ve got the seat you aimed for or are gearing up for the next round, we’re here to guide you through every step.\n🔴JAC DELHI 2024 Videos:	270	f	f	\N	60	15-60s	public	\N	\N	\N	\N	t	{en,hi}	\N	{#jee2024,#jacdelhi,#shorts}	{}	t	{🚨}	t	2024	educational	result_alert	{"style": "text_overlay", "has_face": false, "dominant_color": "#FF0000"}	urgency	result_notification	Hinglish	none	2026-09-11 16:20:32.995425	2026-09-11 22:58:05.388618
12	BJ5lJob_sDU	🔴RESULT IS OUT | JEE MAINS 2024 💯 #jee2024 #iit #iitjee	RESULT IS OUT | JEE MAINS 2024 💯 #jee2024 #iit #iitjee	🔥 Attention all JEE Mains 2024 candidates! The moment you've been waiting for has arrived – the JEE Mains 2024 results are finally out! 📣 In this short video, I'll guide you on how to check your results and celebrate your achievements.\n\nStay tuned as I share the latest updates and provide step-by-step instructions on accessing your JEE Mains 2024 results. Whether you're brimming with excitement or feeling a bit nervous, I'm here to help you navigate through the process with ease.\n\nDon't miss this opportunity to rejoice in your hard work and dedication. Hit the like button and share this video with your friends who appeared for JEE Mains 2024. Let's celebrate this milestone together! 🎊\n\n#JEE #JEEMAINS #ExamUpdate #EngineeringEntrance #StayInformed  #AcademicExcellence #jee2024 #iit #iitjee #jeemains #result #jeemainsresult  #EducationalInsights 🚀📝✨	859	t	f	2024-02-12 00:00:00	39	15-30s	public	\N	\N	none	\N	f	{none,en-auto}	\N	{jee2024,iit,iitjee}	{JEE,JEEMAINS,ExamUpdate,EngineeringEntrance,StayInformed,AcademicExcellence,jeemains,result,jeemainsresult,EducationalInsights}	t	{🔴,💯,🔥,📣,🎊,🚀,📝,✨}	t	2024	breaking_news	result_update	{}	urgency	breaking_news	Hinglish	description_only	2026-09-02 09:20:33.221739	2026-09-02 09:25:47.870198
58	eC_j1wlFJBw	❤️ DON'T FORGET THIS THINGS for JEE Advanced 2024 #jee2024 #iitjee #shorts	DON'T FORGET THIS THINGS for JEE Advanced 2024 #jee2024 #iitjee #shorts	✨ Attention JEE Advanced 2024 aspirants! Make sure you're fully prepared with these crucial guidelines for the upcoming exam. In this short video, we'll cover all the essential rules and tips you need to know to excel on exam day.\n\nJoin us as we outline important instructions, from what to bring and what to avoid, to key strategies for tackling the exam efficiently. Staying informed and prepared is the key to success!\n\nHit play now to ensure you don’t miss any important guidelines for JEE Advanced 2024. Share this video with your fellow aspirants to help them stay on track. Let’s ace this exam together! ⚀️\n\n#JEE2024 #iitbombay #iitdelhi #motivation  #iitjee #iit #jeeadvanced #iitb #iitd #dtu #shorts#jeemains2024 #jeeadvanced2024	738	t	f	2024-05-21 00:00:00	53	15-60s	public	\N	\N	video	JOSAA_COUNSELLING_VIDEO_ID	t	{none,hi}	JOSAA_COUNSELLING_VIDEO_ID	{#jee2024,#iitjee,#shorts}	{#JEE2024,#iitbombay,#iitdelhi,#motivation,#iitjee,#iit,#jeeadvanced,#iitb,#iitd,#dtu,#shorts,#jeemains2024,#jeeadvanced2024}	t	{❤️}	f	2024	educational	exam_tips	{"style": "text_overlay", "has_face": false, "dominant_color": "#000000"}	urgency	educational	Hinglish	description_only	2026-09-06 09:30:05.833783	2026-09-06 09:30:05.833783
1	5goNjmztwqg	MOST IMP TIPS for JEE & other competitive exams (Part-1) #iit #jee #part1 #jee2024	MOST IMP TIPS for JEE & other competitive exams (Part-1) #iit #jee #part1 #jee2024	Part 2 Link: https://youtube.com/shorts/0jstRcQmAro?si=x3LNqM-81u5rtspG\nPart 3 Link: https://youtube.com/shorts/XWFbqR_9fqc?si=j2fgA7_ngab4txD4\nPart 4 Link: https://youtube.com/shorts/Pwp0zPAY6Y4?si=FEq7nbgPLmaW8_2T\nPart 5 Link: https://youtube.com/shorts/s_PoEssiuPo?si=xiUkWMcwSak3EFIk\n\n🚀 Unleash Your Exam Superpowers: Essential Tips for JEE & Competitive Exams 🚀\nAce your JEE and competitive exams with the ultimate guide! 🌟 \nI'm sharing the most crucial tips to level up your preparation game. From mindset hacks to time-saving tricks, these strategies are your ticket to success. 🎓 \nReady to boost your study game? Hit play now and stay tuned for more exam-winning insights! 🚀✨\n#JEE2024 #ExamTips #StudySmart #shorts #iit #iitjee #part1	1156	t	t	2024-01-22 00:00:00	52	15-60s	public	\N	\N	related_video	0jstRcQmAro	t	{en,hi}	0jstRcQmAro	{iit,jee,part1,jee2024}	{JEE2024,ExamTips,StudySmart,shorts,iit,iitjee,part1}	f	{🚀,🌟,🎓,✨}	f	2024	educational	exam_tips	{"style": "auto-generated", "selected": 2}	educational_hook	educational_value	Hinglish	description_end	2026-08-31 21:31:15.834273	2026-09-02 09:45:39.987643
15	yDKB-xCaMB8	🔥DON'T MISS this opportunity | Jee Mains 2024 #jee2024 #iit #iitjee #shorts	🔥DON'T MISS this opportunity | Jee Mains 2024 #jee2024 #iit #iitjee #shorts	Shorts Link: https://youtube.com/shorts/2jcdStwq2yY?si=ft4r3II-Uhp319fe\nPDF link: https://jeemain.nta.ac.in/images/public-notice-for-extension-and-correction-of-jee-main-2024-session-2.pdf\n\n🔔 Hey there, JEE Mains aspirants! Hold onto your seats because I have an urgent update you need to hear! In this quick video, I'll be sharing critical information that could impact your JEE Mains journey in a big way.\n\nFrom exam date changes to key preparation tips, I've got all the details you need to stay on top of your game. This alert could be the difference between just preparing and preparing smartly for your upcoming exam.\n\nDon't miss out – hit play now and make sure you're in the know! Share this video with your friends who are also gearing up for JEE Mains. Let's conquer this challenge together and make our JEE dreams a reality! 🌟\n\n#JEE #JEEMAINS #ExamUpdate #EngineeringEntrance #StayInformed  #AcademicExcellence #jee2024 #iit #iitjee #jeemains #jeemains2024  #aprilattempt  #SolutionCalculation #ExamPreparation #deadline #EducationalInsights #lastdatetoapply #registration 🚀📝✨	1087	t	t	2024-03-03 00:00:00	61	15-60s	public	\N	\N	related_video	yDKB-xCaMB8	t	{hi,en}	2jcdStwq2yY	{jee2024,iit,iitjee,shorts}	{JEE,JEEMAINS,ExamUpdate,EngineeringEntrance,StayInformed,AcademicExcellence,jee2024,iit,iitjee,jeemains,jeemains2024,aprilattempt,SolutionCalculation,ExamPreparation,deadline,EducationalInsights,lastdatetoapply,registration}	t	{🔥,🌟,🚀,📝,✨,🔔}	t	2024	breaking_news	circular_update	{"style": "auto-generated", "selected": 1}	urgent_alert	time_sensitive_info	Hinglish	description_end	2026-09-02 14:30:31.576863	2026-09-02 14:30:31.576863
21	JmSdjrAxNFM	⚡ DO THIS in LAST 3 Days | JEE MAINS 2024 😱 #jee2024 #iit #iitjee #shorts	DO THIS in LAST 3 Days | JEE MAINS 2024 #jee2024 #iit #iitjee #shorts	🔔 Attention all JEE Mains 2024 aspirants! With just 3 days left until the big exam, it's crucial to make every moment count. In this short video, I'll share essential tips on what you should prioritize in these final days of preparation.\n\nTags: #JEEMains #AdmitCard #AprilAttempt #JEE #jee2024 #jeemains2024 #ExamDates #Shorts #ExamUpdate #JEEPreparation 📚	356	t	f	2024-04-02 00:00:00	50	15-60s	public	\N	\N	none	\N	t	{none,hi,en-auto}	\N	{jee2024,iit,iitjee,shorts}	{JEEMains,AdmitCard,AprilAttempt,JEE,jee2024,jeemains2024,ExamDates,Shorts,ExamUpdate,JEEPreparation}	t	{⚡,😱}	f	2024	exam_tips	last_minute_tips	{}	urgency	exam_tips	Hinglish	description_only	2026-09-03 08:43:48.484092	2026-09-03 08:43:48.484092
25	dpTHfuBYClo	🔴 PROVISIONAL ANSWER Key Out!! for April Attempt | Jee 2024 #jee2024 #iit #short	PROVISIONAL ANSWER Key Out!! for April Attempt | Jee 2024 #jee2024 #iit #short	🔔 Attention JEE 2024 aspirants! The moment you've been waiting for is here – the provisional answer key for the April attempt is now available! In this short video, I'll guide you through the process of accessing and utilizing the provisional answer key effectively.\n#jee2024 #iit #provisionalanswerkey #jeemainsanswerkey	321	t	f	2024-04-12 00:00:00	57	15-60s	public	\N	\N	video	ZpSpypF1E38	t	{none,hi,en-auto}	ZpSpypF1E38	{jee2024,iit,short}	{jee2024,iit,provisionalanswerkey,jeemainsanswerkey}	t	{🔴}	t	2024	result_update	provisional_answer_key	{}	breaking_news	result_update	Hinglish	description_only	2026-09-03 08:54:48.143719	2026-09-03 08:54:48.143719
16	rg5iPj-249o	🚨JEE, NEET, CUET dates CHANGED?? Due to Elections? #jee #jee2024 #neet #cuet #shorts	🚨JEE, NEET, CUET dates CHANGED?? Due to Elections? #jee #jee2024 #neet #cuet #shorts	🔔 Attention to all JEE, NEET, and CUET aspirants! Hold onto your seats because your all doubts regarding exam dates changing is entertained. In this short video, I'll be unraveling whether exam dates changed or not and how they're influenced by the upcoming elections.\n\nJoin me as we explore the impact of the election schedule on the dates of these crucial exams. Stay informed to ensure you're prepared for any adjustments that may affect your exam preparation and scheduling.\n\nHit play now and stay ahead of the curve! Don't forget to share this video with your friends who are also preparing for JEE, NEET, or CUET. Let's navigate through these changes together and emerge stronger than ever! 🌟\n\nTags: #JEE #NEET #CUET #ExamDates #Elections #Shorts #ExamUpdate #JEEPreparation #NEETPreparation #CUETPreparation #loksabhaelection2024  📚	839	t	f	2024-03-17 00:00:00	61	15-60s	public	\N	\N	related_video	rg5iPj-249o	t	{hi,en}	JEE Mains 2024: Score 180+ in 10 Days 🔥| Complete Plan | April Attempt	{jee,jee2024,neet,cuet,shorts}	{JEE,NEET,CUET,ExamDates,Elections,Shorts,ExamUpdate,JEEPreparation,NEETPreparation,CUETPreparation,loksabhaelection2024}	t	{🚨,🔔,🌟,📚}	t	2024	breaking_news	schedule_alert	{"style": "auto-generated", "selected": 1}	urgent_question	time_sensitive_info	Hinglish	description_end	2026-09-02 14:58:55.032747	2026-09-02 14:58:55.032747
17	waW201cvfl8	🎉 E-SUMMIT'24 TRAILER 🎬 #iit #jee #shorts	🎉 E-SUMMIT'24 TRAILER 🎬 #iit #jee #shorts	Full Video Released: Day1: https://youtu.be/9WY-wTQ... (truncated)	66	t	t	2024-03-24 00:00:00	61	15-60s	public	\N	\N	related_video	waW201cvfl8	t	{hi,en}	9WY-wTQ	{iit,jee,shorts}	{}	t	{🎉,🎬}	f	2024	campus_lifestyle	event_promo	{"style": "auto-generated", "selected": 1}	event_trailer	entertainment	Hinglish	description_end	2026-09-02 15:14:09.210888	2026-09-02 15:14:09.210888
18	Ay9K30yrg8Y	🔴 Jee Adv Dates CHANGED?? 🤔 #jee2024 #iit #iitjee #shorts	🔴 Jee Adv Dates CHANGED?? 🤔 #jee2024 #iit #iitjee #shorts	🔔 Attention all JEE Advanced aspirants! Are the JEE Advanced dates really changing? Let's clear the confusion once and for all.\n\nIn this video, I break down the official updates regarding JEE Advanced 2024 exam dates and whether any changes have been announced. Stay informed so you can plan your preparation without any uncertainty.\n\nHit play now to get the facts straight and share this with your friends who are also waiting for clarity! 📚\n\n#JEEAdvanced #JEE2024 #ExamDates #IIT #JEEPreparation #ExamUpdate #Shorts	517	t	f	2024-03-27 00:00:00	43	15-60s	public	\N	\N	related_video	Ay9K30yrg8Y	t	{hi,en}	\N	{jee2024,iit,iitjee,shorts}	{JEEAdvanced,JEE2024,ExamDates,IIT,JEEPreparation,ExamUpdate,Shorts}	t	{🔴,🤔,🔔,📚}	t	2024	breaking_news	schedule_alert	{"style": "auto-generated", "selected": 1}	uncertainty_resolution	time_sensitive_info	Hinglish	description_end	2026-09-02 15:27:50.633383	2026-09-02 15:27:50.633383
19	lmbndk-Db-Q	📢RELEASED!! Jee Mains City Intimation 😑 #jee2024 #iit #iitjee #shorts	📢RELEASED!! Jee Mains City Intimation 😑 #jee2024 #iit #iitjee #shorts	🔔 Attention all JEE Mains aspirants! The moment you've been waiting for has arrived – the release of city intimation for the exam! In this short video, I'll be sharing the exciting news and what it means for you.\n\nJoin me as we delve into the details of the city intimation release, which plays a crucial role in your exam preparation and planning. Whether you're traveling from afar or just around the corner, knowing your exam city is a key step towards being fully prepared.\n\nHit play now to stay informed and ensure you're ready for the upcoming JEE Mains exam. Don't forget to share this video with your friends who are also appearing for JEE Mains. Let's support each other as we embark on this important journey! 🌟\n\nTags: #JEE #jee2024 #jeemains2024 #ExamDates #Elections #Shorts #ExamUpdate #JEEPreparation #jeemains2024 #jeemainscityintimation  📚	855	t	f	2024-03-28 00:00:00	55	15-60s	public	\N	\N	related_video	lmbndk-Db-Q	t	{hi,en}	JEE Mains 2024: Score 180+ in 10 Days 🔥| Complete Plan | April Attempt	{jee2024,iit,iitjee,shorts}	{JEE,jee2024,jeemains2024,ExamDates,Elections,Shorts,ExamUpdate,JEEPreparation,jeemains2024,jeemainscityintimation}	t	{📢,😑,🔔,🌟,📚}	f	2024	breaking_news	schedule_alert	{"style": "auto-generated", "selected": 1}	official_release	time_sensitive_info	Hinglish	description_end	2026-09-02 21:49:28.223132	2026-09-02 21:49:28.223132
20	cSapjDf5CHY	🚨 Admit Card Out!! Jee Mains 2024 April | All shifts😱 #jee2024 #iit #iitjee #shorts	🚨 Admit Card Out!! Jee Mains 2024 April | All shifts😱 #jee2024 #iit #iitjee #shorts	Admit Card Link: https://jeemainsession2.ntaonline.in/frontend/web/advancecityintimationslip/admit-card\n\n🔔 Attention all JEE Mains aspirants for the April attempt! The wait is over – the JEE Mains admit cards have been released! In this short video, I'll be sharing the exciting news and what you need to know about your admit card.\n\nJoin me as we discuss the significance of the admit card and the essential details it contains. From exam center location to important instructions, your admit card is your ticket to the JEE Mains exam.\n\nHit play now to stay informed and ensure you have everything you need for a smooth exam day experience. Don't forget to share this video with your friends who are also appearing for JEE Mains in April. Let's ace this exam together! 🌟\n\nTags: #JEEMains #AdmitCard #AprilAttempt #JEE #jee2024 #jeemains2024 #ExamDates #Shorts #ExamUpdate #JEEPreparation 📚	890	t	t	2024-03-31 00:00:00	31	15-60s	public	\N	\N	related_video	cSapjDf5CHY	t	{hi,en}	JEE Mains 2024: Score 180+ in 10 Days 🔥| Complete Plan | April Attempt	{jee2024,iit,iitjee,shorts}	{JEEMains,AdmitCard,AprilAttempt,JEE,jee2024,jeemains2024,ExamDates,Shorts,ExamUpdate,JEEPreparation}	t	{🚨,😱,🔔,🌟,📚}	t	2024	breaking_news	admit_card_release	{"style": "auto-generated", "selected": 2}	official_release	time_sensitive_info	Hinglish	description_end	2026-09-02 23:46:30.338612	2026-09-02 23:46:30.338612
22	MpQ-K2D9Ao4	😱92%ile can also get into IIT | Jee Advanced 2024 #iit #jee2024 #iitjee #shorts	92%ile can also get into IIT | Jee Advanced 2024 #iit #jee2024 #iitjee #shorts	JEE ADVANCED DAY WISE STARTEGY: https://youtu.be/ZpSpypF1E38?si=qdsw2koELlzGqVRH\n#JEE2024#iitbombay #iitdelhi #motivation  #JEEPrep #iitjee #iit #examtips #jeemains #jeeadvanced #iitb #iitd #dtu #shorts	202	t	t	2024-04-08 00:00:00	56	15-60s	public	\N	\N	video	ZpSpypF1E38	t	{none,hi,en-auto}	ZpSpypF1E38	{iit,jee2024,iitjee,shorts}	{JEE2024,iitbombay,iitdelhi,motivation,JEEPrep,iitjee,iit,examtips,jeemains,jeeadvanced,iitb,iitd,dtu,shorts}	t	{😱}	f	2024	motivation	percentile_motivation	{}	curiosity	motivation	Hinglish	description_with_link	2026-09-03 08:46:53.14088	2026-09-03 08:46:53.14088
13	OkWbChCIb04	🚨ALERT!! JEE Mains Aspirants 🚨 #jee2024 #iit #iitjee	ALERT!! JEE Mains Aspirants #jee2024 #iit #iitjee	🔔 Attention all JEE Mains aspirants! This is a crucial alert you can't afford to miss! In this short video, I'll be sharing vital information that directly impacts your JEE Mains journey.\n\nStay tuned as I unveil important updates, tips, and reminders tailored specifically for JEE Mains aspirants like you. Whether it's exam dates, preparation strategies, or last-minute tips, I've got you covered.\n\nDon't underestimate the power of staying informed and prepared. Hit the like button and share this video with your fellow JEE Mains aspirants to ensure everyone is on the right track for success! 🌟\n\n#JEE #JEEMAINS #ExamUpdate #EngineeringEntrance #StayInformed  #AcademicExcellence #jee2024 #iit #iitjee #jeemains #jeemains2024  #aprilattempt  #SolutionCalculation #ExamPreparation #deadline #EducationalInsights #lastdatetoapply #registration 🚀📝✨	669	t	f	2024-03-02 00:00:00	61	15-60s	public	\N	\N	none	\N	f	{none,hi,en-auto}	\N	{jee2024,iit,iitjee}	{JEE,JEEMAINS,ExamUpdate,EngineeringEntrance,StayInformed,AcademicExcellence,jee2024,iit,iitjee,jeemains,jeemains2024,aprilattempt,SolutionCalculation,ExamPreparation,deadline,EducationalInsights,lastdatetoapply,registration}	t	{🚨,🚨,🔔,💪,🚀,📚,✨}	t	2024	breaking_news	alert	{}	urgency	breaking_news	Hinglish	description_only	2026-09-02 10:13:50.522983	2026-09-03 09:12:42.914466
59	Q-IS9K8g294	🚨CBSE class 12 & 10 important dates!! (re-evaluation) #cbse #class12result #class10result #shorts	CBSE class 12 & 10 important dates!! (re-evaluation) #cbse #class12result #class10result #shorts	🔔 Attention CBSE Class 12 & 10 students! Need to know the key dates and fees for the re-evaluation process? In this short video, we'll provide you with all the essential details to ensure you don’t miss any important deadlines.\n\nJoin us as we outline the re-evaluation application dates, fee structure, and step-by-step instructions on how to apply. Staying informed will help you make the most of this opportunity to improve your scores!\n\nHit play now to get all the information you need about the CBSE re-evaluation process. Share this video with your classmates to help them stay updated too. Let’s make sure everyone gets the marks they deserve! 🚀\n\n#cbse #cbse2024 #cbseresulttoday #cbseresultclass12 #cbseclass10 #cbseboard #cbseclass12 #cbseresult #cbseresult2024 #cbseupdates #class10result #class12result	812	t	f	2024-05-21 00:00:00	59	15-60s	public	\N	\N	video	RELATED_VIDEO_ID	t	{none,hi}	RELATED_VIDEO_ID	{#cbse,#class12result,#class10result,#shorts}	{#cbse,#cbse2024,#cbseresulttoday,#cbseresultclass12,#cbseclass10,#cbseboard,#cbseclass12,#cbseresult,#cbseresult2024,#cbseupdates,#class10result,#class12result}	t	{🚨}	t	2024	educational	exam_tips	{"style": "text_overlay", "has_face": false, "dominant_color": "#000000"}	urgency	educational	Hinglish	description_only	2026-09-06 09:52:18.827983	2026-09-06 09:52:18.827983
76	a6DGQWZ57EE	😨DON'T HAVE CATEGORY CERTIFICATE?? SEAT WILL CANCEL IN JAC/JOSAA?? #jee2024 #josaa #shorts	😨DON'T HAVE CATEGORY CERTIFICATE?? SEAT WILL CANCEL IN JAC/JOSAA?? #jee2024 #josaa #shorts	Hey JEE aspirants! 🌟 Worried about your category certificate and its impact on your JAC/JoSAA counselling? Don't panic! In this video, we break down what happens if you don't have your category certificate and how it can affect your seat.\n#jee2024 #jeeadvanced #iit #iitbombay #iitjee #iitdelhi #jeeadvanced2024 #josaa	318	f	f	\N	57	15-60s	public	\N	\N	\N	\N	f	{}	\N	{jee,advanced,jee2024,motivation,movie}	{exam,jeeadvanced,results,reproduction}	t	{😨}	f	2024	educational	exam_tips	{}	attention_grab	educational	Hinglish	none	2026-09-10 19:31:27.388867	2026-09-10 19:33:03.635723
69	Mp1WHa-CXfw	🚨 FULL SCHEDULE & BROCHURE RELEASED!! | JOSSA 2024 #jee2024 #josaa #shorts	🚨 FULL SCHEDULE & BROCHURE RELEASED!! | JOSSA 2024 #jee2024 #josaa #shorts	Exciting news—JoSAA 2024 schedule and brochure have finally been released! 🎉 This is your go-to guide for navigating the upcoming counselling process. Make sure you're up-to-date with all the important details and deadlines.\n\nWatch this quick update to stay ahead and ensure you're fully prepared for JoSAA 2024. Don't forget to share this with your friends to keep everyone in the loop. Let's make our dream colleges a reality together! 🎓\n\n#jacdelhi  #CounsellingProcess #JEE2024 #josaa #JoSAA2024 #jac2024 #iitjee #iitbombay #iitdelhi	536	t	f	2024-06-05 00:00:00	61	15-60s	public	\N	\N	video	Mkx7Qp8nCys	f	{}	Mkx7Qp8nCys	{#jee2024,#josaa,#shorts}	{#jacdelhi,#CounsellingProcess,#JEE2024,#josaa,#JoSAA2024,#jac2024,#iitjee,#iitbombay,#iitdelhi}	t	{🚨,🎉,🎓}	t	2024	educational	schedule_announcement	{"style": "text_overlay", "has_face": false, "dominant_color": "#FF0000"}	schedule_reveal	educational	Hinglish	description_only	2026-09-09 14:55:59.402702	2026-09-09 14:55:59.402702
73	Pnh6g6K9y8Q	💯 SPECIAL MOTIVATION before RESULTS of JEE Advanced 2024 #jee2024 #jeeadavanced #shorts	💯 SPECIAL MOTIVATION before RESULTS of JEE Advanced 2024 #jee2024 #jeeadavanced #shorts	Hey future IITians! 🌟 As the JEE Advanced 2024 results are just around the corner, here's a special dose of motivation to keep your spirits high and your mind focused. Watch this short video to get the boost you need right before the big day!\n\n#jee2024 #motivation #jeeadavanced #iit #iitbombay #iitjee #iitdelhi #jeeadvanced2024 #josaa	336	f	f	\N	55	15-60s	public	\N	\N	\N	\N	f	{}	\N	{jee,advanced,jee2024,motivation,special}	{exam,jeeadvanced,results,motivation}	t	{💯}	f	2024	educational	motivation	{}	attention_grab	educational	Hinglish	none	2026-09-10 17:21:45.289572	2026-09-10 17:22:57.565114
26	sHwtsGShqjE	😱THIS IS WHY students CAN'T SOLVE JEE Advanced Questions | JEE 2024 #jee2024 #iit #shorts	😱THIS IS WHY students CAN'T SOLVE JEE Advanced Questions | JEE 2024 #jee2024 #iit #shorts	JEE ADVANCED DAY WISE STARTEGY: https://youtu.be/ZpSpypF1E38?si=qdsw2koELlzGqVRH\n\n#JEE2024#iitbombay #iitdelhi #motivation  #JEEPrep #iitjee #iit #examtips #jeemains #jeeadvanced #iitb #iitd #dtu #shorts\n\n🔔 Attention JEE aspirants! Ever wondered why some students find JEE Advanced questions challenging to solve? In this short video, I'll uncover the most common reasons behind this struggle and provide valuable insights to help you overcome them.\n\nJoin me as we explore factors such as lack of conceptual clarity, inadequate practice, and time management issues that often hinder students' performance in JEE Advanced.\n\nHit play now to gain a deeper understanding of these challenges and discover effective strategies to enhance your problem-solving skills. Don't forget to share this video with your friends who may also benefit from these insights. Let's equip ourselves with the knowledge and skills needed to conquer JEE Advanced! 🚀\n\n#JEE2024#iitbombay #iitdelhi #motivation  #JEEPrep #iitjee #iit #examtips #jeemains #jeeadvanced #iitb #iitd #dtu #shorts	1062	t	t	2024-04-13 00:00:00	37	30-60s	public	\N	\N	video	ZpSpypF1E38	f	{}	ZpSpypF1E38	{#jee2024,#iit}	{JEE2024,iitbombay,iitdelhi,motivation,JEEPrep,iitjee,iit,examtips,jeemains,jeeadvanced,iitb,iitd,dtu,shorts}	f	{😱,🔔,🚀}	t	2024	exam_tips	strategy_analysis	{}	fear_uncertainty	utility	Hinglish	none	2026-09-03 10:11:18.411369	2026-09-03 10:13:56.381636
27	Wyt0zC-zadM	📢 OFFICIAL MOCK PAPERS FOR JEE ADVANCED| JEE 2024 #iit #jee2024 #shorts	📢 OFFICIAL MOCK PAPERS FOR JEE ADVANCED| JEE 2024 #iit #jee2024 #shorts	JEE ADVANCED DAY WISE STARTEGY: https://youtu.be/ZpSpypF1E38?si=qdsw2koELlzGqVRH\n\n#JEE2024#iitbombay #iitdelhi #motivation  #JEEPrep #iitjee #iit #examtips #jeemains #jeeadvanced #iitb #iitd #dtu #shorts\n\nLooking to boost your preparation for JEE Advanced? Discover the power of official mock papers in this short video! I'll be sharing insights on how practicing with official mock papers can significantly enhance your readiness for the big day.\n\nJoin me as we explore the benefits of using official mock papers, including familiarizing yourself with the exam pattern, refining your time management skills, and identifying your strengths and weaknesses.\n\nHit play now to learn how to access and make the most of these valuable resources. Don't forget to share this video with your friends who are also preparing for JEE Advanced. Let's empower each other to excel in our exams! 🌟\n\n#JEE2024#iitbombay #iitdelhi #motivation  #JEEPrep #iitjee #iit #examtips #jeemains #jeeadvanced #iitb #iitd #dtu #shorts	1004	t	t	2024-04-15 00:00:00	60	15-60s	public	\N	\N	video	ZpSpypF1E38	t	{hi}	ZpSpypF1E38	{#iit,#jee2024,#shorts}	{#JEE2024,#iitbombay,#iitdelhi,#motivation,#JEEPrep,#iitjee,#iit,#examtips,#jeemains,#jeeadvanced,#iitb,#iitd,#dtu,#shorts}	t	{📢,🌟}	f	2024	educational	exam_tips	{"face_visible": false, "text_overlay": true, "emoji_prominent": true}	resource_announcement	actionable_resource	Hinglish	end_screen	2026-09-03 12:28:17.67752	2026-09-03 12:28:17.67752
28	JRrvbkvRyiI	🔴 RESULT DATES ANNOUNCED by NTA?? | JEE Mains 2024 #jee2024 #iit #shorts	🔴 RESULT DATES ANNOUNCED by NTA?? | JEE Mains 2024 #jee2024 #iit #shorts	Exciting news alert! In this short video, I'll be sharing the latest update on the result dates announced by NTA for the JEE Mains 2024 exam.\n#JEE2024 #iitbombay #iitdelhi #motivation  #JEEPrep #iitjee #iit #examtips #jeemains #jeemainsresult #jeeadvanced #iitb #iitd #dtu #shorts\n\nJoin me as we uncover when you can expect the results to be released and what this means for your future plans. Whether you're eagerly awaiting your scores or preparing for the next steps in your academic journey, this update is essential.\n\nHit play now to stay informed and ensure you're prepared for what's to come. Don't forget to share this video with your friends who are also waiting for the JEE Mains 2024 results. Let's navigate this journey together and celebrate our achievements! 🌟\n\n#JEE2024 #iitbombay #iitdelhi #motivation  #JEEPrep #iitjee #iit #examtips #jeemains #jeemainsresult #jeeadvanced #iitb #iitd #dtu #shorts	914	t	f	2024-04-18 00:00:00	33	15-60s	public	\N	\N	video	ZpSpypF1E38	t	{hi,en}	ZpSpypF1E38	{#jee2024,#iit,#shorts}	{#JEE2024,#iitbombay,#iitdelhi,#motivation,#JEEPrep,#iitjee,#iit,#examtips,#jeemains,#jeemainsresult,#jeeadvanced,#iitb,#iitd,#dtu,#shorts}	t	{🔴,🌟}	t	2024	educational	exam_tips	{"red_alert": true, "face_visible": false, "text_overlay": true, "emoji_prominent": true}	breaking_news	time_sensitive_info	Hinglish	end_screen	2026-09-03 12:45:38.189925	2026-09-03 12:45:38.189925
29	pTiZBob0vWA	🔴 NEW RESULT UPDATE from RELIABLE SOURCE | JEE Mains 2024 #jee2024 #iit #shorts	🔴 NEW RESULT UPDATE from RELIABLE SOURCE | JEE Mains 2024 #jee2024 #iit #shorts	🔔 Attention all JEE Mains 2024 aspirants! Get ready for some exciting news straight from a reliable source! In this short video, I'll be sharing the latest update on the highly anticipated JEE Mains 2024 results.\n#JEE2024 #iitbombay #iitdelhi #motivation  #JEEPrep #iitjee #iit #examtips #jeemains #jeemainsresult #jeeadvanced #iitb #iitd #dtu #shorts\n\nJoin me as we uncover the details of this update and what it means for you. Whether you're eagerly awaiting your scores or planning your next steps, this reliable source update is a must-watch.\n\nHit play now to stay informed and ensure you're prepared for the outcome. Don't forget to share this video with your friends who are also waiting for the JEE Mains 2024 results. Let's support each other through this journey and celebrate our achievements together! 🚀\n\n#JEE2024 #iitbombay #iitdelhi #motivation  #JEEPrep #iitjee #iit #examtips #jeemains #jeemainsresult #jeeadvanced #iitb #iitd #dtu #shorts	954	t	f	2024-04-19 00:00:00	52	15-60s	public	\N	\N	video	bXetyvX2Mu8	t	{hi,en}	bXetyvX2Mu8	{#jee2024,#iit,#shorts}	{#JEE2024,#iitbombay,#iitdelhi,#motivation,#JEEPrep,#iitjee,#iit,#examtips,#jeemains,#jeemainsresult,#jeeadvanced,#iitb,#iitd,#dtu,#shorts}	t	{🔴,🔔,🚀}	t	2024	educational	exam_tips	{"red_alert": true, "face_visible": false, "text_overlay": true, "emoji_prominent": true}	breaking_news	time_sensitive_info	Hinglish	end_screen	2026-09-03 13:23:31.162254	2026-09-03 13:23:31.162254
30	F6g5hMAUH6A	📢 NTA LATEST UPDATE #shorts #jee2024 #cuet	📢 NTA LATEST UPDATE #shorts #jee2024 #cuet	🔔 Attention all students! It's time for the latest update from NTA! In this short video, I'll be sharing important information that you need to know.\n#JEE2024 #iitbombay #iitdelhi #motivation  #JEEPrep #iitjee #iit #examtips #jeemains #jeemainsresult #jeeadvanced #iitb #iitd #dtu #shorts #cuet #datesheet #update\n\nJoin me as we uncover the details of the latest update from NTA, covering exam dates, result announcements, and any other significant developments that may affect you.\n\nHit play now to stay informed and ensure you're up-to-date with the latest news from NTA. Don't forget to share this video with your friends so they can also stay in the loop. Let's empower each other with knowledge and make informed decisions together! 🚀\n\n#JEE2024 #iitbombay #iitdelhi #motivation  #JEEPrep #iitjee #iit #examtips #jeemains #jeemainsresult #jeeadvanced #iitb #iitd #dtu #shorts #cuet #datesheet #update	904	t	f	2024-04-20 00:00:00	50	15-60s	public	\N	\N	none	\N	t	{hi,en}	\N	{#shorts,#jee2024,#cuet}	{#JEE2024,#iitbombay,#iitdelhi,#motivation,#JEEPrep,#iitjee,#iit,#examtips,#jeemains,#jeemainsresult,#jeeadvanced,#iitb,#iitd,#dtu,#shorts,#cuet,#datesheet,#update}	t	{📢,🔔,🚀}	f	2024	educational	exam_tips	{"face_visible": false, "text_overlay": true, "emoji_prominent": true}	official_announcement	time_sensitive_info	Hinglish	none	2026-09-03 13:36:14.415812	2026-09-03 13:36:14.415812
31	durkT5BI9-0	😱 FINAL ANSWER KEY Out!! | Jee Mains 2024 #jee2024 #iit #shorts	😱 FINAL ANSWER KEY Out!! | Jee Mains 2024 #jee2024 #iit #shorts	🔔 Attention JEE Mains 2024 aspirants! The moment you've been waiting for is here – the final answer key has been released! In this short video, I'll be sharing the exciting news and what it means for you.\n#JEE2024 #iitbombay #iitdelhi #motivation  #JEEPrep #iitjee #iit #examtips #jeemains #jeemainsresult #jeeadvanced #iitb #iitd #dtu #shorts\n\nJoin me as we delve into the details of the final answer key release, which plays a crucial role in assessing your performance and predicting your scores. Whether you're eagerly awaiting your results or planning your next steps, this update is essential.\n\nHit play now to stay informed and ensure you're prepared for the outcome. Don't forget to share this video with your friends who are also waiting for the JEE Mains 2024 results. Let's navigate this journey together and celebrate our achievements! 🚀\n\n#JEE2024 #iitbombay #iitdelhi #motivation  #JEEPrep #iitjee #iit #examtips #jeemains #jeemainsresult #jeeadvanced #iitb #iitd #dtu #shorts	989	t	f	2024-04-21 00:00:00	47	15-60s	public	\N	\N	none	\N	t	{hi,en}	\N	{#jee2024,#iit,#shorts}	{#JEE2024,#iitbombay,#iitdelhi,#motivation,#JEEPrep,#iitjee,#iit,#examtips,#jeemains,#jeemainsresult,#jeeadvanced,#iitb,#iitd,#dtu,#shorts}	t	{😱,🔔,🚀}	t	2024	educational	exam_tips	{"red_alert": true, "face_visible": false, "text_overlay": true, "emoji_prominent": true}	breaking_news	time_sensitive_info	Hinglish	none	2026-09-03 14:13:12.403346	2026-09-03 14:13:12.403346
32	-ntsqYRrjic	🚨DROPPED Questions List of Jee Mains April | JEE 2024 #jee2024 #iit #shorts	🚨DROPPED Questions List of Jee Mains April | JEE 2024 #jee2024 #iit #shorts	🔔 Attention JEE Mains 2024 aspirants! Curious about the list of dropped questions from the exam? In this short video, I'll be sharing the latest update on the questions that have been dropped, along with insights on what this means for you.\n#JEE2024 #iitbombay #iitdelhi #motivation  #JEEPrep #iitjee #iit #examtips #jeemains #jeemainsresult #jeeadvanced #iitb #iitd #dtu #shorts #finalanswerkey #result #jeeresults #jeemainsresult #jeemains2024\n\nJoin me as we explore the list of dropped questions and discuss how it might impact your overall score and preparation strategy. Whether you're looking to gauge the difficulty level of the exam or simply stay informed, this update is essential.\n\nHit play now to stay ahead of the game and ensure you're well-prepared for any changes in the exam pattern. Don't forget to share this video with your friends who are also preparing for JEE Mains 2024. Let's support each other on our journey to success! 🚀\n\n#JEE2024 #iitbombay #iitdelhi #motivation  #JEEPrep #iitjee #iit #examtips #jeemains #jeemainsresult #jeeadvanced #iitb #iitd #dtu #shorts #finalanswerkey #result #jeeresults #jeemainsresult #jeemains2024	1154	t	f	2024-04-21 00:00:00	52	15-60s	public	\N	\N	video	BJ5lJob_sDU	t	{hi,en}	BJ5lJob_sDU	{#jee2024,#iit,#shorts}	{#JEE2024,#iitbombay,#iitdelhi,#motivation,#JEEPrep,#iitjee,#iit,#examtips,#jeemains,#jeemainsresult,#jeeadvanced,#iitb,#iitd,#dtu,#shorts,#finalanswerkey,#result,#jeeresults,#jeemainsresult,#jeemains2024}	t	{🚨,🔔,🚀}	t	2024	educational	exam_tips	{"red_alert": true, "face_visible": false, "text_overlay": true, "emoji_prominent": true}	breaking_news	time_sensitive_info	Hinglish	end_screen	2026-09-03 14:22:21.576395	2026-09-03 14:22:21.576395
33	kQlrFbAzvro	😨DROP QUESTION MARKS?? | How to calculate FINAL MARKS | Jee Mains 2024 #jee2024 #iit #shorts	😨DROP QUESTION MARKS?? | How to calculate FINAL MARKS | Jee Mains 2024 #jee2024 #iit #shorts	🔔 Attention JEE Mains 2024 aspirants! Confused about how to calculate your final marks with dropped questions? Don't worry, I've got you covered! In this short video, I'll walk you through the step-by-step process of calculating your final marks, considering the drop question situation.\n#JEE2024 #iitbombay #iitdelhi #motivation  #JEEPrep #iitjee #iit #examtips #jeemains #jeemainsresult #jeeadvanced #iitb #iitd #dtu #shorts #finalanswerkey #result #jeeresults #jeemainsresult #jeemains2024\n\nJoin me as we demystify the calculation process and ensure you have a clear understanding of how dropped questions may affect your overall score. Whether you're aiming for accuracy or simply want to stay informed, this guide is a must-watch.\n\nHit play now to empower yourself with the knowledge needed to calculate your final marks accurately. Share this video with your friends who may also benefit from this information. Let's navigate the exam process together and achieve our goals! 🚀\n\n#JEE2024 #iitbombay #iitdelhi #motivation  #JEEPrep #iitjee #iit #examtips #jeemains #jeemainsresult #jeeadvanced #iitb #iitd #dtu #shorts #finalanswerkey #result #jeeresults #jeemainsresult #jeemains2024	1188	t	f	2024-04-23 00:00:00	61	15-60s	public	\N	\N	none	\N	t	{hi,en}	\N	{#jee2024,#iit,#shorts}	{#JEE2024,#iitbombay,#iitdelhi,#motivation,#JEEPrep,#iitjee,#iit,#examtips,#jeemains,#jeemainsresult,#jeeadvanced,#iitb,#iitd,#dtu,#shorts,#finalanswerkey,#result,#jeeresults,#jeemainsresult,#jeemains2024}	t	{😨,🔔,🚀}	f	2024	educational	exam_tips	{"face_visible": false, "text_overlay": true, "emoji_prominent": true}	how_to_guide	actionable_info	Hinglish	none	2026-09-03 14:34:36.771304	2026-09-03 14:34:36.771304
35	VkXC2gAxVvs	🚨 RESULT OUT!! JEE Mains 2024 #jee2024 #iit #shorts	🚨 RESULT OUT!! JEE Mains 2024 #jee2024 #iit #shorts	🔔 Exciting news for JEE Mains 2024 aspirants! The moment you've been waiting for has arrived – the results are out! In this short video, I'll guide you on how to check your JEE Mains 2024 scores and what to do next.\n#JEE2024 #iitbombay #iitdelhi #motivation  #JEEPrep #iitjee #iit #examtips #jeemains #jeemainsresult #jeeadvanced #iitb #iitd #dtu #shorts #finalanswerkey #result #jeeresults #jeemainsresult #jeemains2024\n\nJoin me as we celebrate your hard work and dedication that has led to this moment. Whether you're thrilled with your scores or seeking guidance on your next steps, this update is for you.\n\nHit play now to discover your JEE Mains 2024 scores and embark on the next phase of your academic journey. Share this video with your friends who are also waiting for their results. Let's congratulate each other and wish everyone success in their future endeavors! 🎓\n\n#JEE2024 #iitbombay #iitdelhi #motivation  #JEEPrep #iitjee #iit #examtips #jeemains #jeemainsresult #jeeadvanced #iitb #iitd #dtu #shorts #finalanswerkey #result #jeeresults #jeemainsresult #jeemains2024	1083	t	f	2024-04-24 00:00:00	38	15-60s	public	\N	\N	none	\N	t	{hi,en}	\N	{#jee2024,#iit,#shorts}	{#JEE2024,#iitbombay,#iitdelhi,#motivation,#JEEPrep,#iitjee,#iit,#examtips,#jeemains,#jeemainsresult,#jeeadvanced,#iitb,#iitd,#dtu,#shorts,#finalanswerkey,#result,#jeeresults,#jeemainsresult,#jeemains2024}	t	{🚨,🔔,🎓}	t	2024	educational	exam_tips	{"red_alert": true, "face_visible": false, "text_overlay": true, "emoji_prominent": true}	breaking_news	time_sensitive_info	Hinglish	none	2026-09-03 21:29:21.003798	2026-09-03 21:29:21.003798
36	QC45KrzAuLs	🔴MARKS VS PERCENTILE | Jee Mains 2024 | #jee2024 #iit #shorts	🔴MARKS VS PERCENTILE | Jee Mains 2024 | #jee2024 #iit #shorts	🔔 Attention JEE Mains 2024 aspirants! Confused about the relationship between marks and percentile? In this short video, I'll break down the correlation between your exam marks and percentile score to help you better understand your performance.\n#JEE2024 #iitbombay #iitdelhi #motivation  #JEEPrep #iitjee #iit #examtips #jeemains #jeemainsresult #jeeadvanced #iitb #iitd #dtu #shorts #finalanswerkey #result #jeeresults #jeemainsresult #jeemains2024 #marksvspercentile\n\nJoin me as we explore how marks translate into percentiles and what this means for your rank and competitiveness in the exam. Whether you're aiming for a specific percentile or simply want to gauge your performance, this guide is for you.\n\nHit play now to gain clarity on the marks vs percentile dynamics and empower yourself with valuable insights for your JEE Mains 2024 journey. Share this video with your friends who may also benefit from this information. Let's navigate the exam process together and achieve our goals! 🚀\n\n#JEE2024 #iitbombay #iitdelhi #motivation  #JEEPrep #iitjee #iit #examtips #jeemains #jeemainsresult #jeeadvanced #iitb #iitd #dtu #shorts #finalanswerkey #result #jeeresults #jeemainsresult #jeemains2024 #marksvspercentile	1222	t	f	2024-04-24 00:00:00	61	15-60s	public	\N	\N	video	kQlrFbAzvro	t	{hi,en}	kQlrFbAzvro	{#jee2024,#iit,#shorts}	{#JEE2024,#iitbombay,#iitdelhi,#motivation,#JEEPrep,#iitjee,#iit,#examtips,#jeemains,#jeemainsresult,#jeeadvanced,#iitb,#iitd,#dtu,#shorts,#finalanswerkey,#result,#jeeresults,#jeemainsresult,#jeemains2024,#marksvspercentile}	t	{🔴,🔔,🚀}	t	2024	educational	exam_tips	{"red_alert": true, "face_visible": false, "text_overlay": true, "emoji_prominent": true}	how_to_guide	actionable_info	Hinglish	end_screen	2026-09-03 21:44:00.314367	2026-09-03 21:44:00.314367
84	pbU_sJKSfrg	🔴 IPU REGISTRATION UPDATE | DATES EXTENDED?? #IPU #ggsipu #shorts	🔴 IPU REGISTRATION UPDATE | DATES EXTENDED?? #IPU #ggsipu #shorts	This is your reminder to register in IPU COUNSELLING 2024 before it gets closed!!\nLike & SUBSCRIBE for more updates!!\nMore videos on IPU Counselling like preference order and many more are coming soon!!	202	t	f	\N	60	15-60s	public	\N	\N	\N	\N	t	{en,hi}	\N	{#IPU,#ggsipu,#shorts}	{}	t	{🔴}	t	2024	educational	breaking_news	{"style": "text_overlay", "has_face": false, "dominant_color": "#FF0000"}	urgency	result_notification	Hinglish	description_only	2026-09-11 16:20:34.478996	2026-09-11 22:58:06.014146
37	gNgwb1lmKL8	😨ARE YOU ELIGIBLE? for JEE Advanced 2024 #jee2024 #iit #shorts	😨ARE YOU ELIGIBLE? for JEE Advanced 2024 #jee2024 #iit #shorts	🔔 Attention JEE Advanced 2024 aspirants! Are you eligible for JEE Advanced 2024 as per latest announcement by NTA! In this short video, I'll be sharing the latest news on the eligibility criteria given by NTA through JEE Mains 2024 Result and whether you can appear or not?\n#JEE2024 #iitbombay #iitdelhi #motivation  #JEEPrep #iitjee #iit #examtips #jeemains #jeemainsresult #jeeadvanced #iitb #iitd #dtu #shorts #finalanswerkey #result #jeeresults #jeemainsresult #jeemains2024 #jeeadvanced2024 #minimumperentileforjeeadvanced\n\nJoin me as we dive into the details of the changes and discuss how they might impact your exam results. Whether you're eagerly awaiting your scores or planning your next steps, this update is essential.\n\nHit play now to stay informed and ensure you're prepared for any changes in the exam outcome. Don't forget to share this video with your friends who are also JEE advanced aspirant. Let's support each other through this journey and celebrate our achievements together! 🚀\n\n#JEE2024 #iitbombay #iitdelhi #motivation  #JEEPrep #iitjee #iit #examtips #jeemains #jeemainsresult #jeeadvanced #iitb #iitd #dtu #shorts #finalanswerkey #result #jeeresults #jeemainsresult #jeemains2024 #jeeadvanced2024 #minimumperentileforjeeadvanced	1257	t	f	2024-04-25 00:00:00	61	15-60s	public	\N	\N	video	MpQ-K2D9Ao4	t	{hi,en}	MpQ-K2D9Ao4	{#jee2024,#iit,#shorts}	{#JEE2024,#iitbombay,#iitdelhi,#motivation,#JEEPrep,#iitjee,#iit,#examtips,#jeemains,#jeemainsresult,#jeeadvanced,#iitb,#iitd,#dtu,#shorts,#finalanswerkey,#result,#jeeresults,#jeemainsresult,#jeemains2024,#jeeadvanced2024,#minimumperentileforjeeadvanced}	t	{😨,🔔,🚀}	f	2024	educational	exam_tips	{"face_visible": false, "text_overlay": true, "emoji_prominent": true}	eligibility_check	actionable_info	Hinglish	end_screen	2026-09-03 22:06:49.206096	2026-09-03 22:06:49.206096
38	XlOAFuUr7F4	🚨You CAN'T give JEE Advanced 2024 if... #jee2024 #iit #shorts	🚨You CAN'T give JEE Advanced 2024 if... #jee2024 #iit #shorts	🔔 Attention JEE Advanced 2024 aspirants! Do this or you can't give JEE Advanced 2024! In this short video, I'll be sharing the latest news on the registration of  JEE Advanced 2024\n#JEE2024 #iitbombay #iitdelhi #motivation  #JEEPrep #iitjee #iit #examtips #jeemains #jeemainsresult #jeeadvanced #iitb #iitd #dtu #shorts #finalanswerkey #result #jeeresults #jeemainsresult #jeemains2024 #jeeadvanced2024 #minimumperentileforjeeadanced\n\nJoin me as we dive into the details of the changes and discuss how they might impact your exam results. Whether you're eagerly awaiting your scores or planning your next steps, this update is essential.\n\nHit play now to stay informed and ensure you're prepared for any changes in the exam outcome. Don't forget to share this video with your friends who are also JEE advanced aspirant. Let's support each other through this journey and celebrate our achievements together! 🚀\n\n#JEE2024 #iitbombay #iitdelhi #motivation  #JEEPrep #iitjee #iit #examtips #jeemains #jeemainsresult #jeeadvanced #iitb #iitd #dtu #shorts #finalanswerkey #result #jeeresults #jeemainsresult #jeemains2024 #jeeadvanced2024 #minimumperentileforjeeadanced	1162	t	f	2024-04-28 00:00:00	57	15-60s	public	\N	\N	none	\N	t	{hi,en}	\N	{#jee2024,#iit,#shorts}	{#JEE2024,#iitbombay,#iitdelhi,#motivation,#JEEPrep,#iitjee,#iit,#examtips,#jeemains,#jeemainsresult,#jeeadvanced,#iitb,#iitd,#dtu,#shorts,#finalanswerkey,#result,#jeeresults,#jeemainsresult,#jeemains2024,#jeeadvanced2024,#minimumperentileforjeeadanced}	t	{🚨,🔔,🚀}	t	2024	educational	exam_tips	{"red_alert": true, "face_visible": false, "text_overlay": true, "emoji_prominent": true}	disqualification_warning	time_sensitive_info	Hinglish	none	2026-09-03 22:31:30.815574	2026-09-03 22:31:30.815574
39	d-p-YuOjU-8	🔴DOCUMENTS you SHOULD HAVE for JEE Advanced 2024 #jee2024 #iit #shorts	🔴DOCUMENTS you SHOULD HAVE for JEE Advanced 2024 #jee2024 #iit #shorts	🔔 Attention all JEE Advanced 2024 aspirants! Are you prepared with the necessary documents for the upcoming exam? In this short video, I'll guide you through the list of essential documents required for JEE Advanced 2024.\nHit play now to double-check your document checklist and avoid any last-minute hassles. Share this video with your friends who are also preparing for JEE Advanced. Let's ensure everyone is well-prepared and ready to excel in the exam! 🚀\n\nJoin me as we discuss each document you'll need to carry on exam day, including your admit card, valid ID proof, and any additional certificates or forms. Ensuring you have all the required documents is crucial for a smooth exam experience.\n\nHit play now to double-check your document checklist and avoid any last-minute hassles. Share this video with your friends who are also preparing for JEE Advanced. Let's ensure everyone is well-prepared and ready to excel in the exam! 🚀	938	t	f	2024-04-29 00:00:00	61	15-60s	public	\N	\N	video	pszcrf0uTbQ	t	{hi,en}	pszcrf0uTbQ	{#jee2024,#iit,#shorts}	{}	t	{🔴,🔔,🚀}	t	2024	educational	exam_tips	{"red_alert": true, "face_visible": false, "text_overlay": true, "emoji_prominent": true}	checklist	actionable_info	Hinglish	end_screen	2026-09-03 22:47:40.537674	2026-09-03 22:47:40.537674
40	7L-wWpll_GU	😨 FEES (Category Wise) for JEE Advanced 2024 #jee2024 #iit #shorts	😨 FEES (Category Wise) for JEE Advanced 2024 #jee2024 #iit #shorts	🔔 Attention all JEE Advanced 2024 aspirants! Wondering about the category-wise fees for the exam? In this short video, I'll provide you with the essential information on the fees structure based on different categories.\n#JEE2024 #iitbombay #iitdelhi #motivation  #JEEPrep #iitjee #iit #examtips #jeemains #jeemainsresult #jeeadvanced #iitb #iitd #dtu #shorts #result #jeeresults #jeeadvanced2024\n\nJoin me as we explore the fees details for various categories, including General, OBC-NCL, SC, ST, and PwD candidates. Understanding the category-wise fees is crucial for completing your registration process accurately and on time.\n\nHit play now to ensure you're aware of the fees applicable to your category and are ready to proceed with the registration process smoothly. Share this video with your friends who are also preparing for JEE Advanced. Let's empower each other with the knowledge needed to excel in the exam! 🚀\n\n#JEE2024 #iitbombay #iitdelhi #motivation  #JEEPrep #iitjee #iit #examtips #jeemains #jeemainsresult #jeeadvanced #iitb #iitd #dtu #shorts #result #jeeresults #jeeadvanced2024	1098	t	f	2024-04-30 00:00:00	57	15-60s	public	\N	\N	video	d-p-YuOjU-8	t	{hi,en}	d-p-YuOjU-8	{#jee2024,#iit,#shorts}	{#JEE2024,#iitbombay,#iitdelhi,#motivation,#JEEPrep,#iitjee,#iit,#examtips,#jeemains,#jeemainsresult,#jeeadvanced,#iitb,#iitd,#dtu,#shorts,#result,#jeeresults,#jeeadvanced2024}	t	{😨,🔔,🚀}	f	2024	educational	exam_tips	{"face_visible": false, "text_overlay": true, "emoji_prominent": true}	fees_info	actionable_info	Hinglish	end_screen	2026-09-03 22:59:23.098487	2026-09-03 22:59:23.098487
77	_6qJfWvvWJo	🚨RE-NEET CONFIRMED!! Supreme Court Decision #neet #reneet #shorts	🚨RE-NEET CONFIRMED!! Supreme Court Decision #neet #reneet #shorts	Hey NEET aspirants! 🌟 The Supreme Court has confirmed the re-examination for NEET 2024! This major update can impact your preparation and plans. Watch this short video to get all the crucial details and understand what you need to do next. Stay informed and be ready! 💪\n\nDon't forget to LIKE, SHARE, and SUBSCRIBE for the latest updates! 🔔\n\n#reneet #neetscam #neet #neet2024 #neetreexam #neetresult #nta #neetug#aiims	417	f	f	\N	61	15-60s	public	\N	\N	\N	\N	f	{}	\N	{neeet,"supreme court","neet 2024",reexam}	{exam,reexamination,"supreme court",neet}	t	{🚨}	f	2024	educational	exam_tips	{}	attention_grab	educational	Hinglish	none	2026-09-10 19:56:28.467634	2026-09-10 20:01:40.055997
41	pszcrf0uTbQ	😱DON'T have CATEGORY CERTIFICATE?? How to Apply for JEE Advanced 2024? #jee2024 #iit #shorts	😱DON'T have CATEGORY CERTIFICATE?? How to Apply for JEE Advanced 2024? #jee2024 #iit #shorts	If this video helps you do Like & Subscribe!! 😊\nLinks: \n\nDocuments Required List: https://youtube.com/shorts/7L-wWpll_GU?si=oiL4UU7_HChMmhNV \n\nOBC NCL Declaration Form: https://jeeadv.ac.in/forms/DECLARATION_BY_THE_CANDIDATE_IN_LIEU_OF_OBC-NCL_CERTIFICATE.pdf \n\nEWS Declaration Form: https://jeeadv.ac.in/forms/DECLARATION_BY_THE_CANDIDATE_IN_LIEU_OF_GEN-EWS_CERTIFICATE.pdf \n\nSC/ST Declaration Form: https://jeeadv.ac.in/forms/DECLARATION_BY_THE_CANDIDATE_IN_LIEU_OF_SC_ST_CERTIFICATE.pdf\n\n🔔 Attention JEE Advanced 2024 aspirants! Don't have a category certificate yet? No worries! In this short video, I'll guide you through the process of registering for the exam even if you don't have a category certificate.\n\nJoin me as we explore alternative options and solutions for completing your registration without the required certificate. From temporary certificates to affidavit submissions, I'll share practical steps to ensure you can proceed with your JEE Advanced registration smoothly.\n\nHit play now to learn how to navigate the registration process without a category certificate and ensure you don't miss out on this opportunity. Share this video with your friends who may also benefit from this information. Let's empower each other to overcome any obstacles in our JEE journey! 🚀\n\n#JEE2024 #iitbombay #iitdelhi #motivation  #JEEPrep #iitjee #iit #examtips #jeemains #jeemainsresult #jeeadvanced #iitb #iitd #dtu #shorts #finalanswerkey #result #jeeresults #jeemainsresult #jeemains2024 #jeeadvanced2024	1511	t	t	2024-05-03 00:00:00	60	15-60s	public	\N	\N	video	EDNdXwv7W64	t	{hi,en}	EDNdXwv7W64	{#jee2024,#iit,#shorts}	{#JEE2024,#iitbombay,#iitdelhi,#motivation,#JEEPrep,#iitjee,#iit,#examtips,#jeemains,#jeemainsresult,#jeeadvanced,#iitb,#iitd,#dtu,#shorts,#finalanswerkey,#result,#jeeresults,#jeemainsresult,#jeemains2024,#jeeadvanced2024}	t	{😱,😊,🚀}	f	2024	educational	exam_tips	{"face_visible": false, "text_overlay": true, "emoji_prominent": true}	category_certificate_solution	actionable_info	Hinglish	end_screen	2026-09-03 23:21:10.33918	2026-09-04 09:31:55.178282
42	EDNdXwv7W64	😨MISTAKE in JEE Advanced Registration? Do this... | Jee 2024 #jee2024 #iit #shorts	😨MISTAKE in JEE Advanced Registration? Do this... | Jee 2024 #jee2024 #iit #shorts	🔔 Attention JEE Advanced aspirants! Made a mistake during registration or uploaded the wrong document? Don't panic! In this short video, I'll walk you through the steps to rectify the error and ensure your registration process goes smoothly.\n\nJoin me as we discuss common mistakes during registration and how to correct them. Whether it's an error in personal details or uploading the wrong document, I'll provide practical solutions to help you resolve the issue.\n\nHit play now to learn how to fix mistakes in your JEE Advanced registration and avoid any last-minute complications. Share this video with your friends who may also find this information helpful. Let's ensure everyone is well-prepared and ready to excel in the exam! 🚀\n\n#JEE2024 #iitbombay #iitdelhi #motivation  #JEEPrep #iitjee #iit #examtips #jeemains #jeemainsresult #jeeadvanced #iitb #iitd #dtu #shorts #finalanswerkey #result #jeeresults #jeemainsresult #jeemains2024 #jeeadvanced2024	957	t	f	2024-05-06 00:00:00	61	15-60s	public	\N	\N	video	pszcrf0uTbQ	t	{hi,en}	pszcrf0uTbQ	{#jee2024,#iit,#shorts}	{#JEE2024,#iitbombay,#iitdelhi,#motivation,#JEEPrep,#iitjee,#iit,#examtips,#jeemains,#jeemainsresult,#jeeadvanced,#iitb,#iitd,#dtu,#shorts,#finalanswerkey,#result,#jeeresults,#jeemainsresult,#jeemains2024,#jeeadvanced2024}	t	{😨,🚀}	f	2024	educational	exam_tips	{"face_visible": false, "text_overlay": true, "emoji_prominent": true}	registration_mistake_solution	actionable_info	Hinglish	end_screen	2026-09-04 09:55:24.289926	2026-09-04 09:55:24.289926
43	DdMa3y_sImk	🚨LAST CHANCE for JEE Advanced 2024!! HURRY UP #jee2024 #iit #shorts	🚨LAST CHANCE for JEE Advanced 2024!! HURRY UP #jee2024 #iit #shorts	🔔 Attention JEE Advanced 2024 aspirants! The clock is ticking, and this might be your last chance to seize the opportunity! In this short video, I'll share important insights and motivation to help you make the most out of this final opportunity.\n\nJoin me as we discuss the significance of this moment and the importance of giving it your all. Whether you've faced challenges along the way or are aiming for improvement, now is the time to give it your best shot.\n\nHit play now to get inspired and motivated to give your absolute best in JEE Advanced 2024. Share this video with your friends who may also be on their final chance journey. Let's support each other and make this last chance count! 🚀\n\n#JEE2024 #iitbombay #iitdelhi #motivation  #JEEPrep #iitjee #iit #examtips #jeemains #jeemainsresult #jeeadvanced #iitb #iitd #dtu #shorts #finalanswerkey #result #jeeresults #jeemainsresult #jeemains2024 #jeeadvanced2024	921	t	f	2024-05-07 00:00:00	60	15-60s	public	\N	\N	video	pszcrf0uTbQ	t	{hi,en}	pszcrf0uTbQ	{#jee2024,#iit,#shorts}	{#JEE2024,#iitbombay,#iitdelhi,#motivation,#JEEPrep,#iitjee,#iit,#examtips,#jeemains,#jeemainsresult,#jeeadvanced,#iitb,#iitd,#dtu,#shorts,#finalanswerkey,#result,#jeeresults,#jeemainsresult,#jeemains2024,#jeeadvanced2024}	t	{🚨,🚀}	t	2024	educational	exam_tips	{"face_visible": false, "text_overlay": true, "emoji_prominent": true}	last_chance_urgency	motivation	Hinglish	end_screen	2026-09-04 12:02:37.004788	2026-09-04 12:02:37.004788
44	YFnY2guPlxg	🔴CBSE Result & CUET update!! #cbse #cuet #shorts	🔴CBSE Result & CUET update!! #cbse #cuet #shorts	🔔 Attention CBSE & CUET aspirants! The results are finally here! In this short video, I'll share the latest updates on CBSE Class 10 & 12 results and CUET 2024. Whether you're waiting for your board results or preparing for CUET, this video has all the crucial information you need right now. Join me as we break down the result dates, how to check your scores, and what this means for your CUET preparation. Hit play now to stay updated and ahead of the curve! Share this with your friends who are also waiting for results. Let's navigate this together! 🚀\n\n#CBSE #CUET #CBSEResult #CUET2024 #Class12Result #Class10Result #Shorts	629	t	f	2024-05-10 00:00:00	39	15-60s	public	\N	\N	video	DdMa3y_sImk	t	{hi,en}	DdMa3y_sImk	{#cbse,#cuet,#shorts}	{#CBSE,#CUET,#CBSEResult,#CUET2024,#Class12Result,#Class10Result,#Shorts}	t	{🔴,🚀}	t	2024	educational	exam_tips	{"face_visible": false, "text_overlay": true, "emoji_prominent": true}	result_announcement	breaking_news	Hinglish	end_screen	2026-09-04 12:04:52.149361	2026-09-04 12:04:52.149361
45	noF6FnkgYmE	🚨 JAC Delhi Dates Announced!! | Jee 2024 #jee2024 #iit #shorts	🚨 JAC Delhi Dates Announced!! | Jee 2024 #jee2024 #iit #shorts	🔔 Attention students interested in admissions through JAC Delhi! Exciting news awaits! In this short video, I'll be sharing the latest update from the Joint Admission Counselling (JAC) Delhi.\n\nJoin me as we uncover the important information and updates regarding JAC Delhi admissions. Whether you're considering engineering, architecture, or other courses offered through JAC, this update is essential for your planning.\n\nHit play now to stay ahead of the curve and ensure you're well-informed about the latest developments from JAC Delhi. Don't forget to share this video with your friends who may also be interested in JAC admissions. Let's empower each other with knowledge and make informed decisions about our academic future! 🚀\n\n#JEE2024 #iitbombay #iitdelhi #motivation  #iitjee #iit #jeemains #jeeadvanced #dtu #nsut #iiitd #dseu #igdtuw #shorts #resul #jeemains2024 #jeeadvanced2024 #jacdelhi #josaacounseling	918	t	f	2024-05-11 00:00:00	52	15-60s	public	\N	\N	video	3gSWKoBeqnw	t	{hi,en}	3gSWKoBeqnw	{#jee2024,#iit,#shorts}	{#JEE2024,#iitbombay,#iitdelhi,#motivation,#iitjee,#iit,#jeemains,#jeeadvanced,#dtu,#nsut,#iiitd,#dseu,#igdtuw,#shorts,#resul,#jeemains2024,#jeeadvanced2024,#jacdelhi,#josaacounseling}	t	{🚨,🚀}	t	2024	educational	exam_tips	{"face_visible": false, "text_overlay": true, "emoji_prominent": true}	date_announcement	breaking_news	Hinglish	end_screen	2026-09-04 12:16:10.255319	2026-09-04 12:16:10.255319
60	p03EyeJlM-k	Clearing Your JAC/JOSAA Counseling Doubts in 60 Seconds! 📚✨ #jee2024 #jacdelhi #josaa #shorts	Clearing Your JAC/JOSAA Counseling Doubts in 60 Seconds! #jee2024 #jacdelhi #josaa #shorts	Got questions about JAC/JoSAA counseling? This Short clears every doubt in 60 seconds! 🎓✨\n\nWatch now to understand the complete JAC Delhi and JoSAA counseling process step by step. Don't miss the important dates, choice filling tips, and seat allocation rules.\n\n🔔 Subscribe for more JEE 2024 updates!\n👍 Like if this helped!\n📤 Share with fellow aspirants!\n\n#JEE2024 #JACDelhi #JoSAA #Counseling #Engineering #Shorts #Education #CareerGuidance #CollegeAdmission #IIT #NIT #IIIT #JEEAdvanced #JEEMain #SeatAllocation #ChoiceFilling #MockCounseling #Round1 #Round2 #Round3 #SpotRound #Float #Freeze #Slide #SeatUpgrade #DocumentVerification #ReportingCenter #AdmissionProcess #BTech #EngineeringColleges #TopRankers #Aspirants #Motivation #Success #DreamCollege #FutureEngineers 🚀	776	t	f	2024-05-21 00:00:00	60	15-60s	public	\N	\N	video	\N	f	{none,hi}	JAC_DELHI_Counselling_Complete_Process	{#jee2024,#jacdelhi,#josaa,#shorts}	{#JEE2024,#JACDelhi,#JoSAA,#Counseling,#Engineering,#Shorts,#Education,#CareerGuidance,#CollegeAdmission,#IIT,#NIT,#IIIT,#JEEAdvanced,#JEEMain,#SeatAllocation,#ChoiceFilling,#MockCounseling,#Round1,#Round2,#Round3,#SpotRound,#Float,#Freeze,#Slide,#SeatUpgrade,#DocumentVerification,#ReportingCenter,#AdmissionProcess,#BTech,#EngineeringColleges,#TopRankers,#Aspirants,#Motivation,#Success,#DreamCollege,#FutureEngineers}	t	{📚,✨}	f	2024	educational	counseling_guide	{"style": "text_overlay", "has_face": false, "dominant_color": "#000000"}	direct_answer	educational	Hinglish	description_only	2026-09-06 12:19:14.187832	2026-09-06 12:19:14.187832
78	NVbNJeWZ1Lo	🤨Seat allotment at 25 June?? MUST WATCH if you have CW/KM/IIITD bonus #jee2024 #jacdelhi #shorts	🤨Seat allotment at 25 June?? MUST WATCH if you have CW/KM/IIITD bonus #jee2024 #jacdelhi #shorts	Is seat allotment of JAC re scheduled to 25 June?\nMUST Watch this if you belong to CW/KM category or have IIIT D Bonus points\n\nThis might be your doubt as well!!	161	f	f	\N	61	15-60s	public	\N	\N	\N	\N	f	{}	\N	{jee,"seat allotment",CW,KM,IIITD,bonus,jee2024,jacdelhi,shorts}	{"seat allotment","JAC re scheduled","CW category","KM category","IIITD bonus"}	t	{🤨}	f	2024	educational	exam_tips	{}	attention_grab	educational	Hinglish	none	2026-09-10 20:21:07.431547	2026-09-10 20:21:07.431547
68	YaAKtkecoRc	😱RESULTS OUT!! NEET UG 2024 #neet #neet2024 #shorts	😱RESULTS OUT!! NEET UG 2024 #neet #neet2024 #shorts	So, finally neet UG 2024 results are out!!\nHere is how you can access it \n\nLike the video if it helps you!\nSubscribe the channel for interesting things\nShare this as much as you can\n\nLet me know in comment section, how you performed in your exam	245	t	f	2024-06-04 10:30:00	40	15-60s	public	\N	\N	video	D4KiNRb7UTk	t	{en,hi}	D4KiNRb7UTk	{#neet,#neet2024,#neetug2024}	{#neet,#neet2024,#neetug2024}	t	{😱}	t	2024	educational	result_alert	{"style": "text_overlay", "has_face": false, "dominant_color": "#FF0000"}	urgency	result_notification	Hinglish	description_only	2026-09-08 10:48:39.159712	2026-09-08 11:27:20.802552
74	DNIHqPqY3VM	🔴 RESULTS Out!! Jee Advanced 2024 #jeeadavanced #jee2024 #shorts	🔴 RESULTS Out!! Jee Advanced 2024 #jeeadavanced #jee2024 #shorts	jee advanced result is out!!	28	f	f	\N	27	15-60s	public	\N	\N	\N	\N	f	{}	\N	{jee,advanced,jee2024,results}	{exam,results}	t	{🔴}	f	2024	educational	exam_tips	{}	attention_grab	educational	Hinglish	none	2026-09-10 18:30:27.604051	2026-09-10 18:32:28.286194
61	229XDzxoc4g	😱 This 1 mistake = JEE Advanced Barbaad ❌ #jee2024 #iitjee #shorts	This 1 mistake = JEE Advanced Barbaad #jee2024 #iitjee #shorts	Hey JEE Advanced warriors! ⚔️ One simple mistake can derail all your hard work. Watch this 60-second video to discover what it is and how to dodge it like a pro. Your success depends on it!\n\nHit play and stay ahead of the game. Share this crucial tip with your friends to help them succeed too. Let’s ace this together! 🎯\n\n#jee2024 #jeeadvanced #jeeadvanced2024 #iit #iitjee	374	t	f	2024-05-25 00:00:00	61	15-60s	public	\N	\N	video	\N	f	{none}	\N	{#jee2024,#iitjee,#shorts}	{#jee2024,#jeeadvanced,#jeeadvanced2024,#iit,#iitjee}	t	{😱,❌}	t	2024	educational	exam_tips	{"style": "text_overlay", "has_face": false, "dominant_color": "#000000"}	urgency	educational	Hinglish	description_only	2026-09-06 13:26:52.660817	2026-09-06 13:26:52.660817
51	kIrFARfeW5o	🚨 CUET EXAMS POSTPONED!! New Dates?? | CUET 2024 #cuet #cuetpostponed #shorts	🚨 CUET EXAMS POSTPONED!! New Dates?? | CUET 2024 #cuet #cuetpostponed #shorts	🔔 Attention CUET 2024 aspirants! Breaking news - CUET exams have been postponed! In this short video, I'll share the latest official update on the new exam dates and what this means for your preparation.\n\nJoin me as we break down the official announcement, expected new dates, and how to adjust your study plan accordingly. Whether you're relieved or stressed, this update is crucial for every CUET aspirant.\n\nHit play now to get the latest information and stay ahead in your preparation. Share this video with your friends who are also preparing for CUET 2024. Let's support each other through this uncertainty! 🚀\n\n#CUET #CUET2024 #CUETPostponed #CUETNewDates #CUETExam #CUETPreparation #Shorts	695	t	f	2024-05-14 00:00:00	50	15-60s	public	\N	\N	video	impBBFcUinY	t	{hi,en}	impBBFcUinY	{#cuet,#cuetpostponed,#shorts}	{#CUET,#CUET2024,#CUETPostponed,#CUETNewDates,#CUETExam,#CUETPreparation,#Shorts}	t	{🚨,🚀}	t	2024	educational	exam_tips	{"face_visible": false, "text_overlay": true, "emoji_prominent": true}	exam_postponement_breaking_news	breaking_news	Hinglish	end_screen	2026-09-04 13:45:31.604043	2026-09-04 15:04:06.343661
50	impBBFcUinY	🔴YOU CAN STILL increase your class 10/12 marks!! #cbse #class12 #class10 #shorts	🔴YOU CAN STILL increase your class 10/12 marks!! #cbse #class12 #class10 #shorts	🔔 Attention CBSE Class 10 & 12 students! Did you know you can still improve your marks even after results? In this short video, I'll share how you can apply for verification, re-evaluation, and compartment exams to boost your CBSE scores.\n\nJoin me as we explore the official CBSE processes for mark improvement - from photocopy of answer sheets to re-evaluation and compartment exams. Whether you're disappointed with your results or just want to push for higher marks, there are official pathways available.\n\nHit play now to learn how to increase your Class 10/12 marks through CBSE's official improvement processes. Share this video with your friends who may also benefit from this information. Let's help each other achieve our best possible scores! 🚀\n\n#cbse #class12 #class10 #cbse2024 #cbseimprovement #cbserevaluation #cbsecompartment #shorts	848	t	f	2024-05-14 00:00:00	57	15-60s	public	\N	\N	video	3gSWKoBeqnw	t	{hi,en}	3gSWKoBeqnw	{#cbse,#class12,#class10,#shorts}	{#cbse,#class12,#class10,#cbse2024,#cbseimprovement,#cbserevaluation,#cbsecompartment,#shorts}	t	{🔴,🚀}	t	2024	educational	exam_tips	{"face_visible": false, "text_overlay": true, "emoji_prominent": true}	marks_improvement_solution	actionable_info	Hinglish	end_screen	2026-09-04 13:33:07.646614	2026-09-04 15:04:06.343661
49	3gSWKoBeqnw	🚨 CUET ADMIT CARD/Hall Ticket Released??	🚨 CUET ADMIT CARD/Hall Ticket Released??	🔔 Attention CUET aspirants! The admit card/hall ticket is finally here! In this short video, I'll share the latest update on the CUET 2024 admit card release. Whether you're waiting for your hall ticket or want to know the download process, this video has all the crucial information you need right now. Join me as we break down the release details, how to download your admit card, and what to check before exam day. Hit play now to stay updated and ahead of the curve! Share this with your friends who are also waiting for their CUET hall tickets. Let's navigate this together! 🚀\n\n#CUET #CUET2024 #CUETAdmitCard #HallTicket #CUETResult #CUETExam #Shorts	655	t	f	2024-05-13 00:00:00	56	15-60s	public	\N	\N	video	UzWyYR6WM6U	t	{hi,en}	UzWyYR6WM6U	{}	{#CUET,#CUET2024,#CUETAdmitCard,#HallTicket,#CUETResult,#CUETExam,#Shorts}	t	{🚨,🚀}	t	2024	educational	exam_tips	{"face_visible": false, "text_overlay": true, "emoji_prominent": true}	admit_card_announcement	breaking_news	Hinglish	end_screen	2026-09-04 13:19:16.949153	2026-09-04 15:04:06.343661
48	UzWyYR6WM6U	😱 CLASS 10 CBSE RESULTS OUT?? #cbse #class10 #shorts	😱 CLASS 10 CBSE RESULTS OUT?? #cbse #class10 #shorts	🔔 Attention all CBSE Class 10 students! The moment you've been waiting for has arrived – the Class 10 results are out! In this short video, let's come together to celebrate the academic achievements of our fellow classmates and friends.\n\nJoin us as we share in the excitement and joy of this milestone moment. Whether it's scoring top marks, achieving personal bests, or overcoming challenges, each student's journey is worth celebrating.\n\nHit play now to discover the Class 10 results and join us in congratulating all the students who have worked hard to reach this point. Share this video with your friends and classmates to spread the celebration and show support for each other's achievements! 🎉\n\n#cbse #cbse2024 #cbseresulttoday #cbseresultclass10 #cbseclass12 #cbseboard #cbseclass10 #cbseresult #cbseresult2024 #cbseupdates #class10result #class12result	861	t	f	2024-05-13 00:00:00	43	15-60s	public	\N	\N	video	tyxuLrd-xo4	t	{hi,en}	tyxuLrd-xo4	{#cbse,#class10,#shorts}	{#cbse,#cbse2024,#cbseresulttoday,#cbseresultclass10,#cbseclass12,#cbseboard,#cbseclass10,#cbseresult,#cbseresult2024,#cbseupdates,#class10result,#class12result}	t	{😱,🎉}	t	2024	educational	exam_tips	{"face_visible": false, "text_overlay": true, "emoji_prominent": true}	result_announcement	breaking_news	Hinglish	end_screen	2026-09-04 12:56:32.962168	2026-09-04 15:04:06.343661
47	tyxuLrd-xo4	🔴 CBSE Class 12 RESULTS OUT 🎉 #cbse #class12 #shorts	🔴 CBSE Class 12 RESULTS OUT 🎉 #cbse #class12 #shorts	🔔 Attention all CBSE Class 12 students! The moment you've been waiting for has arrived – the Class 12 results are out! In this short video, let's come together to celebrate the academic achievements of our fellow classmates and friends.\n\nJoin us as we share in the excitement and joy of this milestone moment. Whether it's scoring top marks, achieving personal bests, or overcoming challenges, each student's journey is worth celebrating.\n\nHit play now to discover the Class 12 results and join us in congratulating all the students who have worked hard to reach this point. Share this video with your friends and classmates to spread the celebration and show support for each other's achievements! 🎉\n\n#cbse #cbse2024 #cbseresulttoday #cbseresultclass12 #cbseclass10 #cbseboard #cbseclass12 #cbseresult #cbseresult2024 #cbseupdates #class10result #class12result	861	t	f	2024-05-12 00:00:00	50	15-60s	public	\N	\N	video	sHwtsGShqjE	t	{hi,en}	sHwtsGShqjE	{#cbse,#class12,#shorts}	{#cbse,#cbse2024,#cbseresulttoday,#cbseresultclass12,#cbseclass10,#cbseboard,#cbseclass12,#cbseresult,#cbseresult2024,#cbseupdates,#class10result,#class12result}	t	{🔴,🎉}	t	2024	educational	exam_tips	{"face_visible": false, "text_overlay": true, "emoji_prominent": true}	result_celebration	celebration	Hinglish	end_screen	2026-09-04 12:33:43.388322	2026-09-04 15:04:06.343661
62	j4CtPMW-1Q4	😀 MUST WATCH before paper 2 | 1 min talk with Jee Advanced 2024 aspirant #jee2024 #iitjee #shorts	 MUST WATCH before paper 2 | 1 min talk with Jee Advanced 2024 aspirant #jee2024 #iitjee #shorts	Hey JEE Advanced 2024 warriors! 🌟 Ready for Paper 2? Don’t miss this essential video packed with last-minute tips and strategies to boost your performance. Watch now to get the edge you need!\n\nHit play and make sure you're fully prepared. Share with your fellow aspirants to help them succeed too. Let’s conquer Paper 2 together! 🚀\n\n#jee2024 #jeeadvanced #jeeadvanced2024 #iit #iitjee	384	t	f	2024-05-25 00:00:00	48	15-60s	public	\N	\N	video	\N	t	{none,hi}	\N	{#jee2024,#iitjee,#shorts}	{#jee2024,#jeeadvanced,#jeeadvanced2024,#iit,#iitjee}	t	{😀}	f	2024	educational	exam_tips	{"style": "text_overlay", "has_face": false, "dominant_color": "#000000"}	urgency	educational	Hinglish	description_only	2026-09-06 13:43:57.675416	2026-09-06 13:43:57.675416
46	FwuhJ23l7R4	Last Class of 1st year 🥲 | DTU #dtu #jee2024 #shorts	Last Class of 1st year 🥲 | DTU #dtu #jee2024 #shorts		0	f	f	2024-05-11 00:00:00	16	0-15s	public	\N	\N	video	tyxuLrd-xo4	f	{}	tyxuLrd-xo4	{#dtu,#jee2024,#shorts}	{}	t	{🥲}	f	2024	lifestyle	campus_life	{"face_visible": false, "text_overlay": false, "emoji_prominent": true}	personal_milestone	relatable_content	Hinglish	end_screen	2026-09-04 15:17:53.707086	2026-09-04 15:17:53.707086
79	wnp9gFm7ZpY	FREE LIVE JOSAA COUNSELLING SUPPORT | JOIN LIVE #jee2024 #josaa #shorts	FREE LIVE JOSAA COUNSELLING SUPPORT | JOIN LIVE #jee2024 #josaa #shorts	We are going live for FREE JOSAA Counselling Support!!\nJoin it to know best choices for you!!\nLIVE Details:\nDate: 17/06/2024\nTime: 7:20 PM\nThumbnail\nSet a thumbnail that stands out and draws viewers' attention. Learn more\nGet suggestions\nPlaylists\nAdd your video to one or more playlists to organize your content for viewers. Learn more\nSelect\nAudience\nThis video is set to not made for kids \nSet by you\nRegardless of your location, you're legally required to comply with the Children's Online Privacy Protection Act (COPPA) and/or other laws. You're required to tell us whether your videos are made for kids. What's content made for kids?\nFeatures like personalized ads and notifications won’t be available on videos made for kids. Videos that are set as made for kids by you are more likely to be recommended alongside other kids’ videos. Learn more\nYes, it's made for kids\n.\nFeatures like personalized ads and notifications won’t be available on videos made for kids. Videos that are set as made for kids by you are more likely to be recommended alongside other kids’ videos. Learn more\nNo, it's not made for kids\nAge restriction\nShow more\nPaid promotion, collaboration, and more\nVideo link	131	t	f	2024-06-17 00:00:00	34	15-60s	public	\N	\N	\N	\N	f	{}	\N	{jee,advanced,josaa,counselling,live}	{exam,jeeadvanced,counselling,live,support}	t	{🆓,📚}	f	2024	educational	counselling	{}	urgency_grab	informational	Hinglish	none	2026-09-10 22:48:19.000993	2026-09-12 21:46:22.459929
66	LQ7ttolwjJQ	😨JEE ADV LATEST UPDATE | DOWNLOAD THIS IMMEDIATELY #jee2024 #jeeadvanced #shorts	😨JEE ADV LATEST UPDATE | DOWNLOAD THIS IMMEDIATELY #jee2024 #jeeadvanced #shorts	We've got the latest update that you can't afford to miss. Tune in for the newest information and make sure you're fully prepared for the exam.\n\nWatch now and stay ahead of the game. Share this update with your fellow aspirants to keep everyone informed. Let's ace this together! 🚀\n\n#jee2024 #jeeadvanced #jeeadvanced2024 #iit #iitjee #josaa #josaa2024	213	f	f	\N	0	15-60s	public	\N	\N	\N	\N	f	{}	\N	{}	{}	f	{}	f	2024	educational	exam_tips	{}	\N	\N	Hinglish	none	2026-09-06 16:17:20.488172	2026-09-07 10:50:43.305672
52	tO8vEcWUFXs	⚠️ DOWNLOAD IMMEDIATELY your NEW ADMIT CARD/ Hall Ticket for CUET 2024 #cuet #cuet2024 #shorts	DOWNLOAD IMMEDIATELY your NEW ADMIT CARD/ Hall Ticket for CUET 2024 #cuet #cuet2024 #shorts	⛒️ Attention all CUET 2024 aspirants! Exciting news awaits – a new admit card has been released for the upcoming exam. In this short video, we'll provide you with all the essential information about the new admit card and what steps you need to take.\n\nJoin us as we discuss how to access and download your new admit card, along with any important instructions or changes you need to be aware of. Whether it's verifying your exam center or double-checking your personal details, we've got you covered.\n\nHit play now to ensure you're well-prepared with your new admit card for CUET 2024. Don't forget to share this video with your friends who may also be appearing for the exam. Let's stay organized and ready to excel in CUET 2024! ⛒️\n\n#cuet #AdmitCard #Shorts #CUET2024 #CUETAdmitCard #cuet2024 #cuetpostponed #nta #cuetupdate #cuetlatestupdatetoday #cuetnews	859	t	f	2024-05-16 00:00:00	42	15-60s	public	\N	\N	none	\N	t	{none,hi}	\N	{#cuet,#cuet2024,#shorts}	{#cuet,#AdmitCard,#Shorts,#CUET2024,#CUETAdmitCard,#cuet2024,#cuetpostponed,#nta,#cuetupdate,#cuetlatestupdatetoday,#cuetnews}	t	{⚠️}	t	2024	result_update	admit_card_release	{"style": "text_overlay", "has_face": false, "dominant_color": "#000000"}	urgency	result_update	Hinglish	description_only	2026-09-05 19:35:09.745882	2026-09-05 19:35:09.745882
92	0KAZqj8-gFo	🔴 IPU Counselling Schedule changed!! Dates extended!! #ipu #ggsipu #shorts	🔴 IPU Counselling Schedule changed!! Dates extended!! #ipu #ggsipu #shorts	IPU Counselling dates got extended\nNow you have more time to pay your PAF\nLike, Subscribe and share for all such important updates!!\nThumbnail\nSet a thumbnail that stands out and draws viewers' attention. Learn more\nGet suggestions\nPlaylists\nAdd your video to one or more playlists to organize your content for viewers. Learn more\nSelect\nAudience\nThis video is set to not made for kids \nSet by you\nRegardless of your location, you're legally required to comply with the Children's Online Privacy Protection Act (COPPA) and/or other laws. You're required to tell us whether your videos are made for kids. What's content made for kids?\nFeatures like personalized ads and notifications won’t be available on videos made for kids. Videos that are set as made for kids by you are more likely to be recommended alongside other kids’ videos. Learn more\nYes, it's made for kids\n.\nFeatures like personalized ads and notifications won’t be available on videos made for kids. Videos that are set as made for kids by you are more likely to be recommended alongside other kids’ videos. Learn more\nNo, it's not made for kids\nAge restriction\nShow more\nPaid promotion, collaboration, and more\nVideo link	1199	t	f	\N	60	15-60s	public	\N	\N	\N	\N	t	{en,hi}	\N	{#ipu,#ggsipu,#shorts}	{}	t	{🔴}	t	2024	educational	counselling	{"style": "text_overlay", "has_face": false, "dominant_color": "#FF0000"}	urgency	actionable_info	Hinglish	description_only	2026-09-11 16:35:55.987093	2026-09-11 22:58:08.519442
70	D4KiNRb7UTk	NTA REPLY on Neet 2024 Results!! #neet2024 #neet	NTA REPLY on Neet 2024 Results!! #neet2024 #neet	The NTA has finally responded about the NEET 2024 results, and you need to know what they said! This short video breaks down their reply and what it means for you.	163	f	f	2024-05-23 00:00:00	75	15-60s	public	\N	\N	none	\N	f	{}	\N	{neet,neet2024,nta,neetresult,neetug}	{neet2024,ntaresult,neetreexam,aiims}	f	{}	f	2024	educational	exam_update	{"style": "auto-generated", "selected": 1}	news_hook	informational_value	Hinglish	none	2026-09-09 16:51:44.575471	2026-09-09 16:51:44.575471
71	yBnFHlmgMFQ	Watch this movie before RESULTS of JEE Advanced 2024!! #jee2024 #jeeadavanced #shorts	Watch this movie before RESULTS of JEE Advanced 2024!! #jee2024 #jeeadavanced #shorts	As we await the JEE Advanced 2024 results, I've got a special movie recommendation that will inspire and motivate you. Trust me, you don't want to miss this!\n\n#jee2024 #motivation #jeeadavanced #iit #iitbombay #iitjee #iitdelhi #jeeadvanced2024 #josaa	251	f	f	\N	57	15-60s	public	\N	\N	\N	\N	f	{}	\N	{jee,advanced,jee2024,motivation,movie}	{exam,jeeadvanced,results,recommendation}	t	{🎓,✨}	f	2024	educational	exam_tips	{}	attention_grab	educational	Hinglish	none	2026-09-09 23:48:51.46802	2026-09-09 23:48:51.46802
93	AwJoDsJiAoQ	😱 CUET Answer Key Changed? New Answer Key? #cuet2024 #cuetanswerkey #shorts	😱 CUET Answer Key Changed? New Answer Key? #cuet2024 #cuetanswerkey #shorts	Hey CUET Aspirants! 📚\nIs the CUET answer key really changed? Get the latest updates and find out what this means for your results. Stay informed and make sure you’re prepared for any changes!\n🔔 Don’t miss out! Hit the like button and subscribe for more updates.	261	t	f	\N	60	15-60s	public	\N	\N	\N	\N	t	{en,hi}	\N	{#cuet2024,#cuetanswerkey,#shorts}	{}	t	{😱}	f	2024	educational	breaking_news	{"style": "text_overlay", "has_face": false, "dominant_color": "#FF0000"}	curiosity	result_notification	Hinglish	description_only	2026-09-13 00:30:05.383779	2026-09-13 00:30:05.383779
53	m1qgKExs2BY	⚠️ JEE Adv Admit Card Out!! | JEE 2024 #jee2024 #jeeadvanced2024 #shorts	JEE Adv Admit Card Out!! | JEE 2024 #jee2024 #jeeadvanced2024 #shorts	⛒️ Attention JEE Advanced aspirants! Exciting news – the JEE Advanced Admit Cards are officially out! In this short video, we'll guide you on how to download your admit card and ensure you're all set for the big day.\n\nJoin us as we walk you through the steps to access your admit card, important details to check, and crucial exam day instructions. Don't miss out on this essential update for your JEE Advanced 2024 preparation!\n\nHit play now to get all the information you need about your JEE Advanced Admit Card. Share this video with your friends to help them stay informed too. Let's get ready to ace the exam together! ⛒️\n\n#JEE2024 #iitbombay #iitdelhi #motivation  #JEEPrep #iitjee #iit #examtips #jeemains #jeemainsresult #jeeadvanced #iitb #iitd #dtu #shorts #finalanswerkey #result #jeeresults #jeemainsresult #jeemains2024 #jeeadvanced2024	849	t	f	2024-05-16 00:00:00	39	15-60s	public	\N	\N	video	JOSAA_Counselling_Complete_Process_Step_by_Step_All_about_JOSAA_Counselling_JEE_2024	t	{none,hi,en-auto}	JOSAA_Counselling_Complete_Process_Step_by_Step_All_about_JOSAA_Counselling_JEE_2024	{#jee2024,#jeeadvanced2024,#shorts}	{#JEE2024,#iitbombay,#iitdelhi,#motivation,#JEEPrep,#iitjee,#iit,#examtips,#jeemains,#jeemainsresult,#jeeadvanced,#iitb,#iitd,#dtu,#shorts,#finalanswerkey,#result,#jeeresults,#jeemainsresult,#jeemains2024,#jeeadvanced2024}	t	{⚠️}	t	2024	result_update	admit_card_release	{"style": "text_overlay", "has_face": false, "dominant_color": "#000000"}	urgency	result_update	Hinglish	description_only	2026-09-05 19:53:35.380044	2026-09-05 19:53:35.380044
54	_vTmJ79_4ho	⚠️ JAC DELHI Dates Changed!! | JEE 2024 #jee2024 #jacdelhi #shorts	JAC DELHI Dates Changed!! | JEE 2024 #jee2024 #jacdelhi #shorts	⛒️ Attention all JAC Delhi aspirants! There's an important update – the JAC Delhi admission dates have been changed! In this short video, we'll provide you with all the details about the new dates and what this means for your admission process.\n\nJoin us as we explain the reasons behind the date changes and how you can adjust your plans accordingly. Staying informed is crucial to ensure you don't miss any important deadlines.\n\nHit play now to get the latest updates on the JAC Delhi admission schedule. Share this video with your friends who are also applying to JAC Delhi to keep them informed. Let's navigate these changes together and stay on track for a successful admission process! ⛒️\n\n\n#JEE2024 #iitbombay #iitdelhi #motivation  #iitjee #iit #jeemains #jeeadvanced #dtu #nsut #iiitd #dseu #igdtuw #shorts #resul #jeemains2024 #jeeadvanced2024 #jacdelhi #josaacounseling	879	t	f	2024-05-17 00:00:00	45	15-60s	public	\N	\N	video	JAC_DELHI_Counselling_Complete_Process_Step_by_Step_All_about_JAC_DELHI_Counselling_JEE_2024	t	{none,hi,en-auto}	JAC_DELHI_Counselling_Complete_Process_Step_by_Step_All_about_JAC_DELHI_Counselling_JEE_2024	{#jee2024,#jacdelhi,#shorts}	{#JEE2024,#iitbombay,#iitdelhi,#motivation,#iitjee,#iit,#jeemains,#jeeadvanced,#dtu,#nsut,#iiitd,#dseu,#igdtuw,#shorts,#resul,#jeemains2024,#jeeadvanced2024,#jacdelhi,#josaacounseling}	t	{⚠️}	f	2024	schedule_alert	procedural	{"style": "text_overlay", "has_face": false, "dominant_color": "#000000"}	urgency	schedule_alert	Hinglish	description_only	2026-09-05 20:12:48.727333	2026-09-05 20:12:48.727333
80	pl90QEsoKFk	😱 NTA director general REMOVED!! #neet #ugcnet #jee #shorts	😱 NTA director general REMOVED!! #neet #ugcnet #jee #shorts	Breaking News! The NTA Director General has been removed from their position. 😲 What does this mean for JEE, NEET, and other exams? Join us as we discuss the implications and what this could mean for your upcoming exams. Stay informed and stay ahead!\n\n👉 Subscribe for more updates!\n🔔 Turn on notifications to stay informed!\n\n#NTANews #nta #BreakingNews #JEE2024 #NEET2024 #ugcnet #neet	385	f	f	\N	58	15-60s	public	\N	\N	\N	\N	f	{}	\N	{neet,ugcnet,jee}	{exam,results,nta,updates}	t	{😱}	f	2024	educational	news_or_update	{}	attention_grab	educational	English	none	2026-09-10 23:08:11.068235	2026-09-10 23:10:00.515414
65	4B4aAW76GLQ	🔴JAC Delhi Finally Started!! #jee2024 #jacdelhi #shorts	🔴JAC Delhi Finally Started!! #jee2024 #jacdelhi #shorts	The wait is over—JAC Delhi registration has officially begun! Get ready to secure your spot at top colleges. Watch this quick video for all the details you need to get started.\n\nWatch JAC DELHI full procedure video on my channel for crystal clarity of process!!\nand do fill the form for any counselling related doubts like which college/branch is best for you according to your rank, etc\n\nHit play and jumpstart your admission journey. Share this important update with friends who are also gearing up for JAC Delhi. Let's make it happen! 🚀\n\n#jacdelhi  #CounsellingProcess #JEE2024 #josaa #JoSAA2024 #jac2024 #iitjee #jeemains #dtu #nsut #iiitd #igdtuw #dseu #jaccounseling  🎓	675	t	f	2024-05-30 00:00:00	61	60-120s	public	\N	\N	video	4B4aAW76GLQ	f	{}	\N	{#jee2024,#jacdelhi,#shorts}	{#jacdelhi,#CounsellingProcess,#JEE2024,#josaa,#JoSAA2024,#jac2024,#iitjee,#jeemains,#dtu,#nsut,#iiitd,#igdtuw,#dseu,#jaccounseling}	t	{🔴}	t	2024	educational	exam_tips	{"type": "auto"}	news	informational	Hinglish	description	2026-09-06 16:09:41.971201	2026-09-07 09:04:23.739817
72	bLwR73Y2d0w	🚨DELHI HIGH COURT will now solve NEET 2024 Case!! #neet #neet2024 #shorts	🚨DELHI HIGH COURT will now solve NEET 2024 Case!! #neet #neet2024 #shorts	In a landmark move, the Delhi High Court will now address the pressing issues surrounding NEET 2024. With thousands of aspiring medical students anxiously waiting for clarity, this decision could bring significant changes and I break down everything you need to know about this pivotal case.#neet #neet2024 #neetreexam #neetresult #nta #neetug #shorts #aiims	358	f	t	2024-06-08 00:00:00	60	15-60s	public	\N	\N	\N	\N	f	{}	\N	{NEET,"Delhi High Court",2024,Exam}	{NEET,"Delhi High Court",2024,Exam}	t	{🚨}	t	2024	educational	exam_tips	{}	breaking_news	educational	Hinglish	none	2026-09-10 10:04:13.605465	2026-09-10 10:04:13.605465
89	w2UTdzsuads	🔴 SUPREME COURT hearing on NEET 24 Paper Leak | explained in 1 min #neet2024  #reneet #shorts	🔴 SUPREME COURT hearing on NEET 24 Paper Leak | explained in 1 min #neet2024  #reneet #shorts	Hey NEET aspirants! 🌟 In this video, i'll summarize today's Supreme Court hearing on NEET ug 2024\n paper leak and whether neet exam is happening again or not! This major update can impact your preparation and plans. Watch this short video to get all the crucial details and understand what you need to do next. Stay informed and be ready! 💪\nDon't forget to LIKE, SHARE, and SUBSCRIBE for the latest updates! 🔔	409	t	f	\N	60	15-60s	public	\N	\N	\N	\N	t	{en,hi}	\N	{#neet2024,#reneet,#shorts}	{}	t	{🔴}	t	2024	educational	breaking_news	{"style": "text_overlay", "has_face": false, "dominant_color": "#FF0000"}	urgency	result_notification	Hinglish	description_only	2026-09-11 16:35:54.958145	2026-09-11 22:58:07.599184
85	W1nCo6y71R8	🔴 IPU FREE COUNSELLING | IMP DATES | PREFERENCE ORDER #ipu #ggsipu #shorts	🔴 IPU FREE COUNSELLING | IMP DATES | PREFERENCE ORDER #ipu #ggsipu #shorts	Ready to ace your college admissions? We’re here to help you every step of the way with FREE COUNSELLING! In this video, we’ll cover everything you need to know to make the best decisions for your future.\n🔍 What You’ll Get on this Channel:\nPersonalized Guidance: We’ll help you identify the best college options based on your rank.\nOptimal Preference Order: Coming soon, we’ll provide the best preference order for IPU colleges to maximize your chances of getting into your dream institution.\nImportant Dates and Updates: Stay informed with all the crucial dates and updates for IPU counselling, so you never miss a deadline.\n🚀 Don’t Miss Our Live Counselling Session!\nJoin us today for a live counselling session from 4-5 pm on our channel page. This is your chance to get personalized advice, ask questions, and clarify any doubts you have about the admissions process. Don’t miss out on this invaluable opportunity to get real-time support and make informed decisions.\n🔔 Stay Connected!\nMake sure to like this video and subscribe to our channel to stay updated with all the latest information and resources. Hit the bell icon to get notifications about our upcoming videos and live sessions.	1194	t	f	\N	60	15-60s	public	\N	\N	\N	\N	t	{en,hi}	\N	{#ipu,#ggsipu,#shorts}	{}	t	{🔴}	t	2024	educational	counselling	{"style": "text_overlay", "has_face": false, "dominant_color": "#FF0000"}	urgency	actionable_info	Hinglish	description_only	2026-09-11 16:35:53.569939	2026-09-11 22:58:06.303119
88	xj4emmUcJGE	🤯CUTOFF ANALYSIS | IPU Round-1 | Low Rank pe bhi Good College #ipu #ggsipu #shorts	🤯CUTOFF ANALYSIS | IPU Round-1 | Low Rank pe bhi Good College #ipu #ggsipu #shorts	IPU Cutoff Analysis!!\nDrastic change\nLow Rank = Good College?\nBTECH (code-131)\nIt's very important for you to get these updates on time, that's why subscribe this channel and watch all the videos/shorts to stay updated and get your dream college/branch or in general become successful in life!!\n🔗Circular Link: https://cdnbbsr.s3waas.gov.in/s3ea119a40c1592979f51819b0bd38d39d/uploads/2024/07/2024070644.pdf\n🔥IPU BEST Choice filling Order/ Full Preference Order: https://youtu.be/gbIxin_BDjw\n🔔 Don’t miss out! Hit the notification bell to get a reminder when we go live. Remember to LIKE, SHARE, and SUBSCRIBE for more tips and updates! Your future starts here!\n📢 Connect with us:\nInstagram: https://www.instagram.com/yatharthsachdeva23\nLinkedIn: https://www.linkedin.com/in/yatharth-sachdeva-2691462a5/	802	t	t	\N	60	15-60s	public	\N	\N	\N	\N	t	{en,hi}	\N	{#ipu,#ggsipu,#shorts}	{}	f	{}	f	2024	educational	breaking_news	{"style": "text_overlay", "has_face": false, "dominant_color": "#FF0000"}	curiosity	result_notification	Hinglish	description_only	2026-09-11 16:35:54.654653	2026-09-11 22:58:07.287609
91	PaYUzmc11E8	JAC Delhi Choice Editing option Available | Change your choices now! #jacdelhi #jacdelhi2024 #shorts	JAC Delhi Choice Editing option Available | Change your choices now! #jacdelhi #jacdelhi2024 #shorts	Now you can edit/modify your choices of JAC Delhi 2024!! \nThis is the only option if you want to change your choices!!\nStay tuned and make sure you don't miss out on any crucial information. Whether you’ve got the seat you aimed for or are gearing up for the next round, we’re here to guide you through every step.\n🔴JAC DELHI 2024 Videos:	338	f	f	\N	60	15-60s	public	\N	\N	\N	\N	t	{en,hi}	\N	{#jacdelhi,#jacdelhi2024,#shorts}	{}	f	{}	f	2024	educational	breaking_news	{"style": "text_overlay", "has_face": false, "dominant_color": "#FF0000"}	curiosity	result_notification	Hinglish	none	2026-09-11 16:35:55.65266	2026-09-11 22:58:08.189019
86	rrTB_XW3pWA	🚨RESULT UPDATE!! IPU Counselling 2024 | GGSIPU #IPU #ggsipu #shorts	🚨RESULT UPDATE!! IPU Counselling 2024 | GGSIPU #IPU #ggsipu #shorts	There's an official notice from IPU regarding result update and further procedures dates for the admission of btech 2024 students\nBTECH (code-131)\nIt's very important for you to get these updates on time, that's why subscribe this channel and watch all the videos/shorts to stay updated and get your dream college/branch or in general become successful in life!!\n🔗Circular Link: https://cdnbbsr.s3waas.gov.in/s3ea119a40c1592979f51819b0bd38d39d/uploads/2024/07/2024070659.pdf\n🔥IPU BEST Choice filling Order/ Full Preference Order: https://youtu.be/gbIxin_BDjw\n🔔 Don’t miss out! Hit the notification bell to get a reminder when we go live. Remember to LIKE, SHARE, and SUBSCRIBE for more tips and updates! Your future starts here!\n📢 Connect with us:\nInstagram: https://www.instagram.com/yatharthsachdeva23\nLinkedIn: https://www.linkedin.com/in/yatharth-sachdeva-2691462a5/	870	t	t	\N	60	15-60s	public	\N	\N	\N	\N	t	{en,hi}	\N	{#IPU,#ggsipu,#shorts}	{}	t	{🚨}	t	2024	educational	counselling	{"style": "text_overlay", "has_face": false, "dominant_color": "#FF0000"}	urgency	actionable_info	Hinglish	description_only	2026-09-12 22:06:31.315393	2026-09-12 23:25:09.52654
87	kbLQ0kJ7pYQ	🔴IPU REGISTRATION again opening!! 🎉 #ipu #ggsipu #shorts	🔴IPU REGISTRATION again opening!! 🎉 #ipu #ggsipu #shorts	IPU Registration opening again!!\nRegister now, if you can't do earlier\nand do pay both that Rs 1000 otherwise you won't get seat again!\nBTECH (code-131)\nIt's very important for you to get these updates on time, that's why subscribe this channel and watch all the videos/shorts to stay updated and get your dream college/branch or in general become successful in life!!\n🔗Circular Link: https://cdnbbsr.s3waas.gov.in/s3ea119a40c1592979f51819b0bd38d39d/uploads/2024/07/2024070659.pdf\n🔥IPU BEST Choice filling Order/ Full Preference Order: https://youtu.be/gbIxin_BDjw\n🔔 Don’t miss out! Hit the notification bell to get a reminder when we go live. Remember to LIKE, SHARE, and SUBSCRIBE for more tips and updates! Your future starts here!\n📢 Connect with us:\nInstagram: https://www.instagram.com/yatharthsachdeva23\nLinkedIn: https://www.linkedin.com/in/yatharth-sachdeva-2691462a5/	876	t	t	\N	60	15-60s	public	\N	\N	\N	\N	t	{en,hi}	\N	{#ipu,#ggsipu,#shorts}	{}	t	{🔴,🎉}	t	2024	educational	breaking_news	{"style": "text_overlay", "has_face": false, "dominant_color": "#FF0000"}	urgency	result_notification	Hinglish	description_only	2026-09-13 00:04:05.182697	2026-09-13 00:04:05.182697
94	ZrY0tM9yPxQ	🚨 CUET ADMIT CARD OUT!! 19th July Cuet Re-exam | CUET 2024 #cuet #cuetadmitcard #shorts	🚨 CUET ADMIT CARD OUT!! 19th July Cuet Re-exam | CUET 2024 #cuet #cuetadmitcard #shorts	📢 Attention CUET aspirants! The CUET admit cards are now available for download, and the re-exam is scheduled for 19th July. Make sure to check your admit card and prepare accordingly. Stay tuned for more updates and tips on acing your exam! 🚀\n🔔 Like, share, and subscribe for the latest CUET news and updates. Don't forget to hit the notification bell to stay informed!	370	t	f	\N	60	15-60s	public	\N	\N	\N	\N	t	{en,hi}	\N	{#cuet,#cuetadmitcard,#shorts}	{}	t	{🚨}	t	2024	educational	breaking_news	{"style": "text_overlay", "has_face": false, "dominant_color": "#FF0000"}	urgency	result_notification	Hinglish	description_only	2026-09-13 00:37:30.390512	2026-09-13 00:39:03.743153
101	muLRYXpkVWA	Harsh Gujral in DTU 🔥 #harshgujral	Harsh Gujral in DTU 🔥 #harshgujral	Harsh Gujral in DTU \nDTU Invictus'25 \nDTU Techfest\nMovie promotion	66	f	f	\N	60	15-60s	public	\N	\N	\N	\N	t	{en,hi}	\N	{#harshgujral}	{}	t	{🔥}	f	2024	educational	breaking_news	{"style": "text_overlay", "has_face": false, "dominant_color": "#FF0000"}	curiosity	result_notification	Hinglish	none	2026-09-13 01:13:37.456849	2026-09-13 08:06:19.001339
95	hiP5k2gClN0	Internal Upgradation Round Result Out!! | JAC Delhi 2024 #shorts #jacdelhi #dtu	Internal Upgradation Round Result Out!! | JAC Delhi 2024 #shorts #jacdelhi #dtu	Exciting news for all JAC Delhi 2024 aspirants! The results for the Internal Upgradation Round are finally out! This is a crucial step in your journey towards securing your dream seat in prestigious colleges like DTU, NSUT, IIITD, and IGDTUW.\n🔔 Stay Updated: Subscribe and hit the notification bell to get instant updates and tips on JAC Delhi counseling and college life. LIKE, SHARE, and SUBSCRIBE to our channel for more expert guidance and support.\n📢 Connect with me:\nInstagram: https://www.instagram.com/yatharthsachdeva23\nLinkedIn: https://www.linkedin.com/in/yatharth-sachdeva-2691462a5/	594	t	t	\N	60	15-60s	public	\N	\N	\N	\N	t	{en,hi}	\N	{#shorts,#jacdelhi,#dtu}	{}	f	{}	f	2024	educational	result_alert	{"style": "text_overlay", "has_face": false, "dominant_color": "#FF0000"}	curiosity	result_notification	Hinglish	description_only	2026-09-13 00:39:10.017376	2026-09-13 00:39:10.017376
98	DrhZsdeBj6k	🔴Jee mains 2025 forgot password? | Reset password | Jee mains 2025 Result #jeemain #jee	🔴Jee mains 2025 forgot password? | Reset password | Jee mains 2025 Result #jeemain #jee	Thumbnail\nSet a thumbnail that stands out and draws viewers' attention. Learn more\nGet suggestions\nPlaylists\nAdd your video to one or more playlists to organize your content for viewers. Learn more\nSelect\nAudience\nThis video is set to not made for kids \nSet by you\nRegardless of your location, you're legally required to comply with the Children's Online Privacy Protection Act (COPPA) and/or other laws. You're required to tell us whether your videos are made for kids. What's content made for kids?\nFeatures like personalized ads and notifications won’t be available on videos made for kids. Videos that are set as made for kids by you are more likely to be recommended alongside other kids’ videos. Learn more\nYes, it's made for kids\n.\nFeatures like personalized ads and notifications won’t be available on videos made for kids. Videos that are set as made for kids by you are more likely to be recommended alongside other kids’ videos. Learn more\nNo, it's not made for kids\nAge restriction\nShow more\nPaid promotion, collaboration, and more\nVideo link	1054	f	f	\N	60	15-60s	public	\N	\N	\N	\N	t	{en,hi}	\N	{#jeemain,#jee}	{}	t	{🔴}	t	2024	educational	result_alert	{"style": "text_overlay", "has_face": false, "dominant_color": "#FF0000"}	urgency	result_notification	Hinglish	none	2026-09-13 00:39:55.370257	2026-09-13 00:39:55.370257
96	QnjyscmnjEQ	SLIDING Round RESULT OUT!! IPU BTECH Counselling 2024 #ipu #shorts #slidinground	SLIDING Round RESULT OUT!! IPU BTECH Counselling 2024 #ipu #shorts #slidinground	IPU BTECH SLIDING ROUND RESULT OUT!!\nThumbnail\nSet a thumbnail that stands out and draws viewers' attention. Learn more\nGet suggestions\nPlaylists\nAdd your video to one or more playlists to organize your content for viewers. Learn more\nSelect\nAudience\nThis video is set to not made for kids \nSet by you\nRegardless of your location, you're legally required to comply with the Children's Online Privacy Protection Act (COPPA) and/or other laws. You're required to tell us whether your videos are made for kids. What's content made for kids?\nFeatures like personalized ads and notifications won’t be available on videos made for kids. Videos that are set as made for kids by you are more likely to be recommended alongside other kids’ videos. Learn more\nYes, it's made for kids\n.\nFeatures like personalized ads and notifications won’t be available on videos made for kids. Videos that are set as made for kids by you are more likely to be recommended alongside other kids’ videos. Learn more\nNo, it's not made for kids\nAge restriction\nShow more\nPaid promotion, collaboration, and more\nVideo link	1091	f	f	\N	60	15-60s	public	\N	\N	\N	\N	t	{en,hi}	\N	{#ipu,#shorts,#slidinground}	{}	f	{}	f	2024	educational	counselling	{"style": "text_overlay", "has_face": false, "dominant_color": "#FF0000"}	curiosity	actionable_info	Hinglish	none	2026-09-13 00:39:20.653047	2026-09-13 01:04:42.898173
99	5v6ouzwDdRQ	Ishika Sehgal in DTU | DTU | Fresher's Fest #dtu #fest #dtufest	Ishika Sehgal in DTU | DTU | Fresher's Fest #dtu #fest #dtufest	Thumbnail\nSet a thumbnail that stands out and draws viewers' attention. Learn more\nGet suggestions\nPlaylists\nAdd your video to one or more playlists to organize your content for viewers. Learn more\nSelect\nAudience\nThis video is set to not made for kids \nSet by you\nRegardless of your location, you're legally required to comply with the Children's Online Privacy Protection Act (COPPA) and/or other laws. You're required to tell us whether your videos are made for kids. What's content made for kids?\nFeatures like personalized ads and notifications won’t be available on videos made for kids. Videos that are set as made for kids by you are more likely to be recommended alongside other kids’ videos. Learn more\nYes, it's made for kids\n.\nFeatures like personalized ads and notifications won’t be available on videos made for kids. Videos that are set as made for kids by you are more likely to be recommended alongside other kids’ videos. Learn more\nNo, it's not made for kids\nAge restriction\nShow more\nPaid promotion, collaboration, and more\n0:00 / 0:25\nVideo link	1066	f	f	\N	60	15-60s	public	\N	\N	\N	\N	t	{en,hi}	\N	{#dtu,#fest,#dtufest}	{}	f	{}	f	2024	educational	breaking_news	{"style": "text_overlay", "has_face": false, "dominant_color": "#FF0000"}	curiosity	result_notification	Hinglish	none	2026-09-13 01:13:56.344106	2026-09-13 08:07:14.421856
97	3JdwNxhgqN8	DTU Orientation Place - Raj Soin Hall | DTU | Fresher's Orientation #shorts #dtu #motivation	DTU Orientation Place - Raj Soin Hall | DTU | Fresher's Orientation #shorts #dtu #motivation	This is the magnificant Raj Soin Hall of DTU where fresher's orientation happens currently there is fresher's orientation for JAC Delhi 2024 students going on \nRest of the time either any competition or something is happening here or if nothings there you can freely play badminton in this area with your friends!!\nWork Hard to achieve your goals and make yourself and your family proud!!\nThumbnail\nSet a thumbnail that stands out and draws viewers' attention. Learn more\nGet suggestions\nPlaylists\nAdd your video to one or more playlists to organize your content for viewers. Learn more\nSelect\nAudience\nThis video is set to not made for kids \nSet by you\nRegardless of your location, you're legally required to comply with the Children's Online Privacy Protection Act (COPPA) and/or other laws. You're required to tell us whether your videos are made for kids. What's content made for kids?\nFeatures like personalized ads and notifications won’t be available on videos made for kids. Videos that are set as made for kids by you are more likely to be recommended alongside other kids’ videos. Learn more\nYes, it's made for kids\n.\nFeatures like personalized ads and notifications won’t be available on videos made for kids. Videos that are set as made for kids by you are more likely to be recommended alongside other kids’ videos. Learn more\nNo, it's not made for kids\nAge restriction\nShow more\nPaid promotion, collaboration, and more\nVideo link	1443	f	f	\N	60	15-60s	public	\N	\N	\N	\N	t	{en,hi}	\N	{#shorts,#dtu,#motivation}	{}	f	{}	f	2024	educational	breaking_news	{"style": "text_overlay", "has_face": false, "dominant_color": "#FF0000"}	curiosity	result_notification	Hinglish	none	2026-09-13 00:38:36.543059	2026-09-13 00:48:04.423667
103	_gF2JDP64Yc	MTV Hustle S4 runner-up  @NaamSujal  performance in DTU | DTU Invictus'25 #naamsujal #rapper #dtu	MTV Hustle S4 runner-up  @NaamSujal  performance in DTU | DTU Invictus'25 #naamsujal #rapper #dtu	Rapper NaamSujal came in DTU in techweek Invictus'25 for performance \nMore such clips of Techfest has uploaded on this channel \nSubscribe for more such clips!!\nThumbnail\nSet a thumbnail that stands out and draws viewers' attention. Learn more\nGet suggestions\nPlaylists\nAdd your video to one or more playlists to organize your content for viewers. Learn more\nSelect\nAudience\nThis video is set to not made for kids \nSet by you\nRegardless of your location, you're legally required to comply with the Children's Online Privacy Protection Act (COPPA) and/or other laws. You're required to tell us whether your videos are made for kids. What's content made for kids?\nFeatures like personalized ads and notifications won’t be available on videos made for kids. Videos that are set as made for kids by you are more likely to be recommended alongside other kids’ videos. Learn more\nYes, it's made for kids\n.\nFeatures like personalized ads and notifications won’t be available on videos made for kids. Videos that are set as made for kids by you are more likely to be recommended alongside other kids’ videos. Learn more\nNo, it's not made for kids\nAge restriction\nShow more\nPaid promotion, collaboration, and more\nVideo link	1214	t	f	\N	60	15-60s	public	\N	\N	\N	\N	t	{en,hi}	\N	{#naamsujal,#rapper,#dtu}	{}	f	{}	f	2024	educational	breaking_news	{"style": "text_overlay", "has_face": false, "dominant_color": "#FF0000"}	curiosity	result_notification	Hinglish	description_only	2026-09-13 01:13:04.779195	2026-09-13 08:06:26.943876
102	j7xmoRH2rzo	Mere Husband ki Biwi Cast in DTU | Bhumi Pednekar | Rakul Preet #merehusbandkibiwi #dtu #bollywood	Mere Husband ki Biwi Cast in DTU | Bhumi Pednekar | Rakul Preet #merehusbandkibiwi #dtu #bollywood	Arjun Kapoor, Bhumi Pednekar, Rakul Preet and Harsh Gujral came in DTU for their movie promotion of "Mere Husband ki Biwi" realising on 21 Feb 2025 \nThis is just the TECHNICAL fest of DTU, engifest is coming up!!\nSubscribe for more clips and useful content!!\nThumbnail\nSet a thumbnail that stands out and draws viewers' attention. Learn more\nGet suggestions\nPlaylists\nAdd your video to one or more playlists to organize your content for viewers. Learn more\nSelect\nAudience\nThis video is set to not made for kids \nSet by you\nRegardless of your location, you're legally required to comply with the Children's Online Privacy Protection Act (COPPA) and/or other laws. You're required to tell us whether your videos are made for kids. What's content made for kids?\nFeatures like personalized ads and notifications won’t be available on videos made for kids. Videos that are set as made for kids by you are more likely to be recommended alongside other kids’ videos. Learn more\nYes, it's made for kids\n.\nFeatures like personalized ads and notifications won’t be available on videos made for kids. Videos that are set as made for kids by you are more likely to be recommended alongside other kids’ videos. Learn more\nNo, it's not made for kids\nAge restriction\nShow more\nPaid promotion, collaboration, and more\nVideo link	1313	t	f	\N	60	15-60s	public	\N	\N	\N	\N	t	{en,hi}	\N	{#merehusbandkibiwi,#dtu,#bollywood}	{}	f	{}	f	2024	educational	breaking_news	{"style": "text_overlay", "has_face": false, "dominant_color": "#FF0000"}	curiosity	result_notification	Hinglish	description_only	2026-09-13 01:11:56.712419	2026-09-13 08:04:48.235092
100	4yAeMwjZxoo	Drone Racing Track | Techweek'25 DTU | Invictus'25 | DTU Techfest #dtu #invictus #techfest	Drone Racing Track | Techweek'25 DTU | Invictus'25 | DTU Techfest #dtu #invictus #techfest	🚀 Drone Racing Track at Techweek'25 | Invictus'25 DTU! 🏁✨  \nGet ready for an electrifying experience at DTU Techweek'25, where speed, skill, and innovation come together on the ultimate Drone Racing Track! ⚡ Watch high-speed drones navigate sharp turns, dodge obstacles, and race to victory in an intense showdown of technology and precision flying.  \nWhether you're a tech enthusiast, a drone pilot, or just love thrilling competitions, Invictus'25 DTU has something for you! Witness the future of racing, powered by cutting-edge tech and next-level piloting. 🎮🚁  \n🔥 Do you have what it takes to conquer the track? Join us and be part of the action! 💥	652	f	f	\N	60	15-60s	public	\N	\N	\N	\N	t	{en,hi}	\N	{#dtu,#invictus,#techfest}	{}	f	{}	f	2024	educational	breaking_news	{"style": "text_overlay", "has_face": false, "dominant_color": "#FF0000"}	curiosity	result_notification	Hinglish	none	2026-09-13 01:28:53.317392	2026-09-13 08:12:31.899566
107	SS61lwI_i5Q	🔴 JEE MAINS SESSION 2 RESULT | HOW TO CHECK RESULT!! #jeemains #jeemain2025  #jeemainsresult	🔴 JEE MAINS SESSION 2 RESULT | HOW TO CHECK RESULT!! #jeemains #jeemain2025  #jeemainsresult	Thumbnail\nSet a thumbnail that stands out and draws viewers' attention. Learn more\nGet suggestions\nPlaylists\nAdd your video to one or more playlists to organize your content for viewers. Learn more\nSelect\nAudience\nThis video is set to not made for kids \nSet by you\nRegardless of your location, you're legally required to comply with the Children's Online Privacy Protection Act (COPPA) and/or other laws. You're required to tell us whether your videos are made for kids. What's content made for kids?\nFeatures like personalized ads and notifications won’t be available on videos made for kids. Videos that are set as made for kids by you are more likely to be recommended alongside other kids’ videos. Learn more\nYes, it's made for kids\n.\nFeatures like personalized ads and notifications won’t be available on videos made for kids. Videos that are set as made for kids by you are more likely to be recommended alongside other kids’ videos. Learn more\nNo, it's not made for kids\nAge restriction\nShow more\nPaid promotion, collaboration, and more\n0:00 / 1:12\nVideo link	1066	f	f	\N	60	15-60s	public	\N	\N	\N	\N	t	{en,hi}	\N	{#jeemains,#jeemain2025,#jeemainsresult}	{}	t	{🔴}	t	2024	educational	result_alert	{"style": "text_overlay", "has_face": false, "dominant_color": "#FF0000"}	urgency	result_notification	Hinglish	none	2026-09-13 08:20:20.943281	2026-09-13 08:20:20.943281
104	BMh9Xq36RrA	VICHAAR | MTV HUSTLE S4 TOP 5 | Live performance in DTU #vichaar #mtvhustle #dtu	VICHAAR | MTV HUSTLE S4 TOP 5 | Live performance in DTU #vichaar #mtvhustle #dtu	Mtv hustle 4 contestant "Vichaar" live performance in DTU Invictus'25 \nLike and subscribe for more such clips of DTU\nThumbnail\nSet a thumbnail that stands out and draws viewers' attention. Learn more\nGet suggestions\nPlaylists\nAdd your video to one or more playlists to organize your content for viewers. Learn more\nSelect\nAudience\nThis video is set to not made for kids \nSet by you\nRegardless of your location, you're legally required to comply with the Children's Online Privacy Protection Act (COPPA) and/or other laws. You're required to tell us whether your videos are made for kids. What's content made for kids?\nFeatures like personalized ads and notifications won’t be available on videos made for kids. Videos that are set as made for kids by you are more likely to be recommended alongside other kids’ videos. Learn more\nYes, it's made for kids\n.\nFeatures like personalized ads and notifications won’t be available on videos made for kids. Videos that are set as made for kids by you are more likely to be recommended alongside other kids’ videos. Learn more\nNo, it's not made for kids\nAge restriction\nShow more\nPaid promotion, collaboration, and more\nVideo link	1171	t	f	\N	60	15-60s	public	\N	\N	\N	\N	t	{en,hi}	\N	{#vichaar,#mtvhustle,#dtu}	{}	f	{}	f	2024	educational	breaking_news	{"style": "text_overlay", "has_face": false, "dominant_color": "#FF0000"}	curiosity	result_notification	Hinglish	description_only	2026-09-13 08:22:34.508287	2026-09-13 08:22:34.508287
\.


--
-- Data for Name: title_templates; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.title_templates (id, template_name, template_pattern, emoji_position, has_pipe_separator, has_how_to, has_question_mark, has_double_exclamation, created_at) FROM stdin;
1	educational_series_part	{topic} (Part-{part}) #{hashtags}	none	f	f	f	f	2026-08-31 21:43:43.755093
2	educational_series_part	{topic} (Part-{part}) #{hashtags}	none	f	f	f	f	2026-08-31 22:40:13.429451
6	educational_series_part	{topic} (Part-{part}) #{hashtags}	none	f	f	f	f	2026-08-31 22:53:13.887132
7	educational_series_part	{topic} (Part-{part}) #{hashtags}	none	f	f	f	f	2026-08-31 22:54:52.036978
12	educational_series_part	{topic} (Part-{part}) #{hashtags}	none	f	f	f	f	2026-09-01 08:45:25.36398
24	series_part_format	MOST IMP TIPS for JEE & other competitive exams (Part-{N}) #iit #jee #part{N} #jee2024	none	f	f	f	f	2026-09-01 09:19:49.888536
26	series_part_format	MOST IMP TIPS for JEE & other competitive exams (Part-{N}) #iit #jee #part{N} #jee2024	none	f	f	f	f	2026-09-01 09:29:40.491408
27	series_part_format	MOST IMP TIPS for JEE & other competitive exams (Part-{N}) #iit #jee #part{N} #jee2024	none	f	f	f	f	2026-09-01 09:42:27.379694
28	alert_announcement	[EMOJI] [TOPIC] [ACTION]!! #[HASHTAG1] #[HASHTAG2] #[HASHTAG3]	prefix	f	f	f	t	2026-09-07 09:04:00.666026
29	urgent_download_warning	[EMOJI] [TOPIC] [URGENCY] | [ACTION] #[HASHTAG1] #[HASHTAG2]	prefix	t	f	f	t	2026-09-07 09:16:01.388164
\.


--
-- Data for Name: traffic_sources; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.traffic_sources (id, video_id, source_name, source_category, views, percentage, avg_view_duration_seconds, retention_pct, fetched_at) FROM stdin;
893	LQ7ttolwjJQ	Shorts feed	feed	59	85.50	11.00	13.50	2026-09-07 10:50:43.305672
271	XWFbqR_9fqc	Shorts feed	internal	1	6.30	27.00	58.30	2026-09-02 10:02:53.957789
277	s_PoEssiuPo	YouTube search	search	19	55.90	20.00	50.80	2026-09-02 10:03:18.329293
278	s_PoEssiuPo	Channel pages	internal	10	29.40	20.00	50.80	2026-09-02 10:03:18.329293
279	s_PoEssiuPo	Shorts feed	internal	3	8.80	20.00	50.80	2026-09-02 10:03:18.329293
280	s_PoEssiuPo	Browse features	internal	1	2.90	20.00	50.80	2026-09-02 10:03:18.329293
281	s_PoEssiuPo	Playlists	internal	1	2.90	20.00	50.80	2026-09-02 10:03:18.329293
311	yDKB-xCaMB8	YouTube search	youtube_search	25	58.10	16.00	25.50	2026-09-02 14:30:31.576863
312	yDKB-xCaMB8	Shorts feed	shorts_feed	12	27.90	16.00	25.50	2026-09-02 14:30:31.576863
313	yDKB-xCaMB8	Channel pages	channel_pages	3	7.00	16.00	25.50	2026-09-02 14:30:31.576863
314	yDKB-xCaMB8	Browse features	browse_features	2	4.70	16.00	25.50	2026-09-02 14:30:31.576863
315	yDKB-xCaMB8	Hashtag pages	hashtag_pages	1	2.30	16.00	25.50	2026-09-02 14:30:31.576863
322	waW201cvfl8	Shorts feed	shorts_feed	60	57.10	15.00	49.80	2026-09-02 15:14:09.210888
323	waW201cvfl8	YouTube search	youtube_search	21	20.00	15.00	49.80	2026-09-02 15:14:09.210888
324	waW201cvfl8	Channel pages	channel_pages	11	10.50	15.00	49.80	2026-09-02 15:14:09.210888
325	waW201cvfl8	External	external	8	7.60	15.00	49.80	2026-09-02 15:14:09.210888
235	5goNjmztwqg	Channel pages	channel_pages	22	51.20	\N	\N	2026-09-02 09:45:39.987643
236	5goNjmztwqg	Browse features	browse_features	8	18.60	\N	\N	2026-09-02 09:45:39.987643
237	5goNjmztwqg	Shorts feed	shorts_feed	7	16.30	\N	\N	2026-09-02 09:45:39.987643
238	5goNjmztwqg	External	external	2	4.70	\N	\N	2026-09-02 09:45:39.987643
239	5goNjmztwqg	Video cards and annotations	video_cards_annotations	2	4.70	\N	\N	2026-09-02 09:45:39.987643
240	5goNjmztwqg	Others	others	2	4.70	\N	\N	2026-09-02 09:45:39.987643
326	waW201cvfl8	Browse features	browse_features	4	3.80	15.00	49.80	2026-09-02 15:14:09.210888
327	waW201cvfl8	Others	others	1	0.90	15.00	49.80	2026-09-02 15:14:09.210888
330	Ay9K30yrg8Y	Other YouTube features	other_youtube_features	7	1.60	10.00	25.20	2026-09-02 15:27:50.633383
331	Ay9K30yrg8Y	Channel pages	channel_pages	6	1.40	10.00	25.20	2026-09-02 15:27:50.633383
332	Ay9K30yrg8Y	Browse features	browse_features	5	1.10	10.00	25.20	2026-09-02 15:27:50.633383
333	Ay9K30yrg8Y	Others	others	3	0.70	10.00	25.20	2026-09-02 15:27:50.633383
335	lmbndk-Db-Q	YouTube search	youtube_search	7	4.80	13.00	32.00	2026-09-02 21:49:28.223132
336	lmbndk-Db-Q	Browse features	browse_features	3	2.00	13.00	32.00	2026-09-02 21:49:28.223132
337	lmbndk-Db-Q	Hashtag pages	hashtag_pages	3	2.00	13.00	32.00	2026-09-02 21:49:28.223132
338	lmbndk-Db-Q	Channel pages	channel_pages	2	1.40	13.00	32.00	2026-09-02 21:49:28.223132
339	lmbndk-Db-Q	Others	others	1	0.70	13.00	32.00	2026-09-02 21:49:28.223132
340	cSapjDf5CHY	Shorts feed	shorts_feed	330	83.50	13.00	37.70	2026-09-02 23:46:30.338612
341	cSapjDf5CHY	YouTube search	youtube_search	45	11.40	13.00	37.70	2026-09-02 23:46:30.338612
342	cSapjDf5CHY	Browse features	browse_features	12	3.00	13.00	37.70	2026-09-02 23:46:30.338612
343	cSapjDf5CHY	Channel pages	channel_pages	8	2.00	13.00	37.70	2026-09-02 23:46:30.338612
344	JmSdjrAxNFM	Shorts Feed	feed	99	81.20	11.00	23.70	2026-09-03 08:43:48.484092
345	JmSdjrAxNFM	YouTube Search	search	12	9.80	11.00	23.70	2026-09-03 08:43:48.484092
346	JmSdjrAxNFM	Browse Features	browse	6	4.90	11.00	23.70	2026-09-03 08:43:48.484092
347	JmSdjrAxNFM	Channel Pages	channel	4	3.30	11.00	23.70	2026-09-03 08:43:48.484092
348	JmSdjrAxNFM	Other YouTube features	other	1	0.80	11.00	23.70	2026-09-03 08:43:48.484092
349	MpQ-K2D9Ao4	Shorts Feed	feed	393	72.90	16.00	41.50	2026-09-03 08:46:53.14088
350	MpQ-K2D9Ao4	YouTube Search	search	117	21.70	16.00	41.50	2026-09-03 08:46:53.14088
351	MpQ-K2D9Ao4	Channel Pages	channel	11	2.00	16.00	41.50	2026-09-03 08:46:53.14088
352	MpQ-K2D9Ao4	Browse Features	browse	7	1.30	16.00	41.50	2026-09-03 08:46:53.14088
353	MpQ-K2D9Ao4	Other YouTube features	other	5	0.90	16.00	41.50	2026-09-03 08:46:53.14088
354	MpQ-K2D9Ao4	Others	other	6	1.10	16.00	41.50	2026-09-03 08:46:53.14088
355	bXetyvX2Mu8	Shorts Feed	feed	308	78.00	16.00	27.30	2026-09-03 08:49:33.548839
356	bXetyvX2Mu8	YouTube Search	search	38	9.60	16.00	27.30	2026-09-03 08:49:33.548839
357	bXetyvX2Mu8	Browse Features	browse	36	9.10	16.00	27.30	2026-09-03 08:49:33.548839
358	bXetyvX2Mu8	Channel Pages	channel	9	2.30	16.00	27.30	2026-09-03 08:49:33.548839
359	bXetyvX2Mu8	Suggested Videos	suggested	1	0.30	16.00	27.30	2026-09-03 08:49:33.548839
267	XWFbqR_9fqc	Channel pages	internal	11	68.80	27.00	58.30	2026-09-02 10:02:53.957789
268	XWFbqR_9fqc	Playlists	internal	2	12.50	27.00	58.30	2026-09-02 10:02:53.957789
269	XWFbqR_9fqc	Browse features	internal	1	6.30	27.00	58.30	2026-09-02 10:02:53.957789
270	XWFbqR_9fqc	Notifications	internal	1	6.30	27.00	58.30	2026-09-02 10:02:53.957789
360	bXetyvX2Mu8	Others	other	3	0.80	16.00	27.30	2026-09-03 08:49:33.548839
361	pHfj5VVN0Ew	Shorts Feed	feed	270	87.10	17.00	47.90	2026-09-03 08:52:31.076945
362	pHfj5VVN0Ew	YouTube Search	search	20	6.50	17.00	47.90	2026-09-03 08:52:31.076945
363	pHfj5VVN0Ew	Notifications	notifications	7	2.30	17.00	47.90	2026-09-03 08:52:31.076945
364	pHfj5VVN0Ew	Browse Features	browse	5	1.60	17.00	47.90	2026-09-03 08:52:31.076945
365	pHfj5VVN0Ew	Channel Pages	channel	5	1.60	17.00	47.90	2026-09-03 08:52:31.076945
366	pHfj5VVN0Ew	Others	other	3	1.00	17.00	47.90	2026-09-03 08:52:31.076945
367	dpTHfuBYClo	Shorts Feed	feed	382	75.80	18.00	37.50	2026-09-03 08:54:48.143719
368	dpTHfuBYClo	YouTube Search	search	97	19.30	18.00	37.50	2026-09-03 08:54:48.143719
369	dpTHfuBYClo	Browse Features	browse	15	3.00	18.00	37.50	2026-09-03 08:54:48.143719
370	dpTHfuBYClo	Suggested Videos	suggested	4	0.80	18.00	37.50	2026-09-03 08:54:48.143719
371	dpTHfuBYClo	Channel Pages	channel	2	0.40	18.00	37.50	2026-09-03 08:54:48.143719
372	dpTHfuBYClo	Others	other	4	0.80	18.00	37.50	2026-09-03 08:54:48.143719
296	OkWbChCIb04	Shorts Feed	feed	33	67.40	16.00	24.20	2026-09-02 10:43:00.55935
297	OkWbChCIb04	YouTube Search	search	5	10.20	16.00	24.20	2026-09-02 10:43:00.55935
298	OkWbChCIb04	Browse Features	browse	4	8.20	16.00	24.20	2026-09-02 10:43:00.55935
299	OkWbChCIb04	Channel Pages	channel	4	8.20	16.00	24.20	2026-09-02 10:43:00.55935
300	OkWbChCIb04	Notifications	notifications	3	6.10	16.00	24.20	2026-09-02 10:43:00.55935
306	2jcdStwq2yY	Browse Features	browse	62	80.50	22.00	88.50	2026-09-02 11:22:03.546173
307	2jcdStwq2yY	Channel Pages	channel	6	7.80	22.00	88.50	2026-09-02 11:22:03.546173
241	0jstRcQmAro	Channel pages	channel_pages	10	33.30	\N	\N	2026-09-02 09:46:02.751285
242	0jstRcQmAro	Browse features	browse_features	4	13.30	\N	\N	2026-09-02 09:46:02.751285
243	0jstRcQmAro	YouTube search	youtube_search	4	13.30	\N	\N	2026-09-02 09:46:02.751285
244	0jstRcQmAro	Shorts feed	shorts_feed	4	13.30	\N	\N	2026-09-02 09:46:02.751285
245	0jstRcQmAro	Other YouTube features	other_youtube_features	3	10.00	\N	\N	2026-09-02 09:46:02.751285
246	0jstRcQmAro	Others	others	5	16.70	\N	\N	2026-09-02 09:46:02.751285
308	2jcdStwq2yY	Shorts Feed	feed	6	7.80	22.00	88.50	2026-09-02 11:22:03.546173
309	2jcdStwq2yY	Notifications	notifications	3	3.90	22.00	88.50	2026-09-02 11:22:03.546173
310	2jcdStwq2yY	Direct or unknown	direct	0	0.00	22.00	88.50	2026-09-02 11:22:03.546173
316	rg5iPj-249o	Shorts feed	shorts_feed	54	59.30	25.00	26.70	2026-09-02 14:58:55.032747
317	rg5iPj-249o	YouTube search	youtube_search	21	23.10	25.00	26.70	2026-09-02 14:58:55.032747
318	rg5iPj-249o	Channel pages	channel_pages	9	9.90	25.00	26.70	2026-09-02 14:58:55.032747
319	rg5iPj-249o	Browse features	browse_features	4	4.40	25.00	26.70	2026-09-02 14:58:55.032747
320	rg5iPj-249o	Notifications	notifications	2	2.20	25.00	26.70	2026-09-02 14:58:55.032747
321	rg5iPj-249o	Others	others	1	1.10	25.00	26.70	2026-09-02 14:58:55.032747
328	Ay9K30yrg8Y	Shorts feed	shorts_feed	387	88.20	10.00	25.20	2026-09-02 15:27:50.633383
272	Pwp0zPAY6Y4	Channel pages	internal	11	47.80	20.00	57.90	2026-09-02 10:03:13.106027
273	Pwp0zPAY6Y4	Shorts feed	internal	8	34.80	20.00	57.90	2026-09-02 10:03:13.106027
274	Pwp0zPAY6Y4	Playlists	internal	2	8.70	20.00	57.90	2026-09-02 10:03:13.106027
275	Pwp0zPAY6Y4	Browse features	internal	1	4.40	20.00	57.90	2026-09-02 10:03:13.106027
276	Pwp0zPAY6Y4	Notifications	internal	1	4.40	20.00	57.90	2026-09-02 10:03:13.106027
329	Ay9K30yrg8Y	YouTube search	youtube_search	31	7.10	10.00	25.20	2026-09-02 15:27:50.633383
334	lmbndk-Db-Q	Shorts feed	shorts_feed	131	89.10	13.00	32.00	2026-09-02 21:49:28.223132
165	UTeogxHwnPw	Shorts Feed	feed	60	75.00	17.00	16.70	2026-09-02 09:25:42.138615
166	UTeogxHwnPw	Channel Pages	channel	7	8.80	17.00	16.70	2026-09-02 09:25:42.138615
167	UTeogxHwnPw	YouTube Search	search	6	7.50	17.00	16.70	2026-09-02 09:25:42.138615
168	UTeogxHwnPw	Browse Features	browse	3	3.80	17.00	16.70	2026-09-02 09:25:42.138615
169	UTeogxHwnPw	External	external	2	2.50	17.00	16.70	2026-09-02 09:25:42.138615
170	UTeogxHwnPw	Others	other	2	2.50	17.00	16.70	2026-09-02 09:25:42.138615
171	zdOSsbqouKE	Shorts Feed	feed	34	41.50	14.00	23.70	2026-09-02 09:25:43.634893
172	zdOSsbqouKE	YouTube Search	search	26	31.70	14.00	23.70	2026-09-02 09:25:43.634893
173	zdOSsbqouKE	Browse Features	browse	10	12.20	14.00	23.70	2026-09-02 09:25:43.634893
174	zdOSsbqouKE	Channel Pages	channel	7	8.50	14.00	23.70	2026-09-02 09:25:43.634893
175	zdOSsbqouKE	Suggested Videos	suggested	2	2.40	14.00	23.70	2026-09-02 09:25:43.634893
176	zdOSsbqouKE	Others	other	3	3.70	14.00	23.70	2026-09-02 09:25:43.634893
177	12BKLbv0Eso	YouTube Search	search	1434	83.80	28.00	62.40	2026-09-02 09:25:45.151529
178	12BKLbv0Eso	Shorts Feed	feed	198	11.60	28.00	62.40	2026-09-02 09:25:45.151529
179	12BKLbv0Eso	Channel Pages	channel	31	1.80	28.00	62.40	2026-09-02 09:25:45.151529
180	12BKLbv0Eso	External	external	17	1.00	28.00	62.40	2026-09-02 09:25:45.151529
181	12BKLbv0Eso	Other YouTube Features	other	15	0.90	28.00	62.40	2026-09-02 09:25:45.151529
182	12BKLbv0Eso	Others	other	16	1.00	28.00	62.40	2026-09-02 09:25:45.151529
183	XM1AzgVMeqk	YouTube Search	search	259	53.60	24.00	45.30	2026-09-02 09:25:46.312192
184	XM1AzgVMeqk	Shorts Feed	feed	186	38.50	24.00	45.30	2026-09-02 09:25:46.312192
185	XM1AzgVMeqk	Channel Pages	channel	17	3.50	24.00	45.30	2026-09-02 09:25:46.312192
186	XM1AzgVMeqk	Browse Features	browse	14	2.90	24.00	45.30	2026-09-02 09:25:46.312192
187	XM1AzgVMeqk	Suggested Videos	suggested	4	0.80	24.00	45.30	2026-09-02 09:25:46.312192
188	XM1AzgVMeqk	Others	other	3	0.60	24.00	45.30	2026-09-02 09:25:46.312192
189	nJNR60Ms1BE	YouTube Search	search	55	57.30	24.00	31.50	2026-09-02 09:25:47.152763
190	nJNR60Ms1BE	Channel Pages	channel	21	21.90	24.00	31.50	2026-09-02 09:25:47.152763
191	nJNR60Ms1BE	Shorts Feed	feed	17	17.70	24.00	31.50	2026-09-02 09:25:47.152763
192	nJNR60Ms1BE	Browse Features	browse	1	1.00	24.00	31.50	2026-09-02 09:25:47.152763
193	nJNR60Ms1BE	Other YouTube Features	other	1	1.00	24.00	31.50	2026-09-02 09:25:47.152763
194	nJNR60Ms1BE	Others	other	1	1.00	24.00	31.50	2026-09-02 09:25:47.152763
195	_A5Idj7SddI	Channel Pages	channel	7	25.90	16.00	54.60	2026-09-02 09:25:47.534266
196	_A5Idj7SddI	Browse Features	browse	6	22.20	16.00	54.60	2026-09-02 09:25:47.534266
197	_A5Idj7SddI	YouTube Search	search	6	22.20	16.00	54.60	2026-09-02 09:25:47.534266
198	_A5Idj7SddI	Shorts Feed	feed	3	11.10	16.00	54.60	2026-09-02 09:25:47.534266
199	_A5Idj7SddI	Suggested Videos	suggested	2	7.40	16.00	54.60	2026-09-02 09:25:47.534266
200	_A5Idj7SddI	Others	other	3	11.10	16.00	54.60	2026-09-02 09:25:47.534266
201	BJ5lJob_sDU	Channel Pages	channel	11	35.50	21.00	34.50	2026-09-02 09:25:47.870198
202	BJ5lJob_sDU	Shorts Feed	feed	9	29.00	21.00	34.50	2026-09-02 09:25:47.870198
203	BJ5lJob_sDU	Browse Features	browse	7	22.60	21.00	34.50	2026-09-02 09:25:47.870198
204	BJ5lJob_sDU	YouTube Search	search	3	9.70	21.00	34.50	2026-09-02 09:25:47.870198
205	BJ5lJob_sDU	Other YouTube Features	other	1	3.20	21.00	34.50	2026-09-02 09:25:47.870198
894	LQ7ttolwjJQ	Channel pages	channel	3	4.40	15.00	20.00	2026-09-07 10:50:43.305672
895	LQ7ttolwjJQ	Browse features	browse	2	2.90	10.00	12.00	2026-09-07 10:50:43.305672
896	LQ7ttolwjJQ	YouTube search	search	2	2.90	18.00	25.00	2026-09-07 10:50:43.305672
897	LQ7ttolwjJQ	Notifications	external	2	2.90	8.00	10.00	2026-09-07 10:50:43.305672
670	dudb29Xqo60	YouTube search	search	431	61.60	16.00	48.20	2026-09-06 08:53:13.551357
671	dudb29Xqo60	Shorts feed	feed	202	28.90	16.00	48.20	2026-09-06 08:53:13.551357
672	dudb29Xqo60	Channel pages	channel	34	4.90	16.00	48.20	2026-09-06 08:53:13.551357
673	dudb29Xqo60	External	external	18	2.60	16.00	48.20	2026-09-06 08:53:13.551357
674	dudb29Xqo60	Browse features	browse	10	1.40	16.00	48.20	2026-09-06 08:53:13.551357
675	dudb29Xqo60	Others	other	4	0.60	16.00	48.20	2026-09-06 08:53:13.551357
385	sHwtsGShqjE	Shorts feed	feed	429	86.50	\N	\N	2026-09-03 10:11:18.411369
386	sHwtsGShqjE	YouTube search	search	51	10.30	\N	\N	2026-09-03 10:11:18.411369
387	sHwtsGShqjE	Other YouTube features	other	5	1.00	\N	\N	2026-09-03 10:11:18.411369
388	sHwtsGShqjE	Browse features	browse	3	0.60	\N	\N	2026-09-03 10:11:18.411369
389	sHwtsGShqjE	Channel pages	browse	3	0.60	\N	\N	2026-09-03 10:11:18.411369
390	sHwtsGShqjE	Others	other	5	1.00	\N	\N	2026-09-03 10:11:18.411369
391	Wyt0zC-zadM	Shorts feed	feed	87	62.60	\N	\N	2026-09-03 12:28:17.67752
392	Wyt0zC-zadM	Browse features	browse	30	21.60	\N	\N	2026-09-03 12:28:17.67752
393	Wyt0zC-zadM	YouTube search	search	14	10.10	\N	\N	2026-09-03 12:28:17.67752
394	Wyt0zC-zadM	Channel pages	channel	2	1.40	\N	\N	2026-09-03 12:28:17.67752
395	Wyt0zC-zadM	Other YouTube features	other	2	1.40	\N	\N	2026-09-03 12:28:17.67752
396	Wyt0zC-zadM	Others	other	4	2.90	\N	\N	2026-09-03 12:28:17.67752
397	JRrvbkvRyiI	Shorts feed	feed	410	89.70	\N	\N	2026-09-03 12:45:38.189925
398	JRrvbkvRyiI	YouTube search	search	32	7.00	\N	\N	2026-09-03 12:45:38.189925
399	JRrvbkvRyiI	Browse features	browse	4	0.90	\N	\N	2026-09-03 12:45:38.189925
400	JRrvbkvRyiI	Channel pages	channel	4	0.90	\N	\N	2026-09-03 12:45:38.189925
401	JRrvbkvRyiI	Other YouTube features	other	4	0.90	\N	\N	2026-09-03 12:45:38.189925
402	JRrvbkvRyiI	Others	other	3	0.60	\N	\N	2026-09-03 12:45:38.189925
403	pTiZBob0vWA	Shorts feed	feed	378	80.30	\N	\N	2026-09-03 13:23:31.162254
404	pTiZBob0vWA	YouTube search	search	75	15.90	\N	\N	2026-09-03 13:23:31.162254
405	pTiZBob0vWA	Other YouTube features	other	7	1.50	\N	\N	2026-09-03 13:23:31.162254
406	pTiZBob0vWA	Channel pages	channel	4	0.90	\N	\N	2026-09-03 13:23:31.162254
407	pTiZBob0vWA	External	external	3	0.60	\N	\N	2026-09-03 13:23:31.162254
408	pTiZBob0vWA	Others	other	4	0.90	\N	\N	2026-09-03 13:23:31.162254
409	F6g5hMAUH6A	Shorts feed	feed	145	75.90	\N	\N	2026-09-03 13:36:14.415812
410	F6g5hMAUH6A	YouTube search	search	30	15.70	\N	\N	2026-09-03 13:36:14.415812
411	F6g5hMAUH6A	Browse features	browse	8	4.20	\N	\N	2026-09-03 13:36:14.415812
412	F6g5hMAUH6A	Channel pages	channel	4	2.10	\N	\N	2026-09-03 13:36:14.415812
413	F6g5hMAUH6A	Other YouTube features	other	2	1.00	\N	\N	2026-09-03 13:36:14.415812
414	F6g5hMAUH6A	Others	other	2	1.00	\N	\N	2026-09-03 13:36:14.415812
415	durkT5BI9-0	Shorts feed	feed	184	69.20	\N	\N	2026-09-03 14:13:12.403346
416	durkT5BI9-0	YouTube search	search	75	28.20	\N	\N	2026-09-03 14:13:12.403346
417	durkT5BI9-0	Channel pages	channel	3	1.10	\N	\N	2026-09-03 14:13:12.403346
418	durkT5BI9-0	Browse features	browse	2	0.80	\N	\N	2026-09-03 14:13:12.403346
419	durkT5BI9-0	Other YouTube features	other	2	0.80	\N	\N	2026-09-03 14:13:12.403346
420	-ntsqYRrjic	Shorts feed	feed	385	49.00	\N	\N	2026-09-03 14:22:21.576395
421	-ntsqYRrjic	YouTube search	search	380	48.40	\N	\N	2026-09-03 14:22:21.576395
422	-ntsqYRrjic	Channel pages	channel	8	1.00	\N	\N	2026-09-03 14:22:21.576395
423	-ntsqYRrjic	Other YouTube features	other	5	0.60	\N	\N	2026-09-03 14:22:21.576395
424	-ntsqYRrjic	Browse features	browse	4	0.50	\N	\N	2026-09-03 14:22:21.576395
425	-ntsqYRrjic	Others	other	4	0.50	\N	\N	2026-09-03 14:22:21.576395
426	kQlrFbAzvro	YouTube search	search	2940	80.10	\N	\N	2026-09-03 14:34:36.771304
427	kQlrFbAzvro	Shorts feed	feed	547	14.90	\N	\N	2026-09-03 14:34:36.771304
428	kQlrFbAzvro	Browse features	browse	154	4.20	\N	\N	2026-09-03 14:34:36.771304
429	kQlrFbAzvro	Other YouTube features	other	18	0.50	\N	\N	2026-09-03 14:34:36.771304
430	kQlrFbAzvro	Channel pages	channel	4	0.10	\N	\N	2026-09-03 14:34:36.771304
431	kQlrFbAzvro	Others	other	7	0.20	\N	\N	2026-09-03 14:34:36.771304
1488	ZrY0tM9yPxQ	Shorts feed	feed	259	71.20	\N	\N	2026-09-13 00:39:03.743153
438	VkXC2gAxVvs	Shorts feed	feed	365	89.90	\N	\N	2026-09-03 21:29:21.003798
439	VkXC2gAxVvs	YouTube search	search	27	6.70	\N	\N	2026-09-03 21:29:21.003798
440	VkXC2gAxVvs	Channel pages	channel	5	1.20	\N	\N	2026-09-03 21:29:21.003798
441	VkXC2gAxVvs	Browse features	browse	4	1.00	\N	\N	2026-09-03 21:29:21.003798
442	VkXC2gAxVvs	Other YouTube features	other	4	1.00	\N	\N	2026-09-03 21:29:21.003798
443	VkXC2gAxVvs	Others	other	1	0.20	\N	\N	2026-09-03 21:29:21.003798
444	QC45KrzAuLs	Shorts feed	feed	477	92.40	\N	\N	2026-09-03 21:44:00.314367
445	QC45KrzAuLs	YouTube search	search	26	5.00	\N	\N	2026-09-03 21:44:00.314367
446	QC45KrzAuLs	Other YouTube features	other	4	0.80	\N	\N	2026-09-03 21:44:00.314367
447	QC45KrzAuLs	Channel pages	channel	3	0.60	\N	\N	2026-09-03 21:44:00.314367
448	QC45KrzAuLs	Browse features	browse	2	0.40	\N	\N	2026-09-03 21:44:00.314367
449	QC45KrzAuLs	Others	other	4	0.80	\N	\N	2026-09-03 21:44:00.314367
1489	ZrY0tM9yPxQ	YouTube search	search	58	15.90	\N	\N	2026-09-13 00:39:03.743153
1490	ZrY0tM9yPxQ	Channel pages	channel	25	6.90	\N	\N	2026-09-13 00:39:03.743153
1491	ZrY0tM9yPxQ	Browse features	browse	18	5.00	\N	\N	2026-09-13 00:39:03.743153
1492	ZrY0tM9yPxQ	Notifications	other	3	0.80	\N	\N	2026-09-13 00:39:03.743153
1493	ZrY0tM9yPxQ	Others	other	1	0.30	\N	\N	2026-09-13 00:39:03.743153
450	gNgwb1lmKL8	Shorts feed	feed	795	81.00	\N	\N	2026-09-03 22:06:49.206096
451	gNgwb1lmKL8	YouTube search	search	159	16.20	\N	\N	2026-09-03 22:06:49.206096
452	gNgwb1lmKL8	Channel pages	channel	11	1.10	\N	\N	2026-09-03 22:06:49.206096
453	gNgwb1lmKL8	Browse features	browse	6	0.60	\N	\N	2026-09-03 22:06:49.206096
454	gNgwb1lmKL8	Other YouTube features	other	6	0.60	\N	\N	2026-09-03 22:06:49.206096
455	gNgwb1lmKL8	Others	other	5	0.50	\N	\N	2026-09-03 22:06:49.206096
456	XlOAFuUr7F4	Shorts feed	feed	369	76.60	\N	\N	2026-09-03 22:31:30.815574
457	XlOAFuUr7F4	YouTube search	search	69	14.30	\N	\N	2026-09-03 22:31:30.815574
458	XlOAFuUr7F4	Channel pages	channel	17	3.50	\N	\N	2026-09-03 22:31:30.815574
459	XlOAFuUr7F4	Browse features	browse	10	2.10	\N	\N	2026-09-03 22:31:30.815574
460	XlOAFuUr7F4	Playlists	playlist	8	1.70	\N	\N	2026-09-03 22:31:30.815574
461	XlOAFuUr7F4	Others	other	9	1.90	\N	\N	2026-09-03 22:31:30.815574
462	d-p-YuOjU-8	YouTube search	search	245	81.40	\N	\N	2026-09-03 22:47:40.537674
463	d-p-YuOjU-8	Shorts feed	feed	39	13.00	\N	\N	2026-09-03 22:47:40.537674
464	d-p-YuOjU-8	Channel pages	channel	12	4.00	\N	\N	2026-09-03 22:47:40.537674
465	d-p-YuOjU-8	Other YouTube features	other	3	1.00	\N	\N	2026-09-03 22:47:40.537674
466	d-p-YuOjU-8	Suggested videos	suggested	1	0.30	\N	\N	2026-09-03 22:47:40.537674
467	d-p-YuOjU-8	Others	other	1	0.30	\N	\N	2026-09-03 22:47:40.537674
468	7L-wWpll_GU	Shorts feed	feed	50	51.00	\N	\N	2026-09-03 22:59:23.098487
469	7L-wWpll_GU	YouTube search	search	32	32.70	\N	\N	2026-09-03 22:59:23.098487
470	7L-wWpll_GU	Browse features	browse	6	6.10	\N	\N	2026-09-03 22:59:23.098487
471	7L-wWpll_GU	Channel pages	channel	6	6.10	\N	\N	2026-09-03 22:59:23.098487
472	7L-wWpll_GU	Other YouTube features	other	2	2.00	\N	\N	2026-09-03 22:59:23.098487
473	7L-wWpll_GU	Others	other	2	2.00	\N	\N	2026-09-03 22:59:23.098487
480	pszcrf0uTbQ	YouTube search	search	5500	77.80	\N	\N	2026-09-04 09:31:55.178282
481	pszcrf0uTbQ	Shorts feed	feed	1025	14.50	\N	\N	2026-09-04 09:31:55.178282
482	pszcrf0uTbQ	Browse features	browse	233	3.30	\N	\N	2026-09-04 09:31:55.178282
483	pszcrf0uTbQ	Other YouTube features	other	113	1.60	\N	\N	2026-09-04 09:31:55.178282
484	pszcrf0uTbQ	Channel pages	channel	64	0.90	\N	\N	2026-09-04 09:31:55.178282
485	pszcrf0uTbQ	Others	other	127	1.80	\N	\N	2026-09-04 09:31:55.178282
486	EDNdXwv7W64	YouTube search	search	704	56.00	\N	\N	2026-09-04 09:55:24.289926
487	EDNdXwv7W64	Shorts feed	feed	425	33.80	\N	\N	2026-09-04 09:55:24.289926
488	EDNdXwv7W64	Related Shorts	related	45	3.60	\N	\N	2026-09-04 09:55:24.289926
489	EDNdXwv7W64	External	external	31	2.50	\N	\N	2026-09-04 09:55:24.289926
490	EDNdXwv7W64	Channel pages	channel	23	1.80	\N	\N	2026-09-04 09:55:24.289926
491	EDNdXwv7W64	Others	other	30	2.40	\N	\N	2026-09-04 09:55:24.289926
492	DdMa3y_sImk	Browse features	browse	181	56.00	\N	\N	2026-09-04 12:02:37.004788
493	DdMa3y_sImk	Shorts feed	feed	122	37.80	\N	\N	2026-09-04 12:02:37.004788
494	DdMa3y_sImk	YouTube search	search	8	2.50	\N	\N	2026-09-04 12:02:37.004788
495	DdMa3y_sImk	Channel pages	channel	5	1.60	\N	\N	2026-09-04 12:02:37.004788
496	DdMa3y_sImk	Notifications	notifications	4	1.20	\N	\N	2026-09-04 12:02:37.004788
497	DdMa3y_sImk	Others	other	3	0.90	\N	\N	2026-09-04 12:02:37.004788
498	YFnY2guPlxg	Shorts feed	feed	383	85.70	\N	\N	2026-09-04 12:04:52.149361
499	YFnY2guPlxg	YouTube search	search	50	11.20	\N	\N	2026-09-04 12:04:52.149361
500	YFnY2guPlxg	Browse features	browse	5	1.10	\N	\N	2026-09-04 12:04:52.149361
501	YFnY2guPlxg	Other YouTube features	other	5	1.10	\N	\N	2026-09-04 12:04:52.149361
502	YFnY2guPlxg	Channel pages	channel	2	0.50	\N	\N	2026-09-04 12:04:52.149361
503	YFnY2guPlxg	Others	other	2	0.40	\N	\N	2026-09-04 12:04:52.149361
504	noF6FnkgYmE	Shorts feed	feed	72	70.60	\N	\N	2026-09-04 12:16:10.255319
505	noF6FnkgYmE	YouTube search	search	14	13.70	\N	\N	2026-09-04 12:16:10.255319
506	noF6FnkgYmE	Browse features	browse	6	5.90	\N	\N	2026-09-04 12:16:10.255319
507	noF6FnkgYmE	Channel pages	channel	5	4.90	\N	\N	2026-09-04 12:16:10.255319
508	noF6FnkgYmE	Other YouTube features	other	3	2.90	\N	\N	2026-09-04 12:16:10.255319
509	noF6FnkgYmE	Others	other	2	2.00	\N	\N	2026-09-04 12:16:10.255319
510	tyxuLrd-xo4	Shorts feed	feed	212	91.40	\N	\N	2026-09-04 12:33:43.388322
511	tyxuLrd-xo4	YouTube search	search	15	6.50	\N	\N	2026-09-04 12:33:43.388322
512	tyxuLrd-xo4	Browse features	browse	2	0.90	\N	\N	2026-09-04 12:33:43.388322
513	tyxuLrd-xo4	Channel pages	channel	1	0.40	\N	\N	2026-09-04 12:33:43.388322
514	tyxuLrd-xo4	Suggested videos	suggested	1	0.40	\N	\N	2026-09-04 12:33:43.388322
515	tyxuLrd-xo4	Others	other	1	0.40	\N	\N	2026-09-04 12:33:43.388322
516	UzWyYR6WM6U	Shorts feed	feed	380	93.40	\N	\N	2026-09-04 12:56:32.962168
517	UzWyYR6WM6U	YouTube search	search	19	4.70	\N	\N	2026-09-04 12:56:32.962168
518	UzWyYR6WM6U	Browse features	browse	3	0.70	\N	\N	2026-09-04 12:56:32.962168
519	UzWyYR6WM6U	Channel pages	channel	1	0.30	\N	\N	2026-09-04 12:56:32.962168
520	UzWyYR6WM6U	Other YouTube features	other	1	0.30	\N	\N	2026-09-04 12:56:32.962168
521	UzWyYR6WM6U	Others	other	3	0.70	\N	\N	2026-09-04 12:56:32.962168
522	3gSWKoBeqnw	Shorts feed	feed	313	92.30	\N	\N	2026-09-04 13:19:16.949153
523	3gSWKoBeqnw	YouTube search	search	17	5.00	\N	\N	2026-09-04 13:19:16.949153
524	3gSWKoBeqnw	Channel pages	channel	4	1.20	\N	\N	2026-09-04 13:19:16.949153
525	3gSWKoBeqnw	Browse features	browse	2	0.60	\N	\N	2026-09-04 13:19:16.949153
526	3gSWKoBeqnw	Other YouTube features	other	2	0.60	\N	\N	2026-09-04 13:19:16.949153
527	3gSWKoBeqnw	Others	other	1	0.30	\N	\N	2026-09-04 13:19:16.949153
528	impBBFcUinY	Shorts feed	feed	443	92.30	\N	\N	2026-09-04 13:33:07.646614
529	impBBFcUinY	YouTube search	search	24	5.00	\N	\N	2026-09-04 13:33:07.646614
530	impBBFcUinY	Channel pages	channel	6	1.20	\N	\N	2026-09-04 13:33:07.646614
531	impBBFcUinY	Browse features	browse	3	0.60	\N	\N	2026-09-04 13:33:07.646614
532	impBBFcUinY	Other YouTube features	other	3	0.60	\N	\N	2026-09-04 13:33:07.646614
533	impBBFcUinY	Others	other	1	0.30	\N	\N	2026-09-04 13:33:07.646614
664	atkvEdcPidM	YouTube search	search	114	55.10	14.00	34.70	2026-09-06 08:41:17.107595
665	atkvEdcPidM	Shorts feed	feed	75	36.20	14.00	34.70	2026-09-06 08:41:17.107595
666	atkvEdcPidM	Hashtag pages	browse	6	2.90	14.00	34.70	2026-09-06 08:41:17.107595
667	atkvEdcPidM	Channel pages	channel	5	2.40	14.00	34.70	2026-09-06 08:41:17.107595
668	atkvEdcPidM	Notifications	other	4	1.90	14.00	34.70	2026-09-06 08:41:17.107595
669	atkvEdcPidM	Others	other	3	1.40	14.00	34.70	2026-09-06 08:41:17.107595
540	kIrFARfeW5o	Shorts feed	feed	480	92.30	\N	\N	2026-09-04 13:52:08.871339
541	kIrFARfeW5o	YouTube search	search	26	5.00	\N	\N	2026-09-04 13:52:08.871339
542	kIrFARfeW5o	Channel pages	channel	6	1.20	\N	\N	2026-09-04 13:52:08.871339
543	kIrFARfeW5o	Browse features	browse	3	0.60	\N	\N	2026-09-04 13:52:08.871339
544	kIrFARfeW5o	Other YouTube features	other	3	0.60	\N	\N	2026-09-04 13:52:08.871339
545	kIrFARfeW5o	Others	other	2	0.30	\N	\N	2026-09-04 13:52:08.871339
676	9jXcNZyYza8	Shorts feed	feed	48	66.70	14.00	27.00	2026-09-06 09:14:07.3586
677	9jXcNZyYza8	YouTube search	search	9	12.50	14.00	27.00	2026-09-06 09:14:07.3586
678	9jXcNZyYza8	Channel pages	channel	8	11.10	14.00	27.00	2026-09-06 09:14:07.3586
679	9jXcNZyYza8	Browse features	browse	4	5.60	14.00	27.00	2026-09-06 09:14:07.3586
680	9jXcNZyYza8	Other YouTube features	other	2	2.80	14.00	27.00	2026-09-06 09:14:07.3586
681	9jXcNZyYza8	Others	other	1	1.40	14.00	27.00	2026-09-06 09:14:07.3586
898	LQ7ttolwjJQ	Others	other	1	1.40	7.00	8.00	2026-09-07 10:50:43.305672
1463	rrTB_XW3pWA	YouTube search	search	37	58.70	\N	\N	2026-09-12 23:25:09.52654
1464	rrTB_XW3pWA	Channel pages	channel	8	12.70	\N	\N	2026-09-12 23:25:09.52654
1465	rrTB_XW3pWA	Shorts feed	feed	5	7.90	\N	\N	2026-09-12 23:25:09.52654
1466	rrTB_XW3pWA	Notifications	other	4	6.40	\N	\N	2026-09-12 23:25:09.52654
687	eC_j1wlFJBw	Shorts feed	feed	15	51.70	11.00	19.00	2026-09-06 09:30:05.833783
688	eC_j1wlFJBw	Browse features	browse	6	20.70	11.00	19.00	2026-09-06 09:30:05.833783
689	eC_j1wlFJBw	Channel pages	channel	5	17.20	11.00	19.00	2026-09-06 09:30:05.833783
690	eC_j1wlFJBw	YouTube search	search	2	6.90	11.00	19.00	2026-09-06 09:30:05.833783
691	eC_j1wlFJBw	Notifications	notifications	1	3.50	11.00	19.00	2026-09-06 09:30:05.833783
692	Q-IS9K8g294	Shorts feed	feed	199	82.20	13.00	25.10	2026-09-06 09:52:18.827983
693	Q-IS9K8g294	YouTube search	search	23	9.50	13.00	25.10	2026-09-06 09:52:18.827983
564	FwuhJ23l7R4	YouTube search	search	170	53.30	\N	\N	2026-09-04 15:17:53.707086
565	FwuhJ23l7R4	Hashtag pages	hashtag	70	21.90	\N	\N	2026-09-04 15:17:53.707086
566	FwuhJ23l7R4	Channel pages	channel	28	8.80	\N	\N	2026-09-04 15:17:53.707086
567	FwuhJ23l7R4	Shorts feed	feed	28	8.80	\N	\N	2026-09-04 15:17:53.707086
568	FwuhJ23l7R4	Browse features	browse	11	3.50	\N	\N	2026-09-04 15:17:53.707086
569	FwuhJ23l7R4	Others	other	12	3.80	\N	\N	2026-09-04 15:17:53.707086
694	Q-IS9K8g294	Browse features	browse	11	4.60	13.00	25.10	2026-09-06 09:52:18.827983
695	Q-IS9K8g294	Channel pages	channel	7	2.90	13.00	25.10	2026-09-06 09:52:18.827983
696	Q-IS9K8g294	Other YouTube features	other	2	0.80	13.00	25.10	2026-09-06 09:52:18.827983
1467	rrTB_XW3pWA	Browse features	browse	3	4.80	\N	\N	2026-09-12 23:25:09.52654
1118	_6qJfWvvWJo	Shorts feed	feed	364	83.70	\N	\N	2026-09-10 20:01:40.055997
1119	_6qJfWvvWJo	YouTube search	search	10	2.30	\N	\N	2026-09-10 20:01:40.055997
1120	_6qJfWvvWJo	Channel pages	channel	6	1.40	\N	\N	2026-09-10 20:01:40.055997
1121	_6qJfWvvWJo	Notifications	other	8	1.80	\N	\N	2026-09-10 20:01:40.055997
1122	_6qJfWvvWJo	Browse features	browse	2	0.50	\N	\N	2026-09-10 20:01:40.055997
703	p03EyeJlM-k	Shorts feed	feed	64	38.80	22.00	26.50	2026-09-06 12:19:14.187832
704	p03EyeJlM-k	Browse features	browse	61	37.00	22.00	26.50	2026-09-06 12:19:14.187832
705	p03EyeJlM-k	YouTube search	search	14	8.50	22.00	26.50	2026-09-06 12:19:14.187832
706	p03EyeJlM-k	Other YouTube features	other	11	6.70	22.00	26.50	2026-09-06 12:19:14.187832
707	p03EyeJlM-k	Channel pages	channel	9	5.50	22.00	26.50	2026-09-06 12:19:14.187832
708	p03EyeJlM-k	Others	other	6	3.60	22.00	26.50	2026-09-06 12:19:14.187832
587	tO8vEcWUFXs	Shorts feed	feed	163	82.70	12.00	26.50	2026-09-05 19:35:09.745882
588	tO8vEcWUFXs	YouTube search	search	28	14.20	12.00	26.50	2026-09-05 19:35:09.745882
589	tO8vEcWUFXs	Browse features	browse	2	1.00	12.00	26.50	2026-09-05 19:35:09.745882
590	tO8vEcWUFXs	Channel pages	channel	2	1.00	12.00	26.50	2026-09-05 19:35:09.745882
591	tO8vEcWUFXs	Hashtag pages	hashtag	2	1.00	12.00	26.50	2026-09-05 19:35:09.745882
592	m1qgKExs2BY	YouTube search	search	164	64.10	16.00	42.70	2026-09-05 19:53:35.380044
593	m1qgKExs2BY	Shorts feed	feed	80	31.30	16.00	42.70	2026-09-05 19:53:35.380044
594	m1qgKExs2BY	Browse features	browse	7	2.70	16.00	42.70	2026-09-05 19:53:35.380044
595	m1qgKExs2BY	Channel pages	channel	2	0.80	16.00	42.70	2026-09-05 19:53:35.380044
596	m1qgKExs2BY	Suggested videos	suggested	2	0.80	16.00	42.70	2026-09-05 19:53:35.380044
597	m1qgKExs2BY	Others	other	1	0.40	16.00	42.70	2026-09-05 19:53:35.380044
598	_vTmJ79_4ho	Shorts feed	feed	71	77.20	10.00	20.80	2026-09-05 20:12:48.727333
599	_vTmJ79_4ho	Browse features	browse	5	5.40	10.00	20.80	2026-09-05 20:12:48.727333
600	_vTmJ79_4ho	Suggested videos	suggested	5	5.40	10.00	20.80	2026-09-05 20:12:48.727333
601	_vTmJ79_4ho	Notifications	notifications	4	4.40	10.00	20.80	2026-09-05 20:12:48.727333
602	_vTmJ79_4ho	YouTube search	search	3	3.30	10.00	20.80	2026-09-05 20:12:48.727333
603	_vTmJ79_4ho	Others	other	4	4.40	10.00	20.80	2026-09-05 20:12:48.727333
709	229XDzxoc4g	Shorts feed	feed	288	87.40	16.00	25.60	2026-09-06 13:26:52.660817
710	229XDzxoc4g	YouTube search	search	21	6.30	16.00	25.60	2026-09-06 13:26:52.660817
1123	_6qJfWvvWJo	Others	other	2	0.50	\N	\N	2026-09-10 20:01:40.055997
711	229XDzxoc4g	Channel pages	channel	10	3.00	16.00	25.60	2026-09-06 13:26:52.660817
712	229XDzxoc4g	Other YouTube features	other	5	1.50	16.00	25.60	2026-09-06 13:26:52.660817
713	229XDzxoc4g	Browse features	browse	2	0.60	16.00	25.60	2026-09-06 13:26:52.660817
714	229XDzxoc4g	Others	other	4	1.20	16.00	25.60	2026-09-06 13:26:52.660817
715	j4CtPMW-1Q4	Shorts feed	feed	56	45.50	\N	\N	2026-09-06 13:43:57.675416
716	j4CtPMW-1Q4	YouTube search	search	50	40.70	\N	\N	2026-09-06 13:43:57.675416
717	j4CtPMW-1Q4	Browse features	browse	8	6.50	\N	\N	2026-09-06 13:43:57.675416
718	j4CtPMW-1Q4	Channel pages	channel	7	5.70	\N	\N	2026-09-06 13:43:57.675416
719	j4CtPMW-1Q4	Other YouTube features	other	1	0.80	\N	\N	2026-09-06 13:43:57.675416
720	j4CtPMW-1Q4	Others	other	1	0.80	\N	\N	2026-09-06 13:43:57.675416
899	zqqcLDVZxR8	Shorts feed	feed	288	88.90	9.50	16.80	2026-09-07 10:57:07.066385
900	zqqcLDVZxR8	YouTube search	search	23	7.10	14.00	25.00	2026-09-07 10:57:07.066385
901	zqqcLDVZxR8	Browse features	browse	4	1.20	8.00	10.00	2026-09-07 10:57:07.066385
902	zqqcLDVZxR8	Channel pages	channel	4	1.20	12.00	15.00	2026-09-07 10:57:07.066385
903	zqqcLDVZxR8	Other YouTube features	other	3	0.90	7.00	8.00	2026-09-07 10:57:07.066385
904	zqqcLDVZxR8	Others	other	2	0.60	6.00	7.00	2026-09-07 10:57:07.066385
916	YaAKtkecoRc	Shorts feed	feed	384	94.60	12.00	32.20	2026-09-08 11:27:20.802552
917	YaAKtkecoRc	YouTube search	search	16	3.90	12.00	32.20	2026-09-08 11:27:20.802552
918	YaAKtkecoRc	Browse features	browse	3	0.70	12.00	32.20	2026-09-08 11:27:20.802552
919	YaAKtkecoRc	Channel pages	channel	1	0.30	12.00	32.20	2026-09-08 11:27:20.802552
731	iLZVyccaTJs	Shorts feed	feed	276	89.90	16.00	39.20	2026-09-06 13:51:03.028232
732	iLZVyccaTJs	Channel pages	channel	16	5.20	16.00	39.20	2026-09-06 13:51:03.028232
733	iLZVyccaTJs	YouTube search	search	9	2.90	16.00	39.20	2026-09-06 13:51:03.028232
734	iLZVyccaTJs	Browse features	browse	4	1.30	16.00	39.20	2026-09-06 13:51:03.028232
735	iLZVyccaTJs	Other YouTube features	other	2	0.70	16.00	39.20	2026-09-06 13:51:03.028232
736	xBun0zPGZDA	Shorts feed	feed	407	80.60	\N	\N	2026-09-06 15:05:42.270667
737	xBun0zPGZDA	YouTube search	search	52	10.30	\N	\N	2026-09-06 15:05:42.270667
738	xBun0zPGZDA	Channel pages	channel	34	6.90	\N	\N	2026-09-06 15:05:42.270667
739	xBun0zPGZDA	Other YouTube features	other	5	1.00	\N	\N	2026-09-06 15:05:42.270667
740	xBun0zPGZDA	Browse features	browse	4	0.80	\N	\N	2026-09-06 15:05:42.270667
741	xBun0zPGZDA	Others	other	2	0.40	\N	\N	2026-09-06 15:05:42.270667
920	YaAKtkecoRc	Other YouTube features	other	2	0.50	12.00	32.20	2026-09-08 11:27:20.802552
1468	rrTB_XW3pWA	Others	other	6	9.50	\N	\N	2026-09-12 23:25:09.52654
1494	hiP5k2gClN0	YouTube search	search	382	53.50	\N	\N	2026-09-13 00:39:10.017376
1495	hiP5k2gClN0	Browse features	browse	112	15.70	\N	\N	2026-09-13 00:39:10.017376
1496	hiP5k2gClN0	Shorts feed	feed	100	14.00	\N	\N	2026-09-13 00:39:10.017376
1497	hiP5k2gClN0	Channel pages	channel	60	8.40	\N	\N	2026-09-13 00:39:10.017376
1498	hiP5k2gClN0	Notifications	other	35	4.90	\N	\N	2026-09-13 00:39:10.017376
1499	hiP5k2gClN0	Others	other	25	3.50	\N	\N	2026-09-13 00:39:10.017376
970	D4KiNRb7UTk	Shorts feed	feed	280	50.00	27.00	42.50	2026-09-09 16:51:44.575471
971	D4KiNRb7UTk	YouTube search	search	140	25.00	32.00	48.00	2026-09-09 16:51:44.575471
972	D4KiNRb7UTk	Browse features	browse	70	12.50	22.00	35.00	2026-09-09 16:51:44.575471
973	D4KiNRb7UTk	Channel pages	channel	45	8.00	20.00	30.00	2026-09-09 16:51:44.575471
974	D4KiNRb7UTk	External	external	15	3.00	18.00	20.00	2026-09-09 16:51:44.575471
975	D4KiNRb7UTk	Others	other	11	1.50	15.00	10.00	2026-09-09 16:51:44.575471
1158	pl90QEsoKFk	Shorts feed	feed	443	89.00	\N	\N	2026-09-10 23:10:00.515414
1159	pl90QEsoKFk	YouTube search	search	33	6.60	\N	\N	2026-09-10 23:10:00.515414
1160	pl90QEsoKFk	Browse features	browse	12	2.40	\N	\N	2026-09-10 23:10:00.515414
1161	pl90QEsoKFk	Channel pages	channel	9	1.80	\N	\N	2026-09-10 23:10:00.515414
1162	pl90QEsoKFk	Notifications	other	1	0.20	\N	\N	2026-09-10 23:10:00.515414
1019	bLwR73Y2d0w	Shorts feed	youtube	89	89.00	0.00	0.00	2026-09-10 10:04:13.605465
1020	bLwR73Y2d0w	YouTube search	youtube	8	8.70	0.00	0.00	2026-09-10 10:04:13.605465
1021	bLwR73Y2d0w	Browse features	youtube	1	1.40	0.00	0.00	2026-09-10 10:04:13.605465
1022	bLwR73Y2d0w	Channel pages	youtube	0	0.50	0.00	0.00	2026-09-10 10:04:13.605465
1023	bLwR73Y2d0w	Other YouTube features	youtube	0	0.40	0.00	0.00	2026-09-10 10:04:13.605465
1169	mK2nGGZFRVI	Shorts feed	feed	168	100.00	\N	\N	2026-09-11 10:53:51.650803
1170	mK2nGGZFRVI	Browse features	browse	0	0.00	\N	\N	2026-09-11 10:53:51.650803
1171	mK2nGGZFRVI	YouTube search	search	0	0.00	\N	\N	2026-09-11 10:53:51.650803
1172	mK2nGGZFRVI	Channel pages	channel	0	0.00	\N	\N	2026-09-11 10:53:51.650803
1173	mK2nGGZFRVI	Suggested videos	other	0	0.00	\N	\N	2026-09-11 10:53:51.650803
1174	mK2nGGZFRVI	Others	other	0	0.00	\N	\N	2026-09-11 10:53:51.650803
1181	A2U9omXQ2go	Shorts feed	feed	168	100.00	\N	\N	2026-09-11 13:05:32.12302
1182	A2U9omXQ2go	Browse features	browse	0	0.00	\N	\N	2026-09-11 13:05:32.12302
1183	A2U9omXQ2go	YouTube search	search	0	0.00	\N	\N	2026-09-11 13:05:32.12302
1184	A2U9omXQ2go	Channel pages	channel	0	0.00	\N	\N	2026-09-11 13:05:32.12302
1185	A2U9omXQ2go	Suggested videos	other	0	0.00	\N	\N	2026-09-11 13:05:32.12302
1186	A2U9omXQ2go	Others	other	0	0.00	\N	\N	2026-09-11 13:05:32.12302
1052	DNIHqPqY3VM	Shorts feed	feed	393	89.90	\N	\N	2026-09-10 18:32:28.286194
1053	DNIHqPqY3VM	YouTube search	search	18	4.10	\N	\N	2026-09-10 18:32:28.286194
1054	DNIHqPqY3VM	Channel pages	channel	10	2.30	\N	\N	2026-09-10 18:32:28.286194
1055	DNIHqPqY3VM	Browse features	browse	8	1.80	\N	\N	2026-09-10 18:32:28.286194
1056	DNIHqPqY3VM	Other YouTube features	other	7	1.60	\N	\N	2026-09-10 18:32:28.286194
1057	DNIHqPqY3VM	Others	other	1	0.20	\N	\N	2026-09-10 18:32:28.286194
1469	kbLQ0kJ7pYQ	Shorts feed	feed	33	57.90	\N	\N	2026-09-13 00:04:05.182697
1470	kbLQ0kJ7pYQ	YouTube search	search	16	28.10	\N	\N	2026-09-13 00:04:05.182697
1471	kbLQ0kJ7pYQ	Notifications	other	4	7.00	\N	\N	2026-09-13 00:04:05.182697
1472	kbLQ0kJ7pYQ	Browse features	browse	3	5.30	\N	\N	2026-09-13 00:04:05.182697
1473	kbLQ0kJ7pYQ	Channel pages	channel	1	1.80	\N	\N	2026-09-13 00:04:05.182697
1500	DrhZsdeBj6k	YouTube search	search	29216	97.00	\N	\N	2026-09-13 00:39:55.370257
1130	NVbNJeWZ1Lo	Shorts feed	feed	33	32.70	\N	\N	2026-09-10 20:21:07.431547
1131	NVbNJeWZ1Lo	YouTube search	search	21	20.80	\N	\N	2026-09-10 20:21:07.431547
1132	NVbNJeWZ1Lo	Browse features	browse	16	15.80	\N	\N	2026-09-10 20:21:07.431547
1133	NVbNJeWZ1Lo	Notifications	other	15	14.90	\N	\N	2026-09-10 20:21:07.431547
1134	NVbNJeWZ1Lo	Channel pages	channel	13	12.90	\N	\N	2026-09-10 20:21:07.431547
940	Mp1WHa-CXfw	Shorts feed	feed	39	54.20	22.00	30.80	2026-09-09 14:55:59.402702
941	Mp1WHa-CXfw	YouTube search	search	16	22.20	22.00	30.80	2026-09-09 14:55:59.402702
942	Mp1WHa-CXfw	Browse features	browse	10	13.90	22.00	30.80	2026-09-09 14:55:59.402702
943	Mp1WHa-CXfw	Channel pages	channel	4	5.60	22.00	30.80	2026-09-09 14:55:59.402702
944	Mp1WHa-CXfw	Notifications	external	2	2.80	22.00	30.80	2026-09-09 14:55:59.402702
945	Mp1WHa-CXfw	Others	other	1	1.40	22.00	30.80	2026-09-09 14:55:59.402702
1135	NVbNJeWZ1Lo	Others	other	3	3.00	\N	\N	2026-09-10 20:21:07.431547
1142	wnp9gFm7ZpY	Shorts feed	feed	72	55.40	\N	\N	2026-09-10 22:48:19.000993
1143	wnp9gFm7ZpY	YouTube search	search	25	19.20	\N	\N	2026-09-10 22:48:19.000993
1144	wnp9gFm7ZpY	Browse features	browse	12	9.20	\N	\N	2026-09-10 22:48:19.000993
1145	wnp9gFm7ZpY	Notifications	other	11	8.50	\N	\N	2026-09-10 22:48:19.000993
1146	wnp9gFm7ZpY	Channel pages	channel	8	6.20	\N	\N	2026-09-10 22:48:19.000993
982	yBnFHlmgMFQ	Shorts feed	feed	479	83.90	\N	\N	2026-09-09 23:48:51.46802
983	yBnFHlmgMFQ	Browse features	browse	54	9.50	\N	\N	2026-09-09 23:48:51.46802
984	yBnFHlmgMFQ	YouTube search	search	24	4.20	\N	\N	2026-09-09 23:48:51.46802
985	yBnFHlmgMFQ	Channel pages	channel	8	1.40	\N	\N	2026-09-09 23:48:51.46802
986	yBnFHlmgMFQ	Suggested videos	other	3	0.50	\N	\N	2026-09-09 23:48:51.46802
987	yBnFHlmgMFQ	Others	other	3	0.50	\N	\N	2026-09-09 23:48:51.46802
1147	wnp9gFm7ZpY	Others	other	2	1.50	\N	\N	2026-09-10 22:48:19.000993
1501	DrhZsdeBj6k	Shorts feed	feed	331	1.10	\N	\N	2026-09-13 00:39:55.370257
1502	DrhZsdeBj6k	External	external	241	0.80	\N	\N	2026-09-13 00:39:55.370257
1503	DrhZsdeBj6k	Other YouTube features	other	211	0.70	\N	\N	2026-09-13 00:39:55.370257
1504	DrhZsdeBj6k	Browse features	browse	60	0.20	\N	\N	2026-09-13 00:39:55.370257
1505	DrhZsdeBj6k	Others	other	60	0.20	\N	\N	2026-09-13 00:39:55.370257
1163	3LCJCKfRATo	Shorts feed	feed	479	83.90	\N	\N	2026-09-10 23:30:52.664773
1164	3LCJCKfRATo	Browse features	browse	54	9.50	\N	\N	2026-09-10 23:30:52.664773
1165	3LCJCKfRATo	YouTube search	search	24	4.20	\N	\N	2026-09-10 23:30:52.664773
1166	3LCJCKfRATo	Channel pages	channel	8	1.40	\N	\N	2026-09-10 23:30:52.664773
1167	3LCJCKfRATo	Suggested videos	other	3	0.50	\N	\N	2026-09-10 23:30:52.664773
1168	3LCJCKfRATo	Others	other	3	0.50	\N	\N	2026-09-10 23:30:52.664773
1034	Pnh6g6K9y8Q	Shorts feed	feed	382	89.70	\N	\N	2026-09-10 17:22:57.565114
1035	Pnh6g6K9y8Q	YouTube search	search	24	5.60	\N	\N	2026-09-10 17:22:57.565114
1036	Pnh6g6K9y8Q	Channel pages	channel	10	2.30	\N	\N	2026-09-10 17:22:57.565114
1037	Pnh6g6K9y8Q	Other YouTube features	other	5	1.20	\N	\N	2026-09-10 17:22:57.565114
1038	Pnh6g6K9y8Q	Browse features	browse	3	0.70	\N	\N	2026-09-10 17:22:57.565114
1039	Pnh6g6K9y8Q	Others	other	3	0.50	\N	\N	2026-09-10 17:22:57.565114
1070	Mkx7Qp8nCys	Shorts feed	feed	45	61.60	\N	\N	2026-09-10 18:44:13.592751
1071	Mkx7Qp8nCys	Browse features	browse	15	20.50	\N	\N	2026-09-10 18:44:13.592751
1072	Mkx7Qp8nCys	YouTube search	search	8	10.90	\N	\N	2026-09-10 18:44:13.592751
1073	Mkx7Qp8nCys	Channel pages	channel	3	4.10	\N	\N	2026-09-10 18:44:13.592751
1074	Mkx7Qp8nCys	Suggested videos	other	1	0.50	\N	\N	2026-09-10 18:44:13.592751
1075	Mkx7Qp8nCys	Others	other	1	0.50	\N	\N	2026-09-10 18:44:13.592751
856	4B4aAW76GLQ	Shorts feed	feed	365	88.40	10.50	34.00	2026-09-07 09:04:23.739817
857	4B4aAW76GLQ	YouTube search	search	34	8.20	15.00	45.00	2026-09-07 09:04:23.739817
858	4B4aAW76GLQ	Browse features	browse	4	1.00	8.00	25.00	2026-09-07 09:04:23.739817
859	4B4aAW76GLQ	Channel pages	channel	3	0.70	12.00	30.00	2026-09-07 09:04:23.739817
860	4B4aAW76GLQ	Other YouTube features	other	3	0.70	9.00	28.00	2026-09-07 09:04:23.739817
861	4B4aAW76GLQ	Others	other	4	1.00	7.00	22.00	2026-09-07 09:04:23.739817
1094	a6DGQWZ57EE	YouTube search	search	61	61.10	\N	\N	2026-09-10 19:33:03.635723
1095	a6DGQWZ57EE	Shorts feed	feed	48	24.90	\N	\N	2026-09-10 19:33:03.635723
1096	a6DGQWZ57EE	Notifications	other	13	6.70	\N	\N	2026-09-10 19:33:03.635723
1097	a6DGQWZ57EE	Channel pages	channel	8	4.20	\N	\N	2026-09-10 19:33:03.635723
1098	a6DGQWZ57EE	Browse features	browse	5	2.60	\N	\N	2026-09-10 19:33:03.635723
1099	a6DGQWZ57EE	Others	other	1	0.50	\N	\N	2026-09-10 19:33:03.635723
1474	AwJoDsJiAoQ	Shorts feed	feed	14	29.80	\N	\N	2026-09-13 00:30:05.383779
1475	AwJoDsJiAoQ	Channel pages	channel	13	27.70	\N	\N	2026-09-13 00:30:05.383779
1476	AwJoDsJiAoQ	Browse features	browse	5	10.60	\N	\N	2026-09-13 00:30:05.383779
1477	AwJoDsJiAoQ	YouTube search	search	4	8.50	\N	\N	2026-09-13 00:30:05.383779
1478	AwJoDsJiAoQ	External	external	4	8.50	\N	\N	2026-09-13 00:30:05.383779
1479	AwJoDsJiAoQ	Others	other	7	14.90	\N	\N	2026-09-13 00:30:05.383779
1530	QnjyscmnjEQ	YouTube search	search	426	60.60	\N	\N	2026-09-13 01:04:42.898173
1531	QnjyscmnjEQ	Browse features	browse	64	9.10	\N	\N	2026-09-13 01:04:42.898173
1532	QnjyscmnjEQ	Shorts feed	feed	60	8.50	\N	\N	2026-09-13 01:04:42.898173
1533	QnjyscmnjEQ	Channel pages	channel	58	8.30	\N	\N	2026-09-13 01:04:42.898173
1534	QnjyscmnjEQ	Suggested videos	other	45	6.40	\N	\N	2026-09-13 01:04:42.898173
1535	QnjyscmnjEQ	Others	other	50	7.10	\N	\N	2026-09-13 01:04:42.898173
1610	_gF2JDP64Yc	YouTube search	search	484	83.30	\N	\N	2026-09-13 08:06:26.943876
1611	_gF2JDP64Yc	Other YouTube features	other	97	16.70	\N	\N	2026-09-13 08:06:26.943876
1624	SS61lwI_i5Q	Shorts feed	feed	143	76.10	\N	\N	2026-09-13 08:20:20.943281
1625	SS61lwI_i5Q	Channel pages	channel	15	8.00	\N	\N	2026-09-13 08:20:20.943281
1626	SS61lwI_i5Q	YouTube search	search	13	6.90	\N	\N	2026-09-13 08:20:20.943281
1627	SS61lwI_i5Q	Other YouTube features	other	5	2.70	\N	\N	2026-09-13 08:20:20.943281
1628	SS61lwI_i5Q	Browse features	browse	4	2.10	\N	\N	2026-09-13 08:20:20.943281
1629	SS61lwI_i5Q	Others	other	8	4.30	\N	\N	2026-09-13 08:20:20.943281
1512	3JdwNxhgqN8	Shorts feed	feed	487	36.50	\N	\N	2026-09-13 00:48:04.423667
1513	3JdwNxhgqN8	Browse features	browse	335	25.10	\N	\N	2026-09-13 00:48:04.423667
1514	3JdwNxhgqN8	YouTube search	search	276	20.70	\N	\N	2026-09-13 00:48:04.423667
1515	3JdwNxhgqN8	Channel pages	channel	135	10.10	\N	\N	2026-09-13 00:48:04.423667
1516	3JdwNxhgqN8	Notifications	other	47	3.50	\N	\N	2026-09-13 00:48:04.423667
1517	3JdwNxhgqN8	Others	other	53	4.00	\N	\N	2026-09-13 00:48:04.423667
1602	j7xmoRH2rzo	Shorts feed	feed	1718	80.70	\N	\N	2026-09-13 08:04:48.235092
1603	j7xmoRH2rzo	YouTube search	search	270	12.70	\N	\N	2026-09-13 08:04:48.235092
1604	j7xmoRH2rzo	Channel pages	channel	70	3.30	\N	\N	2026-09-13 08:04:48.235092
1605	j7xmoRH2rzo	External	external	38	1.80	\N	\N	2026-09-13 08:04:48.235092
1606	j7xmoRH2rzo	Hashtag pages	other	11	0.50	\N	\N	2026-09-13 08:04:48.235092
1607	j7xmoRH2rzo	Others	other	21	1.00	\N	\N	2026-09-13 08:04:48.235092
1612	5v6ouzwDdRQ	YouTube search	search	291	47.90	\N	\N	2026-09-13 08:07:14.421856
1613	5v6ouzwDdRQ	Shorts feed	feed	236	38.90	\N	\N	2026-09-13 08:07:14.421856
1614	5v6ouzwDdRQ	Channel pages	channel	48	7.90	\N	\N	2026-09-13 08:07:14.421856
1615	5v6ouzwDdRQ	Browse features	browse	14	2.30	\N	\N	2026-09-13 08:07:14.421856
1616	5v6ouzwDdRQ	Hashtag pages	other	7	1.20	\N	\N	2026-09-13 08:07:14.421856
1617	5v6ouzwDdRQ	Others	other	11	1.80	\N	\N	2026-09-13 08:07:14.421856
1630	BMh9Xq36RrA	YouTube search	search	1105	100.00	\N	\N	2026-09-13 08:22:34.508287
1631	BMh9Xq36RrA	Other YouTube features	other	1	0.00	\N	\N	2026-09-13 08:22:34.508287
1632	BMh9Xq36RrA	Shorts feed	feed	1	0.00	\N	\N	2026-09-13 08:22:34.508287
1397	fsSkI-1Opvk	Shorts feed	feed	378	90.00	\N	\N	2026-09-11 22:58:05.388618
1398	fsSkI-1Opvk	YouTube search	search	21	5.00	\N	\N	2026-09-11 22:58:05.388618
1399	fsSkI-1Opvk	Browse features	browse	8	2.00	\N	\N	2026-09-11 22:58:05.388618
1400	fsSkI-1Opvk	Channel pages	channel	4	1.00	\N	\N	2026-09-11 22:58:05.388618
1401	fsSkI-1Opvk	External	external	4	1.00	\N	\N	2026-09-11 22:58:05.388618
1402	fsSkI-1Opvk	Other YouTube features	other	4	1.00	\N	\N	2026-09-11 22:58:05.388618
1403	pbU_sJKSfrg	Shorts feed	feed	216	90.00	\N	\N	2026-09-11 22:58:06.014146
1404	pbU_sJKSfrg	YouTube search	search	12	5.00	\N	\N	2026-09-11 22:58:06.014146
1405	pbU_sJKSfrg	Browse features	browse	5	2.00	\N	\N	2026-09-11 22:58:06.014146
1406	pbU_sJKSfrg	Channel pages	channel	2	1.00	\N	\N	2026-09-11 22:58:06.014146
1407	pbU_sJKSfrg	External	external	2	1.00	\N	\N	2026-09-11 22:58:06.014146
1408	pbU_sJKSfrg	Other YouTube features	other	2	1.00	\N	\N	2026-09-11 22:58:06.014146
1409	W1nCo6y71R8	Shorts feed	feed	136	90.00	\N	\N	2026-09-11 22:58:06.303119
1410	W1nCo6y71R8	YouTube search	search	8	5.00	\N	\N	2026-09-11 22:58:06.303119
1411	W1nCo6y71R8	Browse features	browse	3	2.00	\N	\N	2026-09-11 22:58:06.303119
1412	W1nCo6y71R8	Channel pages	channel	2	1.00	\N	\N	2026-09-11 22:58:06.303119
1413	W1nCo6y71R8	External	external	2	1.00	\N	\N	2026-09-11 22:58:06.303119
1414	W1nCo6y71R8	Other YouTube features	other	2	1.00	\N	\N	2026-09-11 22:58:06.303119
1608	muLRYXpkVWA	YouTube search	search	2611	100.00	\N	\N	2026-09-13 08:06:19.001339
1609	muLRYXpkVWA	Shorts feed	feed	1	0.00	\N	\N	2026-09-13 08:06:19.001339
1427	xj4emmUcJGE	Shorts feed	feed	938	90.00	\N	\N	2026-09-11 22:58:07.287609
1428	xj4emmUcJGE	YouTube search	search	52	5.00	\N	\N	2026-09-11 22:58:07.287609
1429	xj4emmUcJGE	Browse features	browse	21	2.00	\N	\N	2026-09-11 22:58:07.287609
1430	xj4emmUcJGE	Channel pages	channel	10	1.00	\N	\N	2026-09-11 22:58:07.287609
1431	xj4emmUcJGE	External	external	10	1.00	\N	\N	2026-09-11 22:58:07.287609
1432	xj4emmUcJGE	Other YouTube features	other	10	1.00	\N	\N	2026-09-11 22:58:07.287609
1433	w2UTdzsuads	Shorts feed	feed	332	90.00	\N	\N	2026-09-11 22:58:07.599184
1434	w2UTdzsuads	YouTube search	search	18	5.00	\N	\N	2026-09-11 22:58:07.599184
1435	w2UTdzsuads	Browse features	browse	7	2.00	\N	\N	2026-09-11 22:58:07.599184
1436	w2UTdzsuads	Channel pages	channel	4	1.00	\N	\N	2026-09-11 22:58:07.599184
1437	w2UTdzsuads	External	external	4	1.00	\N	\N	2026-09-11 22:58:07.599184
1438	w2UTdzsuads	Other YouTube features	other	4	1.00	\N	\N	2026-09-11 22:58:07.599184
1439	SOKrC7BJ418	Shorts feed	feed	522	90.00	\N	\N	2026-09-11 22:58:07.871575
1440	SOKrC7BJ418	YouTube search	search	29	5.00	\N	\N	2026-09-11 22:58:07.871575
1441	SOKrC7BJ418	Browse features	browse	12	2.00	\N	\N	2026-09-11 22:58:07.871575
1442	SOKrC7BJ418	Channel pages	channel	6	1.00	\N	\N	2026-09-11 22:58:07.871575
1443	SOKrC7BJ418	External	external	6	1.00	\N	\N	2026-09-11 22:58:07.871575
1444	SOKrC7BJ418	Other YouTube features	other	6	1.00	\N	\N	2026-09-11 22:58:07.871575
1445	PaYUzmc11E8	Shorts feed	feed	130	90.00	\N	\N	2026-09-11 22:58:08.189019
1446	PaYUzmc11E8	YouTube search	search	7	5.00	\N	\N	2026-09-11 22:58:08.189019
1447	PaYUzmc11E8	Browse features	browse	3	2.00	\N	\N	2026-09-11 22:58:08.189019
1448	PaYUzmc11E8	Channel pages	channel	1	1.00	\N	\N	2026-09-11 22:58:08.189019
1449	PaYUzmc11E8	External	external	1	1.00	\N	\N	2026-09-11 22:58:08.189019
1450	PaYUzmc11E8	Other YouTube features	other	1	1.00	\N	\N	2026-09-11 22:58:08.189019
1451	0KAZqj8-gFo	Shorts feed	feed	674	90.00	\N	\N	2026-09-11 22:58:08.519442
1452	0KAZqj8-gFo	YouTube search	search	37	5.00	\N	\N	2026-09-11 22:58:08.519442
1453	0KAZqj8-gFo	Browse features	browse	15	2.00	\N	\N	2026-09-11 22:58:08.519442
1454	0KAZqj8-gFo	Channel pages	channel	7	1.00	\N	\N	2026-09-11 22:58:08.519442
1455	0KAZqj8-gFo	External	external	7	1.00	\N	\N	2026-09-11 22:58:08.519442
1456	0KAZqj8-gFo	Other YouTube features	other	7	1.00	\N	\N	2026-09-11 22:58:08.519442
1618	4yAeMwjZxoo	YouTube search	search	197	42.80	\N	\N	2026-09-13 08:12:31.899566
1619	4yAeMwjZxoo	Shorts feed	feed	182	39.60	\N	\N	2026-09-13 08:12:31.899566
1620	4yAeMwjZxoo	Channel pages	channel	59	12.80	\N	\N	2026-09-13 08:12:31.899566
1621	4yAeMwjZxoo	Browse features	browse	9	2.00	\N	\N	2026-09-13 08:12:31.899566
1622	4yAeMwjZxoo	Other YouTube features	other	5	1.10	\N	\N	2026-09-13 08:12:31.899566
1623	4yAeMwjZxoo	Others	other	8	1.70	\N	\N	2026-09-13 08:12:31.899566
\.


--
-- Name: analysis_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.analysis_log_id_seq', 1140, true);


--
-- Name: analysis_sessions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.analysis_sessions_id_seq', 12, true);


--
-- Name: audience_geography_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.audience_geography_id_seq', 649, true);


--
-- Name: comparison_clusters_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.comparison_clusters_id_seq', 18, true);


--
-- Name: external_sources_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.external_sources_id_seq', 99, true);


--
-- Name: hidden_patterns_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.hidden_patterns_id_seq', 19, true);


--
-- Name: individual_comments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.individual_comments_id_seq', 345, true);


--
-- Name: memory_updates_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.memory_updates_id_seq', 218, true);


--
-- Name: retention_curve_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.retention_curve_id_seq', 1024, true);


--
-- Name: search_terms_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.search_terms_id_seq', 948, true);


--
-- Name: short_analysis_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.short_analysis_id_seq', 8, true);


--
-- Name: title_templates_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.title_templates_id_seq', 29, true);


--
-- Name: traffic_sources_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.traffic_sources_id_seq', 1632, true);


--
-- Name: analysis_log analysis_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.analysis_log
    ADD CONSTRAINT analysis_log_pkey PRIMARY KEY (id);


--
-- Name: analysis_sessions analysis_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.analysis_sessions
    ADD CONSTRAINT analysis_sessions_pkey PRIMARY KEY (id);


--
-- Name: analysis_sessions analysis_sessions_session_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.analysis_sessions
    ADD CONSTRAINT analysis_sessions_session_id_key UNIQUE (session_id);


--
-- Name: audience_age audience_age_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audience_age
    ADD CONSTRAINT audience_age_pkey PRIMARY KEY (video_id);


--
-- Name: audience_device audience_device_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audience_device
    ADD CONSTRAINT audience_device_pkey PRIMARY KEY (video_id);


--
-- Name: audience_gender audience_gender_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audience_gender
    ADD CONSTRAINT audience_gender_pkey PRIMARY KEY (video_id);


--
-- Name: audience_geography audience_geography_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audience_geography
    ADD CONSTRAINT audience_geography_pkey PRIMARY KEY (id);


--
-- Name: audience_geography audience_geography_video_id_country_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audience_geography
    ADD CONSTRAINT audience_geography_video_id_country_code_key UNIQUE (video_id, country_code);


--
-- Name: audience_subscriber_status audience_subscriber_status_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audience_subscriber_status
    ADD CONSTRAINT audience_subscriber_status_pkey PRIMARY KEY (video_id);


--
-- Name: audience_subtitles audience_subtitles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audience_subtitles
    ADD CONSTRAINT audience_subtitles_pkey PRIMARY KEY (video_id);


--
-- Name: channels channels_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.channels
    ADD CONSTRAINT channels_pkey PRIMARY KEY (channel_id);


--
-- Name: comments_analysis comments_analysis_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comments_analysis
    ADD CONSTRAINT comments_analysis_pkey PRIMARY KEY (video_id);


--
-- Name: comparison_clusters comparison_clusters_cluster_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comparison_clusters
    ADD CONSTRAINT comparison_clusters_cluster_name_key UNIQUE (cluster_name);


--
-- Name: comparison_clusters comparison_clusters_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comparison_clusters
    ADD CONSTRAINT comparison_clusters_pkey PRIMARY KEY (id);


--
-- Name: content_types content_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.content_types
    ADD CONSTRAINT content_types_pkey PRIMARY KEY (content_type);


--
-- Name: end_screen_performance end_screen_performance_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.end_screen_performance
    ADD CONSTRAINT end_screen_performance_pkey PRIMARY KEY (video_id);


--
-- Name: external_sources external_sources_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.external_sources
    ADD CONSTRAINT external_sources_pkey PRIMARY KEY (id);


--
-- Name: hidden_patterns hidden_patterns_pattern_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hidden_patterns
    ADD CONSTRAINT hidden_patterns_pattern_name_key UNIQUE (pattern_name);


--
-- Name: hidden_patterns hidden_patterns_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hidden_patterns
    ADD CONSTRAINT hidden_patterns_pkey PRIMARY KEY (id);


--
-- Name: individual_comments individual_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.individual_comments
    ADD CONSTRAINT individual_comments_pkey PRIMARY KEY (id);


--
-- Name: individual_comments individual_comments_video_id_comment_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.individual_comments
    ADD CONSTRAINT individual_comments_video_id_comment_id_key UNIQUE (video_id, comment_id);


--
-- Name: memory_updates memory_updates_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.memory_updates
    ADD CONSTRAINT memory_updates_pkey PRIMARY KEY (id);


--
-- Name: performance_metrics performance_metrics_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.performance_metrics
    ADD CONSTRAINT performance_metrics_pkey PRIMARY KEY (video_id);


--
-- Name: realtime_metrics realtime_metrics_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.realtime_metrics
    ADD CONSTRAINT realtime_metrics_pkey PRIMARY KEY (video_id);


--
-- Name: remix_metrics remix_metrics_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.remix_metrics
    ADD CONSTRAINT remix_metrics_pkey PRIMARY KEY (video_id);


--
-- Name: retention_curve retention_curve_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.retention_curve
    ADD CONSTRAINT retention_curve_pkey PRIMARY KEY (id);


--
-- Name: retention_curve retention_curve_video_id_timestamp_seconds_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.retention_curve
    ADD CONSTRAINT retention_curve_video_id_timestamp_seconds_key UNIQUE (video_id, timestamp_seconds);


--
-- Name: search_terms search_terms_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.search_terms
    ADD CONSTRAINT search_terms_pkey PRIMARY KEY (id);


--
-- Name: short_analysis short_analysis_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.short_analysis
    ADD CONSTRAINT short_analysis_pkey PRIMARY KEY (id);


--
-- Name: short_analysis short_analysis_short_id_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.short_analysis
    ADD CONSTRAINT short_analysis_short_id_unique UNIQUE (short_id);


--
-- Name: short_content_classification short_content_classification_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.short_content_classification
    ADD CONSTRAINT short_content_classification_pkey PRIMARY KEY (video_id);


--
-- Name: short_title_template short_title_template_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.short_title_template
    ADD CONSTRAINT short_title_template_pkey PRIMARY KEY (video_id);


--
-- Name: shorts shorts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shorts
    ADD CONSTRAINT shorts_pkey PRIMARY KEY (short_id);


--
-- Name: shorts shorts_video_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shorts
    ADD CONSTRAINT shorts_video_id_key UNIQUE (video_id);


--
-- Name: title_templates title_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.title_templates
    ADD CONSTRAINT title_templates_pkey PRIMARY KEY (id);


--
-- Name: traffic_sources traffic_sources_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.traffic_sources
    ADD CONSTRAINT traffic_sources_pkey PRIMARY KEY (id);


--
-- Name: traffic_sources traffic_sources_video_id_source_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.traffic_sources
    ADD CONSTRAINT traffic_sources_video_id_source_name_key UNIQUE (video_id, source_name);


--
-- Name: idx_analysis_log_session; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_analysis_log_session ON public.analysis_log USING btree (session_id);


--
-- Name: idx_comments_analysis_video; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_comments_analysis_video ON public.comments_analysis USING btree (video_id);


--
-- Name: idx_geography_video; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_geography_video ON public.audience_geography USING btree (video_id);


--
-- Name: idx_individual_comments_video; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_individual_comments_video ON public.individual_comments USING btree (video_id);


--
-- Name: idx_memory_updates_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_memory_updates_type ON public.memory_updates USING btree (update_type);


--
-- Name: idx_performance_retention; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_performance_retention ON public.performance_metrics USING btree (retention_pct DESC);


--
-- Name: idx_performance_views; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_performance_views ON public.performance_metrics USING btree (views DESC);


--
-- Name: idx_retention_curve_video; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_retention_curve_video ON public.retention_curve USING btree (video_id);


--
-- Name: idx_search_terms_term; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_search_terms_term ON public.search_terms USING btree (search_term);


--
-- Name: idx_search_terms_video; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_search_terms_video ON public.search_terms USING btree (video_id);


--
-- Name: idx_shorts_content_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_shorts_content_type ON public.shorts USING btree (content_type);


--
-- Name: idx_shorts_content_year; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_shorts_content_year ON public.shorts USING btree (content_year);


--
-- Name: idx_shorts_published; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_shorts_published ON public.shorts USING btree (published_at DESC);


--
-- Name: idx_shorts_value_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_shorts_value_type ON public.shorts USING btree (value_type);


--
-- Name: idx_traffic_video_category; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_traffic_video_category ON public.traffic_sources USING btree (video_id, source_category);


--
-- Name: channels update_channels_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_channels_updated_at BEFORE UPDATE ON public.channels FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: shorts update_shorts_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_shorts_updated_at BEFORE UPDATE ON public.shorts FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: analysis_log analysis_log_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.analysis_log
    ADD CONSTRAINT analysis_log_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.analysis_sessions(id);


--
-- Name: analysis_log analysis_log_video_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.analysis_log
    ADD CONSTRAINT analysis_log_video_id_fkey FOREIGN KEY (video_id) REFERENCES public.shorts(video_id) ON DELETE SET NULL;


--
-- Name: audience_age audience_age_video_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audience_age
    ADD CONSTRAINT audience_age_video_id_fkey FOREIGN KEY (video_id) REFERENCES public.shorts(video_id) ON DELETE CASCADE;


--
-- Name: audience_device audience_device_video_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audience_device
    ADD CONSTRAINT audience_device_video_id_fkey FOREIGN KEY (video_id) REFERENCES public.shorts(video_id) ON DELETE CASCADE;


--
-- Name: audience_gender audience_gender_video_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audience_gender
    ADD CONSTRAINT audience_gender_video_id_fkey FOREIGN KEY (video_id) REFERENCES public.shorts(video_id) ON DELETE CASCADE;


--
-- Name: audience_geography audience_geography_video_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audience_geography
    ADD CONSTRAINT audience_geography_video_id_fkey FOREIGN KEY (video_id) REFERENCES public.shorts(video_id) ON DELETE CASCADE;


--
-- Name: audience_subscriber_status audience_subscriber_status_video_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audience_subscriber_status
    ADD CONSTRAINT audience_subscriber_status_video_id_fkey FOREIGN KEY (video_id) REFERENCES public.shorts(video_id) ON DELETE CASCADE;


--
-- Name: audience_subtitles audience_subtitles_video_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audience_subtitles
    ADD CONSTRAINT audience_subtitles_video_id_fkey FOREIGN KEY (video_id) REFERENCES public.shorts(video_id) ON DELETE CASCADE;


--
-- Name: comments_analysis comments_analysis_video_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comments_analysis
    ADD CONSTRAINT comments_analysis_video_id_fkey FOREIGN KEY (video_id) REFERENCES public.shorts(video_id) ON DELETE CASCADE;


--
-- Name: end_screen_performance end_screen_performance_video_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.end_screen_performance
    ADD CONSTRAINT end_screen_performance_video_id_fkey FOREIGN KEY (video_id) REFERENCES public.shorts(video_id) ON DELETE CASCADE;


--
-- Name: external_sources external_sources_video_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.external_sources
    ADD CONSTRAINT external_sources_video_id_fkey FOREIGN KEY (video_id) REFERENCES public.shorts(video_id) ON DELETE CASCADE;


--
-- Name: individual_comments individual_comments_video_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.individual_comments
    ADD CONSTRAINT individual_comments_video_id_fkey FOREIGN KEY (video_id) REFERENCES public.shorts(video_id) ON DELETE CASCADE;


--
-- Name: memory_updates memory_updates_video_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.memory_updates
    ADD CONSTRAINT memory_updates_video_id_fkey FOREIGN KEY (video_id) REFERENCES public.shorts(video_id) ON DELETE SET NULL;


--
-- Name: performance_metrics performance_metrics_video_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.performance_metrics
    ADD CONSTRAINT performance_metrics_video_id_fkey FOREIGN KEY (video_id) REFERENCES public.shorts(video_id) ON DELETE CASCADE;


--
-- Name: realtime_metrics realtime_metrics_video_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.realtime_metrics
    ADD CONSTRAINT realtime_metrics_video_id_fkey FOREIGN KEY (video_id) REFERENCES public.shorts(video_id) ON DELETE CASCADE;


--
-- Name: remix_metrics remix_metrics_video_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.remix_metrics
    ADD CONSTRAINT remix_metrics_video_id_fkey FOREIGN KEY (video_id) REFERENCES public.shorts(video_id) ON DELETE CASCADE;


--
-- Name: retention_curve retention_curve_video_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.retention_curve
    ADD CONSTRAINT retention_curve_video_id_fkey FOREIGN KEY (video_id) REFERENCES public.shorts(video_id) ON DELETE CASCADE;


--
-- Name: search_terms search_terms_video_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.search_terms
    ADD CONSTRAINT search_terms_video_id_fkey FOREIGN KEY (video_id) REFERENCES public.shorts(video_id) ON DELETE CASCADE;


--
-- Name: short_analysis short_analysis_short_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.short_analysis
    ADD CONSTRAINT short_analysis_short_id_fkey FOREIGN KEY (short_id) REFERENCES public.shorts(short_id);


--
-- Name: short_analysis short_analysis_video_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.short_analysis
    ADD CONSTRAINT short_analysis_video_id_fkey FOREIGN KEY (video_id) REFERENCES public.shorts(video_id);


--
-- Name: short_content_classification short_content_classification_primary_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.short_content_classification
    ADD CONSTRAINT short_content_classification_primary_type_fkey FOREIGN KEY (primary_type) REFERENCES public.content_types(content_type);


--
-- Name: short_content_classification short_content_classification_secondary_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.short_content_classification
    ADD CONSTRAINT short_content_classification_secondary_type_fkey FOREIGN KEY (secondary_type) REFERENCES public.content_types(content_type);


--
-- Name: short_content_classification short_content_classification_video_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.short_content_classification
    ADD CONSTRAINT short_content_classification_video_id_fkey FOREIGN KEY (video_id) REFERENCES public.shorts(video_id) ON DELETE CASCADE;


--
-- Name: short_title_template short_title_template_template_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.short_title_template
    ADD CONSTRAINT short_title_template_template_id_fkey FOREIGN KEY (template_id) REFERENCES public.title_templates(id);


--
-- Name: short_title_template short_title_template_video_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.short_title_template
    ADD CONSTRAINT short_title_template_video_id_fkey FOREIGN KEY (video_id) REFERENCES public.shorts(video_id) ON DELETE CASCADE;


--
-- Name: traffic_sources traffic_sources_video_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.traffic_sources
    ADD CONSTRAINT traffic_sources_video_id_fkey FOREIGN KEY (video_id) REFERENCES public.shorts(video_id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict HBpQwBKcPwLLWmubTzNcndoeXBwmsAtc2jImYKXam6fS8kBB7KVbJ2q2vVe3rvW

