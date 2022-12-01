# frozen_string_literal: true

class ApplicationCredentialsController < ApplicationController
  respond_to :html
  before_action :find_application_credential, only: %i[show edit update destroy]

  def new
    @application_credential = ApplicationCredential.new
  end

  def index
    @application_credentials = ApplicationCredential.all
    respond_with @application_credentials
  end

  def show
    @application_credential = ApplicationCredential.find(params[:id])
    client = OAuth2::Client.new(@application_credential.client_id, @application_credential.client_secret, site: @application_credential.provider_url)
    @url = client.auth_code.authorize_url(redirect_uri: @application_credential.redirect_uri)

    respond_with @application_credential
  end

  def create
    @application_credential = ApplicationCredential.new(create_params)
    @application_credential.save

    respond_with(@application_credential)
  end

  def update
    if @application_credential.update(update_params)
      flash[:notice] = 'Application credential was successfully updated.'
      respond_with(@application_credential)
    else
      flash.now[:alert] = @application_credential.errors
      render action: 'edit'
    end
  end

  def destroy
    @application_credential.destroy

    redirect_to application_credentials_url
  end

  def generate_access_token
    application_credentials = ApplicationCredential.find_by_app_id(params[:app_id])
    client = OAuth2::Client.new(application_credentials.client_id, application_credentials.client_secret, site: application_credentials.provider_url)
    token = client.auth_code.get_token(params[:code], redirect_uri: application_credentials.redirect_uri)
    api_client = application_credentials.api_clients.build
    api_client.update(token: token.token, token_expires_at: Time.at(token.expires_at), refresh_token: token.refresh_token)

    redirect_to api_clients_path
  end

  private

  def find_application_credential
    @application_credential = ApplicationCredential.find params[:id]
  end

  def create_params
    params.require(:application_credential).permit(:app_id, :client_id, :client_secret, :redirect_uri, :provider_url)
  end

  def update_params
    params.require(:application_credential).permit(:app_id, :client_id, :client_secret, :redirect_uri, :provider_url)
  end
end
