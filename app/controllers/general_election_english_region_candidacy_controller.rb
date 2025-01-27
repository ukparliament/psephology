class GeneralElectionEnglishRegionCandidacyController < ApplicationController
  
  def index
    country = params[:country]
    english_region = params[:english_region]
    @english_region = EnglishRegion.all.where( 'id = ?', english_region ).where( 'country_id =?', country).first
    
    raise ActiveRecord::RecordNotFound unless @english_region
    
    respond_to do |format|
      format.csv {
        @candidacies = @general_election.candidacies_in_english_region( @english_region )
        response.headers['Content-Disposition'] = "attachment; filename=\"#{@general_election.csv_filename_for_english_region( @english_region )}\""
        render :template => 'general_election_candidacy/index'
      }
      format.html {
        @page_title = "#{@general_election.result_type} for #{@general_election.noun_phrase_article} UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - #{@english_region.name}, England - candidates"
        @multiline_page_title = "#{@general_election.result_type} for #{@general_election.noun_phrase_article} UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>#{@english_region.name}, England - candidates</span>".html_safe
        @description = "#{@general_election.result_type} in #{@english_region.name}, England for #{@general_election.noun_phrase_article} general election to the Parliament of the United Kingdom on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} listing all candidates, available as a CSV."
        @csv_url = general_election_english_region_candidacy_list_url( :format => 'csv' )
        @crumb << { label: 'Parliament periods', url: parliament_period_list_url }
        @crumb << { label: @general_election.parliament_period_crumb_label, url: parliament_period_show_url( :parliament_period => @general_election.parliament_period_number) }
        @crumb << { label: @general_election.crumb_label, url: general_election_show_url }
        @crumb << { label: 'England', url: general_election_country_show_url }
        @crumb << { label: @english_region.name, url: general_election_english_region_show_url }
        @crumb << { label: 'Candidates', url: nil }
        @section = 'elections'
      }
    end
  end
end
