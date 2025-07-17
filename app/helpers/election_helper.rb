module ElectionHelper

  def election_writ_issued_text( election )
  if election.writ_issued_on
      if election.general_election
        election_writ_issued_text = content_tag( 'p', "The writ for this election was issued on #{election.writ_issued_on.strftime( $DATE_DISPLAY_FORMAT )}." )
      else
        election_writ_issued_text = content_tag( 'p', "The writ for this by-election was issued on #{election.writ_issued_on.strftime( $DATE_DISPLAY_FORMAT )}." )
      end
    end
    election_writ_issued_text if election_writ_issued_text
  end
  
  def election_constituency_area_name_with_boundary_set_dates( election, boundary_set )
    name = ''
    if election.boundary_set_start_on == boundary_set.start_on and election.boundary_set_end_on == boundary_set.end_on
      name += election.constituency_area_name
    else
      name += election.constituency_area_name
      name += ' ('
      name += election.boundary_set_start_on.strftime( '%Y') 
      name += '  - '
      name += election.boundary_set_end_on.strftime( '%Y') 
      name += ')'
    end
    name
  end
end
