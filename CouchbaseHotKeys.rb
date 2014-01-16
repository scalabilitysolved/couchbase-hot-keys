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

def retreiveCouchbaseStats(url,zoom)
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
  opt.separator  "     url: Url of one of your cluster nodes"
  opt.separator  "     zoom: Time scopre {minute|hour|day|week|month|year|}"
  opt.separator  "     additionalStats: include top key stats"
  opt.separator  ""
  opt.separator  "Options"

  opt.on("-u","--url URL",String,"Which node to target") do |url|
    options[:url] = url
  end

  opt.on("-z","--zoom ZOOM",String,"When to target") do |zoom|
    options[:zoom] = zoom
  end



  opt.on("-s","--stats",TrueClass,"additional stats") do |additional_stats|
  	options[:additional_stats] = additional_stats
  end

  opt.on("-h","--help","help") do
    puts opt_parser
  end
end

opt_parser.parse!

case ARGV[0]
when "u"
  puts "call start on options #{options.inspect}"
when "z"
  puts "call stop on options #{options.inspect}"
when "s"
  puts "call restart on options #{options.inspect}"
else
  puts opt_parser
  raise abort
end


url = options[:url]
zoom = options[:zoom]
additional_stats = options[:additional_stats]
puts url
puts zoom
puts additional_stats

json_response = retreiveCouchbaseStats(url,zoom)
generateHotKeys(json_response)
generateAdditionalStats(json_response)