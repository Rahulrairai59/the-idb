class AddDiskSpaceToMachine < ActiveRecord::Migration[4.2]
  def change
    add_column :machines, :diskspace, :bigint
  end
end
