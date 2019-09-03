//
//  test_eth.mm
//  JubSDKCore
//
//  Created by Pan Min on 2019/8/5.
//  Copyright © 2019 JuBiter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JubSDKCore.h"
#import "JubSDKCore+COIN_ETH.h"

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

void  get_address_pubkey_ETH(NSUInteger contextID);
void    transaction_test_ETH(NSUInteger contextID, Json::Value root);
void   transaction_ERC20_ETH(NSUInteger contextID, Json::Value root);
void set_my_address_test_ETH(NSUInteger contextID);
//void set_ERC20_token_test(NSUInteger contextID, Json::Value root);

void ETH_test(NSUInteger deviceID, const char* json_file) {
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
    
    NSString* mainPath = [NSString stringWithUTF8String:(char*)root["main_path"].asCString()];
    
    ContextConfigETH* cfgETH = [[ContextConfigETH alloc] init];
    cfgETH.mainPath = mainPath;
    cfgETH.chainID = root["chainID"].asInt();
    NSUInteger contextID = [g_sdk JUB_CreateContextETH:deviceID
                                                   cfg:cfgETH];
    lastError = (long)[g_sdk JUB_LastError];
    NSLog(@"[%li] JUB_CreateContextETH(%li)\n", lastError, deviceID);
    if (JUBR_OK != lastError) {
        return ;
    }
    NSLog(@"ContextETH: %li\n", contextID);
    
    while (true) {
        NSLog(@"|----------------------------------|\n");
        NSLog(@"|******* Jubiter Wallet ETH *******|\n");
        NSLog(@"| 1. show_address_pubkey_test.     |\n");
        NSLog(@"| 2. transaction_test.             |\n");
        NSLog(@"| 3. transaction_ERC20_test.       |\n");
        NSLog(@"| 4. set_my_address_test.          |\n");
        NSLog(@"| 5. set_timeout_test.             |\n");
        NSLog(@"| 6. set_ERC20_token_test.         |\n");
        NSLog(@"|                                  |\n");
        NSLog(@"| 9. return.                       |\n");
        NSLog(@"|----------------------------------|\n");
        NSLog(@"* Please enter your choice:         \n");
        
        int choice = 0;
        std::cin >> choice;
        switch (choice) {
            case 1:
                get_address_pubkey_ETH(contextID);
                break;
            case 2:
                transaction_test_ETH(contextID, root);
                break;
            case 3:
                transaction_ERC20_ETH(contextID, root);
                break;
            case 4:
                set_my_address_test_ETH(contextID);
                break;
            case 5:
                set_timeout_test(contextID);
                break;
//            case 6:
//                set_ERC20_token_test(contextID, root);
                break;
            case 9:
                main_test();
            default:
                continue;
        }
    }
}

void get_address_pubkey_ETH(NSUInteger contextID) {
    NSUInteger lastError = JUBR_ERROR;
    
    NSLog(@"please input change level (non-zero means 1):\n");
    int change = 0;
    cin >> change;
    NSLog(@"please input index \n");
    long index = 0;
    cin >> index;
    
    NSString* pubkey = [g_sdk JUB_GetMainHDNodeETH:contextID
                                            format:NS_HEX];
    lastError = (long)[g_sdk JUB_LastError];
    NSLog(@"[%li] JUB_GetMainHDNodeETH(%li)\n", lastError, contextID);
    if (JUBR_OK != lastError) {
        return ;
    }
    NSLog(@"MainXpub in hex format: %@\n", pubkey);
    
    pubkey = [g_sdk JUB_GetMainHDNodeETH:contextID
                                  format:NS_XPUB];
    lastError = (long)[g_sdk JUB_LastError];
    NSLog(@"[%li] JUB_GetMainHDNodeETH(%li)\n", lastError, contextID);
    if (JUBR_OK != lastError) {
        return ;
    }
    NSLog(@"MainXpub in xpub format: %@\n", pubkey);
    
    BIP32Path* path;
    path.change = JUB_NS_ENUM_BOOL(change);
    path.addressIndex = index;
    pubkey = [g_sdk JUB_GetHDNodeETH:contextID
                              format:NS_HEX
                                path:path];
    lastError = (long)[g_sdk JUB_LastError];
    NSLog(@"[%li] JUB_GetHDNodeETH(%li)\n", lastError, contextID);
    if (JUBR_OK != lastError) {
        return ;
    }
    NSLog(@"pubkey in hex format: %@\n", pubkey);
    
    pubkey = [g_sdk JUB_GetHDNodeETH:contextID
                              format:NS_XPUB
                                path:path];
    lastError = (long)[g_sdk JUB_LastError];
    NSLog(@"[%li] JUB_GetHDNodeETH(%li)\n", lastError, contextID);
    if (JUBR_OK != lastError) {
        return ;
    }
    NSLog(@"pubkey in xpub format: %@\n", pubkey);
    
    NSString* address = [g_sdk JUB_GetAddressETH:contextID
                                            path:path
                                           bShow:BOOL_NS_TRUE];
    lastError = (long)[g_sdk JUB_LastError];
    NSLog(@"[%li] JUB_GetAddressETH(%li)\n", lastError, contextID);
    if (JUBR_OK != lastError) {
        return ;
    }
    NSLog(@"address: %@\n", address);
}

void transaction_test_ETH(NSUInteger contextID, Json::Value root) {
    NSUInteger lastError = JUBR_ERROR;
    
    lastError = verify_pin(contextID);
    if (JUBR_OK != lastError) {
        return;
    }
    
    //ETH Test
    BIP32Path* path;
    if (root["ETH"]["bip32_path"]["change"].asBool()) {
        path.change = BOOL_NS_TRUE;
    }
    else {
        path.change = BOOL_NS_FALSE;
    }
    path.addressIndex = root["ETH"]["bip32_path"]["addressIndex"].asUInt();
    
    NSUInteger nonce = root["ETH"]["nonce"].asUInt();//.asDouble();
    NSUInteger gasLimit = root["ETH"]["gasLimit"].asUInt();//.asDouble();
    NSString* gasPriceInWei = [NSString stringWithUTF8String:(char*)root["ETH"]["gasPriceInWei"].asCString()];
    NSString* valueInWei = [NSString stringWithUTF8String:(char*)root["ETH"]["valueInWei"].asCString()];
    NSString* to = [NSString stringWithUTF8String:(char*)root["ETH"]["to"].asCString()];
    NSString* data = [NSString stringWithUTF8String:(char*)root["ETH"]["data"].asCString()];
    NSString* raw = [g_sdk JUB_SignTransactionETH:contextID
                                             path:path
                                            nonce:nonce
                                         gasLimit:gasLimit
                                    gasPriceInWei:gasPriceInWei
                                               to:to
                                       valueInWei:valueInWei
                                            input:data];
    lastError = (long)[g_sdk JUB_LastError];
    NSLog(@"[%li] JUB_SignTransactionETH(%li)\n", lastError, contextID);
    if (JUBR_OK != lastError) {
        return ;
    }
    NSLog(@"raw: %@\n", raw);
}

//ERC-20 Test
void transaction_ERC20_ETH(NSUInteger contextID, Json::Value root) {
    NSUInteger lastError = JUBR_ERROR;
    
    lastError = verify_pin(contextID);
    if (JUBR_OK != lastError) {
        return;
    }
    
    NSString* tokenTo = [NSString stringWithUTF8String:(char*)root["ERC20"]["token_to"].asCString()];
    NSString* tokenValue = [NSString stringWithUTF8String:(char*)root["ERC20"]["token_value"].asCString()];
    NSString* abi = [g_sdk JUB_BuildERC20AbiETH:contextID
                                        tokenTo:tokenTo
                                     tokenValue:tokenValue];
    lastError = (long)[g_sdk JUB_LastError];
    NSLog(@"[%li] JUB_BuildERC20AbiETH(%li)\n", lastError, contextID);
    if (JUBR_OK != lastError) {
        return ;
    }
    NSLog(@"abi: %@\n", abi);
    
    BIP32Path* path;
    if (root["ERC20"]["bip32_path"]["change"].asBool()) {
        path.change = BOOL_NS_TRUE;
    }
    else {
        path.change = BOOL_NS_FALSE;
    }
    path.addressIndex = root["ERC20"]["bip32_path"]["addressIndex"].asUInt();
    
    NSUInteger nonce = root["ERC20"]["nonce"].asUInt();//.asDouble();
    NSUInteger gasLimit = root["ERC20"]["gasLimit"].asUInt();//.asDouble();
    NSString* gasPriceInWei = [NSString stringWithUTF8String:(char*)root["ERC20"]["gasPriceInWei"].asCString()];
    NSString* to = [NSString stringWithUTF8String:(char*)root["ERC20"]["contract_address"].asCString()];
    NSString* raw = [g_sdk JUB_SignTransactionETH:contextID
                                             path:path
                                            nonce:nonce
                                         gasLimit:gasLimit
                                    gasPriceInWei:gasPriceInWei
                                               to:to
                                       valueInWei:@""
                                            input:abi];
    lastError = (long)[g_sdk JUB_LastError];
    NSLog(@"[%li] JUB_SignTransactionETH(%li)\n", lastError, contextID);
    if (JUBR_OK != lastError) {
        return ;
    }
    NSLog(@"raw: %@\n", raw);
}

void set_my_address_test_ETH(NSUInteger contextID) {
    NSUInteger lastError = JUBR_ERROR;
    
    lastError = verify_pin(contextID);
    if (JUBR_OK != lastError) {
        return;
    }
    
    NSLog(@"please input change level (non-zero means 1):\n");
    int change = 0;
    std::cin >> change;
    NSLog(@"please input index:\n");
    long index = 0;
    std::cin >> index;
    
    BIP32Path* path;
    path.change = JUB_NS_ENUM_BOOL(change);
    path.addressIndex = index;
    
    NSString* address = [g_sdk JUB_SetMyAddressETH:contextID
                                              path:path];
    lastError = (long)[g_sdk JUB_LastError];
    NSLog(@"[%li] JUB_SetMyAddressETH(%li)\n", lastError, contextID);
    if (JUBR_OK != lastError) {
        return ;
    }
    NSLog(@"set my address is: %@\n", address);
}
//
//void set_ERC20_token_test(NSUInteger contextID, Json::Value root) {
//    NSUInteger lastError = JUBR_ERROR;
//
//    NSString* tokenName = [NSString stringWithUTF8String:(char*)root["ERC20Token"]["tokenName"].asCString()];
//    NSUInteger dp = root["ERC20Token"]["dp"].asUInt();
//    NSString* contractAddress = [NSString stringWithUTF8String:(char*)root["ERC20Token"]["contract_address"].asCString()];
//
//    [g_sdk JUB_SetERC20ETHToken:contextID
//                      tokenName:tokenName
//                         unitDP:dp
//                contractAddress:contractAddress];
//    lastError = (long)[g_sdk JUB_LastError];
//    NSLog(@"[%li] JUB_SetERC20ETHToken(%li)\n", lastError, contextID);
//}
