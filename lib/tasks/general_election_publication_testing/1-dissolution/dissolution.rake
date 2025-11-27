# This task would also need to:
# * close the current Parliament by applying a dissolution date
# * create a new Parliament with a number, a summoned on, a state opening on, a Wikidata data ID and a London Gazette citation
# * create a new general election attached to the new Parliament with a polling date, flagged not notional, a Commons Library briefing URL if it exists and a publication state of dissolution
# * create four new general election in boundary set records for the four open boundary sets, each with an ordinality of two

# ## A task to create stub elections at dissolution.
task :create_stub_elections_at_dissolution => :environment do

  # We find the general election.
  general_election = GeneralElection.find( GENERAL_ELECTION_ID )
  
  # We find all the current constituency groups.
  constituency_groups = ConstituencyGroup.find_by_sql(
    "
      SELECT cg.*
      FROM constituency_groups cg, constituency_areas ca, boundary_sets bs
      WHERE cg.constituency_area_id = ca.id
      AND ca.boundary_set_id = bs.id
      AND bs.end_on IS NULL
    "
  )
  
  # For each current constituency group ...
  constituency_groups.each do |constituency_group|
  
    # ... we attempt to find a non-notional election for this constituency group in this general election.
    election = Election
      .where( "constituency_group_id = ?", constituency_group.id )
      .where( "general_election_id = ?", general_election.id )
      .where( "is_notional IS FALSE" )
      .first
      
    # Unless we find  a non-notional election for this constituency group in this general election ...
    unless election
    
      # ... we create a new election.
      election = Election.new
      
      # With a writ issued date of the date of the dissolution of the previous Parliament.
      election.writ_issued_on = general_election.parliament_period.previous_parliament_period.dissolved_on
      
      # With the same polling date as the polling date of the general election.
      election.polling_on = general_election.polling_on
    
      # That is not notional.
      election.is_notional = false
    
      # For the constituency group.
      election.constituency_group = constituency_group
      
      # As part of the general election
      election.general_election = general_election
      
      # Into the same Parliament period as the general election.
      election.parliament_period = general_election.parliament_period
    
      # We save the election.
      election.save!
    end
  end
end

