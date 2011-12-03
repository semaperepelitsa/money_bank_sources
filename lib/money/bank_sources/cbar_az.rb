require "open-uri"
require "rexml/document"

class Money
  module BankSources
    class CbarAz
      CODE_MAP = {
        # RUR is an old roubles code according to ISO 4217
        "RUR" => "RUB"
      }

      attr_reader :rates

      def initialize(options = {})
        @date = options[:date] || Date.today
        @bank = options[:bank] || Money.default_bank
        @only = options[:only] ? Array(options[:only]) : nil
        @data = options[:data]
        @rates = {}
      end

      def parse
        xml.elements.each("ValCurs/ValType/Valute") do |currency|
          code = currency.attributes["Code"]

          code = CODE_MAP.fetch(code, code)
          next if skip_code?(code)

          rate = currency.elements["Value"].text.to_f
          rates[code] = rate
        end
        self
      end

      def store!
        rates.each do |code, rate|
          if Money::Currency.find(code)
            @bank.add_rate(code, :azn, rate)
            @bank.add_rate(:azn, code, 1.0/rate)
          end
        end
        @bank.save! if @bank.respond_to?(:save!)
      end

      def url
        @url ||= "http://cbar.az/currencies/#{formatted_date}.xml"
      end

    private

      def formatted_date
        @formatted_date ||= @date.strftime("%d.%m.%Y")
      end

      def data
        @data ||= open(url).read
      end

      def xml
        @xml ||= REXML::Document.new(data)
      end

      def skip_code?(code)
        @only && !@only.include?(code)
      end
    end
  end
end
