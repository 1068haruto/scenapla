class UsersController < AfterBaseController
  def show
    @user = current_user
  end
end
