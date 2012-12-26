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
import org.apache.flex.compiler.internal.js.codgen.JSSharedData;
import org.apache.flex.compiler.tree.as.IFileNode;
import org.apache.flex.compiler.tree.as.IFunctionNode;
import org.apache.flex.js.internal.driver.TestWalkerBase;
import org.junit.Ignore;
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

    @Test
    public void testSimpleParameterReturnType()
    {
        JSSharedData.OUTPUT_JSDOC = false;
        IFunctionNode node = getMethod("function foo(bar:int):int{\n}");
        visitor.visitFunction(node);
        assertOut("foo.bar.A = function(bar) {\n}");
        JSSharedData.OUTPUT_JSDOC = true;
    }

    @Test
    public void testSimpleMultipleParameter()
    {
        JSSharedData.OUTPUT_JSDOC = false;
        IFunctionNode node = getMethod("function foo(bar:int, baz:String, goo:A):void{\n}");
        visitor.visitFunction(node);
        assertOut("foo.bar.A = function(bar, baz, goo) {\n}");
        JSSharedData.OUTPUT_JSDOC = true;
    }

    @Ignore
    @Test
    public void testSimpleMultipleParameter_JSDoc()
    {
        // jsdoc still needs to be sorted out before tests are executing
        IFunctionNode node = getMethod("function foo(bar:int, baz:String, goo:A):void{\n}");
        visitor.visitFunction(node);
        assertOut("/**\n * @this {foo.bar.A}\n * @param {int} bar\n * @param {String} baz\n"
                + " * @param {A} goo\n * @return {void}\n */\nfoo.bar.A = "
                + "function(bar, baz, goo) {\n}");
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

    protected IFunctionNode getMethod(String code)
    {
        String source = "package foo.bar {public class A {" + code + "}}";
        IFileNode node = getFileNode(source);
        IFunctionNode child = (IFunctionNode) findFirstDescendantOfType(node,
                IFunctionNode.class);
        return child;
    }
}
