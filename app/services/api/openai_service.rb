require "openai"

module Api
  class OpenaiService
    include Constants

    class AdviceGenerationError < StandardError; end

    def initialize(user)
      @user = user
      @client = OpenAI::Client.new(
        access_token: ENV.fetch("OPENAI_API_KEY", Rails.application.credentials.dig(:openai, :api_key))
      )
      @scenario = @user.scenarios.find_by(scenario_type: "現実")
    end

    # アドバイス生成 & 保存-> Boolean
    def call
      check_preconditions!

      new_advice_content = generate_from_api
      @user.ai_advices.create!(
        content: new_advice_content,
        real_scenario_updated_at: @scenario.updated_at
      )
      true
    end

    private

    # 前提条件チェック-> 例外発生 or true
    def check_preconditions!
      # 生成回数（上限：月3回）
      start_of_month = Time.zone.now.beginning_of_month
      count = @user.ai_advices.where("created_at >= ?", start_of_month).count
      if count >= ADVICE_LIMIT_PER_MONTH
        raise AdviceGenerationError, "アドバイス生成可能回数を超えています。翌月にリセットされます。"
      end

      # 収支シナリオの存在
      balance_scenario = @scenario&.balance_scenario
      if !balance_scenario.present?
        raise AdviceGenerationError, "データ入力がないため、アドバイスを生成できません。"
      end

      # シナリオの更新有無
      last_scenario_updated = @user.ai_advices.last&.real_scenario_updated_at
      scenario_table_updated = @scenario.updated_at
      if last_scenario_updated == scenario_table_updated
        raise AdviceGenerationError, "シミュレーション結果の更新がありません。"
      end
    end

    # APIリクエスト-> String
    def generate_from_api
      prompt = DataGenerator::PromptGenerator.new(@user, @scenario).call

      response = @client.chat(
        parameters: {
          model: "gpt-3.5-turbo",
          messages: [
            { role: "system", content: "あなたは経験豊富なライフプランナーです。" },
            { role: "user", content: prompt }
          ],
          max_tokens: MAX_TOKENS,
          temperature: TEMPERATURE
        }
      )

      response.dig("choices", 0, "message", "content") || "アドバイスの生成に失敗しました。"
    rescue OpenAI::Error => e
      raise AdviceGenerationError, "APIエラー: #{e.message}"
    rescue StandardError => e
      raise AdviceGenerationError, "エラーが発生しました: #{e.message}"
    end
  end
end
