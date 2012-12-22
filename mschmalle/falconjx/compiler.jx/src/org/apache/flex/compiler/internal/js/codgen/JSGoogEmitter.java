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

package org.apache.flex.compiler.internal.js.codgen;

import java.io.FilterWriter;
import java.util.ArrayList;

import org.apache.flex.compiler.definitions.IClassDefinition;
import org.apache.flex.compiler.definitions.IPackageDefinition;
import org.apache.flex.compiler.internal.tree.as.FunctionNode;
import org.apache.flex.compiler.problems.ICompilerProblem;
import org.apache.flex.compiler.tree.as.IClassNode;
import org.apache.flex.compiler.tree.as.IDefinitionNode;
import org.apache.flex.compiler.tree.as.IExpressionNode;
import org.apache.flex.compiler.tree.as.IFunctionNode;
import org.apache.flex.compiler.tree.as.IPackageNode;
import org.apache.flex.compiler.tree.as.ITypeNode;
import org.apache.flex.compiler.tree.as.IVariableNode;

public class JSGoogEmitter extends JSEmitter
{
    private IClassDefinition classDefinition;

    @Override
    public void emitPackageHeader(IPackageNode node)
    {
        ITypeNode type = findTypeNode(node);
        write("goog.provide('" + type.getQualifiedName() + "');");
        write("\n");
        write("\n");
    }

    @Override
    public void emitPackageHeaderContents(IPackageNode node)
    {
        IPackageDefinition parent = (IPackageDefinition) node.getDefinition();
        ArrayList<String> list = new ArrayList<String>();
        parent.getContainedScope().getScopeNode().getAllImports(list);
        for (String imp : list)
        {
            if (imp.indexOf("__AS3__") != -1)
                continue;
            write("goog.require('" + imp + "');");
            write("\n");
        }
        write("\n");
    }

    @Override
    public void emitPackageContents(IPackageNode node)
    {
        ITypeNode type = findTypeNode(node);
        IClassNode cnode = (IClassNode) type;
        classDefinition = cnode.getDefinition();
        // constructor
        emitConstructor((IFunctionNode) classDefinition.getConstructor()
                .getNode());

        IDefinitionNode[] members = cnode.getAllMemberNodes();
        for (IDefinitionNode dnode : members)
        {
            if (dnode instanceof IVariableNode)
            {
                emitField((IVariableNode) dnode);
            }
        }

        for (IDefinitionNode dnode : members)
        {
            if (dnode instanceof IFunctionNode)
            {
                emitMethod((IFunctionNode) dnode);
            }
        }
    }

    @Override
    public void emitPackageFooter(IPackageNode node)
    {
    }

    @Override
    public void emitConstructor(IFunctionNode node)
    {
        FunctionNode fn = (FunctionNode) node;
        fn.parseFunctionBody(new ArrayList<ICompilerProblem>());
        
        emitJSDocConstructor(node, getWalker().getProject());
        
        String qname = classDefinition.getQualifiedName();
        write(qname);
        write(" ");
        write("=");
        write(" ");
        write("function");
        emitParamters(node.getParameterNodes());
        emitMethodScope(node.getScopedNode());
        write("\n");
        write("\n");
    }

    public void emitField(IVariableNode node)
    {
        emitJSDocVariable(node);
        write(classDefinition.getQualifiedName() + ".prototype."
                + node.getName());
        IExpressionNode vnode = node.getAssignedValueNode();
        if (vnode != null)
        {
            write(" = ");
            getWalker().walk(vnode);
        }
        write(";\n");
        write("\n");
    }

    @Override
    public void emitMethod(IFunctionNode node)
    {
        if (node.isConstructor())
            return;
        
        emitJSDoc(node, getWalker().getProject(), false, classDefinition);
        FunctionNode fn = (FunctionNode) node;
        fn.parseFunctionBody(new ArrayList<ICompilerProblem>());

        String qname = classDefinition.getQualifiedName();
        write(qname);
        write(" ");
        write("=");
        write(" ");
        write("function");
        emitParamters(node.getParameterNodes());
        emitMethodScope(node.getScopedNode());
        write("\n");
        write("\n");
    }

    public JSGoogEmitter(FilterWriter out)
    {
        super(out);
    }

}
