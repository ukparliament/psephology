# ## A task close Parliament 59, create Parliament 60 and create the general election.
task :parliament_59_dissolution => :environment do
  puts "closing Parliament 59, creating Parliament 60 and creating the general election"
  
  # We set out what we know at dissolution.
  PARLIAMENT_59_DISSOLUTION_DATE = '2029-04-11'
  PARLIAMENT_59_LONDON_GAZETTE_DISSOLUTION_PROCLAMATION = 'issue 9000'
  PARLIAMENT_60_SUMMONED_ON_DATE = '2029-06-01'
  PARLIAMENT_60_STATE_OPENING_ON_DATE = nil
  PARLIAMENT_60_WIKIDATA_ID = 'Q60000000'
  GENERAL_ELECTION_POLLING_ON_DATE = '2029-05-13'
  
  
  # ## Closing Parliament 59
  
  # We find Parliament 59 ...
  parliament_59 = ParliamentPeriod.find_by_number( 59 )
  
  # ... and apply its dissolution date ...
  parliament_59.dissolved_on = PARLIAMENT_59_DISSOLUTION_DATE
  
  # ... and the ID of the London Gazette with the dissolution proclamation if known.
  parliament_59.london_gazette = PARLIAMENT_59_LONDON_GAZETTE_DISSOLUTION_PROCLAMATION if PARLIAMENT_59_LONDON_GAZETTE_DISSOLUTION_PROCLAMATION
  parliament_59.save!
  
  
  # ## Opening Parliament 60
  
  # We attempt to find Parliament 60.
  parliament_60 = ParliamentPeriod.find_by_number( 60 )
  
  # Unless we find Parliament 60 ...
  unless parliament_60
  
    # ... we create it.
    parliament_60 = ParliamentPeriod.new
  end
  
  # We populate Parliament 60.
  parliament_60.number = 60
  parliament_60.summoned_on = PARLIAMENT_60_SUMMONED_ON_DATE
  parliament_60.state_opening_on = PARLIAMENT_60_STATE_OPENING_ON_DATE if PARLIAMENT_60_STATE_OPENING_ON_DATE
  parliament_60.wikidata_id = PARLIAMENT_60_WIKIDATA_ID if PARLIAMENT_60_WIKIDATA_ID
  parliament_60.save!
  
  
  # ## Creating the general election for Parliament 60
  
  # We attempt to find the general election for Parliament 60.
  general_election = GeneralElection
    .where( "parliament_period_id = ?", parliament_60.id )
    .where( "is_notional is false" )
    .first
  
  # Unless we find the general election for Parliament 60 ...
  unless general_election
  
    # ... we create it.
    general_election = GeneralElection.new
  end
  
  # We populate the general election.
  general_election.polling_on = GENERAL_ELECTION_POLLING_ON_DATE
  general_election.is_notional = false
  general_election.parliament_period_id = parliament_60.id
  general_election.general_election_state_id = 1
  general_election.save!
  
  
  # ## Creating the elections within the general election.
  
  # We find all curent constituency groups, being those in current boundary sets.
  current_constituency_groups = ConstituencyGroup.find_by_sql(
    "
      SELECT cg.*
      FROM constituency_groups cg, constituency_areas ca, boundary_sets bs
      WHERE cg.constituency_area_id = ca.id
      AND ca.boundary_set_id = bs.id
      AND bs.end_on IS NULL
    "
  )
  
  # For each current constituency group ...
  current_constituency_groups.each do |constituency_group|
  
    # ... we attempt to find an election for this constituency group in this general election ...
    election = Election.find_by_sql([
      "
        SELECT *
        FROM elections
        WHERE is_notional IS FALSE
        AND constituency_group_id = ?
        AND general_election_id = ?
      ", constituency_group.id, general_election.id
    ]).first
    
    # Unless we find an election for this constituency group in this general election ...
    unless election
    
      # ... we create it.
      election = Election.new
      election.is_notional = false
      election.constituency_group_id = constituency_group.id
      election.general_election_id = general_election.id
    end
    
    # We populate the election.
    election.polling_on = GENERAL_ELECTION_POLLING_ON_DATE
    election.parliament_period_id = parliament_60.id
    election.writ_issued_on = PARLIAMENT_59_DISSOLUTION_DATE
    election.election_state_id = 1
    election.save!
  end
end