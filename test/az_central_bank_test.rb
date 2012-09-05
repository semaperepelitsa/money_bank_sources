require "bundler/setup"
require 'minitest/autorun'
require 'money'
$:.unshift(File.expand_path('../../lib', __FILE__))
require "money/bank_sources/az_central_bank"

class MoneyBankSourceAzCentralBankTest < MiniTest::Unit::TestCase
  include Money::BankSources, Money::Bank

  def setup
    @bank = VariableExchange.new
  end

  def test_ignores_unknown_currency
    source = AzCentralBank.new :data => fixture(:unknown), :bank => @bank
    refute Money::Currency.find(:sdr)
    source.parse
  end

  def test_adds_rates
    source = AzCentralBank.new :data => fixture(:two), :bank => @bank
    source.parse
    assert_equal 0.0245, @bank.get_rate(:rub, :azn)
    assert_equal 1.2166, @bank.get_rate(:gbp, :azn)
  end

  def test_adds_reverse_rates
    source = AzCentralBank.new :data => fixture(:two), :bank => @bank
    source.parse
    assert_in_delta 40.8163, @bank.get_rate(:azn, :rub)
    assert_in_delta  0.8219, @bank.get_rate(:azn, :gbp)
  end

  def test_url
    date = Date.new(2011, 01, 02)
    source = AzCentralBank.new(:date => date)
    assert_equal "http://cbar.az/currencies/02.01.2011.xml", source.url
  end

  private

  def fixture name
    @data ||= IO.read(File.expand_path("../fixtures/#{name}.xml", __FILE__))
  end
end
