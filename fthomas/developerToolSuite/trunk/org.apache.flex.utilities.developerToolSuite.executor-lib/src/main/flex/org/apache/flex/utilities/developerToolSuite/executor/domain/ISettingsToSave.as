package org.apache.flex.utilities.developerToolSuite.executor.domain {
    public interface ISettingsToSave {

        function get dbVersion():uint;

        function get appBounds():String;

        function get appDisplayState():String;

        function get locale():String;

        function get JAVA_HOME():String;

        function get ANT_HOME():String;

        function get MAVEN_HOME():String;

        function get CYGWIN_HOME():String;
    }
}
