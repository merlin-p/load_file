require 'LoadFile/adapter/base'
require "LoadFile/adapter/nethttp"

module LoadFile
  module Adapter
    DEFAULT = LoadFile::Adapter::NetHTTP
  end
end