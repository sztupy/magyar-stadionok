#!/usr/bin/env ruby

require 'rubygems'
require 'bundler'
require 'json'
require 'nokogiri'
require 'open-uri'

COUNTY_LIST = %w(bacs-kiskun baranya bekes borsod-abauj-zemplen csongrad fejer gyor-moson-sopron hajdu-bihar heves jasz-nagykun-szolnok komarom-esztergom nograd pest somogy szabolcs-szatmar-bereg tolna vas veszprem zala)
BP_DISTRICTS = 23

markers = {}

COUNTY_LIST.each do |county|
  STDERR.puts county
  open("http://www.magyarfutball.hu/hu/stadionok/terkep/#{county}") do |f|
    f.each_line do |l|
      if l =~ /addMarker\((.*),(.*),(.*), '(.*)',(.*)\)/
        markers[$5.strip.to_i] = {lat: $2.strip.to_f, lon: $3.strip.to_f, name: $4, id: $5.strip.to_i}
      end
    end
  end
  STDERR.puts markers.length
end

(1..BP_DISTRICTS).each do |district|
  STDERR.puts district
  open("http://www.magyarfutball.hu/hu/budapesti-stadionterkep/#{district}") do |f|
    lat = nil
    lon = nil
    f.each_line do |l|
      if l =~ /new GLatLng\((.*),(.*)\);/
        lat = $1.strip.to_f
        lon = $2.strip.to_f
      elsif l =~ /createMarker\(point, "(.*)", "<a href=\\"\/hu\/stadion\/([0-9]+)\\">/
        markers[$2.strip.to_i] = {lat: lat, lon: lon, name: $1, id: $2.strip.to_i} if lat
        lat = nil
      end
    end
  end
  STDERR.puts markers.length
end

puts "var addressPoints = [#{markers.map{|id,m|m.to_json}.join(",")}];"
