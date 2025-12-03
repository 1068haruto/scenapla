module DataGenerator
  class PromptGenerator
    def initialize(user, scenario)
      @user = user
      @scenario = scenario
      @balance_scenario = scenario.balance_scenario
    end

    # プロンプトの生成-> String
    def call
      financial_forecast = generate_financial_data
      forecast_str = financial_forecast.map { |age, amount| "#{age}代:#{amount}万円" }.join("、")

      <<~PROMPT
        以下のユーザー情報とアドバイス要件に基づき、今後のライフプランについてアドバイスを提供してください。
        # ユーザー情報:
        - 私の名前: #{@user.name}
        - 私の現在年齢: #{@user.calculate_user_age}歳
        - 私の今後の収支状況の見込み: #{forecast_str}
        # アドバイスの要件:
        - 300字以内の日本語で回答してください。
        - どのような読み手でも理解しやすいように、専門用語は避けてください。
        - 共有されていないライフイベントと70代以降の収支の減少については言及しないでください。
        - 70代までに、マイナスの収支があれば、特に考慮してください。
      PROMPT
    end

    private

    # 見込み収支データの生成-> Hash{age_group => total_amount}
    def generate_financial_data
      current_age = @user.calculate_user_age
      current_year = Date.today.year
      financial_data = Hash.new(0)

      @balance_scenario.each do |entry|
        age_at_year = current_age + (entry["date"].to_i - current_year)
        age_group = (age_at_year / 10) * 10  # 40代,50代...に分類
        financial_data[age_group] += entry["amount"].to_i
      end

      financial_data
    end
  end
end
