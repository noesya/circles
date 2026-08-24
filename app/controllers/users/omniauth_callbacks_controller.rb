class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: :saml

  def saml
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user&.persisted?
      @user.remember_me = true
      sign_in_and_redirect @user, event: :authentication
    else
      flash[:notice] = t('devise.omniauth_callbacks.failure')
      redirect_to new_user_session_url
    end
  end

end