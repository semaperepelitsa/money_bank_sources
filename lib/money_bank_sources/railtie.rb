module MoneyBankSources
  class Railtie < Rails::Railtie
    rake_tasks do
      load "money_bank_sources/tasks/cbar_az.rake"
    end
  end
end
