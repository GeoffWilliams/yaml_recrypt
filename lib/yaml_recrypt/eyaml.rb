# sourced from:  https://github.com/voxpupuli/hiera-eyaml
# file: /hiera/backend/eyaml/encryptors/pkcs7.rb
require 'openssl'
require 'base64'
module YamlRecrypt
  module Eyaml

    def self.encrypt(pt, eyaml_pub_key)
      public_key_pem = File.read eyaml_pub_key
      public_key_x509 = OpenSSL::X509::Certificate.new( public_key_pem )

      cipher = OpenSSL::Cipher::AES.new(256, :CBC)
      OpenSSL::PKCS7::encrypt([public_key_x509], pt, cipher, OpenSSL::PKCS7::BINARY).to_der
    end

    def self.encrypt_and_encode(pt, eyaml_pub_key)
      # eyaml has its own YAML encryption standard which we must cludge/copy ;-)
      # basically we wedge the cyphertext inside `ENC[...]` with some metadata
      # see /lib/hiera/backend/eyaml/parser/encrypted_tokens.rb (to_encrypted)
      ct = encrypt(pt, eyaml_pub_key)
      ct64 = Base64.encode64(ct).strip
      return "ENC[PKCS7,#{ct64}]"
    end


    def self.decrypt(ct, eyaml_pub_key, eyaml_prv_key)
      private_key_pem = File.read eyaml_prv_key
      private_key_rsa = OpenSSL::PKey::RSA.new( private_key_pem )

      public_key_pem = File.read eyaml_pub_key
      public_key_x509 = OpenSSL::X509::Certificate.new( public_key_pem )

      pkcs7 = OpenSSL::PKCS7.new( ct )
      pkcs7.decrypt(private_key_rsa, public_key_x509)
    end

  end
end
