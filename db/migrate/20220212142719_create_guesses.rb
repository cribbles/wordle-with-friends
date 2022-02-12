class CreateGuesses < ActiveRecord::Migration[7.0]
  def change
    create_table :guesses do |t|
      t.string :word, null: false, limit: 5
      t.references :player, null: false, foreign_key: true

      t.timestamps
    end
  end
end
