require "spec_helper"
require "yaml_recrypt/eyaml"

RSpec.describe YamlRecrypt::Eyaml do

  it "encrypts eyaml correctly" do
    pt = File.open(PLAINTEXT_FILE, 'r') { |f| f.read }
    encrypted = YamlRecrypt::Eyaml.encrypt(pt, EYAML_PUB_KEY)

    # test by decrypting the cypertext and checking it matches the original
    decrypted = YamlRecrypt::Eyaml.decrypt(encrypted, EYAML_PUB_KEY, EYAML_PRV_KEY)
    expect(decrypted).to eq pt
  end

end
