package org.apache.flex.utilities.developerToolSuite.executor.application.util {
    import avmplus.getQualifiedClassName;

    import mx.logging.ILogger;
    import mx.logging.Log;

    public class LogUtil {
        public static function getLogger(category:*):ILogger {
            var className:String = getQualifiedClassName(category).replace("::", ".");
            return Log.getLogger(className);
        }
    }
}
