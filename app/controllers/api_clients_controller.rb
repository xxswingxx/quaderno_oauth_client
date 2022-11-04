# frozen_string_literal: true

class ApiClientsController < ApplicationController
  before_action :find_api_client, only: %i[show edit update destroy refresh_token]

  def index
    @api_clients = ApiClient.all
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @api_clients }
    end
  end

  def login
    app_credentials = ApplicationCredential.find_by(app_id: params[:app_id])

    if app_credentials
      client = OAuth2::Client.new(app_credentials.client_id, app_credentials.client_secret, site: 'http://lvh.me:3000')
      @url = client.auth_code.authorize_url(redirect_uri: app_credentials.redirect_uri)
    else
      @url = '#'
    end
  end

  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @api_client }
    end
  end

  def new
    @api_client = ApiClient.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @api_client }
    end
  end

  def create
    @api_client = ApiClient.new(params[:api_client])

    respond_to do |format|
      if @api_client.save
        format.html { redirect_to @api_client, notice: 'Api client was successfully created.' }
        format.json { render json: @api_client, status: :created, location: @api_client }
      else
        format.html { render action: 'new' }
        format.json { render json: @api_client.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @api_client.update_attributes(params[:api_client])
        format.html { redirect_to @api_client, notice: 'Api client was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @api_client.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @api_client.destroy

    respond_to do |format|
      format.html { redirect_to api_clients_url }
      format.json { head :no_content }
    end
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
end
