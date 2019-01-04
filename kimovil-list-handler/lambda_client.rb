require 'aws-sdk-lambda'
require 'yaml'

module LambdaClient
  def self.initialize!
    creds = YAML.load(File.read('keys.yml'))

    @@client ||= Aws::Lambda::Client.new(
      access_key_id: creds['access_key_id'],
      secret_access_key: creds['secret_access_key']
    )
  end

  module_function

  def invoke(function, event)
    initialize! unless defined? @@client
    @@client.invoke_async({
      function_name: function,
      invoke_args: event.to_json
    })
  end
end
