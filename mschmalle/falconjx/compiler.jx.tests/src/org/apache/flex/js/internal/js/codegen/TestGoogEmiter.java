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

package org.apache.flex.js.internal.js.codegen;

import java.io.FilterWriter;

import org.apache.flex.compiler.clients.IBackend;
import org.apache.flex.compiler.internal.driver.JSBackend;
import org.apache.flex.compiler.internal.js.codgen.JSEmitter;
import org.apache.flex.compiler.internal.js.codgen.JSGoogEmitter;
import org.apache.flex.compiler.tree.as.IFileNode;
import org.apache.flex.js.internal.driver.TestWalkerBase;
import org.junit.Test;

/**
 * This class tests the production of 'goog' JavaScript output.
 * <p>
 * Note; this is a complete prototype more used in figuring out where
 * abstraction and indirection is needed concerning the AS -> JS translations.
 * 
 * @author Michael Schmalle
 */
public class TestGoogEmiter extends TestWalkerBase
{
    // emitPackageHeader()
    // emitImports()
    // emitClass()

    @Test
    public void testSimple()
    {
        String code = "package com.example.components {"
                + "import org.apache.flex.html.staticControls.TextButton;"
                + "public class MyTextButton extends TextButton {"
                + "public function MyTextButton() {if (foo() != 42) { bar(); } }"
                + "private var _privateVar:String = \"do \";"
                + "public var publicProperty:Number = 100;"
                + "public function myFunction(value: String): String{"
                + "return \"Don't \" + _privateVar + value; }";
        IFileNode node = getFileNode(code);
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
