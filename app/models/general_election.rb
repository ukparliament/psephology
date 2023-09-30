class GeneralElection < ApplicationRecord
  
  def elections_in_country( country )
    Election.find_by_sql(
      "
        SELECT e.*, cg.name AS constituency_group_name
        FROM elections e, constituency_groups cg, constituency_areas ca
        WHERE e.general_election_id = #{self.id}
        AND e.constituency_group_id = cg.id
        AND cg.constituency_area_id = ca.id
        AND ca.country_id = #{country.id}
        ORDER BY cg.name
      "
    )
  end
  
  def elections_in_english_region( english_region )
    Election.find_by_sql(
      "
        SELECT e.*, cg.name AS constituency_group_name
        FROM elections e, constituency_groups cg, constituency_areas ca
        WHERE e.general_election_id = #{self.id}
        AND e.constituency_group_id = cg.id
        AND cg.constituency_area_id = ca.id
        AND ca.english_region_id = #{english_region.id}
        ORDER BY cg.name
      "
    )
  end
end
