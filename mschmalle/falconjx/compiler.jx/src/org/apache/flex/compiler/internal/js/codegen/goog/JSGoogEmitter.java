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
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.flex.compiler.common.ASModifier;
import org.apache.flex.compiler.definitions.IClassDefinition;
import org.apache.flex.compiler.definitions.IFunctionDefinition;
import org.apache.flex.compiler.definitions.IPackageDefinition;
import org.apache.flex.compiler.definitions.ITypeDefinition;
import org.apache.flex.compiler.internal.js.codegen.JSEmitter;
import org.apache.flex.compiler.internal.semantics.SemanticUtils;
import org.apache.flex.compiler.internal.tree.as.ChainedVariableNode;
import org.apache.flex.compiler.internal.tree.as.FunctionNode;
import org.apache.flex.compiler.js.codegen.goog.IJSGoogDocEmitter;
import org.apache.flex.compiler.js.codegen.goog.IJSGoogEmitter;
import org.apache.flex.compiler.problems.ICompilerProblem;
import org.apache.flex.compiler.projects.ICompilerProject;
import org.apache.flex.compiler.tree.ASTNodeID;
import org.apache.flex.compiler.tree.as.IASNode;
import org.apache.flex.compiler.tree.as.IAccessorNode;
import org.apache.flex.compiler.tree.as.IBinaryOperatorNode;
import org.apache.flex.compiler.tree.as.IClassNode;
import org.apache.flex.compiler.tree.as.IDefinitionNode;
import org.apache.flex.compiler.tree.as.IExpressionNode;
import org.apache.flex.compiler.tree.as.IFunctionNode;
import org.apache.flex.compiler.tree.as.IGetterNode;
import org.apache.flex.compiler.tree.as.IIdentifierNode;
import org.apache.flex.compiler.tree.as.IPackageNode;
import org.apache.flex.compiler.tree.as.IParameterNode;
import org.apache.flex.compiler.tree.as.IScopedNode;
import org.apache.flex.compiler.tree.as.ISetterNode;
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

    @Override
    public void emitJSDocVariable(IVariableNode node)
    {
        getDoc().begin();
        
        // emit namespace annotation
        String ns = node.getNamespace();
        if (ns == "private")
        {
        	getDoc().emitPrivate(node);
        }
        else if (ns == "protected")
        {	
        	getDoc().emitProtected(node);
        }
        
        if (node.isConst())
        	getDoc().emitConst(node);
        
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
        if (containsThisReference(node))
            getDoc().emitThis(parent);
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

        String root = "";
        if (!node.isConst())
        	root = "prototype.";
        write(definition.getQualifiedName() + "." + root + node.getName());
        
        IExpressionNode vnode = node.getAssignedValueNode();
        if (vnode != null)
        {
            write(" = ");
            getWalker().walk(vnode);
        }

        if (!(node instanceof ChainedVariableNode))
        {
            int len = node.getChildCount();
            for (int i = 0; i < len; i++)
            {
                IASNode child = node.getChild(i);
                if (child instanceof ChainedVariableNode)
                {
                    write(";");
                    write("\n\n");
                    emitField((IVariableNode) child);
                }
            }
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
                boolean hasDoc = false;

                // @this
                if (containsThisReference(node))
                {
                    getDoc().begin();
                    hasDoc = true;

                    getDoc().emitThis(type);
                }

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
                String returnType = node.getReturnType();
                if (returnType != "" && returnType != "void")
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
    public void emitGetAccessor(IGetterNode node)
    {
        emitObjectDefineProperty(node);
    }
    
    @Override
    public void emitSetAccessor(ISetterNode node)
    {
        emitObjectDefineProperty(node);
    }

    @Override
    public void emitMethod(IFunctionNode node)
    {
        if (node.isConstructor())
        {
            emitConstructor(node);
            return;
        }

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

        emitDefaultParameterCodeBlock(node);
    }

    private void emitDefaultParameterCodeBlock(IFunctionNode node)
    {
        IParameterNode[] pnodes = node.getParameterNodes();
        if (pnodes.length == 0)
            return;

        Map<Integer, IParameterNode> defaults = getDefaults(pnodes);

        final StringBuilder code = new StringBuilder();

        if (defaults != null)
        {
            if (!hasBody(node))
            {
                indentPush();
                write("\t");
            }

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
                    + (pnodes.length - 1) + ");\n");

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

    private static boolean containsThisReference(IASNode node)
    {
        final int len = node.getChildCount();
        for (int i = 0; i < len; i++)
        {
            final IASNode child = node.getChild(i);
            if (child.getChildCount() > 0)
            {
                return containsThisReference(child);
            }
            else
            {
                if (SemanticUtils.isThisKeyword(child))
                    return true;
            }
        }

        return false;
    }

    private void emitObjectDefineProperty(IAccessorNode node)
    {
        /*
        Object.defineProperty(
            A.prototype, 
            'foo', 
            {get: function() {return -1;}, 
            configurable: true}
         );
        */
        // head
        write("Object.defineProperty(");
        indentPush();
        write("\n");

        // Type
        IFunctionDefinition definition = node.getDefinition();
        ITypeDefinition type = (ITypeDefinition) definition.getParent();
        write(type.getQualifiedName());
        write(".");
        write("prototype");
        write(", ");
        write("\n");

        // name
        write("'");
        write(definition.getBaseName());
        write("'");
        write(", ");
        write("\n");

        // info object
        // declaration
        write("{");
        write(node.getNodeID() == ASTNodeID.GetterID ? "get" : "set");
        write(":");
        write("function");
        emitParamters(node.getParameterNodes());

        emitMethodScope(node.getScopedNode());

        write(", ");
        write("configurable:true");
        write("}");
        indentPop();
        write("\n");

        // tail, no colon; parent container will add it
        write(")");
    }

    //--------------------------------------------------------------------------
    // Operators
    //--------------------------------------------------------------------------

    @Override
    public void emitBinaryOperator(IBinaryOperatorNode node)
    {
    	ASTNodeID id = node.getNodeID();
    	
    	if (id == ASTNodeID.Op_AsID || id == ASTNodeID.Op_IsID)
        {
        	// TODO (erikdebruin) replace: this is a placeholder for the 
    		//                    eventual implementation
            write((id == ASTNodeID.Op_AsID) ? "as(" : "is(");
            getWalker().walk(node.getLeftOperandNode());
            write(", ");
            getWalker().walk(node.getRightOperandNode());
            write(")");
        }
        else
        {
        	getWalker().walk(node.getLeftOperandNode());

            if (id != ASTNodeID.Op_CommaID)
                write(" ");
            
            // (erikdebruin) rewrite 'a &&= b' to 'a = a && b'
            if (id == ASTNodeID.Op_LogicalAndAssignID || id == ASTNodeID.Op_LogicalOrAssignID)
            {
            	IIdentifierNode lnode = (IIdentifierNode) node.getLeftOperandNode();
            	
                write("=");
                write(" ");
                write(lnode.getName());
                write(" ");
                write((id == ASTNodeID.Op_LogicalAndAssignID) ? ASTNodeID.Op_LogicalAndID.getParaphrase() : ASTNodeID.Op_LogicalOrID.getParaphrase());
            }
            else
            {
            	write(node.getOperator().getOperatorText());
            }
            
            write(" ");
            
            getWalker().walk(node.getRightOperandNode());
        }
    }
}
