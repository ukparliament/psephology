# ## A task to sort party names in result summaries.
task :sort_party_names_in_result_summaries => :environment do
  puts "sorting party names in result summaries"
  
  # We get all result summaries.
  result_summaries = ResultSummary.all
  
  # For each result summary ...
  result_summaries.each do |result_summary|
  
    # We create a string to hold the new summary text.
    new_summary_text = ''
  
    # ... if the result summary summary text includes ' gain from ' ...
    if result_summary.summary.include?( ' gain from ' )
    
      # ... if the result summary is to the Speaker ...
      if result_summary.is_to_commons_speaker
      
        # ... we set the new result summary text to include 'Speaker'.
        new_summary_text = 'Speaker'
    
      # Otherwise, if the result summary is to an independent ...
      elsif result_summary.is_to_independent
      
        # ... we set the new result summary text to include 'Independent'.
        new_summary_text = 'Independent'
      
      # Otherwise, the result summary must be to a party ...
      else
      
        # ... so we find the party ...
        political_party = PoliticalParty.find( result_summary.to_political_party_id )
        
        # ... and set the new result summary text to include the party name.
        new_summary_text = political_party.name
      end
      
      # We append the text ' gain from ' to the new summary text.
      new_summary_text += ' gain from '
      
      # If the result summary is from the Speaker ...
      if result_summary.is_from_commons_speaker
      
        # ... we append 'Speaker' to the new result summary text.
        new_summary_text += 'Speaker'
    
      # Otherwise, if the result summary is from an independent ...
      elsif result_summary.is_from_independent
      
        # ... we append 'Independent' to the new result summary text.
        new_summary_text += 'Independent'
      
      # Otherwise, the result summary must be from a party ...
      else
      
        # ... so we find the party ...
        political_party = PoliticalParty.find( result_summary.from_political_party_id )
        
        # ... and append the party name to the new result summary text.
        new_summary_text += political_party.name
      end
      
    # Otherwise, if the result summary summary text includes ' hold' ...
    elsif result_summary.summary.include?( ' hold' )
    
      # ... if the result summary is from the Speaker ...
      if result_summary.is_from_commons_speaker
      
        # ... we set the new result summary text to 'Speaker hold'.
        new_summary_text = 'Speaker hold'
    
      # Otherwise, if the result summary is from an independent ...
      elsif result_summary.is_from_independent
      
        # ... we set the new result summary text to 'Independent hold'.
        new_summary_text = 'Independent hold'
      
      # Otherwise, the result summary must be from a party ...
      else
      
        # ... so we find the party ...
        political_party = PoliticalParty.find( result_summary.from_political_party_id )
        
        # ... and set the new result summary text to 'party name hold'.
        new_summary_text = political_party.name + ' hold'
      end
    
    # Otherwise, if the result summary summary text includes neither ' gain from ' nor ' hold' ...
    else
    
      # ... we flag that something has gone wrong.
      puts "result summary summary text includes neither ' gain from ' nor ' hold'"
    end
    
    # If the result summary summary text has changed ...
    if new_summary_text != result_summary.summary
    
      # ... we set the summary of the result summary to new text ...
      result_summary.summary = new_summary_text
      
      # ... and save the result summary.
      result_summary.save!
    end
  end
end