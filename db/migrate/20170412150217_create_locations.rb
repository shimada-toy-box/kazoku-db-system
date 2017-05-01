class CreateLocations < ActiveRecord::Migration[5.0]
  def change
    create_table :locations do |t|
      t.string :address
      t.decimal :latitude, {:precision => 10, :scale => 6}
      t.decimal :longitude, {:precision => 10, :scale => 6}

      t.timestamps
    end
    add_reference :locations, :user
  end
end
