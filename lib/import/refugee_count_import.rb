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
      "China",
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
      origin_country = data[0][0]

      headers = data[1]
      rows = data[2,200]

      rows.each do |row|
        name = row[0]
        totals = row[1,13]

        totals.each do |total|
          if total && total != "*" && name != "Various"

            if unhcr_names.include? origin_country
              origin_country = topojson_names[unhcr_names.index(origin_country)]
            end

            count = RefugeeCount.create!(total: total, year: headers[row.index(total)].to_i)
            origin = Country.find_by(name: origin_country)

            if origin
              count.origin = origin
            else
              count.origin = UNHCRData.create_country(origin_country)
            end

            if unhcr_names.include? name
              name = topojson_names[unhcr_names.index(name)]
            end

            destination = Country.find_by(name: name)
            if destination
              count.destination = destination
            else
              count.destination = UNHCRData.create_country(name)
            end

            count.save!
          end
        end

      end
    end

  end

end