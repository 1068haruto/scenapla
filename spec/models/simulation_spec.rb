require 'rails_helper'

RSpec.describe Simulation, type: :model do
  let(:user) { create(:user) }
  let(:simulation) { create(:simulation, user: user) }

  describe 'アソシエーションテスト' do
    it { should belong_to(:user) }
    it { should have_many(:incomes).dependent(:destroy) }
    it { should have_many(:expenses).dependent(:destroy) }
    it { should have_many(:user_assets).dependent(:destroy) }
    it { should have_many(:life_events).dependent(:destroy) }
    it { should have_many(:scenarios).dependent(:destroy) }
    it { should have_many(:asset_lifespans).dependent(:destroy) }
  end

  describe 'バリデーションテスト' do
    context '必須項目の確認' do
      it 'user_idは必須' do
        simulation.user = nil
        expect(simulation).not_to be_valid
      end
    end
  end

  describe 'クラスメソッドテスト' do
    let(:life_event_data) { { "date"=>2000, "amount"=>100 } }

    describe '.calculate_scenario_data' do
      before do
        allow(simulation).to receive(:merged_income_expense_event).with(life_event_data).and_return({ "date"=>2000, "amount"=>100 })
        allow(simulation).to receive(:get_total_income).and_return(2000)

        # life_event_dataにreal_life_event_data入っていない場合を想定
        simulation.expense_data = [ { "date"=>2000, "amount"=>100 } ]
        simulation.real_life_event_data = [ { "date"=>2000, "amount"=>100 } ]
        valid_datasets = [ simulation.expense_data, life_event_data, simulation.real_life_event_data ].compact  # nilを取り除く
        allow(simulation).to receive(:get_total_expense).with(*valid_datasets).and_return(-1000)

        allow(simulation).to receive(:get_monthly_expense).and_return(20)
        allow(simulation).to receive(:calculate_shortage).with(1000).and_return(100)
        allow(described_class).to receive(:calculate_and_save_lifespan_data).with(simulation)
      end

      it 'シナリオデータを計算する各処理が正しく呼ばれる' do
        result = described_class.calculate_scenario_data(simulation, life_event_data)

        expect(result[:balance_scenario]).to eq({ "date"=>2000, "amount"=>100 })
        expect(result[:total_income]).to eq(2000)
        expect(result[:total_expense]).to eq(-1000)
        expect(result[:total_balance]).to eq(1000)  # 2000 + (-1000)
        expect(result[:withdrawal]).to eq(50)  # 1000 / 20
        expect(result[:shortage]).to eq(0)  # total_balance > 0 のため
      end

      it '資産寿命データの計算と保存をする処理が呼ばれる' do
        expect(described_class).to receive(:calculate_and_save_lifespan_data).with(simulation)
        described_class.calculate_scenario_data(simulation, life_event_data)
      end
    end

    describe '.calculate_and_save_lifespan_data' do
      before do
        allow(simulation.user_assets).to receive(:sum).with(:amount).and_return(total_assets)
        allow(simulation).to receive(:get_monthly_expense).and_return(monthly_expense)
        allow(AssetLifespan).to receive(:update_lifespan_data!) # ここは一旦モック
        allow(described_class).to receive(:calculate_yearly_lifespan).with(total_assets, monthly_expense).and_return(yearly_lifespan)
        allow(described_class).to receive(:convert_to_years_and_months).with(total_assets, monthly_expense).and_return([ lifespan_years, lifespan_months ])
      end

      context '月次支出が0以下の場合' do
        let(:total_assets) { 1000 }
        let(:monthly_expense) { 0 }
        let(:yearly_lifespan) { nil }
        let(:lifespan_years) { nil }
        let(:lifespan_months) { nil }

        it '計算をスキップする' do
          expect(AssetLifespan).not_to receive(:update_lifespan_data!)
          described_class.calculate_and_save_lifespan_data(simulation)
        end
      end

      context '月次支出が0以上の場合' do
        let(:total_assets) { 120 } # 1200万円の資産
        let(:monthly_expense) { 10 } # 月10万円の支出
        let(:yearly_lifespan) { { 2000 => 120,  2001=> 90, 2002=> -30 } } # 計算上の年間寿命
        let(:lifespan_years) { 1 }
        let(:lifespan_months) { 0 }

        it '資産寿命データを更新する' do
          expect(AssetLifespan).to receive(:update_lifespan_data!).with(simulation, yearly_lifespan, lifespan_years, lifespan_months)
          described_class.calculate_and_save_lifespan_data(simulation)
        end
      end
    end

    describe '.calculate_yearly_lifespan' do
      before do
        allow(Date).to receive(:today).and_return(Date.new(2000, 10, 1)) # 2023年10月1日を返す
      end

      context '十分な資産がある場合' do
        let(:total_assets) { 120 } # 120万円
        let(:monthly_expense) { 10 } # 月10万円

        it '1年目と2年目の資産を正しく計算することを確認する' do
          result = described_class.calculate_yearly_lifespan(total_assets, monthly_expense)
          expect(result).to eq({ 2000 => 120,  2001=> 90, 2002=> -30 })
        end
      end

      context '資産がゼロの場合' do
        let(:total_assets) { 0 }
        let(:monthly_expense) { 10 }

        it '計算結果が空であること' do
          result = described_class.calculate_yearly_lifespan(total_assets, monthly_expense)
          expect(result).to eq({ 2000 => 0,  2001=> -30 })
        end
      end
    end

    describe '.convert_to_years_and_months' do
      it '資産寿命が1年以上となる計算が正しくできる' do
        total_assets = 130
        monthly_expense = 10

        expected_result = [ 1, 1 ] # 130万円 / 10万円 = 1年1ヶ月
        result = described_class.convert_to_years_and_months(total_assets, monthly_expense)

        expect(result).to eq(expected_result)
      end

      it '資産寿命が1年以下となる計算が正しくできる' do
        total_assets = 120
        monthly_expense = 20

        expected_result = [ 0, 6 ]  # 120万円 / 20万円 = 0年6ヶ月
        result = described_class.convert_to_years_and_months(total_assets, monthly_expense)

        expect(result).to eq(expected_result)
      end

      it '小数点以下を切り捨て正しく計算ができる' do
        total_assets = 100
        monthly_expense = 30

        expected_result = [ 0, 3 ]  # 100万円 / 30万円 = 0年3ヶ月(3.333の小数点以下切り捨て)
        result = described_class.convert_to_years_and_months(total_assets, monthly_expense)

        expect(result).to eq(expected_result)
      end

      it '月間支出が0の場合にエラーを発生させる' do
        total_assets = 100
        monthly_expense = 0

        expect { described_class.convert_to_years_and_months(total_assets, monthly_expense) }.to raise_error(ZeroDivisionError)
      end
    end
  end

  describe 'インスタンスメソッドテスト' do
    let(:life_event_data) { { "date" => 2003, "amount" => -100 } }

    before do
      allow(simulation).to receive(:income_data).and_return(
        [ { "date" => 2001, "amount" => 500 }, { "date" => 2002, "amount" => 600 } ]
      )
      allow(simulation).to receive(:expense_data).and_return(
        [ { "date" => 2001, "amount" => -200 }, { "date" => 2002, "amount" => -250 } ]
      )
    end

    describe 'シミュレーションデータ更新処理' do
      before do
        allow(Income).to receive(:generate_income_data_for).with(user).and_return(
          [ { "date" => 2001, "amount" => 500 }, { "date" => 2002, "amount" => 600 } ]
        )
        allow(Expense).to receive(:generate_expense_data_for).with(user).and_return(
          [ { "date" => 2001, "amount" => -200 }, { "date" => 2002, "amount" => -250 } ]
        )
        allow(UserAsset).to receive(:generate_user_asset_data_for).with(user).and_return({ "date"=>2000, "amount"=>500 })
        allow(LifeEvent).to receive(:generate_life_event_data_for).with(user).and_return({
          real_event_data: { "date"=>2010, "amount"=>100 }, ideal_event_data: { "date"=>2020, "amount"=>200 }
        })
      end

      it '#update_income_data!' do
        simulation.update_income_data!(user)
        expect(simulation.income_data).to eq([ { "date" => 2001, "amount" => 500 }, { "date" => 2002, "amount" => 600 } ])
      end

      it '#update_expense_data!' do
        simulation.update_expense_data!(user)
        expect(simulation.expense_data).to eq([ { "date" => 2001, "amount" => -200 }, { "date" => 2002, "amount" => -250 } ])
      end

      it '#update_user_asset_data!' do
        simulation.update_user_asset_data!(user)
        expect(simulation.user_asset_data).to eq({ "date"=>2000, "amount"=>500 })
      end

      it '#update_life_event_data!' do
        simulation.update_life_event_data!(user)
        expect(simulation.real_life_event_data).to eq({ "date"=>2010, "amount"=>100 })
        expect(simulation.ideal_life_event_data).to eq({ "date"=>2020, "amount"=>200 })
      end
    end

    describe '#merged_income_expense_event' do
      it '収入・支出・ライフイベントを統合し、前年の収支を繰り越す' do
        allow(simulation).to receive(:merge_data).with(
          simulation.income_data, simulation.expense_data, life_event_data
        ).and_return([
          { "date" => 2001, "amount" => 300 }, # 500 - 200
          { "date" => 2002, "amount" => 350 }, # 600 - 250
          { "date" => 2003, "amount" => -100 } # life_event_data
        ])

        result = simulation.merged_income_expense_event(life_event_data)

        expect(result).to eq([
          { "date" => 2001, "amount" => 300 },
          { "date" => 2002, "amount" => 650 }, # 350 + 300 (前年の収支)
          { "date" => 2003, "amount" => 550 }  # -100 + 650
        ])
      end
    end

    describe '#get_total_income' do
      it '収入データを正しく計算する' do
        result = simulation.get_total_income
        expect(result).to eq(1100) # 500 + 600
      end
    end

    describe '#get_total_expense' do
      it '支出データを正しく合計する' do
        datasets = [ simulation.expense_data, life_event_data ]
        allow(simulation).to receive(:merge_data).with(*datasets).and_return([
          { "date" => 2001, "amount" => -100 },
          { "date" => 2002, "amount" => -200 },
          { "date" => 2003, "amount" => -300 }
        ])

        result = simulation.get_total_expense(*datasets)
        expect(result).to eq(-600) # -100 + -200 + -300
      end
    end

    describe '#get_monthly_expense' do
      it '正しい月間支出を計算する' do
        create(:expense, user: user, simulation: simulation, housing_expense: 10, living_expenses: 20, monthly_premiums: 30, other_expenses: 40)

        expect(simulation.get_monthly_expense).to eq(10 + 20 + 30 + 40)
      end
    end

    describe '#calculate_shortage' do
      it '年間不足額を正しく計算する' do
        allow(user).to receive(:calculate_user_age).and_return(30)  # ユーザー年齢を30歳に設定

        # (70 - 30 = 40年)
        expect(simulation.calculate_shortage(100)).to eq((100 / 40.0).round(2))  # 正の値
        expect(simulation.calculate_shortage(-100)).to eq((100 / 40.0).round(2))  # 負の値(絶対値を取る)
        expect(simulation.calculate_shortage(0)).to eq(0) # 0ならそのまま
      end
    end

    describe '#merge_data' do
      # simulation.rbで使用しているdatasetの中身は、すべてハッシュ配列。

      it '異なるデータセットを統合し、同じdateのamountを合計する' do
        dataset1 = [ { "date" => 2000, "amount" => 100 }, { "date" => 2001, "amount" => 200 } ]
        dataset2 = [ { "date" => 2000, "amount" => 50 }, { "date" => 2002, "amount" => 300 } ]
        dataset3 = [ { "date" => 2001, "amount" => 100 }, { "date" => 2002, "amount" => 150 } ]

        result = simulation.merge_data(dataset1, dataset2, dataset3)
        expect(result).to eq([
          { "date" => 2000, "amount" => 150 }, # 100 + 50
          { "date" => 2001, "amount" => 300 }, # 200 + 100
          { "date" => 2002, "amount" => 450 }  # 300 + 150
        ])
      end

      it 'nilのデータセットを受け取っても処理できる' do
        dataset1 = [ { "date" => 2000, "amount" => 100 } ]
        dataset2 = nil
        dataset3 = [ { "date" => 2000, "amount" => 50 } ]

        result = simulation.merge_data(dataset1, dataset2, dataset3)
        expect(result).to eq([
          { "date" => 2000, "amount" => 150 } # 100 + 50
        ])
      end

      it '空のデータセットを受け取った場合、空の配列を返す' do
        result = simulation.merge_data([], [], [])
        expect(result).to eq([])
      end

      it '単一のデータセットでも正しく処理できる' do
        dataset1 = [ { "date" => 2000, "amount" => 100 }, { "date" => 2001, "amount" => 200 }, { "date" => 2001, "amount" => 200 } ]

        result = simulation.merge_data(dataset1)
        expect(result).to eq([
          { "date" => 2000, "amount" => 100 },
          { "date" => 2001, "amount" => 400 }
        ])
      end
    end

    describe '#merged_income_expense_event' do
      it '収入・支出・ライフイベントを統合し、前年の収支を繰り越す' do
        allow(simulation).to receive(:merge_data).with(
          simulation.income_data, simulation.expense_data, life_event_data
        ).and_return([
          { "date" => 2001, "amount" => 300 }, # 500 - 200
          { "date" => 2002, "amount" => 350 }, # 600 - 250
          { "date" => 2003, "amount" => -100 } # life_event_data
        ])

        result = simulation.merged_income_expense_event(life_event_data)

        expect(result).to eq([
          { "date" => 2001, "amount" => 300 },
          { "date" => 2002, "amount" => 650 }, # 350 + 300 (前年の収支)
          { "date" => 2003, "amount" => 550 }  # -100 + 650
        ])
      end
    end

    describe '#get_total_income' do
      it '収入データを正しく計算する' do
        result = simulation.get_total_income
        expect(result).to eq(1100) # 500 + 600
      end
    end

    describe '#get_total_expense' do
      it '支出データを正しく合計する' do
        datasets = [ simulation.expense_data, life_event_data ]
        allow(simulation).to receive(:merge_data).with(*datasets).and_return([
          { "date" => 2001, "amount" => -100 },
          { "date" => 2002, "amount" => -200 },
          { "date" => 2003, "amount" => -300 }
        ])

        result = simulation.get_total_expense(*datasets)
        expect(result).to eq(-600) # -100 + -200 + -300
      end
    end
  end
end
