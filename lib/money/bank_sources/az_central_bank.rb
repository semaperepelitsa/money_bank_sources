require "open-uri"
require "rexml/document"

class Money
  module BankSources
    class AzCentralBank
      def initialize(options = {})
        @date = options[:date] || Date.today
        @bank = options[:bank] || Money.default_bank
        @data = options[:data]
      end

      def parse
        xml.elements.each("ValCurs/ValType/Valute") do |currency|
          code = currency.attributes["Code"]
          rate = currency.elements["Value"].text.to_f
          add_rate code, rate
        end
        self
      end

      def url
        @url ||= "https://cbar.az/currencies/#{formatted_date}.xml"
      end

      private

      def add_rate code, rate
        @bank.add_rate(code, :azn, rate)
        @bank.add_rate(:azn, code, 1.0/rate)
      rescue Currency::UnknownCurrency
      end

      def formatted_date
        @formatted_date ||= @date.strftime("%d.%m.%Y")
      end

      def data
        @data ||= open(url).read
      end

      def xml
        @xml ||= REXML::Document.new(data)
      end
    end
  end
end
