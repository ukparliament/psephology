require 'csv'

task :setup => [
  :import_genders,
  :import_general_elections,
  :import_election_candidacy_results,
  :import_boundary_sets,
  :attach_constituency_areas_to_boundary_sets,
  :import_election_constituency_results
]

# ## A task to import genders.
task :import_genders => :environment do
  puts "importing genders"
  CSV.foreach( 'db/data/genders.csv' ) do |row|
    gender = Gender.new
    gender.gender = row[0]
    gender.save
  end
end

# ## A task to import general elections.
task :import_general_elections => :environment do
  puts "importing general elections"
  CSV.foreach( 'db/data/general_elections.csv' ) do |row|
    general_election = GeneralElection.new
    general_election.polling_on = row[0]
    general_election.save
  end
end

# ## A task to import election candidacy results.
task :import_election_candidacy_results => :environment do
  puts "importing election candidacy_results"
  
  # We import results for the 2015-05-07 general election.
  polling_on = '2015-05-07'
  import_election_candidacy_results( polling_on )
  
  # We import results for the 2017-06-08 general election.
  polling_on = '2017-06-08'
  import_election_candidacy_results( polling_on )
  
  # We import results for the 2019-12-12 general election.
  polling_on = '2019-12-12'
  import_election_candidacy_results( polling_on )
end

# ## A task to import boundary sets.
task :import_boundary_sets => :environment do
  puts "importing boundary_sets"
  CSV.foreach( 'db/data/boundary_sets.csv' ) do |row|
    
    # We attempt to find the Order in Council establishing this boundary set.
    order_in_council = OrderInCouncil.find_by_uri( row[1] )
    
    # If we don't find the Order in Council ...
    unless order_in_council
      
      # ... we create the Order in Council.
      order_in_council = OrderInCouncil.new
      order_in_council.title = row[2]
      order_in_council.uri = row[1]
      order_in_council.made_on = row[5]
      order_in_council.save!
    end
    
    # We find the country the boundary set is for.
    country = Country.find_by_name( row[0] )
    
    # We create the boundary set.
    boundary_set = BoundarySet.new
    boundary_set.start_on = row[3]
    boundary_set.end_on = row[4] if row[4]
    boundary_set.country = country
    boundary_set.order_in_council = order_in_council
    boundary_set.save!
  end
end

# ## A task to attach constituency areas to boundary sets.
task :attach_constituency_areas_to_boundary_sets => :environment do
  puts "attaching constituency areas to boundary sets"
  
  # We get all the constituency areas.
  constituency_areas = ConstituencyArea.all
  
  # For each constituency area ...
  constituency_areas.each do |constituency_area|
    
    # ... we find the boundary set for the country the constituency area is in.
    boundary_set = BoundarySet
      .all
      .where( "country_id = ?", constituency_area.country_id )
      .first
      
    # We attach the constituency area to its boundary set.
    constituency_area.boundary_set = boundary_set
    constituency_area.save!
  end
end

# ## A task to import election constituency results.
task :import_election_constituency_results => :environment do
  puts "importing election constituency results"
  
  # We import results for the 2015-05-07 general election.
  polling_on = '2015-05-07'
  import_election_constituency_results_winner_unnamed( polling_on )
  
  # We import results for the 2017-06-08 general election.
  polling_on = '2017-06-08'
  import_election_constituency_results_winner_unnamed( polling_on )
  
  # We import results for the 2019-12-12 general election.
  polling_on = '2019-12-12'
  import_election_constituency_results_winner_named( polling_on )
end



# ## A method to import election candidacy results.
def import_election_candidacy_results( polling_on )
  puts "importing election candidacy results for #{polling_on} general election"
  
  # We find the general election this election forms part of.
  general_election = GeneralElection.find_by_polling_on( polling_on )
  
  # For each row in the results sheet ...
  CSV.foreach( "db/data/results/by-candidate/#{polling_on}.csv" ) do |row|
    
    # ... we check if the country exists.
    country = Country.find_by_name( row[5] )
    
    # If the country does not exist ...
    unless country
      
      # ... we create the country.
      country = Country.new
      country.name = row[5]
      country.ons_code = row[1] unless row[5] == 'England'
      country.save!
    end
    
    # If the country is England ...
    if country.name == 'England'
    
      # ... we check if the Englsih region exists.
      english_region = EnglishRegion.find_by_ons_code( row[1] )
      
      # If the English region does not exist ...
      unless english_region
        
        # ... we create the English region.
        english_region = EnglishRegion.new
        english_region.name = row[4]
        english_region.ons_code = row[1]
        english_region.country = country
        english_region.save!
      end
    end
    
    # We check if the constituency area type exists.
    constituency_area_type = ConstituencyAreaType.find_by_area_type( row[6] )
    
    # If the constituency area type does not exist ...
    unless constituency_area_type
      
      # ... we create the constituency area type.
      constituency_area_type = ConstituencyAreaType.new
      constituency_area_type.area_type = row[6]
      constituency_area_type.save!
    end
    
    # We check if there's a constituency area with this ONS code.
    constituency_area = ConstituencyArea.find_by_ons_code( row[0] )
    
    # If there's no constituency area with this ONS code ...
    unless constituency_area
      
      # ... we create the constituency area ...
      constituency_area = ConstituencyArea.new
      constituency_area.name = row[2]
      constituency_area.ons_code = row[0]
      constituency_area.constituency_area_type = constituency_area_type
      constituency_area.country = country
      constituency_area.english_region = english_region if english_region
      constituency_area.save!
      
    end
    
    # We check if there's a constituency group with a constituency area with this ONS code.
    constituency_group = ConstituencyGroup.find_by_sql(
      "
        SELECT cg.*
        FROM constituency_groups cg, constituency_areas ca
        WHERE cg.constituency_area_id = ca.id
        AND ca.ons_code = '#{row[1]}'
      "
    ).first
    
    # Unless we find a constituency group with a constituency area with this ONS code ...
    unless constituency_group
      
      # ... we create the constituency group.
      constituency_group = ConstituencyGroup.new
      constituency_group.name = row[2]
      constituency_group.constituency_area = constituency_area
      constituency_group.save!
    end
      
    
    # We check if there's an election forming part of this general election for this constituency group.
    election = Election.find_by_sql(
      "
        SELECT e.*
        FROM elections e, constituency_groups cg
        WHERE e.constituency_group_id = cg.id
        AND cg.constituency_area_id = #{constituency_area.id}
        AND e.general_election_id = #{general_election.id}
      "
    ).first
    
    # If there's no election forming part of this general election for this area group ...
    unless election
      
      # ... we create the election.
      election = Election.new
      election.polling_on = polling_on
      election.constituency_group = constituency_group
      election.general_election = general_election
      election.save!
    end
    
    # We find the gender of the candidate.
    gender = Gender.find_by_gender( row[11] )
    
    # We create a candidacy.
    candidacy = Candidacy.new
    candidacy.candidate_given_name = row[9]
    candidacy.candidate_family_name = row[10]
    candidacy.candidate_is_sitting_mp = row[12]
    candidacy.candidate_is_former_mp = row[13]
    candidacy.candidate_gender = gender
    candidacy.election = election
    candidacy.vote_count = row[14]
    candidacy.vote_share = row[15]
    candidacy.vote_change = row[16]
    candidacy.save!
    
    # If the party name is Labour and Co-operative ...
    if row[7] == 'Labour and Co-operative'
      
      # ... we check if the Labour Party exists.
      political_party = PoliticalParty.find_by_name( 'Labour' )
      
      # If the Labour Party does not exist ...
      unless political_party
        
        # ... we create it.
        political_party = PoliticalParty.new
        political_party.name = 'Labour'
        political_party.abbreviation = 'Lab'
        political_party.save!
      end
      
      # We create a certification of the candidacy by the party.
      certification1 = Certification.new
      certification1.candidacy = candidacy
      certification1.political_party = political_party
      certification1.save!
      
      # ... we check if the Co-operative Party exists.
      political_party = PoliticalParty.find_by_name( 'Co-operative' )
      
      # If the Co-operative Party does not exist ...
      unless political_party
        
        # ... we create it.
        political_party = PoliticalParty.new
        political_party.name = 'Co-operative'
        political_party.abbreviation = 'Co-op'
        political_party.save!
      end
      
      # We create a certification of the candidacy by the party.
      certification2 = Certification.new
      certification2.candidacy = candidacy
      certification2.political_party = political_party
      
      # Making it adjunct to the certification by the Labour Party.
      certification2.adjunct_to_certification_id = certification1.id
      certification2.save!
      
    # Otherwise, if the party name is not Labour and Co-operative ...
    else
      
      # ... we check if the party exists.
      political_party = PoliticalParty.find_by_name( row[7] )
      
      # If the party does not exist ...
      unless political_party
        
        # ... we create it.
        political_party = PoliticalParty.new
        political_party.name = row[7]
        political_party.abbreviation = row[8]
        political_party.save!
      end
      
      # We create a certification of the candidacy by the party.
      certification = Certification.new
      certification.candidacy = candidacy
      certification.political_party = political_party
      certification.save!
    end
    
    # Note; row[3] holds the county name. I've not done anything with this yet because - whilst counties fit wholly into countries - constituencies do not fit wholly into counties.
  end
end

# ## A method to import election constituency results with no named winner.
def import_election_constituency_results_winner_unnamed( polling_on )
  puts "importing election constituency results for #{polling_on} general election"
  
  # We find the general election this election forms part of.
  general_election = GeneralElection.find_by_polling_on( polling_on )
  
  # For each row in the results sheet ...
  CSV.foreach( "db/data/results/by-constituency/#{polling_on}.csv" ) do |row|
    
    # We store the new data we want to capture in the database.
    election_declaration_time = row[7]
    election_result_type = row[8]
    election_valid_vote_count = row[12]
    election_invalid_vote_count = row[13]
    election_majority = row[14]
    electorate_count = row[11]
    
    # We store the data we need to find the candidacy, quoted for SQL.
    winning_party_abbreviation = row[9]
    constituency_area_ons_code = ActiveRecord::Base.connection.quote( row[0] )
    
    # We find the winning political party.
    winning_political_party = PoliticalParty.where( "abbreviation =?", winning_party_abbreviation ).first
    
    # We find the candidacy.
    # NOTE: this works on the assumption that the winning candidate in a given election in a given general election is the only candidate certified by the winning party standing in a constituency with a given ONS code is unique.
    # This is not true for election: 1052
    # This query works by change there.
    candidacy = Candidacy.find_by_sql(
      "
        SELECT c.*
        FROM candidacies c, elections e, constituency_groups cg, constituency_areas ca, certifications cert
        WHERE c.election_id = e.id
        AND e.general_election_id = #{general_election.id}
        AND e.constituency_group_id = cg.id
        AND cg.constituency_area_id = ca.id
        AND ca.ons_code = #{constituency_area_ons_code}
        AND c.id = cert.candidacy_id
        AND cert.political_party_id = #{winning_political_party.id}
      "
    ).first
    
    # We annotate the election results.
    annotate_election_results( candidacy, election_declaration_time, election_result_type, election_valid_vote_count, election_invalid_vote_count, election_majority, electorate_count )
  end
end

# ## A method to import election constituency results with a named winner.
def import_election_constituency_results_winner_named( polling_on )
  puts "importing election constituency results for #{polling_on} general election"
  
  # We find the general election this election forms part of.
  general_election = GeneralElection.find_by_polling_on( polling_on )
  
  # For each row in the results sheet ...
  CSV.foreach( "db/data/results/by-constituency/#{polling_on}.csv" ) do |row|
    
    # We store the new data we want to capture in the database.
    election_declaration_time = row[7]
    election_result_type = row[11]
    election_valid_vote_count = row[15]
    election_invalid_vote_count = row[16]
    election_majority = row[17]
    electorate_count = row[14]
    
    # We store the data we need to find the candidacy, quoted for SQL.
    candidacy_candidate_family_name = ActiveRecord::Base.connection.quote( row[9] )
    candidacy_candidate_given_name = ActiveRecord::Base.connection.quote( row[8] )
    constituency_area_ons_code = ActiveRecord::Base.connection.quote( row[0] )
    
    # We find the candidacy.
    # NOTE: this works on the assumption that the name of the winning candidate standing in a given general election in a constituency with a given ONS code is unique, which appears to be true.
    candidacy = Candidacy.find_by_sql(
      "
        SELECT c.*
        FROM candidacies c, elections e, constituency_groups cg, constituency_areas ca
        WHERE c.candidate_given_name = #{candidacy_candidate_given_name}
        AND c.candidate_family_name = #{candidacy_candidate_family_name}
        AND c.election_id = e.id
        AND e.general_election_id = #{general_election.id}
        AND e.constituency_group_id = cg.id
        AND cg.constituency_area_id = ca.id
        AND ca.ons_code = #{constituency_area_ons_code}
      "
    ).first
    
    # We annotate the election results.
    annotate_election_results( candidacy, election_declaration_time, election_result_type, election_valid_vote_count, election_invalid_vote_count, election_majority, electorate_count )
  end
end

# ## A method to annotate elections with constituency level results.
def annotate_election_results( candidacy, election_declaration_time, election_result_type, election_valid_vote_count, election_invalid_vote_count, election_majority, electorate_count )
  
  # We mark the candidacy as being the winning candidacy.
  candidacy.is_winning_candidacy = true
  candidacy.save
  
  # We add the declaration time to the election the candidacy is in.
  candidacy.election.declaration_at = election_declaration_time
  candidacy.election.result_summary = election_result_type
  candidacy.election.valid_vote_count = election_valid_vote_count
  candidacy.election.invalid_vote_count = election_invalid_vote_count
  candidacy.election.majority = election_majority
  candidacy.election.save!
  
  # We create a new electorate.
  electorate = Electorate.new
  electorate.population_count = electorate_count
  electorate.election = candidacy.election
  electorate.constituency_group = candidacy.election.constituency_group
  electorate.save!
end

