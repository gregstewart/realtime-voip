class CreateRealtimes < ActiveRecord::Migration
  def self.up
    create_table :realtimes do |t|
      t.string :auto_login
      t.string :auto_password
      t.integer:account_id
      t.string :password
      t.text :xml_content
      t.timestamps
    end
  end

  def self.down
    drop_table :realtimes
  end
end
