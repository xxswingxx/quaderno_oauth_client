class AddProviderUrlToApplicationCredentials < ActiveRecord::Migration[7.0]
  def change
    add_column :application_credentials, :provider_url, :string
  end
end
