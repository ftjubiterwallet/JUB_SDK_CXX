package com.jubiter.sdk.jubnative;

/**
 * 版权所有：(C)飞天诚信科技股份有限公司
 * 文件名称：InnerScanCallback
 * 文件标识：
 * 内容摘要：内部扫描回调接口
 * 其它说明：其它内容的说明
 * 当前版本：1.0.0
 * 作 者：fs
 * 完成日期：2017/5/17
 **/
public interface InnerScanCallback {

    /**
     * 搜索结果回调
     *
     * @param name 设备名：蓝牙为广播名称、音频为设备序列号
     * @param uuid 设备 MAC 地址（只有蓝牙有）
     * @param devType 设备类型：音频、蓝牙、OTG
     */
    public void onScanResult(String name, String uuid, int devType);

    /**
     * 扫描停止
     */
    public void onStop();

    /**
     *
     * @param errorCode
     */
    public void onError(int errorCode);


}
