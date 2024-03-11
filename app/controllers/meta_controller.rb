class MetaController < ApplicationController
  
  def index
    @page_title = 'Meta'
  end
  
  def coverage
    @page_title = 'Content coverage: March 2024'
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
  
  def url_mapping
    @page_title = 'URL mapping'
    
    @elections = Election.find_by_sql(
      "
        SELECT e.*, cg.name AS constituency_group_name
        FROM elections e, constituency_groups cg
        WHERE e.is_notional IS FALSE
        AND e.constituency_group_id = cg.id
      "
    )
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
end
