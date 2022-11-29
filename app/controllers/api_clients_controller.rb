# frozen_string_literal: true

class ApiClientsController < ApplicationController
  respond_to :html
  before_action :find_api_client, only: %i[show edit update destroy refresh_token]

  def index
    @api_clients = ApiClient.all
    respond_with @api_clients
  end

  def update
    if @api_client.update_attributes(update_params)
      redirect_to @api_client, notice: 'Api client was successfully updated.'
    else
      flash.now[:alert] = @api_client.errors
      render action: 'edit'
    end
  end

  def destroy
    @api_client.destroy

    redirect_to api_clients_url
  end

  def refresh_token
    application_credential = @api_client.application_credential

    client = OAuth2::Client.new(
      application_credential.client_id,
      application_credential.client_secret,
      redirect_uri: application_credential.redirect_uri,
      site: ApplicationCredential::SITE
    )

    token = OAuth2::AccessToken.from_hash(client, refresh_token: @api_client.refresh_token, grant_type: 'refresh_token')
    token_info = token.refresh!

    @api_client.update(token: token_info.token, refresh_token: token_info.refresh_token, token_expires_at: Time.at(token_info.expires_at))

    redirect_to api_clients_url
  end

  private

  def find_api_client
    @api_client = ApiClient.find(params[:id])
  end

  def update_params
    params.require(:api_client).permit(:token, :refresh_token, :token_expires_at)
  end
end
