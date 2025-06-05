class RedirectController < ApplicationController
  
  def coverage
    redirect_to( meta_coverage_url, allow_other_host: true, status: 301)
  end
  
  def election
    polling_on = params[:polling_on]
    constituency_name = params[:constituency].downcase
    
    election = Election.find_by_sql([
      "
        SELECT e.*
        FROM elections e, constituency_groups cg
        WHERE e.polling_on = :polling_on
        AND e.constituency_group_id = cg.id
        AND LOWER( cg.name ) = :constituency_name
      ", polling_on: polling_on, constituency_name: constituency_name
    ]).first
    
    raise ActiveRecord::RecordNotFound unless election

    redirect_to( "/elections/#{election.id}", allow_other_host: true, status: 301)
  end
  
  def general_election_country_uk
    redirect_to( "/general-elections/#{get_general_election_id}", allow_other_host: true, status: 301 )
  end
  
  def general_election_country
    country_name = params[:country]
    country = Country.all.where( "name = ?", country_name ).first
    
    raise ActiveRecord::RecordNotFound unless country

    redirect_to( "/general-elections/#{get_general_election_id}/countries/#{country.id}", allow_other_host: true, status: 301 )
  end
  
  def general_election_region
    region_name = params[:region]
    region = EnglishRegion.all.where( "name = ?", region_name ).first
    
    raise ActiveRecord::RecordNotFound unless region

    redirect_to( "/general-elections/#{get_general_election_id}/countries/2/english-regions/#{region.id}", allow_other_host: true, status: 301 )
  end
  
  def general_election_majority
    redirect_to( "/general-elections/#{get_general_election_id}/majority", allow_other_host: true, status: 301 )
  end
  
  def general_election_turnout
    redirect_to( "/general-elections/#{get_general_election_id}/turnout", allow_other_host: true, status: 301 )
  end
  
  def general_election_party
    party_name = params[:party]
    party = PoliticalParty.all.where( "name = ?", party_name ).first
    
    raise ActiveRecord::RecordNotFound unless party

    redirect_to( "/general-elections/#{get_general_election_id}/political-parties/#{party.id}/elections", allow_other_host: true, status: 301 )
  end
  
  def general_election_see_also
    redirect_to( "/general-elections/#{get_general_election_id}", allow_other_host: true, status: 303 )
  end

  private

  def get_general_election_id
    polling_on = params[:polling_on]
    general_election = GeneralElection.all.where( "polling_on = ?", polling_on).where( 'is_notional IS FALSE').first

    raise ActiveRecord::RecordNotFound unless general_election

    general_election.id
  end
end