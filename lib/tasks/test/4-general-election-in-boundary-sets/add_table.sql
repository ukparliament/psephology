drop table if exists general_election_in_boundary_sets;

create table general_election_in_boundary_sets (
	id serial not null,
	ordinality int not null,
	general_election_id int not null,
	boundary_set_id int not null,
	constraint fk_parent_general_election foreign key (general_election_id) references general_elections(id),
	constraint fk_parent_boundary_set foreign key (boundary_set_id) references boundary_sets(id),
	primary key (id)
);