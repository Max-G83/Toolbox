class App
  #include ActiveModel::Conversion
  #extend ActiveModel::Naming
  #
  #def persisted?
  #  false
  #end

  def self.base_api_url
    'http://shielded-mesa-1340.herokuapp.com/'
  end

  def self.get(uri)
    uri = URI.parse(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    response
  end

  def self.post(uri, params)
    uri = URI.parse(uri)
    response = Net::HTTP.post_form(uri, params)
    response
  end

  def self.login(username, password)
    url = App.base_api_url + 'login.json'
    params = {'username' => username, 'password' => password}
    response = App.post(url, params).body
    JSON.parse(response)
  end

  def self.customers
    url = url = App.base_api_url + 'customers.json'
    customers = App.get(url).body
    customers = JSON.parse customers
    Hash[customers.map { |c| [c['siteId'], {'siteName' => c['siteName']}] }]
  end

  def self.machines
    url = url = App.base_api_url + 'machines.json'
    machines = App.get(url).body
    machines = JSON.parse machines
    # I think I can do this in one line with inject
    tmp = {}
    machines.each { |k,v| tmp[k] = {'deviceName' => machines[k]['deviceName'], 'deviceId' => machines[k]['deviceId'], 'siteId' => machines[k]['siteId']} }
    tmp
  end
end