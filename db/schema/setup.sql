drop table if exists certifications;
drop table if exists candidacies;
drop table if exists elections;
drop table if exists general_elections;
drop table if exists constituency_groups;
drop table if exists constituency_areas;
drop table if exists boundary_sets;
drop table if exists orders_in_council;
drop table if exists english_regions;
drop table if exists countries;
drop table if exists genders;
drop table if exists constituency_area_types;
drop table if exists political_parties;



create table political_parties (
	id serial not null,
	name varchar(255) not null,
	abbreviation varchar(255) not null,
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
	primary key (id)
);

create table countries (
	id serial not null,
	name varchar(255) not null,
	ons_code varchar(255),
	primary key (id)
);

create table english_regions (
	id serial not null,
	name varchar(255) not null,
	ons_code varchar(255) not null,
	country_id int not null,
	constraint fk_country foreign key (country_id) references countries(id),
	primary key (id)
);

create table orders_in_council (
	id serial not null,
	title varchar(500) not null,
	uri varchar(255) not null,
	primary key (id)
);

create table boundary_sets (
	id serial not null,
	start_on date not null,
	end_on date,
	country_id int not null,
	order_in_council_id int not null,
	interim_change_from_boundary_set_id int,
	constraint fk_country foreign key (country_id) references countries(id),
	constraint fk_order_in_council foreign key (order_in_council_id) references orders_in_council(id),
	constraint fk_interim_change_from_boundary_set foreign key (interim_change_from_boundary_set_id) references boundary_sets(id),
	primary key (id)
);

create table constituency_areas (
	id serial not null,
	name varchar(255) not null,
	ons_code varchar(255) not null,
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
	constraint fk_constituency_area foreign key (constituency_area_id) references constituency_areas(id),
	primary key (id)
);

create table elections (
	id serial not null,
	polling_on date not null,
	constituency_group_id int not null,
	general_election_id int,
	constraint fk_constituency_group foreign key (constituency_group_id) references constituency_groups(id),
	constraint fk_general_election foreign key (general_election_id) references general_elections(id),
	primary key (id)
);

create table candidacies (
	id serial not null,
	candidate_given_name varchar(255) not null,
	candidate_family_name varchar(255) not null,
	candidate_is_sitting_mp boolean default false,
	candidate_is_former_mp boolean default false,
	candidate_gender_id int not null,
	election_id int not null,
	vote_count int,
	vote_share float(18),
	vote_change float(18),
	constraint fk_candidate_gender foreign key (candidate_gender_id) references genders(id),
	constraint fk_election foreign key (election_id) references elections(id),
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