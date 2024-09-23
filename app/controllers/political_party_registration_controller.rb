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
    
    # Allow for table sorting.
    @sort = params[:sort]
    @order = params[:order]
    if @order and @sort
      case @order
      when 'descending'
        case @sort
        when 'party'
          @political_party_registrations.sort_by! {|registration | registration.party_name}.reverse!
        when 'registered-on'
          @political_party_registrations.sort_by! {|registration | registration.start_on}.reverse!
        when 'deregistered-on'
          @political_party_registrations.sort_by! {|registration | registration.end_on || Date.new}.reverse!
        when 'primary-name-last-updated-on'
          @political_party_registrations.sort_by! {|registration | registration.political_party_name_last_updated_on || Date.new}.reverse!
        when 'country'
          @political_party_registrations.sort_by! {|registration | registration.country_name}.reverse!
        end
      when 'ascending'
        case @sort
        when 'party'
          @political_party_registrations.sort_by! {|registration | registration.party_name}
        when 'registered-on'
          @political_party_registrations.sort_by! {|registration | registration.start_on}
        when 'deregistered-on'
          @political_party_registrations.sort_by! {|registration | registration.end_on || Date.new}
        when 'primary-name-last-updated-on'
          @political_party_registrations.sort_by! {|registration | registration.political_party_name_last_updated_on || Date.new}
        when 'country'
          @political_party_registrations.sort_by! {|registration | registration.country_name}
        end
      end
    else
      @sort = 'party'
      @order = 'ascending'
    end
    
    @page_title = 'Political party registrations'
    @description = "Political parties registered by the Electoral Commissions."
    @crumb << { label: 'Political parties', url: political_party_winning_list_url }
    @crumb << { label: 'Registrations', url: nil }
    @section = 'political-parties'
    @subsection = 'registration'
  end
end
