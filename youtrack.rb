require 'faraday'

class Youtrack

  def initialize
    @connection = Faraday.new(:url => 'http://tracker.tworedkites.com') do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      #faraday.response :logger                  # log requests to STDOUT
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
  end

  def authenticate login, password
    login = @connection.post '/youtrack/rest/user/login', { login: login, password: password}
    @cookie = login.headers['set-cookie']
  end

  def create_project id, name
    create_response = @connection.put "/youtrack/rest/admin/project/#{id}" do |req|
      req.headers['Cookie'] = @cookie
      req.body = {projectName: name, startingNumber: 1, projectLeadLogin: 'test'}
    end
    raise create_response.env[:body] unless create_response.status == 201

  end


  # create_ticket
  #   project_name    short name of project
  #   options
  #     summary       Short description of issue
  #     description   Long description (optional)
  #     private       when set to true the visibility is set to 2RK (default false)
  #     subtask_of    ID of parent issue (optional)
  #     type          sets issue type (default feature)
  #     estimate      work estimate in hours

  def create_ticket project_name, options={}
    p '-----------------'
    p options
    options.merge!(permittedGroup: '2rk') if options[:private]
    options.merge!(project: project_name)
    estimation = options[:estimation]

    command_lists = []
    command_lists << "subtask of #{options[:subtask_of]}" if options[:subtask_of]
    command_lists << "type #{options[:type] || 'feature'}"
    #command_lists << "estimation #{options[:estimation]}h" if options[:estimation]
    command_list = command_lists.join(' ')

    issue_options = options.delete_if {|key, value| ![:project, :summary, :description, :permittedGroup].include? key }
    p issue_options
    p '-----------------'
    create_response = @connection.put '/youtrack/rest/issue' do |req|
      req.headers['Cookie'] = @cookie
      req.body = issue_options
    end

    raise create_response.env[:body] unless create_response.status == 201
    new_ticket = create_response["location"].split('/').last

    command_response = @connection.post do |req|
      req.url "/youtrack/rest/issue/#{new_ticket}/execute"
      req.headers['Cookie'] = @cookie
      req.body = {command: command_list}
    end
    if estimation
      estimate_response = @connection.post do |req|
        req.url "/youtrack/rest/issue/#{new_ticket}/execute"
        req.headers['Cookie'] = @cookie
        req.body = {command: "estimation #{estimation}h"}
      end

    end
    unless command_response.status == 200
      delete_response = @connection.delete "/youtrack/rest/issue/#{new_ticket}" do |req|
        req.headers['Cookie'] = @cookie
      end
      raise command_response.env[:body]
    end
    puts "Ticket #{new_ticket} created"
    new_ticket
  end


end