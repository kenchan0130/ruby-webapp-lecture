class CreatePosts < ActiveRecord::Migration[4.2]
  def change
    create_table :posts do |t|
      t.string :title,    null: false
      t.string :contents, null: false

      t.timestamps
    end
  end
end
