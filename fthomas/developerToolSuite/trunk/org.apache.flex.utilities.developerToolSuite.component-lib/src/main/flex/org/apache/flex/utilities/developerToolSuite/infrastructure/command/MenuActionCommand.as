package org.apache.flex.utilities.developerToolSuite.infrastructure.command {
    import org.apache.flex.utilities.developerToolSuite.infrastructure.message.MenuActionMessage;
    import org.apache.flex.utilities.developerToolSuite.presentation.behavior.menu.ApplicationMenuPM;

    public class MenuActionCommand {

        [Inject]
        public var service:ApplicationMenuPM;

        public function execute(msg:MenuActionMessage):void {
            service.doMenuAction(msg.item);
        }
    }
}
