-- Two parts to this, one is to add indexes to speed up rake task

CREATE INDEX "index_boundary_set_legislation_items_on_boundary_set_id" ON "boundary_set_legislation_items" ("boundary_set_id");
CREATE INDEX "index_boundary_set_legislation_items_on_legislation_item_id" ON "boundary_set_legislation_items" ("legislation_item_id");
CREATE INDEX "index_boundary_sets_on_country_id" ON "boundary_sets" ("country_id");
CREATE INDEX "index_candidacies_on_candidate_gender_id" ON "candidacies" ("candidate_gender_id");
CREATE INDEX "index_candidacies_on_election_id" ON "candidacies" ("election_id");
CREATE INDEX "index_candidacies_on_member_id" ON "candidacies" ("member_id");
CREATE INDEX "index_certifications_on_candidacy_id" ON "certifications" ("candidacy_id");
CREATE INDEX "index_certifications_on_political_party_id" ON "certifications" ("political_party_id");
CREATE INDEX "index_constituency_areas_on_boundary_set_id" ON "constituency_areas" ("boundary_set_id");
CREATE INDEX "index_constituency_areas_on_constituency_area_type_id" ON "constituency_areas" ("constituency_area_type_id");
CREATE INDEX "index_constituency_areas_on_country_id" ON "constituency_areas" ("country_id");
CREATE INDEX "index_constituency_areas_on_english_region_id" ON "constituency_areas" ("english_region_id");
CREATE INDEX "index_constituency_group_sets_on_country_id" ON "constituency_group_sets" ("country_id");
CREATE INDEX "index_constituency_groups_on_constituency_area_id" ON "constituency_groups" ("constituency_area_id");
CREATE INDEX "index_constituency_groups_on_constituency_group_set_id" ON "constituency_groups" ("constituency_group_set_id");
CREATE INDEX "index_country_general_election_party_performances_on_country_id" ON "country_general_election_party_performances" ("country_id");
CREATE INDEX "index_elections_on_constituency_group_id" ON "elections" ("constituency_group_id");
CREATE INDEX "index_elections_on_electorate_id" ON "elections" ("electorate_id");
CREATE INDEX "index_elections_on_general_election_id" ON "elections" ("general_election_id");
CREATE INDEX "index_elections_on_parliament_period_id" ON "elections" ("parliament_period_id");
CREATE INDEX "index_elections_on_result_summary_id" ON "elections" ("result_summary_id");
CREATE INDEX "index_electorates_on_constituency_group_id" ON "electorates" ("constituency_group_id");
CREATE INDEX "index_english_regions_on_country_id" ON "english_regions" ("country_id");
CREATE INDEX "index_general_election_in_boundary_sets_on_boundary_set_id" ON "general_election_in_boundary_sets" ("boundary_set_id");
CREATE INDEX "index_general_elections_on_parliament_period_id" ON "general_elections" ("parliament_period_id");
CREATE INDEX "index_legislation_items_on_legislation_type_id" ON "legislation_items" ("legislation_type_id");
