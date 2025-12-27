require "rails_helper"

RSpec.describe Api::OpenaiService do
  let!(:user) { create(:user) }
  let!(:simulation) { create(:simulation, user: user) }
  let!(:scenario) { create(:scenario, user: user, simulation: simulation, scenario_type: "現実", updated_at: 1.day.ago) }
  let(:service) { described_class.new(user) }

  before do
    allow(user).to receive(:get_user_age).and_return(30)
    allow_any_instance_of(Scenario).to receive(:balance_scenario).and_return([ { "date" => Date.today.year, "amount" => 100 } ])
  end

  describe "#call" do
    context "回数制限中の場合" do
      before do
        create_list(:ai_advice, Constants::ADVICE_LIMIT_PER_MONTH, user: user, created_at: Time.zone.now.beginning_of_month + 1.hour)
      end

      it "上限到達の例外を返す" do
        expect { service.call }.to raise_error(
          Api::OpenaiService::AdviceGenerationError,
          "生成可能回数を超えています（翌月月初にリセット）"
        )
      end
    end

    context "scenarios.balance_dataがない場合" do
      before do
        user.scenarios.destroy_all
      end

      it "データなしの例外を返す" do
        expect { service.call }.to raise_error(
          Api::OpenaiService::AdviceGenerationError,
          "データ入力がないため、生成できません。"
        )
      end
    end

    context "scenariosの更新がない場合" do
      before do
        # 時刻を固定（秒未満を0にする）
        fixed_time = Time.zone.now.change(usec: 0)

        # scenarioとadviceの時刻を完全に一致させる
        scenario.update!(updated_at: fixed_time)
        create(:ai_advice, user: user, real_scenario_updated_at: fixed_time)
      end

      it "更新なしの例外を返す" do
        expect { service.call }.to raise_error(
          Api::OpenaiService::AdviceGenerationError,
          "シミュレーション結果の更新がありません。"
        )
      end
    end

    context "OpenAIの正常時" do
      let(:mock_openai_response) do
        { "choices" => [ { "message" => { "content" => "アドバイス内容" } } ] }
      end

      before do
        allow_any_instance_of(OpenAI::Client).to receive(:chat).and_return(mock_openai_response)
        create(:ai_advice, user: user, real_scenario_updated_at: 2.day.ago)
      end

      it "生成されたアドバイスを返す", :focus do
        expect { @result = service.call }.to change { user.ai_advices.count }.by(1)
        expect(user.ai_advices.last.content).to eq("アドバイス内容")
        expect(@result).to eq(true)
      end
    end

    context "OpenAIの異常時" do
      before do
        allow_any_instance_of(OpenAI::Client).to receive(:chat).and_raise(OpenAI::Error.new("APIエラー"))
      end

      it "APIエラーメッセージを返す" do
        expect { service.call }.to raise_error(
          Api::OpenaiService::AdviceGenerationError,
          /APIエラー/
        )
      end
    end

    context "予期せぬエラーが発生する場合" do
      before do
        allow_any_instance_of(OpenAI::Client).to receive(:chat).and_raise(StandardError.new("予期しないエラー"))
      end

      it "一般的なエラーメッセージを返す" do
        expect { service.call }.to raise_error(
          Api::OpenaiService::AdviceGenerationError,
          "エラーが発生しました: 予期しないエラー"
        )
      end
    end
  end
end
