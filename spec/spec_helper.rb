require "bundler/setup"
require "yaml_recrypt"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

MOCK_GPG_HIERADATA_TESTCASE = 'spec/fixtures/mock_gpg_hieradata'
MOCK_GPG_HIERADATA_FILE = "#{MOCK_GPG_HIERADATA_TESTCASE}/nesting01/gpg.yaml"
GPG_HOME = "spec/fixtures/gpghome"
GPG_ENCRYPTED_FILE='spec/fixtures/plaintext_value.txt.gpg'
PLAINTEXT_FILE='spec/fixtures/plaintext_value.txt'
EYAML_PRV_KEY='spec/fixtures/keys/private_key.pkcs7.pem'
EYAML_PUB_KEY='spec/fixtures/keys/public_key.pkcs7.pem'
