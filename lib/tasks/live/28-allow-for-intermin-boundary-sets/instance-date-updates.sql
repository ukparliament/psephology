/* We expand the date range of the parent boundary set to cover the period to the next full boundary review */
UPDATE boundary_sets set end_on = '1997-04-08' where id = 16;

/* Post interim boundary change set */

/* We make the post interim boundary change boundary set a child of its parent */
UPDATE boundary_sets set parent_boundary_set_id = 16 where id = 13;

/* We add a description to the post interim boundary change boundary set */
UPDATE boundary_sets set description = 'Post interim boundary change boundary set' where id = 13;


/* Pre interim boundary change set */

/* We create a new pre-interim boundary set change boundary set */
INSERT INTO boundary_sets (start_on, end_on, country_id, parent_boundary_set_id) VALUES ('1983-05-14', '1992-03-16', 2, 16);

/* We add a description to pre-interim boundary change boundary set */
UPDATE boundary_sets set description = 'Pre interim boundary change boundary set' where id = 35;

/* We link the new pre-interim boundary set to its establishing legislation */
INSERT INTO boundary_set_legislation_items (boundary_set_id, legislation_item_id) VALUES(35, 21);




