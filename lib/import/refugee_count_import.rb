require 'csv'

class UNHCRData

  def self.build_codes_hash
    file = File.read("#{Rails.root}/public/world-topo-min.json")
    countries = JSON.parse(file)["objects"]["countries"]["geometries"]
    codes = {}

    countries.each do |country|
      codes[country["id"].to_s] = country["properties"]["name"]
    end

    return codes
  end

  def self.create_country(name)
    code = UNHCRData.build_codes_hash.key(name)
    Country.create!(name: name, code: code)
  end

  def self.import_refugee_counts
    # Get all country file names
    dir = "#{Rails.root}/data/refugees"
    country_files = Dir.new(dir).entries
    country_files.delete('.')
    country_files.delete('..')

    # Import data from csv files
    country_files.each do |f|
      data = CSV.read("#{dir}/#{f}")
      origin_country = data[0][0]

      headers = data[1]
      rows = data[2,200]

      rows.each do |row|
        name = row[0]
        totals = row[1,13]

        totals.each do |total|
          if total && total != "*" && name != "Various"
            count = RefugeeCount.create!(total: total, year: headers[row.index(total)].to_i)
            origin = Country.find_by(name: origin_country)
            if origin
              count.origin_id = origin
            else
              count.origin_id = UNHCRData.create_country(origin_country)
            end

            destination = Country.find_by(name: row[0])
            if destination
              count.destination_id = destination
            else
              count.destination_id = UNHCRData.create_country(name)
            end

            count.save!
          end
        end

      end
    end

  end

end