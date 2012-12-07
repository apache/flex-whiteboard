package org.apache.flex.utilities.developerToolSuite.executor.infrastructure.nativeProcess {
    import flash.events.ProgressEvent;

    import org.flexunit.Assert;
    import org.flexunit.asserts.assertNotNull;
    import org.flexunit.async.Async;

    public class CommandLineProcessTest {

        private var command:NativeShellHelper;

        [Before]
        public function setUp():void {
            command = new NativeShellHelper();
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

            command.run(args, shell);
        }

        private function outputDataLogHandler(event:ProgressEvent, passThroughData:Object):void {
            var command:NativeShellHelper = event.currentTarget as NativeShellHelper;
            var result:String = command.process.standardOutput.readUTFBytes(command.process.standardOutput.bytesAvailable);
            trace("res: ", result);
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
