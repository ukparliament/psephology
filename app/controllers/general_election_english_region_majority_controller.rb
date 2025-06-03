class GeneralElectionEnglishRegionMajorityController < ApplicationController
  
  def index
    country = params[:country]
    english_region = params[:english_region]
    @english_region = EnglishRegion.all.where( 'id = ?', english_region ).where( 'country_id =?', country).first
    raise ActiveRecord::RecordNotFound unless @english_region
    @elections = @general_election.elections_by_majority_in_english_region( @english_region )
    
    respond_to do |format|
      format.csv {
        response.headers['Content-Disposition'] = "attachment; filename=\"winning-candidate-majorities-in-england-#{@english_region.name.downcase.gsub( ' ', '-' )}-#{'notional-' if @general_election.is_notional}general-election-#{@general_election.polling_on.strftime( '%d-%m-%Y' )}.csv\""
        render :template => 'general_election_majority/index'
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
                  @elections.sort_by! {|election| election.constituency_group_name}.reverse!
                when 'candidate-name'
                  @elections.sort_by! {|election| [ election.winning_candidacy_candidate_family_name, election.winning_candidacy_candidate_given_name ]}.reverse!
                when 'party-name'
                  @elections.sort_by!{ |election| election.main_party_name.nil? ? 'z' : election.main_party_name }.reverse!
                when 'majority'
                  @elections.sort_by! {|election| election.majority}.reverse!
                when 'valid-vote-count'
                  @elections.sort_by! {|election| election.valid_vote_count}.reverse!
                when 'majority-percentage'
                  @elections.sort_by! {|election| election.majority_percentage}.reverse!
              end
            when 'ascending'
              case @sort
                when 'constituency-name'
                  @elections.sort_by! {|election| election.constituency_group_name}
                when 'candidate-name'
                  @elections.sort_by! {|election| [ election.winning_candidacy_candidate_family_name, election.winning_candidacy_candidate_given_name ]}
                when 'party-name'
                  @elections.sort_by!{ |election| election.main_party_name.nil? ? 'z' : election.main_party_name }
                when 'majority'
                  @elections.sort_by! {|election| election.majority}
                when 'valid-vote-count'
                  @elections.sort_by! {|election| election.valid_vote_count}
                when 'majority-percentage'
                  @elections.sort_by! {|election| election.majority_percentage}
            end
          end
        else
          @sort = 'majority-percentage'
          @order = 'descending'
        end
        
        @page_title = "#{@general_election.result_type} for #{@general_election.noun_phrase_article} UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - #{@english_region.name}, England - by majority"
        @multiline_page_title = "#{@general_election.result_type} for #{@general_election.noun_phrase_article} UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>#{@english_region.name}, England - by majority</span>".html_safe
        @description = "#{@general_election.result_type} in #{@english_region.name}, England for #{@general_election.noun_phrase_article} general election to the Parliament of the United Kingdom on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )}, listed by the majority of the winning candidate."
        @csv_url = general_election_english_region_majority_list_url( :format => 'csv' )
        @crumb << { label: 'Parliament periods', url: parliament_period_list_url }
        @crumb << { label: @general_election.parliament_period_crumb_label, url: parliament_period_show_url( :parliament_period => @general_election.parliament_period_number) }
        @crumb << { label: @general_election.crumb_label, url: general_election_show_url }
        @crumb << { label: 'England', url: general_election_country_show_url }
        @crumb << { label: @english_region.name, url: general_election_english_region_show_url }
        @crumb << { label: 'Majorities', url: nil }
        @section = 'elections'
        @subsection = 'majorities'
        
        render :template => 'general_election_english_region_majority/index_notional' if @general_election.is_notional
      }
    end
  end
end
