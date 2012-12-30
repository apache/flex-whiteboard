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

import java.io.FilterWriter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.flex.compiler.common.ASModifier;
import org.apache.flex.compiler.definitions.IClassDefinition;
import org.apache.flex.compiler.definitions.IPackageDefinition;
import org.apache.flex.compiler.definitions.ITypeDefinition;
import org.apache.flex.compiler.internal.js.codegen.JSEmitter;
import org.apache.flex.compiler.internal.js.codegen.JSSharedData;
import org.apache.flex.compiler.internal.tree.as.FunctionNode;
import org.apache.flex.compiler.js.codegen.goog.IJSGoogDocEmitter;
import org.apache.flex.compiler.js.codegen.goog.IJSGoogEmitter;
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

/**
 * Concrete implementation of the 'goog' JavaScript production.
 * 
 * @author Michael Schmalle
 */
public class JSGoogEmitter extends JSEmitter implements IJSGoogEmitter
{
    IJSGoogDocEmitter getDoc()
    {
        return (IJSGoogDocEmitter) getDocEmitter();
    }

    //--------------------------------------------------------------------------
    // 
    //--------------------------------------------------------------------------

    public void emitJSDocPackgeHeader(IPackageNode node)
    {
        //        getDocEmitter().emmitPackageHeader(node);
    }

    @Override
    public void emitJSDocVariable(IVariableNode node)
    {
        getDoc().begin();
        getDoc().emitType(node);
        getDoc().end();
    }

    @Override
    public void emitJSDocConstructor(IFunctionNode node,
            ICompilerProject project)
    {
        IClassDefinition parent = (IClassDefinition) node.getDefinition()
                .getParent();
        IClassDefinition superClass = parent.resolveBaseClass(project);

        getDoc().begin();
        getDoc().emitConstructor(node);
        if (superClass != null)
            getDoc().emitExtends(superClass);
        getDoc().end();
    }

    //--------------------------------------------------------------------------
    // 
    //--------------------------------------------------------------------------

    @Override
    public void emitPackageHeader(IPackageNode node)
    {
        ITypeNode type = findTypeNode(node);
        if (type == null)
            return;

        write("goog.provide('" + type.getQualifiedName() + "');");
        write("\n");
        write("\n");
    }

    @Override
    public void emitPackageHeaderContents(IPackageNode node)
    {
        ITypeNode type = findTypeNode(node);
        if (type == null)
            return;

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
        if (type == null)
            return;

        IClassNode cnode = (IClassNode) type;
        IClassDefinition definition = cnode.getDefinition();

        // constructor
        emitConstructor((IFunctionNode) definition.getConstructor().getNode());
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
        IClassDefinition definition = getClassDefinition(node);

        FunctionNode fn = (FunctionNode) node;
        fn.parseFunctionBody(new ArrayList<ICompilerProblem>());

        emitJSDocConstructor(node, getWalker().getProject());

        String qname = definition.getQualifiedName();
        write(qname);
        write(" ");
        write("=");
        write(" ");
        write("function");
        emitParamters(node.getParameterNodes());
        emitMethodScope(node.getScopedNode());
    }

    @Override
    public void emitField(IVariableNode node)
    {
        IClassDefinition definition = getClassDefinition(node);

        emitJSDocVariable(node);
        write(definition.getQualifiedName() + ".prototype." + node.getName());
        IExpressionNode vnode = node.getAssignedValueNode();
        if (vnode != null)
        {
            write(" = ");
            getWalker().walk(vnode);
        }
    }

    @Override
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
            	Boolean hasDoc = false;
            	
                // @this
                // TODO (erikdebruin) only emit @this when there actually is 
                //                    a 'this' reference in the method block
            	/*
                if (false)
                {
                    getDoc().begin();
                	hasDoc = true;
                	
                	getDoc().emitThis(type);
                }
                //*/
                
                // @param
                IParameterNode[] parameters = node.getParameterNodes();
                for (IParameterNode pnode : parameters)
                {
                	if (!hasDoc)
                	{
                        getDoc().begin();
                    	hasDoc = true;
                	}
                		
                    getDoc().emitParam(pnode);
                }
                
                // @return
                // TODO (erikdebruin) only emit @return when there actually is 
                //					  a return value defined
                String returnType = node.getReturnType();
                if (returnType != "")
                {
                	if (!hasDoc)
                	{
                        getDoc().begin();
                    	hasDoc = true;
                	}
                		
                	getDoc().emitReturn(node);
                }
                
                // @override
                Boolean override = node.hasModifier(ASModifier.OVERRIDE);
                if (override)
                {
                	if (!hasDoc)
                	{
                        getDoc().begin();
                    	hasDoc = true;
                	}
                		
                	getDoc().emitOverride(node);
                }
                
                if (hasDoc)
                	getDoc().end();
            }
        }
    }

    @Override
    public void emitMethod(IFunctionNode node)
    {
        if (node.isConstructor())
            return;

        IClassDefinition definition = getClassDefinition(node);

        emitJSDoc(node, getWalker().getProject(), false, definition);
        FunctionNode fn = (FunctionNode) node;
        fn.parseFunctionBody(new ArrayList<ICompilerProblem>());

        String qname = getTypeDefinition(node).getQualifiedName();
        if (qname != null && !qname.equals(""))
        {
            write(qname);
            write(".");
            if (!fn.hasModifier(ASModifier.STATIC))
            	write("prototype.");
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
        emitRestParameterCodeBlock(node);
        
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
        if (pnodes.length == 0)
            return;

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

    private void emitRestParameterCodeBlock(IFunctionNode node)
    {
        IParameterNode[] pnodes = node.getParameterNodes();

        IParameterNode rest = getRest(pnodes);
        if (rest != null)
        {
            final StringBuilder code = new StringBuilder();

            code.append(rest.getName() + " = "
                    + "Array.prototype.slice.call(arguments, "
                    + (pnodes.length - 1)
                    + ");\n");

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

    private IParameterNode getRest(IParameterNode[] nodes)
    {
        for (IParameterNode node : nodes)
        {
            if (node.isRest())
                return node;
        }

        return null;
    }

    private static ITypeDefinition getTypeDefinition(IDefinitionNode node)
    {
        ITypeNode tnode = (ITypeNode) node.getAncestorOfType(ITypeNode.class);
        return (ITypeDefinition) tnode.getDefinition();
    }

    private static IClassDefinition getClassDefinition(IDefinitionNode node)
    {
        IClassNode tnode = (IClassNode) node
                .getAncestorOfType(IClassNode.class);
        return tnode.getDefinition();
    }

    private static boolean hasBody(IFunctionNode node)
    {
        IScopedNode scope = node.getScopedNode();
        return scope.getChildCount() > 0;
    }
}
