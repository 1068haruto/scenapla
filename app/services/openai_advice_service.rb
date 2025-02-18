require 'openai'

class OpenaiAdviceService
  def initialize(user)
    @user = user
    @client = OpenAI::Client.new(access_token: Rails.application.credentials.dig(:openai, :api_key))
  end

	def generate_advice
		prompt = build_prompt
	
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

  private

  def build_prompt
    <<~PROMPT
      総資産額100万円を持つ30歳です。
			5年以内に300万円の車を買うには、どのような計画を立てればよいでしょうか？
			実行可能なアドバイスを日本語で200字以内でください。
    PROMPT
  end
end