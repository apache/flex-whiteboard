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

    import org.apache.flex.utilities.developerToolSuite.LocaleUtil;
    import org.apache.flex.utilities.developerToolSuite.executor.database.ApplicationDB;

    public class InitDBCommand {
        private static var _conn:SQLConnection;

        private var createSettingsTableSql:String = "create table if not exists settings(id integer primary key autoincrement, name text, value text);";
        private var insertSettingsTableSql:String = "INSERT INTO settings (name, value) VALUES ('locale', '" + LocaleUtil.getDefaultLanguage().data + "');";

        public function execute():void {
            _conn = new SQLConnection();

            // The database file is in the application storage directory
            var folder:File = File.applicationStorageDirectory;
            var dbFile:File = folder.resolvePath(ApplicationDB.DATABASE_NAME);

            _conn.open(dbFile);

            if (!settingsTableCreated())
                buildDatabaseTables();

            _conn.close();

        }

        private function settingsTableCreated():Boolean {

            try {
                _conn.loadSchema();
            } catch (err:SQLError) {
                return false;
            }
            var schema:SQLSchemaResult = _conn.getSchemaResult();

            for each(var currentTable:SQLTableSchema in schema.tables)
                if (currentTable.name == "settings")
                    return true;

            return false;
        }

        private function buildDatabaseTables():void {
            try {
                _conn.begin();
                createSettingsTable();
                insertSettingsTable();
                _conn.commit();
            } catch (err:SQLError) {
                _conn.rollback();
                trace("Error message:", err.message);
                trace("Details:", err.details);
            };

            function createSettingsTable():void {
                var stmtCreateSettingsTable:SQLStatement;
                stmtCreateSettingsTable = new SQLStatement();
                stmtCreateSettingsTable.sqlConnection = _conn;
                stmtCreateSettingsTable.text = createSettingsTableSql;
                stmtCreateSettingsTable.execute();
            }

            function insertSettingsTable():void {
                var stmtInsertSettingsTable:SQLStatement;
                stmtInsertSettingsTable = new SQLStatement();
                stmtInsertSettingsTable.sqlConnection = _conn;
                stmtInsertSettingsTable.text = insertSettingsTableSql;
                stmtInsertSettingsTable.execute();
            }
        }
    }
}
