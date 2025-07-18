/* We add a parent boundary set ID to the boundary sets table */
ALTER TABLE boundary_sets ADD column parent_boundary_set_id INT;

/* We make the boundary set parent ID a foreign key to the boundary sets table */
ALTER TABLE ONLY public.boundary_sets
	ADD CONSTRAINT fk_parent_boundary_set FOREIGN KEY (parent_boundary_set_id) REFERENCES public.boundary_sets(id);

/* We add a description to the boundary sets table */
ALTER TABLE boundary_sets ADD column description varchar(255);

/* We add a parent constituency group set ID to the constituency group sets table */
ALTER TABLE constituency_group_sets ADD column parent_constituency_group_set_id INT;

/* We make the constituency group set parent ID a foreign key to the constituency groups sets table */
ALTER TABLE ONLY public.constituency_group_sets
	ADD CONSTRAINT fk_parent_constituency_group_set FOREIGN KEY (parent_constituency_group_set_id) REFERENCES public.constituency_group_sets(id);

/* We add a description to the constituency group sets table */
ALTER TABLE constituency_group_sets ADD column description varchar(255);
