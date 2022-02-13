class CreatePlayers < ActiveRecord::Migration[7.0]
  def change
    create_table :players, id: :string do |t|
      t.string :name
      t.string :room_id, null: false, index: true
 
      t.timestamps
    end

    add_foreign_key :players, :rooms
  end
end
