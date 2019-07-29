# JUB_SDK_CXX

[![Build Status](https://travis-ci.org/joemccann/dillinger.svg?branch=master)](https://travis-ci.org/joemccann/dillinger)


### Contents
- Description
- Software Dependencies
- License
- Build from source

JUB_SDK_CXX lets you use JuBiter cryptocurrency hardware wallet easily. It provides hardware wallet operation interface for both HID and BLE device. It suports:
  - BTC
  - BCH
  - LTC
  - USDT
  - ETH
  - ERC20-token

# New Features!
  - GetVersion
  - VerifyPIN
  - GetDeviceInfo
  - GetDeviceCert
  - SendOneApdu
  - IsInitialize
  - IsBootLoader
  - SetTimeOut
  - EnumApplets
  - EnumSupportCoins
  - GetAppletVersion

You can also:
  - Operating HID device:
     - ListDevice
     - ConnetDevice
     - DisconnetDevice
  - Operating BLE device:
     - initDevice
     - enumDevices
     - stopEnumDevices
     - connectDevice
     - cancelConnect
     - disconnectDevice
     - isDeviceConnect
     - queryBattery
  - Currency trading related:
     - CreateContextBTC/ETH
     - GetHDNodeBTC/ETH
     - GetMainHDNodeBTC/ETH
     - GetAddressBTC/ETH
     - SetMyAddressBTC/ETH
     - SignTransactionBTC/ETH
     - SetUnitBTC
     - BuildUSDTOutputs
     - BuildERC20AbiETH


### Tech
JUB_SDK_CXX uses a number of open source projects to work properly:

* [bigint-2010.04.30](https://mattmccutchen.net/bigint/bigint-2010.04.30.tar.bz2) - C++ Big Integer Library
* [JsonCpp](https://github.com/open-source-parsers/jsoncpp) - is a C++ library that allows manipulating JSON values, including serialization and deserialization to and from strings.
* [PolarSSL](https://tls.mbed.org/) - now known as mbed TLS, include cryptographic and SSL/TLS capabilities.
* mSIGNA
  * [uchar_vector.h from mSIGNA stdutils](https://github.com/ciphrex/mSIGNA/blob/master/deps/stdutils/src/uchar_vector.h) - Underlying data structure; JuBiter added some code.
* airbitz-core
  * [Data.hpp/cpp from airbitz-core util](https://github.com/EdgeApp/airbitz-core.git) - Underlying data structure; JuBiter added some code.
* panzi
  * [portable_endian.h](https://gist.github.com/panzi/6856583) -   Underlying data structure
* bitcoin
  * [common from Bitcoin Core 0.14.2](https://bitcoindoxygen.art/doge/common_8h_source.html) - Underlying data structure; JuBiter added some code.
  * [byteswap from Bitcoin Core 0.14.2](https://bitcoindoxygen.art/doge/byteswap_8h_source.html) - Underlying data structure
  * hash.h - Bitcoin reference client
  * [bitcoin-base58](https://github.com/bitcoin/bitcoin/tree/master/src)
  * [bech32](https://github.com/bitcoin/bitcoin/tree/master/src)
* libcoinABC
  * [cashaddr](https://github.com/Bitcoin-ABC/bitcoin-abc/tree/master/src) - Bitcoin ABC(Bitcoin Cash)
* libbitcoin
  * [opcode from Bitcoin Core](https://github.com/libbitcoin/libbitcoin) - JuBiter annotated some irrelevant code
* hidapi [v0.7.0](http://www.signal11.us/oss/hidapi/)

And of course Dillinger itself is open source with a [public repository][dill]
 on GitHub.


#### Building for source
For MacOS and Linux, you should install hidapi first.
```sh
$ mkdir build
$ cd build
$ cmake ..
$ make
```
For production release for iOS:
```sh
$ mkdir build
$ cd build
$ cmake .. -G Xcode -DCMAKE_TOOLCHAIN_FILE=../cmake/ios.toolchain.cmake -DPLATFORM=OS64COMBINED
$ cmake --build . --config Release --target
```
or simply proceed
```sh
$ sh ./tools/ios-build
```


### Todos

 - Write MORE Tests
 - Add iOS Demo

License
----

MIT


**Free Software, Hell Yeah!**

[//]: # (These are reference links used in the body of this note and get stripped out when the markdown processor does its job. There is no need to format nicely because it shouldn't be seen. Thanks SO - http://stackoverflow.com/questions/4823468/store-comments-in-markdown-syntax)


   [dill]: <https://github.com/ftjubiterwallet/JUB_SDK_CXX.git>
