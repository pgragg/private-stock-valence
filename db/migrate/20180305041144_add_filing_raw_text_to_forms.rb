class AddFilingRawTextToForms < ActiveRecord::Migration[5.1]
  def change
    add_column :forms, :filing_raw_text, :text
  end
end
