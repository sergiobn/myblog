class ChangeColumnPermissionLevelFromStringToInteger < ActiveRecord::Migration
  def change
  	remove_column :users,:permission_level
  	add_column :users,:permission_level, :integer
  end
end
