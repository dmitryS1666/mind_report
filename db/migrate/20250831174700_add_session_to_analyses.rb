class AddSessionToAnalyses < ActiveRecord::Migration[7.0]
  def change
    add_reference :analyses, :session, null: false, foreign_key: true
  end
end
