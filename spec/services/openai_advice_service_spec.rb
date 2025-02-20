require "rails_helper"

RSpec.describe OpenaiAdviceService do
  let!(:user) { create(:user, :without_scenarios) } # シナリオデータの自動生成を抑制
  let!(:simulation) { create(:simulation, user: user) }
  let!(:scenario) { create(:scenario, user: user, simulation: simulation,  updated_at: 1.day.ago) }
  let(:service) { described_class.new(user) }
  let(:balance_scenario) { [ { "date" => Date.today.year, "amount" => 100 } ] }

  before do
    allow(user).to receive(:scenarios).and_return(Scenario.where(user: user))
    allow(user).to receive(:calculate_user_age).and_return(30)
    allow(scenario).to receive(:balance_scenario).and_return(balance_scenario)
  end

  describe "#generate_and_save_advice" do
    context "リクエスト制限回数を超える場合" do
      before do
        create_list(:ai_advice, OpenaiAdviceService::ADVICE_LIMIT_PER_MONTH, user: user, created_at: Time.zone.now.beginning_of_month + 1.hour)
      end

      it "処理を中断し、上限到達メッセージを返す" do
        expect(service.generate_and_save_advice).to eq("今月のアドバイス取得回数の上限に達しました。")
      end
    end

    context "scenariosテーブルのbalance_dataがない場合" do
      before do
        allow(user).to receive(:scenarios).and_return(Scenario.none)
      end

      it "処理を中断し、データなしのメッセージを返す" do
        expect(service.generate_and_save_advice).to eq("データ入力がないため、アドバイスを生成できません。")
      end
    end

    context "scenariosテーブル内容の変更がない場合" do
      before do
        allow(user).to receive(:scenarios).and_return(Scenario.where(id: scenario.id))
        allow(scenario).to receive(:balance_scenario).and_return(balance_scenario)
        create(:ai_advice, user: user, real_scenario_updated_at: scenario.updated_at)
      end

      it "処理を中断し、変更がない旨のメッセージを返す" do
        expect(service.generate_and_save_advice).to eq("シナリオの更新がありません。")
      end
    end

    context "OpenAI APIが正常にレスポンスする場合" do
      let(:mock_openai_response) do
        { "choices" => [ { "message" => { "content" => "これはサンプルのアドバイスです。" } } ] }
      end

      before do
        allow_any_instance_of(OpenAI::Client).to receive(:chat).and_return(mock_openai_response)
        create(:ai_advice, user: user, real_scenario_updated_at: 2.day.ago)
      end

      it "アドバイスを生成し成功メッセージを返す", :focus do
        expect { service.generate_and_save_advice }.to change { user.ai_advices.count }.by(1)
        expect(user.ai_advices.last.content).to eq("これはサンプルのアドバイスです。")
        expect(service.generate_and_save_advice).to eq("アドバイスを生成しました。")
      end
    end

    context "when OpenAI API returns an error" do
      before do
        allow_any_instance_of(OpenAI::Client).to receive(:chat).and_raise(OpenAI::Error.new("APIエラー"))
      end

      it "returns an error message" do
        expect(service.generate_and_save_advice).to eq("OpenAI APIエラー: APIエラー")
      end
    end

    context "when an unexpected error occurs" do
      before do
        allow_any_instance_of(OpenAI::Client).to receive(:chat).and_raise(StandardError.new("予期しないエラー"))
      end

      it "returns a generic error message" do
        expect(service.generate_and_save_advice).to eq("エラーが発生しました: 予期しないエラー")
      end
    end
  end
end
