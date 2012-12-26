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
import org.apache.flex.compiler.definitions.ITypeDefinition;
import org.apache.flex.compiler.internal.as.codegen.ASEmitter;
import org.apache.flex.compiler.js.IJSEmitter;
import org.apache.flex.compiler.projects.IASProject;
import org.apache.flex.compiler.projects.ICompilerProject;
import org.apache.flex.compiler.tree.as.IFunctionNode;
import org.apache.flex.compiler.tree.as.IPackageNode;
import org.apache.flex.compiler.tree.as.IParameterNode;
import org.apache.flex.compiler.tree.as.IVariableNode;

/**
 * @author Michael Schmalle
 */
public class JSEmitter extends ASEmitter implements IJSEmitter
{
    public static boolean javascriptMode = false;

    protected JSDocEmitter jsdoc;

    public JSEmitter(FilterWriter out)
    {
        super(out);
        this.jsdoc = new JSDocEmitter(this);
    }

    public void emitJSDocPackgeHeader(IPackageNode node)
    {
        jsdoc.emmitPackageHeader(node);
    }

    public void emitRequire(ITypeDefinition definition)
    {
        IPackageDefinition parent = (IPackageDefinition) definition.getParent();
        ArrayList<String> list = new ArrayList<String>();
        parent.getContainedScope().getScopeNode().getAllImports(list);
        for (String imp : list)
        {
            if (imp.indexOf("__AS3__") != -1)
                continue;
            write("goog.require('" + imp + "');");
            writeNewline();
        }
        writeNewline();
    }

    public void emitInherits(IClassDefinition definition, IASProject project)
    {
        IClassDefinition superClass = definition.resolveBaseClass(project);

        if (superClass != null)
        {
            write("\ngoog.inherits(" + definition.getQualifiedName() + ", "
                    + superClass.getQualifiedName() + ");");
            writeNewline();
        }
    }

    // TODO this signature doesn't feel right
    public void emitJSDoc(IFunctionNode node, ICompilerProject project,
            boolean isConstructor, ITypeDefinition type)
    {
        if (node instanceof IFunctionNode)
        {
            if (isConstructor)
            {
                emitJSDocConstructor(node, project);
            }
            else
            {
                jsdoc.begin();
                jsdoc.emitThis(type);
                // @param
                IParameterNode[] parameters = node.getParameterNodes();
                for (IParameterNode pnode : parameters)
                {
                    jsdoc.emitParam(pnode);
                }
                // @return
                jsdoc.emitReturn(node);
                jsdoc.end();
            }
        }
    }

    public void emitJSDocVariable(IVariableNode node)
    {
        jsdoc.begin();
        jsdoc.emitType(node);
        jsdoc.end();
    }

    public void emitJSDocConstructor(IFunctionNode node,
            ICompilerProject project)
    {
        IClassDefinition parent = (IClassDefinition) node.getDefinition()
                .getParent();
        IClassDefinition superClass = parent.resolveBaseClass(project);

        jsdoc.begin();
        jsdoc.emitConstructor(node);
        if (superClass != null)
            jsdoc.emitExtends(superClass);
        jsdoc.end();
    }

    public void emitConstructor(IFunctionNode node)
    {
        // for now, we just call back, this is to allow custom handling
        // straight from the emitter
        getWalker().visitConstructor(node);
    }

    public void emitField(IVariableNode node)
    {
        super.emitField(node);
        //        emitJSDocVariable(node);
        //        write(getVisitor().getCurrentType().getQualifiedName() + ".prototype."
        //                + node.getName());
        //        IExpressionNode vnode = node.getAssignedValueNode();
        //        if (vnode != null)
        //        {
        //            write(" = ");
        //            getVisitor().walk(vnode);
        //        }
        //        write(";\n");
    }

    public void emitVarDeclaration(IVariableNode node)
    {
        super.emitVarDeclaration(node);
        //        getWalker().walk(node.getChild(0)); // VariableExpressionNode
        //        write(" ");
        //        getWalker().walk(node.getNameExpressionNode());
        //        // add :Type
        //        {
        //            IExpressionNode tnode = node.getVariableTypeNode();
        //            if (tnode instanceof ILanguageIdentifierNode)
        //            {
        //                ILanguageIdentifierNode lnode = (ILanguageIdentifierNode) tnode;
        //                if (lnode.getKind() != ILanguageIdentifierNode.LanguageIdentifierKind.ANY_TYPE)
        //                    write(":");
        //            }
        //            else
        //            {
        //                write(":");
        //            }
        //
        //            getWalker().walk(node.getVariableTypeNode());
        //        }
        //        IExpressionNode vnode = node.getAssignedValueNode();
        //        if (vnode != null)
        //        {
        //            write(" = ");
        //            if (vnode instanceof FunctionObjectNode)
        //            {
        //                //getWalker().pushContext(TraverseContext.FUNCTION);
        //                getWalker().walk(vnode.getChild(0)); // IFunctionNode
        //                //getWalker().popContext(TraverseContext.FUNCTION);
        //            }
        //            else
        //            {
        //                getWalker().walk(vnode);
        //            }
        //        }
    }
}
