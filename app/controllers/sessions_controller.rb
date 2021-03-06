class SessionsController < ApplicationController
  def login
    if session[:user].nil?
      if params[:login].nil?
        logout
      else
        authenticate
      end
    end
  end
  def authenticate
    username = params[:login][:username]
    password = params[:login][:password]
    
    user = User.where("username=?", username)
    if user.empty?
      logout
      (flash[:messages] ||= []) << "User not found."
      return
    end

    if BCrypt::Password.new(user.first[:password_digest]) == password
      session[:user] = username
      session[:card] = user.first[:card_access]
      cookies[:timeout] = Rails.application.config.session_options[:expire_after]
      print Rails.application.config.session_options[:expire_after], "%%"

    else
      logout
      (flash[:messages] ||= []) << "Incorrect password."
    end
  end
  def logout
    cookies.delete(:timeout) 
    reset_session
    redirect_to "/welcome/index"
  end
end
