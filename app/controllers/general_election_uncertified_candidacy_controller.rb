class GeneralElectionUncertifiedCandidacyController < ApplicationController
  
  def index
    @uncertified_candidacies = @general_election.uncertified_candidacies
    
    respond_to do |format|
      format.csv {
        response.headers['Content-Disposition'] = "attachment; filename=\"non-party-candidates-#{'notional-' if @general_election.is_notional}general-election-#{@general_election.polling_on.strftime( '%d-%m-%Y' )}.csv\""
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
                  @uncertified_candidacies.sort_by!{ |h| [h[:result_position], -h[:vote_count]] }.reverse!
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
                  @uncertified_candidacies.sort_by!{ |h| [h[:result_position], -h[:vote_count]] }
            end
          end
        else
          @sort = 'votes'
          @order = 'descending'
        end
      
        @page_title = "#{@general_election.result_type} for #{@general_election.noun_phrase_article} UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - non-party candidates"
        @multiline_page_title = "#{@general_election.result_type} for #{@general_election.noun_phrase_article} UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>Non-party candidates</span>".html_safe
        @description = "#{@general_election.result_type} for #{@general_election.noun_phrase_article} general election to the Parliament of the United Kingdom on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} listing candidates not certified by a political party."
        @csv_url = general_election_uncertified_candidacy_list_url( :format => 'csv' )
        @crumb << { label: 'Parliament periods', url: parliament_period_list_url }
        @crumb << { label: @general_election.parliament_period_crumb_label, url: parliament_period_show_url( :parliament_period => @general_election.parliament_period_number) }
        @crumb << { label: @general_election.crumb_label, url: general_election_show_url }
        @crumb << { label: 'Non-party candidates', url: nil }
        @section = 'elections'
        @subsection = 'uncertified-candidacies'
      }
    end
  end
end
