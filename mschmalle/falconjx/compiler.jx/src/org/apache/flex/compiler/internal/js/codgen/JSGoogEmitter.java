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
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.flex.compiler.definitions.IClassDefinition;
import org.apache.flex.compiler.definitions.IPackageDefinition;
import org.apache.flex.compiler.definitions.ITypeDefinition;
import org.apache.flex.compiler.internal.tree.as.FunctionNode;
import org.apache.flex.compiler.problems.ICompilerProblem;
import org.apache.flex.compiler.projects.ICompilerProject;
import org.apache.flex.compiler.tree.as.IClassNode;
import org.apache.flex.compiler.tree.as.IDefinitionNode;
import org.apache.flex.compiler.tree.as.IExpressionNode;
import org.apache.flex.compiler.tree.as.IFunctionNode;
import org.apache.flex.compiler.tree.as.IPackageNode;
import org.apache.flex.compiler.tree.as.IParameterNode;
import org.apache.flex.compiler.tree.as.IScopedNode;
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
        write(";\n");
        write("\n");

        IDefinitionNode[] members = cnode.getAllMemberNodes();
        for (IDefinitionNode dnode : members)
        {
            if (dnode instanceof IVariableNode)
            {
                emitField((IVariableNode) dnode);
                write(";\n");
                write("\n");
            }
        }

        for (IDefinitionNode dnode : members)
        {
            if (dnode instanceof IFunctionNode)
            {
                if (!((IFunctionNode) dnode).isConstructor())
                {
                    emitMethod((IFunctionNode) dnode);
                    write(";\n");
                    write("\n");
                }
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
    }

    public void emitJSDoc(IFunctionNode node, ICompilerProject project,
            boolean isConstructor, ITypeDefinition type)
    {
        // TODO (mschmalle) change method signature, remove type
        // this is a temp override until I change the method signature
        // unit testing dosn't have access to the type, we need to use the AST to get the definition
        if (type == null)
        {
            ITypeNode tnode = (ITypeNode) node
                    .getAncestorOfType(ITypeNode.class);
            type = (ITypeDefinition) tnode.getDefinition();
        }

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

    @Override
    public void emitMethod(IFunctionNode node)
    {
        if (node.isConstructor())
            return;

        emitJSDoc(node, getWalker().getProject(), false, classDefinition);
        FunctionNode fn = (FunctionNode) node;
        fn.parseFunctionBody(new ArrayList<ICompilerProblem>());

        String qname = getTypeDefinition(node).getQualifiedName();
        if (qname != null && !qname.equals(""))
        {
            write(qname);
            write(".");
        }

        emitMemberName(node);
        write(" ");
        write("=");
        write(" ");
        write("function");
        emitParamters(node.getParameterNodes());
        emitMethodScope(node.getScopedNode());
    }

    @Override
    public void emitFunctionBlockHeader(IFunctionNode node)
    {
        if (JSSharedData.OUTPUT_ALTERNATE)
        {
            emitDefaultParameterCodeBlock_Alternate(node);
        }
        else
        {
            emitDefaultParameterCodeBlock(node);
        }
    }

    private void emitDefaultParameterCodeBlock(IFunctionNode node)
    {
        // TODO (mschmalle) test for ... rest 
        // if default parameters exist, produce the init code
        IParameterNode[] pnodes = node.getParameterNodes();
        Map<Integer, IParameterNode> defaults = getDefaults(pnodes);
        final StringBuilder code = new StringBuilder();
        if (defaults != null)
        {
            List<IParameterNode> parameters = new ArrayList<IParameterNode>(
                    defaults.values());
            Collections.reverse(parameters);

            int len = defaults.size();
            int numDefaults = 0;
            // make the header in reverse order
            for (IParameterNode pnode : parameters)
            {
                if (pnode != null)
                {
                    code.append(getIndent(numDefaults));
                    code.append("if (arguments.length < " + len + ") {\n");
                    numDefaults++;
                }
                len--;
            }

            Collections.reverse(parameters);
            for (IParameterNode pnode : parameters)
            {
                if (pnode != null)
                {
                    code.append(getIndent(numDefaults));
                    code.append(pnode.getName());
                    code.append(" = ");
                    code.append(pnode.getDefaultValue());
                    code.append(";\n");
                    code.append(getIndent(numDefaults - 1));
                    code.append("}");
                    if (numDefaults > 1)
                        code.append("\n");
                    numDefaults--;
                }
            }
            IScopedNode sbn = node.getScopedNode();
            boolean hasBody = sbn.getChildCount() > 0;
            // adds the current block indent to the generated code
            String indent = getIndent(getCurrentIndent() + (!hasBody ? 1 : 0));
            String result = code.toString().replaceAll("\n", "\n" + indent);
            // if the block dosn't have a body (children), need to add indent to head
            if (!hasBody)
                result = indent + result;
            // have to add newline after the replace or we get an extra indent
            result += "\n";
            write(result);
        }
    }

    private void emitDefaultParameterCodeBlock_Alternate(IFunctionNode node)
    {
        // (erikdebruin) implemented alternative approach to handling 
        //               default parameter values in JS

        IParameterNode[] pnodes = node.getParameterNodes();

        Map<Integer, IParameterNode> defaults = getDefaults(pnodes);

        if (!hasBody(node))
        {
            indentPush();
            write("\t");
        }

        final StringBuilder code = new StringBuilder();

        if (defaults != null)
        {
            List<IParameterNode> parameters = new ArrayList<IParameterNode>(
                    defaults.values());

            int numDefaults = 0;
            for (IParameterNode pnode : parameters)
            {
                if (pnode != null)
                {
                    if (numDefaults > 0)
                        code.append(getIndent(getCurrentIndent()));

                    code.append(pnode.getName() + " = typeof "
                            + pnode.getName() + " !== 'undefined' ? "
                            + pnode.getName() + " : " + pnode.getDefaultValue()
                            + ";\n");

                    numDefaults++;
                }
            }

            if (!hasBody(node))
                indentPop();

            write(code.toString());
        }
    }

    @Override
    public void emitParameter(IParameterNode node)
    {
        // only the name gets output in JS
        getWalker().walk(node.getNameExpressionNode());
    }

    public JSGoogEmitter(FilterWriter out)
    {
        super(out);
    }

    private ITypeDefinition getTypeDefinition(IDefinitionNode node)
    {
        if (classDefinition != null)
            return classDefinition;

        ITypeNode tnode = (ITypeNode) node.getAncestorOfType(ITypeNode.class);
        return (ITypeDefinition) tnode.getDefinition();
    }

    private Map<Integer, IParameterNode> getDefaults(IParameterNode[] nodes)
    {
        Map<Integer, IParameterNode> result = new HashMap<Integer, IParameterNode>();
        int i = 0;
        boolean hasDefaults = false;
        for (IParameterNode node : nodes)
        {
            if (node.hasDefaultValue())
            {
                hasDefaults = true;
                result.put(i, node);
            }
            else
            {
                result.put(i, null);
            }
            i++;
        }

        if (!hasDefaults)
            return null;

        return result;
    }

    private static boolean hasBody(IFunctionNode node)
    {
        IScopedNode scope = node.getScopedNode();
        return scope.getChildCount() > 0;
    }
}
