class ConstituencyAreaEnglishRegionController < ApplicationController
  
  def index
    country = params[:country]
    @country = Country.find( country )
    @page_title = "Current constituencies - English regions"
    @multiline_page_title = "Current constituencies <span class='subhead'>English regions</span>".html_safe
    @english_regions = @country.current_english_regions
    raise ActiveRecord::RecordNotFound if @english_regions.empty?
  end
  
  def show
    country = params[:country]
    @country = Country.find( country )
    english_region = params[:english_region]
    @english_region = EnglishRegion.find( english_region )
    @page_title = "Current constituencies - #{@english_region.name}, #{@country.name}"
    @multiline_page_title = "Current constituencies <span class='subhead'>#{@english_region.name}, #{@country.name}</span>".html_safe
    @current_constituencies = @country.current_constituencies_in_region( @english_region )
    raise ActiveRecord::RecordNotFound if @current_constituencies.empty?
  end
end
