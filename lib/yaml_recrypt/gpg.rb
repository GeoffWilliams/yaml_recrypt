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



    def self.decrypt(ciphertext, gpg_private_key)
      gnupghome = gpg_private_key

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
        warn("No usable keys found in #{gnupghome}. Check :gpg_gnupghome value in hiera.yaml is correct")
        raise ArgumentError, "No usable keys found in #{gnupghome}. Check :gpg_gnupghome value in hiera.yaml is correct"
      end
    end

  end
end
