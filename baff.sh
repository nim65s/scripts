#!/bin/bash

set -e
#set -x

MSMTP_ACCOUNT=gandi

SIGNER=9B1A79065D2F2B806C8A5A1C7D2ACDAF4653CF28
SIGNER=$(gpg --list-keys --with-colon $SIGNER|grep '^pub'|cut -d ':' -f5)
SIGNERPUBFILE=/tmp/baff_signer_pub_${SIGNER}.gpg
SIGNERSECFILE=/tmp/baff_signer_sec_${SIGNER}.gpg

gpg --export $SIGNER > $SIGNERPUBFILE
gpg --export-secret-keys $SIGNER > $SIGNERSECFILE

for key in 7D2ACDAF4653CF28
do
    gpg --recv-keys $key
    KEY=$(gpg --list-keys --with-colon $key|grep '^pub'|cut -d ':' -f5)
    KEYFILE=/tmp/baff_keyfile_${KEY}.gpg
    KEYRING=/tmp/baff_keyring_${KEY}.gpg

    echo
    echo "===== Signing $KEY ====="
    echo

    gpg --export $KEY > $KEYFILE
    gpg --no-default-keyring --keyring $KEYRING --import $KEYFILE $SIGNERPUBFILE $SIGNERSECFILE
    gpg --no-default-keyring --keyring $KEYRING --trusted-key $SIGNER -u $SIGNER --edit-key $KEY minimize save

    NUID=0
    while read uid
    do
        ((NUID++)) || true
        echo "----- uid $NUID: $uid -----"
        gpg --no-default-keyring --keyring $KEYRING --trusted-key $SIGNER -u $SIGNER --edit-key $KEY "uid $NUID" sign save
        gpg --no-default-keyring --keyring $KEYRING --export --armor $KEY > ${KEYFILE}.${NUID}.signed_by.${SIGNER}.asc
        #gpg --no-default-keyring --keyring $KEYRING -r $KEY --encrypt ${KEYFILE}.${NUID}.signed_by.${SIGNER}.asc
        #cat | msmtp -a $MSMTP_ACCOUNT $uid

    done <<< $(gpg --with-colons --fingerprint $KEY|grep '^uid'|grep -v '^uid:r:'|cut -d':' -f10)

    rm $KEYFILE $KEYRING
done

rm $SIGNERPUBFILE $SIGNERSECFILE
