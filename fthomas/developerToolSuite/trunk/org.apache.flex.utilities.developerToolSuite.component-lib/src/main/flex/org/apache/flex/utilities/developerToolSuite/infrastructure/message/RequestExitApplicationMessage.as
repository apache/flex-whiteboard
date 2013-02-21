package org.apache.flex.utilities.developerToolSuite.infrastructure.message {
    import org.apache.flex.utilities.developerToolSuite.executor.infrastructure.message.SaveSettingsMessage;

    public class RequestExitApplicationMessage{
        public var settings:Object;

        public function RequestExitApplicationMessage(settings:Object) {
            this.settings = settings;
        }
    }
}
