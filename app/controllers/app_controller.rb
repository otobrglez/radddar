class AppController < ApplicationController

  include ActionView::Helpers::JavaScriptHelper

	respond_to :html, :only => [:app, :landing, :public_radddar]
  respond_to :js
  respond_to :json

	layout 'app'

	before_filter :check_user_auth, :except => [:landing, :live, :reminder, :wisdom_script, :steelfish, :reload_clients, :public_radddar]

	# Landing page
	def landing
		return redirect_to(app_url) if signed_in?

    @reminder = Reminder.new
		render :landing, :layout => false
  end

	# The app
	def app; end

  # Set reminder
  def reminder
    
    @reminder = Reminder.new
    unless params[:reminder].nil? or params[:reminder][:email].nil?
      @reminder.email = params[:reminder][:email] 
    end

    if @reminder.valid?
      ReminderMailer.thanks_for_signup(@reminder).deliver
      ReminderMailer.new_reminder(@reminder).deliver
    end

    respond_with(@reminder) do |f|
      f.js{ render "reminder" }
    end
  end

  # The live
  def live

    @users = User.all
    render :live, :layout => "live"
  end

  # Return user
  def profile
    @user = User.find(params[:id])
    respond_with(@user) do |f|
      f.js { render "app/user/profile" }
    end
  end

  # Retuns current user
  def current_user_action
    respond_with(current_user)
  end

  # Profile update
  def profile_update

    unless params[:user][:loc].nil?
      params[:user][:loc] = params[:user][:loc].map(&:to_f)
    end

    current_user.update_attributes(params[:user])
    
    if current_user.valid?
      current_user.save
      current_user.trigger_swap_event "status-update_swap", current_user
    end

    return render :json => current_user
  end

  # Status form
  def status_form
    respond_with(current_user) do |f|
      f.js { render "app/user/status_form" }
    end
  end

  # Get status
  def status_reload
    respond_with(current_user) do |f|
      f.js { render "app/user/status_reload" }
    end
  end

  # Set status
  def status_set
    current_user.update_attributes(params[:user])
    
    if current_user.valid?
      current_user.save
      # EVENT
      return render "app/user/status_reload"
    end

    respond_with(current_user) do |f|
      f.js { render "app/user/status_form" }
    end
  end

  # Swap the shit
  def swap
    respond_to do |f|
      f.json do 
        render :json => {
          live_list_html: (render_to_string(
            partial: "app/map/live_list", locals:{user: current_user})),
          stat_html: (render_to_string(
            partial: "app/stat"))
        }
      end
    end
  end

  # Send notification
  def notify
    @user = User.find(params[:id])
    current_user.notify(@user) if current_user.can_notify? @user
    respond_with(@user) do |f|
      f.js { render "app/user/notify" }
    end
  end

  # Remove notification
  def remove_note
    @note = Note.find_with_stamp(params[:stamp])
    unless @note.nil?
      @note.delete
    end

    respond_with(@note) do |f|
      f.js { render "app/chat/reload_chat_feed"}
    end
  end

  # Reload "chat feeds"
  def reload_chat_feed
    respond_with(current_user) do |f|
      f.js { render "app/chat/reload_chat_feed"}
    end
  end

  # Chat
  def chat
    @jump = params[:jump]
    @jump = 1 if @jump.nil?

    @user = User.find(params[:id])
    @message = Message.new(sender: current_user, recipient: @user)
    @messages = current_user.chat_with @user
    respond_with(@messages,@message) do |f|
      f.js { render "app/chat/chat" }
    end
  end

  # Send message
  def message
    @user = User.find(params[:id])
    @message = Message.new(
      sender: current_user,
      recipient: @user,
      body: params[:message][:body].strip)

    if @message.valid?
      @message.save
    end

    respond_with(@message,@user) do |f|
      f.js { render "app/chat/message" }
    end
  end

  # Send reload command to all clients
  def reload_clients
    if params[:key] == "I5iG0uOzPqh3"
      Pusher["general"].trigger("reload_clients",{when:DateTime.now})
      return render :json => {status: "OK"}
    end

    return render :json => {status: "Fail!"}
  end


  # For the loving god. S3 does not support "Access-Control-Allow-Origin" header
  def wisdom_script; send_font "wisdom_script-webfont.ttf" end
  def steelfish; send_font "steelfish.ttf" end

  # Public radddar
  def public_radddar
    begin
      @user = User.find(params[:id])
    rescue
      return redirect_to(root_path) if @user.nil?
    end

    respond_with(@user) do |f|
      f.html {
        render :public_radddar, layout: false
      }
    end
  end

	private
		# Make sure user is signed in!
		def check_user_auth
			return redirect_to(root_url, :notice => "Please sign in!") if not signed_in?
		end

    def send_font font
      response.headers["Access-Control-Allow-Origin"] = "*"
      response.headers["Expires"] = CGI.rfc1123_date(Time.now + 10.days)
      file_path = Rails.root.join("app","assets","images",font)
      File.open(file_path, 'r') do |f|
        send_data f.read, :type => "application/x-font-ttf", :filename => font
      end
    end

end
