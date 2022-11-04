# frozen_string_literal: true

class ApplicationCredentialsController < ApplicationController
  before_action :find_application_credential, only: %i[show edit update destroy]

  def index
    @application_credentials = ApplicationCredential.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @application_credentials }
    end
  end

  def show
    @application_credential = ApplicationCredential.find(params[:id])
    client = OAuth2::Client.new(@application_credential.client_id, @application_credential.client_secret, site: ApplicationCredential::SITE)
    @url = client.auth_code.authorize_url(redirect_uri: @application_credential.redirect_uri)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @application_credential }
    end
  end

  def new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @application_credential }
    end
  end

  def create
    @application_credential = ApplicationCredential.new(create_params)

    respond_to do |format|
      if @application_credential.save
        format.html { redirect_to @application_credential, notice: 'Application credential was successfully created.' }
        format.json { render json: @application_credential, status: :created, location: @application_credential }
      else
        format.html { render action: 'new' }
        format.json { render json: @application_credential.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @application_credential.update(update_params)
        format.html { redirect_to @application_credential, notice: 'Application credential was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @application_credential.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @application_credential.destroy

    respond_to do |format|
      format.html { redirect_to application_credentials_url }
      format.json { head :no_content }
    end
  end

  def generate_access_token
    application_credentials = ApplicationCredential.find_by_app_id(params[:app_id])
    client = OAuth2::Client.new(application_credentials.client_id, application_credentials.client_secret, site: ApplicationCredential::SITE)
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
    params.require(:application_credential).permit(:client_id, :client_secret, :redirect_uri)
  end

  def update_params
    params.require(:application_credential).permit(:client_id, :client_secret, :redirect_uri)
  end
end
