#! /usr/bin/ruby
# coding: utf-8

require 'cgi'
require 'erb'
require 'csv'
require 'time'
require 'date'
require 'yaml'
require 'sqlite3'

CONFIG = YAML.load_file(File.expand_path("../config.yml", __FILE__))

#
# オブジェクトを深いコピーする
#
def deep_copy(obj)
  Marshal.load(Marshal.dump(obj))
end

#
# ログ
#
def log(str, file)
  open(file, "a") do |f|
    f.write("[#{Time.now.to_s}] #{str}\n")
  end
end


#
# エラー処理は全部これ
#
def exception_handling(e, cgi)
  log("#{cgi.remote_addr} #{cgi.remote_host}: " + e.to_s + "\n" + e.backtrace.join("\n"), "./error.log")

  print cgi.header( {
    "status"     => "REDIRECT",
    "Location"   => "./?has_error=true"
  })
end
