class UsersController < ApplicationController
  before_filter :signed_in_user,  only: [:index, :edit, :update, :destroy]
  before_filter :correct_user,  only: [:edit, :update]
  before_filter :admin_user,  only: :destroy

  def destroy
    if User.find(params[:id]).admin?
      flash[:error] = "Admins cannot be deleted."
      redirect_to root_url
    else
      User.find(params[:id]).destroy
      flash[:success] = "User destroyed."
      redirect_to users_url
    end
  end

  def index
    @users = User.paginate(page: params[:page])
  end

  def show
    if signed_in? #added to correct error introduced by adding delete link to user profiles.
      @user = User.find(params[:id])
    else
      flash[:error] = "Please sign in to view user profiles."
      redirect_to signin_url
    end
  end
  
  def new
    if signed_in? #added for 9.6.6
      flash[:error] = "You cannot sign up if you're already signed in."
      redirect_to root_url
      #redirect_to users_path #various tests to tease out proper syntax
      #@user = User.new
    else
  	 @user = User.new
    end
  end

  def create
    if signed_in? #added for 9.6.6
      flash[:error] = "You cannot sign up if you're already signed in."
      redirect_to root_url
    else
    	@user = User.new(params[:user])
    	if @user.save
        sign_in @user
    		flash[:success] = "Welcome to the Sample App!"
    		redirect_to @user
    	else
    		render 'new'
    	end
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile Updated"
      sign_in @user
      redirect_to @user
    else
      render 'edit'
    end
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password,
       :password_confirmation)

    end

    # Before filters

    def signed_in_user
      store_location
      redirect_to signin_url, notice: "Please sign in." unless signed_in?
    end

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end

    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
end
