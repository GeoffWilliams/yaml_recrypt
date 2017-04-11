require "yaml_recrypt/version"
require 'find'
require 'escort'
require 'yaml'

module YamlRecrypt
  GPG_MAGIC = "-----BEGIN PGP MESSAGE-----"

  def self.recrypt_file(filename, gpg_private_key, eyaml_pub_key)
    Escort::Logger.output.puts "Processing #{filename}"

    # load the yaml into a hash
    hash = YAML.load(File.readlines(filename).join("\n"))
    puts "data loaded!"

    # descend every key until a string (or terminal) is reached
    converted = descend(gpg_private_key, eyaml_pub_key, hash)
    require 'pp'

    PP.pp(converted)
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

    # PGP values are always broken onto newlines using '|'
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
