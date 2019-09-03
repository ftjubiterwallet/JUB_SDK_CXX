#include "JUB_SDK.h"
#include "libBCH/libBCH.hpp"

#include "bitcoin/segwit_addr.h"
#include "machine/opcode.hpp"

namespace jub {

namespace bch {


JUB_RV buildScriptPubFromAddress(const std::string& address, uchar_vector& scriptPub) {

    auto pubkeyDataBit5 = cashaddr::Decode(address);
    abcd::DataChunk pubkeyHash;
    segwit_addr::convertbits<5, 8, false>(pubkeyHash, abcd::DataChunk(pubkeyDataBit5.second.begin(), pubkeyDataBit5.second.end()));

    if (TypeBitsP2PKH == pubkeyHash[0]) { //p2pkh
        scriptPub << libbitcoin::machine::opcode::dup;
        scriptPub << libbitcoin::machine::opcode::hash160;
        scriptPub & uchar_vector(pubkeyHash.begin() + 1, pubkeyHash.end());
        scriptPub << libbitcoin::machine::opcode::equalverify;
        scriptPub << libbitcoin::machine::opcode::checksig;
    }
    else if (TypeBitsP2SH == pubkeyHash[0]) { //p2sh
        scriptPub << libbitcoin::machine::opcode::hash160;
        scriptPub & uchar_vector(pubkeyHash.begin() + 1, pubkeyHash.end());
        scriptPub << libbitcoin::machine::opcode::equal;
    }
    else {
        return JUBR_ERROR;
    }

    return JUBR_OK;
}

JUB_RV serializeUnsignedTx(const JUB_BTC_TRANS_TYPE type,
                           const std::vector<INPUT_BTC>& vInputs,
                           const std::vector<OUTPUT_BTC>& vOutputs,
                           const JUB_UINT32 lockTime,
                           uchar_vector& unsignedRaw) {

    uchar_vector unsignedTrans;
    unsignedTrans << version1;

    //input
    unsignedTrans << (JUB_BYTE)vInputs.size();
    for (auto input : vInputs) {
        //preHash
        uchar_vector preHash = std::string(input.preHash);
        preHash.reverse();
        unsignedTrans << preHash;
        //preIndex
        unsignedTrans << (JUB_UINT32)input.preIndex;
        //sig
        unsignedTrans << (JUB_BYTE)0;
        unsignedTrans << sequence;
    }

    //output
    unsignedTrans << (JUB_BYTE)vOutputs.size();
    for (auto output : vOutputs) {
        switch (output.type) {
        case SCRIPT_BTC_TYPE::P2PKH:
        {
            //amount
            unsignedTrans << (uint64_t)output.stdOutput.amount;
            //script_pub
            uchar_vector scriptPub;
            if (JUBR_OK != buildScriptPubFromAddress(output.stdOutput.address, scriptPub)) {
                return JUBR_ERROR;
            }
            unsignedTrans && scriptPub;
            break;
        } // case SCRIPT_BTC_TYPE::P2PKH end
        case SCRIPT_BTC_TYPE::RETURN0:
        {
            unsignedTrans << (uint64_t)output.return0.amount;
            uchar_vector scriptPub;
            scriptPub << (JUB_BYTE)libbitcoin::machine::opcode::return_; //op_return0
            scriptPub << output.return0.dataLen;
            scriptPub.insert(scriptPub.end(), output.return0.data, output.return0.data + output.return0.dataLen);

            unsignedTrans && scriptPub;
            break;
        } // case SCRIPT_BTC_TYPE::RETURN0 end
        default:
            break;
        } // switch (output.type) end
    }

    unsignedTrans << lockTime;
    unsignedRaw = unsignedTrans;

    return JUBR_OK;
}

} // namespace bch end

} // namespace jub end

