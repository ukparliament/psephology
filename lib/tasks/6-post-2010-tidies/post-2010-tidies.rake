require 'csv'

task :post_2010_tidies => [
  :post_2010_tidies_update_parliaments,
  :reassign_yorkshire_parties,
  :split_scottish_greens,
  :regenerate_general_election_party_performances_for_greens,
  :remove_green_parties_from_country_general_election_party_performances,
  :regenerate_country_general_election_party_performances_for_greens,
  :remove_green_party_from_scottish_boundary_set_general_election_party_performances
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

# ## A task to split Sscottish Greens from Green Party.
task :split_scottish_greens => :environment do
  puts "splitting out scottish greens"
  
  # We attempt to find the Scottish Green Party.
  scottish_green_party = PoliticalParty.find_by_electoral_commission_id( 'PP130' )
  
  # Unless we find the Scottish Green Party ...
  unless scottish_green_party
  
    # ... we create it.
    scottish_green_party = PoliticalParty.new
    scottish_green_party.name = "Scottish Green Party"
    scottish_green_party.abbreviation = "Green"
    scottish_green_party.electoral_commission_id = "PP130"
    scottish_green_party.mnis_id = 1057
    scottish_green_party.save!
  end
  
  # We get all general elections with vote counts.
  general_elections = GeneralElection.all.where( 'valid_vote_count != 0' )
  
  # For each general elections...
  general_elections.each do |general_election|
    
    # ... we find certifications to the Green Party, of a candidate in an election, in the general election, in a constituency, in Scotland.
    certifications = Certification.find_by_sql(
      "
        SELECT cert.*
        FROM certifications cert, candidacies cand, elections e, constituency_groups cg, constituency_areas ca
        WHERE cert.political_party_id = 2
        AND cert.candidacy_id = cand.id
        AND cand.election_id = e.id
        AND e.general_election_id = #{general_election.id}
        AND e.constituency_group_id = cg.id
        AND cg.constituency_area_id = ca.id
        AND ca.country_id = 5
        
      "
    )
    
    # For each certification ...
    certifications.each do |certification|
      
      # ... we point the certification to the scottish green party.
      certification.political_party = scottish_green_party
      certification.save!
    end
  end
end

# ## Regenerate general election party performances for both Green parties.
task :regenerate_general_election_party_performances_for_greens => :environment do
  puts "regenerating general election party performaces for both green parties"
  
  # We get all the general elections with results.
  general_elections = GeneralElection.all.where( 'valid_vote_count != 0' )
  
  # We get the two Green parties.
  political_parties = PoliticalParty.all.where( "electoral_commission_id = 'PP63' OR electoral_commission_id = 'PP130'" )
  
  # For each political party ...
  political_parties.each do |political_party|
    
    # ... for each general election ...
    general_elections.each do |general_election|
      
      # ... we attempt to find the general election party performance for this party.
      general_election_party_performance = GeneralElectionPartyPerformance
        .all
        .where( "general_election_id = ?", general_election.id )
        .where( "political_party_id = ?", political_party.id )
        .first
      
      # Unless we find the general election party performance for this party ...
      unless general_election_party_performance
        
        # ... we create a general election party performance for this party.
        general_election_party_performance = GeneralElectionPartyPerformance.new
        general_election_party_performance.general_election = general_election
        general_election_party_performance.political_party = political_party
      end
      
      # We set all counts to zero.
      general_election_party_performance.constituency_contested_count = 0
      general_election_party_performance.constituency_won_count = 0
      general_election_party_performance.cumulative_vote_count = 0
      general_election_party_performance.cumulative_valid_vote_count = 0
      
      # For each election forming part of the general election ...
      general_election.elections.each do |election|
        
        # ... if a candidacy representing the political party is in the election ...
        if political_party.represented_in_election?( election )
          
          # ... we increment the constituency contested count.
          general_election_party_performance.constituency_contested_count += 1
          
          # We add the vote count of the party candidate to the cumulative vote count.
          general_election_party_performance.cumulative_vote_count += election.political_party_candidacy( political_party ).vote_count
          
          # We add the valid vote count in the election to the cumulative valid vote count.
          general_election_party_performance.cumulative_valid_vote_count += election.valid_vote_count
          
          # If the winning candidacy in the election represented the political party ...
          if political_party.won_election?( election )
          
            # ... we increment the constituency won count.
            general_election_party_performance.constituency_won_count += 1
          end
        end
        
        # We save the general election party performance record.
        general_election_party_performance.save!
      end
    end
  end
end

# ## A task to remove green parties from country general election party performances.
task :remove_green_parties_from_country_general_election_party_performances => :environment do
  puts "removing green parties from country general election party performances"
  
  # We get all general elections with vote counts.
  general_elections = GeneralElection.all.where( 'valid_vote_count != 0' )
  
  # We get the two Green parties.
  political_parties = PoliticalParty.all.where( "electoral_commission_id = 'PP63' OR electoral_commission_id = 'PP130'" )
  
  # We get all the countries.
  countries = Country.all
  
  # For each country ...
  countries.each do |country|
  
    # ... for each political party ...
    political_parties.each do |political_party|
    
      # ... for each general election ...
      general_elections.each do |general_election|
        
        # ... we attempt to find the general election party performance for this party in this country.
        country_general_election_party_performances = CountryGeneralElectionPartyPerformance
          .all
          .where( "general_election_id = ?", general_election.id )
          .where( "political_party_id = ?", political_party.id )
          .where( "country_id = ?", country.id )
          
        # For each general election party performance for this party in this country ...
        country_general_election_party_performances.each do |country_general_election_party_performance|
          
          # ... we destroy it.
          country_general_election_party_performance.destroy!
        end
      end
    end
  end
end

# ## Regenerate country general election party performances for both Green parties.
task :regenerate_country_general_election_party_performances_for_greens => :environment do
  puts "regenerating country general election party performaces for both green parties"
  
  # We get all the general elections with results.
  general_elections = GeneralElection.all.where( 'valid_vote_count != 0' )
  
  # We get the two Green parties.
  political_parties = PoliticalParty.all.where( "electoral_commission_id = 'PP63' OR electoral_commission_id = 'PP130'" )
  
  # We get all the countries.
  countries = Country.all
  
  # For each country ...
  countries.each do |country|
  
    # ... for each political party ...
    political_parties.each do |political_party|
    
      # ... for each general election ...
      general_elections.each do |general_election|
        
        # ... we attempt to find the general election party performance for this party in this country.
        country_general_election_party_performance = CountryGeneralElectionPartyPerformance
          .all
          .where( "general_election_id = ?", general_election.id )
          .where( "political_party_id = ?", political_party.id )
          .where( "country_id = ?", country.id )
          .first
        
        # ... for each election forming part of the general election in this country ...
        general_election.elections_in_country( country ).each do |election|
          
          # ... if a candidacy representing the political party is in the election ...
          if political_party.represented_in_election?( election )
            
            # ... we attempt to find the general election party performance for this party in this country.
            country_general_election_party_performance = CountryGeneralElectionPartyPerformance
              .all
              .where( "general_election_id = ?", general_election.id )
              .where( "political_party_id = ?", political_party.id )
              .where( "country_id = ?", country.id )
              .first
      
            # Unless we find the general election party performance for this party in this country ...
            unless country_general_election_party_performance
              
              # ... we create a general election party performance for this country, setting counts to zero.
              country_general_election_party_performance = CountryGeneralElectionPartyPerformance.new
              country_general_election_party_performance.general_election = general_election
              country_general_election_party_performance.political_party = political_party
              country_general_election_party_performance.country = country
              country_general_election_party_performance.constituency_contested_count = 0
              country_general_election_party_performance.constituency_won_count = 0
              country_general_election_party_performance.cumulative_vote_count = 0
            end
            
            # We increment the constituency contested count ...
            country_general_election_party_performance.constituency_contested_count += 1
            
            # ... and add the vote count of the party candidate to the cumulative vote count.
            country_general_election_party_performance.cumulative_vote_count += election.political_party_candidacy( political_party ).vote_count
          
            # If the winning candidacy in the election represented the political party ...
            if political_party.won_election?( election )
          
              # ... we increment the constituency won count,
              country_general_election_party_performance.constituency_won_count += 1
            end
            
            # We save the country general election party performance record.
            country_general_election_party_performance.save!
          end
        end
      end
    end
  end
end

# ## A task to remove the Green Party from the Scottish boundary set general election party performances.
task :remove_green_party_from_scottish_boundary_set_general_election_party_performances => :environment do
  puts "removing the Green Party from the Scottish boundary set general election party performances"
  
  # We get the England and Wales Green Party.
  political_party = PoliticalParty.all.where( "electoral_commission_id = 'PP63'" ).first
  
  # We get all the 2005 - 2024 Scottish boundary set.
  boundary_set = BoundarySet.find( 8 )
  
  # We get all general elections with vote counts.
  general_elections = GeneralElection.all.where( 'valid_vote_count != 0' )
  
  # For each general election ...
  general_elections.each do |general_election|
        
    # ... we attempt to find the boundary set election party performance for this party.
    boundary_set_general_election_party_performances = BoundarySetGeneralElectionPartyPerformance
      .all
      .where( "general_election_id = ?", general_election.id )
      .where( "political_party_id = ?", political_party.id )
      .where( "boundary_set_id = ?", boundary_set.id )
      
    # For each boundary set election party performance for this party in this boundary set ...
    boundary_set_general_election_party_performances.each do |boundary_set_general_election_party_performance|
      
      # ... we destroy it.
      boundary_set_general_election_party_performance.destroy!
    end
  end
end