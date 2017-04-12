[![Build Status](https://travis-ci.org/GeoffWilliams/yaml_recrypt.svg?branch=master)](https://travis-ci.org/GeoffWilliams/yaml_recrypt)
# YamlRecrypt

Handy small tool for parsing YAML files and finding the keys that are currently encrypted with [hiera-eyaml-gpg](https://github.com/sihil/hiera-eyaml-gpg/)(not to be confused with [hiera-gpg](https://github.com/crayfishx/hiera-gpg) which encrypts entire yaml fies).  While `hiera-eyaml-gpg` is a cool idea, the complexities of GPG can negate some of its benefits in practice , so this tool was developed to allow conversion to regular eyaml.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'yaml_recrypt'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install yaml_recrypt

## Usage

### Re-encrypting your hiera data
At present, `yaml_recrypt` only offers one mode of operation which is to recursively process files in the current directory, decrypting any `hiera-eyaml-gpg` data and then re-encrypting it with plain hiera-eyaml.

To do this, `yaml_recrypt` needs:
* Some data to decrypt
* Your GPG PKI (directory of gpg keychains, etc - usually at `~/.gpg`)
* Your hiera-eyaml public key (usually at `/etc/puppetlabs/puppet/keys`)

`yaml_recrypt` should not be run inside the `/etc/puppet*` directory to avoid the risk of updating files which are currently in use.  Ideally, data should be copied off the puppet server for rencryption (eg a workstation) as:
* This prevents altering the `gems` installed on the production master
* The conversion can be done in a safe and controlled environment
* Files can be easilty deleted afterwards

A conversion workflow should look something like this:
1.  Obtain the existing hiera data (tar + scp on master or git checkout if your using version control)
2.  Obtain GPG keychain from master (need the entire directory described in the `:gpg_gnupghome:` key in `hiera.yaml`)
3.  Obtain the hiera-eyaml public key from the (new?) master
4.  Run the conversion:
  ```shell
  yaml_recrypt convert --gpg-home gpghome/ --eyaml-pub-key keys/public_key.pkcs7.pem
  ```
  Worked example:
  ```shell
  cd /home/geoff/tmp/hieradata
  yaml_recrypt convert --gpg-home /home/geoff/tmp/gpghome --eyaml-pub-key /home/geoff/tmp/keys/public_key.pkcs7.pem
  ```
5.  Check results and commit changed data back to git
6.  When happy with conversion results, don't forget to remove the old GPG keychain files from your system - it's a security risk, to leave they lying around

## Development and Contributing
There are a few additional things this codebase could be extended to cover if there's interest:
* hiera-gpg (whole file encrypted) to hiera-eyaml
* hiera-eyaml to hiera-eyaml-gpg
* hiera-eyaml to ...something else
* something else... to hiera-eyaml

Bug reports and pull requests are welcome on GitHub at https://github.com/GeoffWilliams/yaml_recrypt.

There are no plans to develop this software beyond its initial capabilities.

## Acknowledgement
Contains adapted sourcecode from:
*  [hiera-eyaml](https://github.com/voxpupuli/hiera-eyaml)
* [hiera-eyaml-gpg](https://github.com/sihil/hiera-eyaml-gpg/)

See the file `LICENCE` for licencing information (MIT)
