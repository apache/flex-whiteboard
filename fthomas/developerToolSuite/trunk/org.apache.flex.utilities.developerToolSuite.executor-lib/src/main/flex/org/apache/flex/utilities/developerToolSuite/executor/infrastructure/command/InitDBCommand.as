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
package org.apache.flex.utilities.developerToolSuite.executor.infrastructure.command {
    import flash.data.SQLConnection;
    import flash.data.SQLResult;
    import flash.data.SQLSchemaResult;
    import flash.data.SQLStatement;
    import flash.data.SQLTableSchema;
    import flash.errors.SQLError;
    import flash.filesystem.File;

    import mx.logging.ILogger;
    import mx.utils.ObjectUtil;

    import org.apache.flex.utilities.developerToolSuite.LocaleUtil;
    import org.apache.flex.utilities.developerToolSuite.executor.application.database.ApplicationDB;
    import org.apache.flex.utilities.developerToolSuite.executor.application.util.LogUtil;
    import org.apache.flex.utilities.developerToolSuite.executor.infrastructure.message.InitApplicationMessage;

    public class InitDBCommand {

        private static var LOG:ILogger = LogUtil.getLogger(InitDBCommand);

        public var callback:Function;

        private static var _conn:SQLConnection;

        private static const DB_VERSION_SQL:String = "SELECT value FROM setting WHERE name='dbVersion'";

        private static const SETTING_TABLE_SQL:String = "create table if not exists setting(id integer primary key autoincrement, name text, value text);";
        private static var settingDataSql:String;

        private static const PROJECT_TABLE_SQL:String = "create table if not exists project(id integer primary key autoincrement, name text, location text, vcsType text, flexSdkVersion text, airSdkVersion text, fpVersion text, creationDate numeric);";
        private static var projectDataSql:String;

        private var _dbVersion:uint;

        public function execute(msg:InitApplicationMessage):void {
            _conn = new SQLConnection();

            // The database file is in the application storage directory
            var folder:File = File.applicationStorageDirectory;
            var dbFile:File = folder.resolvePath(ApplicationDB.DATABASE_NAME);

            LOG.debug("Connecting DB: {0}", ApplicationDB.DATABASE_NAME);
            _conn.open(dbFile);

            if (!settingsTableCreated()) {
                buildDatabaseTables();
            } else {
                _dbVersion = getDBVersion();
                if (_dbVersion < ApplicationDB.DB_VERSION)
                updateSchema();
            }

            _conn.close();
            LOG.debug("Closing DB: {0}", ApplicationDB.DATABASE_NAME);

            callback(CommandCallBack.DEFAULT_RESULT);
        }

        private function updateSchema():void {
            LOG.debug("Updating DB Schema from version {0} to {1}", _dbVersion, ApplicationDB.DB_VERSION);
        }

        private function getDBVersion():uint {

            LOG.debug("looking for dbVersion");

            var getDbVersionStmt:SQLStatement = new SQLStatement();
            getDbVersionStmt.sqlConnection = _conn;
            getDbVersionStmt.text = DB_VERSION_SQL;
            getDbVersionStmt.execute();

            var dbVersionResult:SQLResult = getDbVersionStmt.getResult();
            if (dbVersionResult.data && dbVersionResult.data.length) {
                LOG.debug("DB version is {0}", dbVersionResult.data[0].value);
                return parseInt(dbVersionResult.data[0].value);
            }

            // Shouldn't happen.
            return 0;
        }

        private function settingsTableCreated():Boolean {

            LOG.debug("Trying create DB schema");
            try {
                _conn.loadSchema();
            } catch (err:SQLError) {
                LOG.debug("Schema wasn't already created");
                return false;
            }
            var schema:SQLSchemaResult = _conn.getSchemaResult();

            for each(var currentTable:SQLTableSchema in schema.tables) {
                if (currentTable.name == "setting") {
                    LOG.debug("Schema was already created");
                    return true;
                }
            }

            LOG.debug("Schema wasn't already created");
            return false;
        }

        private function buildDatabaseTables():void {
            try {
                LOG.debug("Start schema creation");
                _conn.begin();

                createSettingsTable();
                insertSettingsTable();

                _conn.commit();
                LOG.debug("Schema creation ok");
            } catch (err:SQLError) {
                LOG.error("Error during schema creation: {0}\n:: Rolling back !", ObjectUtil.toString(err));
                _conn.rollback();
            }
            ;

            function createSettingsTable():void {
                var stmtCreateSettingsTable:SQLStatement;
                stmtCreateSettingsTable = new SQLStatement();
                stmtCreateSettingsTable.sqlConnection = _conn;
                stmtCreateSettingsTable.text = SETTING_TABLE_SQL;
                stmtCreateSettingsTable.execute();
            }

            function insertSettingsTable():void {
                LOG.debug("Inserting data");
                prepareInsertSettingsData();
                var stmtInsertSettingsTable:SQLStatement;
                stmtInsertSettingsTable = new SQLStatement();
                stmtInsertSettingsTable.sqlConnection = _conn;
                stmtInsertSettingsTable.text = settingDataSql;
                stmtInsertSettingsTable.execute();
            }

            function prepareInsertSettingsData():void {
                settingDataSql = "INSERT INTO 'setting' SELECT '1' AS 'id', 'dbVersion' AS 'name', '1' AS 'value' ";
                settingDataSql += "UNION SELECT '2', 'locale', '" + LocaleUtil.getDefaultLanguage().data + "' ";
                settingDataSql += "UNION SELECT '3', 'appDisplayState', '' ";
                settingDataSql += "UNION SELECT '4', 'appBounds', '' ";
                settingDataSql += "UNION SELECT '5', 'JAVA_HOME', '' ";
                settingDataSql += "UNION SELECT '6', 'ANT_HOME', '' ";
                settingDataSql += "UNION SELECT '7', 'MAVEN_HOME', '' ";
                settingDataSql += "UNION SELECT '8', 'CYGWIN_HOME', '';";
            }
        }
    }
}
