require 'rails_helper'

RSpec.describe Income, type: :model do
  describe 'relation' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:simulation) }
  end

  describe 'constant' do
    it 'MONTHS_IN_A_YEARは「12」' do
      expect(described_class::MONTHS_IN_A_YEAR).to eq(12)
    end

    it 'JANUARYは「1」' do
      expect(described_class::JANUARY).to eq(1)
    end

    it 'FIRSTは「1」' do
      expect(described_class::FIRST).to eq(1)
    end
  end

  describe 'enum' do
    it 'person_typesが正しい値を持つ' do
      expect(described_class.person_types).to eq({ "本人" => 0, "配偶者" => 1 })
    end
  end

  describe 'validation' do
    let(:income) { build(:income) }

    context '必須項目' do
      it 'user_idなしは、無効' do
        income.user_id = nil
        expect(income).not_to be_valid
      end

      it 'simulation_idなしは、無効' do
        income.simulation_id = nil
        expect(income).not_to be_valid
      end

      it '対象者なしは、無効' do
        income.person_type = nil
        expect(income).not_to be_valid
        expect(income.errors[:person_type]).to include("対象者を入力してください。")
      end

      it '月収なしは、無効' do
        income.monthly_income = nil
        expect(income).not_to be_valid
        expect(income.errors[:monthly_income]).to include("月収を入力してください。", "数値を入力してください。")
      end

      it '賞与年額なしは、無効' do
        income.yearly_bonus = nil
        expect(income).not_to be_valid
        expect(income.errors[:yearly_bonus]).to include("賞与年額を入力してください。", "数値を入力してください。")
      end

      it '退職時期なしは、無効' do
        income.retirement_date = nil
        expect(income).not_to be_valid
        expect(income.errors[:retirement_date]).to include("退職時期を入力してください。")
      end

      it '退職金なしは、無効' do
        income.retirement_pay = nil
        expect(income).not_to be_valid
        expect(income.errors[:retirement_pay]).to include("退職金を入力してください。", "数値を入力してください。")
      end
    end

    context 'プラス値項目' do
      it '収入がマイナスなら無効' do
        income.monthly_income = -1
        expect(income).not_to be_valid
        expect(income.errors[:monthly_income]).to include("月収はプラス値で入力してください。")
      end

      it '賞与がマイナスなら無効' do
        income.yearly_bonus = -1
        expect(income).not_to be_valid
        expect(income.errors[:yearly_bonus]).to include("賞与年額はプラス値で入力してください。")
      end

      it '退職金がマイナスなら無効' do
        income.retirement_pay = -1
        expect(income).not_to be_valid
        expect(income.errors[:retirement_pay]).to include("退職金はプラス値で入力してください。")
      end
    end

    context '数値項目' do
      it "月収がInt以外なら無効" do
        income.monthly_income = "abc"
        expect(income).not_to be_valid
        expect(income.errors[:monthly_income]).to include("数値を入力してください。")
      end

      it "賞与年額がInt以外なら無効" do
        income.yearly_bonus = "abc"
        expect(income).not_to be_valid
        expect(income.errors[:yearly_bonus]).to include("数値を入力してください。")
      end

      it "退職金がInt以外なら無効" do
        income.retirement_pay = "abc"
        expect(income).not_to be_valid
        expect(income.errors[:retirement_pay]).to include("数値を入力してください。")
      end
    end
  end

  describe 'メソッド' do
    let(:user) { create(:user) }
    let(:simulation) { create(:simulation, user: user) }
    year = Date.current.year

    describe '.generate_income_data' do
      it '全収入データを1つのオブジェクト配列にする' do
        create(:income, user: user, simulation: simulation)
        create(:income, user: user, simulation: simulation)
        result = Income.generate_income_data(user)

        expect(result).to include(
          { amount: 26, date: year },
          { amount: 26, date: year + 1 },
          { amount: 26, date: year + 2 },
          { amount: 26, date: year + 3 },
          { amount: 26, date: year + 4 },
          { amount: 28, date: year + 5 }
        )
        expect(result).to include({ date: year, amount: 26 })
        expect(result).to include({ date: year + 5, amount: 28 })
        expect(result.length).to eq(6)
      end
    end

    describe '#calculate_until_retirement' do
      it '現在〜退職までの年収を計算し、オブジェクト配列とする' do
        income = build(:income)
        result = income.calculate_until_retirement

        expect(result).to include(
          { amount: 13, date: year },
          { amount: 13, date: year + 1 },
          { amount: 13, date: year + 2 },
          { amount: 13, date: year + 3 },
          { amount: 13, date: year + 4 },
          { amount: 14, date: year + 5 }
        )
        expect(result.length).to eq(6)
      end
    end

    describe '.grouped' do
      it '同じ年の複数の収入を合計する' do
        allIncomeData = [
          { date: year, amount: 5 },
          { date: year + 5, amount: 1 },
          { date: year + 5, amount: 2 }
        ]
        result = Income.send(:grouped, allIncomeData)

        expect(result).to include(
          { date: year, amount: 5 },
          { date: year + 5, amount: 3 }
        )
      end
    end

    describe '#retirement_date=' do
      it '退職年をDate型の年始に設定する' do
        income = build(:income, retirement_date: "2030")
        expect(income.retirement_date).to eq(Date.new(2030, 1, 1))
      end
    end
  end
end
