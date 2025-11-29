module DataGenerator
  class LifeEventDataGenerator
    # コンストラクタでuser受け取り
    def initialize(user)
      @user = user
    end

    # life_event_dataの生成 -> Hash of Arrays
    def call
      life_events = @user.life_events
      real_events = life_events.where(event_type: 0)
      ideal_events = life_events.where(event_type: 1)

      real_event_data = get_yearly_totals(real_events)
      ideal_event_data = nil
      if ideal_events.present?
        # ActiveRecord::Relation#+ は使えないため、.to_a
        ideal_event_data = get_yearly_totals(real_events.to_a + ideal_events.to_a)
      end

      {
        real_event_data: real_event_data,
        ideal_event_data: ideal_event_data
      }
    end

    private

    def get_yearly_totals(events)
      yearly_totals = Hash.new(0)
      events.each do |event|
        (0...event.payment_period).each do |i|
          year = event.event_date.year + i
          yearly_totals[year] += -event.amount
        end
      end
      FormatService.format(yearly_totals)
    end
  end
end
