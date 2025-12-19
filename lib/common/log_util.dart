/// Created with Android Studio
/// User：keria
/// Date：2021/6/29
/// Email：runchen.brc@alibaba-inc.com
/// Reference：******

class LogUtil {
  static const String _TAG_DEF = "livepush_flutter";

  static bool debuggable = true;

  static String TAG = _TAG_DEF;

  static void init({bool isDebug = false, String tag = _TAG_DEF}) {
    debuggable = isDebug;
    TAG = tag;
  }

  static void e(Object object, {String tag = _TAG_DEF}) {
    _printLog(tag, ':->', object);
  }

  static void v(Object object, {String tag = _TAG_DEF}) {
    if (debuggable) {
      _printLog(tag, ':->', object);
    }
  }

  static void _printLog(String tag, String stag, Object object) {
    StringBuffer sb = StringBuffer();
    sb.write((tag.isEmpty) ? TAG : tag);
    sb.write(stag);
    sb.write(object);
    print(sb.toString());
  }
}
