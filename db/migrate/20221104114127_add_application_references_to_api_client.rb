# frozen_string_literal: true

class AddApplicationReferencesToApiClient < ActiveRecord::Migration[7.0]
  def change
    add_reference :api_clients, :application_credential, index: true
  end
end
