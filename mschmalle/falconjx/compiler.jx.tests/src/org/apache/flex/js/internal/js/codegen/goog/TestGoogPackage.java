/*
 *
 *  Licensed to the Apache Software Foundation (ASF) under one or more
 *  contributor license agreements.  See the NOTICE file distributed with
 *  this work for additional information regarding copyright ownership.
 *  The ASF licenses this file to You under the Apache License, Version 2.0
 *  (the "License"); you may not use this file except in compliance with
 *  the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

package org.apache.flex.js.internal.js.codegen.goog;

import java.io.FilterWriter;

import org.apache.flex.compiler.clients.IBackend;
import org.apache.flex.compiler.internal.driver.JSBackend;
import org.apache.flex.compiler.internal.js.codgen.JSEmitter;
import org.apache.flex.compiler.internal.js.codgen.JSGoogEmitter;
import org.apache.flex.compiler.tree.as.IFileNode;
import org.apache.flex.js.internal.driver.TestPackage;
import org.junit.Ignore;
import org.junit.Test;

/**
 * This class tests the production of 'goog' JavaScript for Package production.
 * 
 * @author Michael Schmalle
 * @author Erik de Bruin
 */
public class TestGoogPackage extends TestPackage
{
	// TODO (erikdebruin)
	// 1) empty packages cause exception
	// 2) empty classes don't get a JS block (curly brackets)
	// 3) empty classes get an '@extends {Object}' annotation: remove
	// 4) there is an extra line after the 'goog.provide' line: remove
	// 5) there are two extra lines at the end of the code: remove
	// 6) constructor body in 'testPackageQualified_ClassBodyMethodContents'
	//    contains cody that is not yet 'goog'-ified
	
	@Ignore
	@Test
    public void testPackage_Simple()
    {
        IFileNode node = getFileNode("package{}");
        visitor.visitFile(node);
        //assertOut("");
    }

	@Ignore
    @Test
    public void testPackage_Name()
    {
        IFileNode node = getFileNode("package foo.bar.baz {}");
        visitor.visitFile(node);
        //assertOut("");
    }

    @Test
    public void testPackageSimple_Class()
    {
        IFileNode node = getFileNode("package {public class A{}}");
        visitor.visitFile(node);
        //assertOut("");
    }

    @Test
    public void testPackageQualified_Class()
    {
        IFileNode node = getFileNode("package foo.bar.baz {public class A{}}");
        visitor.visitFile(node);
        //assertOut("");
    }

    @Test
    public void testPackageQualified_ClassBody()
    {
        IFileNode node = getFileNode("package foo.bar.baz {public class A{public function A(){}}}");
        visitor.visitFile(node);
        assertOut("goog.provide('foo.bar.baz.A');\n\n\n/**\n * @constructor\n * @extends {Object}\n */\nfoo.bar.baz.A = function() {\n};\n\n");
    }

    @Test
    public void testPackageQualified_ClassBodyMethodContents()
    {
        IFileNode node = getFileNode("package foo.bar.baz {public class A{public function A(){if (a){for each(var i:Object in obj){doit();}}}}}");
        visitor.visitFile(node);
        //assertOut("");
    }

    protected IBackend createBackend()
    {
        return new GoogBackend();
    }

    class GoogBackend extends JSBackend
    {
        @Override
        protected JSEmitter createEmitter(FilterWriter out)
        {
            return new JSGoogEmitter(out);
        }
    }

}
