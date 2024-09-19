ALTER TABLE political_parties RENAME electoral_commission_id TO legacy_electoral_commission_id;

CREATE TABLE political_party_registrations (
	id serial not null,
	electoral_commission_id varchar(20) not null,
	start_on date not null,
	end_on date,
	political_party_name_last_updated_on date,
	political_party_id int not null,
	country_id int not null,
	constraint fk_political_parties foreign key (political_party_id) references political_parties(id),
	constraint fk_country foreign key (country_id) references countries(id),
	primary key (id)
);