package com.jubiter.test.jubsdktest;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import android.util.Log;

import com.jubiter.sdk.jubnative.NativeApi;
import com.jubiter.sdk.jubnative.utils.JUB_DEVICE_INFO;
import com.jubiter.test.jubsdktest.ble.BluetoothKeyApi;
import com.jubiter.test.jubsdktest.ble.FTBTDevice;
import com.jubiter.test.jubsdktest.ble.FtBTConnectCallback;


/**
 * @Date 2018/4/19  11:30
 * @Author ZJF
 * @Version 1.0
 */
public class JubiterImpl {

    private Context mContext;
    private BluetoothKeyApi mBluetoothKeyApi;

    private Handler mUIHandler = new Handler(Looper.getMainLooper());
    private long deviceHandle;

    private JubiterImpl(Context context) {
        mContext = context;
        mBluetoothKeyApi = new BluetoothKeyApi(mContext);
    }

    private static JubiterImpl fidoApdu;

    public static JubiterImpl getInstance(Context context) {
        if (fidoApdu == null) {
            fidoApdu = new JubiterImpl(context);
        }

        return fidoApdu;
    }

    public void connect(final FtBTConnectCallback connectCallback) {
        mBluetoothKeyApi.connect(new FtBTConnectCallback() {
            @Override
            public void connected(final FTBTDevice device, int code) {
                new Thread(new Runnable() {
                    @Override
                    public void run() {
                        if (device == null) {
                            return;
                        }
                        deviceHandle = device.getHandler();
                    }
                }).start();
                connectCallback.connected(device, code);
            }

            @Override
            public void disConnected() {
                connectCallback.disConnected();
            }
        });
    }

    public int disConnectBt(long handler) {
        return mBluetoothKeyApi.disConnect(handler);
    }

    public void getDeviceInfo(final long bleHandle, final JubCallback<JUB_DEVICE_INFO, Void> callback) {
        new Thread(new Runnable() {
            @Override
            public void run() {

                final int rv = NativeApi.nativeIsConnected(bleHandle);
                if (rv != 0) {
                    mUIHandler.post(new Runnable() {
                        @Override
                        public void run() {
                            callback.onFailed(rv);
                        }
                    });
                    return;
                }

                final JUB_DEVICE_INFO info = new JUB_DEVICE_INFO();
                final int ret = NativeApi.nativeGetDeviceInfo(info, bleHandle);
                if (ret != 0) {
                    mUIHandler.post(new Runnable() {
                        @Override
                        public void run() {
                            callback.onFailed(ret);
                        }
                    });

                } else {
                    mUIHandler.post(new Runnable() {
                        @Override
                        public void run() {
                            callback.onSuccess(info, null);
                        }
                    });
                }
            }
        }).start();
    }


    public void testGetAddress(final JubCallback<String, String> callback) {
        new Thread(new Runnable() {
            @Override
            public void run() {

                int[] contextIDs = new int[1];
                int rv = NativeApi.nativeBTCCreateContext(contextIDs,
                        JSONParseUtils.getJsonStr(mContext, "testBTC44.json"),
                        deviceHandle);
                if (rv != 0) {
                    final int finalRet = NativeApi.nativeGetErrorCode();
                    mUIHandler.post(new Runnable() {
                        @Override
                        public void run() {
                            callback.onFailed(finalRet);
                        }
                    });
                    return;
                }

                long contextID = contextIDs[0];
                String[] array = NativeApi.nativeBTCGetAddress(contextID, JSONParseUtils.getJsonStr(mContext, "path.json"));
                if (array == null || array.length == 0) {
                    final int finalRet = NativeApi.nativeGetErrorCode();
                    mUIHandler.post(new Runnable() {
                        @Override
                        public void run() {
                            callback.onFailed(finalRet);
                        }
                    });
                    return;
                }

                final StringBuilder builder = new StringBuilder();

                for (int i = 0; i < array.length; i += 2) {
                    builder.append("\n\n xpub: \n").append(array[i])
                            .append("\n\n address: \n").append(array[i + 1]);
                }

                mUIHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        callback.onSuccess(builder.toString(), null);
                    }
                });

            }
        }).start();
    }


    public void testTrans(final JubCallback<String, Void> callback) {
        new Thread(new Runnable() {
            @Override
            public void run() {
                int[] contextIDs = new int[1];
                NativeApi.nativeBTCCreateContext(contextIDs,
                        JSONParseUtils.getJsonStr(mContext, "testBTC44.json"),
                        deviceHandle);
                final long contextID = contextIDs[0];

                Log.d("btcTrans contextID:", " " + contextID);
                int ret = NativeApi.nativeShowVirtualPwd(contextID);
                if (ret != 0) {
                    final int finalRet = ret;
                    mUIHandler.post(new Runnable() {
                        @Override
                        public void run() {
                            callback.onFailed(finalRet);
                        }
                    });
                    return;
                }

                mUIHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        final VerifyPinDialog dialog = new VerifyPinDialog(mContext, new VerifyPinDialog.callback() {
                            @Override
                            public void onClickListener(String pin) {
                                int ret = 0;
                                if (TextUtils.isEmpty(pin) || pin.length() != 4) {
                                    final int finalRet = ret;
                                    mUIHandler.post(new Runnable() {
                                        @Override
                                        public void run() {
                                            callback.onFailed(finalRet);
                                        }
                                    });
                                    return;
                                }

                                ret = NativeApi.nativeVerifyPIN(contextID, pin.getBytes());
                                if (ret != 0) {
                                    final int finalRet = ret;
                                    mUIHandler.post(new Runnable() {
                                        @Override
                                        public void run() {
                                            callback.onFailed(finalRet);
                                        }
                                    });
                                    return;
                                }
                                final String signRaw = NativeApi.nativeBTCTransaction(contextID, JSONParseUtils.getJsonStr(mContext, "testBTC44.json"));
                                if (TextUtils.isEmpty(signRaw)) {
                                    mUIHandler.post(new Runnable() {
                                        @Override
                                        public void run() {
                                            callback.onFailed(NativeApi.nativeGetErrorCode());
                                        }
                                    });
                                    return;
                                }
                                Log.d("Raw:",signRaw);
                                mUIHandler.post(new Runnable() {
                                    @Override
                                    public void run() {
                                        callback.onSuccess(signRaw, null);
                                    }
                                });
                            }
                        });
                        dialog.show();
                    }
                });

            }
        }).start();
    }

    public void sendApdu(final long bleHandle, final String apdu, final JubCallback<String, Void> callback) {
        Log.d("sendAPDU", apdu);
        new Thread(new Runnable() {
            @Override
            public void run() {
                final String result = NativeApi.nativeSendApdu(bleHandle, apdu);
                mUIHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        if (TextUtils.isEmpty(result)) {
                            callback.onFailed(-1);
                        } else {
                            callback.onSuccess(result, null);
                        }
                    }
                });
            }
        }).start();
    }

}
