class AddLinkToParliament59ByElectionsBriefing < ActiveRecord::Migration[8.1]
  def change
  
    # We find Parliament 59 ...
    parliament = ParliamentPeriod.find( 59 )
    
    # ... and assign its by-election briefing URL.
    parliament.commons_library_briefing_by_election_briefing_url = 'https://commonslibrary.parliament.uk/research-briefings/cbp-10268/'
    parliament.save!
  end
end
