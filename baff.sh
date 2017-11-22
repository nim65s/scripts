#!/bin/bash

set -e
set -x

SIGNER=${2:-7D2ACDAF4653CF28}
SIGNERPUBFILE=/tmp/baff_signer_pub_${SIGNER}.gpg
SIGNERSECFILE=/tmp/baff_signer_sec_${SIGNER}.gpg

gpg --export $SIGNER > $SIGNERPUBFILE
gpg --export-secret-keys $SIGNER > $SIGNERSECFILE

KEY=${1:-381A7594}
KEYFILE=/tmp/baff_keyfile_${KEY}.gpg
KEYRING=/tmp/baff_keyring_${KEY}.gpg

gpg --export $KEY > $KEYFILE
gpg --no-default-keyring --keyring $KEYRING --import $KEYFILE $SIGNERPUBFILE $SIGNERSECFILE
gpg --no-default-keyring --keyring $KEYRING --trusted-key $SIGNER -u $SIGNER --sign-key $KEY
gpg --no-default-keyring --keyring $KEYRING --export --armor $KEY > ${KEYFILE}.asc
gpg --no-default-keyring --keyring $KEYRING -r $KEY --encrypt ${KEYFILE}.asc

rm $SIGNERPUBFILE $SIGNERSECFILE $KEYFILE $KEYRING
