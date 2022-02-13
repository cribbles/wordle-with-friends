class CreateGuesses < ActiveRecord::Migration[7.0]
  def change
    create_table :guesses do |t|
      t.string :word, null: false, limit: 5
      t.string :player_id, null: false, index: true

      t.timestamps
    end

    add_foreign_key :guesses, :players
  end
end
