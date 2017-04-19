require "spec_helper"
require "yaml_recrypt"

RSpec.describe YamlRecrypt do
  it "has a version number" do
    expect(YamlRecrypt::VERSION).not_to be nil
  end

  it "detects correct replacement count" do
    raw_data = File.open(MOCK_GPG_HIERADATA_FILE, 'r') { |f| f.read }
    hash_wip  = YAML.load(raw_data)
    gpg_home = GPG_HOME
    eyaml_pub_key = EYAML_PUB_KEY

    r, converted = YamlRecrypt.descend(gpg_home, eyaml_pub_key, hash_wip)
    # should be 3 replacements
    expect(r).to be 3

    # Reprocessing, there should be 0 replacements because we fixed em all...
    r, converted = YamlRecrypt.descend(gpg_home, eyaml_pub_key, hash_wip)
    expect(r).to be 0
  end

  it "works end-to-end and makes backup file" do
    tmpdir = Dir.mktmpdir
    puts tmpdir

    # copy the testcases in
    Dir.glob("#{MOCK_GPG_HIERADATA_TESTCASE}/*") {|f| FileUtils.cp_r File.expand_path(f), tmpdir }
    YamlRecrypt::recrypt_r(tmpdir, GPG_HOME, EYAML_PUB_KEY)

    # Check we have 3 instances of '^ENC'
    file_basename   = File.basename(MOCK_GPG_HIERADATA_FILE)
    target_file     = File.join(tmpdir,'nesting01','gpg.yaml')
    eyaml_instances = File.open(target_file).grep(/ENC\[PKCS7/)

    expect(eyaml_instances.size).to be 3

    # check the backup file was created
    expect(File.exists?("#{target_file}.orig")).to be true

    # FileUtils.rm_rm(tmpdir)
  end

  it "does not alter other embeded GPG messages (public key)" do
    raw_data = File.open(MOCK_GPG_HIERADATA_FILE, 'r') { |f| f.read }
    hash_wip  = YAML.load(raw_data)
    gpg_home = GPG_HOME
    eyaml_pub_key = EYAML_PUB_KEY

    r, converted = YamlRecrypt.descend(gpg_home, eyaml_pub_key, hash_wip)

    cert_asc = File.open(GPG_CERT_FILE, 'r') { |f| f.read }

    # should be the exact same text
    expect(converted["should_be_left_alone"].strip).to eq cert_asc.strip


  end

end
