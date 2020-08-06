//
// Created by FT on 2018/4/16.
//

#include <jni.h>
#include <logUtils.h>
#include <utils.h>
#include <JUB_SDK.h>
#include <vector>
#include <jsoncpp/include/json/json.h>

// 保存 JavaVM
JavaVM *g_vm = NULL;
int errorCode = 0;

JNIEXPORT jint JNICALL native_getErrorCode(JNIEnv *env, jobject obj) {
    return errorCode;
}



//================================= 蓝牙 ================================================


JNIEXPORT jint JNICALL native_initDevice(JNIEnv *env, jobject obj) {

    DEVICE_INIT_PARAM initParam;
    // 初始化参数转换
    jobjectToInitParam(env, g_vm, &initParam);

    JUB_RV rv = JUB_initDevice(initParam);
    if (rv != JUBR_OK) {
        LOG_ERR("JUB_initDevice ret: %08x", rv);
        return rv;
    }
    return 0;
}

JNIEXPORT jint JNICALL native_startScan(JNIEnv *env, jobject obj, jobject scanCallback) {
    jobject objParam = env->NewGlobalRef(scanCallback);
    setScanCallbackObj(g_vm, objParam);

    JUB_RV rv = JUB_enumDevices();
    if (rv != JUBR_OK) {
        LOG_ERR("JUB_enumDevices rv: %08x", rv);
        return rv;
    }
    return 0;
}

JNIEXPORT jint JNICALL native_stopScan(JNIEnv *env, jobject obj) {
    JUB_RV rv = JUB_stopEnumDevices();
    if (rv != JUBR_OK) {
        LOG_ERR("JUB_stopEnumDevices rv: %08x", rv);
        return rv;
    }
    return 0;
}

JNIEXPORT jint JNICALL
native_connectDevice(JNIEnv *env, jobject obj, jstring address, jint devType, jlongArray handle,
                     jint timeout, jobject disCallback) {
    JUB_BYTE_PTR pAddress = (JUB_BYTE_PTR) (env->GetStringUTFChars(address, NULL));
    JUB_UINT16 *pHandle = reinterpret_cast<JUB_UINT16 *>(env->GetLongArrayElements(handle, NULL));

    jobject objParam = env->NewGlobalRef(disCallback);
    setDiscCallbackObj(g_vm, objParam);

    JUB_RV rv = JUB_connectDevice(pAddress, devType, pHandle, timeout);
    if (rv != JUBR_OK) {
        LOG_ERR("JUB_stopEnumDevices rv: %08x", rv);
        env->ReleaseLongArrayElements(handle, reinterpret_cast<jlong *>(pHandle), 0);
        return rv;
    }
    env->ReleaseLongArrayElements(handle, reinterpret_cast<jlong *>(pHandle), 0);
    return 0;
}



JNIEXPORT jint JNICALL native_disconnectDevice(JNIEnv *env, jobject obj, jlong deviceHandle) {
    JUB_RV rv = JUB_disconnectDevice(deviceHandle);
    if (rv != 0) {
        LOG_ERR("JUB_disconnectDevice rv: %08x", rv);
    }
    return rv;
}


JNIEXPORT jint JNICALL native_isConnectDevice(JNIEnv *env, jobject obj, jlong deviceHandle) {
    JUB_RV rv = JUB_isDeviceConnect(deviceHandle);
    if (rv != 0) {
        LOG_ERR("JUB_isDeviceConnect rv: %08x", rv);
    }
    return rv;
}

JNIEXPORT jint JNICALL native_showVirtualPwd(JNIEnv *env, jobject obj, jlong contextID) {
    JUB_RV rv = JUB_ShowVirtualPwd(contextID);
    if (rv != 0) {
        LOG_ERR("JUB_showVirtualPwd rv: %08x", rv);
    }
    return rv;
}

JNIEXPORT jint JNICALL native_CancelVirtualPwd(JNIEnv *env, jobject obj, jlong contextID) {
    JUB_RV rv = JUB_CancelVirtualPwd(contextID);
    if (rv != JUBR_OK) {
        LOG_ERR("JUB_CancelVirtualPwd rv: %08x", rv);
    }
    return rv;
}

JNIEXPORT jint JNICALL native_verifyPIN(JNIEnv *env, jobject obj, jlong contextID,
                                        jbyteArray jPin) {
    JUB_CHAR_PTR pPin = (JUB_CHAR_PTR) (env->GetByteArrayElements(jPin, FALSE));
    int length = env->GetArrayLength(jPin);

    *(pPin + length) = '\0';

    JUB_ULONG retry;
    JUB_RV ret = JUB_VerifyPIN(contextID, pPin, &retry);
    env->ReleaseByteArrayElements(jPin, (jbyte *) pPin, FALSE);
    return ret;
}

JNIEXPORT jint JNICALL native_GetDeviceInfo(JNIEnv *env, jobject obj,
                                            jobject deviceInfo, jlong deviceHandle) {
    JUB_DEVICE_INFO info;
    JUB_RV rv = JUB_GetDeviceInfo((JUB_UINT16) deviceHandle, &info);
    if (rv == JUBR_OK) {
        jclass clazz = env->GetObjectClass(deviceInfo);
        jmethodID setSN = env->GetMethodID(clazz, "setSn", "(Ljava/lang/String;)V");
        env->CallVoidMethod(deviceInfo, setSN, env->NewStringUTF(info.sn));

        jmethodID setLabel = env->GetMethodID(clazz, "setLabel", "(Ljava/lang/String;)V");
        env->CallVoidMethod(deviceInfo, setLabel, env->NewStringUTF(info.label));

        jmethodID pin_retry = env->GetMethodID(clazz, "setPin_retry", "(I)V");
        env->CallVoidMethod(deviceInfo, pin_retry, info.pinRetry);

        jmethodID pin_max_retry = env->GetMethodID(clazz, "setPin_max_retry", "(I)V");
        env->CallVoidMethod(deviceInfo, pin_max_retry, info.pinMaxRetry);

        char tmpVersion[5] = {0,};
        memcpy(tmpVersion, info.bleVersion, 4);
        jmethodID ble_version = env->GetMethodID(clazz, "setBle_version", "(Ljava/lang/String;)V");
        jstring version = env->NewStringUTF(tmpVersion);
        env->CallVoidMethod(deviceInfo, ble_version, version);

        char tmpFirewareVersion[5] = {0,};
        memcpy(tmpFirewareVersion, info.firmwareVersion, 4);
        jmethodID firmware_version = env->GetMethodID(clazz, "setFirmware_version",
                                                      "(Ljava/lang/String;)V");
        jstring firmware_versionStr = env->NewStringUTF(tmpFirewareVersion);
        env->CallVoidMethod(deviceInfo, firmware_version, firmware_versionStr);
    }
    return rv;
};



JNIEXPORT jstring JNICALL native_sendAPDU(JNIEnv *env, jobject obj, jlong deviceID,
                                          jstring jApdu) {
    JUB_CHAR_PTR pApdu = const_cast<JUB_CHAR_PTR>(env->GetStringUTFChars(jApdu, NULL));
    JUB_CHAR_PTR response = nullptr;
    JUB_RV ret = JUB_SendOneApdu(deviceID, pApdu, &response);
    if (ret == 0) {
        return env->NewStringUTF(response);
    } else {
        return NULL;
    }
}

JNIEXPORT jstring JNICALL native_GetDeviceCert(JNIEnv *env, jobject obj, jlong deviceHandle) {
    JUB_CHAR_PTR cert = NULL;
    JUB_RV rv = JUB_GetDeviceCert((JUB_UINT16) deviceHandle, &cert);
    if (rv == JUBR_OK) {
        jstring result = env->NewStringUTF(cert);
        JUB_FreeMemory(cert);
        return result;
    } else {
        LOG_ERR("JUB_GetDeviceCert error");
        return NULL;
    }
}


JNIEXPORT jstring JNICALL native_EnumApplets(JNIEnv *env, jobject obj, jlong deviceHandle) {

    JUB_CHAR_PTR list = NULL;
    JUB_RV rv = JUB_EnumApplets((JUB_UINT16) deviceHandle, &list);
    if (rv == JUBR_OK) {
        jstring result = env->NewStringUTF(list);
        JUB_FreeMemory(list);
        return result;
    } else {
        LOG_ERR("JUB_EnumApplets error");
        return NULL;
    }
}

JNIEXPORT jstring JNICALL
native_GetAppletVersion(JNIEnv *env, jobject obj, jlong deviceHandle, jstring appID) {
    JUB_CHAR_PTR pAppID = const_cast<JUB_CHAR_PTR>(env->GetStringUTFChars(appID, NULL));
    JUB_CHAR_PTR appVersion = NULL;
    JUB_RV rv = JUB_GetAppletVersion((JUB_UINT16) deviceHandle, pAppID, &appVersion);
    if (rv == JUBR_OK) {
        jstring result = env->NewStringUTF(appVersion);
        JUB_FreeMemory(appVersion);
        return result;
    } else {
        LOG_ERR("JUB_GetAppletVersion error");
        return NULL;
    }
}

JNIEXPORT jint JNICALL native_SetTimeOut(JNIEnv *env, jobject obj, jlong contextID, jint jTimeOut) {
    return static_cast<jint>(JUB_SetTimeOut(static_cast<JUB_UINT16>(contextID),
                                            static_cast<JUB_UINT16>(jTimeOut)));
}

JNIEXPORT jstring JNICALL native_EnumSupportCoins(JNIEnv *env, jobject obj, jlong deviceID) {
    JUB_CHAR_PTR pCoinList = NULL;
    JUB_RV rv = Jub_EnumSupportCoins(deviceID, &pCoinList);
    if (rv != JUBR_OK) {
        LOG_ERR("Jub_EnumSupportCoins rv: %08x", rv);
    }
    jstring coinList = env->NewStringUTF(pCoinList);
    JUB_FreeMemory(pCoinList);
    return coinList;
}

//===================================== BTC ============================================

JNIEXPORT jint JNICALL
native_BTCCreateContext(JNIEnv *env, jobject obj, jintArray jContextId,
                        jstring jJSON,
                        jlong deviceInfo) {

    if (NULL == jJSON) {
        return JUBR_ARGUMENTS_BAD;
    }

    int length = env->GetStringLength(jJSON);
    if (0 == length) {
        errorCode = JUBR_ARGUMENTS_BAD;
        return JUBR_ARGUMENTS_BAD;
    }

    JUB_UINT16 *pContextID = (JUB_UINT16 *) env->GetIntArrayElements(jContextId, NULL);
    JUB_CHAR_PTR pJSON = const_cast<JUB_CHAR_PTR>(env->GetStringUTFChars(jJSON, NULL));

    Json::Reader reader;
    Json::Value root;
    reader.parse(pJSON, root);

    CONTEXT_CONFIG_BTC cfg;
    cfg.mainPath = (char *) root["main_path"].asCString();
    int cointype = root["coin_type"].asInt();
    switch (cointype) {
        case 0x00:
            cfg.coinType = COINBTC;
            break;
        case 0x01:
            cfg.coinType = COINBCH;
            break;
        case 0x02:
            cfg.coinType = COINLTC;
            break;
        case 0x03:
            cfg.coinType = COINUSDT;
            break;
        case 0x04:
            cfg.coinType = COINDASH;
            break;
        default:
            cfg.coinType = COINBTC;
            break;
    }


    JUB_RV rv = JUBR_OK;
    if (COINBCH == cfg.coinType) {
        cfg.transType = p2pkh;
    } else {
        if (root["p2sh_segwit"].asBool()) {
            cfg.transType = p2sh_p2wpkh;
        } else {
            cfg.transType = p2pkh;
        }
    }
    rv = JUB_CreateContextBTC(cfg, deviceInfo, pContextID);

    if (rv != JUBR_OK) {
        LOG_ERR("JUB_CreateContextBTC: %08x", rv);
        errorCode = rv;
    } else {
        LOG_INF("contextID: %d", *pContextID);
    }
    env->ReleaseIntArrayElements(jContextId, (jint *) pContextID, 0);
    return rv;
}

JNIEXPORT jstring JNICALL
native_BTC_ShowAddress(JNIEnv *env, jobject obj, jlong contextID, jint change, jint index) {

    jclass clazz = env->FindClass("java/lang/String");
    if (clazz == NULL) {
        LOG_ERR("clazz == NULL");
        return NULL;
    }

    BIP32_Path path;
    path.change = JUB_ENUM_BOOL(change);
    path.addressIndex = static_cast<JUB_UINT64>(index);

    JUB_CHAR_PTR pAddress = NULL;
    JUB_RV rv = JUB_GetAddressBTC(static_cast<JUB_UINT16>(contextID), path, BOOL_TRUE, &pAddress);
    if (rv != JUBR_OK) {
        LOG_ERR("JUB_GetAddressBTC: %08x", rv);
        errorCode = static_cast<int>(rv);
        return NULL;
    }
    jstring address = env->NewStringUTF(pAddress);
    JUB_FreeMemory(pAddress);
    return address;
}

JNIEXPORT jstring JNICALL
native_BTC_SetMyAddress(JNIEnv *env, jobject obj, jlong contextID, jint change, jint index) {

    jclass clazz = env->FindClass("java/lang/String");
    if (clazz == NULL) {
        LOG_ERR("clazz == NULL");
        return NULL;
    }

    BIP32_Path path;
    path.change = JUB_ENUM_BOOL(change);
    path.addressIndex = static_cast<JUB_UINT64>(index);

    JUB_CHAR_PTR pAddress = NULL;
    JUB_RV rv = JUB_SetMyAddressBTC(static_cast<JUB_UINT16>(contextID), path, &pAddress);
    if (rv != JUBR_OK) {
        LOG_ERR("JUB_SetMyAddressBTC: %08x", rv);
        errorCode = static_cast<int>(rv);
        return NULL;
    }
    jstring address = env->NewStringUTF(pAddress);
    JUB_FreeMemory(pAddress);
    return address;
}

#define BIP32_PATH   "bip32_path"
#define CHANGE       "change"
#define INDEX        "addressIndex"

JNIEXPORT jobjectArray JNICALL
native_BTCGetAddress(JNIEnv *env, jobject obj, jlong contextID, jstring jJSON) {

    jclass clazz = env->FindClass("java/lang/String");
    if (clazz == NULL) {
        LOG_ERR("clazz == NULL");
        return NULL;
    }
    JUB_CHAR_PTR pJSON = const_cast<JUB_CHAR_PTR>(env->GetStringUTFChars(jJSON, FALSE));

    Json::Reader reader;
    Json::Value root;
    reader.parse(pJSON, root);

    int input_number = root[BIP32_PATH].size();
    jobjectArray array = env->NewObjectArray(2 * input_number, clazz, 0);
    for (int i = 0; i < input_number; i++) {
        JUB_CHAR_PTR xpub;

        BIP32_Path path;
        path.change = (JUB_ENUM_BOOL) root[BIP32_PATH][i][CHANGE].asBool();
        path.addressIndex = static_cast<JUB_UINT64>(root[BIP32_PATH][i][INDEX].asInt());

        JUB_RV rv = JUB_GetHDNodeBTC(contextID, path, &xpub);
        if (rv != JUBR_OK) {
            errorCode = rv;
            LOG_ERR("JUB_GetHDNodeBTC: %08x", rv);
            env->SetObjectArrayElement(array, 2 * i, NULL);
            env->SetObjectArrayElement(array, 2 * i + 1, NULL);
        } else {
            jstring jsXpub = env->NewStringUTF(xpub);
            JUB_CHAR_PTR pAddress = NULL;
            rv = JUB_GetAddressBTC(contextID, path, BOOL_FALSE, &pAddress);
            if (rv != JUBR_OK) {
                errorCode = rv;
                LOG_ERR("JUB_GetAddressBTC: %08x", rv);
                env->SetObjectArrayElement(array, 2 * i, jsXpub);
                env->SetObjectArrayElement(array, 2 * i + 1, NULL);
            } else {
                jstring address = env->NewStringUTF(pAddress);
                env->SetObjectArrayElement(array, 2 * i, jsXpub);
                env->SetObjectArrayElement(array, 2 * i + 1, address);
            }
        }
    }
    return array;
}

JNIEXPORT jstring JNICALL
native_BTCTransaction(JNIEnv *env, jobject obj, jlong contextID, jstring jJSON) {

    JUB_CHAR_PTR pJSON = const_cast<JUB_CHAR_PTR>(env->GetStringUTFChars(jJSON, NULL));
    Json::Reader reader;
    Json::Value root;
    reader.parse(pJSON, root);

    std::vector<INPUT_BTC> inputs;
    std::vector<OUTPUT_BTC> outputs;

    int input_number = root["inputs"].size();
    for (int i = 0; i < input_number; i++) {
        INPUT_BTC input;
        // 根据全局变量赋值
        input.type =  P2PKH;
//        input.type = SCRIPT_BTC_TYPE(root[INPUTS][i][MULTISIG].asInt());
        input.preHash = (char *) root["inputs"][i]["preHash"].asCString();
        input.preIndex = static_cast<JUB_UINT16>(root["inputs"][i]["preIndex"].asUInt64());
        input.path.change = (JUB_ENUM_BOOL) root["inputs"][i][BIP32_PATH][CHANGE].asBool();
        input.path.addressIndex = static_cast<JUB_UINT64>(root["inputs"][i][BIP32_PATH][INDEX].asUInt64());
        input.amount = static_cast<JUB_UINT64>(root["inputs"][i]["amount"].asUInt64());
        inputs.push_back(input);
    }

    int output_number = root["outputs"].size();
    for (int i = 0; i < output_number; i++) {
        OUTPUT_BTC output;
        // 根据全局变量赋值
        output.type = P2PKH;
//        output.type = SCRIPT_BTC_TYPE(root[OUTPUTS][i][MULTISIG].asInt());
        output.stdOutput.address = (char *) root["outputs"][i]["address"].asCString();
        output.stdOutput.amount = static_cast<JUB_UINT64>(root["outputs"][i]["amount"].asUInt64());
        output.stdOutput.changeAddress = (JUB_ENUM_BOOL) root["outputs"][i]["change_address"].asBool();
        if (output.stdOutput.changeAddress) {
            output.stdOutput.path.change = (JUB_ENUM_BOOL) root["outputs"][i][BIP32_PATH][CHANGE].asBool();
            output.stdOutput.path.addressIndex = static_cast<JUB_UINT64>(root["outputs"][i][BIP32_PATH][INDEX].asUInt64());
        }
        outputs.push_back(output);
    }

    char *raw = NULL;
    JUB_SetUnitBTC(static_cast<JUB_UINT16>(contextID), BTC);
    JUB_RV rv = JUB_SignTransactionBTC(static_cast<JUB_UINT16>(contextID), &inputs[0],
                                       (JUB_UINT16) inputs.size(),
                                       &outputs[0], (JUB_UINT16) outputs.size(), 0, &raw);

    // JUBR_MULTISIG_OK 表示多重签名结果不完整，需要后续再次签名
    if (rv != JUBR_OK) {
        errorCode = static_cast<int>(rv);
        return NULL;
    }
    errorCode = rv;
    jstring rawString = env->NewStringUTF(raw);
    JUB_FreeMemory(raw);
    return rawString;
}

//==================================== ETH ==========================================

JNIEXPORT jint JNICALL
native_ETHCreateContext(JNIEnv *env, jobject obj, jintArray jContextId, jstring jJSON,
                        jlong deviceInfo) {


    JUB_UINT16 *pContextID = (JUB_UINT16 *) env->GetIntArrayElements(jContextId, NULL);

    JUB_CHAR_PTR pJSON = const_cast<JUB_CHAR_PTR>(env->GetStringUTFChars(jJSON, NULL));

    Json::Reader reader;
    Json::Value root;
    reader.parse(pJSON, root);

    CONTEXT_CONFIG_ETH cfg;
    cfg.mainPath = (char *) root["main_path"].asCString();
    cfg.chainID = root["chainID"].asInt();
    int rv = static_cast<int>(JUB_CreateContextETH(cfg, static_cast<JUB_UINT16>(deviceInfo),
                                                   pContextID));
    if (rv != JUBR_OK) {
        LOG_ERR("JUB_GetAddressETH: %08x", rv);
    } else {
        LOG_INF("JUB_GetAddressETH: %d", *pContextID);
    }
    env->ReleaseIntArrayElements(jContextId, (jint *) pContextID, FALSE);
    return rv;
}


JNIEXPORT jstring JNICALL native_ETH_Transaction(JNIEnv *env, jobject obj, jlong contextID,
                                                 jstring jJSON) {

    JUB_CHAR_PTR pJSON = const_cast<JUB_CHAR_PTR>(env->GetStringUTFChars(jJSON, NULL));

    Json::Reader reader;
    Json::Value root;
    reader.parse(pJSON, root);

    BIP32_Path path;
    path.change = (JUB_ENUM_BOOL) root["ETH"]["bip32_path"]["change"].asBool();
    path.addressIndex = root["ETH"]["bip32_path"]["addressIndex"].asUInt();

    uint32_t nonce = static_cast<uint32_t>(root["ETH"]["nonce"].asDouble());
    uint32_t gasLimit = static_cast<uint32_t>(root["ETH"]["gasLimit"].asDouble());
    char *gasPriceInWei = (char *) root["ETH"]["gasPriceInWei"].asCString();
    char *valueInWei = (char *) root["ETH"]["valueInWei"].asCString();
    char *to = (char *) root["ETH"]["to"].asCString();
    char *data = (char *) root["ETH"]["data"].asCString();

    char *raw = nullptr;
    JUB_RV rv = JUB_SignTransactionETH(static_cast<JUB_UINT16>(contextID), path,
                                       nonce, gasLimit,
                                       gasPriceInWei, to, valueInWei, data, &raw);
    if (rv != JUBR_OK) {
        errorCode = static_cast<int>(rv);
        return NULL;
    }

    jstring rawString = env->NewStringUTF(raw);
    JUB_FreeMemory(raw);
    return rawString;
}


JNIEXPORT jstring JNICALL
native_ETHShowAddress(JNIEnv *env, jobject obj, jlong contextID, jint index) {
    jclass clazz = env->FindClass("java/lang/String");
    if (clazz == NULL) {
        LOG_ERR("clazz == NULL");
        return NULL;
    }

    BIP32_Path path;
    path.change = JUB_ENUM_BOOL(BOOL_FALSE);
    path.addressIndex = static_cast<JUB_UINT64>(index);

    JUB_CHAR_PTR pAddress = NULL;
    JUB_RV rv = JUB_GetAddressETH(static_cast<JUB_UINT16>(contextID), path, BOOL_TRUE, &pAddress);
    if (rv != JUBR_OK) {
        LOG_ERR("JUB_GetAddressBTC: %08x", rv);
        errorCode = static_cast<int>(rv);
        return NULL;
    }
    jstring address = env->NewStringUTF(pAddress);
    JUB_FreeMemory(pAddress);
    return address;
}


JNIEXPORT jobjectArray JNICALL
native_ETHGetAddress(JNIEnv *env, jobject obj, jlong contextID, jstring jJSON) {

#define BIP32_PATH   "bip32_path"
#define CHANGE       "change"
#define INDEX        "addressIndex"

    jclass clazz = env->FindClass("java/lang/String");
    if (clazz == NULL) {
        LOG_ERR("clazz == NULL");
        return NULL;
    }
    JUB_CHAR_PTR pJSON = const_cast<JUB_CHAR_PTR>(env->GetStringUTFChars(jJSON, NULL));

    Json::Reader reader;
    Json::Value root;
    reader.parse(pJSON, root);

    int input_number = root[BIP32_PATH].size();
    jobjectArray array = env->NewObjectArray(2 * input_number, clazz, 0);
    for (int i = 0; i < input_number; i++) {
        JUB_CHAR_PTR xpub;

        BIP32_Path path;
        path.change = (JUB_ENUM_BOOL) root[BIP32_PATH][i][CHANGE].asBool();
        path.addressIndex = static_cast<JUB_UINT64>(root[BIP32_PATH][i][INDEX].asInt());

        JUB_RV rv = JUB_GetHDNodeETH(contextID, XPUB, path, &xpub);
        if (rv != JUBR_OK) {
            LOG_ERR("JUB_GetHDNodeBTC: %08x", rv);
            env->SetObjectArrayElement(array, 2 * i, NULL);
            env->SetObjectArrayElement(array, 2 * i + 1, NULL);
        } else {
            jstring jsXpub = env->NewStringUTF(xpub);
            JUB_CHAR_PTR pAddress = NULL;
            rv = JUB_GetAddressETH(contextID, path, BOOL_FALSE, &pAddress);
            if (rv != JUBR_OK) {
                LOG_ERR("JUB_GetAddressBTC: %08x", rv);
                env->SetObjectArrayElement(array, 2 * i, jsXpub);
                env->SetObjectArrayElement(array, 2 * i + 1, NULL);
            } else {
                jstring address = env->NewStringUTF(pAddress);
                env->SetObjectArrayElement(array, 2 * i, jsXpub);
                env->SetObjectArrayElement(array, 2 * i + 1, address);
            }
        }
    }
    return array;
}

JNIEXPORT jstring JNICALL
native_SetMyAddressETH(JNIEnv *env, jobject obj, jlong contextID, jint index) {

    jclass clazz = env->FindClass("java/lang/String");
    if (clazz == NULL) {
        LOG_ERR("clazz == NULL");
        return NULL;
    }

    BIP32_Path path;
    path.change = JUB_ENUM_BOOL(BOOL_FALSE);
    path.addressIndex = static_cast<JUB_UINT64>(index);

    JUB_CHAR_PTR pAddress = NULL;
    JUB_RV rv = JUB_SetMyAddressETH(static_cast<JUB_UINT16>(contextID), path, &pAddress);
    if (rv != JUBR_OK) {
        LOG_ERR("JUB_SetMyAddressETH: %08x", rv);
        errorCode = static_cast<int>(rv);
        return NULL;
    }
    jstring address = env->NewStringUTF(pAddress);
    JUB_FreeMemory(pAddress);
    return address;
}

JNIEXPORT jstring JNICALL native_ETH_ERC20_Transaction(JNIEnv *env, jobject obj, jlong contextID,
                                                       jstring jJSON) {

    JUB_CHAR_PTR pJSON = const_cast<JUB_CHAR_PTR>(env->GetStringUTFChars(jJSON, NULL));

    Json::Reader reader;
    Json::Value root;
    reader.parse(pJSON, root);

    uint32_t nonce = root["ERC20"]["nonce"].asDouble();
    uint32_t gasLimit = root["ERC20"]["gasLimit"].asDouble();
    char *gasPriceInWei = (char *) root["ERC20"]["gasPriceInWei"].asCString();
    char *to = (char *) root["ERC20"]["contract_address"].asCString();
    char *token_to = (char *) root["ERC20"]["token_to"].asCString();
    char *token_value = (char *) root["ERC20"]["token_value"].asCString();

    BIP32_Path path;
    path.change = (JUB_ENUM_BOOL) root["ERC20"]["bip32_path"]["change"].asBool();
    path.addressIndex = root["ERC20"]["bip32_path"]["addressIndex"].asUInt();

    char *tokenName = (char *) root["ERC20Token"]["tokenName"].asCString();
    uint16_t unitDP = root["ERC20Token"]["dp"].asDouble();
    char *contractAddress = (char *) root["ERC20Token"]["contract_address"].asCString();


    char *abi = nullptr;
    JUB_RV rv = JUB_BuildERC20AbiETH(contextID, tokenName, unitDP, contractAddress, token_to,
                                     token_value, &abi);
    if (rv != JUBR_OK) {
        LOG_ERR("JUB_BuildERC20AbiETH: %08x", rv);
        env->ReleaseStringUTFChars(jJSON, pJSON);
        return NULL;
    }

    char *raw = nullptr;
    rv = JUB_SignTransactionETH(contextID, path, nonce, gasLimit, gasPriceInWei, to, 0, abi, &raw);

    JUB_FreeMemory(abi);
    if (rv != JUBR_OK) {
        errorCode = static_cast<int>(rv);
        return NULL;
    }

    jstring rawString = env->NewStringUTF(raw);
    JUB_FreeMemory(raw);
    return rawString;
}

/**
 * JNINativeMethod由三部分组成:
 * (1)Java中的函数名;
 * (2)函数签名,格式为(输入参数类型)返回值类型;
 * (3)native函数名
 */
static JNINativeMethod gMethods[] = {

        {
                "nativeGetErrorCode",
                "()I",
                (void *) native_getErrorCode
        },
        {
                "nativeInitDevice",
                "()I",
                (void *) native_initDevice
        },
        {
                "nativeStartScan",
                "(Lcom/jubiter/sdk/jubnative/InnerScanCallback;)I",
                (void *) native_startScan
        },
        {
                "nativeStopScan",
                "()I",
                (void *) native_stopScan
        },
        {
                "nativeConnectDevice",
                "(Ljava/lang/String;I[JILcom/jubiter/sdk/jubnative/InnerDiscCallback;)I",
                (void *) native_connectDevice
        },
        {
                "nativeDisconnect",
                "(J)I",
                (void *) native_disconnectDevice
        },
        {
                "nativeIsConnected",
                "(J)I",
                (void *) native_isConnectDevice
        },
        {
                "nativeShowVirtualPwd",
                "(J)I",
                (void *) native_showVirtualPwd
        },
        {
                "nativeCancelVirtualPwd",
                "(J)I",
                (void *) native_CancelVirtualPwd
        },
        {
                "nativeVerifyPIN",
                "(J[B)I",
                (void *) native_verifyPIN
        },
        {
                "nativeGetDeviceInfo",
                "(Lcom/jubiter/sdk/jubnative/utils/JUB_DEVICE_INFO;J)I",
                (void *) native_GetDeviceInfo
        },
        {
                "nativeSendApdu",
                "(JLjava/lang/String;)Ljava/lang/String;",
                (void *) native_sendAPDU
        },
        {
                "nativeGetDeviceCert",
                "(J)Ljava/lang/String;",
                (void *) native_GetDeviceCert
        },
        {
                "nativeEnumApplets",
                "(J)Ljava/lang/String;",
                (void *) native_EnumApplets
        },
        {
                "nativeGetAppletVersion",
                "(JLjava/lang/String;)Ljava/lang/String;",
                (void *) native_GetAppletVersion
        },
        {
                "nativeSetTimeOut",
                "(JI)I",
                (void *) native_SetTimeOut
        },
        {
                "nativeEnumSupportCoins",
                "(J)Ljava/lang/String;",
                (void *) native_EnumSupportCoins
        },
        {
                "nativeBTCCreateContext",
                "([ILjava/lang/String;J)I",
                (void *) native_BTCCreateContext
        },
        {
                "nativeBTCGetAddress",
                "(JLjava/lang/String;)[Ljava/lang/String;",
                (void *) native_BTCGetAddress
        },
        {
                "nativeBTCShowAddress",
                "(JII)Ljava/lang/String;",
                (void *) native_BTC_ShowAddress
        },
        {
                "nativeBTCSetMyAddress",
                "(JII)Ljava/lang/String;",
                (void *) native_BTC_SetMyAddress
        },
        {
                "nativeSetTimeOut",
                "(JI)I",
                (void *) native_SetTimeOut
        },
        {
                "nativeBTCTransaction",
                "(JLjava/lang/String;)Ljava/lang/String;",
                (void *) native_BTCTransaction
        },
        {
                "nativeETHCreateContext",
                "([ILjava/lang/String;J)I",
                (void *) native_ETHCreateContext
        },
        {
                "nativeETHTransaction",
                "(JLjava/lang/String;)Ljava/lang/String;",
                (void *) native_ETH_Transaction
        },
        {
                "nativeETHERC20Transaction",
                "(JLjava/lang/String;)Ljava/lang/String;",
                (void *) native_ETH_ERC20_Transaction
        },
        {
                "nativeETHShowAddress",
                "(JI)Ljava/lang/String;",
                (void *) native_ETHShowAddress
        },
        {
                "nativeETHSetMyAddress",
                "(JII)Ljava/lang/String;",
                (void *) native_SetMyAddressETH
        },
        {
                "nativeETHGetAddress",
                "(JLjava/lang/String;)[Ljava/lang/String;",
                (void *) native_ETHGetAddress
        },

};


#define NATIVE_API_CLASS "com/jubiter/sdk/jubnative/NativeApi"

/**
 * JNI_OnLoad 默认会在 System.loadLibrary 过程中自动调用到，因而可利用此函数，进行动态注册
 * JNI 版本的返回视对应 JDK 版本而定
 */
JNIEXPORT jint JNICALL JNI_OnLoad(JavaVM *vm, void *reserved) {
    JNIEnv *env = NULL;
    jint ret = JNI_FALSE;

    // 获取 env 指针
    if (vm->GetEnv((void **) &env, JNI_VERSION_1_6) != JNI_OK) {
        return ret;
    }

    // 保存全局 JVM 以便在动态注册的皆空中使用 env 环境
    env->GetJavaVM(&g_vm);

    // 获取类引用
    jclass clazz = env->FindClass(NATIVE_API_CLASS);
    if (clazz == NULL) {
        return ret;
    }

    // 注册 JNI 方法
    if (env->RegisterNatives(clazz, gMethods, sizeof(gMethods) / sizeof(gMethods[0])) < JNI_OK) {
        return ret;
    }
    // 成功
    return JNI_VERSION_1_6;
}