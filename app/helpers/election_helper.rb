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
end
