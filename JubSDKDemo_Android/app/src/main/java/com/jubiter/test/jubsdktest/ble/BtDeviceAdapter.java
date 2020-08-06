package com.jubiter.test.jubsdktest.ble;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;


import com.jubiter.sdk.R;

import java.util.List;

public class BtDeviceAdapter extends BaseAdapter {

    protected List<FTBTDevice> deviceNameList;
    protected Context mContext;

    public BtDeviceAdapter(Context context, List<FTBTDevice> list) {
        mContext = context;
        deviceNameList = list;
    }

    @Override
    public int getCount() {
        return deviceNameList.size();
    }

    @Override
    public FTBTDevice getItem(int position) {
        return deviceNameList.get(position);
    }

    @Override
    public long getItemId(int arg0) {
        return arg0;
    }

    @Override
    public View getView(final int position, View convertView, ViewGroup parent) {
        MyViewHolder mViewHolder;
        if (convertView == null) {
            convertView = LayoutInflater.from(mContext).inflate(
                    R.layout.device_list_item, parent, false);
            mViewHolder = new MyViewHolder();
            mViewHolder.tv = (TextView) convertView.findViewById(R.id.text_device_name);
            mViewHolder.iv = (ImageView) convertView.findViewById(R.id.img_icon);
            convertView.setTag(mViewHolder);
        } else {
            mViewHolder = (MyViewHolder) convertView.getTag();
        }
        mViewHolder.tv.setText(deviceNameList.get(position).toString());
        mViewHolder.iv.setBackgroundResource(R.drawable.ic_bluetooth_blue_500_24dp);
        return convertView;
    }


    public void addItem(FTBTDevice device) {
        deviceNameList.add(device);
    }

    public class MyViewHolder {
        public TextView tv;
        public ImageView iv;
    }
}
