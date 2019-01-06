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

  
  phone_detail_links = []
  next_page_link = url
  while true do
    res = RestClient.get(next_page_link)
    res = JSON.parse(res)
    doc = Nokogiri::HTML(res['content'])

    next_page_link = 'https://www.kimovil.com' + res['next_page_url'] + '?xhr=1'
    puts "next_page_link: #{next_page_link}"
    phone_detail_links << doc.css('div.item-wrapper a.open-newtab').map { |a| { url: a['href'] } }
    break if next_page_link.include? 'page.50'
  end
  
  puts "Total links: #{phone_detail_links.flatten.count}"
  threads = []
  # threads << Thread.new { LambdaClient.invoke('kimovil-list-handler-2', { url: next_page_link }) }
  phone_detail_links.flatten.each do |link|
    threads << Thread.new do
      # Invoke lambda handler for detail link
      LambdaClient.invoke('kimovil-detail-handler-2', link)
    end
  end
  threads.map(&:join)

  puts "DONE"
  # Save crawled page to db
  #DynamoDb.save_to_db('kimovil-crawled-pages', { url: url, created_at: Time.now.to_s })

rescue => e
  puts "ERROR: #{e}"
end

lambda_handler(event: { 'url' => 'https://www.kimovil.com/en/compare-smartphones/page.45?xhr=1'}, context: nil)
