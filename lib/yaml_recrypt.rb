require "yaml_recrypt/version"
require 'find'
require 'escort'
require 'yaml'
require 'fileutils'
require 'gpgme'
require 'openssl'

module YamlRecrypt
  GPG_MAGIC   = "-----BEGIN PGP MESSAGE-----"
  BACKUP_EXT  = "orig"

  def self.recrypt_file(filename, gpg_private_key, eyaml_pub_key)
    Escort::Logger.output.puts "Processing #{filename}"

    # load the yaml into a hash
    hash_wip  = YAML.load(File.readlines(filename).join("\n"))

    # descend every key until a string (or terminal) is reached
    #converted =
    replaced, converted = descend(gpg_private_key, eyaml_pub_key, hash_wip)
    require 'pp'

    #PP.pp(converted)
    #PP.pp(hash)

    if replaced > 0
      Escort::Logger.output.puts "*** updated #{replaced} values in #{filename} ****"
      # save old file with .orig -- some fool might run this on a non-version
      # controlled directory...
      FileUtils.cp(filename, "#{filename}.#{BACKUP_EXT}")

      # save the new data
      File.open(filename, 'w') {|f| f.write hash_wip.to_yaml }
    end
  end

  def self.descend(gpg_private_key, eyaml_pub_key, value)
    replaced = 0
    if value.class == Array
      value = value.map { |e|
        r, newvalue = process_value(e, gpg_private_key, eyaml_pub_key)
        replaced += r

        newvalue
      }
    elsif value.class == Hash
      value.each { |k,v|
        r, subtree = descend(gpg_private_key, eyaml_pub_key, v)
        value[k] = subtree
        replaced += r
      }
    else
      r, value = process_value(value, gpg_private_key, eyaml_pub_key)
      replaced += r
    end

    return replaced, value
  end

  def self.process_value(value, gpg_private_key, eyaml_pub_key)
    split = value.split("\n")

    # PGP values are always broken onto newlines
    if split[0].strip == '' and split[1].strip == GPG_MAGIC
      value = recrypt(value, gpg_private_key, eyaml_pub_key)
      changed = 1
    else
      changed = 0
    end

    return changed, value
  end

  def self.recrypt_r(dir, gpg_private_key, eyaml_pub_key)
    Find.find(dir) do |path|
      if path =~ /.*\.yaml$/
        recrypt_file(path, gpg_private_key, eyaml_pub_key)
      end
    end

  end

  def self.decrypt_gpg(ct, gpg_private_key)
    decrypt(ct, gpg_private_key)
  end




  def self.recrypt(value, gpg_private_key, eyaml_pub_key)
    "HIPOPOTOMUS"
  end
end
