class AddIsNotionalPoliticalPartyAggregateToCandidacies < ActiveRecord::Migration[8.1]
  def change
    add_column :candidacies, :is_notional_political_party_aggregate, :boolean, default: false
  end
end
