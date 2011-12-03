namespace :bank_sources do
  namespace :cbar_az do
    task :fetch => :environment do
      Money::BankSources::CbarAz.new(:date => Time.zone.today).parse.store!
    end
  end
end
