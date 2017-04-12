require "spec_helper"
require "yaml_recrypt/gpg"

RSpec.describe YamlRecrypt::Gpg do
  it "decrypts GPG correctly" do
    ct = File.readlines(GPG_ENCRYPTED_FILE).join("\n")
    pt = File.readlines(PLAINTEXT_FILE).join("\n")
    decrypted = YamlRecrypt::Gpg.decrypt(ct, GPG_HOME)
    expect(decrypted).to eq pt
  end

end
