require 'rails_helper'

RSpec.describe Expense, type: :model do
  let(:user) { create(:user) }
  let(:simulation) { create(:simulation, user: user) }
  let(:expense) { build(:expense, user: user, simulation: simulation) }

  describe 'アソシエーションテスト' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:simulation) }
  end

  describe '定数テスト' do
    it 'AGE_LIMITは70である' do
      expect(described_class::AGE_LIMIT).to eq(70)
    end

    it 'MONTHS_IN_A_YEARは12である' do
      expect(described_class::MONTHS_IN_A_YEAR).to eq(12)
    end
  end

  describe 'バリデーションテスト' do
    context '必須項目の確認' do
      it 'user_idは必須' do
        expense.user_id = nil
        expect(expense).not_to be_valid
      end

      it 'simulation_idは必須' do
        expense.simulation_id = nil
        expect(expense).not_to be_valid
      end

      it '住居費は必須' do
        expense.housing_expenses = nil
        expect(expense).not_to be_valid
        expect(expense.errors[:housing_expenses]).to include("住居費を入力してください。")
      end

      it '生活費は必須' do
        expense.living_expenses = nil
        expect(expense).not_to be_valid
        expect(expense.errors[:living_expenses]).to include("生活費を入力してください。")
      end

      it '保険費は必須' do
        expense.monthly_premiums = nil
        expect(expense).not_to be_valid
        expect(expense.errors[:monthly_premiums]).to include("保険費を入力してください。")
      end

      it 'その他費用は必須' do
        expense.other_expenses = nil
        expect(expense).not_to be_valid
        expect(expense.errors[:other_expenses]).to include("その他費用を入力してください。")
      end
    end

    context 'プラス値入力の確認' do
      it '住居費は0以上' do
        expense.housing_expenses = -1
        expect(expense).not_to be_valid
        expect(expense.errors[:housing_expenses]).to include("住居費はプラス値で入力してください。")
      end

      it '住居費は0以上' do
        expense.living_expenses = -1
        expect(expense).not_to be_valid
        expect(expense.errors[:living_expenses]).to include("生活費はプラス値で入力してください。")
      end

      it '保険費は0以上' do
        expense.monthly_premiums = -1
        expect(expense).not_to be_valid
        expect(expense.errors[:monthly_premiums]).to include("保険費はプラス値で入力してください。")
      end

      it '保険費は0以上' do
        expense.other_expenses = -1
        expect(expense).not_to be_valid
        expect(expense.errors[:other_expenses]).to include("その他費用はプラス値で入力してください。")
      end
    end

    context '数値入力の確認' do
      it "住居費が文字列の場合、無効" do
        expense.housing_expenses = "abc"
        expect(expense).not_to be_valid
        expect(expense.errors[:housing_expenses]).to include("数値を入力してください。")
      end

      it "生活費が文字列の場合、無効" do
        expense.living_expenses = "abc"
        expect(expense).not_to be_valid
        expect(expense.errors[:living_expenses]).to include("数値を入力してください。")
      end

      it "保険費が文字列の場合、無効" do
        expense.monthly_premiums = "abc"
        expect(expense).not_to be_valid
        expect(expense.errors[:monthly_premiums]).to include("数値を入力してください。")
      end

      it "その他費用が文字列の場合、無効" do
        expense.other_expenses = "abc"
        expect(expense).not_to be_valid
        expect(expense.errors[:other_expenses]).to include("数値を入力してください。")
      end
    end
  end

  describe 'カスタムセッターテスト' do
    describe '#repayment_date=' do
      it '入力されたローン完済年を年始の日付に変換する' do
        expense.repayment_date = '2030'
        expect(expense.repayment_date).to eq(Date.new(2030, 1, 1))
      end

      it '入力がnilの場合nilを返す' do
        expense.repayment_date = nil
        expect(expense.repayment_date).to be_nil
      end
    end
  end

  describe 'クラスメソッドテスト' do
    let!(:expense) { create(:expense, user: user, simulation: simulation) }

    describe '.generate_expense_data_for' do
      it 'シミュレーションデータを作成する' do
        current_year = Date.current.year
        year_after_repayment_date = current_year + 11
        year_user_age_seventy = current_year + 30

        result = described_class.generate_expense_data_for(user)

        expect(result).to be_an(Array)
        expect(result.first).to include({ date: current_year, amount: -48 })
        expect(result).to include({ date: year_after_repayment_date, amount: -36 })
        expect(result.last).to include({ date: year_user_age_seventy, amount: -36 })
        expect(result.length).to eq(31)
      end
    end
  end

  describe 'インスタンスメソッドテスト' do
    describe '#calculate_yearly_expenses' do
      let(:model) { described_class.new }
      let(:current_year) { 2025 }
      let(:year_age_seventy) { 2027 }

      # モック化
      before do
        allow(model).to receive(:calculate_yearly_expense_for_year).with(2025).and_return(100)
        allow(model).to receive(:calculate_yearly_expense_for_year).with(2026).and_return(200)
        allow(model).to receive(:calculate_yearly_expense_for_year).with(2027).and_return(300)
      end

      it '各年のデータを含むハッシュの配列を返す' do
        result = model.calculate_yearly_expenses(current_year, year_age_seventy)

        expect(result).to eq([
          { date: 2025, amount: 100 }, { date: 2026, amount: 200 }, { date: 2027, amount: 300 }
        ])
      end
    end

    describe '#calculate_yearly_expense_for_year' do
      it '退職までの年次支出合計を返す（退職年を含む）' do
        current_year = Date.today.year
        expect(expense.calculate_yearly_expense_for_year(current_year)).to eq(-expense.total_monthly_expense * 12)
      end

      it '退職後の年次支出合計を返す（退職年を含まない）' do
        future_year = expense.repayment_date.year + 1
        expect(expense.calculate_yearly_expense_for_year(future_year)).to eq(-expense.reduced_monthly_expense * 12)
      end
    end

    it '#total_monthly_expense: 住居費を含む月次支出合計を計算する' do
      expect(expense.total_monthly_expense).to eq(4)
    end

    it '#reduced_monthly_expense: 住居費を除く月次支出合計を計算する' do
      expect(expense.reduced_monthly_expense).to eq(3)
    end
  end
end
