require_relative '../import/refugee_count_import.rb'

namespace :import do

  desc "Import refugee counts for countries"
  task refugee_counts: :environment do
    UNHCRData.import_refugee_counts
    UNHCRData.assignUrls

  end

  desc "Delete all counts"
  task delete_counts: :environment do
    RefugeeCount.delete_all
  end

  desc "Delete all countries"
  task delete_countries: :environment do
    Country.delete_all
  end

end
