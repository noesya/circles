class ApplicationController < ActionController::Base
  include WithErrors
  
  before_action :authenticate_user!
end
