/**
 Licensed to the Apache Software Foundation (ASF) under one or more
 contributor license agreements.  See the NOTICE file distributed with
 this work for additional information regarding copyright ownership.
 The ASF licenses this file to You under the Apache License, Version 2.0
 (the "License"); you may not use this file except in compliance with
 the License.  You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */
package org.apache.flex.utilities.developerToolSuite.executor.application.database {
    import flash.data.SQLConnection;
    import flash.data.SQLResult;
    import flash.data.SQLStatement;
    import flash.errors.SQLError;
    import flash.events.EventDispatcher;
    import flash.events.SQLErrorEvent;
    import flash.events.SQLEvent;
    import flash.filesystem.File;
    import flash.net.Responder;

    import mx.logging.ILogger;
    import mx.utils.ObjectUtil;

    import org.apache.flex.utilities.developerToolSuite.executor.application.util.LogUtil;

    public class ApplicationDB extends EventDispatcher{

        public static const DB_VERSION:uint = 1;

        private static var LOG:ILogger = LogUtil.getLogger(ApplicationDB);

        public static const DATABASE_NAME:String = "DTSDB.db";
        private static var _conn:SQLConnection;

        private var _isReady:Boolean;
        private var _isBusy:Boolean;

        private var _callbacks:Array = [];
        private var _resultCallback:Function;
        private var _errorCallback:Function;

        public function connect(callback:Function):void {

            _callbacks.push(callback);

            if (!_isReady && !_isBusy) {
                LOG.debug("Connecting async DB: {0}", ApplicationDB.DATABASE_NAME);
                _conn = new SQLConnection();

                _conn.addEventListener(SQLEvent.OPEN, openHandler);
                _conn.addEventListener(SQLEvent.CLOSE, closedHandler);
                _conn.addEventListener(SQLErrorEvent.ERROR, errorHandler);

                // The database file is in the application storage directory
                var folder:File = File.applicationStorageDirectory;
                var dbFile:File = folder.resolvePath(DATABASE_NAME);

                _isBusy = true;
                _conn.openAsync(dbFile);
            } else executeNextCallback();
        }

        protected function openHandler(event:SQLEvent):void {
            _isReady = true;
            _isBusy = false;
            LOG.debug("the database was opened successfully");
            executeNextCallback();
        }

        protected function close():void {
            LOG.debug("Closing async DB: {0}", ApplicationDB.DATABASE_NAME);
            _isReady = false;
            _isBusy = false;
            _conn.close();
        }

        protected function closedHandler(event:SQLEvent):void {
            LOG.debug("the database was closed successfully");
            dispatchEvent(event);
        }

        protected function errorHandler(event:SQLErrorEvent):void {
            LOG.error("Error executing DB Command: {0}", ObjectUtil.toString(event.error));
            _isReady = false;
            _isBusy = false;
        }

        public function executeSqlStatement(stmt:SQLStatement, resultCallback:Function, errorCallback:Function):void {
            _resultCallback = resultCallback;
            _errorCallback = errorCallback;

            _isBusy = true;
            stmt.sqlConnection = _conn;
            stmt.execute(-1, new Responder(result, error));
        }

        private function result(result:SQLResult):void {
            _isBusy = false;
            if (_resultCallback) {
                _resultCallback(result);
                _resultCallback = null;
            }
            executeNextCallback();
        }

        private function error(error:SQLError):void {
            LOG.error("Error executing DB Command: {0}", ObjectUtil.toString(error));
            _isBusy = false;
            if (_errorCallback) {
                _errorCallback(error);
                _errorCallback = null;
            }
            executeNextCallback();
        }

        private function executeNextCallback():void {
            if (_isReady && !_isBusy) {
                if (_callbacks.length > 0) {
                    _callbacks.pop()();
                } else {
                    close();
                }
            }
        }
    }
}
