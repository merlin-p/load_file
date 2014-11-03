# LoadFile

Load files from URIs and unpack archives (currently zip,gzip)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'LoadFile'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install LoadFile

## Usage

a bin script is included for cli usage

    $ loadfile http://ninja/1.gz http://ninja/2.test

### directly download file to PWD
> LoadFile.from_uri("http://ninja/url")

### load file with authentication
> LoadFile::URI.new("http://ninja/file").auth(user,pass).load

### download and unpack file to custom directory
> LoadFile.load_archive("http://ninja/file.zip","/opt/archive")

## Features

 + + implemented

 - missing

### general

 - logging

 - job queue + retries

### URI

 + + HTTP streaming (reducing load for large files)

 + + HTTP range (resume)

 + + HTTPS

 + + HTTPS disable certificate verification

 + + HTTP Basic Auth

 - FTP, SSH/SFTP

 - http status handling (e.g. 404 -> error, 301 -> redirect)

 - integrity checks (checksum verify)

### Archive

 + + zip

 + + gzip

 - bzip, rar, 7z

 - mime-type support (currently only file extensions -> depends on server reply + uri)

 - password support

 - file listing + verification