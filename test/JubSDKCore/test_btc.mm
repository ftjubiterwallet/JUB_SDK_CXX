//
//  test_btc.mm
//  JubSDKCore
//
//  Created by Pan Min on 2019/8/1.
//  Copyright © 2019 JuBiter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JubSDKCore.h"
#import "JubSDKCore+DEV.h"
#import "JubSDKCore+COIN_BTC.h"

#include <json/json.h>
#include <iostream>     // std::cout
#include <sstream>      // std::istringstream
#include <string>       // std::string
#include <vector>
#include <fstream>

using namespace std;

extern JubSDKCore* g_sdk;

void error_exit(const char* message);
void main_test();

NSUInteger verify_pin(NSUInteger contextID);
void set_timeout_test(NSUInteger contextID);

void     get_address_test(NSUInteger contextID, Json::Value root);
void    show_address_test(NSUInteger contextID);
void     transaction_test(NSUInteger contextID, Json::Value root);
void transactionUSDT_test(NSUInteger contextID, Json::Value root);
void set_my_address_test_BTC(NSUInteger contextID);

void BTC_test(NSUInteger deviceID,
              const char* json_file, JUB_NS_ENUM_COINTYPE_BTC coinType) {
    NSUInteger lastError = JUBR_ERROR;
    
    Json::CharReaderBuilder builder;
    Json::Value root;
    ifstream in(json_file, ios::binary);
    if (!in.is_open()) {
        error_exit("Error opening json file\n");
    }
    
    JSONCPP_STRING errs;
    if (!parseFromStream(builder, in, &root, &errs)) {
        error_exit("Error parse json file\n");
    }
    
    NSUInteger contextID = 0;
    try {
        NSString* mainPath = [NSString stringWithUTF8String:(char*)root["main_path"].asCString()];
        
        JUB_NS_BTC_TRANS_TYPE transType;
        if (root["p2sh-segwit"].asBool()) {
            transType = ns_p2sh_p2wpkh;
        }
        else {
            transType = ns_p2pkh;
        }
        
        switch (transType) {
            case ns_p2sh_p2wpkh:
            case ns_p2pkh:
            {
                ContextConfigBTC* cfgBTC = [[ContextConfigBTC alloc] init];
                cfgBTC.mainPath = mainPath;
                cfgBTC.coinType = coinType;
                cfgBTC.transType = transType;
                contextID = [g_sdk JUB_CreateContextBTC:deviceID
                                                    cfg:cfgBTC];
                break;
            }
            default:
                break;
        }
        
        lastError = (long)[g_sdk JUB_LastError];
        NSLog(@"[%li] JUB_CreateContextBTC(%li)\n", lastError, deviceID);
        if (JUBR_OK != lastError) {
            return ;
        }
        NSLog(@"ContextBTC: %li\n", contextID);
    }
    catch (...) {
        error_exit("Error format json file\n");
    }
    
    while (true) {
        NSLog(@"|----------------------------------|\n");
        NSLog(@"|******* Jubiter Wallet BTC *******|\n");
        NSLog(@"| 1. get_address_test.             |\n");
        NSLog(@"| 2. show_address_test.            |\n");
        NSLog(@"| 3. transaction_test.             |\n");
        NSLog(@"| 4. set_my_address_test.          |\n");
        NSLog(@"| 5. set_timeout_test.             |\n");
        NSLog(@"| 6. multisig_transaction_test.    |\n");
        NSLog(@"|                                  |\n");
        NSLog(@"| 9. return.                       |\n");
        NSLog(@"|----------------------------------|\n");
        NSLog(@"* Please enter your choice:         \n");
        
        int choice = 0;
        std::cin >> choice;
        if (0 == choice) {
            exit(0);
        }
        
        switch (choice) {
            case 1:
                get_address_test(contextID, root);
                break;
            case 2:
                show_address_test(contextID);
                break;
            case 3:
                transaction_test(contextID, root);
                break;
            case 4:
                set_my_address_test_BTC(contextID);
                break;
            case 5:
                set_timeout_test(contextID);
                break;
            case 9:
                main_test();
                break;
            default:
                continue;
        }
    }
}

void USDT_test(NSUInteger deviceID,
               const char* json_file) {
    NSUInteger lastError = JUBR_ERROR;
    
    Json::CharReaderBuilder builder;
    Json::Value root;
    ifstream in(json_file, ios::binary);
    if (!in.is_open()) {
        error_exit("Error opening json file\n");
    }
    JSONCPP_STRING errs;
    if (!parseFromStream(builder, in, &root, &errs)) {
        error_exit("Error parse json file\n");
    }
    
    NSUInteger contextID = 0;
    try {
        NSString* mainPath = [NSString stringWithUTF8String:(char*)root["main_path"].asCString()];
        
        ContextConfigBTC* cfgBTC = [[ContextConfigBTC alloc] init];
        cfgBTC.mainPath = mainPath;
        cfgBTC.coinType = NS_COINUSDT;
        cfgBTC.transType = ns_p2pkh;
        contextID = [g_sdk JUB_CreateContextBTC:deviceID
                                            cfg:cfgBTC];
        lastError = (long)[g_sdk JUB_LastError];
        NSLog(@"[%li] JUB_CreateContextBTC(%li)\n", lastError, deviceID);
        if (JUBR_OK != lastError) {
            return ;
        }
        NSLog(@"ContextBTC: %li\n", contextID);
    }
    catch (...) {
        error_exit("Error format json file\n");
    }
    
    while (true) {
        NSLog(@"|------------------------------|\n");
        NSLog(@"|***** Jubiter Wallet USDT ****|\n");
        NSLog(@"| 1. get_address_test.         |\n");
        NSLog(@"| 2. show_address_test.        |\n");
        NSLog(@"| 3. transaction_test.         |\n");
        NSLog(@"| 4. set_my_address_test.      |\n");
        NSLog(@"| 5. set_timeout_test.         |\n");
        NSLog(@"|                              |\n");
        NSLog(@"| 9. return.                   |\n");
        NSLog(@"|------------------------------|\n");
        NSLog(@"* Please enter your choice:     \n");

        int choice = 0;
        cin >> choice;

        switch (choice) {
            case 1:
                get_address_test(contextID, root);
                break;
            case 2:
                show_address_test(contextID);
                break;
            case 3:
                transactionUSDT_test(contextID, root);
                break;
            case 4:
                set_my_address_test_BTC(contextID);
                break;
            case 5:
                set_timeout_test(contextID);
                break;
            case 9:
                main_test();
            default:
                continue;
        }
    }
}

void get_address_test(NSUInteger contextID, Json::Value root) {
    NSUInteger lastError = JUBR_ERROR;
    
    try {
        NSString *mainXpub = [g_sdk JUB_GetMainHDNodeBTC:contextID];
        lastError = (long)[g_sdk JUB_LastError];
        NSLog(@"[%li] JUB_GetMainHDNodeBTC(%li)\n", lastError, contextID);
        if (JUBR_OK != lastError) {
            return ;
        }
        NSLog(@"main xpub: %@\n", mainXpub);
        
        unsigned int inputNumber = root["inputs"].size();
        for (unsigned int i=0; i<inputNumber; ++i) {
            BIP32Path* path = [[BIP32Path alloc] init];
            bool isChange = root["inputs"][i]["bip32_path"]["change"].asBool();
            if (true == isChange) {
                path.change = BOOL_NS_TRUE;
            }
            else {
                path.change = BOOL_NS_FALSE;
            }
            path.addressIndex = root["inputs"][i]["bip32_path"]["addressIndex"].asInt();
        
            NSString* xpub = [g_sdk JUB_GetHDNodeBTC:contextID
                                                path:path];
            lastError = (long)[g_sdk JUB_LastError];
            NSLog(@"[%li] JUB_GetHDNodeBTC(%li)\n", lastError, contextID);
            if (JUBR_OK != lastError) {
                return ;
            }
            NSLog(@"xpub: %@\n", xpub);
            
            NSString* address = [g_sdk JUB_GetAddressBTC:contextID
                                                    path:path
                                                   bShow:BOOL_NS_FALSE];
            lastError = (long)[g_sdk JUB_LastError];
            NSLog(@"[%li] JUB_GetAddressBTC(%li)\n", lastError, contextID);
            if (JUBR_OK != lastError) {
                return ;
            }
            NSLog(@"address: %@\n", address);
//            
//            NSString* p2shAddress = [g_sdk JUB_GetP2SHMultisigAddressBTC:contextID
//                                                                    path:path
//                                                                   bShow:BOOL_NS_FALSE];
//            lastError = (long)[g_sdk JUB_LastError];
//            NSLog(@"[%li] JUB_GetP2SHMultisigAddressBTC(%li)\n", lastError, contextID);
//            if (JUBR_OK != lastError) {
//                return ;
//            }
//            NSLog(@"address: %@\n", p2shAddress);
        }
    }
    catch (...) {
        error_exit("Error format json file\n");
    }
}

void show_address_test(NSUInteger contextID) {
    NSUInteger lastError = JUBR_ERROR;
    
    NSLog(@"please input change level (non-zero means 1):\n");
    int change = 0;
    std::cin >> change;
    
    NSLog(@"please input index\n");
    unsigned long long index = 0;
    std::cin >> index;
    
    BIP32Path* path = [[BIP32Path alloc] init];
    if (0 == change) {
        path.change = BOOL_NS_FALSE;
    }
    else {
        path.change = BOOL_NS_TRUE;
    }
    path.addressIndex = index;
    
    NSString* address = [g_sdk JUB_GetAddressBTC:contextID
                                            path:path
                                           bShow:BOOL_NS_TRUE];
    lastError = (long)[g_sdk JUB_LastError];
    NSLog(@"[%li] JUB_GetAddressBTC(%li)\n", lastError, contextID);
    if (JUBR_OK != lastError) {
        return ;
    }
    NSLog(@"address: %@\n", address);
}

InputBTC* JSON2InputBTC(int i, Json::Value root) {
    InputBTC* input = [[InputBTC alloc] init];
    
    if (!root["inputs"][i]["multisig"].asBool()) {
        input.type = JUB_NS_SCRIPT_BTC_TYPE::NS_P2PKH;
    }
    else {
//        input.type = JUB_NS_SCRIPT_BTC_TYPE::NS_P2SH_MULTISIG;
    }
    
    input.preHash = [NSString stringWithUTF8String:(char*)root["inputs"][i]["preHash"].asCString()];
    input.preIndex = root["inputs"][i]["preIndex"].asInt();
    if (nil == input.path) {
        input.path = [[BIP32Path alloc] init];
    }
    if (root["inputs"][i]["bip32_path"]["change"].asBool()) {
        input.path.change = BOOL_NS_TRUE;
    }
    else {
        input.path.change = BOOL_NS_FALSE;
    }
    input.path.addressIndex = root["inputs"][i]["bip32_path"]["addressIndex"].asInt();
    input.amount = root["inputs"][i]["amount"].asUInt64();
    
    return input;
}

OutputBTC* JSON2OutputBTC(int i, Json::Value root) {
    OutputBTC* output = [[OutputBTC alloc] init];
    
    if (!root["outputs"][i]["multisig"].asBool()) {
        output.type = JUB_NS_SCRIPT_BTC_TYPE::NS_P2PKH;
    }
    else {
//        output.type = JUB_NS_SCRIPT_BTC_TYPE::NS_P2SH_MULTISIG;
    }
    
    if (nil == output.stdOutput) {
        output.stdOutput = [[StdOutput alloc] init];
    }
    if (nil == output.stdOutput.path) {
        output.stdOutput.path = [[BIP32Path alloc] init];
    }
    output.stdOutput.address = [NSString stringWithUTF8String:(char*)root["outputs"][i]["address"].asCString()];
    output.stdOutput.amount = root["outputs"][i]["amount"].asUInt64();
    if (root["outputs"][i]["change_address"].asBool()) {
        output.stdOutput.isChangeAddress = BOOL_NS_TRUE;
    }
    else {
        output.stdOutput.isChangeAddress = BOOL_NS_FALSE;
    }
    if (root["outputs"][i]["bip32_path"]["change"].asBool()) {
        output.stdOutput.path.change = BOOL_NS_TRUE;
    }
    else {
        output.stdOutput.path.change = BOOL_NS_FALSE;
    }
    
    output.stdOutput.path.addressIndex = root["outputs"][i]["bip32_path"]["addressIndex"].asInt();

    return output;
}

void transaction_test(NSUInteger contextID, Json::Value root) {
    NSUInteger lastError = JUBR_ERROR;
    
    NSLog(@"| Please input BTCunit on JuBiterHID |");
    NSLog(@"|  1: BTC                            |");
    NSLog(@"|  2: cBTC                           |");
    NSLog(@"|  3: mBTC                           |");
    NSLog(@"|  4: uBTC                           |");
    NSLog(@"|  5: Satoshi                        |");
    
    int choice = 0;
    std::cin >> choice;
    if (0 == choice) {
        exit(0);
    }
    
    JUB_NS_BTC_UNIT_TYPE unit = NS_mBTC;
    switch (choice) {
        case 1:
            unit = NS_BTC;
            break;
        case 2:
            unit = NS_cBTC;
            break;
        case 3:
            unit = NS_mBTC;
            break;
        case 4:
            unit = NS_uBTC;
            break;
        case 5:
            unit = NS_Satoshi;
            break;
        default:
            main_test();
            break;
    }
    
    lastError = verify_pin(contextID);
    if (JUBR_OK != lastError) {
        return;
    }
    
    try {
        NSMutableArray *ins = [NSMutableArray array];
        int inputNumber = root["inputs"].size();
        for (int i = 0; i < inputNumber; i++) {
            InputBTC* input = JSON2InputBTC(i, root);
            [ins addObject:input];
        }
        NSArray* inputs = [NSArray arrayWithArray:ins];
        
        NSMutableArray *outs = [NSMutableArray array];
        int outputNumber = root["outputs"].size();
        for (int i = 0; i < outputNumber; i++) {
            OutputBTC* output = JSON2OutputBTC(i, root);
            [outs addObject:output];
        }
        NSArray* outputs = [NSArray arrayWithArray:outs];
        
        [g_sdk JUB_SetUnitBTC:contextID
                         unit:unit];
        lastError = (long)[g_sdk JUB_LastError];
        NSLog(@"[%li] JUB_SetUnitBTC(%li)\n", lastError, contextID);
        if (JUBR_OK != lastError) {
            return ;
        }
        
        NSString* raw = [g_sdk JUB_SignTransactionBTC:contextID
                                           inputArray:inputs
                                          outputArray:outputs
                                             lockTime:0];
        lastError = (long)[g_sdk JUB_LastError];
        NSLog(@"[%li] JUB_SignTransactionBTC(%li)\n", lastError, contextID);
        if (JUBR_USER_CANCEL == lastError) {
            NSLog(@"User cancel the transaction !\n");
            return;
        }
        if (   JUBR_OK != lastError
//            && JUBR_MULTISIG_OK != lastError
            ) {
            return ;
        }
        NSLog(@"JUB_SignTransactionBTC return %@\n", raw);
    }
    catch (...) {
        error_exit("Error format json file\n");
    }
}

void transactionUSDT_test(NSUInteger contextID, Json::Value root) {
    NSUInteger lastError = JUBR_ERROR;
    
    lastError = verify_pin(contextID);
    if (JUBR_OK != lastError) {
        return;
    }
    
    try {
        NSMutableArray *ins = [NSMutableArray array];
        int inputNumber = root["inputs"].size();
        for (int i = 0; i < inputNumber; i++) {
            InputBTC* input = JSON2InputBTC(i, root);
            [ins addObject:input];
        }
        NSArray* inputs = [NSArray arrayWithArray:ins];
        
        NSMutableArray *outs = [NSMutableArray array];
        int outputNumber = root["outputs"].size();
        for (int i = 0; i < outputNumber; i++) {
            OutputBTC* output = JSON2OutputBTC(i, root);
            [outs addObject:output];
        }
        
        NSArray *usdtouts = [g_sdk JUB_BuildUSDTOutputs:contextID
                                                 USDTTo:[NSString stringWithUTF8String:(char*)root["USDT_to"].asCString()]
                                                 amount:root["USDT_amount"].asUInt64()];
        lastError = (long)[g_sdk JUB_LastError];
        NSLog(@"[%li] JUB_BuildUSDTOutputs(%li)\n", lastError, contextID);
        if (JUBR_OK != lastError) {
            return ;
        }
        NSLog(@"USDT output size %li\n", [usdtouts count]);
        
        for (NSUInteger i=0; i<[usdtouts count]; ++i) {
            [outs addObject:usdtouts[i]];
        }
        NSArray* outputs = [NSArray arrayWithArray:outs];
        
        NSString* raw = [g_sdk JUB_SignTransactionBTC:contextID
                                           inputArray:inputs
                                          outputArray:outputs
                                             lockTime:0];
        lastError = (long)[g_sdk JUB_LastError];
        NSLog(@"[%li] JUB_SignTransactionBTC(%li)\n", lastError, contextID);
        if (JUBR_USER_CANCEL == lastError) {
            NSLog(@"User cancel the transaction !\n");
            return;
        }
        if (JUBR_OK != lastError) {
            return ;
        }
        NSLog(@"USDT raw: %@\n", raw);
    }
    catch (...) {
        error_exit("Error format json file\n");
    }
}

void set_my_address_test_BTC(NSUInteger contextID) {
    NSUInteger lastError = JUBR_ERROR;
    
    lastError = verify_pin(contextID);
    if (JUBR_OK != lastError) {
        return;
    }
    
    NSLog(@"please input change level (non-zero means 1):\n");
    int change = 0;
    std::cin >> change;
    
    NSLog(@"please input index:\n");
    unsigned long index = 0;
    std::cin >> index;
    
    BIP32Path* path = [[BIP32Path alloc] init];
    path.change = JUB_NS_ENUM_BOOL(change);
    path.addressIndex = index;
    
    NSString* address = [g_sdk JUB_SetMyAddressBTC:contextID
                                              path:path];
    lastError = (long)[g_sdk JUB_LastError];
    NSLog(@"[%li] JUB_SetMyAddressBTC(%li)\n", lastError, contextID);
    if (JUBR_OK != lastError) {
        return ;
    }
    NSLog(@"set my address is: %@\n", address);
}
