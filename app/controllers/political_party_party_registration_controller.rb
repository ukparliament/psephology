class PoliticalPartyPartyRegistrationController < ApplicationController
  
  def index
    political_party = params[:political_party]
    @political_party = PoliticalParty.find( political_party )
    
    @political_party_registrations = @political_party.registrations
    
    respond_to do |format|
      format.csv {
        response.headers['Content-Disposition'] = "attachment; filename=\"political-party-registrations-for-#{@political_party.name.downcase.gsub( ' ', '-') }.csv\""
        render :template => 'political_party_registration/index'
      }
      format.html {
        @page_title = "#{@political_party.name} - registrations"
        @multiline_page_title = "#{@political_party.name} <span class='subhead'>Registrations</span>".html_safe
        @description = "Registrations of #{@political_party.name} by the Electoral Commissions."
        @csv_url = political_party_party_registration_list_url( :format => 'csv' )
        @crumb << { label: 'Political parties', url: political_party_winning_list_url }
        @crumb << { label: @political_party.name, url: political_party_show_url }
        @crumb << { label: 'Registrations', url: nil }
        @section = 'political-parties'
        @subsection = 'registration'
      }
    end
  end
end
