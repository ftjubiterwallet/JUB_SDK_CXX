//
//  test_trezor_crypto.mm
//  JubSDKCore
//
//  Created by Pan Min on 2019/8/21.
//  Copyright © 2019 JuBiter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JubSDKCore.h"
#import "JubSDKCore+DEV_HID.h"
#import "JubSDKCore+COIN_BTC.h"

#include <iostream>     // std::cout
#include <sstream>      // std::istringstream
#include <string>       // std::string
#include <vector>
#include <map>
#include "mSIGNA/stdutils/uchar_vector.h"
#include "libbitcoin/machine/opcode.hpp"
#include "bitcoin/hash.h"
#include "bitcoin/base58.h"
//#include "bitcoin/bech32.h"
#include "bitcoin/segwit_addr.h"

//#include <TrezorCrypto/address.h>
//#include <TrezorCrypto/aes.h>
//#include <TrezorCrypto/base32.h>
//#include <TrezorCrypto/base58.h>
//#include <TrezorCrypto/ripple/base58.h>
//#include <TrezorCrypto/bignum.h>
//#include <TrezorCrypto/bip32.h>
#include <TrezorCrypto/bip39.h>
//#include <TrezorCrypto/blake2b.h>
//#include <TrezorCrypto/blake256.h>
//#include <TrezorCrypto/cash_addr.h>
#include <TrezorCrypto/curves.h>
//#include <TrezorCrypto/ed25519.h>
//#include <TrezorCrypto/hasher.h>
//#include <TrezorCrypto/hmac.h>
//#include <TrezorCrypto/memzero.h>
//#include <TrezorCrypto/monero/monero.h>
//#include <TrezorCrypto/nem.h>
//#include <TrezorCrypto/nist256p1.h>
//#include <TrezorCrypto/pbkdf2.h>
//#include <TrezorCrypto/rand.h>
//#include <TrezorCrypto/ripemd160.h>
#include <TrezorCrypto/secp256k1.h>
//#include <TrezorCrypto/sha2.h>
//#include <TrezorCrypto/sha3.h>
#include "TrezorCrypto/ecdsa.h"

using namespace std;

//JubSDKCore* g_sdk;

void address_code_test() {
    //legacy: 1JxkR2xGeroewqiWC7shuXAsSrAuFoPonJ
    //        32EbjhDXXF7pVzVExRaN3ZGXbR1UQ9YZmr
    std::string address =     "7jWbzFMvmNPZN6aNK54X3pKbRnBhx7XvtD";//"M8Sk3adVUMyFJVm94JZhsCWvv7bvRyHXri";//"Xrxf9nCM8AWPs2CYhkYpep1d7ZU4Yb1PAA";
    
    uchar_vector vchRet;
    if (!base58::DecodeBase58Check(address, vchRet)) {
        return;
    }
    vchRet.reset_it();
    size_t vchLen = vchRet.size();
    std::cout << "[" << vchLen << "]" << vchRet.getHex() << std::endl;
    uint8_t mainnet = vchRet.read_uint8();
    std::cout << "minnet[" << to_string(mainnet) << "]" << std::endl;
    uchar_vector hash = vchRet.read_vector(vchLen-1);
    std::cout << "[" << hash.size() << "]" << hash.getHex() << std::endl;
    
    //qtum: QeZjXLEyqKgUNyoXcTCC2nxVx77cSnmpcy
    //      M8Sk3adVUMyFJVm94JZhsCWvv7bvRyHXri
    uchar_vector scriptAddress;
    scriptAddress << (unsigned char)0x05;//mainnet;//(unsigned char)0x3a;
    scriptAddress << hash;
    std::string addr = base58::EncodeBase58Check(scriptAddress);
    std::cout << "Qtum base58 address: " << addr << std::endl;
    /*
    //qtum witness: qc1qc5z5rwp0fndz7cwthsset9w8nl7mfuh656anjn
    //              qc1qqhu3a4xhkz67zl0y9dxhkz8fxs2ywfj3aj0hq3
    int witver = 0x00;
    std::string bechAddr = segwit_addr::encode("qc", witver, hash);
    std::cout << "Qtum bech32 address: " << bechAddr << std::endl;*/
}

#define VERSION_PUBLIC  0x0488b21e
#define VERSION_PRIVATE 0x0488ade4

void hdFromXpub() {
    int rv = 0;

    // m/45'/0/0/0: xpub    std::__1::string &    "xpub6Ee2MvBN8nyti9PnL8D2jTke63MKSDK6ykvVedt3Ztjp3Z69uU3teSfHx2Ee1jvSpAkapnDX5FkKLQBoQYMx4CMnBiwwDWcTUAVu8DeHKcN"    0x00007ffeefbfec78
    HDNode hdkey;
    uint32_t parentFingerprint;
//    string deriveRootXpub = "xpub69fZU73sYR4gxkmD7nLTgAWtNyCzJ52yJUD93JjQmzUouvofiTrPtu36keJJaLUSxZRYdiFGG64hFapgUVBvVyNeN6bY1GohX3tPV3gPYGE";
    string deriveRootXpub = "dpubZCbFqsRasq6vpG4Cnd3dx2Zpp7p5YPqRncKgk9ooeb5c9tD6oofBEH9v7C6uSzJXzdXaXMddQ2u1e3darfwXQXrHWAubffWKrDVWGbG34pi";
    rv = hdnode_deserialize(deriveRootXpub.c_str(),
                            VERSION_PUBLIC, VERSION_PRIVATE,
                            SECP256K1_NAME,
                            &hdkey, &parentFingerprint);
    uchar_vector publickey;
    for (int i=0; i<sizeof(hdkey.public_key)/sizeof(uint8_t); ++i) {
        publickey.push_back(hdkey.public_key[i]);
    }
    NSLog(@"public_key: %s\n", publickey.getHex().c_str());
    uchar_vector chaincode;
    for (int i=0; i<sizeof(hdkey.chain_code)/sizeof(uint8_t); ++i) {
        chaincode.push_back(hdkey.chain_code[i]);
    }
    parentFingerprint = hdnode_fingerprint(&hdkey);
    NSLog(@"chain_code: %s\n", chaincode.getHex().c_str());
    NSLog(@"fingerprint: 0x%xl\n", parentFingerprint);

    char xpub[MAX_ADDR_SIZE] = {0,};
    // m/45'
    //xpub    std::__1::string &   "xpub68PwQJExtoyySq2uW3dUm9rptFdvuRanXnqx6ukXoGpQU9bpyoZyYK5uDbMr3kpWpXgT7Vmp9mE822YQYenk7HXn2zLEzaZnSADRVwtpdGA"
    rv = hdnode_serialize_public(&hdkey, parentFingerprint, VERSION_PUBLIC, xpub, MAX_ADDR_SIZE);
    publickey.clear();
    for (int i=0; i<sizeof(hdkey.public_key)/sizeof(uint8_t); ++i) {
        publickey.push_back(hdkey.public_key[i]);
    }
    NSLog(@"public_key: %s\n", publickey.getHex().c_str());
    chaincode.clear();
    for (int i=0; i<sizeof(hdkey.chain_code)/sizeof(uint8_t); ++i) {
        chaincode.push_back(hdkey.chain_code[i]);
    }
    parentFingerprint = hdnode_fingerprint(&hdkey);
    NSLog(@"chain_code: %s\n", chaincode.getHex().c_str());
    NSLog(@"fingerprint: 0x%xl\n", parentFingerprint);
    NSLog(@"[%i] hdnode_serialize_public return: %s\n", rv, xpub);

    // m/45'/0
    //xpub    std::__1::string &    "xpub6ADSVAkxaUyVJq1hLnfVX1zePWQtdWDzkK6QSj4raaLBEeRJzJZRoquq85z9RmCkPm3JefcwNWYujw8391Y3QeZcsFiG2ZQv75ycaBgvwoP"
//    rv = hdnode_private_ckd(&hdkey, 0);
//    hdnode_fill_public_key(&hdkey);
    rv = hdnode_public_ckd(&hdkey, 0);
    memset(xpub, 0x00, MAX_ADDR_SIZE);
    rv = hdnode_serialize_public(&hdkey, parentFingerprint, VERSION_PUBLIC, xpub, MAX_ADDR_SIZE);
    publickey.clear();
    for (int i=0; i<sizeof(hdkey.public_key)/sizeof(uint8_t); ++i) {
        publickey.push_back(hdkey.public_key[i]);
    }
    NSLog(@"public_key: %s\n", publickey.getHex().c_str());
    chaincode.clear();
    for (int i=0; i<sizeof(hdkey.chain_code)/sizeof(uint8_t); ++i) {
        chaincode.push_back(hdkey.chain_code[i]);
    }
    parentFingerprint = hdnode_fingerprint(&hdkey);
    NSLog(@"chain_code: %s\n", chaincode.getHex().c_str());
    NSLog(@"fingerprint: 0x%xl\n", parentFingerprint);
    NSLog(@"[%i] hdnode_serialize_public return: %s\n", rv, xpub);

    // m/45'/0/0
    //xpub    std::__1::string &    "xpub6Bzxt2qXAf8KE69LWr87TSD62bh8oYNGFb7hKcGd2o4WQNp1K7nohihM5aKsmk8iwrV3dhMvqaBZx6aR945NUkhZSzrcNctmSJLLAfySBkz"
//    rv = hdnode_private_ckd(&hdkey, 0);
//    hdnode_fill_public_key(&hdkey);
    rv = hdnode_public_ckd(&hdkey, 0);
    memset(xpub, 0x00, MAX_ADDR_SIZE);
    rv = hdnode_serialize_public(&hdkey, parentFingerprint, VERSION_PUBLIC, xpub, MAX_ADDR_SIZE);
    publickey.clear();
    for (int i=0; i<sizeof(hdkey.public_key)/sizeof(uint8_t); ++i) {
        publickey.push_back(hdkey.public_key[i]);
    }
    NSLog(@"public_key: %s\n", publickey.getHex().c_str());
    chaincode.clear();
    for (int i=0; i<sizeof(hdkey.chain_code)/sizeof(uint8_t); ++i) {
        chaincode.push_back(hdkey.chain_code[i]);
    }
    parentFingerprint = hdnode_fingerprint(&hdkey);
    NSLog(@"chain_code: %s\n", chaincode.getHex().c_str());
    NSLog(@"fingerprint: 0x%xl\n", parentFingerprint);
    NSLog(@"[%i] hdnode_serialize_public return: %s\n", rv, xpub);

    // m/45'/0/0/0
    //xpub    std::__1::string &    "xpub6Ee2MvBN8nyti9PnL8D2jTke63MKSDK6ykvVedt3Ztjp3Z69uU3teSfHx2Ee1jvSpAkapnDX5FkKLQBoQYMx4CMnBiwwDWcTUAVu8DeHKcN"
//    rv = hdnode_private_ckd(&hdkey, 0);
//    hdnode_fill_public_key(&hdkey);
    rv = hdnode_public_ckd(&hdkey, 0);
    memset(xpub, 0x00, MAX_ADDR_SIZE);
    rv = hdnode_serialize_public(&hdkey, parentFingerprint, VERSION_PUBLIC, xpub, MAX_ADDR_SIZE);
    publickey.clear();
    for (int i=0; i<sizeof(hdkey.public_key)/sizeof(uint8_t); ++i) {
        publickey.push_back(hdkey.public_key[i]);
    }
    NSLog(@"public_key: %s\n", publickey.getHex().c_str());
    chaincode.clear();
    for (int i=0; i<sizeof(hdkey.chain_code)/sizeof(uint8_t); ++i) {
        chaincode.push_back(hdkey.chain_code[i]);
    }
    parentFingerprint = hdnode_fingerprint(&hdkey);
    NSLog(@"chain_code: %s\n", chaincode.getHex().c_str());
    NSLog(@"fingerprint: 0x%xl\n", parentFingerprint);
    NSLog(@"[%i] hdnode_serialize_public return: %s\n", rv, xpub);
}
