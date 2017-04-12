require "spec_helper"
require "yaml_recrypt/postprocess"

RSpec.describe YamlRecrypt::PostProcess do
  it "decrypts GPG correctly" do
    raw_lines = [
      "a:",
      "  secret: |-",
      "    ENC[PKCS7,MIIBiQYJKoZIhvcNAQcDoIIBejCCAXYCAQAxggEhMIIBHQIBADAFMAACAQEw",
      "    DQYJKoZIhvcNAQEBBQAEggEAf/fMWqfuXjn705jK7Y73wyDHGxqIAovgIPBC",
      "    L3iREx+qxFGx7hXRQGjkcc/hGAIMDz5KF48R+uVZkIfv1uLpicMfnlFBrlIX",
      "  myob: |-",
      "    dont_touch_this",
      "    abc",
    ]

    YamlRecrypt::PostProcess.fix_encoding(raw_lines)

    # check we 'fixed' `|-` to be `>` (folding)
    expect(raw_lines[1]).to match />/

    # check we left the `myob` line alone as `|-`
    expect(raw_lines[5]).not_to match />/
  end
end
