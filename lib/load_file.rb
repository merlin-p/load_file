require 'LoadFile/version'
require 'LoadFile/uri'
require 'LoadFile/archive'
require 'LoadFile/adapter'
require 'LoadFile/status'
require 'LoadFile/job'
# Public: loads resources from URI and unpacks zip/gzip archives
module LoadFile
  # Public: helper to download directly
  #
  # remote_uri - the URI to load from
  # save_location - where to save the loaded data (file|dir) (default: nil)
  # user - optional http auth user (default: nil)
  # password - optional http auth pass (default: nil)
  #
  # Returns result Hash
  def self.from_uri(remote_uri, save_location = nil, user = nil, password = nil)
    loader = LoadFile::URI.new(remote_uri, save_location)
    loader.auth(user, password)
    loader.load
  end

  # Public: helper to unpack archives
  #
  # file - the archive filename
  # save_location - optional save location, if none is given PWD is used (default: nil)
  #
  # Returns unpack location
  def self.from_archive(file, save_location = nil)
    LoadFile::Archive.new(file, save_location).unpack
  end

  # Public: helper to load and unpack archives
  #
  # remote_uri - the URI to load from
  # save_location - where to save the data
  def self.load_archive(remote_uri, save_location = nil, user = nil, password = nil)
    loader = LoadFile::URI.new(remote_uri, save_location)
    loader.auth user, password
    result = loader.load
    if result.success?
      from_archive(result.file, save_location)
    else
      raise "download failed, result: #{result.inspect}"
    end
  end
end
