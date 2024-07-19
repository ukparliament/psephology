class GeneralElectionEnglishRegionUncertifiedCandidacyController < ApplicationController
  
  def index
    general_election = params[:general_election]
    @general_election = GeneralElection.find_by_sql(
      "
        SELECT ge.*, pp.number AS parliament_period_number
        FROM general_elections ge, parliament_periods pp
        WHERE ge.parliament_period_id = pp.id
        AND ge.id = #{general_election}
      "
    ).first
    
    country = params[:country]
    english_region = params[:english_region]
    @english_region = EnglishRegion.all.where( 'id = ?', english_region ).where( 'country_id =?', country).first
    
    raise ActiveRecord::RecordNotFound unless @general_election and @english_region
    
    @uncertified_candidacies = @general_election.uncertified_candidacies_in_english_region( @english_region )
    
    @page_title = "Results for a UK general election on #{@general_election.crumb_label} - #{@english_region.name}, England - non-party candidates"
    @multiline_page_title = "Results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>#{@english_region.name}, England - non-party candidates</span>".html_safe
    @description = "Non-party candidates in #{@english_region.name}, England for a general election to the Parliament of the United Kingdom on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )}."
    
    @crumb << { label: 'General elections', url: general_election_list_url }
    @crumb << { label: @general_election.crumb_label, url: general_election_party_list_url }
    @crumb << { label: 'England', url: general_election_country_political_party_list_url }
    @crumb << { label: @english_region.name, url: general_election_english_region_political_party_list_url }
    @crumb << { label: 'Non-party candidates', url: nil }
    @section = 'general-elections'
    @subsection = 'uncertified-candidacies'
  end
end
