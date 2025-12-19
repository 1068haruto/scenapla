class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  protected

  def after_sign_up_path_for(resource)
    if resource.date_of_birth.blank?
      edit_dob_path
    else
      dashboard_path
    end
  end
end
