/* Add Labour / Co-op disclaimer to the political parties table */
alter table political_parties add column disclaimer varchar(500);
update political_parties set disclaimer = 'Figures presented for Labour include those candidates certified by both the Labour and the Co-operative parties.' where id = 3;

/* Add Democracy Club person ID to the candidacies table */
alter table candidacies add column democracy_club_person_identifier int;