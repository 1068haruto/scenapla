class LifePlansController < AfterBaseController
  def index
    @view_model = LifePlansIndexViewModel.new(current_user, params)
  end

  def generate_advice
    Api::OpenaiService.new(current_user).call
    redirect_to life_plans_path,
    notice: t("common.actions.get", data: AI_ADVICE)
  rescue => e
    redirect_to life_plans_path,
    alert: e.message
  end

  def save_memo
    @memo = current_user.memos.find_or_initialize_by(age_group: memo_params[:age_group])

    @memo.content = memo_params[:content]
    if @memo.save
      redirect_to life_plans_path,
      notice: t("common.actions.save", data: MEMO)
    else
      render_error(
        @memo.errors.full_messages.join,
        :unprocessable_entity
      )
    end
  end

  private

  def memo_params
    params.require(:memo).permit(:age_group, :content)
  end
end
