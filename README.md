# Kimovil lambda crawler

# Description

Serverless crawler using AWS Lambda and DynamoDb. This project is a demo scraper for https://kimovil.com/en/compare-smartphones.

# Installation

This project consists of 2 lambda functions. Therefore, installation need to be done in both functions.

- Install dependencies for both functions.
```
cd kimovil-detail-handler && bundle install --path vendor/bundle

cd kimovil-list-handler && bundle install --path vendor/bundle
```
- Change aws credential keys and put your keys in there.
```
cp kimovil-detail-handler/keys.yml.sample kimovil-detail-handler/keys.yml

cp kimovil-list-handler/keys.yml.sample kimovil-list-handler/keys.yml
```

- Prepare deployment packages to AWS Lambda
```
cd kimovil-detail-handler
zip -r function.zip lambda_function.rb dynamodb.rb keys.yml lambda_client.rb vendor

cd kimovil-list-handler
zip -r function.zip lambda_function.rb dynamodb.rb keys.yml lambda_client.rb vendor
```

- Deploy `zip` packages to AWS Lambda
This can be done using Lambda Function Management screen on AWS or using AWS CLI command:
```
cd kimovil-detail-handler
aws lambda update-function-code --function-name kimovil-detail-handler --zip-file fileb://function.zip

cd kimovil-list-handler
aws lambda update-function-code --function-name kimovil-list-handler --zip-file fileb://function.zip
```
