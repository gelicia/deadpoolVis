require 'net/http'
require 'json'
require 'digest/md5'

time = Time.now.to_i 
config = JSON.parse(File.read('config.json'))

moreComics = true
allResults = Array.new

url = URI('http://gateway.marvel.com/v1/public/characters/' + config['superheroID'])
params = {
  :ts => time,
  :apikey => config['marvelPublicAPIKey'],
  :hash => Digest::MD5.hexdigest(time.to_s + config['marvelPrivateAPIKey'] + config['marvelPublicAPIKey']),
}
url.query = URI.encode_www_form(params)

resp = Net::HTTP.get_response(url)
jsonResp = JSON.parse(resp.body)['data']['results']
["comics", "events", "series", "stories"].each { |k| jsonResp.delete(k) }
#jsonResp.delete("comics")
#jsonResp.delete("events")
#jsonResp.delete("series")
#jsonResp.delete("stories")

config_path = File.expand_path("../../data/character.json", __FILE__)
outfile = File.open(config_path, 'w')
outfile.write(jsonResp.to_json)