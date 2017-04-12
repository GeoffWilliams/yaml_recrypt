# sourced from:  https://github.com/voxpupuli/hiera-eyaml
# file: /hiera/backend/eyaml/encryptors/pkcs7.rb
require 'openssl'
module YamlRecrypt
  module Eyaml

    def self.encrypt(pt, eyaml_pub_key)
      public_key_pem = File.read eyaml_pub_key
      public_key_x509 = OpenSSL::X509::Certificate.new( public_key_pem )

      cipher = OpenSSL::Cipher::AES.new(256, :CBC)
      OpenSSL::PKCS7::encrypt([public_key_x509], pt, cipher, OpenSSL::PKCS7::BINARY).to_der
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
