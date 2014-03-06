require 'net/http'
require 'json'
require 'digest/md5'

time = Time.now.to_i 
config = JSON.parse(File.read('config.json'))

allResults = Array.new

url = URI('http://gateway.marvel.com/v1/public/characters/' + config['superheroID'] + '/series')
params = {
  :ts => time,
  :apikey => config['marvelPublicAPIKey'],
  :hash => Digest::MD5.hexdigest(time.to_s + config['marvelPrivateAPIKey'] + config['marvelPublicAPIKey']),
  :limit => '100',
  :orderBy => 'startYear'
}
url.query = URI.encode_www_form(params)

resp = Net::HTTP.get_response(url)
jsonResp = JSON.parse(resp.body)
allResults = jsonResp['data']['results']
seriesCount = jsonResp['data']['total']

if seriesCount != 100
	loopCount = ((seriesCount / 100).floor) - 1
end

puts seriesCount.to_s + " " + loopCount.to_s

incrementor = 0
while incrementor <= loopCount
	puts "offset = " + ((incrementor + 1) * 100).to_s
	time = Time.now.to_i
	url = URI('http://gateway.marvel.com/v1/public/characters/' + config['superheroID'] + '/series')
	params = {
	  :ts => time,
	  :apikey => config['marvelPublicAPIKey'],
	  :hash => Digest::MD5.hexdigest(time.to_s + config['marvelPrivateAPIKey'] + config['marvelPublicAPIKey']),
	  :limit => '100',
	  :orderBy => 'startYear',
	  :offset => ((incrementor+1) * 100)
	}
	url.query = URI.encode_www_form(params)
	resp = Net::HTTP.get_response(url)
	jsonResp = JSON.parse(resp.body)
	allResults += jsonResp['data']['results']

	incrementor += 1
end

config_path = File.expand_path("../../data/series.json", __FILE__)
outfile = File.open(config_path, 'w')
outfile.write(allResults.to_json)
