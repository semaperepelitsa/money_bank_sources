module MoneyBankSources
  class Railtie < Rails::Railtie
    rake_tasks do
      load "money_bank_sources/tasks/az_central_bank.rake"
    end
  end
end
