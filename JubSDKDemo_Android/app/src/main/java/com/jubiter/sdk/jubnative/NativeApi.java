package com.jubiter.sdk.jubnative;


import com.jubiter.sdk.jubnative.utils.JUB_DEVICE_INFO;

/**
 * Copyright © FEITIAN Technologies Co., Ltd. All Rights Reserved.
 *
 * @Author ZJF
 * @date 2018/3/12
 * @time 13:26
 */

public class NativeApi {

    static {
        System.loadLibrary("coreNDK");
    }

    public static native int nativeGetErrorCode();


    //*********************************** bt *****************************************

    public static native int nativeInitDevice();

    public static native int nativeStartScan(InnerScanCallback scanCallback);

    public static native int nativeStopScan();

    public static native int nativeConnectDevice(String address, int devType, long[] handle, int timeout, InnerDiscCallback discCallback);

    public static native int nativeDisconnect(long deviceHandle);

    public static native int nativeIsConnected(long deviceHandle);

    //tool

    public static native int nativeShowVirtualPwd(long deviceHandle);

    public static native int nativeCancelVirtualPwd(long deviceHandle);

    public static native int nativeVerifyPIN(long deviceHandle, byte[] pin);

    public static native int nativeGetDeviceInfo(JUB_DEVICE_INFO info, long deviceHandle);

    public static native String nativeSendApdu(long deviceHandle, String apduStr);

    public static native String nativeGetDeviceCert(long deviceHandle);

    public static native String nativeEnumApplets(long deviceHandle);

    public static native String nativeGetAppletVersion(long deviceHandle, String appID);

    public static native int nativeSetTimeOut(long deviceHandle, int timeout);

    public static native String nativeEnumSupportCoins(long deviceHandle);

    // btc
    public static native int nativeBTCCreateContext(int[] handle, String json, long deviceHandle);

    public static native String nativeBTCShowAddress(long deviceHandle, int change, int index);

    public static native String nativeBTCSetMyAddress(long deviceHandle, int change, int index);


    public static native String[] nativeBTCGetAddress(long deviceHandle, String json);

    public static native String nativeBTCTransaction(long deviceHandle, String json);


    //eth
    public static native int nativeETHCreateContext(int[] handle, String json, long deviceHandle);

    public static native String nativeETHShowAddress(long deviceHandle, int index);

    public static native String nativeETHSetMyAddress(long deviceHandle, int change, int index);

    public static native String[] nativeETHGetAddress(long deviceHandle, String json);

    public static native String nativeETHTransaction(long deviceHandle, String json);

    public static native String nativeETHERC20Transaction(long deviceHandle, String json);

}
