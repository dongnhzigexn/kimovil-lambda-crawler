require 'json'
require 'rest-client'
require 'nokogiri'
require 'yaml'
require 'digest'
require_relative 'dynamodb'

def lambda_handler(event:, context:)
  url = event['url']
  res = RestClient.get(url)
  doc = Nokogiri::HTML(res)
  
  # Parse data from detail page
  name, antutu, price, id = get_data(doc)
  created_at = Time.now.to_s

  data = {
    id: id,
    name: name,
    antutu: antutu,
    price: price,
    created_at: created_at
  }

  # Save crawled data to db
  DynamoDb.save_to_db('kimovil-result', data)

  # Save crawled links to db
  DynamoDb.save_to_db('kimovil-crawled-links', { url: url, status: res.code, created_at: created_at })
  
rescue => e
  puts "ERROR: #{e}"
end

def get_data(doc)
  name = squish(doc.css('.description h1').children.last.text)
  antutu = doc.css('div.fc.w100.antutu').children.last.text.gsub(/\D/, '')
  price = doc.css('div.other-devices-list-version li.item.active span.ksps span.xx_usd').text.gsub(/\D/, '')
  price = '-' if price.empty?
  id = Digest::MD5.hexdigest(name + antutu + price)
  return [name, antutu, price, id]
end

def squish(str)
  return unless str
  str.strip.gsub(/\s+/, ' ')
end
