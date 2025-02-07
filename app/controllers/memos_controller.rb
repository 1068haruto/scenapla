class MemosController < ApplicationController
  before_action :authenticate_user!

  def create
    @memo = current_user.memos.new(memo_params)
    if @memo.save
      render json: { message: "保存しました。", memo: @memo }
    else
      render json: { message: "保存に失敗しました。", errors: @memo.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    @memo = current_user.memos.find_by(id: params[:id])
    if @memo.update(memo_params)
      render json: { message: "保存しました。", memo: @memo }
    else
      render json: { message: "保存に失敗しました。", errors: @memo.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def memo_params
    params.require(:memo).permit(:age_group, :content)
  end
end
