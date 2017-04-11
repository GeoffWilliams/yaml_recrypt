require "yaml_recrypt/version"
require 'find'
require 'escort'
require 'yaml'
require 'fileutils'

module YamlRecrypt
  GPG_MAGIC   = "-----BEGIN PGP MESSAGE-----"
  BACKUP_EXT  = "orig"

  def self.recrypt_file(filename, gpg_private_key, eyaml_pub_key)
    Escort::Logger.output.puts "Processing #{filename}"

    # load the yaml into a hash

    # I'm going to hell for this
    hash_orig = YAML.load(File.readlines(filename).join("\n"))
    hash_wip  = YAML.load(File.readlines(filename).join("\n"))

    # descend every key until a string (or terminal) is reached
    #converted =
    descend(gpg_private_key, eyaml_pub_key, hash_wip)
    require 'pp'

    #PP.pp(converted)
    #PP.pp(hash)

    if hash_orig != hash_wip
      Escort::Logger.output.puts "***updated values in #{filename}****"
      # save old file with .orig -- some fool might run this on a non-version
      # controlled directory...
      FileUtils.cp(filename, "#{filename}.#{BACKUP_EXT}")

      # save the new data
      File.open(filename, 'w') {|f| f.write hash_wip.to_yaml }
    end
  end

  def self.descend(gpg_private_key, eyaml_pub_key, value)
    if value.class == Array
      value.map { |e|
        process_value(e, gpg_private_key, eyaml_pub_key)
      }
    elsif value.class == Hash
      value.each { |k,v|
        value[k] = descend(gpg_private_key, eyaml_pub_key, v)
      }
    else
      value = process_value(value, gpg_private_key, eyaml_pub_key)
    end

    value
  end

  def self.process_value(value, gpg_private_key, eyaml_pub_key)
    split = value.split("\n")

    # PGP values are always broken onto newlines
    if split[0].strip == '' and split[1].strip == GPG_MAGIC
      value = recrypt(value, gpg_private_key, eyaml_pub_key)
    end

    value
  end

  def self.recrypt_r(dir, gpg_private_key, eyaml_pub_key)
    Find.find(dir) do |path|
      if path =~ /.*\.yaml$/
        recrypt_file(path, gpg_private_key, eyaml_pub_key)
      end
    end

  end

  def self.recrypt(value, gpg_private_key, eyaml_pub_key)
    "HIPOPOTOMUS"
  end
end
