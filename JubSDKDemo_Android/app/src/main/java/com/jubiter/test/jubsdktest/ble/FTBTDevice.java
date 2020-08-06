/**
 * 版权所有：(C)飞天诚信科技股份有限公司 
 *  包名称 ： [com.example.btkeycommlib] 
 *  类名称 ： [FTBTDevice]
 *  类描述 ： [一句话描述该类]
 * 其他说明： [附加说明]
 * 作       者： [zhldxy]
 * 完成日期： [2017年3月20日 下午6:39:27]
 * 当前版本： [当前版本号]
 * 修改记录1：修改历史记录，包括修改日期、修改者及修改内容
 *            修改日期：
 *            版 本 号：
 *            修 改 人：
 *            修改内容：改原因以及修改内容说明
 */
package com.jubiter.test.jubsdktest.ble;

import android.os.Parcel;
import android.os.Parcelable;

/**
 * @author zhldxy
 *
 */
public class FTBTDevice implements Parcelable {
	private String devName;
	private String devMac;
	private long handler;
	
	public FTBTDevice(String name, String mac) {
		devName = name;
		devMac = mac;
	}

	protected FTBTDevice(Parcel in) {
		devName = in.readString();
		devMac = in.readString();
		handler = in.readLong();
	}

	public void setHandler(long hdler) {
		handler = hdler;
	}

	public static final Creator<FTBTDevice> CREATOR = new Creator<FTBTDevice>() {
		@Override
		public FTBTDevice createFromParcel(Parcel in) {
			return new FTBTDevice(in);
		}

		@Override
		public FTBTDevice[] newArray(int size) {
			return new FTBTDevice[size];
		}
	};

	@Override
	public int describeContents() {
		return 0;
	}

	@Override
	public void writeToParcel(Parcel dest, int flags) {
		dest.writeString(devName);
		dest.writeString(devMac);
		dest.writeLong(handler);
	}

	public String getMac() {
		return devMac;
	}
	
	public String getName() {
		return devName;
	}

	public void setName(String devName){
		this.devName = devName;
	}

	public long getHandler() {
		return handler;
	}

	@Override
	public boolean equals(Object o) {
		if (o instanceof FTBTDevice) {
			return devMac.equals(((FTBTDevice)o).getMac());
		}
		return false;
	}

	@Override
	public int hashCode() {
		return devMac.hashCode();
	}

	@Override
	public String toString() {
		return devName + "\n" + devMac;
	}
}
