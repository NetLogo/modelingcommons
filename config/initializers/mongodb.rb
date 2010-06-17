# Open TCP connection to the MongoDB, and select the database
MongoMapper.database = "modelingcommons_#{RAILS_ENV}"

host = '127.0.0.1'
port = 27017

# Initialize the connection to MongoDB
MongoMapper.connection = XGen::Mongo::Driver::Mongo.new(host, port, :auto_reconnect => true)
