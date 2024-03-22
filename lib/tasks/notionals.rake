require 'csv'

task :notionals => [
  :import_new_constituencies,
  :generate_group_sets_for_new_constituencies,
  :import_constituency_area_overlaps,
  :populate_whole_of_booleans_on_constituency_area_overlaps,
  :import_notional_results,
  :generate_notional_vote_shares,
  :populate_result_positions_on_notional_candidacies,
  :assign_winners_to_notional_results,
  :generate_notional_general_election_cumulative_counts,
  :generate_notional_general_election_party_performances,
  :generate_english_region_notional_general_election_party_performances,
  :generate_country_notional_general_election_party_performances
  
  #:generate_boundary_set_notional_general_election_party_performances,
  #:infill_missing_boundary_set_notional_general_election_party_performances
]

# ## A task to import new constituencies.
task :import_new_constituencies => :environment do
  puts "importing new constituencies"
  
  # For each new constituency ...
  CSV.foreach( 'db/data/new-constituencies.csv' ) do |row|
    
    # ... we store the values from the spreadsheet.
    new_constituency_country_or_region = row[2].strip if row[2]
    new_constituency_name = row[3].strip if row[3]
    new_constituency_area_type = row[5].strip if row[5]
    new_constituency_geographic_code = row[7].strip if row[7]
    
    # We find the constituency area type.
    constituency_area_type = ConstituencyAreaType.find_by_area_type( new_constituency_area_type )
    
    # We find the country and region if in England.
    case new_constituency_country_or_region
    when 'Wales'
      country = Country.find_by_name( 'Wales' )
    when "Scotland"
      country = Country.find_by_name( 'Scotland' )
    when "Northern Ireland"
      country = Country.find_by_name( 'Northern Ireland' )
    else
      country = Country.find_by_name( 'England' )
      english_region = EnglishRegion.find_by_name( new_constituency_country_or_region )
    end
    
    # We find the boundary set.
    boundary_set = get_boundary_set( country.id, 'new' )
    
    # We create the new constituency area.
    constituency_area = ConstituencyArea.new
    constituency_area.name = new_constituency_name
    constituency_area.geographic_code = new_constituency_geographic_code
    constituency_area.constituency_area_type = constituency_area_type
    constituency_area.country = country
    constituency_area.english_region = english_region if english_region
    constituency_area.boundary_set = boundary_set
    constituency_area.save!
    
    # We create the new constituency group.
    constituency_group = ConstituencyGroup.new
    constituency_group.name = new_constituency_name
    constituency_group.constituency_area = constituency_area
    constituency_group.save!
  end
end

# ## A task to generate group sets for new constituencies.
task :generate_group_sets_for_new_constituencies => :environment do
  puts "generating group sets for new constituencies"
  
  # We get all the constituency groups with no constituency group set membership.
  constituency_groups = ConstituencyGroup.all.where( 'constituency_group_set_id IS NULL' )
  
  # For each constituency group ...
  constituency_groups.each do |constituency_group|
    
    # ... we get the boundary set.
    boundary_set = constituency_group.boundary_set
    
    # If the boundary_set has a start date ...
    if boundary_set.start_on
      
      # ... we attempt to find a constituency group set for this country with this start date.
      constituency_group_set = ConstituencyGroupSet.all.where( "start_on = ?", boundary_set.start_on ).where( "country_id = ?", boundary_set.country_id ).first
      
    # Otherwise, if the boundary set has no start date ...
    else
      
      # ... we attempt to find a constituency group set for this country with a NULL start date.
      constituency_group_set = ConstituencyGroupSet.all.where( "start_on IS NULL" ).where( "country_id = ?", boundary_set.country_id ).first
    end
    
    # Unless we find a constituency group set for this country with this start date ...
    unless constituency_group_set
    
      # ... we create a new constituency group set.
      constituency_group_set = ConstituencyGroupSet.new
      constituency_group_set.start_on = boundary_set.start_on
      constituency_group_set.end_on = boundary_set.end_on
      constituency_group_set.country = boundary_set.country
      constituency_group_set.save!
      
      # We get the legislation items establishing the boundary set.
      legislation_items = boundary_set.establishing_legislation
      
      # For each legislation item ...
      legislation_items.each do |legislation_item|
        
        # ... we create a new constituency group set legislation item.
        constituency_group_set_legislation_item = ConstituencyGroupSetLegislationItem.new
        constituency_group_set_legislation_item.constituency_group_set = constituency_group_set
        constituency_group_set_legislation_item.legislation_item = legislation_item
        constituency_group_set_legislation_item.save!
      end
    end
    
    # We attach the constituency group to its constituency group set.
    constituency_group.constituency_group_set = constituency_group_set
    constituency_group.save!
  end
end

# ## A task to import constituency area overlaps.
task :import_constituency_area_overlaps => :environment do
  puts "importing constituency area overlaps"
  
  # For each constituency area overlap ...
  CSV.foreach( 'db/data/constituency-area-overlaps.csv' ) do |row|
    
    # ... we store the values from the spreadsheet.
    from_constituency_area_geographic_code = row[1].strip if row[1]
    to_constituency_area_geographic_code = row[3].strip if row[3]
    from_constituency_area_residential_overlap = row[5].strip if row[5]
    to_constituency_area_residential_overlap = row[6].strip if row[6]
    from_constituency_area_geographic_overlap = row[7].strip if row[7]
    to_constituency_area_geographic_overlap = row[8].strip if row[8]
    from_constituency_area_population_overlap = row[9].strip if row[9]
    to_constituency_area_population_overlap = row[10].strip if row[10]
    
    # If dissolution has happened ...
    if has_dissolution_happened?
    
      # ... we find the from constituency area in the boundary set with a non-NULL start date and a non-NULL end date ...
      from_constituency_area = ConstituencyArea.find_by_sql(
        "
          SELECT ca.*
          FROM constituency_areas ca, boundary_sets bs
          WHERE ca.geographic_code = '#{from_constituency_area_geographic_code}'
          AND ca.boundary_set_id = bs.id
          AND bs.start_on IS NOT NULL
          AND bs.end_on IS NOT NULL
        "
      ).first
  
      # ... and we find the to constituency area in the boundary set with a non-NULL start date and a NULL end date ...
      to_constituency_area = ConstituencyArea.find_by_sql(
        "
          SELECT ca.*
          FROM constituency_areas ca, boundary_sets bs
          WHERE ca.geographic_code = '#{to_constituency_area_geographic_code}'
          AND ca.boundary_set_id = bs.id
          AND bs.start_on IS NOT NULL
          AND bs.end_on IS NULL
        "
      ).first
      
    # Otherwise, if dissolution has not happened ...
    else
    
      # ... we find the from constituency area in the boundary set with a non-NULL start date and a NULL end date ...
      from_constituency_area = ConstituencyArea.find_by_sql(
        "
          SELECT ca.*
          FROM constituency_areas ca, boundary_sets bs
          WHERE ca.geographic_code = '#{from_constituency_area_geographic_code}'
          AND ca.boundary_set_id = bs.id
          AND bs.start_on IS NOT NULL
          AND bs.end_on IS NULL
        "
      ).first
  
      # ... and we find the to constituency area in the boundary set with a NULL start date and a NULL end date ...
      to_constituency_area = ConstituencyArea.find_by_sql(
        "
          SELECT ca.*
          FROM constituency_areas ca, boundary_sets bs
          WHERE ca.geographic_code = '#{to_constituency_area_geographic_code}'
          AND ca.boundary_set_id = bs.id
          AND bs.start_on IS NULL
          AND bs.end_on IS NULL
        "
      ).first
    end
    
    # We create a new constituency area overlap.
    constituency_area_overlap = ConstituencyAreaOverlap.new
    constituency_area_overlap.from_constituency_area_id = from_constituency_area.id
    constituency_area_overlap.to_constituency_area_id = to_constituency_area.id
    constituency_area_overlap.from_constituency_residential = from_constituency_area_residential_overlap
    constituency_area_overlap.to_constituency_residential = to_constituency_area_residential_overlap
    constituency_area_overlap.from_constituency_geographical = from_constituency_area_geographic_overlap
    constituency_area_overlap.to_constituency_geographical = to_constituency_area_geographic_overlap
    constituency_area_overlap.from_constituency_population = from_constituency_area_population_overlap
    constituency_area_overlap.to_constituency_population = to_constituency_area_population_overlap
    constituency_area_overlap.save!
  end
end

# ## A task to populate whole of booleans on constituency area overlaps.
task :populate_whole_of_booleans_on_constituency_area_overlaps => :environment do
  puts "populating whole of booleans on constituency area overlaps"
  
  # We get all the constituency area overlaps.
  constituency_area_overlaps = ConstituencyAreaOverlap.all
  
  # For each constituency area overlap ...
  constituency_area_overlaps.each do |constituency_area_overlap|
    
    # ... we get the from constituency area.
    from_constituency_area = constituency_area_overlap.from_constituency_area
    
    # If the from constituency area has one overlap with a future constituency area ...
    if from_constituency_area.overlaps_to.size == 1
      
      # ... we set the constituency area overlap formed from whole of boolean to true.
      constituency_area_overlap.formed_from_whole_of = true
      constituency_area_overlap.save!
    end
    
    # We get the to constituency area.
    to_constituency_area = constituency_area_overlap.to_constituency_area
    
    # If the to constituency area has one overlap with a past constituency area ...
    if to_constituency_area.overlaps_from.size == 1
      
      # ... we set the constituency area overlap forms whole of boolean to true.
      constituency_area_overlap.forms_whole_of = true
      constituency_area_overlap.save!
    end
  end
end










# ## A task to import notional results.
task :import_notional_results => :environment do
  puts "importing notional results"
  
  # We find the notional general election.
  general_election = GeneralElection.all.where( 'is_notional IS TRUE' ).first
  
  # For each result ...
  CSV.foreach( 'db/data/results-by-parliament/58/notional-general-election/results.csv' ) do |row|
    
    # ... we store the values from the spreadsheet.
    notional_election_constituency_area_geographic_code = row[2].strip if row[2]
    notional_election_country_name = row[5].strip if row[5]
    notional_election_turnout = row[7].strip if row[7]
    notional_election_electorate_population_count = row[8].strip if row[8]
    notional_election_valid_vote_count = row[9].strip if row[9]
    notional_election_majority = row[10].strip if row[10]
    notional_election_candidacy_party_code = row[11].strip if row[11]
    notional_election_candidacy_vote_count = row[12].strip if row[12]
    notional_election_candidacy_party_abbreviation = row[13].strip if row[13]
    notional_election_candidacy_party_name = row[14].sub( "'", "''" ).strip if row[14]
    notional_election_candidacy_mnis_id = row[15].strip if row[15]
    
    # We find the country.
    country = Country.find_by_name( notional_election_country_name )
    
    # We find the boundary set.
    boundary_set = get_boundary_set( country.id, 'new' )
    
    # We find the constituency group.
    constituency_group = ConstituencyGroup.find_by_sql(
      "
        SELECT cg.*
        FROM constituency_groups cg, constituency_areas ca
        WHERE cg.constituency_area_id = ca.id
        AND ca.boundary_set_id = #{boundary_set.id}
        AND ca.geographic_code = '#{notional_election_constituency_area_geographic_code}'
      "
    ).first
    
    # We attempt to find the electorate.
    electorate = Electorate.find_by_sql(
      "
        SELECT *
        FROM electorates
        WHERE constituency_group_id = #{constituency_group.id}
        AND population_count = #{notional_election_electorate_population_count}
      "
    ).first
    
    # Unless we find the electorate ...
    unless electorate
      
      # ... we create a new electorate.
      electorate = Electorate.new
      electorate.population_count = notional_election_electorate_population_count
      electorate.constituency_group = constituency_group
      electorate.save!
    end
    
    # We attempt to find the election ...
    election = Election.find_by_sql(
      "
        SELECT * 
        FROM elections
        WHERE general_election_id = #{general_election.id}
        AND constituency_group_id = #{constituency_group.id}
      "
    ).first
    
    # Unless we find the election ...
    unless election
      
      # ... we create a new election
      election = Election.new
      election.polling_on = general_election.polling_on
      election.is_notional = true
      election.valid_vote_count = notional_election_valid_vote_count
      election.majority = notional_election_majority
      election.constituency_group = constituency_group
      election.general_election = general_election
      election.electorate = electorate
      election.parliament_period = general_election.parliament_period
      election.save!
    end
    
    # If the party code is neither TOTOTHV nor MAXOTHV ...
    if notional_election_candidacy_party_code != 'TOTOTHV' and notional_election_candidacy_party_code != 'MAXOTHV'
      
      # ... we know this is a candidate we want to capture.
      # We start to create a candidacy.
      candidacy = Candidacy.new
      candidacy.is_notional = true
      candidacy.vote_count = notional_election_candidacy_vote_count
      candidacy.election = election
      
      # If the party name is Commons Speaker ...
      if notional_election_candidacy_party_name == 'Commons Speaker'
        
        # ... we flag the candidacy as Commons Speaker ...
        candidacy.is_standing_as_commons_speaker = true
        
        # ... and save it.
        candidacy.save!
      
      # Otherwise, if the MNIS ID is 8 (Independent) ....
      elsif notional_election_candidacy_mnis_id == '8'
        
        # ... we flag the candidacy as independent ...
        candidacy.is_standing_as_independent = true
        
        # ... and save it.
        candidacy.save!
        
      # Otherwise, if the MNIS ID is not recorded as 'NA' and is not 8 ...
      else
        
        # ... we save the candidacy.
        candidacy.save!
        
        # ... we attempt to find the political party.
        political_party = PoliticalParty.find_by_sql(
          "
            SELECT *
            FROM political_parties
            WHERE mnis_id = '#{notional_election_candidacy_mnis_id}'
          "
        ).first
        
        # If we don't find the political party ...
        unless political_party
          
          # ... we flag an alert.
          puts "*************** party #{notional_election_candidacy_mnis_id} not found ***************"
          
        # Otherwise, if we do find the political party ...
        else  
          
          # ... we create a new certification.
          certification = Certification.new
          certification.candidacy = candidacy
          certification.political_party = political_party
          certification.save! 
        end
      end
    end
  end
end

# ## A task to generate notional vote shares.
task :generate_notional_vote_shares => :environment do
  puts "generating notional vote shares"
  
  # We get all notional elections.
  notional_elections = Election.all.where( 'is_notional IS TRUE' )
  
  # For each notional candidacy ...
  notional_elections.each do |notional_election|
    
    # ... for each candidacy in a notional election ...
    notional_election.candidacies.each do |notional_candidacy|
      
      # ... we calculate the vote share ...
      vote_share = notional_candidacy.vote_count.to_f / notional_election.valid_vote_count.to_f
      
      # ... and save it to the notional candidacy.
      notional_candidacy.vote_share = vote_share
      notional_candidacy.save!
    end
  end
end

# ## A task to populate result positions on notional candidacies.
task :populate_result_positions_on_notional_candidacies => :environment do
  puts "populating result positions on notional candidacies"
  
  # We get all the notional elections.
  elections = Election.all.where( 'is_notional IS TRUE' )
  
  # For each election ...
  elections.each do |election|
    
    # ... we set the result position to zero.
    result_position = 0
    
    # For each candidacy result in the election ...
    election.results.each do |result|
      
      # ... we increment the result position ...
      result_position += 1
      
      # ... and save the result position on the candidacy.
      result.result_position = result_position
      result.save!
    end
  end
end

# ## A task to assign winners to notional results.
task :assign_winners_to_notional_results => :environment do
  puts "assigning winners to notional results"
  
  # We find all notional general elections.
  notional_general_elections = GeneralElection.all.where( 'is_notional IS TRUE' )
  
  # For each election in a notional general election ...
  notional_general_elections.each do |notional_general_election|
    
    # ... for each election in a notional general election ...
    notional_general_election.elections.each do |notional_election|
      
      # ... for each candidacy in a notional election ...
      notional_election.candidacies.each do |notional_candidacy|
        
        # ... if the candidacy has result position 1 ...
        if notional_candidacy.result_position == 1
          
          # ... we mark the candidacy as being the winning candidacy.
          notional_candidacy.is_winning_candidacy = true
          notional_candidacy.save!
        end
      end
    end
  end
end

# ## A task to generate notional general election cumulative counts.
task :generate_notional_general_election_cumulative_counts => :environment do
  puts "generating notional general election cumulative counts"
  
  # We get all notional general elections.
  notional_general_elections = GeneralElection.all.where( 'is_notional IS TRUE' )
  
  # For each notional general election ...
  notional_general_elections.each do |notional_general_election|
    
    # ... we set the valid vote count, the invalid vote count and the electorate population count to zero.
    valid_vote_count = 0
    invalid_vote_count = 0
    electorate_population_count = 0
    
    # For each notional election in the notional general election ...
    notional_general_election.elections.each do |notional_election|
      
      # ... we add the valid vote count, invalid vote count and electorate population count.
      valid_vote_count += notional_election.valid_vote_count
      invalid_vote_count += notional_election.invalid_vote_count if notional_election.invalid_vote_count
      electorate_population_count += notional_election.electorate_population_count
    end
    
    # We save the cumulative counts.
    notional_general_election.valid_vote_count = valid_vote_count
    notional_general_election.invalid_vote_count = invalid_vote_count
    notional_general_election.electorate_population_count = electorate_population_count
    notional_general_election.save!
  end
end

# ## A task to generate notional general election party performances.
task :generate_notional_general_election_party_performances => :environment do
  puts "generating notional general election party performances"
  
  # We get all the notional general elections.
  notional_general_elections = GeneralElection.all.where( 'is_notional IS TRUE')
  
  # We get all the political parties.
  political_parties = PoliticalParty.all
  
  # For each political party ...
  political_parties.each do |political_party|
    
    # ... for each notional general election ...
    notional_general_elections.each do |notional_general_election|
      
      # ... we attempt to find the notional general election party performance for this party.
      notional_general_election_party_performance = GeneralElectionPartyPerformance
        .all
        .where( "general_election_id = ?", notional_general_election.id )
        .where( "political_party_id = ?", political_party.id )
        .first
      
      # Unless we find the notional general election party performance for this party ...
      unless notional_general_election_party_performance
        
        # ... we create a notional general election party performance with all counts set to zero.
        notional_general_election_party_performance = GeneralElectionPartyPerformance.new
        notional_general_election_party_performance.general_election = notional_general_election
        notional_general_election_party_performance.political_party = political_party
        notional_general_election_party_performance.constituency_contested_count = 0
        notional_general_election_party_performance.constituency_won_count = 0
        notional_general_election_party_performance.cumulative_vote_count = 0
        notional_general_election_party_performance.cumulative_valid_vote_count = 0
      end
      
      # For each notional election forming part of the notional general election ...
      notional_general_election.elections.each do |notional_election|
        
        # ... if a candidacy representing the political party is in the election ...
        if political_party.represented_in_election?( notional_election )
          
          # ... we increment the constituency contested count.
          notional_general_election_party_performance.constituency_contested_count += 1
          
          # We add the vote count of the party candidate to the cumulative vote count.
          notional_general_election_party_performance.cumulative_vote_count += notional_election.political_party_candidacy( political_party ).vote_count
          
          # We add the valid vote count in the notional election to the cumulative valid vote count.
          notional_general_election_party_performance.cumulative_valid_vote_count += notional_election.valid_vote_count
          
          # If the winning candidacy in the notional election represented the political party ...
          if political_party.won_election?( notional_election )
          
            # ... we increment the constituency won count.
            notional_general_election_party_performance.constituency_won_count += 1
          end
        end
        
        # We save the general election party performance record.
        notional_general_election_party_performance.save!
      end
    end
  end
end

# ## A task to generate English region notional general election party performances.
task :generate_english_region_notional_general_election_party_performances => :environment do
  puts "generating english region notional general election party performances"
  
  # We get all the notional general elections.
  notional_general_elections = GeneralElection.all.where( 'is_notional IS TRUE' )
  
  # We get all the political parties.
  political_parties = PoliticalParty.all
  
  # We get all the english regions.
  english_regions = EnglishRegion.all
  
  # For each english region ...
  english_regions.each do |english_region|
  
    # ... for each political party ...
    political_parties.each do |political_party|
    
      # ... for each notional general election ...
      notional_general_elections.each do |notional_general_election|
        
        # ... for each notional election forming part of the notional general election in this English region ...
        notional_general_election.elections_in_english_region( english_region ).each do |notional_election|
          
          # ... if a candidacy representing the political party is in the notional election ...
          if political_party.represented_in_election?( notional_election )
            
            # ... we attempt to find the notional general election party performance for this party in this English region.
            english_region_notional_general_election_party_performance = EnglishRegionGeneralElectionPartyPerformance
              .all
              .where( "general_election_id = ?", notional_general_election.id )
              .where( "political_party_id = ?", political_party.id )
              .where( "english_region_id = ?", english_region.id )
              .first
      
            # Unless we find the notional general election party performance for this party in this English region ...
            unless english_region_notional_general_election_party_performance
              
              # ... we create a notional general election party performance for this English region with all counts set to zero.
              english_region_notional_general_election_party_performance = EnglishRegionGeneralElectionPartyPerformance.new
              english_region_notional_general_election_party_performance.general_election = notional_general_election
              english_region_notional_general_election_party_performance.political_party = political_party
              english_region_notional_general_election_party_performance.english_region = english_region
              english_region_notional_general_election_party_performance.constituency_contested_count = 0
              english_region_notional_general_election_party_performance.constituency_won_count = 0
              english_region_notional_general_election_party_performance.cumulative_vote_count = 0
            end
            
            # We increment the constituency contested count ...
            english_region_notional_general_election_party_performance.constituency_contested_count += 1
            
            # ... and add the vote count of the party candidate to the cumulative vote count.
            english_region_notional_general_election_party_performance.cumulative_vote_count += notional_election.political_party_candidacy( political_party ).vote_count
          
            # If the winning candidacy in the election represented the political party ...
            if political_party.won_election?( notional_election )
          
              # ... we increment the constituency won count,
              english_region_notional_general_election_party_performance.constituency_won_count += 1
            end
            
            # We save the english region general election party performance record.
            #english_region_notional_general_election_party_performance.save!
          end
        end
      end
    end
  end
end

# ## A task to generate country notional general election party performances.
task :generate_country_notional_general_election_party_performances => :environment do
  puts "generating country notional general election party performances"
  
  # We get all the notional general elections.
  notional_general_elections = GeneralElection.all.where( 'is_notional IS TRUE' )
  
  # We get all the political parties.
  political_parties = PoliticalParty.all
  
  # We get all the countries.
  countries = Country.all
  
  # For each country ...
  countries.each do |country|
  
    # ... for each political party ...
    political_parties.each do |political_party|
    
      # ... for each notional general election ...
      notional_general_elections.each do |notional_general_election|
        
        # ... for each notional election forming part of the notional general election in this country ...
        notional_general_election.elections_in_country( country ).each do |notional_election|
          
          # ... if a candidacy representing the political party is in the notional election ...
          if political_party.represented_in_election?( notional_election )
            
            # ... we attempt to find the notional general election party performance for this party in this country.
            country_notional_general_election_party_performance = CountryGeneralElectionPartyPerformance
              .all
              .where( "general_election_id = ?", notional_general_election.id )
              .where( "political_party_id = ?", political_party.id )
              .where( "country_id = ?", country.id )
              .first
      
            # Unless we find the notional general election party performance for this party in this country ...
            unless country_notional_general_election_party_performance
              
              # ... we create a notional general election party performance for this country with all counts set to zero.
              country_notional_general_election_party_performance = CountryGeneralElectionPartyPerformance.new
              country_notional_general_election_party_performance.general_election = notional_general_election
              country_notional_general_election_party_performance.political_party = political_party
              country_notional_general_election_party_performance.country = country
              country_notional_general_election_party_performance.constituency_contested_count = 0
              country_notional_general_election_party_performance.constituency_won_count = 0
              country_notional_general_election_party_performance.cumulative_vote_count = 0
            end
            
            # We increment the constituency contested count ...
            country_notional_general_election_party_performance.constituency_contested_count += 1
            
            # ... and add the vote count of the party candidate to the cumulative vote count.
            country_notional_general_election_party_performance.cumulative_vote_count += notional_election.political_party_candidacy( political_party ).vote_count
          
            # If the winning candidacy in the notional election represented the political party ...
            if political_party.won_election?( notional_election )
          
              # ... we increment the constituency won count,
              country_notional_general_election_party_performance.constituency_won_count += 1
            end
            
            # We save the country notional general election party performance record.
            country_notional_general_election_party_performance.save!
          end
        end
      end
    end
  end
end