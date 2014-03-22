require 'csv'

class UNHCRData
  # @@country_codes = self.build_codes_hash

  def self.build_codes_hash
    file = File.open("#{Rails.root}/data/country_codes.text")
    codes = {}

    file.each do |line|
      val = line.chomp
      codes[val[0,3]] = val[4,180]
    end

    return codes
    binding.pry
  end

  def self.create_country(name)
    code = UNHCRData.build_codes_hash.key(name)
    new_country = Country.create!(name: name, code: code)

    return new_country
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
              count.origin_id = origin.id
            else
              count.origin_id = UNHCRData.create_country(origin_country).id
            end

            destination = Country.find_by(name: row[0])
            if destination
              count.destination_id = destination.id
            else
              count.destination_id = UNHCRData.create_country(name).id
            end

            count.save!
          end
        end

      end
    end

  end

end