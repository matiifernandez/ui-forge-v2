class AddColumnsToProject < ActiveRecord::Migration[7.1]
  def change
    add_column :projects, :primary_color, :string
    add_column :projects, :secondary_color, :string
  end
end
