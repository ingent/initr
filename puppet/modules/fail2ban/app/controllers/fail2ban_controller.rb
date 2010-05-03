class Fail2banController < InitrController
  unloadable

  menu_item :initr
  # authorize filter expects @project to be the current project
  # we set this on find_fail2ban filter
  before_filter :find_fail2ban, :authorize

  def configure
    if request.post?
      params["fail2ban"] ||= {}
      params["fail2ban"]["fail2ban_jails"] ||= {}
      if @klass.update_attributes(params["fail2ban"])
        flash[:notice]='Configuration saved'
        redirect_to :controller=>'klass', :action=>'list', :id=>@node
      else
        render :action=>'configure'
      end
    end
  end

  private

  def find_fail2ban
    @klass = Initr::Fail2ban.find params[:id]
    @node = @klass.node
    @project = @node.project
  end

end
