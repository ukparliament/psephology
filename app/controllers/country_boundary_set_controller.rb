class CountryBoundarySetController < ApplicationController
  
  def index
    country = params[:country]
    @country = Country.find( country )
    @boundary_sets = @country.boundary_sets
    
    respond_to do |format|
      format.csv {
        response.headers['Content-Disposition'] = "attachment; filename=\"boundary-sets-in-#{@country.name.downcase}.csv\""
      }
      format.html {
        @page_title = "Boundary sets - #{@country.name}"
        @multiline_page_title = "Boundary sets <span class='subhead'>In #{@country.name}</span>".html_safe
        @description = "Boundary sets establishing new constituencies, in #{@country.name}."
        @crumb << { label: 'Boundary sets', url: boundary_set_list_url }
        @crumb << { label: @country.name, url: country_show_url }
        @crumb << { label: 'Boundary sets', url: nil }
        @section = 'boundary-sets'
      }
    end
  end
end
