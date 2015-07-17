class CreateSearchSuggestion < ActiveRecord::Migration
  def change
    create_table :search_suggestion do |t|
      t.string :term
      t.integer :popularity
    end
  end
end
