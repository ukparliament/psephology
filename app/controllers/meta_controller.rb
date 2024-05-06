class MetaController < ApplicationController
  
  def index
    @page_title = 'Meta'
  end
  
  def coverage
    @page_title = 'Coverage: April 2024'
  end
  
  def roadmap
    @page_title = 'Roadmap'
  end
  
  def contact
    @page_title = 'Contact'
  end
  
  def cookies
    @page_title = 'Cookies'
  end
  
  def schema
    @page_title = 'Database schema'
  end
  
  def redirect
    polling_on = params[:polling_on]
    constituency_name = params[:constituency].downcase
    
    election = Election.find_by_sql(
      "
        SELECT e.*
        FROM elections e, constituency_groups cg
        WHERE e.polling_on = '#{polling_on}'
        AND e.constituency_group_id = cg.id
        AND LOWER( cg.name ) = '#{constituency_name}'
      "
    ).first
    
    redirect_to( "/elections/#{election.id}", allow_other_host: true, status: 301)
  end
  
  def about_redirect
    redirect_to( meta_coverage_url, allow_other_host: true, status: 301)
  end
  
  def redirect_country
    polling_on = params[:polling_on]
    general_election = GeneralElection.all.where( "polling_on = ?", polling_on).where( 'is_notional IS FALSE').first
    
    country_name = params[:country]
    country = Country.all.where( "name = ?", country_name ).first
    
    redirect_to( "/general-elections/#{general_election.id}/countries/#{country.id}", allow_other_host: true, status: 301 )
  end
  
  def redirect_country_uk
    polling_on = params[:polling_on]
    general_election = GeneralElection.all.where( "polling_on = ?", polling_on).where( 'is_notional IS FALSE').first
    
    redirect_to( "/general-elections/#{general_election.id}", allow_other_host: true, status: 301 )
  end
  
  def redirect_region
    polling_on = params[:polling_on]
    general_election = GeneralElection.all.where( "polling_on = ?", polling_on).where( 'is_notional IS FALSE').first
    
    region_name = params[:region]
    region = EnglishRegion.all.where( "name = ?", region_name ).first
    
    redirect_to( "/general-elections/#{general_election.id}/countries/2/english-regions/#{region.id}", allow_other_host: true, status: 301 )
  end
  
  def redirect_party
    polling_on = params[:polling_on]
    general_election = GeneralElection.all.where( "polling_on = ?", polling_on).where( 'is_notional IS FALSE').first
    
    party_name = params[:party]
    party = PoliticalParty.all.where( "name = ?", party_name ).first
    
    redirect_to( "/general-elections/#{general_election.id}/political-parties/#{party.id}/elections", allow_other_host: true, status: 301 )
  end
  
  def redirect_candidate_statistics
    polling_on = params[:polling_on]
    general_election = GeneralElection.all.where( "polling_on = ?", polling_on).where( 'is_notional IS FALSE').first
    
    redirect_to( "/general-elections/#{general_election.id}", allow_other_host: true, status: 303 )
  end
  
  def redirect_majority
    polling_on = params[:polling_on]
    general_election = GeneralElection.all.where( "polling_on = ?", polling_on).where( 'is_notional IS FALSE').first
    
    redirect_to( "/general-elections/#{general_election.id}/majority", allow_other_host: true, status: 301 )
  end
  
  def redirect_turnout
    polling_on = params[:polling_on]
    general_election = GeneralElection.all.where( "polling_on = ?", polling_on).where( 'is_notional IS FALSE').first
    
    redirect_to( "/general-elections/#{general_election.id}/turnout", allow_other_host: true, status: 301 )
  end
  
  def redirect_county
    polling_on = params[:polling_on]
    general_election = GeneralElection.all.where( "polling_on = ?", polling_on).where( 'is_notional IS FALSE').first
    
    redirect_to( "/general-elections/#{general_election.id}", allow_other_host: true, status: 303 )
  end
  
  def redirect_search
    polling_on = params[:polling_on]
    general_election = GeneralElection.all.where( "polling_on = ?", polling_on).where( 'is_notional IS FALSE').first
    
    redirect_to( "/general-elections/#{general_election.id}", allow_other_host: true, status: 303 )
  end
end
