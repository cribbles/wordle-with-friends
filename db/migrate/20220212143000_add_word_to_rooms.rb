class AddWordToRooms < ActiveRecord::Migration[7.0]
  def change
    add_column :rooms, :word, :string, null: false, limit: 5
  end
end
