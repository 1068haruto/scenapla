require 'rails_helper'

RSpec.describe Income, type: :model do
  describe 'アソシエーションテスト' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:simulation) }
  end

  describe '定数テスト' do
    it 'MONTHS_IN_A_YEARは12である' do
      expect(described_class::MONTHS_IN_A_YEAR).to eq(12)
    end
  end

  describe 'enumテスト' do
    it 'person_typesが正しい値を持つ' do
      expect(described_class.person_types).to eq({ "本人" => 0, "配偶者" => 1 })
    end
  end

  describe 'バリデーションテスト' do
    let(:income) { build(:income) }

    context '必須項目の確認' do
      it 'user_idは必須' do
        income.user_id = nil
        expect(income).not_to be_valid
      end

      it 'simulation_idは必須' do
        income.simulation_id = nil
        expect(income).not_to be_valid
      end

      it '対象は必須' do
        income.person_type = nil
        expect(income).not_to be_valid
        expect(income.errors[:person_type]).to include("対象者を入力してください。")
      end

      it '月収は必須' do
        income.monthly_income = nil
        expect(income).not_to be_valid
        expect(income.errors[:monthly_income]).to include("月収を入力してください。", "数値を入力してください。")
      end

      it '賞与年額は必須' do
        income.yearly_bonus = nil
        expect(income).not_to be_valid
        expect(income.errors[:yearly_bonus]).to include("賞与年額を入力してください。", "数値を入力してください。")
      end

      it '退職時期は必須' do
        income.retirement_date = nil
        expect(income).not_to be_valid
        expect(income.errors[:retirement_date]).to include("退職時期を入力してください。")
      end

      it '退職金は必須' do
        income.retirement_pay = nil
        expect(income).not_to be_valid
        expect(income.errors[:retirement_pay]).to include("退職金を入力してください。", "数値を入力してください。")
      end
    end

    context 'プラス値入力の確認' do
      it '収入が0以上' do
        income.monthly_income = -1
        expect(income).not_to be_valid
        expect(income.errors[:monthly_income]).to include("月収はプラス値で入力してください。")
      end

      it '収入が0以上' do
        income.yearly_bonus = -1
        expect(income).not_to be_valid
        expect(income.errors[:yearly_bonus]).to include("賞与年額はプラス値で入力してください。")
      end

      it '退職金が0以上' do
        income.retirement_pay = -1
        expect(income).not_to be_valid
        expect(income.errors[:retirement_pay]).to include("退職金はプラス値で入力してください。")
      end
    end

    context '数値入力の確認' do
      it "月収が文字列の場合、無効" do
        income.monthly_income = "abc"
        expect(income).not_to be_valid
        expect(income.errors[:monthly_income]).to include("数値を入力してください。")
      end

      it "賞与が文字列の場合、無効" do
        income.yearly_bonus = "abc"
        expect(income).not_to be_valid
        expect(income.errors[:yearly_bonus]).to include("数値を入力してください。")
      end

      it "退職金が文字列の場合、無効" do
        income.retirement_pay = "abc"
        expect(income).not_to be_valid
        expect(income.errors[:retirement_pay]).to include("数値を入力してください。")
      end
    end
  end

  describe 'カスタムセッターテスト' do
    describe '#retirement_date=' do
      it '入力された退職年を年始の日付に変換する' do
        income = build(:income, retirement_date: "2030")
        expect(income.retirement_date).to eq(Date.new(2030, 1, 1))
      end
    end
  end

  describe 'クラスメソッドテスト' do
    describe '.generate_income_data_for' do
      let(:user) { create(:user) }
      let(:simulation) { create(:simulation, user: user) }

      it '指定されたユーザーの全収入データを1つのハッシュ配列に整形すること' do
        create(:income, user: user, simulation: simulation, monthly_income: 1, yearly_bonus: 1, retirement_date: 2030, retirement_pay: 1)
        create(:income, user: user, simulation: simulation, monthly_income: 1, yearly_bonus: 1, retirement_date: 2030, retirement_pay: 1)

        result = Income.generate_income_data_for(user)

        expect(result).to include(
          { amount: 26, date: 2025 }, { amount: 26, date: 2026 }, { amount: 26, date: 2027 },
          { amount: 26, date: 2028 }, { amount: 26, date: 2029 }, { amount: 28, date: 2030 }
        )
        expect(result).to include({ date: Date.current.year, amount: 26 })
        expect(result).to include({ date: 2030, amount: 28 })
      end
    end

    describe '.format_grouped_data' do
      it '# 年毎に収入を合計して整形すること' do
        grouped_data = {
          2025 => [ { date: 2025, amount: 5 } ], 2030 => [ { date: 2030, amount: 1 }, { date: 2030, amount: 2 } ]
        }

        result = Income.send(:format_grouped_data, grouped_data)

        expect(result).to include({ date: 2025, amount: 5 }, { date: 2030, amount: 3 })
      end
    end
  end

  describe 'インスタンスメソッドテスト' do
    describe '#calculate_income_until_retirement' do
      it '現在〜退職まで年毎に年収のハッシュ配列を作成する' do
        income = build(:income, retirement_date: 2030)
        result = income.calculate_income_until_retirement

        expect(result).to include(
          { amount: 12, date: 2025 }, { amount: 12, date: 2026 }, { amount: 12, date: 2027 },
          { amount: 12, date: 2028 }, { amount: 12, date: 2029 }, { amount: 13, date: 2030 }
        )
        expect(result).to include({ date: Date.current.year, amount: 12 })
        expect(result.length).to eq(2030 - Date.current.year + 1)
      end
    end

    describe '#calculate_income_for_year, #calculate_adjusted_income_for_year' do
      it '退職年の年収は退職金を含むこと' do
        income = build(:income, monthly_income: 1, retirement_date: 2030, retirement_pay: 1)
        result = income.send(:calculate_income_for_year, 2030)
        expect(result).to eq({ date: 2030, amount: 13 })
      end

      it '退職年以外の年収は退職金を含まないこと' do
        income = build(:income, monthly_income: 1, retirement_date: 2030, retirement_pay: 1)
        result = income.send(:calculate_income_for_year, 2025)
        expect(result).to eq({ date: 2025, amount: 12 })
      end
    end
  end
end
