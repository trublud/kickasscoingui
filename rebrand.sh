#!/bin/bash -e
# This script is an experiment to clone litecoin into a 
# brand new coin + blockchain.
# The script will perform the following steps:
# 1) create first a docker image with ubuntu ready to build and run the new coin daemon
# 2) clone GenesisH0 and mine the genesis blocks of main, test and regtest networks in the container (this may take a lot of time)
# 3) clone litecoin
# 4) replace variables (keys, merkle tree hashes, timestamps..)
# 5) build new coin
# 6) run 4 docker nodes and connect to each other
# 
# By default the script uses the regtest network, which can mine blocks
# instantly. If you wish to switch to the main network, simply change the 
# CHAIN variable below

# change the following variables to match your new coin

COIN_NAME="KickAssCoin"
COIN_UNIT="mKIK"
# 42 million coins at total (litecoin total supply is 84000000)
TOTAL_SUPPLY=42000000
MAINNET_PORT="11976"
TESTNET_PORT="11975"
PHRASE="Noah Collette Jacob Jennifer John"
# First letter of the wallet address. Check https://en.bitcoin.it/wiki/Base58Check_encoding
PUBKEY_CHAR="19"
# number of blocks to wait to be able to spend coinbase UTXO's
COINBASE_MATURITY=5
# leave CHAIN empty for main network, -regtest for regression network and -testnet for test network
CHAIN="-regtest"
# this is the amount of coins to get as a reward of mining the block of height 1. if not set this will default to 50
PREMINED_AMOUNT=1000

# warning: change this to your own pubkey to get the genesis block mining reward
GENESIS_REWARD_PUBKEY=04200d4bc823e20e14d66396a64960c993585400c53f1e6decb273f249bfeba0e71f140ffa7316f2cdaaae574e7d72620538c3e7791ae9861dfe84dd2955fc85e8

# dont change the following variables unless you know what you are doing
LITECOIN_BRANCH=0.16
GENESISHZERO_REPOS=https://github.com/lhartikk/GenesisH0
LITECOIN_REPOS=https://github.com/litecoin-project/litecoin.git
LITECOIN_PUB_KEY=040184710fa689ad5023690c80f3a49c8f13f8d45b8c857fbcbc8bc4a8e4d3eb4b10f4d4604fa08dce601aaf0f470216fe1b51850b4acf21b179c45070ac7b03a9
LITECOIN_MERKLE_HASH=97ddfbbae6be97fd6cdf3e7ca13232a3afff2353e29badfab7f73011edd4ced9
LITECOIN_MAIN_GENESIS_HASH=12a765e31ffd4059bada1e25190f6e98c99d9714d334efa41a195a7e7e04bfe2
LITECOIN_TEST_GENESIS_HASH=4966625a4b2851d9fdee139e56211a0d88575f59ed816ff5e6a63deb4e3e29a0
LITECOIN_REGTEST_GENESIS_HASH=530827f38f93b43ed12af0b3ad25a288dc02ed74d6d7857862df51fc56c416f9
MINIMUM_CHAIN_WORK_MAIN=0x0000000000000000000000000000000000000000000000c1bfe2bbe614f41260
MINIMUM_CHAIN_WORK_TEST=0x000000000000000000000000000000000000000000000000001df7b5aa1700ce
COIN_NAME_LOWER=$(echo $COIN_NAME | tr '[:upper:]' '[:lower:]')
COIN_NAME_UPPER=$(echo $COIN_NAME | tr '[:lower:]' '[:upper:]')
COIN_UNIT_LOWER=$(echo $COIN_UNIT | tr '[:upper:]' '[:lower:]')
DIRNAME=$(dirname $0)
DOCKER_NETWORK="172.18.0"
DOCKER_IMAGE_LABEL="newcoin-env"
OSVERSION="$(uname -s)"


newcoin_replace_vars()
{
 
  

pushd kickasscoin
 
   


    # now replace all litcoin references to the new coin name
    for i in $(find . -type f | grep -v "^./.git"); do

   $SED -i "s/18081/21977/g" $i
        $SED -i "s/28081/31977/g" $i
        $SED -i "s/38081/41977/g" $i
   $SED -i "s/18082/21978/g" $i
        $SED -i "s/28082/31978/g" $i
        $SED -i "s/38082/41978/g" $i
done
popd

    # TODO: fix checkpoints
    
}



if [ $DIRNAME =  "." ]; then
    DIRNAME=$PWD
fi

cd $DIRNAME

# sanity check

case $OSVERSION in
    Linux*)
        SED=sed
    ;;
    Darwin*)
        SED=$(which gsed 2>/dev/null)
        if [ $? -ne 0 ]; then
            echo "please install gnu-sed with 'brew install gnu-sed'"
            exit 1
        fi
        SED=gsed
    ;;
    *)
        echo "This script only works on Linux and MacOS"
        exit 1
    ;;
esac


if ! which docker &>/dev/null; then
    echo Please install docker first
    exit 1
fi

if ! which git &>/dev/null; then
    echo Please install git first
    exit 1
fi

case $1 in
    stop)
        docker_stop_nodes
    ;;
    remove_nodes)
        docker_stop_nodes
        docker_remove_nodes
    ;;
    clean_up)
        docker_stop_nodes
        for i in $(seq 2 5); do
           docker_run_node $i "rm -rf /$COIN_NAME_LOWER /root/.$COIN_NAME_LOWER" &>/dev/null
        done
        docker_remove_nodes
        docker_remove_network
        rm -rf $COIN_NAME_LOWER
        if [ "$2" != "keep_genesis_block" ]; then
            rm -f GenesisH0/${COIN_NAME}-*.txt
        fi
        for i in $(seq 2 5); do
           rm -rf miner$i
        done
    ;;
    start)
  
        newcoin_replace_vars
    
        echo "done"
        exit 1
    ;;
    *)
        cat <<EOF
Usage: $0 (start|stop|remove_nodes|clean_up)
 - start: bootstrap environment, build and run your new coin
 - stop: simply stop the containers without removing them
 - remove_nodes: remove the old docker container images. This will stop them first if necessary.
 - clean_up: WARNING: this will stop and remove docker containers and network, source code, genesis block information and nodes data directory. (to start from scratch)
EOF
    ;;
esac
