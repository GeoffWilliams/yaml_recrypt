require "yaml_recrypt/version"
require "yaml_recrypt/gpg"
require "yaml_recrypt/eyaml"
require "yaml_recrypt/postprocess"
require 'find'
require 'escort'
require 'yaml'
require 'fileutils'
require 'gpgme'
require 'openssl'

module YamlRecrypt
  GPG_MAGIC       = "-----BEGIN PGP MESSAGE-----"
  BACKUP_EXT      = "orig"
  # match /etc/puppet and /etc/puppetlabs to protect all customers
  REAL_PUPPET_DIR = "/etc/puppet"

  def self.recrypt_file(filename, gpg_home, eyaml_pub_key)
    if filename.start_with? REAL_PUPPET_DIR
      abort("Detected being run from the #{REAL_PUPPET_DIR}*! Refusing to run to avoid trashing live puppet master")
    end
    Escort::Logger.output.puts "Processing #{filename}"

    # load the yaml into a hash
    hash_wip  = YAML.load(File.readlines(filename).join("\n"))

    # descend every key until a string (or terminal) is reached
    replaced, converted = descend(gpg_home, eyaml_pub_key, hash_wip)

    if replaced > 0
      Escort::Logger.output.puts "*** updated #{replaced} values in #{filename} ****"
      # save old file with .orig -- some fool might run this on a non-version
      # controlled directory...
      FileUtils.cp(filename, "#{filename}.#{BACKUP_EXT}")

      # save the new data
      File.open(filename, 'w') {|f| f.write hash_wip.to_yaml }

      # Post-process the data to convert yaml multi-line blocks into yaml folded
      # blocks
      YamlRecrypt::PostProcess::postprocess(filename)
    end
  end

  def self.descend(gpg_home, eyaml_pub_key, value)
    replaced = 0
    if value.class == Array
      i = 0
      value.each { |v|
        begin
          r, subtree  = descend(gpg_home, eyaml_pub_key, v)
          value[i]    = subtree
          replaced    += r
        rescue GPGME::Error::NoData
          raise("Invalid GPG data detected in element #{i}")
        end
        i += 1
      }
    elsif value.class == Hash
      value.each { |k,v|
        begin
          r, subtree  = descend(gpg_home, eyaml_pub_key, v)
          value[k]    = subtree
          replaced    += r
        rescue GPGME::Error::NoData
          raise("Invalid GPG data detected in key #{k}")
        end
      }
    else
      r, value = process_value(value, gpg_home, eyaml_pub_key)
      replaced += r
    end

    return replaced, value
  end

  def self.process_value(value, gpg_home, eyaml_pub_key)
    split = value.split("\n")

    # PGP values are always broken onto newlines
    if split[0].strip == '' and split[1].strip == GPG_MAGIC
      value = recrypt(value, gpg_home, eyaml_pub_key)
      changed = 1
    else
      changed = 0
    end

    return changed, value
  end

  def self.recrypt_r(dir, gpg_home, eyaml_pub_key)
    Find.find(dir) do |path|
      if path =~ /.*\.yaml$/
        recrypt_file(path, gpg_home, eyaml_pub_key)
      end
    end

  end

  def self.recrypt(gpg_ct, gpg_home, eyaml_pub_key)
    pt = YamlRecrypt::Gpg::decrypt(gpg_ct, gpg_home)

    YamlRecrypt::Eyaml::encrypt_and_encode(pt, eyaml_pub_key).strip
  end
end
