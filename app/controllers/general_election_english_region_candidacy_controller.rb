class GeneralElectionEnglishRegionCandidacyController < ApplicationController
  
  def index
    general_election = params[:general_election]
    @general_election = GeneralElection.find( general_election )
    
    country = params[:country]
    english_region = params[:english_region]
    @english_region = EnglishRegion.all.where( 'id = ?', english_region ).where( 'country_id =?', country).first
    
    raise ActiveRecord::RecordNotFound unless @general_election and @english_region
    
    respond_to do |format|
      format.csv {
        @candidacies = @general_election.candidacies_in_english_region( @english_region )
        response.headers['Content-Disposition'] = "attachment; filename=\"#{@general_election.csv_filename_for_english_region( @english_region )}\""
        render :template => 'general_election_candidacy/index'
      }
      format.html {
        @csv_url = general_election_english_region_candidacy_list_url( :format => 'csv' )
        @crumb << { label: 'General elections', url: general_election_list_url }
        @crumb << { label: @general_election.crumb_label, url: general_election_show_url }
        @crumb << { label: 'England', url: general_election_country_show_url }
        @crumb << { label: @english_region.name, url: general_election_english_region_show_url }
        @crumb << { label: 'Candidates', url: nil }
        @section = 'general-elections'
        
        if @general_election.is_notional
          @page_title = "Notional results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - #{@english_region.name}, England - candidates"
          @multiline_page_title = "Notional results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>#{@english_region.name}, England - candidates</span>".html_safe
          @description = "Notional results in #{@english_region.name}, England for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} listing all candidates, available as a CSV."
        else
          @page_title = "Results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - #{@english_region.name}, England - candidates"
          @multiline_page_title = "Results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>#{@english_region.name}, England - candidates</span>".html_safe
          @description = "Results in #{@english_region.name}, England for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} listing all candidates, available as a CSV."
        end
      }
    end
  end
end
