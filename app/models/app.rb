class App
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  def initialize
  end

  def persisted?
    false
  end

  #require 'uri'
  #require 'net/http'
  #require 'json'

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
    url = App.base_api_url + 'login'
    params = {'username' => username, 'password' => password}
    response = App.post(url, params)
    response
  end

  def self.customers
    url = 'http://shielded-mesa-1340.herokuapp.com/customers.json'
    customers = App.get(url).body
    customers = JSON.parse customers
    customers = Hash[customers.map { |c| [c['siteId'], {'siteName' => c['siteName']}] }]
    customers
  end

  def self.machines
    url = 'http://shielded-mesa-1340.herokuapp.com/machines.json'
    machines = App.get(url).body
    machines = JSON.parse machines
    # How do I really do this?
    tmp = {}
    machines.each { |k,v| tmp[k] = {'deviceName' => machines[k]['deviceName'], 'deviceId' => machines[k]['deviceId'], 'siteId' => machines[k]['siteId']} }
    tmp
  end
end