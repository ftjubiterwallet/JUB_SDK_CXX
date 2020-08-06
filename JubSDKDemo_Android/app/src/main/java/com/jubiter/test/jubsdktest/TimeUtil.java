package com.jubiter.test.jubsdktest;

/**
 * Created by GOD on 2016/5/26.
 */
public class TimeUtil {

    /**
     * 时间格式化
     *
     * @param time 毫秒数
     * @return
     */
    public static String formatTime(long time) {
        long hours = (time % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60);
        long minutes = (time % (1000 * 60 * 60)) / (1000 * 60);
        long seconds = (time % (1000 * 60)) / 1000;
        long milliSec = time % 1000;
        StringBuffer buf = new StringBuffer();
        if (hours != 0) {
            buf.append(hours + "小时");
        }
        if (minutes != 0) {
            buf.append(minutes + "分");
        }
        if (seconds != 0) {
            buf.append(seconds + "秒");
        }
        if (milliSec != 0) {
            buf.append(milliSec + "毫秒");
        }
        return buf.toString();
    }

}
