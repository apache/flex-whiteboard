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

package org.apache.flex.compiler.internal.js.codegen.goog;

import org.apache.flex.compiler.clients.IBackend;
import org.apache.flex.compiler.internal.as.codegen.TestPackage;
import org.apache.flex.compiler.internal.js.driver.goog.GoogBackend;
import org.apache.flex.compiler.tree.as.IFileNode;
import org.junit.Ignore;
import org.junit.Test;

/**
 * This class tests the production of 'goog' JavaScript for AS package.
 * 
 * @author Michael Schmalle
 * @author Erik de Bruin
 */
public class TestGoogPackage extends TestPackage
{
    // TODO (erikdebruin)
    // 2) empty classes don't get a JS block (curly brackets)
    //    - do we produce implicit constructors?
    // 4) there is an extra line after the 'goog.provide' line: remove
    // 5) there are two extra lines at the end of the code: remove
    // 6) constructor body in 'testPackageQualified_ClassBodyMethodContents'
    //    contains code that is not yet 'goog'-ified

    @Override
    @Test
    public void testPackage_Simple()
    {
        IFileNode node = getFileNode("package{}");
        visitor.visitFile(node);
        assertOut("");
    }

    @Override
    @Test
    public void testPackage_Name()
    {
        IFileNode node = getFileNode("package foo.bar.baz {}");
        visitor.visitFile(node);
        assertOut("");
    }

    @Override
    @Ignore
    @Test
    public void testPackageSimple_Class()
    {
        // does JS need a implicit constructor function? ... always?
        // All class nodes in AST get either an implicit or explicit constructor
        // this is an implicit and the way I have the before/after handler working
        // with block disallows implicit blocks from getting { }
        IFileNode node = getFileNode("package {public class A{}}");
        visitor.visitFile(node);
        assertOut("");
    }

    @Override
    @Ignore
    @Test
    public void testPackageQualified_Class()
    {
        // same here; see testPackageSimple_Class
        IFileNode node = getFileNode("package foo.bar.baz {public class A{}}");
        visitor.visitFile(node);
        assertOut("");
    }

    @Override
    @Test
    public void testPackageQualified_ClassBody()
    {
        // there is still two newlines at the end and after provide which shouldn't happen
        // I'll look into that if you don't get to it
        IFileNode node = getFileNode("package foo.bar.baz {public class A{public function A(){}}}");
        visitor.visitFile(node);
        assertOut("goog.provide('foo.bar.baz.A');\n\n\n/**\n * @constructor\n */\nfoo.bar.baz.A = function() {\n};\n\n");
    }

    @Override
    @Test
    public void testPackageQualified_ClassBodyMethodContents()
    {
        IFileNode node = getFileNode("package foo.bar.baz {public class A{public function A(){if (a){for each(var i:Object in obj){doit();}}}}}");
        visitor.visitFile(node);
        //assertOut("");
    }

    @Override
    protected IBackend createBackend()
    {
        return new GoogBackend();
    }
}
