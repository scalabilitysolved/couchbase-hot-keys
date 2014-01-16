#!/usr/bin/env ruby
require 'net/http'
require 'json'
require 'jsonpath'
require 'optparse'

class HotKey
  def initialize(id,ops)
    @id = id
    @ops = ops
  end

  def to_s
    "ID: " + @id.to_s.gsub('"','').gsub('[','').gsub(']','') + " OPS: " + @ops.to_s.gsub('"','').gsub('[','').gsub(']','')
  end
end

def retreiveCouchbaseStats(ip,bucket,zoom)
  url = "http://" + ip + ":8091/pools/default/buckets/" + bucket + "/stats"
  uri = URI.parse(url)
  params = {:zoom => zoom.to_s}
  uri.query = URI.encode_www_form(params)
  req = Net::HTTP::Get.new(uri)
  res = Net::HTTP.start(uri.host, uri.port) {|http|
    http.request(req)
  }
  json_response = JSON.parse(res.body)
end

def generateHotKeys(json)
  hot_keys = json["hot_keys"]
  hot_keys.each do |key| 
    id = JsonPath.on(key,"$..name").to_s
    ops = JsonPath.on(key,"$..ops").to_s
    puts hotKey = HotKey.new(id,ops)
  end
end

def generateAdditionalStats(json)
names = ["couch_docs_fragmentation","couch_views_fragmentation","ep_cache_miss_rate","cmd_get","cmd_set","disk_write_queue"]
names.each{ |name| puts name + " " +  JsonPath.on(json,"$.." + name + "[-1]").to_s}
end

options = {}

opt_parser = OptionParser.new do |opt|
  opt.banner = "Usage: Couchbase Hot Keys COMMAND [OPTIONS]"
  opt.separator  ""
  opt.separator  "Commands"
  opt.separator  "     ip: Ip of one of the nodes in your cluster"
  opt.separator  "     zoom: Time scope"
  opt.separator  "     bucket: Name of the bucket"
  opt.separator  "     stats: Include doc/view fragmentation, disk write queue and other key stats"
  opt.separator  ""
  opt.separator  "Options"

  opt.on("-u","--ip IP",String,"Node IP") do |ip|
    options[:ip] = ip
  end

  opt.on("-b","--bucket BUCKET",String,"Bucket name") do |bucket|
    options[:bucket] = bucket
  end

  opt.on("-z","--zoom ZOOM",String,"Options {minute|hour|day|week|month|year|}") do |zoom|
    options[:zoom] = zoom
  end

  opt.on("-s","--stats",TrueClass,"add flag for additional stats") do |stats|
  	options[:stats] = stats
  end

  opt.on("-h","--help","help") do
    puts opt_parser
  end
end

opt_parser.parse!



ip = options[:ip]
zoom = options[:zoom]
bucket = options[:bucket]
additional_stats = options[:stats]

puts ip
puts zoom
puts bucket

if ip.nil? or zoom.nil? or bucket.nil?
puts opt_parser
raise abort
end

json_response = retreiveCouchbaseStats(ip,bucket,zoom)
generateHotKeys(json_response)

if additional_stats
generateAdditionalStats(json_response)
end