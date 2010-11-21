# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem

  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password


  protected
    def render_optional_error_file(status_code)
      render :template => 'errors/500', :status => 500, :layout => 'application'
    end

    def rescues_path(template_name)
      "#{template_root}/rescues/#{template_name}.rhtml"
    end
end
