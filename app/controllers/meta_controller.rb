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
    constituency_name = params[:constituency]
    
    election = Election.find_by_sql(
      "
        SELECT e.*
        FROM elections e, constituency_groups cg
        WHERE e.polling_on = '#{polling_on}'
        AND e.constituency_group_id = cg.id
        AND cg.name = '#{constituency_name}'
      "
    ).first
    
    redirect_to( "/elections/#{election.id}", allow_other_host: true, status: 301)
  end
  
  def about_redirect
    redirect_to( meta_coverage_url, allow_other_host: true, status: 301)
  end
end
