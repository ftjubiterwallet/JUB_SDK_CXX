#ifndef __HardwareTokenImpl__
#define __HardwareTokenImpl__

#include "JUB_SDK_DEV_BLE.h"
#include <memory>

#include "utility/util.h"

#include "token/interface/TokenInterface.hpp"
#include "device/ApduBuilder.hpp"
#include "device/JubiterHidDevice.hpp"

#ifdef HID_MODE // modify later..
#include "device/JubiterHidDevice.hpp"
using DeviceType = jub::JubiterHidDevice;
#else
#include "device/JubiterBLEDevice.hpp"
using DeviceType = jub::JubiterBLEDevice;
#endif

namespace jub {

constexpr JUB_BYTE kPKIAID_FIDO[8] = {
    0xa0, 0x00,	0x00, 0x06, 0x47, 0x2f, 0x00, 0x01
};

typedef struct _stAppInfos_ {
    abcd::DataChunk appID;
    std::string coinName;
    std::string minimumAppletVersion;
} stAppInfos;

class JubiterBLDImpl :
	public CommonTokenInterface,
	public BTCTokenInterface,
	public ETHTokenInterface
{
public:
    JubiterBLDImpl(std::string path);
    JubiterBLDImpl(DeviceType* device);
    ~JubiterBLDImpl();

public:
    /* functions */
    virtual JUB_RV ConnectToken();
    virtual JUB_RV DisconnectToken();

    //BTC functions
    virtual JUB_RV SelectAppletBTC();
    virtual JUB_RV GetHDNodeBTC(const JUB_BTC_TRANS_TYPE &type, const std::string& path, std::string &xpub);
    virtual JUB_RV GetAddressBTC(const JUB_BTC_TRANS_TYPE &type, const std::string &path, const JUB_UINT16 tag, std::string &address);
    virtual JUB_RV SetUnitBTC(const JUB_BTC_UNIT_TYPE& unit);
    virtual JUB_RV SetCoinTypeBTC(const JUB_ENUM_COINTYPE_BTC& type);
    virtual JUB_RV SignTXBTC(const JUB_BTC_TRANS_TYPE& type,
                             const JUB_UINT16 inputCount,
                             const std::vector<JUB_UINT64>& vInputAmount,
                             const std::vector<std::string>& vInputPath,
                             const std::vector<JUB_UINT16>& vChangeIndex,
                             const std::vector<std::string>& vChangePath,
                             const std::vector<JUB_BYTE>& vUnsigedTrans,
                             std::vector<JUB_BYTE> &vRaw);

    //ETH functions

    virtual JUB_RV SelectAppletETH();
    virtual JUB_RV GetAddressETH(const std::string& path, const JUB_UINT16 tag, std::string& address);
    virtual JUB_RV GetHDNodeETH(const JUB_BYTE format, const std::string& path, std::string& pubkey);
    virtual JUB_RV SignTXETH(const bool bERC20,
                             const std::vector<JUB_BYTE>& vNonce,
                             const std::vector<JUB_BYTE>& vGasPrice,
                             const std::vector<JUB_BYTE>& vGasLimit,
                             const std::vector<JUB_BYTE>& vTo,
                             const std::vector<JUB_BYTE>& vValue,
                             const std::vector<JUB_BYTE>& vData,
                             const std::vector<JUB_BYTE>& vPath,
                             const std::vector<JUB_BYTE>& vChainID,
                             std::vector<JUB_BYTE> &vRaw);
    virtual JUB_RV SetERC20ETHToken(const std::string& tokenName,
                                    const JUB_UINT16 unitDP,
                                    const std::string& contractAddress);

    //common token functions
    virtual JUB_RV QueryBattery(JUB_BYTE &percent);
    virtual JUB_RV ShowVirtualPwd();
    virtual JUB_RV CancelVirtualPwd();
    virtual bool   IsInitialize();
    virtual bool   IsBootLoader();
    virtual JUB_RV GetSN(JUB_BYTE sn[24]);
    virtual JUB_RV GetLabel(JUB_BYTE label[32]);
    virtual JUB_RV GetPinRetry(JUB_BYTE& retry);
    virtual JUB_RV GetPinMaxRetry(JUB_BYTE& maxRetry);
    virtual JUB_RV GetBleVersion(JUB_BYTE bleVersion[4]);
    virtual JUB_RV GetFwVersion(JUB_BYTE fwVersion[4]);

    virtual JUB_RV EnumApplet(std::string& appletList);
    virtual JUB_RV GetAppletVersion(const std::string& appID, std::string& version);
    virtual JUB_RV EnumSupportCoins(std::string& coinList);
    virtual JUB_RV GetDeviceCert(std::string& cert);
    virtual JUB_RV SendOneApdu(const std::string& apdu, std::string& response);

    virtual JUB_RV VerifyPIN(const std::string &pinMix, OUT JUB_ULONG &retry);

    virtual JUB_RV SetTimeout(JUB_UINT16 timeout);

    // get function
    std::string getPath() {
        return _path;
    };

    static stAppInfos g_appInfo[];

private:
    JUB_RV _SelectApp(const JUB_BYTE PKIAID[],
                      JUB_BYTE length);

    JUB_RV _TranPack(const abcd::DataSlice &apduData,
                     JUB_BYTE sigType,
                     JUB_ULONG ulSendOnceLen,
                     int finalData = false,
                     int bOnce = false);

    JUB_RV _SendApdu(const APDU *apdu, JUB_UINT16 &wRet,
                     JUB_BYTE *retData = nullptr, JUB_ULONG *pulRetDataLen = nullptr,
                     JUB_ULONG ulMiliSecondTimeout = 1200000);

    std::shared_ptr<ApduBuilder> _apduBuiler;
    std::shared_ptr<DeviceType> _device;
    std::string _path;
}; // class JubiterBLDImpl end

}  // namespace jub end

#endif  // __HardwareTokenImpl__
