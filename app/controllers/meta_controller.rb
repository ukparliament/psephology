class MetaController < ApplicationController
  
  def index
    @page_title = 'Meta'
  end
  
  def schema
    @page_title = 'Schema'
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
end
