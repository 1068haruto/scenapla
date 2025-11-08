require 'rails_helper'

RSpec.describe Expense, type: :model do
  let(:user) { create(:user) }
  let(:simulation) { create(:simulation, user: user) }
  let(:expense) { build(:expense, user: user, simulation: simulation) }

  describe 'Relation' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:simulation) }
  end

  describe 'Const' do
    it 'AGE_LIMITは「70」' do
      expect(described_class::AGE_LIMIT).to eq(70)
    end

    it 'MONTHS_IN_A_YEARは「12」' do
      expect(described_class::MONTHS_IN_A_YEAR).to eq(12)
    end

    it 'NO_REPAYMENT_YEARは「0」' do
      expect(described_class::NO_REPAYMENT_YEAR).to eq(0)
    end

    it 'JANUARYは「1」' do
      expect(described_class::JANUARY).to eq(1)
    end

    it 'FIRSTは「1」' do
      expect(described_class::FIRST).to eq(1)
    end
  end

  describe 'Validation' do
    context '必須項目' do
      it 'user_idなしは、無効' do
        expense.user_id = nil
        expect(expense).not_to be_valid
      end

      it 'simulation_idなしは、無効' do
        expense.simulation_id = nil
        expect(expense).not_to be_valid
      end

      it '住居費なしは、無効' do
        expense.housing_expenses = nil
        expect(expense).not_to be_valid
        expect(expense.errors[:housing_expenses]).to include("住居費を入力してください。")
      end

      it '生活費なしは、無効' do
        expense.living_expenses = nil
        expect(expense).not_to be_valid
        expect(expense.errors[:living_expenses]).to include("生活費を入力してください。")
      end

      it '保険費なしは、無効' do
        expense.monthly_premiums = nil
        expect(expense).not_to be_valid
        expect(expense.errors[:monthly_premiums]).to include("保険費を入力してください。")
      end

      it 'その他費用なしは、無効' do
        expense.other_expenses = nil
        expect(expense).not_to be_valid
        expect(expense.errors[:other_expenses]).to include("その他費用を入力してください。")
      end
    end

    context 'プラス値項目' do
      it '住居費がマイナスなら無効' do
        expense.housing_expenses = -1
        expect(expense).not_to be_valid
        expect(expense.errors[:housing_expenses]).to include("住居費はプラス値で入力してください。")
      end

      it '住居費がマイナスなら無効' do
        expense.living_expenses = -1
        expect(expense).not_to be_valid
        expect(expense.errors[:living_expenses]).to include("生活費はプラス値で入力してください。")
      end

      it '保険費がマイナスなら無効' do
        expense.monthly_premiums = -1
        expect(expense).not_to be_valid
        expect(expense.errors[:monthly_premiums]).to include("保険費はプラス値で入力してください。")
      end

      it '保険費がマイナスなら無効' do
        expense.other_expenses = -1
        expect(expense).not_to be_valid
        expect(expense.errors[:other_expenses]).to include("その他費用はプラス値で入力してください。")
      end
    end

    context '数値項目' do
      it "住居費がInt以外なら無効" do
        expense.housing_expenses = "abc"
        expect(expense).not_to be_valid
        expect(expense.errors[:housing_expenses]).to include("数値を入力してください。")
      end

      it "生活費がInt以外なら無効" do
        expense.living_expenses = "abc"
        expect(expense).not_to be_valid
        expect(expense.errors[:living_expenses]).to include("数値を入力してください。")
      end

      it "保険費がInt以外なら無効" do
        expense.monthly_premiums = "abc"
        expect(expense).not_to be_valid
        expect(expense.errors[:monthly_premiums]).to include("数値を入力してください。")
      end

      it "その他費用がInt以外なら無効" do
        expense.other_expenses = "abc"
        expect(expense).not_to be_valid
        expect(expense.errors[:other_expenses]).to include("数値を入力してください。")
      end
    end
  end

  describe 'メソッド' do
    describe '.generate_expense_data + .calculate_until_limit' do
      it 'expense_dataを生成する' do
        create(:expense, user: user, simulation: simulation)
        currentYear = Date.today.year
        yearAfterRepayment = currentYear + 4
        yearAtSeventy = currentYear + 10

        result = Expense.generate_expense_data(user)

        expect(result.first).to include({ date: currentYear, amount: -48 })
        expect(result).to include({ date: yearAfterRepayment, amount: -36 })
        expect(result.last).to include({ date: yearAtSeventy, amount: -36 })
        expect(result.length).to eq(11)
      end
    end

    describe '#repayment_date=' do
      it 'ローン完済年をDate型の年始に設定する' do
        expense.repayment_date = '2030'
        expect(expense.repayment_date).to eq(Date.new(2030, 1, 1))
      end

      it '入力がnilの場合、nilを返す' do
        expense.repayment_date = nil
        expect(expense.repayment_date).to be_nil
      end
    end
  end
end
