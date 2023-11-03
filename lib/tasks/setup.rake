require 'csv'

task :setup => [
  :import_genders,
  :import_general_elections,
  :import_election_candidacy_results,
  :import_boundary_sets,
  :attach_constituency_areas_to_boundary_sets,
  :import_election_constituency_results,
  :assign_non_party_flags_to_result_summaries,
  :import_expanded_result_summaries,
  :generate_general_election_party_performances,
  :generate_general_election_cumulative_counts,
  :associate_result_summaries_with_political_parties,
  :generate_political_party_switches,
  :generate_graphviz
]


# ## A task to import legislation types.
task :import_legislation_types => :environment do
  puts "importing legislation types"
  CSV.foreach( 'db/data/legislation/types.csv' ) do |row|
    legislation_type = LegislationType.new
    legislation_type.abbreviation = row[0]
    legislation_type.label = row[1]
    legislation_type.save
  end
end

# ## A task to import Acts of Parliament.
task :import_acts => :environment do
  puts "importing acts of parliament"
  
  # We find the legislation type.
  legislation_type = LegislationType.find_by_abbreviation( 'acts' )
  
  CSV.foreach( 'db/data/legislation/acts.csv' ) do |row|
    legislation_item = LegislationItem.new
    legislation_item.title = row[0]
    legislation_item.uri = row[1]
    legislation_item.url_key = row[2]
    legislation_item.royal_assent_on = row[3]
    legislation_item.statute_book_on = row[3]
    legislation_item.legislation_type = legislation_type
    legislation_item.save
  end
end

# ## A task to import Orders in Council.
task :import_orders => :environment do
  puts "importing orders in council"
  
  # We find the legislation type.
  legislation_type = LegislationType.find_by_abbreviation( 'orders' )
  
  CSV.foreach( 'db/data/legislation/orders.csv' ) do |row|
    legislation_item = LegislationItem.new
    legislation_item.title = row[0]
    legislation_item.uri = row[1]
    legislation_item.url_key = row[2]
    legislation_item.made_on = row[3]
    legislation_item.statute_book_on = row[3]
    legislation_item.legislation_type = legislation_type
    legislation_item.save
    
    # If the order has one enabling Act ...
    if row[4]
      
      # ... we find the enabling Act ...
      enabling_act = LegislationItem.find_by_title( row[4] )
      
      # ... and create a new enabling.
      enabling = Enabling.new
      enabling.enabling_legislation_id = enabling_act.id
      enabling.enabled_legislation_id = legislation_item.id
      enabling.save
    end
    
    # If the order has two enabling Acts ...
    if row[5]
      
      # ... we find the enabling Act ...
      enabling_act = LegislationItem.find_by_title( row[5] )
      
      # ... and create a new enabling.
      enabling = Enabling.new
      enabling.enabling_legislation_id = enabling_act.id
      enabling.enabled_legislation_id = legislation_item.id
      enabling.save
    end
  end
end

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
      order_in_council.url_key = order_in_council.generate_url_key
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

# ## A take to assign non-party flags - Speaker and Independent - to result summaries.
task :assign_non_party_flags_to_result_summaries => :environment do
  puts "assigning non-party flags - Speaker and Independent - to result summaries"
  
  # We get all the result summaries.
  result_summaries = ResultSummary.all
  
  # For each result summary ...
  result_summaries.each do |result_summary|
    
    # ... we want to deal with Labour / Co-op as Labour, so we remove any mention of ' Coop'.
    result_summary.short_summary.gsub!( ' Coop', '' )
    
    # If the short summary is two words long ...
    if result_summary.short_summary.split( ' ' ).size == 2
      
      # ... we know this is a holding party.
      # If the first word indicates Commons Speaker ...
      if result_summary.short_summary.split( ' ' ).first == 'Spk'
        
        # ... we update the result summary to say Speaker holding.
        result_summary.is_from_commons_speaker = true
        result_summary.is_to_commons_speaker = true
        result_summary.save!
      
      # Otherwise, if the first word indicates Independent ...
      elsif result_summary.short_summary.split( ' ' ).first == 'Ind'
        
        # ... we update the result summary to say Independent holding.
        result_summary.is_from_independent = true
        result_summary.is_to_independent = true
        result_summary.save!
      end
      
    # Otherwise, if the short summary is four words long ...
    elsif result_summary.short_summary.split( ' ' ).size == 4
      
      # ... we know this is a gaining party.
      # If the first word indicates Commons Speaker ...
      if result_summary.short_summary.split( ' ' ).first == 'Spk'
        
        # ... we update the result summary to say Speaker gaining.
        result_summary.is_to_commons_speaker = true
        result_summary.save!
      
      # Otherwise, if the first word indicates Independent ...
      elsif result_summary.short_summary.split( ' ' ).first == 'Ind'
        
        # ... we update the result summary to say Independent gaining.
        result_summary.is_to_independent = true
        result_summary.save!
      end
      
      # If the last word indicates Commons Speaker ...
      if result_summary.short_summary.split( ' ' ).last == 'Spk'
        
        # ... we update the result summary to say Speaker losing.
        result_summary.is_from_commons_speaker = true
        result_summary.save!
      
      # Otherwise, if the last word indicates Independent ...
      elsif result_summary.short_summary.split( ' ' ).last == 'Ind'
        
        # ... we update the result summary to say Independent losing.
        result_summary.is_from_independent = true
        result_summary.save!
      end
    end
  end
end

# ## A task to import expanded result summaries.
task :import_expanded_result_summaries => :environment do
  puts "importing expanded result summaries"
  
  # For each result summary ...
  CSV.foreach( 'db/data/result_summaries.csv' ) do |row|
    
    # ... we find the result_summary.
    result_summary = ResultSummary.where( "short_summary = ?", row[0] ).first
    
    # We set the expanded summary.
    result_summary.summary = row[1]
    result_summary.save!
  end
end

# ## A task to generate general election party performances.
task :generate_general_election_party_performances => :environment do
  puts "importing general election party performances"
  
  # We get all the general elections.
  general_elections = GeneralElection.all
  
  # We get all the political parties.
  political_parties = PoliticalParty.all
  
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
        general_election_party_performance = GeneralElectionPartyPerformance.new
        general_election_party_performance.general_election = general_election
        general_election_party_performance.political_party = political_party
        general_election_party_performance.constituency_contested_count = 0
        general_election_party_performance.constituency_won_count = 0
        general_election_party_performance.cumulative_vote_count = 0
      end
      
      # For each election forming part of the general election ...
      general_election.elections.each do |election|
        
        # ... if a candidacy representing the political party is in the election ...
        if political_party.represented_in_election?( election )
          
          # ... we increment the constituency contested count.
          general_election_party_performance.constituency_contested_count += 1
          
          
          # ... and add the vote count of the party candidate to the cumulative vote count.
          general_election_party_performance.cumulative_vote_count = general_election_party_performance.cumulative_vote_count + election.political_party_candidacy( political_party ).vote_count
          
          # If the winning candidacy in the election represented the political party ...
          if political_party.won_election?( election )
          
            # ... we increment the constituency won count,
            general_election_party_performance.constituency_won_count += 1
          end
        end
        
        # We save the general election party performance record.
        general_election_party_performance.save!
      end
    end
  end
end

# ## A task to generate general election cumulatve counts.
task :generate_general_election_cumulative_counts => :environment do
  puts "generating general election cumulative counts"
  
  # We get all general elections.
  general_elections = GeneralElection.all
  
  # For each general election.
  general_elections.each do |general_election|
    
    # ... we set the valid vote count, the invalid vote count and the electorate population count to zero.
    valid_vote_count = 0
    invalid_vote_count = 0
    electorate_population_count = 0
    
    # For each election in the general election ...
    general_election.elections.each do |election|
      
      # ... we add the valid vote count, invalid vote count and electorate population count.
      valid_vote_count += election.valid_vote_count
      invalid_vote_count += election.invalid_vote_count
      electorate_population_count += election.electorate_population_count
    end
    
    # We save the cumulative counts.
    general_election.valid_vote_count = valid_vote_count
    general_election.invalid_vote_count = invalid_vote_count
    general_election.electorate_population_count = electorate_population_count
    general_election.save
  end
end

# ## A task to associate result summaries with political parties.
task :associate_result_summaries_with_political_parties => :environment do
  puts "associate result summaries with political parties"
  
  # We get all the result summaries.
  result_summaries = ResultSummary.all
  
  # For each result summary ....
  result_summaries.each do |result_summary|
    
    # We want to deal with Labour / Co-op as Labour, so we remove any mention of ' Coop'.
    result_summary.short_summary.gsub!( ' Coop', '' )
    
    # ... if the short summary is two words long ...
    if result_summary.short_summary.split( ' ' ).size == 2
      
      # ... it must be a holding.
      # Unless the result summary is from the Commons Speaker or from an independent ...
      unless result_summary.is_from_commons_speaker == true || result_summary.is_from_independent == true
        
        # We get the party abbreviation ...
        party_abbreviation = result_summary.short_summary.split( ' ' ).first
      
        # ... and attempt to find the political party.
        holding_political_party = PoliticalParty.find_by_abbreviation( party_abbreviation )
      
        # We associate the result summary with the political party.
        result_summary.from_political_party_id = holding_political_party.id
        result_summary.to_political_party_id = holding_political_party.id
      end
      
      
    # Otherwise, if the short summary is four words long ...
    elsif result_summary.short_summary.split( ' ' ).size == 4
      
      # ... it must be a gain from.
      # Unless the result summary is a gain by the Commons Speaker or by an independent ...
      unless result_summary.is_to_commons_speaker == true || result_summary.is_to_independent == true
        
        # ... we get the gaining party abbreviation ...
        gaining_party_abbreviation = result_summary.short_summary.split( ' ' ).first
      
        # ... and attempt to find the political party.
        gaining_political_party = PoliticalParty.find_by_abbreviation( gaining_party_abbreviation )
      
        # We associate the result summary with the gaining political party.
        result_summary.to_political_party_id = gaining_political_party.id
      end
      
      # Unless the result summary is a loss by the Commons Speaker or by an independent ...
      unless result_summary.is_from_commons_speaker == true || result_summary.is_from_independent == true
      
        # ... we get the losing party abbreviation ...
        losing_party_abbreviation = result_summary.short_summary.split( ' ' ).last
      
        # ... and attempt to find the political party.
        losing_political_party = PoliticalParty.find_by_abbreviation( losing_party_abbreviation )
      
        # We associate the result summary with the losing political party.
        result_summary.from_political_party_id = losing_political_party.id
      end
    end
    
    # We save the result summary.
    result_summary.save!
  end
end

# ## A task to generate political party switches.
task :generate_political_party_switches => :environment do
  puts "generating political party switches"
  
  # We get all the general elections.
  general_elections = GeneralElection.all
  
  # For each general election ...
  general_elections.each do |general_election|
    
    # ... for each election ...
    general_election.elections.each do |election|
      
      # ... we get the boundary set.
      boundary_set = election.boundary_set
      
      # If the election result summary is from the Commons Speaker ...
      if election.result_summary.is_from_commons_speaker == true
        
        # ... we set the from political party name and abbreviation.
        from_political_party_name = 'Speaker'
        from_political_party_abbreviation = 'Spk'
        
      # Otherwise, if the election result summary is from independent ...
      elsif election.result_summary.is_from_independent == true
        
        # ... we set the from political party name and abbreviation.
        from_political_party_name = 'Independent'
        from_political_party_abbreviation = 'Ind'
        
      # Otherwise ...
      else
        
        # ... we set the from political party name and abbreviation to those of the result summary from political party.
        from_political_party_name = election.result_summary.from_political_party.name
        from_political_party_abbreviation = election.result_summary.from_political_party.abbreviation
      end
      
      # If the election result summary is to the Commons Speaker ...
      if election.result_summary.is_to_commons_speaker == true
        
        # ... we set the to political party name and abbreviation.
        to_political_party_name = 'Speaker'
        to_political_party_abbreviation = 'Spk'
        
      # Otherwise, if the election result summary is to independent ...
      elsif election.result_summary.is_to_independent == true
        
        # ... we set the to political party name and abbreviation.
        to_political_party_name = 'Independent'
        to_political_party_abbreviation = 'Ind'
        
      # Otherwise ...
      else
        
        # ... we set the to political party name and abbreviation to those of the result summary to political party.
        to_political_party_name = election.result_summary.to_political_party.name
        to_political_party_abbreviation = election.result_summary.to_political_party.abbreviation
      end
      
      # We look for a political party switch in this general election for this party or parties.
      political_party_switch = PoliticalPartySwitch
        .all
        .where( "general_election_id = ?", general_election.id )
        .where( "from_political_party_name = ?", from_political_party_name )
        .where( "to_political_party_name = ?", to_political_party_name )
        .where( "boundary_set_id = ?", boundary_set.id )
        .first
      
      # Unless we find a political party switch in this general election for this political party or parties.
      unless political_party_switch
        
        # We create a new political party switch.
        political_party_switch = PoliticalPartySwitch.new
        political_party_switch.count = 1
        political_party_switch.from_political_party_name = from_political_party_name
        political_party_switch.from_political_party_abbreviation = from_political_party_abbreviation
        political_party_switch.to_political_party_name = to_political_party_name
        political_party_switch.to_political_party_abbreviation = to_political_party_abbreviation
        political_party_switch.general_election = general_election
        political_party_switch.boundary_set = boundary_set
        
        # If the result summary is associated with a from political party ...
        if election.result_summary.from_political_party_id
          
          # ... we associate the party switch with the from political party.
          political_party_switch.from_political_party_id = election.result_summary.from_political_party_id
        end
        
        # If the result summary is associated with a to political party ...
        if election.result_summary.to_political_party_id
          
          # ... we associate the party switch with the to political party.
          political_party_switch.to_political_party_id = election.result_summary.to_political_party_id
        end
        
      # Otherwise, if we find a political party switch in this general election for this party or parties ...
      else
        
        # ... we increment the count.
        political_party_switch.count += 1
      end
      
      # We save the political party switch.
      political_party_switch.save!
    end
  end
end

# ## A task to generate political party switch nodes and edges.
task :generate_graphviz => :environment do
  puts 'generating political party switch nodes and edges'
  
  # We get all the political party switches.
  political_party_switches = PoliticalPartySwitch.find_by_sql(
    "
      SELECT
        pps.*,
        ge.polling_on AS general_election_polling_on
      FROM political_party_switches pps, general_elections ge
      WHERE ge.id = pps.general_election_id
    "
  )
  
  # For each political party switch ...
  political_party_switches.each do |political_party_switch|
    
    # We set the from node label.
    from_node_label = political_party_switch.from_political_party_abbreviation + ' ' + political_party_switch.general_election.preceding_general_election.polling_on.strftime( '%Y' )
    
    # We attempt to find the from node.
    from_node = Node.all.where( "label = ?", from_node_label ).where( "boundary_set_id =?", political_party_switch.boundary_set_id ).first
    
    # Unless we find the from node ...
    unless from_node
      
      # ... we create the from node.
      from_node = Node.new
      from_node.label = from_node_label
      from_node.boundary_set_id = political_party_switch.boundary_set_id
      from_node.save!
    end
    
    # We set the to node label.
    to_node_label = political_party_switch.to_political_party_abbreviation + ' ' + political_party_switch.general_election.polling_on.strftime( '%Y' )
    
    # We attempt to find the to node.
    to_node = Node.all.where( "label = ?", to_node_label ).where( "boundary_set_id =?", political_party_switch.boundary_set_id ).first
    
    # Unless we find the to node ...
    unless to_node
      
      # ... we create the to node.
      to_node = Node.new
      to_node.label = to_node_label
      to_node.boundary_set_id = political_party_switch.boundary_set_id
      to_node.save!
    end
    
    # We create a new edge.
    edge = Edge.new
    edge.count = political_party_switch.count
    edge.from_node_label = from_node_label
    edge.to_node_label = to_node_label
    edge.from_node_id = from_node.id
    edge.to_node_id = to_node.id
    edge.save!
  end
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
      # We hard code England because other countries are in the spreadsheet as regions.
      if row[5] == 'England'
        country.geographic_code = 'E92000001'
      else
        country.geographic_code = row[1]
      end
      country.save!
    end
    
    # If the country is England ...
    if country.name == 'England'
    
      # ... we check if the English region exists.
      english_region = EnglishRegion.find_by_geographic_code( row[1] )
      
      # If the English region does not exist ...
      unless english_region
        
        # ... we create the English region.
        english_region = EnglishRegion.new
        english_region.name = row[4]
        english_region.geographic_code = row[1]
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
    
    # We check if there's a constituency area with this geographic code.
    constituency_area = ConstituencyArea.find_by_geographic_code( row[0] )
    
    # If there's no constituency area with this geographic code ...
    unless constituency_area
      
      # ... we create the constituency area ...
      constituency_area = ConstituencyArea.new
      constituency_area.name = row[2]
      constituency_area.geographic_code = row[0]
      constituency_area.constituency_area_type = constituency_area_type
      constituency_area.country = country
      constituency_area.english_region = english_region if english_region
      constituency_area.save!
      
    end
    
    # We check if there's a constituency group with a constituency area with this geographic code.
    constituency_group = ConstituencyGroup.find_by_sql(
      "
        SELECT cg.*
        FROM constituency_groups cg, constituency_areas ca
        WHERE cg.constituency_area_id = ca.id
        AND ca.geographic_code = '#{row[1]}'
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
    
    # If the party name is Independent ...
    if row[7] == 'Independent'
      
      # ... we flag the candidacy as standing as independent.
      candidacy.is_standing_as_independent = true
      
    # Otherwise, if the party name is Speaker ...
    elsif row[7] == 'Speaker'
      
      # ... we flag the candidacy as standing as Commons Speaker.
      candidacy.is_standing_as_commons_speaker = true
    
    # Otherwise, if the party name is Labour and Co-operative ...
    elsif row[7] == 'Labour and Co-operative'
      
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
    
    # We save the candidacy.
    candidacy.save!
    
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
    winning_party_abbreviation = row[9]
    
    # We store the data we need to find the candidacy, quoted for SQL.
    constituency_area_geographic_code = ActiveRecord::Base.connection.quote( row[0] )
    
    # If the winning party acronym is Spk ...
    if winning_party_abbreviation == 'Spk'
      
      # ... we find the candidacy.
      candidacy = Candidacy.find_by_sql(
        "
          SELECT c.*
          FROM candidacies c, elections e, constituency_groups cg, constituency_areas ca
          WHERE c.is_standing_as_commons_speaker IS TRUE
          AND c.election_id = e.id
          AND e.general_election_id = #{general_election.id}
          AND e.constituency_group_id = cg.id
          AND cg.constituency_area_id = ca.id
          AND ca.geographic_code = #{constituency_area_geographic_code}
          ORDER BY c.vote_count DESC
        "
      ).first
      
    # Otherwise, if the winning party abbreviation is Ind ...
    elsif  winning_party_abbreviation == 'Ind'
      
      # ... we find the candidacy.
      candidacy = Candidacy.find_by_sql(
        "
          SELECT c.*
          FROM candidacies c, elections e, constituency_groups cg, constituency_areas ca
          WHERE c.is_standing_as_independent IS TRUE
          AND c.election_id = e.id
          AND e.general_election_id = #{general_election.id}
          AND e.constituency_group_id = cg.id
          AND cg.constituency_area_id = ca.id
          AND ca.geographic_code = #{constituency_area_geographic_code}
          ORDER BY c.vote_count DESC
        "
      ).first
      
    # Otherwise ...
    else
    
      # ... we find the winning political party.
      winning_political_party = PoliticalParty.where( "abbreviation =?", winning_party_abbreviation ).first
    
      # We find the candidacy.
      candidacy = Candidacy.find_by_sql(
        "
          SELECT c.*
          FROM candidacies c, elections e, constituency_groups cg, constituency_areas ca, certifications cert
          WHERE c.election_id = e.id
          AND e.general_election_id = #{general_election.id}
          AND e.constituency_group_id = cg.id
          AND cg.constituency_area_id = ca.id
          AND ca.geographic_code = #{constituency_area_geographic_code}
          AND c.id = cert.candidacy_id
          AND cert.political_party_id = #{winning_political_party.id}
          ORDER BY c.vote_count DESC
        "
      ).first
    end
    
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
    constituency_area_geographic_code = ActiveRecord::Base.connection.quote( row[0] )
    
    # We find the candidacy.
    # NOTE: this works on the assumption that the name of the winning candidate standing in a given general election in a constituency with a given geographic code is unique, which appears to be true.
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
        AND ca.geographic_code = #{constituency_area_geographic_code}
        ORDER BY c.vote_count DESC
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
  
  # We attempt to find the result summary.
  result_summary = ResultSummary.find_by_short_summary( election_result_type )
  
  # Unless we fine the result summary ...
  unless result_summary
    
    # ... we create the result summary.
    result_summary = ResultSummary.new
    result_summary.short_summary = election_result_type
    result_summary.save
  end
  
  # We attempt to find an elecorate for this constituency group with this population count.
  electorate = Electorate.all.where( "population_count = ?", electorate_count ).where( "constituency_group_id = ?", candidacy.election.constituency_group_id ).first
  
  # Unless we find an elecorate for this constituency group with this population count ...
  unless electorate
  
    # ... we create a new electorate.
    electorate = Electorate.new
    electorate.population_count = electorate_count
    electorate.constituency_group = candidacy.election.constituency_group
    electorate.save!
  end
  
  # We add annotate the election with new properties.
  candidacy.election.declaration_at = election_declaration_time
  candidacy.election.valid_vote_count = election_valid_vote_count
  candidacy.election.invalid_vote_count = election_invalid_vote_count
  candidacy.election.majority = election_majority
  candidacy.election.result_summary = result_summary
  candidacy.election.electorate = electorate
  candidacy.election.save!
end