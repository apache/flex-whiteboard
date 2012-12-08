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
    import flash.data.SQLSchemaResult;
    import flash.data.SQLStatement;
    import flash.data.SQLTableSchema;
    import flash.errors.SQLError;
    import flash.filesystem.File;

    import mx.logging.ILogger;
    import mx.utils.ObjectUtil;

    import org.apache.flex.utilities.developerToolSuite.LocaleUtil;
    import org.apache.flex.utilities.developerToolSuite.executor.infrastructure.database.ApplicationDB;
    import org.apache.flex.utilities.developerToolSuite.executor.infrastructure.util.LogUtil;

    public class InitDBCommand {

        private static var LOG:ILogger = LogUtil.getLogger(InitDBCommand);

        public var callback:Function;

        private static var _conn:SQLConnection;

        private static const SETTINGS_TABLE_SQL:String = "create table if not exists settings(id integer primary key autoincrement, name text, value text);";
        private static var settingsDataSql:String;

        public function execute():void {
            _conn = new SQLConnection();

            // The database file is in the application storage directory
            var folder:File = File.applicationStorageDirectory;
            var dbFile:File = folder.resolvePath(ApplicationDB.DATABASE_NAME);

            LOG.debug("Connecting DB: " + ApplicationDB.DATABASE_NAME);
            _conn.open(dbFile);

            if (!settingsTableCreated()) {
                buildDatabaseTables();
            }

            _conn.close();
            LOG.debug("Closing DB: " + ApplicationDB.DATABASE_NAME);

            callback(true);
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
                if (currentTable.name == "settings") {
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
                LOG.error("Error during schema creation: " + ObjectUtil.toString(err) + " : Rolling back !");
                _conn.rollback();
            }
            ;

            function createSettingsTable():void {
                var stmtCreateSettingsTable:SQLStatement;
                stmtCreateSettingsTable = new SQLStatement();
                stmtCreateSettingsTable.sqlConnection = _conn;
                stmtCreateSettingsTable.text = SETTINGS_TABLE_SQL;
                stmtCreateSettingsTable.execute();
            }

            function insertSettingsTable():void {
                LOG.debug("Inserting data");
                prepareSettingsData();
                var stmtInsertSettingsTable:SQLStatement;
                stmtInsertSettingsTable = new SQLStatement();
                stmtInsertSettingsTable.sqlConnection = _conn;
                stmtInsertSettingsTable.text = settingsDataSql;
                stmtInsertSettingsTable.execute();
            }

            function prepareSettingsData():void {
                settingsDataSql = "INSERT INTO 'settings' SELECT '1' AS 'id', 'locale' AS 'name', '" + LocaleUtil.getDefaultLanguage().data + "' AS 'value' ";
                settingsDataSql += "UNION SELECT '2', 'appDisplayState', '' ";
                settingsDataSql += "UNION SELECT '3', 'appBounds', '' ";
                settingsDataSql += "UNION SELECT '4', 'JAVA_HOME', '' ";
                settingsDataSql += "UNION SELECT '5', 'ANT_HOME', '' ";
                settingsDataSql += "UNION SELECT '6', 'MAVEN_HOME', '' ";
                settingsDataSql += "UNION SELECT '7', 'CYGWIN_HOME', '';";
            }
        }
    }
}
