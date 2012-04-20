namespace :bank_sources do
  namespace :az_central_bank do
    task :fetch => :environment do
      require "money/bank_sources/az_central_bank"
      Money::BankSources::AzCentralBank.new(:date => Time.zone.today).parse.store!
    end
  end
end
