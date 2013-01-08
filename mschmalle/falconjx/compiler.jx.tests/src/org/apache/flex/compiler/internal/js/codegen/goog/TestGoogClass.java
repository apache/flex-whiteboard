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
import org.apache.flex.compiler.internal.as.codegen.TestClass;
import org.apache.flex.compiler.internal.js.codegen.JSSharedData;
import org.apache.flex.compiler.internal.js.driver.goog.GoogBackend;
import org.apache.flex.compiler.tree.as.IClassNode;
import org.apache.flex.compiler.tree.as.IFileNode;
import org.junit.Ignore;
import org.junit.Test;

/**
 * This class tests the production of 'goog' JS code for Classes.
 * 
 * @author Michael Schmalle
 * @author Erik de Bruin
 */
public class TestGoogClass extends TestClass
{
	@Override
	@Test
    public void testSimple()
    {
        IClassNode node = getClassNode("public class A{}");
        visitor.visitClass(node);
        assertOut("/**\n * @constructor\n */\norg.apache.flex.A = function() {\n};\n\n");
    }

	@Override
    @Test
    public void testSimpleInternal()
    {
		// TODO (erikdebruin) is there a 'goog' equivalent for the 
		//                    'internal' namespace?
        IClassNode node = getClassNode("internal class A{}");
        visitor.visitClass(node);
        assertOut("/**\n * @constructor\n */\norg.apache.flex.A = function() {\n};\n\n");
    }

	@Override
    @Test
    public void testSimpleFinal()
    {
		// TODO (erikdebruin) is there a 'goog' equivalent for the 
		//                    'final' keyword?
        IClassNode node = getClassNode("public final class A{}");
        visitor.visitClass(node);
        assertOut("/**\n * @constructor\n */\norg.apache.flex.A = function() {\n};\n\n");
    }

	@Override
    @Test
    public void testSimpleExtends()
    {
        IClassNode node = getClassNode("public class A extends B {public function A() {}}");
        visitor.visitClass(node);
        assertOut("/**\n * @constructor\n */\norg.apache.flex.A = function() {\n\tgoog.base(this, optArgs);\n\n}\ngoog.inherits('childClass', 'parentClass');\n\n");
    }

	@Ignore
	@Override
    @Test
    public void testSimpleImplements()
    {
        IClassNode node = getClassNode("public class A implements IA {}");
        visitor.visitClass(node);
        //assertOut("");
    }

	@Ignore
	@Override
    @Test
    public void testSimpleImplementsMultiple()
    {
        IClassNode node = getClassNode("public class A implements IA, IB, IC {}");
        visitor.visitClass(node);
        //assertOut("");
    }

	@Ignore
	@Override
    @Test
    public void testSimpleExtendsImplements()
    {
        IClassNode node = getClassNode("public class A extends B implements IA {}");
        visitor.visitClass(node);
        //assertOut("");
    }

	@Ignore
	@Override
    @Test
    public void testSimpleExtendsImplementsMultiple()
    {
        IClassNode node = getClassNode("public class A extends B implements IA, IB, IC {}");
        visitor.visitClass(node);
        //assertOut("");
    }

	@Ignore
	@Override
    @Test
    public void testSimpleFinalExtendsImplementsMultiple()
    {
        IClassNode node = getClassNode("public final class A extends B implements IA, IB, IC {}");
        visitor.visitClass(node);
        //assertOut("");
    }

	@Ignore
	@Override
    @Test
    public void testQualifiedExtendsImplementsMultiple()
    {
        IClassNode node = getClassNode("public class A extends goo.B implements foo.bar.IA, goo.foo.IB, baz.boo.IC {}");
        visitor.visitClass(node);
        //assertOut("");
    }

	@Ignore
	@Override
    @Test
    public void testConstructor()
    {
		// TODO (erikdebruin) replace 'super' call with 'goog.base()'... Can you
		//                    call 'super' if the class doesn't extend any other?
        IClassNode node = getClassNode("public class A {public function A() {super('foo', 42);}}");
        JSSharedData.OUTPUT_JSDOC = false;
        visitor.visitClass(node);
        JSSharedData.OUTPUT_JSDOC = true;
        assertOut("org.apache.flex.A = function() {\n\tsuper('foo', 42);\n};\n\n");
    }
    
	@Ignore
	@Override
    @Test
    public void testFields()
    {
        IClassNode node = getClassNode("public class A {public var a:Object;protected var b:String; "
                + "private var c:int; internal var d:uint; var e:Number}");
        visitor.visitClass(node);
        //assertOut("");
    }

	@Ignore
	@Override
    @Test
    public void testConstants()
    {
        IClassNode node = getClassNode("public class A {" +
        		"public static const A:int = 42;" +
        		"protected static const B:Number = 42;" +
                "private static const C:Number = 42;" +
                "foo_bar static const C:String = 'me' + 'you';");
        visitor.visitClass(node);
        //assertOut("");
    }
    
	@Ignore
	@Override
    @Test
    public void testAccessors()
    {
        IClassNode node = getClassNode("public class A {"
                + "public function get foo1():Object{return null;}"
                + "public function set foo1(value:Object):void{}"
                + "protected function get foo2():Object{return null;}"
                + "protected function set foo2(value:Object):void{}"
                + "private function get foo3():Object{return null;}"
                + "private function set foo3(value:Object):void{}"
                + "internal function get foo5():Object{return null;}"
                + "internal function set foo5(value:Object):void{}"
                + "foo_bar function get foo6():Object{return null;}"
                + "foo_bar function set foo6(value:Object):void{}" + "}");
        visitor.visitClass(node);
        //assertOut("");
    }

	@Ignore
	@Override
    @Test
    public void testMethods()
    {
        IClassNode node = getClassNode("public class A {"
                + "public function foo1():Object{return null;}"
                + "public final function foo1a():Object{return null;}"
                + "override public function foo1b():Object{return super.foo1b();}"
                + "protected function foo2(value:Object):void{}"
                + "private function foo3(value:Object):void{}"
                + "internal function foo5(value:Object):void{}"
                + "foo_bar function foo6(value:Object):void{}"
                + "public static function foo7(value:Object):void{}"
                + "foo_bar static function foo7(value:Object):void{}" + "}");
        visitor.visitClass(node);
        //assertOut("");
    }

	@Override
    protected IClassNode getClassNode(String code)
    {
        String source = "package org.apache.flex {" + code + "}";
        IFileNode node = getFileNode(source);
        IClassNode child = (IClassNode) findFirstDescendantOfType(node, IClassNode.class);
        return child;
    }
    
    protected IBackend createBackend()
    {
        return new GoogBackend();
    }

}
