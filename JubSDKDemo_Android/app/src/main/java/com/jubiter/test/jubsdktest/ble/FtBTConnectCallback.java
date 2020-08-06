package com.jubiter.test.jubsdktest.ble;

/**
 * Copyright © FEITIAN Technologies Co., Ltd. All Rights Reserved.
 *
 * @Date 2018/1/8  18:36
 * @Author ZJF
 * @Version 1.0
 */

public interface FtBTConnectCallback {

    void connected(FTBTDevice device, int code);

    void disConnected();

}
