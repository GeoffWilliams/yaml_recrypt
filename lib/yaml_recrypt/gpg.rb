# Sourced from https://github.com/sihil/hiera-eyaml-gpg
# file: /lib/hiera/backend/eyaml/encryptors/gpg.rb
module YamlRecrypt
  module Gpg
    def self.gnupghome
    gnupghome = self.option :gnupghome
    debug("GNUPGHOME is #{gnupghome}")
      if gnupghome.nil? || gnupghome.empty?
        warn("No GPG home directory configured, check gpg_gnupghome configuration value is correct")
        raise ArgumentError, "No GPG home directory configured, check gpg_gnupghome configuration value is correct"
      elsif !File.directory?(gnupghome)
        warn("Configured GPG home directory #{gnupghome} doesn't exist, check gpg_gnupghome configuration value is correct")
        raise ArgumentError, "Configured GPG home directory #{gnupghome} doesn't exist, check gpg_gnupghome configuration value is correct"
      else
        gnupghome
      end
    end



    def self.decrypt(ciphertext, gpg_home)
      gnupghome = gpg_home

      GPGME::Engine.home_dir = gnupghome

      ctx = GPGME::Ctx.new
      # Example of how to add support for asking the passphrase
      #  if hiera?
      #   GPGME::Ctx.new
      # else
      #   GPGME::Ctx.new(:passphrase_callback => method(:passfunc))
      # end

      if !ctx.keys.empty?
        raw = GPGME::Data.new(ciphertext)
        txt = GPGME::Data.new

        begin
          txt = ctx.decrypt(raw)
        rescue GPGME::Error::DecryptFailed => e
          warn("Fatal: Failed to decrypt ciphertext (check settings and that you are a recipient)")
          raise e
        rescue Exception => e
          warn("Warning: General exception decrypting GPG file")
          raise e
        end

        txt.seek 0
        txt.read
      else
        raise "No usable keys found in #{gpg_home}.  Things to check: permissions, "\
        "correct paths, file integrity, trying to use an older gpg to read files "\
        "from a newer one (export first).  Some verions of gpg insist on having the "\
        "--gpg-home directory as ~/.gnupg so please try moving your directory of gpg "\
        "stuff to that location"
      end
    end

  end
end
