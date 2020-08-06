package com.jubiter.test.jubsdktest;

import android.util.SparseArray;

import java.util.Arrays;
import java.util.Collections;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

/**
 * Created by zhldxy on 2017/6/1.
 */

public class StrUtil {

    /**
     * 将字节数组转换成十六进制的字符串
     * @param bt      字节数组
     */
    public static String byteArr2HexStr(byte[] bt) {
        return byteArr2HexStr(bt, "");
    }

    /**
     * 将字节数组转换成十六进制的字符串
     * @param bt      字节数组
     * @param sep     每个字节之间的分割字符串
     */
    public static String byteArr2HexStr(byte[] bt, String sep) {
        return byteArr2HexStr(bt, 0, bt.length, sep);
    }

    /**
     * 将字节数组转换成十六进制的字符串
     * @param bt      字节数组
     * @param end     终止下标
     * @param sep     每个字节之间的分割字符串
     */
    public static String byteArr2HexStr(byte[] bt, int end, String sep) {
        return byteArr2HexStr(bt, 0, end, sep);
    }

    /**
     * 将字节数组转换成十六进制的字符串
     * @param bt      字节数组
     * @param start   起始下标
     * @param end     终止下标
     */
    public static String byteArr2HexStr(byte[] bt, int start, int end) {
        return byteArr2HexStr(bt, start, end, "");
    }

    /**
     * 将字节数组转换成十六进制的字符串
     * @param bt      字节数组
     * @param start   起始下标
     * @param end     终止下标
     * @param sep     每个字节之间的分割字符串
     */
    public static String byteArr2HexStr(byte[] bt, int start, int end, String sep) {
        if (bt == null || bt.length < end || start < 0 || start >= end)
            throw new RuntimeException("param format error");

        StringBuffer sb = new StringBuffer();
        for (int i = start; i < end; i++) {
            sb.append(byte2HexStr(bt[i])).append(sep);
        }
        return sb.toString();
    }

    /**
     *  将byte转换成对应的十六进制字符串（如：byte值0x3D转换成字符串"3D"）
     *  @return  返回字符串长度一定为2
     */
    public static String byte2HexStr(byte b) {
        int i = (b & 0xF0) >> 4;
        int j = (b & 0x0F);
        char c = (char)(i > 9 ? 'A' + i%10 : '0' + i);
        char d = (char)(j > 9 ? 'A' + j%10 : '0' + j);
        return "" + c + d;
    }


    /**
     *  十六进制的str转换成byte数组（如："8AC4"转换成数组[0x8A, 0xC4]）
     *  @param str  长度必须是偶数，否则会抛异常
     */
    public static byte[] hexStr2ByteArr(String str) {
        if (str == null || str.length() % 2 != 0)
            throw new RuntimeException("param format error.");

        byte[] bt = new byte[str.length()/2];
        for (int i = 0; i < bt.length; i++) {
            bt[i] = (byte)((hexChar2Byte(str.charAt(2*i)) << 4)
                    + hexChar2Byte(str.charAt(2*i+1)));
        }
        return bt;
    }

    /**
     *  十六进制的char转换成byte（如：'D'转换成十进制的13）
     *  @param c  必须是合法的十六进制字符0-9,a-f,A-F
     */
    public static byte hexChar2Byte(char c) {
        if (c >= '0' && c <= '9') {
            return (byte)(c - '0');
        } else if (c >= 'A' && c <= 'F') {
            return (byte)(c - 'A' + 10);
        } else if (c >= 'a' && c <= 'f') {
            return (byte)(c - 'a' + 10);
        } else {
            throw new RuntimeException("param format error.");
        }
    }

    /**
     *  十六进制的str转换成byte（如："3D"转换成十进制的61）
     *  @param str  长度不能大于2
     */
    public static byte hexStr2Byte(String str) {
        if (str == null || str.length() > 2)
            throw new RuntimeException("param format error.");
        if (str.length() == 1)
            return hexChar2Byte(str.charAt(0));
        else
            return (byte)((hexChar2Byte(str.charAt(1)) << 4) + hexChar2Byte(str.charAt(0)));
    }

    /**
     * 队列比较
     * @param <T>
     * @param a
     * @param b
     * @return
     */
    public static <T extends Comparable<T>> boolean compare(List<T> a, List<T> b) {
        if(a.size() != b.size()) {
            return false;
        }

        Collections.sort(a);
        Collections.sort(b);
        for(int i = 0; i < a.size(); i++) {
            if(!a.get(i).equals(b.get(i)))
                return false;
        }
        return true;
    }

    public static String toString(SparseArray<byte[]> array) {
        if (array == null) {
            return "null";
        }
        if (array.size() == 0) {
            return "{}";
        }
        StringBuilder buffer = new StringBuilder();
        buffer.append('{');
        for (int i = 0; i < array.size(); ++i) {
            buffer.append(array.keyAt(i)).append("=").append(Arrays.toString(array.valueAt(i)));
        }
        buffer.append('}');
        return buffer.toString();
    }

    /**
     * Returns a string composed from a {@link Map}.
     */
    public static <T> String toString(Map<T, byte[]> map) {
        if (map == null) {
            return "null";
        }
        if (map.isEmpty()) {
            return "{}";
        }
        StringBuilder buffer = new StringBuilder();
        buffer.append('{');
        Iterator<Map.Entry<T, byte[]>> it = map.entrySet().iterator();
        while (it.hasNext()) {
            Map.Entry<T, byte[]> entry = it.next();
            Object key = entry.getKey();
            buffer.append(key).append("=").append(Arrays.toString(map.get(key)));
            if (it.hasNext()) {
                buffer.append(", ");
            }
        }
        buffer.append('}');
        return buffer.toString();
    }

    public static int byteArr2Int(byte[] b, int start, int len) {
        int sum = 0;
        int end = start + len;
        for (int i = start; i < end; i++) {
            int n = ((int)b[i]) & 0xff;
            n <<= (--len) * 8;
            sum += n;
        }

        return sum;
    }
}
