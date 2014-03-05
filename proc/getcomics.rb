require 'net/http'
require 'json'
require 'digest/md5'

time = Time.now.to_i 
config = JSON.parse(File.read('config.json'))

moreComics = true
allResults = Array.new

url = URI('http://gateway.marvel.com/v1/public/characters/' + config['superheroID'] + '/comics')
params = {
  :ts => time,
  :apikey => config['marvelPublicAPIKey'],
  :hash => Digest::MD5.hexdigest(time.to_s + config['marvelPrivateAPIKey'] + config['marvelPublicAPIKey']),
  :limit => '100',
  :orderBy => 'focDate'
}
url.query = URI.encode_www_form(params)

resp = Net::HTTP.get_response(url)
jsonResp = JSON.parse(resp.body)
allResults = jsonResp['data']['results']
comicCount = jsonResp['data']['total']

if comicCount != 100
	loopCount = ((comicCount / 100).floor) - 1
end

puts comicCount.to_s + " " + loopCount.to_s

incrementor = 0
while incrementor <= loopCount
	puts "offset = " + ((incrementor + 1) * 100).to_s
	url = URI('http://gateway.marvel.com/v1/public/characters/' + config['superheroID'] + '/comics')
	params = {
	  :ts => time,
	  :apikey => config['marvelPublicAPIKey'],
	  :hash => Digest::MD5.hexdigest(time.to_s + config['marvelPrivateAPIKey'] + config['marvelPublicAPIKey']),
	  :limit => '100',
	  :orderBy => 'focDate',
	  :offset => ((incrementor+1) * 100)
	}
	url.query = URI.encode_www_form(params)
	resp = Net::HTTP.get_response(url)
	jsonResp = JSON.parse(resp.body)
	allResults += jsonResp['data']['results']

	incrementor += 1
end

puts allResults