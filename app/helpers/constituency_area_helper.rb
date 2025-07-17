module ConstituencyAreaHelper

  def constituency_area_name_with_boundary_set_dates( constituency_area, boundary_set )
    name = ''
    if constituency_area.boundary_set_start_on == boundary_set.start_on and constituency_area.boundary_set_end_on == boundary_set.end_on
      name += constituency_area.name
    else
      name += constituency_area.name
      name += ' ('
      name += constituency_area.boundary_set_start_on.strftime( '%Y') 
      name += '  - '
      name += constituency_area.boundary_set_end_on.strftime( '%Y') 
      name += ')'
    end
    name
  end
end