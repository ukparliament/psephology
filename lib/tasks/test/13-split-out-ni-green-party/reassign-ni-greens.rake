task :reassign_ni_greens => [
  :reassign_ni_green_certifications,
  :remove_ew_green_party_from_bspp_in_ni,
  :remove_ew_green_party_from_cpp_in_ni,
  :generate_ni_green_party_cpp_in_ni,
  :remove_green_parties_from_gepp,
  :regenerate_green_parties_general_election_party_performances
]



# ## A task to reassign certifications from E&W Green Party to NI Green Party for candidates standing in elections in Northern Ireland.
task :reassign_ni_green_certifications => :environment do
  puts "reassigning certifications from E&W Green Party to NI Green Party for candidates standing in elections in Northern Ireland"
  
  # We find the Northern Ireland Green Party.
  to_party = PoliticalParty.find_by_name( 'Northern Ireland Green Party' )
  
  # We find the England and Wales Green Party.
  from_party = PoliticalParty.find_by_name( 'Green Party' )
  
  # We find Northern Ireland.
  country = Country.find_by_name( 'Northern Ireland' )
  
  # We find all certifications to the England and Wales Green Party for candidacies in elections in constituencies in Northern Ireland.
  certifications = Certification.find_by_sql(
    "
    SELECT cert.*
    FROM certifications cert, candidacies cand, elections e, constituency_groups cg, constituency_areas ca
    WHERE cert.adjunct_to_certification_id IS NULL
    AND cert.political_party_id = #{from_party.id}
    AND cert.candidacy_id = cand.id
    AND cand.election_id = e.id
    AND e.constituency_group_id = cg.id
    AND cg.constituency_area_id = ca.id
    AND ca.country_id = #{country.id}
    "
  )
  
  # For each certification ...
  certifications.each do |certification|
  
    # ... we reassign to the Northern Ireland Green Party.
    certification.political_party = to_party
    certification.save!
  end
end

# A task to remove the England and Wales Green Party from any boundary set general election party performance for a boundary set in Northern Ireland.
task :remove_ew_green_party_from_bspp_in_ni => :environment do
  puts "removing the England and Wales Green Party from any boundary set general election party performance for a boundary set in Northern Ireland"

  # We find the England and Wales Green Party.
  from_party = PoliticalParty.find_by_name( 'Green Party' )
  
  # We find Northern Ireland.
  country = Country.find_by_name( 'Northern Ireland' )
  
  # We get all boundary set party performances for the England and Wales Green Party for boundary sets in Northern Ireland.
  boundary_set_general_election_party_performances = BoundarySetGeneralElectionPartyPerformance.find_by_sql(
    "
      SELECT bsgepp.*
      FROM boundary_set_general_election_party_performances bsgepp, boundary_sets bs
      WHERE bsgepp.political_party_id = #{from_party.id}
      AND bsgepp.boundary_set_id = bs.id
      AND bs.country_id = #{country.id}
    "
  )
  
  # For each boundary set party performance for the England and Wales Green Party for boundary sets in Northern Ireland ...
  boundary_set_general_election_party_performances.each do |bsgepp|
  
    # ... we destroy it.
    bsgepp.destroy!
  end
end

# A task to remove the England and Wales Green Party from any country general election party performance in Northern Ireland.
task :remove_ew_green_party_from_cpp_in_ni => :environment do
  puts "removing the England and Wales Green Party from any country general election party performance in Northern Ireland"

  # We find the England and Wales Green Party.
  from_party = PoliticalParty.find_by_name( 'Green Party' )
  
  # We find Northern Ireland.
  country = Country.find_by_name( 'Northern Ireland' )
  
  # We find all country general election party performances for the England and Wales Green Party in Northern Ireland.
  country_general_election_party_performances = CountryGeneralElectionPartyPerformance.find_by_sql(
    "
      SELECT cgepp.*
      FROM country_general_election_party_performances cgepp
      WHERE cgepp.political_party_id = #{from_party.id}
      AND cgepp.country_id = #{country.id}
    "
  )
  
  # For each country general election party performance for the England and Wales Green Party in Northern Ireland ...
  country_general_election_party_performances.each do |cgepp|
  
    # ... we destroy it.
    cgepp.destroy!
  end
end

# A task to generate country general election party performances for the Northern Ireland Green Party.
task :generate_ni_green_party_cpp_in_ni => :environment do
  puts "generating country general election party performances for the Northern Ireland Green Party"

  # We find the Northern Ireland Green Party.
  to_party = PoliticalParty.find_by_name( 'Northern Ireland Green Party' )
  
  # We find Northern Ireland.
  country = Country.find_by_name( 'Northern Ireland' )
  
  # We find all general elections.
  general_elections = GeneralElection.all
  
  # For each general election ...
  general_elections.each do |general_election|
  
    # ... we attempt to find a country general election party performance in the general election in Northern Ireland for the Northern Ireland Green Party.
    country_general_election_party_performance = CountryGeneralElectionPartyPerformance.find_by_sql(
      "
        SELECT cgepp.*
        FROM country_general_election_party_performances cgepp
        WHERE cgepp.general_election_id = #{general_election.id}
        AND cgepp.country_id = #{country.id}
        AND cgepp.political_party_id = #{to_party.id}
        
      "
    ).first
    
    # Unless we find a country general election party performance in the general election in Northern Ireland for the Northern Ireland Green Party ...
    unless country_general_election_party_performance
    
      # We create a new country general election party performance.
      country_general_election_party_performance = CountryGeneralElectionPartyPerformance.new
      country_general_election_party_performance.political_party = to_party
      country_general_election_party_performance.country = country
      country_general_election_party_performance.general_election = general_election
    
      # ... we set the contested, won and vote counts to zero.
      contested = 0
      won = 0
      vote_count = 0
      
      # ... for each election forming part of the general election in this country ...
      general_election.elections_in_country( country ).each do |election|
      
        # ... if a candidacy representing the political party is in the election ...
        if to_party.represented_in_election?( election )
        
          # ... we increment the contested count ...
          contested += 1
          
          # ... and add the vote count of the party candidate to the cumulative vote count.
          vote_count += election.political_party_candidacy( to_party ).vote_count
          
          # If the winning candidacy in the election represented the political party ...
          if to_party.won_election?( election )
        
            # ... we increment the constituency won count,
            won += 1
          end
        end
      end
      
      # We assigned contested, won and vote count to the new country general election party performance
      country_general_election_party_performance.constituency_contested_count = contested
      country_general_election_party_performance.constituency_won_count = won
      country_general_election_party_performance.cumulative_vote_count = vote_count
      country_general_election_party_performance.save!
    end
  end
end






# A task to remove the Green Parties from all general election party performances.
task :remove_green_parties_from_gepp => :environment do
  puts "removing the England and Wales Green Party from all general election party performances"
  
  # We find all the Green Parties.
  green_parties = PoliticalParty.all.where( 'abbreviation =?', 'Green' )
  
  # We find all general elections.
  general_elections = GeneralElection.all
  
  # For each Green Party ...
  green_parties.each do |green_party|
  
    # ... for each general election ...
    general_elections.each do |general_election|
  
      # ... we find all general election party performances for this party in this general election.
      general_election_party_performances = GeneralElectionPartyPerformance.find_by_sql(
        "
          SELECT gepp.*
          FROM general_election_party_performances gepp
          WHERE gepp.political_party_id = #{green_party.id}
          AND gepp.general_election_id = #{general_election.id}
        "
      )
    
      # For each general election party performance for this party in this general election ...
      general_election_party_performances.each do |gepp|
    
        # ... we destroy it.
        gepp.destroy!
      end
    end
  end
end

# A task to regenerate general election party performances for the Green parties.
task :regenerate_green_parties_general_election_party_performances => :environment do
  puts "regenerating general election party performances for the Green parties"
  
  # We find all the Green Parties.
  green_parties = PoliticalParty.all.where( 'abbreviation =?', 'Green' )
  
  # We find all general elections.
  general_elections = GeneralElection.all
  
  # For each general_election ...
  general_elections.each do |general_election|
  
    # ... for each Green Party ...
    green_parties.each do |green_party|
    
      # ... we attempt to find the general election party performance for this party.
      general_election_party_performance = GeneralElectionPartyPerformance
        .all
        .where( "general_election_id = ?", general_election.id )
        .where( "political_party_id = ?", green_party.id )
        .first
    
      # Unless we find the general election party performance for this party ...
      unless general_election_party_performance
        
        # ... we create a general election party performance with all counts set to zero.
        general_election_party_performance = GeneralElectionPartyPerformance.new
        general_election_party_performance.general_election = general_election
        general_election_party_performance.political_party = green_party
        general_election_party_performance.constituency_contested_count = 0
        general_election_party_performance.constituency_won_count = 0
        general_election_party_performance.cumulative_vote_count = 0
        general_election_party_performance.cumulative_valid_vote_count = 0
      end
      
      # For each election forming part of the general election ...
      general_election.elections.each do |election|
        
        # ... if a candidacy representing the political party is in the election ...
        if green_party.represented_in_election?( election )
          
          # ... we increment the constituency contested count.
          general_election_party_performance.constituency_contested_count += 1
          
          # We add the vote count of the party candidate to the cumulative vote count.
          general_election_party_performance.cumulative_vote_count += election.political_party_candidacy( green_party ).vote_count
          
          # We add the valid vote count in the election to the cumulative valid vote count.
          general_election_party_performance.cumulative_valid_vote_count += election.valid_vote_count
          
          # If the winning candidacy in the election represented the political party ...
          if green_party.won_election?( election )
          
            # ... we increment the constituency won count.
            general_election_party_performance.constituency_won_count += 1
          end
        end
      end
        
      # We save the general election party performance record.
      general_election_party_performance.save!
    end
  end
end




