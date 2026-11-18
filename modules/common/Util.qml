pragma Singleton
import QtQuick
import Quickshell

// Util.qml — 格式化小工具：时间、编号、单位、字节。
QtObject {
    id: util

    function pad2(n) {
        return n < 10 ? "0" + n : "" + n;
    }

    function pad3(n) {
        if (n < 10)
            return "00" + n;
        if (n < 100)
            return "0" + n;
        return "" + n;
    }

    function clockText(date, seconds, use24h) {
        if (use24h === false) {
            var h12 = date.getHours() % 12;
            if (h12 === 0)
                h12 = 12;
            var s = pad2(h12) + ":" + pad2(date.getMinutes());
            if (seconds)
                s += ":" + pad2(date.getSeconds());
            return s + (date.getHours() >= 12 ? " PM" : " AM");
        }
        var t = pad2(date.getHours()) + ":" + pad2(date.getMinutes());
        if (seconds)
            t += ":" + pad2(date.getSeconds());
        return t;
    }

    readonly property var weekdaysEN: ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
    readonly property var weekdaysCN: ["周日", "周一", "周二", "周三", "周四", "周五", "周六"]
    readonly property var monthsEN: ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]

    function weekday(date, cn) {
        return (cn ? weekdaysCN : weekdaysEN)[date.getDay()];
    }

    function dateText(date, cn) {
        if (cn)
            return (date.getMonth() + 1) + "月" + date.getDate() + "日 " + weekday(date, true);
        return weekdaysEN[date.getDay()] + "  " + pad2(date.getDate()) + " " + monthsEN[date.getMonth()] + " " + date.getFullYear();
    }

    // 少前界面上到处都是这种编号，例如 “ECHELON 03” / “OP-042”。
    function echelon(n) {
        return "ECHELON " + pad2(n);
    }

    function opNumber(seed) {
        var s = "" + (seed || new Date().getTime());
        var h = 0;
        for (var i = 0; i < s.length; i++)
            h = (h * 31 + s.charCodeAt(i)) % 9973;
        return "OP-" + pad3(h % 1000);
    }

    function clamp(v, lo, hi) {
        return Math.max(lo, Math.min(hi, v));
    }

    function percent(value) {
        return Math.round(clamp(value, 0, 1) * 100);
    }

    function truncate(text, max) {
        if (!text)
            return "";
        if (text.length <= max)
            return text;
        return text.substring(0, Math.max(1, max - 1)) + "…";
    }

    function basename(p) {
        if (!p)
            return "";
        var i = p.lastIndexOf("/");
        return i >= 0 ? p.substring(i + 1) : p;
    }

    function execBinary(execString) {
        if (!execString)
            return "";
        var s = ("" + execString).replace(/%[fFuUdDnNickvm]/g, "").trim();
        var parts = s.split(/\s+/);
        return parts.length > 0 ? parts[0] : "";
    }

    function bytesHuman(bps) {
        if (!isFinite(bps) || bps <= 0)
            return "0 B/s";
        var units = ["B/s", "K/s", "M/s", "G/s"];
        var i = 0;
        while (bps >= 1024 && i < units.length - 1) {
            bps /= 1024;
            i++;
        }
        return (bps >= 100 ? Math.round(bps) : bps.toFixed(1)) + " " + units[i];
    }

    function gib(v) {
        return (Math.round(v * 10) / 10).toFixed(1);
    }

    function uptimeText(sec) {
        var d = Math.floor(sec / 86400);
        var h = Math.floor((sec % 86400) / 3600);
        var m = Math.floor((sec % 3600) / 60);
        if (d > 0)
            return d + "D " + pad2(h) + "H";
        return pad2(h) + ":" + pad2(m);
    }

    function percentText(v) {
        return pad2(Math.round(clamp(v, 0, 1) * 100)) + "%";
    }
}
