require 'aws-sdk-dynamodb'
require 'yaml'

module DynamoDb
  def self.initialize!
    creds = YAML.load(File.read('keys.yml'))

    @@client ||= Aws::DynamoDB::Client.new(
      access_key_id: creds['access_key_id'],
      secret_access_key: creds['secret_access_key']
    )
  end

  module_function

  def client
    initialize! unless defined? @@client
    @@client
  end
  
  def save_to_db(table, data)
   client.put_item({
     table_name: table,
     item: data
   })
  end

  #
  # @table_name: string
  # @bulk_data: Array of data, Ex: [{a: 1},{b: 2}]
  #
  def bulk_save_to_db(table, bulk_data)
    requests = bulk_data.map { |data| { put_request: { item: data } } }

    client.batch_write_item({
      request_items: {
        table => requests
      }
    })
  end

  def delete_from_db(table, key)
    client.delete_item({
      table_name: table,
      key: key
    })
  end

  def tables
    client.list_tables
  end
end
