require 'json'
require 'rest-client'
require 'nokogiri'
require 'yaml'
require 'aws-sdk-dynamodb'
require_relative 'dynamodb'
require 'digest'

def lambda_handler(event:, context:)
  url = event['url']
  res = RestClient.get(url)
  doc = Nokogiri::HTML(res)
  name = squish(doc.css('.description h1').children.last.text)
  antutu = doc.css('div.fc.w100.antutu').children.last.text.gsub(/\D/, '')
  price = doc.css('div.other-devices-list-version li.item.active span.ksps span.xx_usd').text.gsub(/\D/, '')
  id = Digest::MD5.hexdigest(name + antutu + price)

  data = {
    Id: id,
    Name: name,
    Antutu: antutu,
    Price: price
  }

  # Save crawled links to db
  DynamoDb.save_to_db('kimovil-crawled-links', { url: url })

  # Save crawled data to db
  DynamoDb.save_to_db('kimovil-result', data)
end

def squish(str)
  return unless str
  str.strip.gsub(/\s+/, ' ')
end
