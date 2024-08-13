class Api::V1::ApplicationController < ActionController::Base
  include Api::SessionsHelper
  include Api::PaginationsHelper

  Settings.http_status_codes.each do |key, value|
    define_method "response_#{key}" do |messages = "", data = nil|
      response = {messages:, data:}
      render json: response, status: value
    end
  end

  skip_before_action :verify_authenticity_token

  before_action :set_locale

  private
  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options
    {locale: I18n.locale}
  end
end
