require 'rails_helper'

RSpec.describe AgeCalculatable, type: :model do
  let(:user) { build(:user, date_of_birth: date_of_birth) }

  describe "#get_user_age" do
    subject { user.get_user_age }
    let(:today) { Date.new(2020, 10, 10) }

    before do
      allow(Date).to receive(:today).and_return(today)
    end

    context "誕生日をすでに迎えている場合" do
      let(:date_of_birth) { Date.new(1990, 10, 9) }
      it "正しい年齢を返す" do
        expect(subject).to eq(30)
      end
    end

    context "誕生日が今日の場合" do
      let(:date_of_birth) { Date.new(1990, 10, 10) }
      it "正しい年齢を返す" do
        expect(subject).to eq(30)
      end
    end

    context "誕生日をまだ迎えていない場合" do
      let(:date_of_birth) { Date.new(1990, 10, 11) }
      it "正しい年齢を返す" do
        expect(subject).to eq(29)
      end
    end
  end

  describe "#get_year_at_seventy" do
    subject { user.get_year_at_seventy }
    let(:date_of_birth) { Date.new(1990, 1, 1) }

    it "生年 + 70 の西暦を返す" do
      expect(subject).to eq(1990 + Constants::AGE_LIMIT)
    end
  end
end
