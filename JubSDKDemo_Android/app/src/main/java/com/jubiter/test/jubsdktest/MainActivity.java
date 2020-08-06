package com.jubiter.test.jubsdktest;

import android.Manifest;
import android.app.ProgressDialog;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Size;
import androidx.appcompat.app.AppCompatActivity;

import com.jubiter.sdk.R;
import com.jubiter.sdk.jubnative.utils.JUB_DEVICE_INFO;
import com.jubiter.test.jubsdktest.ble.FTBTDevice;
import com.jubiter.test.jubsdktest.ble.FtBTConnectCallback;

import java.util.List;

import pub.devrel.easypermissions.AppSettingsDialog;
import pub.devrel.easypermissions.EasyPermissions;

public class MainActivity extends AppCompatActivity implements EasyPermissions.PermissionCallbacks {

    private Button mBtnScan;
    private TextView mTxtState, mTxtInfo;
    private boolean isConnect = false;
    private long mBtDeviceHandler;
    private JubiterImpl mJubiter;
    private ProgressDialog mDialog;
    private EditText mEditApdu;

    private final static int REQUEST_PERMISSION = 0x1001;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        if (!hasPermissions()) {
            requestPermissions("Permission request", REQUEST_PERMISSION, Manifest.permission.ACCESS_COARSE_LOCATION, Manifest.permission.ACCESS_FINE_LOCATION);
        } else {
            mJubiter = JubiterImpl.getInstance(this);
        }

        mBtnScan = findViewById(R.id.btn_scan);
        mTxtState = findViewById(R.id.text_state);
        mTxtInfo = findViewById(R.id.info_tv);
        mDialog = new ProgressDialog(this);
        mEditApdu = findViewById(R.id.edit_apdu);
    }

    public void onClick(View view) {
        mTxtInfo.setText(null);
        switch (view.getId()) {
            case R.id.btn_scan:
                switchBt();
                break;
            case R.id.btn_get_device_info:
                mDialog.setMessage("通讯中....");
                mDialog.show();
                mJubiter.getDeviceInfo(mBtDeviceHandler, new JubCallback<JUB_DEVICE_INFO, Void>() {
                    @Override
                    public void onSuccess(JUB_DEVICE_INFO info, Void aVoid) {
                        mDialog.dismiss();
                        Log.d("info", info.toString());
                        mTxtInfo.setText(info.toString());
                    }

                    @Override
                    public void onFailed(int errorCode) {
                        mDialog.dismiss();
                        Log.e("ret:", errorCode + "");
                        mTxtInfo.setText("errorCode:" + errorCode);
                    }
                });
                break;
            case R.id.btn_test_getAddress:
                mDialog.setMessage("通讯中....");
                mDialog.show();
                mJubiter.testGetAddress(new JubCallback<String, String>() {
                    @Override
                    public void onSuccess(String s, String s2) {
                        mTxtInfo.append(s + "\t");
                        if (mDialog != null) {
                            mDialog.dismiss();
                        }
                    }

                    @Override
                    public void onFailed(int errorCode) {
                        mDialog.dismiss();
                        Log.e("ret:", errorCode + "");
                        mTxtInfo.setText("errorCode:" + errorCode);
                    }
                });
                break;
            case R.id.btn_test_trans:
                mDialog.setMessage("通讯中....");
                mDialog.show();
                mJubiter.testTrans(new JubCallback<String, Void>() {
                    @Override
                    public void onSuccess(String s, Void aVoid) {
                        mDialog.dismiss();
                        mTxtInfo.setText(s + "\n");
                    }

                    @Override
                    public void onFailed(int errorCode) {
                        mDialog.dismiss();
                        Log.e("ret:", errorCode + "");
                        mTxtInfo.setText("errorCode:" + errorCode);
                    }
                });
                break;
            case R.id.btn_send_apdu:
                String apduStr = mEditApdu.getText().toString().trim().replace(" ", "");
                if (TextUtils.isEmpty(apduStr)) {
                    return;
                }
                mDialog.setMessage("通讯中....");
                mDialog.show();
                mJubiter.sendApdu(mBtDeviceHandler, apduStr, new JubCallback<String, Void>() {
                    @Override
                    public void onSuccess(String s, Void aVoid) {
                        mDialog.dismiss();
                        mTxtInfo.setText(s);
                    }

                    @Override
                    public void onFailed(int errorCode) {
                        mDialog.dismiss();
                        mTxtInfo.setText("sendAPDU failed");
                    }
                });
                break;
        }
    }

    private void switchBt() {
        if (isConnect) {
            mJubiter.disConnectBt(mBtDeviceHandler);
            mBtnScan.setText("连接");
            mTxtInfo.setText(null);
            isConnect = false;
        } else {
            mJubiter.connect(new FtBTConnectCallback() {
                @Override
                public void connected(FTBTDevice device, int code) {
                    if (code == 0) {
                        mTxtState.setText(device.getName() + "\n" + device.getMac());
                        mBtnScan.setText("断开");
                        mBtDeviceHandler = device.getHandler();
                        isConnect = true;
                    } else {
                        mTxtState.setText(String.format("连接失败：0x%x", code) + "\n");
                    }
                }

                @Override
                public void disConnected() {
                    mTxtState.setText("");
                    mBtnScan.setText("连接");
                    isConnect = false;
                }
            });
        }
    }

    public boolean hasPermissions() {
        return EasyPermissions.hasPermissions(this, Manifest.permission.ACCESS_COARSE_LOCATION);
    }

    public void requestPermissions(@NonNull String rationale,
                                   int requestCode, @Size(min = 1) @NonNull String... perms) {
        EasyPermissions.requestPermissions(this, rationale, requestCode, perms);
    }

    @Override
    public void onPermissionsGranted(int requestCode, @NonNull List<String> perms) {
        mJubiter = JubiterImpl.getInstance(this);
    }

    @Override
    public void onPermissionsDenied(int requestCode, @NonNull List<String> perms) {
        if (EasyPermissions.somePermissionPermanentlyDenied(this, perms)) {
            new AppSettingsDialog.Builder(this).build().show();
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        EasyPermissions.onRequestPermissionsResult(requestCode, permissions, grantResults, this);
    }
}
