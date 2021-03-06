class CustomKlasses < ActiveRecord::Migration

  def self.up
    puts "\nYOU SHOULD UPDATE YOUR DATABASE WITH: update klasses set type=\"CustomKlass\" where type is NULL;\n\n"
    add_column(:klasses, :name, :string)
    add_column(:klasses, :description, :string)
    create_table :custom_klass_confs do |t|
      t.integer :custom_klass_id
      t.string :name
      t.string :value
    end
  end

  def self.down
    remove_column(:klasses, :name)
    remove_column(:klasses, :description)
    drop_table :custom_klass_confs
  end

end

