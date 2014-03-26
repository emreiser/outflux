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
    to_alias = [
      "Congo, the Democratic Republic of the",
      "Syrian Arab Republic",
    ]

    new_alias = [
      "DRC",
      "Syria"
    ]

    code = UNHCRData.build_codes_hash.key(name)
    country = Country.create!(name: name, code: code)

    if to_alias.include? name
      country.alias = new_alias[to_alias.index(name)]
      country.save!
    end

    return country

  end

  def self.import_refugee_counts
    unhcr_names = [
      "United States of America",
      "Bolivia (Plurinational State of)",
      "Hong Kong SAR, China",
      "Iran (Islamic Republic of)",
      "Libyan Arab Jamahiriya",
      "Republic of Korea",
      "Republic of Moldova",
      "Serbia and Montenegro",
      "The former Yugoslav Republic of Macedonia",
      "United Kingdom of Great Britain and Northern Ireland",
      "Venezuela (Bolivarian Republic of)",
      "Democratic Republic of the Congo",
      "United Republic of Tanzania",
      "Macao SAR, China",
      "Serbia (and Kosovo: S/RES/1244 (1999))",
      "Micronesia (Federated States of)",
      "Palestinian"
    ]

    topojson_names = [
      "United States",
      "Bolivia, Plurinational State of",
      "Hong Kong",
      "Iran, Islamic Republic of",
      "Libya",
      "Korea, Republic of",
      "Moldova, Republic of",
      "Serbia",
      "Macedonia, the former Yugoslav Republic of",
      "United Kingdom",
      "Venezuela, Bolivarian Republic of",
      "Congo, the Democratic Republic of the",
      "Tanzania, United Republic of",
      "Macao",
      "Serbia",
      "Micronesia, Federated States of",
      "Palestine, State of"
    ]

    # Get all country file names
    dir = "#{Rails.root}/data/refugees"
    country_files = Dir.new(dir).entries
    country_files.delete('.')
    country_files.delete('..')

    # Import data from csv files
    country_files.each do |f|
      data = CSV.read("#{dir}/#{f}")

      origin_name = data[0][0]
      if unhcr_names.include? origin_name
        origin_name = topojson_names[unhcr_names.index(origin_name)]
      end

      origin = Country.find_by(name: origin_name)
      if !origin
        origin = UNHCRData.create_country(origin_name)
      end

      headers = data[1][1,13]
      rows = data[2,200]

      rows.each do |row|
        dest_name = row[0]
        totals = row[1,13]

        if unhcr_names.include? dest_name
          dest_name = topojson_names[unhcr_names.index(dest_name)]
        end

        destination = Country.find_by(name: dest_name)
        if !destination
          destination = UNHCRData.create_country(dest_name)
        end

        totals.each_with_index do |total, i|
          if total && total != "*"
            # This will be incorrect if total is repeated!!
            count = RefugeeCount.create!(total: total, year: headers[i].to_i)
            count.origin = origin
            count.destination = destination

            count.save!
          end
        end

      end
    end

  end

end