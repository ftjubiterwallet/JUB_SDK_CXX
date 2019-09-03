#pragma once
#ifndef __ContextETH__
#define __ContextETH__

#include "JUB_SDK_ETH.h"

#include <string>
#include <vector>

#include "utility/Singleton.h"
#include "utility/xManager.hpp"

#include "context/Context.h"

#define JUB_CHECK_CONTEXT_ETH(x)                                    \
do {                                                                \
    auto context = jub::ContextManager::GetInstance()->GetOne(x);   \
    JUB_CHECK_NULL(context);                                        \
    const std::type_info& tCtx = typeid(*context);                  \
    const std::type_info& tCtxETH = typeid(jub::ContextETH);        \
    if (tCtx.hash_code() != tCtxETH.hash_code()) {                  \
        return JUBR_ARGUMENTS_BAD;                                  \
    }                                                               \
} while(0)

namespace jub {

class ContextETH : public Context {
public:
    ContextETH(CONTEXT_CONFIG_ETH cfg, JUB_UINT16 deviceID) {
        _mainPath = cfg.mainPath;
        _chainID = cfg.chainID;
        _deviceID = deviceID;
        _timeout = 120 * 2;
    };
    ~ContextETH() {};

    virtual JUB_RV GetAddress(const BIP32_Path& path, const JUB_UINT16 tag, std::string& address);
    virtual JUB_RV SetMyAddress(const BIP32_Path& path, std::string& address);
    virtual JUB_RV GetHDNode(const JUB_BYTE format, const BIP32_Path& path, std::string& pubkey);
    virtual JUB_RV GetMainHDNode(const JUB_BYTE format, std::string& xpub);

    virtual JUB_RV SignTransaction(IN const BIP32_Path& path,
                                   IN const JUB_UINT32 nonce,
                                   IN const JUB_UINT32 gasLimit,
                                   IN const JUB_CHAR_PTR gasPriceInWei,
                                   IN const JUB_CHAR_PTR to,
                                   IN const JUB_CHAR_PTR valueInWei,
                                   IN const JUB_CHAR_PTR input,
                                   OUT std::string& raw);

    virtual JUB_RV BuildERC20Abi(const JUB_CHAR_PTR to, const JUB_CHAR_PTR value, std::string& abi);
    virtual JUB_RV SetERC20ETHToken(const JUB_CHAR_PTR pTokenName,
                                    const JUB_UINT16 unitDP,
                                    const JUB_CHAR_PTR pContractAddress);
    virtual JUB_RV ActiveSelf();

private:
    int _chainID;
}; // class ContextETH end

} // namespace jub end

#endif // #pragma once
