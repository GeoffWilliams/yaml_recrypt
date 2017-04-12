#for file in gpghome/private*/*.key ; do

#done
DISPLAY= gpg --batch --homedir gpghome -r test@test.test --encrypt plaintext_value.txt
