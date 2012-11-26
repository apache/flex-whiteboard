package org.apache.flex.utilities.developerToolSuite {
    import flash.system.Capabilities;
    import flash.utils.Dictionary;

    import mx.utils.StringUtil;

    public class LocaleUtil {

        private static var initializer = init();

        private static var _LOCALE_MAP:Dictionary;
        private static var _LANGUAGE_MAP:Dictionary;

        public static var AVAILABLE_LANGUAGES:Array = [
            {label: 'English', data: 'en_US'},
            {label: 'Français', data: 'fr_FR'}
        ];


        private static  function init():void {
            initLocaleMap();
            initLanguageCodeMap();
        }

        private static function initLocaleMap():void {
            _LOCALE_MAP = new Dictionary();
            _LOCALE_MAP['en'] = "en_US";
            _LOCALE_MAP['fr'] = "fr_FR";
        }

        private static function initLanguageCodeMap():void {
            _LANGUAGE_MAP = new Dictionary();
            _LANGUAGE_MAP['en_US'] = "English";
            _LANGUAGE_MAP['fr_FR'] = "Français";
        }

        public static function getOSLanguage():Object {
            var language:String = _LANGUAGE_MAP[_LOCALE_MAP[Capabilities.language]];

            for (var i:uint; i < AVAILABLE_LANGUAGES.length; i++)
                if (AVAILABLE_LANGUAGES[i].label == language)
                    return AVAILABLE_LANGUAGES[i];

            return AVAILABLE_LANGUAGES[0];
        }

        public static function getOrderedLocalChain(firstLocale:String = null):Array {

            if (StringUtil.trim(firstLocale) == "")
                firstLocale = _LOCALE_MAP[Capabilities.language];

            var localeChain:Array = ['en_US', 'fr_FR'];

            var idx:int = localeChain.indexOf(firstLocale);

            if (idx < 1)
                return localeChain;

            localeChain.splice(idx, 1);
            localeChain.splice(0,0,firstLocale);

            return localeChain;
        }
    }
}
