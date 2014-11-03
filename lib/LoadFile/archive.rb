require "pathname"
require "digest/md5"

module LoadFile
  class Archive
    # Public: the archive filename
    attr_reader :file

    # Public: where to extract the archive
    attr_reader :save_location

    # Public: if enabled archive will be removed once extracted
    attr_accessor :delete_archive

    # Public: setup an archive for processing
    #
    # file - the archive filename (can be a relative path)
    # save_location - where to extract the archive, PWD used by default (default: nil)
    #
    # Examples
    #
    #   # unpack to PWD
    #   FileLoad::Archive.new("/ninja/file.gz").unpack
    #
    #   # unpack to custom directory
    #   FileLoad::Archive.new("file.zip", "/data").unpack
    #
    def initialize(file, save_location = nil)
      if File.exist?(file)
        @file = File.expand_path file
      else
        raise IOError, "Archive file not found, cannot continue [#{file}]"
      end

      if save_location.nil?
        @save_location = Dir.pwd
      elsif File.directory? save_location
        @save_location = File.expand_path save_location
      else
        @save_location = Pathname.new(File.expand_path(save_location)).dirname
      end
    end

    # Public: unpack the archive
    #
    # Returns LoadFile::Status::*
    def unpack
      case File.extname(@file)
      when ".zip"
        unzip
      when /\.(gz)|(gzip)/
        gunzip
      else
        status LoadFile::Status::Success
      end
    end

    private
      def complete_file
        checksum_file = ".complete-" + Digest::MD5.hexdigest(@file)
        File.join @save_location, checksum_file
      end

      def cleanup
        File.delete(complete_file) if File.exists?(complete_file)
      end

      def unzip
        cleanup
        # -q quiet, -o always overwrite
        `cd "#{@save_location}" && unzip -q -o "#{@file}" && touch #{complete_file}`
        check_command $?
      end

      def gunzip
        cleanup
        target = File.join(@save_location, File.basename(@file, File.extname(@file)))
        # -c to stdout, -q quiet, -f force overwrite, -k keep original
        `gunzip -c -q -f -k "#{@file}" > "#{target}" && touch #{complete_file}`
        check_command $?
      end

      def check_command(return_code)
        if return_code.exitstatus == 0 && File.exists?(complete_file)
          File.delete complete_file
          File.delete(file) if @delete_archive
          status LoadFile::Status::Success
        else
          status LoadFile::Status::Error
        end
      end

      def status(state, error = nil, trace = nil)
        state.new ({
          :input => {
            :file => @file
          },
          :error   => error,
          :trace   => trace
        })
      end
  end
end