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
import org.apache.flex.compiler.internal.as.codegen.TestMethodMembers;
import org.apache.flex.compiler.internal.js.codegen.JSSharedData;
import org.apache.flex.compiler.internal.js.driver.goog.GoogBackend;
import org.apache.flex.compiler.tree.as.IFunctionNode;
import org.junit.Test;

/**
 * This class tests the production of 'goog'-ified JS code for Class Method members.
 * 
 * @author Michael Schmalle
 * @author Erik de Bruin
 */
public class TestGoogMethodMembers extends TestMethodMembers
{
	// TODO (erikdebruin)
	//  1) ideally '@this' should only be included in the annotation if there is
	//     actually a reference to 'this' in the function body
	//  9) switch 'alternate' indicator to point to 'Wienberg style', not mine ;-)
	// 10) can we safely ignore the 'public' and custom namespaces?

    @Override
    public void tearDown()
    {
        super.tearDown();
        // XXX (mschmalle) We really have to get rid of these globals.
        // I had all tests in TestGoogEmitter fail because this wasn't switched back
        // to false in your tests below, this proves these are bad and are just 
        // left from FalconJS
        // not switching this back to false was leaving extra \t in method blocks
        JSSharedData.OUTPUT_ALTERNATE = false;
    }
    
    @Override
    @Test
    public void testMethod()
    {
        IFunctionNode node = getMethod("function foo(){}");
        visitor.visitFunction(node);
        assertOut("A.prototype.foo = function() {\n}");
    }

    @Override
    @Test
    public void testMethod_withReturnType()
    {
        IFunctionNode node = getMethod("function foo():int{\treturn -1;}");
        visitor.visitFunction(node);
        assertOut("/**\n * @return {number}\n */\nA.prototype.foo = function() {\n\treturn -1;\n}");
    }

    @Override
    @Test
    public void testMethod_withParameterReturnType()
    {
        IFunctionNode node = getMethod("function foo(bar):int{\treturn -1;}");
        visitor.visitFunction(node);
        assertOut("/**\n * @param {*} bar\n * @return {number}\n */\nA.prototype.foo = function(bar) {\n\treturn -1;\n}");
    }

    @Override
    @Test
    public void testMethod_withParameterTypeReturnType()
    {
        IFunctionNode node = getMethod("function foo(bar:String):int{\treturn -1;}");
        visitor.visitFunction(node);
        assertOut("/**\n * @param {string} bar\n * @return {number}\n */\nA.prototype.foo = function(bar) {\n\treturn -1;\n}");
    }

    @Override
    @Test
    public void testMethod_withDefaultParameterTypeReturnType()
    {
        IFunctionNode node = getMethod("function foo(bar:String = \"baz\"):int{\treturn -1;}");
    	JSSharedData.OUTPUT_ALTERNATE = true;
        visitor.visitFunction(node);
        assertOut("/**\n * @param {string=} bar\n * @return {number}\n */\nA.prototype.foo = function(bar) {\n\tbar = typeof bar !== 'undefined' ? bar : \"baz\";\n\treturn -1;\n}");
    }

    @Test
    public void testMethod_withDefaultParameterTypeReturnType_Alternate()
    {
        IFunctionNode node = getMethod("function foo(bar:String = \"baz\"):int{\treturn -1;}");
        visitor.visitFunction(node);
        assertOut("/**\n * @param {string=} bar\n * @return {number}\n */\nA.prototype.foo = function(bar) {\n\tif (arguments.length < 1) {\n\t\tbar = \"baz\";\n\t}\n\treturn -1;\n}");
    }

    @Override
    @Test
    public void testMethod_withMultipleDefaultParameterTypeReturnType()
    {
        IFunctionNode node = getMethod("function foo(bar:String, baz:int = null):int{\treturn -1;}");
    	JSSharedData.OUTPUT_ALTERNATE = true;
        visitor.visitFunction(node);
        assertOut("/**\n * @param {string} bar\n * @param {number=} baz\n * @return {number}\n */\nA.prototype.foo = function(bar, baz) {\n\tbaz = typeof baz !== 'undefined' ? baz : null;\n\treturn -1;\n}");
    }

    @Test
    public void testMethod_withMultipleDefaultParameterTypeReturnType_Alternate()
    {
        IFunctionNode node = getMethod("function foo(bar:String, baz:int = null):int{\treturn -1;}");
        visitor.visitFunction(node);
        assertOut("/**\n * @param {string} bar\n * @param {number=} baz\n * @return {number}\n */\nA.prototype.foo = function(bar, baz) {\n\tif (arguments.length < 2) {\n\t\tbaz = null;\n\t}\n\treturn -1;\n}");
    }

    @Override
    @Test
    public void testMethod_withRestParameterTypeReturnType()
    {
        IFunctionNode node = getMethod("function foo(bar:String, ...rest):int{\treturn -1;}");
        visitor.visitFunction(node);
        assertOut("/**\n * @param {string} bar\n * @param {...} rest\n * @return {number}\n */\nA.prototype.foo = function(bar, rest) {\n\trest = Array.prototype.slice.call(arguments, 1);\n\treturn -1;\n}");
    }

    @Override
    @Test
    public void testMethod_withNamespace()
    {
        IFunctionNode node = getMethod("public function foo(bar:String, baz:int = null):int{\treturn -1;}");
    	JSSharedData.OUTPUT_ALTERNATE = true;
        visitor.visitFunction(node);
        // we ignore the 'public' namespace completely
        assertOut("/**\n * @param {string} bar\n * @param {number=} baz\n * @return {number}\n */\nA.prototype.foo = function(bar, baz) {\n\tbaz = typeof baz !== 'undefined' ? baz : null;\n\treturn -1;\n}");
    }

    @Override
    @Test
    public void testMethod_withNamespaceCustom()
    {
        IFunctionNode node = getMethod("mx_internal function foo(bar:String, baz:int = null):int{\treturn -1;}");
    	JSSharedData.OUTPUT_ALTERNATE = true;
        visitor.visitFunction(node);
        // we ignore the custom namespaces completely (are there side effects I'm missing?)
        assertOut("/**\n * @param {string} bar\n * @param {number=} baz\n * @return {number}\n */\nA.prototype.foo = function(bar, baz) {\n\tbaz = typeof baz !== 'undefined' ? baz : null;\n\treturn -1;\n}");
    }
    
    @Override
    @Test
    public void testMethod_withNamespaceModifiers()
    {
        IFunctionNode node = getMethod("public static function foo(bar:String, baz:int = null):int{\treturn -1;}");
    	JSSharedData.OUTPUT_ALTERNATE = true;
        visitor.visitFunction(node);
        // (erikdebruin) here we actually DO want to declare the method
        //               directly on the 'class' constructor instead of the
        //               prototype!
        assertOut("/**\n * @param {string} bar\n * @param {number=} baz\n * @return {number}\n */\nA.foo = function(bar, baz) {\n\tbaz = typeof baz !== 'undefined' ? baz : null;\n\treturn -1;\n}");
    }

    @Override
    @Test
    public void testMethod_withNamespaceModifierOverride()
    {
        IFunctionNode node = getMethod("public override function foo(bar:String, baz:int = null):int{\treturn -1;}");
    	JSSharedData.OUTPUT_ALTERNATE = true;
        visitor.visitFunction(node);
        assertOut("/**\n * @param {string} bar\n * @param {number=} baz\n * @return {number}\n * @override\n */\nA.prototype.foo = function(bar, baz) {\n\tbaz = typeof baz !== 'undefined' ? baz : null;\n\treturn -1;\n}");
    }

    @Override
    @Test
    public void testMethod_withNamespaceModifierOverrideBackwards()
    {
        IFunctionNode node = getMethod("override public function foo(bar:String, baz:int = null):int{return -1;}");
    	JSSharedData.OUTPUT_ALTERNATE = true;
        visitor.visitFunction(node);
        assertOut("/**\n * @param {string} bar\n * @param {number=} baz\n * @return {number}\n * @override\n */\nA.prototype.foo = function(bar, baz) {\n\tbaz = typeof baz !== 'undefined' ? baz : null;\n\treturn -1;\n}");
    }

    //--------------------------------------------------------------------------
    // Doc Specific Tests 
    //--------------------------------------------------------------------------
    
    @Test
    public void testConstructor_withThisInBody()
    {
        IFunctionNode node = getMethod("public function A(){this.foo;}");
        visitor.visitConstructor(node);
        // TODO Erik; Do we need the @this tag if it's annotated with @constructor?
        // Right now I have it inserting if 'this' is present in the constructor scope
        assertOut("/**\n * @constructor\n * @this {A}\n */\nA = function() {\n\tthis.foo;\n}");
    }
    
    @Test
    public void testMethod_withThisInBody()
    {
        IFunctionNode node = getMethod("function foo(){this.foo;}");
        visitor.visitFunction(node);
        assertOut("/**\n * @this {A}\n */\nA.prototype.foo = function() {\n\tthis.foo;\n}");
    }
    
    @Test
    public void testMethod_withThisInBodyComplex()
    {
        IFunctionNode node = getMethod("function foo(){if(true){while(i){this.bar(42);}}}");
        visitor.visitFunction(node);
        assertOut("/**\n * @this {A}\n */\nA.prototype.foo = function() {\n\tif (true) " +
        		"{\n\t\twhile (i) {\n\t\t\tthis.bar(42);\n\t\t}\n\t}\n}");
    }
    
    @Override
    protected IFunctionNode getMethod(String code)
    {
    	JSSharedData.OUTPUT_ALTERNATE = false;
    	
    	return super.getMethod(code);
    }

    @Override
    protected IBackend createBackend()
    {
        return new GoogBackend();
    }
}
