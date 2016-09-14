require 'aws-sdk'

def get_public_url(client, bucket_name, key)
  Aws::S3::Object.new(
    key: key,
    bucket_name: bucket_name,
    client: client
  ).public_url
end

# list file in a bucket
def list_files(client, bucket_name)
  client.list_objects(bucket: bucket_name).contents.each_with_index do |content, index|
    puts "\t #{index+1}. #{content.key}(#{content.size} bytes)"
    public_url = get_public_url(client, bucket_name, content.key)
    puts "\t\tPublic link: #{public_url}"
  end
end

# configure AWS S3
Aws.config.update(
  access_key_id: 'x',
  secret_access_key: 'y',
  region: 'localhost',
  s3: {
    endpoint: 'http://localhost:10001',
    force_path_style: true
  }
)

# create bucket
client = Aws::S3::Client.new
bucket_name = 'pixtavietnam-local'
client.create_bucket(bucket: bucket_name)
puts "Create bucket \'#{bucket_name}\' successfully!"

# list all current buckets
buckets = client.list_buckets.buckets
puts "\n#{buckets.count} current buckets:"
buckets.each_with_index do |bucket, index|
  puts "\t#{index+1}. Name: #{bucket.name}, Creation Date: #{bucket.creation_date}"
end

# upload files to pixtavietnam-local bucket
client.put_object(
  bucket: bucket_name,
  key: "first_file.txt",
  body: File.open("uploads/note.txt", "rb")
)

client.put_object(
  bucket: bucket_name,
  key: "second_file.png",
  body: File.open("uploads/dev.png", "rb")
)
puts "\nUpload files to \'#{bucket_name}\' successfully!"

# list all objects
puts "\nList files:"
list_files(client, bucket_name)

# delete
client.delete_object(
  bucket: bucket_name,
  key: "first_file.txt"
)
puts "\nDelete first_file.txt successfully!"

client.delete_object(
  bucket: bucket_name,
  key: "second_file.png"
)
puts "Delete second_file.png successfully!"

# Delete bucket
client.delete_bucket(bucket: bucket_name)
puts "Delete bucket \'#{bucket_name}\' successfully!"
