class ChangeShortestPathFromStringToInt < ActiveRecord::Migration[7.1]
  def change
    change_column :games, :shortest_path, :integer
  end
end
