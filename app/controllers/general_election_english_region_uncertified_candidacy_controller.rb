class GeneralElectionEnglishRegionUncertifiedCandidacyController < ApplicationController
  
  def index
    country = params[:country]
    english_region = params[:english_region]
    @english_region = EnglishRegion.all.where( 'id = ?', english_region ).where( 'country_id =?', country).first
    raise ActiveRecord::RecordNotFound unless @english_region
    @uncertified_candidacies = @general_election.uncertified_candidacies_in_english_region( @english_region )
    
    respond_to do |format|
      format.csv {
        response.headers['Content-Disposition'] = "attachment; filename=\"uncertified-candidate-data-in-england-#{@english_region.name.downcase.gsub( ' ', '-' )}-#{'notional-' if @general_election.is_notional}general-election-#{@general_election.polling_on.strftime( '%d-%m-%Y' )}.csv\""
        render :template => 'general_election_uncertified_candidacy/index'
      }
      format.html {
      
        # Allow for table sorting.
        @sort = params[:sort]
        @order = params[:order]
        if @order and @sort
          case @order
            when 'descending'
              case @sort
                when 'constituency-name'
                  @uncertified_candidacies.sort_by! {|election| election.constituency_group_name}.reverse!
                when 'candidate-name'
                  @uncertified_candidacies.sort_by! {|election| [ election.candidate_family_name, election.candidate_given_name ]}.reverse!
                when 'votes'
                  @uncertified_candidacies.sort_by! {|election| election.vote_count}.reverse!
                when 'vote-share'
                  @uncertified_candidacies.sort_by! {|election| election.vote_share}.reverse!
                when 'position'
                  @uncertified_candidacies.sort_by! {|election| election.result_position}.reverse!
              end
            when 'ascending'
              case @sort
                when 'constituency-name'
                  @uncertified_candidacies.sort_by! {|election| election.constituency_group_name}
                when 'candidate-name'
                  @uncertified_candidacies.sort_by! {|election| [ election.candidate_family_name, election.candidate_given_name ]}
                when 'votes'
                  @uncertified_candidacies.sort_by! {|election| election.vote_count}
                when 'vote-share'
                  @uncertified_candidacies.sort_by! {|election| election.vote_share}
                when 'position'
                  @uncertified_candidacies.sort_by! {|election| election.result_position}
            end
          end
        else
          @sort = 'position'
          @order = 'ascending'
        end
        
        @page_title = "#{@general_election.result_type} for #{@general_election.noun_phrase_article} UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - #{@english_region.name}, England - non-party candidates"
        @multiline_page_title = "#{@general_election.result_type} for #{@general_election.noun_phrase_article} UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>#{@english_region.name}, England - non-party candidates</span>".html_safe
        @description = "Non-party candidates in #{@english_region.name}, England for #{@general_election.noun_phrase_article} general election to the Parliament of the United Kingdom on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )}."
        @csv_url = general_election_english_region_uncertified_candidacy_list_url( :format => 'csv' )
        @crumb << { label: 'Parliament periods', url: parliament_period_list_url }
        @crumb << { label: @general_election.parliament_period_crumb_label, url: parliament_period_show_url( :parliament_period => @general_election.parliament_period_number) }
        @crumb << { label: @general_election.crumb_label, url: general_election_show_url }
        @crumb << { label: 'England', url: general_election_country_show_url }
        @crumb << { label: @english_region.name, url: general_election_english_region_show_url }
        @crumb << { label: 'Non-party candidates', url: nil }
        @section = 'elections'
        @subsection = 'uncertified-candidacies'
      }
    end
  end
end
