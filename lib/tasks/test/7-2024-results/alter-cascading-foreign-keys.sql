-- add foreign keys to aid a database reset, i.e. delete 2010 by deleting the general election record and cascading the delete

ALTER TABLE "elections" DROP CONSTRAINT "fk_rails_5df3ee16cb";
ALTER TABLE "elections" ADD CONSTRAINT "fk_rails_5df3ee16cb" FOREIGN KEY ("general_election_id") REFERENCES "general_elections" ("id") ON DELETE CASCADE;

ALTER TABLE "general_election_in_boundary_sets" DROP CONSTRAINT "fk_rails_6909cacca3";
ALTER TABLE "general_election_in_boundary_sets" ADD CONSTRAINT "fk_rails_6909cacca3" FOREIGN KEY ("general_election_id") REFERENCES "general_elections" ("id") ON DELETE CASCADE;

ALTER TABLE "general_election_party_performances" DROP CONSTRAINT "fk_rails_04362dd9c7";
ALTER TABLE "general_election_party_performances" ADD CONSTRAINT "fk_rails_04362dd9c7" FOREIGN KEY ("general_election_id") REFERENCES "general_elections" ("id") ON DELETE CASCADE;

ALTER TABLE "boundary_set_general_election_party_performances" DROP CONSTRAINT "fk_rails_7b4a6c8811";
ALTER TABLE "boundary_set_general_election_party_performances" ADD CONSTRAINT "fk_rails_7b4a6c8811" FOREIGN KEY ("general_election_id") REFERENCES "general_elections" ("id") ON DELETE CASCADE;

ALTER TABLE "english_region_general_election_party_performances" DROP CONSTRAINT "fk_rails_5f22c935f7";
ALTER TABLE "english_region_general_election_party_performances" ADD CONSTRAINT "fk_rails_5f22c935f7" FOREIGN KEY ("general_election_id") REFERENCES "general_elections" ("id") ON DELETE CASCADE;

ALTER TABLE "country_general_election_party_performances" DROP CONSTRAINT "fk_rails_c00ed8a882";
ALTER TABLE "country_general_election_party_performances" ADD CONSTRAINT "fk_rails_c00ed8a882" FOREIGN KEY ("general_election_id") REFERENCES "general_elections" ("id") ON DELETE CASCADE;

ALTER TABLE "candidacies" DROP CONSTRAINT "fk_rails_83a7e565e2";
ALTER TABLE "candidacies" ADD CONSTRAINT "fk_rails_83a7e565e2" FOREIGN KEY ("election_id") REFERENCES "elections" ("id") ON DELETE CASCADE;

ALTER TABLE "certifications" DROP CONSTRAINT "fk_rails_e2d166b33e";
ALTER TABLE "certifications" ADD CONSTRAINT "fk_rails_e2d166b33e" FOREIGN KEY ("candidacy_id") REFERENCES "candidacies" ("id") ON DELETE CASCADE;
