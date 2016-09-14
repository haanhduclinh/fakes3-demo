require 'aws-sdk'

# list file in a bucket
def list_files(bucket)
  bucket.objects.each_with_index do |object_summary, index|
    puts "\t #{index+1}. #{object_summary.key}(#{object_summary.size} bytes)"
    puts "\t\tPublic link: #{object_summary.public_url}"
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
s3 = Aws::S3::Resource.new
bucket = s3.bucket(bucket_name)

first_obj = bucket.object("first_file.txt");
first_obj.upload_file('uploads/note.txt')

second_obj = bucket.object("second_file.png");
second_obj.upload_file('uploads/dev.png')

puts "\nUpload files to \'#{bucket_name}\' successfully!"

puts "\nList files:"
list_files(bucket)

# delete
puts "You want to delete first_file.txt? (y/n)"
first_obj.delete if $stdin.getc == 'y'

# check delete
if first_obj.exists?
  puts "\nNot delete anything!"
else
  puts "\nDelete first_file.txt successfully!"
  puts "List files again:"
  list_files(bucket)
end
