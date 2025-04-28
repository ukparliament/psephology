drop table if exists maiden_speeches;

create table maiden_speeches (
	id serial not null,
	made_on date not null,
	session_number int not null,
	hansard_reference varchar(255) not null,
	hansard_url varchar(255) not null,
	member_id int not null,
	constituency_group_id int not null,
	parliament_period_id int not null,
	constraint fk_member foreign key (member_id) references members(id),
	constraint fk_constituency_group foreign key (constituency_group_id) references constituency_groups(id),
	constraint fk_parliament_period foreign key (parliament_period_id) references parliament_periods(id),
	primary key (id)
);