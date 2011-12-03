require "bundler/setup"
require 'minitest/autorun'
require 'money'
$:.unshift(File.expand_path('../../lib', __FILE__))
require "money/bank_sources/cbar_az"

class MoneyBankSourceCbarAzTest < MiniTest::Unit::TestCase
  include Money::BankSources

  def test_store_adds_direct_and_reverse_rates
    bank = MiniTest::Mock.new

    bank.expect(:add_rate, nil, ["USD", :azn, 2])
    bank.expect(:add_rate, nil, [:azn, "USD", 0.5])
    bank.expect(:add_rate, nil, ["EUR", :azn, 4])
    bank.expect(:add_rate, nil, [:azn, "EUR", 0.25])

    bank.expect(:save!, true)

    source = CbarAz.new(:bank => bank)
    def source.rates
      { "USD" => 2, "EUR" => 4 }
    end

    source.store!
    bank.verify
  end

  def test_store_unknown_currency_silently
    bank = Money::Bank::VariableExchange.new
    source = CbarAz.new(:bank => bank)
    def source.rates
      { "AAA" => 4 }
    end
    source.store!
  end

  def test_url
    date = Date.new(2011, 01, 02)
    source = CbarAz.new(:date => date)
    assert_equal "http://cbar.az/currencies/02.01.2011.xml", source.url
  end

  def test_url_with_default_date
    date = Date.today
    source = CbarAz.new
    assert_equal "http://cbar.az/currencies/#{date.strftime("%d.%m.%Y")}.xml", source.url
  end

  def test_parse
    source = CbarAz.new(:data => data)
    assert_equal source, source.parse
    assert_equal parsed_data, source.rates
  end

  def test_parse_only
    source = CbarAz.new(:only => "USD", :data => data)
    assert_equal({ "USD" => parsed_data["USD"] }, source.parse.rates)
  end

  def test_only_multiple
    source = CbarAz.new(:only => ["USD", "EUR"], :data => data)
    assert_equal({ "USD" => parsed_data["USD"], "EUR" => parsed_data["EUR"] }, source.parse.rates)
  end

private

  def data
    @data ||= IO.read(File.expand_path("../fixtures/cbar_az.xml", __FILE__))
  end

  def parsed_data
    {
      "ZAR"=>0.0963,
      "AED"=>0.2142,
      "IDR"=>0.0087,
      "SDR"=>1.2269,
      "KGS"=>0.0174,
      "CHF"=>0.8639,
      "HKD"=>0.1009,
      "NZD"=>0.6072,
      "INR"=>0.0159,
      "ARS"=>0.1873,
      "LVL"=>1.4877,
      "KWD"=>2.836,
      "EUR"=>1.0553,
      "MXN"=>0.0576,
      "UZS"=>0.0452,
      "GEL"=>0.4735,
      "EGP"=>0.1318,
      "SEK"=>0.1132,
      "CNY"=>0.1232,
      "SAR"=>0.2098,
      "RUB"=>0.0245,
      "LTL"=>0.3081,
      "LBP"=>0.0523,
      "DKK"=>0.1418,
      "KRW"=>0.0664,
      "TMT"=>0.2767,
      "KZT"=>0.0053,
      "BYR"=>0.0142,
      "TRY"=>0.429,
      "SGD"=>0.6037,
      "ILS"=>0.2115,
      "AUD"=>0.7663,
      "BRL"=>0.4292,
      "UAH"=>0.0983,
      "CAD"=>0.7619,
      "USD"=>0.7869,
      "TJS"=>0.1651,
      "PLN"=>0.2409,
      "JPY"=>1.0298,
      "CZK"=>0.0428,
      "IRR"=>0.0073,
      "MDL"=>0.066,
      "NOK"=>0.1342,
      "GBP"=>1.2166,
      "XPD"=>518.5671,
      "XAU"=>1329.0741,
      "XPT"=>1299.1719,
      "XAG"=>25.889
    }
  end
end
