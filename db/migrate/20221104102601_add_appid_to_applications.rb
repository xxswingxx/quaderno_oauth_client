# frozen_string_literal: true

class AddAppidToApplications < ActiveRecord::Migration[7.0]
  def change
    add_column :application_credentials, :app_id, :string

    add_index :application_credentials, :app_id, unique: true
  end
end
