require "http"
require "json"
require "dotenv/load"

pp "howdy"

pp "Where are you located?"

user_response = gets.chomp.gsub(" ", "%20")

pp "Checking the weather at " + user_response + "."

gmaps_url = "https://maps.googleapis.com/maps/api/geocode/json?address=" + user_response + "&key=" + ENV.fetch("GMAPS_KEY")

raw_response = HTTP.get(gmaps_url).to_s

parsed_response = JSON.parse(raw_response)
#hoca bu asagidakini tek tek acti
coords = parsed_response.fetch("results").at(0).fetch("geometry").fetch("location")
lat = coords.fetch("lat")
lng = coords.fetch("lng")

pp user_response + " is at " + lat.round(2).to_s + ", " + lng.round(2).to_s + "."

pirate_weather_api_key = ENV.fetch("PIRATE_WEATHER_API_KEY")

pirate_weather_url = "https://api.pirateweather.net/forecast/" + pirate_weather_api_key + "/" + lat.to_s + "," + lng.to_s

raw_response_pirate = HTTP.get(pirate_weather_url)

parsed_response_pirate = JSON.parse(raw_response_pirate)

currently_hash = parsed_response_pirate.fetch("currently")
hourly_hash = parsed_response_pirate.fetch("hourly")
current_temp = currently_hash.fetch("temperature")
hourly_summary = hourly_hash.fetch("data").at(0).fetch("summary")
pp "The current temperature is " + current_temp.to_s + "°F, " + ((current_temp - 32) * 5 / 9).round(2).to_s + "°C."
pp "Weather for the next hour is " + hourly_summary.to_s + "."

hourly_precip = Array.new
0.upto(11) do |hour|
  hourly_precip.push(hourly_hash.fetch("data").at(hour).fetch("precipProbability"))
end

hour = 1
hourly_precip.each do |precip|
  pp "In #{hour} hour(s), there is a #{(precip * 100).to_i}% change of precipitation."
  hour = hour + 1
end

if hourly_precip.max > 0.10
  pp "Would recommend carrying an umbrella!"
end
