package com.jubiter.sdk.jubnative.utils;

/**
 * Copyright © FEITIAN Technologies Co., Ltd. All Rights Reserved.
 *
 * @Date 2018/5/16  20:35
 * @Author ZJF
 * @Version 1.0
 */
public class JUB_DEVICE_INFO {

    private String label;
    private String sn;
    private int pin_retry;
    private int pin_max_retry;
    private String ble_version;
    private String firmware_version;

    public JUB_DEVICE_INFO() {
    }

    public String getLabel() {
        return label;
    }

    public void setLabel(String label) {
        this.label = label;
    }

    public String getSn() {
        return sn;
    }

    public void setSn(String sn) {
        this.sn = sn;
    }

    public int getPin_retry() {
        return pin_retry;
    }

    public void setPin_retry(int pin_retry) {
        this.pin_retry = pin_retry;
    }

    public int getPin_max_retry() {
        return pin_max_retry;
    }

    public void setPin_max_retry(int pin_max_retry) {
        this.pin_max_retry = pin_max_retry;
    }

    public String getBle_version() {
        return ble_version;
    }

    public void setBle_version(String ble_version) {
        this.ble_version = ble_version;
    }

    public String getFirmware_version() {
        return firmware_version;
    }

    public void setFirmware_version(String firmware_version) {
        this.firmware_version = firmware_version;
    }

    @Override
    public String toString() {
        return "JUB_DEVICE_INFO{" +
                "label='" + label + '\'' +
                ", sn='" + sn + '\'' +
                ", pin_retry=" + pin_retry +
                ", pin_max_retry=" + pin_max_retry +
                ", ble_version='" + ble_version + '\'' +
                ", firmware_version='" + firmware_version + '\'' +
                '}';
    }
}
