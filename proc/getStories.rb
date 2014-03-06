require 'net/http'
require 'json'
require 'digest/md5'

time = Time.now.to_i 
config = JSON.parse(File.read('config.json'))

allResults = Array.new

url = URI('http://gateway.marvel.com/v1/public/characters/' + config['superheroID'] + '/stories')
params = {
  :ts => time,
  :apikey => config['marvelPublicAPIKey'],
  :hash => Digest::MD5.hexdigest(time.to_s + config['marvelPrivateAPIKey'] + config['marvelPublicAPIKey']),
  :limit => '100',
  :orderBy => 'id'
}
url.query = URI.encode_www_form(params)

resp = Net::HTTP.get_response(url)
jsonResp = JSON.parse(resp.body)
allResults = jsonResp['data']['results']
storyCount = jsonResp['data']['total']

if storyCount != 100
	loopCount = ((storyCount / 100).floor) - 1
end

puts storyCount.to_s + " " + loopCount.to_s

incrementor = 0
while incrementor <= loopCount
	puts "offset = " + ((incrementor + 1) * 100).to_s
	time = Time.now.to_i
	url = URI('http://gateway.marvel.com/v1/public/characters/' + config['superheroID'] + '/stories')
	params = {
	  :ts => time,
	  :apikey => config['marvelPublicAPIKey'],
	  :hash => Digest::MD5.hexdigest(time.to_s + config['marvelPrivateAPIKey'] + config['marvelPublicAPIKey']),
	  :limit => '100',
	  :orderBy => 'id',
	  :offset => ((incrementor+1) * 100)
	}
	url.query = URI.encode_www_form(params)
	resp = Net::HTTP.get_response(url)
	jsonResp = JSON.parse(resp.body)
	allResults += jsonResp['data']['results']

	incrementor += 1
end

config_path = File.expand_path("../../data/stories.json", __FILE__)
outfile = File.open(config_path, 'w')
outfile.write(allResults.to_json)
