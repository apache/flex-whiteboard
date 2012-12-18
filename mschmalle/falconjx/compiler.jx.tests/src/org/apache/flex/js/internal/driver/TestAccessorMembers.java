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

package org.apache.flex.js.internal.driver;

import org.apache.flex.compiler.tree.as.IAccessorNode;
import org.apache.flex.compiler.tree.as.IFileNode;
import org.apache.flex.compiler.tree.as.IFunctionNode;
import org.junit.Test;

/**
 * This class tests the production of valid ActionScript3 code for Class
 * Accessor members.
 * 
 * @author Michael Schmalle
 */
public class TestAccessorMembers extends TestWalkerBase
{
    //--------------------------------------------------------------------------
    // Accessor
    //--------------------------------------------------------------------------

    @Test
    public void testGetAccessor()
    {
        IFunctionNode node = getAccessor("function get foo():int{return -1;}");
        visitor.visitFunction(node);
        assertOut("function get foo():int {\n\treturn -1;\n}");
    }

    @Test
    public void testGetAccessor_withNamespace()
    {
        IFunctionNode node = getAccessor("public function get foo():int{return -1;}");
        visitor.visitFunction(node);
        assertOut("public function get foo():int {\n\treturn -1;\n}");
    }

    @Test
    public void testSetAccessor()
    {
        IFunctionNode node = getAccessor("function set foo(value:int):void{}");
        visitor.visitFunction(node);
        assertOut("function set foo(value:int):void {\n}");
    }

    @Test
    public void testSetAccessor_withNamespace()
    {
        IFunctionNode node = getAccessor("public function set foo(value:int):void{}");
        visitor.visitFunction(node);
        assertOut("public function set foo(value:int):void {\n}");
    }

    protected IAccessorNode getAccessor(String code)
    {
        String source = "package {public class A {" + code + "}}";
        IFileNode node = getFileNode(source);
        IAccessorNode child = (IAccessorNode) findFirstDescendantOfType(node,
                IAccessorNode.class);
        return child;
    }
}
