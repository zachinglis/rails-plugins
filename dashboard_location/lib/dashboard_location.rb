module DashboardLocation
  def self.included(controller)
    controller.helper_method(:dashboard_domain, :dashboard_subdomain, 
                             :dashboard_host, :dashboard_url, 
                             :current_dashboard, :current_subscription)
  end

protected
  def default_dashboard_subdomain
   current_dashboard.permalink if current_dashboard
  end

  def home_url(dashboard_subdomain = default_dashboard_subdomain, use_ssl = request.ssl?)
    (use_ssl ? "https://" : "http://") + dashboard_host(dashboard_subdomain)
  end

  def dashboard_host(dashboard_subdomain = default_dashboard_subdomain)
    dashboard_subdomain + "." + dashboard_domain
  end

  def dashboard_domain
    dashboard_domain = ""
    dashboard_domain << request.subdomains[1..-1].join(".") + "." if request.subdomains.size > 1
    dashboard_domain << request.domain + request.port_string
    dashboard_domain
  end

  def dashboard_subdomain
    request.subdomains.first
  end

  def current_dashboard
    Home.find_by_permalink(dashboard_subdomain)
  end

  def ensure_current_dashboard
    return true if current_dashboard
    flash[:notice] = "Sorry, but that is an invalid home."
    redirect_to root_url and return false
  end
  
  def should_add_subdomain_for_home_if_logged_in
    redirect_to dashboard_link if request.subdomains.empty? && logged_in?
  end

  def should_redirect_if_no_subdomain
    return unless request.subdomains.empty?
    redirect_to logged_in? ? dashboard_link : root_url
  end

  def redirect_dashboard_calls
    return if request.subdomains.empty?
    if !logged_in? && !dashboard_subdomain.nil? && !current_dashboard.nil?      
      flash[:notice] = "Please login to access your account"
      redirect_to login_url
    elsif logged_in? && current_user.home_id.nil?
      flash[:notice] = "You don't have a home."
      redirect_to root_url
    elsif logged_in? && current_user.home_id != dashboard_subdomain.id
      flash[:notice] = "Please only access your own home panel."
      redirect_to dashboard_link(current_dashboard.permalink)
    elsif dashboard_subdomain && current_dashboard.nil?
      flash[:notice] = "We can't find where you are looking for."
      redirect_to clean_root_url
    elsif logged_in? && (request.path.nil? || request.path == "/")
      redirect_to_dashboard_if_logged_in
    end
  end

  def redirect_to_dashboard_if_logged_in
    redirect_to dashboard_url if logged_in?
  end

  def dashboard_link(permalink=nil)
    home_permalink = request.subdomains.empty? ? current_user.home.permalink : request.subdomains.first
    home_permalink = permalink unless permalink.nil? # overwrite fu
    protocol + home_permalink + request.port_string
  end

  def clean_root_url
    protocol + request.domain + request.port_string
  end
  
  def protocol
    request.ssl? ? "https://" : "http://"
  end
end