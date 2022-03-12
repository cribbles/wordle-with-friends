class AddPasswordToPlayers < ActiveRecord::Migration[7.0]
  def change
    add_column :players, :password, :string

    Player.update_all(password: SecureRandom.alphanumeric(10))

    change_column_null :players, :password, false
  end
end
