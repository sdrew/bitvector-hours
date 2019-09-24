require "bitvector"
require "bitvector/hours/version"

require "active_support/core_ext/module/delegation"
require "active_support/core_ext/numeric/time"
require "active_support/core_ext/time/calculations"
require "active_support/core_ext/time/zones"

module BitVector
  class Hours
    class Error < StandardError; end

    MINUTES_MAX = 60 * 24

    attr_writer :timezone
    attr_reader :vector

    delegate :size, to: :vector

    def initialize(encoded = '', resolution: 5)
      size = (MINUTES_MAX / resolution.to_f).round
      value = 0

      unless encoded.empty?
        encoded = ::BitVector::Hours.decode(encoded)
        raise(Hours::Error, "Resolution mismatch") if size != encoded.length
        value = encoded.to_i 2
      end

      @vector = BitVector.new value, size
    end

    def active?(bit: nil, hour: nil)
      bit = bit_from_hour(hour) if hour.present?
      bit = self.current_bit if bit.nil?

      vector[bit] == 1
    end

    def clear(range)
      range = array_to_range(range) if range.is_a?(Array)
      range.to_a.each { |bit| vector[bit] = 0 }
    end

    def current_bit
      bit_from_time current_time
    end

    def current_hour
      bit_to_hour current_bit
    end

    def current_time
      Time.use_zone(self.timezone) { Time.current }
    end

    def expand(range)
      range = array_to_range(range) if range.is_a?(Array)
      range.to_a.each { |bit| vector[bit] = 1 }
    end

    def hours
      ranges.map do |range|
        [bit_to_hour(range.begin), bit_to_hour(range.end)]
      end
    end

    def ranges
      vector.to_s.reverse.enum_for(:scan, /([1]+)/).map do
        range = $~.offset 0
        range[0]...range[1]
      end
    end

    def resolution
      MINUTES_MAX / size
    end

    def timezone
      @timezone || Time.zone
    end

    def to_s
      ::BitVector::Hours.encode vector.to_s
    end

    class << self
      def decode(value)
        value.split('-').map do |v|
          v.hex.to_s(2).rjust(32, '0')
        end.join('')
      end

      def encode(vector)
        vector.scan(/\d{32}/).map do |v|
          v.to_i(2).to_s(16).rjust(8, '0')
        end.join('-')
      end
    end

    private
    def array_to_range(arr)
      raise(Hours::Error, "Array length mismatch") if arr.length != 2
      raise(Hours::Error, "Array contents mismatch") if arr.map(&:class).uniq.length != 1

      case
      when arr[0].is_a?(Numeric)
        arr[0].to_i...arr[1].to_i
      when arr[0].is_a?(String)
        raise(Hours::Error, "Array hours format error") unless arr.all? { |x| x.match(/\A\d{1,2}:\d{2}\z/) }
        bit_from_hour(arr[0])...bit_from_hour(arr[1])
      else
        raise(Hours::Error, "Array content types error")
      end
    end

    def bit_from_hour(hour)
      bit_from_minute hour_to_minute(hour)
    end

    def bit_from_minute(minute)
      minute / self.resolution
    end

    def bit_from_time(at)
      bit_from_minute time_to_minute(at)
    end

    def bit_to_minute(bit)
      bit * self.resolution
    end

    def bit_to_hour(bit)
      hour_from_minute bit_to_minute(bit)
    end

    def bit_to_time(bit)
      time_from_bit bit
    end

    def hour_from_minute(minute)
      hour = minute / 60
      minute = minute % 60
      "%02d:%02d" % [hour, minute]
    end

    def hour_to_minute(hour)
      hour, minute = hour.split(':').map(&:to_i)
      (hour * 60) + minute
    end

    def time_from_bit(bit)
      time_from_minute bit_to_minute(bit)
    end

    def time_from_minute(minute)
      at = Time.use_zone(self.timezone) { Time.current.beginning_of_day }

      at + (minute * 60)
    end

    def time_to_minute(at)
      (at.hour * 60) + at.min
    end
  end
end
