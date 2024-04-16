module ApplicationHelper

  def csv_icon_link(url, title)
		link_to( content_tag( 'span', 'CSV' ), url, :title => title, :class => 'csv' ) + content_tag( 'label', title )
  end

end
