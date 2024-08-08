module ApplicationHelper

  def csv_icon_link(url, title)
		link_to( content_tag( 'abbr', 'CSV' ), url, :title => title, :class => 'csv' ) + link_to( title , url)
  end

  def election_lists_of_links
    general_election_links = relevant_general_elections.pluck(:id, :polling_on).map do |id, polling_on|
      link_to(polling_on.year, general_election_show_path(id))
    end
  end

  def output_election_lists_of_links
    sanitize election_lists_of_links.to_sentence
  end

  def output_election_years
    relevant_general_elections.pluck(:polling_on).map do |polling_on|
      polling_on.year
    end.to_sentence(last_word_connector: ' or ')
  end

  def relevant_general_elections
    GeneralElection.where(is_notional: false).where("EXTRACT(YEAR FROM polling_on) <= #{end_year}").order(:polling_on)
  end

  def end_year
    ENV.fetch('LATEST_ELECTION_YEAR', 2019)
  end
end
