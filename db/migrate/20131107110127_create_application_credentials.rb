# frozen_string_literal: true

class CreateApplicationCredentials < ActiveRecord::Migration[7.0]
  def change
    create_table :application_credentials do |t|
      t.text :client_id
      t.text :client_secret
      t.string :redirect_uri

      t.timestamps
    end
  end
end
