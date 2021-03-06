class App
  #include ActiveModel::Conversion
  #extend ActiveModel::Naming
  #
  #def persisted?
  #  false
  #end

  # http://stackoverflow.com/a/895752/2197402
  #class << self
  #  attr_accessor :username
  #  attr_accessor :password
  #end
  #
  #@@username = nil
  #@@password = nil

  require 'net/http'

  def self.base_api_url
    'http://shielded-mesa-1340.herokuapp.com/'
  end

  def self.get(uri)
    uri = URI.parse(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    http.request(request)
  end

  def self.post(uri, params)
    uri = URI.parse(uri)
    Net::HTTP.post_form(uri, params)
  end

  def self.login(username, password)
  #def self.login(username = @@username, password = @@password)
  #  if username.present? and password.present?
    url = App.base_api_url + 'login.json'
    params = {'username' => username, 'password' => password}
    JSON.parse App.post(url, params).body
  end

  def self.customers
    #App.login
    url = App.base_api_url + 'customers.json'
    customers = JSON.parse App.get(url).body
    # Why am I nesting it this deep ...
    Hash[customers.map { |c| [c['siteId'], {'siteName' => c['siteName']}] }]
  end

  def self.machines
    #App.login
    url = App.base_api_url + 'machines.json'
    machines = JSON.parse App.get(url).body
    Hash[machines.map { |k, v| [k, {'deviceName' => v['deviceName'], 'deviceId' => v['deviceId'], 'siteId' => v['siteId']}] }]
  end

  def self.parts_info(customer_id)
    #App.login
    url = App.base_api_url + 'parts_info.json'
    params = {'site_id' => customer_id}
    machines = JSON.parse App.post(url, params).body
    Hash[machines.map { |k, v| [k, v['packageQty']] }]
  end

  def self.machine_counts(customer_id, machine_id)
    #App.login
    url = App.base_api_url + 'machine_counts.json'
    params = {'site_id' => customer_id, 'device_id' => machine_id}
    counts = JSON.parse App.post(url, params).body
    counts = counts.select { |k,v| v['sku'].present? }
    counts = counts.map {|k,v| [v['sku'], v['count'].to_i]}
    counts.inject({}) {|new,line| new.key?(line[0]) ? new[line[0]]+=line[1] : new[line[0]]=line[1]; new}
  end

  def self.transaction_summary(customer_id, machine_id, begin_date)
    #App.login
    url = App.base_api_url + 'transaction_summary.json'
    params = {'site_id' => customer_id, 'device_id' => machine_id, 'begin_date' => begin_date, 'end_date' => Date.today.strftime('%m/%d/%Y')}
    summary = JSON.parse App.post(url, params).body
    summary = summary.map {|line| [line['productNum1'], line['packageQty']*line['qtyDispensed']] }
    summary.inject({}) {|new,line| new.key?(line[0]) ? new[line[0]]+=line[1] : new[line[0]]=line[1]; new}
  end

  def self.transaction_details(customer_id, machine_id, begin_date, begin_time)
    #App.login
    end_date = (Date.strptime(begin_date, '%m/%d/%Y') + 1).strftime('%m/%d/%Y')
    cutoff = DateTime.strptime(begin_date + begin_time, '%m/%d/%Y%H:%M:%S')
    url = App.base_api_url + 'transaction_details.json'
    params = {'site_id' => customer_id, 'device_id' => machine_id, 'begin_date' => begin_date, 'end_date' => end_date}
    details = JSON.parse App.post(url, params).body
    # Remove timezone stamp (for now)
    details = details.each { |line| line[0] = line[0].scan(/[\d -:]+/)[0]}
    details = details.select { |line| DateTime.strptime(line[0], '%Y-%m-%d %H:%M:%S') > cutoff}
    details = details.map { |line| [line[1], line[2].to_i * line[3].to_i] }
    details.inject({}) {|new,line| new.key?(line[0]) ? new[line[0]]+=line[1] : new[line[0]]=line[1]; new}
  end
end

class Location < App
  def self.calculate(customer_id, machine_id, begin_date, begin_time)
    if begin_time == '00:00:00'
      details = {}
    else
      details = App.transaction_details(customer_id, machine_id, begin_date, begin_time)
      begin_date = (Date.strptime(begin_date, '%m/%d/%Y') + 1).strftime('%m/%d/%Y')
    end
    parts_info = App.parts_info(customer_id)
    counts = App.machine_counts(customer_id, machine_id)
    summary = App.transaction_summary(customer_id, machine_id, begin_date)
    counts = counts.each { |k,v| counts[k] *= parts_info[k]}
    # collapse details into summary, summary into counts
    details.each { |k, v| summary.key?(k) ? summary[k] += details[k] : summary[k] = details[k] }
    summary.each { |k, v| counts.key?(k) ? counts[k] += summary[k] : counts[k] = summary[k] }
    counts = counts.select {|k,v| v>0 }
    counts = counts.inject('') {|str, (k, v)| str + "#{k}\t#{v}\n"}
    counts.gsub(/\[.*?\]/,'')
  end
end