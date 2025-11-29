module ApplicationEnums
  PERSON_TYPES = {
    本人: 0,
    配偶者: 1
  }.freeze

  ASSET_TYPES = {
    預金: 0,
    貯蓄型保険: 1,
    投資_NISA: 2,
    投資_iDeCo: 3,
    投資_その他: 4
  }.freeze

  EVENT_TYPES = {
    現実: 0,
    理想: 1
  }.freeze

  SCENARIO_TYPES ={
    現実: 0,
    理想: 1
  }.freeze
end
