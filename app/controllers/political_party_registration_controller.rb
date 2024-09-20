class PoliticalPartyRegistrationController < ApplicationController
  
  def index
    @political_party_registrations = PoliticalPartyRegistration.find_by_sql(
      "
        SELECT ppr.*, pp.name AS party_name, c.name AS country_name
        FROM political_party_registrations ppr, political_parties pp, countries c
        WHERE ppr.political_party_id = pp.id
        AND ppr.country_id = c.id
        ORDER BY pp.name, c.name, ppr.start_on
      "
    )
    
    @page_title = 'Political party registrations'
    @description = "Political parties registered by the Electoral Commissions."
    @crumb << { label: 'Political parties', url: political_party_winning_list_url }
    @crumb << { label: 'Registrations', url: nil }
    @section = 'political-parties'
  end
end
