require "openai"

class OpenaiAdviceService
  ADVICE_LIMIT_PER_MONTH = 5
  MAX_TOKENS = 300
  TEMPERATURE = 0.7

  def initialize(user)
    @user = user
    @client = OpenAI::Client.new(access_token: ENV.fetch("OPENAI_API_KEY", Rails.application.credentials.dig(:openai, :api_key)))
  end

  def generate_and_save_advice
    return "今月のアドバイス取得回数の上限に達しました。取得回数は翌月にリセットされます。" if advice_request_limit_reached?
    return "データ入力がないため、アドバイスを生成できません。" unless valid_scenario_data?
    return "シナリオの更新がありません。" unless scenario_updated?

    new_advice_content = generate_advice_from_openai
    return new_advice_content if new_advice_content.start_with?("OpenAI APIエラー:", "エラーが発生しました:")
    @user.ai_advices.create!(content: new_advice_content, real_scenario_updated_at: @scenario.updated_at)

    "アドバイスを生成しました。" # 成功時のメッセージを返す
  end

  private

  def advice_request_limit_reached?
    start_of_month = Time.zone.now.beginning_of_month
    @user.ai_advices.where("created_at >= ?", start_of_month).count >= ADVICE_LIMIT_PER_MONTH
  end

  def valid_scenario_data?
    @scenario = @user.scenarios.find_by(scenario_type: "現実")
    @balance_scenario = @scenario&.balance_scenario
    @balance_scenario.present?
  end

  def scenario_updated?
    last_scenario_updated = @user.ai_advices.last&.real_scenario_updated_at
    scenario_table_updated = @scenario.updated_at
    last_scenario_updated != scenario_table_updated
  end

  def generate_advice_from_openai
    financial_forecast = generate_financial_data
    prompt = build_prompt(financial_forecast)

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
    "OpenAI APIエラー: #{e.message}"
  rescue StandardError => e
    "エラーが発生しました: #{e.message}"
  end

  def generate_financial_data
    current_age = @user.calculate_user_age
    current_year = Date.today.year

    financial_data = Hash.new(0)

    @balance_scenario.each do |entry|
      year = entry["date"]
      amount = entry["amount"]
      age_at_year = current_age + (year - current_year)
      age_group = (age_at_year / 10) * 10  # 40代,50代... に分類
      financial_data[age_group] += amount
    end

    financial_data
  end

  def build_prompt(financial_forecast)
    current_age = @user.calculate_user_age
    forecast_str = financial_forecast.map { |age, amount| "#{age}代:#{amount}万円" }.join("、")

    <<~PROMPT
      私は現在#{current_age}歳です。
      今後の収支状況は次のようになる見込みです。
      収支状況：#{forecast_str}
      上記の収支状況を評価した上で、今後の計画を立てるには何から考えると良いか、どんな目標を立てると良いかを上記の収支状況をもとにアドバイスをしてください。
      回答はどんな読み手でも理解しやすい、300字以内の日本語の文章にまとめてください。
      共有されていないライフイベントと70代以降の収支の減少については言及しないでください。
      70代までのマイナス収支があれば、特に考慮してください。
    PROMPT
  end
end
