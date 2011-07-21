class ApplicationController < ActionController::Base
  before_filter :authenticate

  self.append_view_path("lib/big_tuna/hooks")
  protect_from_forgery

  protected

  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      AUTH.each.map do |auth|
        auth["name"] == username && auth["password"] == password
      end.include?(true)
    end
  end
end
