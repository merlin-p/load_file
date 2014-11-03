require "pathname"
require "digest/md5"

module LoadFile
  class Archive
    # Public: the archive filename
    attr_reader :file

    # Public: where to extract the archive
    attr_reader :local_path

    # Public: if enabled archive will be removed once extracted
    attr_accessor :delete_archive

    # Public: setup an archive for processing
    #
    # file - the archive filename (can be a relative path)
    # local_path - where to extract the archive, PWD used by default (default: nil)
    #
    # Examples
    #
    #   # unpack to PWD
    #   FileLoad::Archive.new("/ninja/file.gz").unpack
    #
    #   # unpack to custom directory
    #   FileLoad::Archive.new("file.zip", "/data").unpack
    #
    def initialize(file, local_path = nil)
      if File.exist?(file)
        @file = File.expand_path file
      else
        raise IOError, "Archive file not found, cannot continue [#{file}]"
      end

      if local_path.nil?
        @local_path = Dir.pwd
      elsif File.directory? local_path
        @local_path = File.expand_path local_path
      else
        @local_path = Pathname.new(File.expand_path(local_path)).dirname
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
        File.join @local_path, checksum_file
      end

      def cleanup
        File.delete(complete_file) if File.exists?(complete_file)
      end

      def unzip
        cleanup
        # -q quiet, -o always overwrite
        `unzip -q -o "#{@file}" -d "#{@local_path}" && touch #{complete_file}`
        check_command $?
      end

      def gunzip
        cleanup
        target = File.join(@local_path, File.basename(@file, File.extname(@file)))
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