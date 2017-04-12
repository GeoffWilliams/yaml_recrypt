require "spec_helper"
require "yaml_recrypt"

RSpec.describe YamlRecrypt do
  it "has a version number" do
    expect(YamlRecrypt::VERSION).not_to be nil
  end

  it "detects correct replacement count" do
    hash_wip  = YAML.load(File.readlines(MOCK_GPG_HIERADATA_FILE).join("\n"))
    gpg_home = GPG_HOME
    eyaml_pub_key = EYAML_PUB_KEY

    r, converted = YamlRecrypt.descend(gpg_home, eyaml_pub_key, hash_wip)
    # should be 3 replacements
    expect(r).to be 3

    # Reprocessing, there should be 0 replacements because we fixed em all...
    r, converted = YamlRecrypt.descend(gpg_home, eyaml_pub_key, hash_wip)
    expect(r).to be 0
  end

end
