class MemosController < ApplicationController
  before_action :authenticate_user!
  before_action :set_memo, only: %i[update]

  def create
    @memo = Memo.new(memo_params.merge(user_id: current_user.id))

    Rails.logger.info "Received memo params: #{memo_params.inspect}"
    Rails.logger.info "Memo object before save: #{@memo.inspect}"
    puts params.inspect

    if @memo.save
      render json: { message: '保存しました。', memo: @memo }
    else
      render json: { message: '保存に失敗しました。', errors: @memo.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @memo.update(memo_params)
      render json: { message: '更新しました。', memo: @memo }
    else
      render json: { message: '更新に失敗しました。', errors: @memo.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_memo
    @memo = Memo.find_by(id: params[:id], user_id: current_user.id)
  end

  def memo_params
    params.require(:memo).permit(:age_group, :content)
  end
end
