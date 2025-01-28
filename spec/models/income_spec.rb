require 'rails_helper'

RSpec.describe Income, type: :model do
  describe 'アソシエーションテスト' do
    it { should belong_to(:user) }
    it { should belong_to(:simulation) }
  end

  describe 'enumテスト' do
    it do
      expect(described_class.person_types).to eq({ "本人" => "本人", "配偶者" => "配偶者" })
    end
  end

  describe 'バリデーションテスト' do
    let(:income) { build(:income) }

    context '必須項目の確認' do
      it '対象が必須であること' do
        income.person_type = nil
        expect(income).not_to be_valid
        expect(income.errors[:person_type]).to include("対象を選択してください。")
      end

      it '月収が必須であること' do
        income.income = nil
        expect(income).not_to be_valid
        expect(income.errors[:income]).to include("月収(手取り)は必須です。", "数値を入力してください。")
      end

      it '退職時期が必須であること' do
        income.retirement_date = nil
        expect(income).not_to be_valid
        expect(income.errors[:retirement_date]).to include("退職時期を入力してください。")
      end

      it '退職金が必須であること' do
        income.retirement_pay = nil
        expect(income).not_to be_valid
        expect(income.errors[:retirement_pay]).to include("退職金(手取り)は必須です。", "数値を入力してください。")
      end
    end

    context 'プラス値入力の確認' do
      it '収入の入力値が0以上であること' do
        income.income = -1
        expect(income).not_to be_valid
        expect(income.errors[:income]).to include("月収(手取り)は、プラス値で入力してください。")
      end

      it '退職金の入力値が0以上であること' do
        income.retirement_pay = -1
        expect(income).not_to be_valid
        expect(income.errors[:retirement_pay]).to include("退職金(手取り)は、プラス値で入力してください。")
      end
    end
  end

  describe 'カスタムセッターテスト' do
    describe '#retirement_date=' do
      it '入力された退職日の値を年始の日付として設定すること' do
        income = build(:income, retirement_date: "2030")
        expect(income.retirement_date).to eq(Date.new(2030, 1, 1))
      end
    end
  end

  describe 'メソッドテスト' do
    describe '#calculate_income_until_retirement' do
      it '現在〜退職まで年毎に年収のハッシュ配列を作成すること' do
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

    describe '.generate_income_data_for' do
      let(:user) { create(:user) }
      let(:simulation) { create(:simulation, user: user) }

      it '指定されたユーザーの全収入データを1つのハッシュ配列に整形すること' do
        create(:income, user: user, simulation: simulation, income: 1, retirement_date: 2030, retirement_pay: 1)
        create(:income, user: user, simulation: simulation, income: 1, retirement_date: 2030, retirement_pay: 1)

        result = Income.generate_income_data_for(user)

        expect(result).to include(
          { amount: 24, date: 2025 }, { amount: 24, date: 2026 }, { amount: 24, date: 2027 },
          { amount: 24, date: 2028 }, { amount: 24, date: 2029 }, { amount: 26, date: 2030 }
        )
        expect(result).to include({ date: Date.current.year, amount: 24 })
        expect(result).to include({ date: 2030, amount: 26 })
      end
    end

    describe '#calculate_income_for_year, #calculate_adjusted_income_for_year' do
      it '退職年の年収は退職金を含むこと' do
        income = build(:income, income: 1, retirement_date: 2030, retirement_pay: 1)
        result = income.send(:calculate_income_for_year, 2030)
        expect(result).to eq({ date: 2030, amount: 13 })
      end

      it '退職年以外の年収は退職金を含まないこと' do
        income = build(:income, income: 1, retirement_date: 2030, retirement_pay: 1)
        result = income.send(:calculate_income_for_year, 2025)
        expect(result).to eq({ date: 2025, amount: 12 })
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
end
