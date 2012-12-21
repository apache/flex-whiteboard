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

import org.apache.flex.compiler.tree.as.IClassNode;
import org.apache.flex.compiler.tree.as.IFileNode;
import org.junit.Test;

/**
 * This class tests the production of valid ActionScript3 code for Class
 * production.
 * 
 * @author Michael Schmalle
 */
public class TestClass extends TestWalkerBase
{
    //--------------------------------------------------------------------------
    // Class
    //--------------------------------------------------------------------------

    @Test
    public void testSimple()
    {
        IClassNode node = getClassNode("public class A{}");
        visitor.visitClass(node);
        assertOut("public class A {\n}");
    }

    @Test
    public void testSimpleInternal()
    {
        IClassNode node = getClassNode("internal class A{}");
        visitor.visitClass(node);
        assertOut("internal class A {\n}");
    }
    
    @Test
    public void testSimpleFinal()
    {
        IClassNode node = getClassNode("public final class A{}");
        visitor.visitClass(node);
        assertOut("public final class A {\n}");
    }

    @Test
    public void testSimpleExtends()
    {
        IClassNode node = getClassNode("public class A extends B {}");
        visitor.visitClass(node);
        assertOut("public class A extends B {\n}");
    }

    @Test
    public void testSimpleImplements()
    {
        IClassNode node = getClassNode("public class A implements IA {}");
        visitor.visitClass(node);
        assertOut("public class A implements IA {\n}");
    }

    @Test
    public void testSimpleImplementsMultiple()
    {
        IClassNode node = getClassNode("public class A implements IA, IB, IC {}");
        visitor.visitClass(node);
        assertOut("public class A implements IA, IB, IC {\n}");
    }

    @Test
    public void testSimpleExtendsImplements()
    {
        IClassNode node = getClassNode("public class A extends B implements IA {}");
        visitor.visitClass(node);
        assertOut("public class A extends B implements IA {\n}");
    }

    @Test
    public void testSimpleExtendsImplementsMultiple()
    {
        IClassNode node = getClassNode("public class A extends B implements IA, IB, IC {}");
        visitor.visitClass(node);
        assertOut("public class A extends B implements IA, IB, IC {\n}");
    }

    @Test
    public void testSimpleFinalExtendsImplementsMultiple()
    {
        IClassNode node = getClassNode("public final class A extends B implements IA, IB, IC {}");
        visitor.visitClass(node);
        assertOut("public final class A extends B implements IA, IB, IC {\n}");
    }

    @Test
    public void testQualifiedExtendsImplementsMultiple()
    {
        IClassNode node = getClassNode("public class A extends goo.B implements foo.bar.IA, goo.foo.IB, baz.boo.IC {}");
        visitor.visitClass(node);
        assertOut("public class A extends goo.B implements foo.bar.IA, goo.foo.IB, baz.boo.IC {\n}");
    }
    
    protected IClassNode getClassNode(String code)
    {
        String source = "package {" + code + "}";
        IFileNode node = getFileNode(source);
        IClassNode child = (IClassNode) findFirstDescendantOfType(node,
                IClassNode.class);
        return child;
    }
}
