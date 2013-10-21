require 'faraday'

conn = Faraday.new(:url => 'http://tracker.tworedkites.com') do |faraday|
  faraday.request  :url_encoded             # form-encode POST params
  faraday.response :logger                  # log requests to STDOUT
  faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP

end

login = conn.post '/youtrack/rest/user/login', { login: 'test', password: 'test'}
cookie = login.headers['set-cookie']

#
#response = conn.get '/youtrack/rest/issue/byproject/notacms' do |req|
#  req.headers['Cookie'] = cookie
#end
#p '---------'
#p response


### Creates a ticket
response = conn.put '/youtrack/rest/issue' do |req|
  req.headers['Cookie'] = cookie
  req.body = {project: 'test', summary: 'wat what 123', description: 'the quick brown fox jumped over the brown fox',
              permittedGroup: '2rk'}
end
p '---------'
p response["location"].split('/').last

=begin
response = conn.post do |req|
  req.url '/youtrack/rest/issue/test-5/execute'
  req.headers['Cookie'] = cookie
  #req.body = {command: "subtask of test-4 type Feature estimation 3h"}  #This works perfectly
  req.body = {command: "work 3h hello world"}

end
p '---------'
p response
=end




#response = conn.get '/youtrack/rest/admin/project' do |req|
#  req.headers['Cookie'] = cookie
#end
#p '---------'
#p response

