require "yaml_recrypt/version"
require 'find'
require 'escort'

module YamlRecrypt
  @@logger = logger()

  def self.recrypt(file, gpg_private_key, eyaml_pub_key)
    Escort::Logger.output.puts "Processing #{file}"
  end

  def self.recrypt_r(dir, gpg_private_key, eyaml_pub_key)
    Find.find(dir) do |path|
      if path =~ /.*\.yaml$/
        recrypt(path, gpg_private_key, eyaml_pub_key)
      end
    end

  end
end
