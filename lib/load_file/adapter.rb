require 'load_file/adapter/base'
require "load_file/adapter/nethttp"

module LoadFile
  module Adapter
    DEFAULT = LoadFile::Adapter::NetHTTP
  end
end