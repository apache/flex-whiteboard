package org.apache.flex.utilities.developerToolSuite.executor.infrastructure.nativeProcess {
    import flash.desktop.NativeProcess;
    import flash.events.ProgressEvent;

    import org.flexunit.Assert;

    import org.flexunit.asserts.assertNotNull;
    import org.flexunit.async.Async;

    public class CommandLineProcessTest {

        private var command:NativeProcessHelper;

        [Before]
        public function setUp():void {
            command = new NativeProcessHelper();
            command.logMessages();
        }

        [Test(async)]
        public function shouldLogMessages():void {
            command.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, Async.asyncHandler(this, outputDataLogHandler, 20000, null, handleTimeout), false, 0,
                                     true);

            var shell:String = "C:\\Windows\\System32\\cmd.exe";
            var args:Vector.<String> = new Vector.<String>();
            args.push("/K");
            args.push("set");

            command.run(shell, args);
        }

        private function outputDataLogHandler(event:ProgressEvent, passThroughData:Object):void {
            var command:NativeProcessHelper = event.currentTarget as NativeProcessHelper;
            var result:String = command.process.standardOutput.readUTFBytes(command.process.standardOutput.bytesAvailable);
            trace("res: ", command.process.standardOutput.readUTFBytes(command.process.standardOutput.bytesAvailable));
            assertNotNull(result);
        }

        private function handleTimeout(passThroughData:Object):void {
            Assert.fail("Timeout reached before event");
        }



        [After]
        public function tearDown():void {
            command = null;
        }
    }
}
