require 'rails_helper'

RSpec.describe ApplicationEnums, type: :module do
  describe 'PERSON_TYPES' do
    let(:person_types) { ApplicationEnums::PERSON_TYPES }

    it 'は正しいキーと値を保持している' do
      expect(person_types).to eq({ 本人: 0, 配偶者: 1 })
    end

    it 'はフリーズされている' do
      expect(person_types).to be_frozen
    end
  end

  describe 'ASSET_TYPES' do
    let(:asset_types) { ApplicationEnums::ASSET_TYPES }

    it 'は正しいキーと値を保持している' do
      expected_keys_and_values = {
        預金: 0,
        貯蓄型保険: 1,
        投資_NISA: 2,
        投資_iDeCo: 3,
        投資_その他: 4
      }
      expect(asset_types).to eq(expected_keys_and_values)
    end

    it 'はフリーズされている' do
      expect(asset_types).to be_frozen
    end
  end

  describe 'EVENT_TYPES' do
    let(:event_types) { ApplicationEnums::EVENT_TYPES }

    it 'は正しいキーと値を保持している' do
      expect(event_types).to eq({ 現実: 0, 理想: 1 })
    end

    it 'はフリーズされている' do
      expect(event_types).to be_frozen
    end
  end

  describe 'SCENARIO_TYPES' do
    let(:scenario_types) { ApplicationEnums::SCENARIO_TYPES }

    it 'は正しいキーと値を保持している' do
      expect(scenario_types).to eq({ 現実: 0, 理想: 1 })
    end

    it 'はフリーズされている' do
      expect(scenario_types).to be_frozen
    end
  end
end
