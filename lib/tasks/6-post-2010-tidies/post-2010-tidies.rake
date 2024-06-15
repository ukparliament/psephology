require 'csv'

task :post_2010_tidies => [
  :post_2010_tidies_update_parliaments,
  :reassign_yorkshire_parties
]

# ## A task to update Parliaments.
task :post_2010_tidies_update_parliaments => :environment do
  puts "updating parliament periods"
  
  # For each Parliament period ...
  CSV.foreach( 'db/data/parliament_periods.csv' ) do |row|
    
    # ... we store the values from the spreadsheet ...
    parliament_number = row[0].strip if row[0]
    parliament_summoned_on = row[2].strip if row[2]
    parliament_state_opening_on = row[3].strip if row[3]
    parliament_dissolved_on = row[4].strip if row[4]
    parliament_wikidata_id = row[5].strip if row[5]
    parliament_london_gazette = row[10].strip if row[10]
    
    # We find the Parliament.
    parliament_period = ParliamentPeriod.find_by_number( parliament_number )
    parliament_period.summoned_on = parliament_summoned_on
    parliament_period.dissolved_on = parliament_dissolved_on
    parliament_period.state_opening_on = parliament_state_opening_on
    parliament_period.wikidata_id = parliament_wikidata_id
    parliament_period.london_gazette = parliament_london_gazette
    parliament_period.save!
  end
end

# ## A task to reassign Yorkshire parties.
task :reassign_yorkshire_parties => :environment do
  puts "reassigning yorkshire parties"
  
  # We find certifications to the yorkshire first party for candidacies in any election in the 2019 notional general election.
  certifications = Certification.find_by_sql(
    "
      SELECT cert.*
      FROM certifications cert, candidacies cand, elections e
      WHERE cert.candidacy_id = cand.id
      AND cand.election_id = e.id
      AND e.general_election_id = 5
      AND cert.political_party_id = 17
    "
  )
  
  # For each certification ...
  certifications.each do |certification|
    
    # ... we reassign the certification to the yorkshire party.
    certification.political_party_id = 129
    certification.save!
  end
  
  # We find the general election party performances by the yorkshire first party in the 2019 notional general election.
  general_election_party_performance = GeneralElectionPartyPerformance.find_by_sql(
    "
      SELECT gepp.*
      FROM general_election_party_performances gepp
      WHERE gepp.general_election_id = 5
      AND gepp.political_party_id = 17
    "
  ).first
  
  # We reassign the general election party performance to the yorkshire party.
  general_election_party_performance.political_party_id = 129
  general_election_party_performance.save!
end