class CreateRooms < ActiveRecord::Migration[7.0]
  def change
    create_table :rooms, id: :string do |t|
      t.string :word, null: false, limit: 5

      t.timestamps
    end
  end
end
