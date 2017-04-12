#DISPLAY= gpg --homedir gpghome --gen-key --passphrase ''
# just ended up doing gpg --gen-key but with an old version (2.0.22) of gpg on 
# centos 7 AND had to have it generate the keys in the default location at 
# ~/.gnupg as it seems not to work at all when --homedir is specified.  The 
# older versions of gpg can't read the newever version's key format or so it 
# seems which is reasonable...
