require "spec_helper"
require "yaml_recrypt/gpg"

RSpec.describe YamlRecrypt::Gpg do
  it "decrypts GPG correctly" do
    pt = File.open(PLAINTEXT_FILE, 'r') { |f| f.read }
    ct = File.open(GPG_ENCRYPTED_FILE, 'r') { |f| f.read }
    
    decrypted = YamlRecrypt::Gpg.decrypt(ct, GPG_HOME)
    expect(decrypted).to eq pt
  end

end
