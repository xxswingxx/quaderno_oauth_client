# frozen_string_literal: true

class CreateApiClients < ActiveRecord::Migration[7.0]
  def change
    create_table :api_clients do |t|
      t.text :token
      t.text :refresh_token
      t.datetime :token_expires_at

      t.timestamps
    end
  end
end
