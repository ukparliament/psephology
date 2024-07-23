class ConstituencyAreaEnglishRegionController < ApplicationController
  
  def index
    country = params[:country]
    @country = Country.find( country )
    @english_regions = @country.current_english_regions
    raise ActiveRecord::RecordNotFound if @english_regions.empty?
    
    @page_title = "Current constituencies - English regions"
    @multiline_page_title = "Current constituencies <span class='subhead'>English regions</span>".html_safe
    @description = "Current constituency areas in #{@country.name}, by region."
    @crumb << { label: 'Constituency areas', url: constituency_area_list_current_url }
    @crumb << { label: @country.name, url: constituency_area_country_show_url }
    @crumb << { label: 'Regions', url: nil }
    @section = 'constituency-areas'
  end
  
  def show
    country = params[:country]
    @country = Country.find( country )
    english_region = params[:english_region]
    @english_region = EnglishRegion.find( english_region )
    @current_constituencies = @country.current_constituencies_in_region( @english_region )
    raise ActiveRecord::RecordNotFound if @current_constituencies.empty?
    
    @page_title = "Current constituencies - #{@english_region.name}, #{@country.name}"
    @multiline_page_title = "Current constituencies <span class='subhead'>#{@english_region.name}, #{@country.name}</span>".html_safe
    @description = "Current constituency areas in #{@english_region.name}, England."
    @crumb << { label: 'Constituency areas', url: constituency_area_list_current_url }
    @crumb << { label: @country.name, url: constituency_area_country_show_url }
    @crumb << { label: @english_region.name, url: nil }
    @section = 'constituency-areas'
  end
end
