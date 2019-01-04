require 'json'
require 'rest-client'
require 'nokogiri'
require_relative 'dynamodb'
require_relative 'lambda_client'

def lambda_handler(event:, context:)
  puts "EVENT RECEIVED:"
  puts event

  url = event['url']
  # Only crawl first 50 pages for testing
  return if url.include? 'page.50'

  res = RestClient.get(url)
  res = JSON.parse(res)
  
  doc = Nokogiri::HTML(res['content'])

  next_page_link = 'https://www.kimovil.com' + res['next_page_url'] + '?xhr=1'
  
  phone_detail_links = doc.css('div.item-wrapper a.open-newtab').map { |a| { url: a['href'] } }
  
  phone_detail_links.each do |link|
    LambdaClient.invoke('kimovil-detail-handler-2', link)
  end

  LambdaClient.invoke('kimovil-list-handler-2', { url: next_page_link })

  # Save crawled page to db
  DynamoDb.save_to_db('kimovil-crawled-pages', { url: url })

rescue => e
  puts "ERROR: #{e}"
end


lambda_handler(event: { 'url' => 'https://www.kimovil.com/en/compare-smartphones/page.45?xhr=1'}, context: nil)
