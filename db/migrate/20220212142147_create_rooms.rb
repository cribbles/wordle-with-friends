class CreateRooms < ActiveRecord::Migration[7.0]
  def change
    create_table :rooms do |t|
      t.string :name, null: false, unique: true, limit: 6

      t.timestamps
    end
  end
end
