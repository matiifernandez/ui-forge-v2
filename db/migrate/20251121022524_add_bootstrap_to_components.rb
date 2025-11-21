class AddBootstrapToComponents < ActiveRecord::Migration[7.1]
  def change
    add_column :components, :bootstrap, :boolean, default: false
  end
end
