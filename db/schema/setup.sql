drop table if exists constituency_area_overlaps;
drop table if exists constituency_group_set_legislation_items;
drop table if exists boundary_set_legislation_items;
drop table if exists edges;
drop table if exists nodes;
drop table if exists political_party_switches;
drop table if exists country_general_election_party_performances;
drop table if exists english_region_general_election_party_performances;
drop table if exists boundary_set_general_election_party_performances;
drop table if exists general_election_party_performances;
drop table if exists certifications;
drop table if exists candidacies;
drop table if exists elections;
drop table if exists general_elections;
drop table if exists electorates;
drop table if exists constituency_groups;
drop table if exists constituency_areas;
drop table if exists constituency_group_sets;
drop table if exists boundary_sets;
drop table if exists english_regions;
drop table if exists commons_library_dashboard_countries;
drop table if exists countries;
drop table if exists genders;
drop table if exists constituency_area_types;
drop table if exists result_summaries;
drop table if exists political_parties;
drop table if exists enablings;
drop table if exists legislation_items;
drop table if exists legislation_types;
drop table if exists members;
drop table if exists parliament_periods;
drop table if exists commons_library_dashboards;



create table commons_library_dashboards (
	id serial not null,
	title varchar(255) not null,
	url varchar(255) not null,
	primary key (id)
);

create table parliament_periods (
	id serial not null,
	number int not null,
	summoned_on date not null,
	state_opening_on date,
	dissolved_on date,
	wikidata_id varchar(20),
	london_gazette varchar(30),
	commons_library_briefing_by_election_briefing_url varchar(255),
	primary key (id)
);

create table members (
	id serial not null,
	given_name varchar(255) not null,
	family_name varchar(255) not null,
	mnis_id int not null,
	primary key (id)
);

create table legislation_types (
	id serial not null,
	label varchar(255) not null,
	abbreviation varchar(10) not null,
	primary key (id)
);

create table legislation_items (
	id serial not null,
	title varchar(255) not null,
	uri varchar(255),
	url_key varchar(20) not null,
	made_on date,
	royal_assent_on date,
	statute_book_on date not null,
	legislation_type_id int not null,
	constraint fk_legislation_type foreign key (legislation_type_id) references legislation_types(id),
	primary key (id)
);

create table enablings (
	id serial not null,
	enabling_legislation_id int not null,
	enabled_legislation_id int not null,
	constraint fk_enabling_legislation foreign key (enabling_legislation_id) references legislation_items(id),
	constraint fk_enabled_legislation foreign key (enabled_legislation_id) references legislation_items(id),
	primary key (id)
);

create table political_parties (
	id serial not null,
	name varchar(255) not null,
	abbreviation varchar(255) not null,
	electoral_commission_id varchar(10),
	mnis_id int,
	has_been_parliamentary_party boolean default false,
	primary key (id)
);

create table result_summaries (
	id serial not null,
	short_summary varchar(50) not null,
	summary varchar(255),
	is_from_commons_speaker boolean default false,
	is_from_independent boolean default false,
	is_to_commons_speaker boolean default false,
	is_to_independent boolean default false,
	from_political_party_id int,
	to_political_party_id int,
	constraint fk_from_political_party foreign key (from_political_party_id) references political_parties(id),
	constraint fk_to_political_party foreign key (to_political_party_id) references political_parties(id),
	primary key (id)
);

create table constituency_area_types (
	id serial not null,
	area_type varchar(20) not null,
	primary key (id)
);

create table genders (
	id serial not null,
	gender varchar(20) not null,
	primary key (id)
);

create table general_elections (
	id serial not null,
	polling_on date not null,
	is_notional boolean default false,
	commons_library_briefing_url varchar(255),
	valid_vote_count int,
	invalid_vote_count int,
	electorate_population_count int,
	parliament_period_id int not null,
	constraint fk_parliament_period foreign key (parliament_period_id) references parliament_periods(id),
	primary key (id)
);

create table countries (
	id serial not null,
	name varchar(255) not null,
	geographic_code varchar(255),
	directly_contains_constituency_areas boolean default false,
	parent_country_id int,
	constraint fk_parent_country foreign key (parent_country_id) references countries(id),
	primary key (id)
);

create table commons_library_dashboard_countries (
	id serial not null,
	commons_library_dashboard_id int not null,
	country_id int not null,
	constraint fk_commons_library_dashboard foreign key (commons_library_dashboard_id) references commons_library_dashboards(id),
	constraint fk_country foreign key (country_id) references countries(id),
	primary key (id)
);

create table english_regions (
	id serial not null,
	name varchar(255) not null,
	geographic_code varchar(255) not null,
	country_id int not null,
	constraint fk_country foreign key (country_id) references countries(id),
	primary key (id)
);

create table boundary_sets (
	id serial not null,
	start_on date,
	end_on date,
	country_id int not null,
	constraint fk_country foreign key (country_id) references countries(id),
	primary key (id)
);

create table constituency_group_sets (
	id serial not null,
	start_on date,
	end_on date,
	country_id int not null,
	constraint fk_country foreign key (country_id) references countries(id),
	primary key (id)
);

create table constituency_areas (
	id serial not null,
	name varchar(255) not null,
	geographic_code varchar(255) not null,
	english_region_id int,
	country_id int not null,
	constituency_area_type_id int not null,
	boundary_set_id int,
	constraint fk_english_region foreign key (english_region_id) references english_regions(id),
	constraint fk_country foreign key (country_id) references countries(id),
	constraint fk_constituency_area_type foreign key (constituency_area_type_id) references constituency_area_types(id),
	constraint fk_boundary_set foreign key (boundary_set_id) references boundary_sets(id),
	primary key (id)
);

create table constituency_groups (
	id serial not null,
	name varchar(255) not null,
	constituency_area_id int,
	constituency_group_set_id int,
	constraint fk_constituency_area foreign key (constituency_area_id) references constituency_areas(id),
	constraint fk_constituency_group_set foreign key (constituency_group_set_id) references constituency_group_sets(id),
	primary key (id)
);

create table electorates (
	id serial not null,
	population_count int not null,
	constituency_group_id int not null,
	constraint fk_constituency_group foreign key (constituency_group_id) references constituency_groups(id),
	primary key (id)
);

create table elections (
	id serial not null,
	polling_on date not null,
	is_notional boolean default false,
	valid_vote_count int,
	invalid_vote_count int,
	majority int,
	declaration_at timestamp,
	constituency_group_id int not null,
	general_election_id int,
	result_summary_id int,
	electorate_id int,
	parliament_period_id int not null,
	constraint fk_constituency_group foreign key (constituency_group_id) references constituency_groups(id),
	constraint fk_general_election foreign key (general_election_id) references general_elections(id),
	constraint fk_result_summary foreign key (result_summary_id) references result_summaries(id),
	constraint fk_electorate foreign key (electorate_id) references electorates(id),
	constraint fk_parliament_period foreign key (parliament_period_id) references parliament_periods(id),
	primary key (id)
);

create table candidacies (
	id serial not null,
	candidate_given_name varchar(255),
	candidate_family_name varchar(255),
	candidate_is_sitting_mp boolean default false,
	candidate_is_former_mp boolean default false,
	is_standing_as_commons_speaker boolean default false,
	is_standing_as_independent boolean default false,
	is_notional boolean default false,
	result_position int,
	is_winning_candidacy boolean default false,
	vote_count int,
	vote_share float(18),
	vote_change float(18),
	candidate_gender_id int,
	election_id int not null,
	member_id int,
	constraint fk_candidate_gender foreign key (candidate_gender_id) references genders(id),
	constraint fk_election foreign key (election_id) references elections(id),
	constraint fk_member foreign key (member_id) references members(id),
	primary key (id)
);

create table certifications (
	id serial not null,
	candidacy_id int not null,
	political_party_id int not null,
	adjunct_to_certification_id int,
	constraint fk_candidacy foreign key (candidacy_id) references candidacies(id),
	constraint fk_political_party foreign key (political_party_id) references political_parties(id),
	constraint fk_adjunct_to_certification foreign key (adjunct_to_certification_id) references certifications(id),
	primary key (id)
);

create table general_election_party_performances (
	id serial not null,
	constituency_contested_count int not null,
	constituency_won_count int not null,
	cumulative_vote_count int not null,
	cumulative_valid_vote_count int not null,
	general_election_id int not null,
	political_party_id int not null,
	constraint fk_general_election foreign key (general_election_id) references general_elections(id),
	constraint fk_political_party foreign key (political_party_id) references political_parties(id),
	primary key (id)
);

create table boundary_set_general_election_party_performances (
	id serial not null,
	constituency_contested_count int not null,
	constituency_won_count int not null,
	cumulative_vote_count int not null,
	general_election_id int not null,
	political_party_id int not null,
	boundary_set_id int not null,
	constraint fk_general_election foreign key (general_election_id) references general_elections(id),
	constraint fk_political_party foreign key (political_party_id) references political_parties(id),
	constraint fk_boundary_set foreign key (boundary_set_id) references boundary_sets(id),
	primary key (id)
);

create table english_region_general_election_party_performances (
	id serial not null,
	constituency_contested_count int not null,
	constituency_won_count int not null,
	cumulative_vote_count int not null,
	general_election_id int not null,
	political_party_id int not null,
	english_region_id int not null,
	constraint fk_general_election foreign key (general_election_id) references general_elections(id),
	constraint fk_political_party foreign key (political_party_id) references political_parties(id),
	constraint fk_english_region foreign key (english_region_id) references english_regions(id),
	primary key (id)
);

create table country_general_election_party_performances (
	id serial not null,
	constituency_contested_count int not null,
	constituency_won_count int not null,
	cumulative_vote_count int not null,
	general_election_id int not null,
	political_party_id int not null,
	country_id int not null,
	constraint fk_general_election foreign key (general_election_id) references general_elections(id),
	constraint fk_political_party foreign key (political_party_id) references political_parties(id),
	constraint fk_country foreign key (country_id) references countries(id),
	primary key (id)
);

create table political_party_switches (
	id serial not null,
	count int not null,
	from_political_party_name varchar(255) not null,
	from_political_party_abbreviation varchar(255) not null,
	to_political_party_name varchar(255) not null,
	to_political_party_abbreviation varchar(255) not null,
	general_election_id int not null,
	from_political_party_id int,
	to_political_party_id int,
	boundary_set_id int not null,
	constraint fk_general_election foreign key (general_election_id) references general_elections(id),
	constraint fk_to_political_party foreign key (to_political_party_id) references political_parties(id),
	constraint fk_from_political_party foreign key (from_political_party_id) references political_parties(id),
	constraint fk_boundary_set foreign key (boundary_set_id) references boundary_sets(id),
	primary key (id)
);

create table nodes (
	id serial not null,
	label varchar(255) not null,
	boundary_set_id int not null,
	constraint fk_boundary_set foreign key (boundary_set_id) references boundary_sets(id),
	primary key (id)
);

create table edges (
	id serial not null,
	count int not null,
	from_node_label varchar(255) not null,
	to_node_label varchar(255) not null,
	from_node_id int not null,
	to_node_id int not null,
	constraint fk_from_node foreign key (from_node_id) references nodes(id),
	constraint fk_to_node foreign key (to_node_id) references nodes(id),
	primary key (id)
);

create table boundary_set_legislation_items (
	id serial not null,
	boundary_set_id int not null,
	legislation_item_id int not null,
	constraint fk_boundary_set foreign key (boundary_set_id) references boundary_sets(id),
	constraint fk_legislation_item foreign key (legislation_item_id) references legislation_items(id),
	primary key (id)
);

create table constituency_group_set_legislation_items (
	id serial not null,
	constituency_group_set_id int not null,
	legislation_item_id int not null,
	constraint fk_constituency_group_set foreign key (constituency_group_set_id) references constituency_group_sets(id),
	constraint fk_legislation_item foreign key (legislation_item_id) references legislation_items(id),
	primary key (id)
);

create table constituency_area_overlaps (
	id serial not null,
	from_constituency_residential float(18) not null,
	to_constituency_residential float(18) not null,
	from_constituency_geographical float(18) not null,
	to_constituency_geographical float(18) not null,
	from_constituency_population float(18) not null,
	to_constituency_population float(18) not null,
	from_constituency_area_id int not null,
	to_constituency_area_id int not null,
	formed_from_whole_of boolean default false,
	forms_whole_of boolean default false,
	constraint fk_from_constituency_area foreign key (from_constituency_area_id) references constituency_areas(id),
	constraint fk_to_constituency_area foreign key (to_constituency_area_id) references constituency_areas(id),
	primary key (id)
);