# frozen_string_literal: true

class ApplicationCredential < ApplicationRecord
  SITE = 'https://sandbox-quadernoapp.com'
  #SITE = 'http://lvh.me:3000'

  validates :client_id, presence: true, uniqueness: true
  validates :client_secret, presence: true, uniqueness: true

  after_initialize :set_app_id
  before_save :set_redirect_uri

  has_many :api_clients

  def set_app_id
    self.app_id ||= SecureRandom.hex(20)
  end

  def set_redirect_uri
    self.redirect_uri ||= "https://quaderno.ngrok.io/#{app_id}/callback"
  end
end
