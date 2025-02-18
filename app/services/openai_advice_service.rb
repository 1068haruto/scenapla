require 'openai'

class OpenaiAdviceService
  def initialize(user)
    @user = user
    @client = OpenAI::Client.new(access_token: Rails.application.credentials.dig(:openai, :api_key))
  end

  def generate_and_save_advice
    existing_advice = @user.ai_advices.last
    new_advice_content = generate_advice_from_openai # OpenAI API を呼び出して新しいアドバイスを取得

    if existing_advice.present?
      existing_advice.update!(content: new_advice_content)  # 既存のアドバイスを更新
    else
      @user.ai_advices.create!(content: new_advice_content) # 新規作成
    end

    new_advice_content
  end

	private

  def generate_advice_from_openai
    financial_forecast = generate_financial_data(@user)
    prompt = build_prompt(financial_forecast)

    response = @client.chat(
      parameters: {
        model: "gpt-3.5-turbo",
        messages: [
          { role: "system", content: "あなたは経験豊富なライフプランナーです。" },
          { role: "user", content: prompt }
        ],
        max_tokens: 300,
        temperature: 0.7
      }
    )

    response.dig("choices", 0, "message", "content") || "アドバイスの生成に失敗しました。"
  rescue OpenAI::Error => e
    "OpenAI APIエラー: #{e.message}"
  rescue StandardError => e
    "エラーが発生しました: #{e.message}"
  end

  def build_prompt(financial_forecast)
    current_age = @user.calculate_user_age
    forecast_str = financial_forecast.map { |age, amount| "#{age}代:#{amount}万円" }.join("、")

    <<~PROMPT
      私は現在#{current_age}歳です。
      ライフイベントを考慮すると、今後の収支状況は下記となる見込みです。
      どのようなプランをいつ実行すれば、改善できるかを下記情報を元に教えてください。
      回答は、理由と特に注意すべき時期を含めて、300字以内の日本語でお願いいたします。
      誰でも理解しやすい単語や文章にしてください。
      #{forecast_str}
    PROMPT
  end

  def generate_financial_data(user)
    current_age = user.calculate_user_age
    current_year = Date.today.year

    scenario = user.scenarios.find_by(scenario_type: "現実") # "現実"のシナリオを取得
    balance_scenario = scenario&.balance_scenario || [] # balance_scenarioを取得

    financial_data = Hash.new(0)  # 年代ごとの収支を格納するハッシュ

    balance_scenario.each do |entry|
      year = entry["date"]
      amount = entry["amount"]

      # その年のユーザーの年齢を計算
      age_at_year = current_age + (year - current_year)
      age_group = (age_at_year / 10) * 10 # 30代, 40代, 50代... に分類

      financial_data[age_group] += amount  # 該当する年代の合計収支を更新
    end

    financial_data
  end
end
