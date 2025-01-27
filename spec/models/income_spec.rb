require 'rails_helper'

RSpec.describe Income, type: :model do
  describe 'アソシエーションのテスト' do
    it { should belong_to(:user) }
    it { should belong_to(:simulation) }
  end

  describe 'enumのテスト' do
    it do
      expect(described_class.person_types).to eq({ "本人" => "本人", "配偶者" => "配偶者" })
    end
  end

  describe 'バリデーションのテスト' do
    it { should validate_presence_of(:person_type) }
    it { should validate_presence_of(:income) }
    it { should validate_numericality_of(:income).is_greater_than_or_equal_to(0) }
    it { should validate_presence_of(:retirement_date) }
    it { should validate_presence_of(:retirement_pay) }
    it { should validate_numericality_of(:retirement_pay).is_greater_than_or_equal_to(0) }
  end

  describe 'カスタムセッターのテスト' do
    describe '#retirement_date=' do
      it '入力された退職日の値を年始の日付として設定すること' do
        income = build(:income, retirement_date: "2030")
        expect(income.retirement_date).to eq(Date.new(2030, 1, 1))
      end
    end
  end

  describe 'パブリックメソッドのテスト' do
    describe '#calculate_income_until_retirement' do
      it '現在〜退職まで年毎に年収のハッシュ配列を作成すること' do
        income = build(:income, retirement_date: 2030)
        result = income.calculate_income_until_retirement

        expect(result).to include(
          {:amount => 12, :date => 2025}, {:amount => 12, :date => 2026}, {:amount => 12, :date => 2027},
          {:amount => 12, :date => 2028}, {:amount => 12, :date => 2029}, {:amount => 13, :date => 2030}
        )
        expect(result).to include({ date: Date.current.year, amount: 12 })
        expect(result.length).to eq(2030 - Date.current.year + 1)
      end
    end

    describe '.grouped_income_data_for' do
      let(:user) { create(:user) }
      let(:simulation) { create(:simulation, user: user) }

      it '指定されたユーザーの全収入データを1つのハッシュ配列に整形すること' do
        create(:income, user: user, simulation: simulation, income: 1, retirement_date: 2030, retirement_pay: 1)
        create(:income, user: user, simulation: simulation, income: 1, retirement_date: 2030, retirement_pay: 1)

        result = Income.grouped_income_data_for(user)

        expect(result).to include(
          {:amount=>24, :date=>2025}, {:amount=>24, :date=>2026}, {:amount=>24, :date=>2027},
          {:amount=>24, :date=>2028}, {:amount=>24, :date=>2029}, {:amount=>26, :date=>2030}
        )
        expect(result).to include({ date: Date.current.year, amount: 24 })
        expect(result).to include({ date: 2030, amount: 26 })
      end
    end
  end

  describe 'プライベートメソッドのテスト' do
    describe '#calculate_yearly_income, #calculate_total_amount' do
      it '退職年の年収は退職金を含むこと' do
        income = build(:income, income: 1, retirement_date: 2030, retirement_pay: 1)
        result = income.send(:calculate_yearly_income, 2030)
        expect(result).to eq({ date: 2030, amount: 13 })
      end

      it '退職年以外の年収は退職金を含まないこと' do
        income = build(:income, income: 1, retirement_date: 2030, retirement_pay: 1)
        result = income.send(:calculate_yearly_income, 2025)
        expect(result).to eq({ date: 2025, amount: 12 })
      end
    end

    describe '.format_income_data' do
      it '# 年毎に収入を合計して整形すること' do
        grouped_data = {
          2025 => [{ date: 2025, amount: 5 }], 2030 => [{ date: 2030, amount: 1 }, { date: 2030, amount: 2 }]
        }

        result = Income.send(:format_income_data, grouped_data)

        expect(result).to include({ date: 2025, amount: 5 }, { date: 2030, amount: 3 })
      end
    end
  end
end
