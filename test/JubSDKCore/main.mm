//
//  main.mm
//  JubSDKCore
//
//  Created by Pan Min on 2019/7/31.
//  Copyright © 2019 JuBiter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JubSDKCore.h"
#import "JubSDKCore+DEV_HID.h"
#import "JubSDKCore+COIN_BTC.h"

#include "TrezorCrypto/TrezorCrypto.h"

#include <iostream>     // std::cout
#include <sstream>      // std::istringstream
#include <string>       // std::string
#include <vector>
#include <map>
#include "mSIGNA/stdutils/uchar_vector.h"
#include "utility/util.h"
#include "libbitcoin/machine/opcode.hpp"

#define USE_DEVICE    1

#define TREZOR_CRYPTO 1
#if TREZOR_CRYPTO
#import "test_trezor_crypto.h"
//#import "test_trezor_crypto_mnemonic.h"
#endif // #if TREZOR_CRYPTO

using namespace std;

JubSDKCore* g_sdk;

void get_device_info_test(NSUInteger deviceID);
void   BTC_test(NSUInteger deviceID, const char* json_file, JUB_NS_ENUM_COINTYPE_BTC coinType);
void  USDT_test(NSUInteger deviceID, const char* json_file);
void   ETH_test(NSUInteger deviceID, const char* json_file);
void Hcash_test(NSUInteger deviceID, const char* json_file);
void HcashMultisig_test(NSUInteger deviceID, const char* json_file);

void error_exit(const char* message) {
    
    cout << message << endl;
    cout << "press any key to exit" << endl;
    char str[9] = { 0, };
    cin >> str;
    exit(0);
}

vector<string> split(const string &str, char delim, bool bSkipEmpty = true) {
    
    istringstream iss(str);
    vector<string> elems;
    for (string item; getline(iss, item, delim); ) {
        if (bSkipEmpty && item.empty()) {
            continue;
        }
        else {
            elems.push_back(item);
        }
    }
    
    return elems;
}

#define FROMHEX_MAXLEN 512

const uint8_t *fromhex(const char *str) {
    static uint8_t buf[FROMHEX_MAXLEN];
    size_t len = strlen(str) / 2;
    if (len > FROMHEX_MAXLEN) len = FROMHEX_MAXLEN;
    for (size_t i = 0; i < len; i++) {
        uint8_t c = 0;
        if (str[i * 2] >= '0' && str[i*2] <= '9') c += (str[i * 2] - '0') << 4;
        if ((str[i * 2] & ~0x20) >= 'A' && (str[i*2] & ~0x20) <= 'F') c += (10 + (str[i * 2] & ~0x20) - 'A') << 4;
        if (str[i * 2 + 1] >= '0' && str[i * 2 + 1] <= '9') c += (str[i * 2 + 1] - '0');
        if ((str[i * 2 + 1] & ~0x20) >= 'A' && (str[i * 2 + 1] & ~0x20) <= 'F') c += (10 + (str[i * 2 + 1] & ~0x20) - 'A');
        buf[i] = c;
    }
    return buf;
}

void main_test() {
    if (nil == g_sdk) {
        g_sdk = [[JubSDKCore alloc] init];
    }
    
    NSUInteger lastError = (long)[g_sdk JUB_LastError];
    
    NSString* version = [g_sdk JUB_GetVersion];
    lastError = (long)[g_sdk JUB_LastError];
    NSLog(@"[%li] JUB_GetVersion(void): \n", lastError);
    if (JUBR_OK != lastError) {
        return ;
    }
    NSLog(@"GetVersion: %@\n", version);
    
#if USE_DEVICE
    NSArray* devices = [g_sdk JUB_ListDeviceHid];
    lastError = (long)[g_sdk JUB_LastError];
    NSLog(@"[%li] JUB_ListDeviceHid(void): \n", lastError);
    if (JUBR_OK != lastError) {
        return ;
    }
    NSUInteger deviceCnt = [devices count];
    NSLog(@"Hid Device count: %li\n", deviceCnt);
    
    if (0 == deviceCnt) {
        NSLog(@"No Hid devices...");
        exit(0);
    }
#endif // #if USE_DEVICE
    
    while (true) {
        NSLog(@"|-------------------------------|\n");
        NSLog(@"|***** Jubiter Wallet Test *****|\n");
#if USE_DEVICE
        NSLog(@"|  1. get_device_info_test.     |\n");
        NSLog(@"|  2. send_one_apdu_test.       |\n");
        NSLog(@"|  31. BTC_test.                |\n");
        NSLog(@"|  32. BTC_segwit_test.         |\n");
        NSLog(@"|  33. BTC_mutilsign_test.      |\n");
        NSLog(@"|  4. BCH_test.                 |\n");
        NSLog(@"|  5. LTC_test.                 |\n");
        NSLog(@"|  6. USDT_test.                |\n");
        NSLog(@"|  7. ETH_test & ETC_test.      |\n");
#endif // #if USE_DEVICE
        NSLog(@"|                               |\n");
#if TREZOR_CRYPTO
        NSLog(@"| 91. derive xpub key from xpub.|\n");
        NSLog(@"| 92. redeem script.            |\n");
        NSLog(@"| 93. address code test.        |\n");
        NSLog(@"| 99. hd from mnemonic test.    |\n");
#endif // #if TREZOR_CRYPTO
        NSLog(@"|  0. exit.                     |\n");
        NSLog(@"|-------------------------------|\n");
        NSLog(@"* Please enter your choice:      \n");
  
        int choice = 0;
        std::cin >> choice;
        if (0 == choice) {
            exit(0);
        }
        
#if USE_DEVICE
        NSUInteger deviceID = [devices[0] unsignedIntegerValue];
//        for (NSUInteger i=0; i<deviceCnt; ++i) {
//            [g_sdk JUB_DisconnetDeviceHid:[devices[i] unsignedIntegerValue]];
//        }
        [g_sdk JUB_DisconnetDeviceHid:deviceID];
        
        [g_sdk JUB_ConnetDeviceHid:deviceID];
        lastError = (long)[g_sdk JUB_LastError];
        NSLog(@"[%li] JUB_ConnetDeviceHid(%li)\n", lastError, deviceID);
        if (JUBR_OK != lastError) {
            return;
        }
#endif // #if USE_DEVICE
        
        switch (choice) {
            case 0:
                exit(0);
#if USE_DEVICE
            case 1:
                get_device_info_test(deviceID);
                break;
            case 2:
                break;
            case 31:
                BTC_test(deviceID, "json/testBTC44.json", NS_COINBTC);
                break;
            case 32:
                BTC_test(deviceID, "json/testBTC49.json", NS_COINBTC);
                break;
            case 33:
                BTC_test(deviceID, "json/testBTC45_7-7/testBTC45_7-7-2.json", NS_COINBTC);
                break;
            case 4:
                BTC_test(deviceID, "json/testBCH.json", NS_COINBCH);
                break;
            case 5:
                BTC_test(deviceID, "json/testLTC.json", NS_COINLTC);
                break;
            case 6:
                USDT_test(deviceID, "json/testUSDT.json");
                break;
            case 7:
                ETH_test(deviceID, "json/testETH.json");
                break;
#endif // #if USE_DEVICE
#if TREZOR_CRYPTO
            case 91:
                hdFromXpub();
                break;
            case 93:
                address_code_test();
                break;
#endif // #if TREZOR_CRYPTO
            default:
                continue;
        }
    }
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        main_test();
    }
    return 0;
}
