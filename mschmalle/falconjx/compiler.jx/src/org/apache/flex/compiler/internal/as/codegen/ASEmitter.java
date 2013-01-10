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

package org.apache.flex.compiler.internal.as.codegen;

import java.io.FilterWriter;
import java.io.IOException;
import java.util.ArrayList;

import org.apache.flex.compiler.as.codegen.IASEmitter;
import org.apache.flex.compiler.as.codegen.IDocEmitter;
import org.apache.flex.compiler.common.ASModifier;
import org.apache.flex.compiler.common.ModifiersSet;
import org.apache.flex.compiler.constants.IASKeywordConstants;
import org.apache.flex.compiler.definitions.IDefinition;
import org.apache.flex.compiler.definitions.IFunctionDefinition;
import org.apache.flex.compiler.definitions.IVariableDefinition;
import org.apache.flex.compiler.internal.tree.as.ChainedVariableNode;
import org.apache.flex.compiler.internal.tree.as.FunctionNode;
import org.apache.flex.compiler.internal.tree.as.FunctionObjectNode;
import org.apache.flex.compiler.problems.ICompilerProblem;
import org.apache.flex.compiler.tree.ASTNodeID;
import org.apache.flex.compiler.tree.as.IASNode;
import org.apache.flex.compiler.tree.as.IAccessorNode;
import org.apache.flex.compiler.tree.as.IBinaryOperatorNode;
import org.apache.flex.compiler.tree.as.IClassNode;
import org.apache.flex.compiler.tree.as.IDefinitionNode;
import org.apache.flex.compiler.tree.as.IExpressionNode;
import org.apache.flex.compiler.tree.as.IFunctionNode;
import org.apache.flex.compiler.tree.as.IGetterNode;
import org.apache.flex.compiler.tree.as.IInterfaceNode;
import org.apache.flex.compiler.tree.as.IKeywordNode;
import org.apache.flex.compiler.tree.as.INamespaceNode;
import org.apache.flex.compiler.tree.as.IPackageNode;
import org.apache.flex.compiler.tree.as.IParameterNode;
import org.apache.flex.compiler.tree.as.IScopedNode;
import org.apache.flex.compiler.tree.as.ISetterNode;
import org.apache.flex.compiler.tree.as.ITypeNode;
import org.apache.flex.compiler.tree.as.IVariableNode;
import org.apache.flex.compiler.visitor.IASBlockWalker;

/**
 * The base implementation for an ActionScript emitter.
 * 
 * @author Michael Schmalle
 */
public class ASEmitter implements IASEmitter
{
    private static final String SPACE = " ";

    protected static final String NL = "\n";

    protected static final String INDENT_STRING = "\t";

    private final FilterWriter out;

    private IDocEmitter docEmitter;

    @Override
    public IDocEmitter getDocEmitter()
    {
        return docEmitter;
    }

    @Override
    public void setDocEmitter(IDocEmitter value)
    {
        docEmitter = value;
    }

    private int currentIndent = 0;

    protected int getCurrentIndent()
    {
        return currentIndent;
    }

    private IASBlockWalker walker;

    @Override
    public IASBlockWalker getWalker()
    {
        return walker;
    }

    @Override
    public void setWalker(IASBlockWalker value)
    {
        walker = value;
    }

    public ASEmitter(FilterWriter out)
    {
        this.out = out;
    }

    @Override
    public void write(String value)
    {
        try
        {
            out.write(value);

            final StringBuilder sb = new StringBuilder();
            if (value.indexOf(NL) != -1)
            {
                for (int i = 0; i < currentIndent; i++)
                    sb.append(INDENT_STRING);

                out.write(sb.toString());
            }
        }
        catch (IOException e)
        {
            throw new RuntimeException(e);
        }
    }

    protected String getIndent(int numIndent)
    {
        final StringBuilder sb = new StringBuilder();
        for (int i = 0; i < numIndent; i++)
            sb.append(INDENT_STRING);
        return sb.toString();
    }

    @Override
    public void indentPush()
    {
        currentIndent++;
    }

    @Override
    public void indentPop()
    {
        currentIndent--;
    }

    // (erikdebruin) I needed a way to add a semi-colon after the closing curly
    //               bracket of a block in the 'goog'-ified output. Instead of 
    // 				 subclassing 'ASAfterNodeStrategy' and  copying
    //               the entire function body, I thought I might use this little
    //               utility method and override that. Am I doing it right?
    public void writeBlockClose()
    {
        write("}");
    }

    public void writeIndent()
    {
        String indent = "";
        for (int i = 0; i < currentIndent; i++)
            indent += INDENT_STRING;
        write(indent);
    }

    public void writeNewline()
    {
        write(NL);
    }

    public void writeToken(String value)
    {
        write(value);
    }

    public void writeSymbol(String value)
    {
        write(value);
    }

    //--------------------------------------------------------------------------
    // IPackageNode
    //--------------------------------------------------------------------------

    @Override
    public void emitPackageHeader(IPackageNode node)
    {
        writeToken(IASKeywordConstants.PACKAGE);

        String name = node.getQualifiedName();
        if (name != null && !name.equals(""))
        {
            write(SPACE);
            getWalker().walk(node.getNameExpressionNode());
        }

        write(SPACE);
        write("{");
    }

    @Override
    public void emitPackageHeaderContents(IPackageNode node)
    {
    }

    @Override
    public void emitPackageContents(IPackageNode node)
    {
        ITypeNode tnode = findTypeNode(node);
        if (tnode != null)
        {
            indentPush();
            write(NL);
            getWalker().walk(tnode); // IClassNode | IInterfaceNode
        }
    }

    @Override
    public void emitPackageFooter(IPackageNode node)
    {
        indentPop();
        write(NL);
        write("}");
    }

    //--------------------------------------------------------------------------
    // 
    //--------------------------------------------------------------------------

    @Override
    public void emitClass(IClassNode node)
    {
        write(node.getNamespace());
        write(SPACE);

        if (node.hasModifier(ASModifier.FINAL))
        {
            writeToken(IASKeywordConstants.FINAL);
            write(SPACE);
        }
        else if (node.hasModifier(ASModifier.DYNAMIC))
        {
            writeToken(IASKeywordConstants.DYNAMIC);
            write(SPACE);
        }

        writeToken(IASKeywordConstants.CLASS);
        write(SPACE);
        getWalker().walk(node.getNameExpressionNode());
        write(SPACE);

        IExpressionNode bnode = node.getBaseClassExpressionNode();
        if (bnode != null)
        {
            writeToken(IASKeywordConstants.EXTENDS);
            write(SPACE);
            getWalker().walk(bnode);
            write(SPACE);
        }

        IExpressionNode[] inodes = node.getImplementedInterfaceNodes();
        final int ilen = inodes.length;
        if (ilen != 0)
        {
            writeToken(IASKeywordConstants.IMPLEMENTS);
            write(SPACE);
            for (int i = 0; i < ilen; i++)
            {
                getWalker().walk(inodes[i]);
                if (i < ilen - 1)
                {
                    write(",");
                    write(SPACE);
                }
            }
            write(SPACE);
        }

        write("{");

        // fields, methods, namespaces
        final IDefinitionNode[] members = node.getAllMemberNodes();
        if (members.length > 0)
        {
            indentPush();
            write(NL);

            final int len = members.length;
            int i = 0;
            for (IDefinitionNode mnode : members)
            {
                getWalker().walk(mnode);
                if (mnode.getNodeID() == ASTNodeID.VariableID)
                {
                    write(";");
                    if (i < len - 1)
                        write(NL);
                }
                else if (mnode.getNodeID() == ASTNodeID.FunctionID)
                {
                    if (i < len - 1)
                        write(NL);
                }
                else if (mnode.getNodeID() == ASTNodeID.GetterID
                        || mnode.getNodeID() == ASTNodeID.SetterID)
                {
                    if (i < len - 1)
                        write(NL);
                }
                i++;
            }

            indentPop();
        }

        write(NL);
        write("}");
    }

    @Override
    public void emitInterface(IInterfaceNode node)
    {
        write(node.getNamespace());
        write(SPACE);

        writeToken(IASKeywordConstants.INTERFACE);
        write(SPACE);
        getWalker().walk(node.getNameExpressionNode());
        write(SPACE);

        IExpressionNode[] inodes = node.getExtendedInterfaceNodes();
        final int ilen = inodes.length;
        if (ilen != 0)
        {
            writeToken(IASKeywordConstants.EXTENDS);
            write(SPACE);
            for (int i = 0; i < ilen; i++)
            {
                getWalker().walk(inodes[i]);
                if (i < ilen - 1)
                {
                    write(",");
                    write(SPACE);
                }
            }
            write(SPACE);
        }

        write("{");

        final IDefinitionNode[] members = node.getAllMemberDefinitionNodes();
        if (members.length > 0)
        {
            indentPush();
            write(NL);

            // TODO (mschmalle) Check to see if the node order is the order of member parsed
            final int len = members.length;
            int i = 0;
            for (IDefinitionNode mnode : members)
            {
                getWalker().walk(mnode);
                write(";");
                if (i < len - 1)
                    write(NL);
                i++;
            }

            indentPop();
        }

        write(NL);
        write("}");
    }

    //--------------------------------------------------------------------------
    // 
    //--------------------------------------------------------------------------

    @Override
    public void emitVarDeclaration(IVariableNode node)
    {
        if (!(node instanceof ChainedVariableNode))
        {
            emitMemberKeyword(node);
        }

        emitDeclarationName(node);
        emitType(node.getVariableTypeNode());
        emitAssignedValue(node.getAssignedValueNode());

        if (!(node instanceof ChainedVariableNode))
        {
            // check for chained variables
            int len = node.getChildCount();
            for (int i = 0; i < len; i++)
            {
                IASNode child = node.getChild(i);
                if (child instanceof ChainedVariableNode)
                {
                    write(",");
                    write(SPACE);
                    emitVarDeclaration((IVariableNode) child);
                }
            }
        }

        // the client such as IASBlockWalker is responsible for the 
        // semi-colon and newline handling
    }

    //--------------------------------------------------------------------------
    // 
    //--------------------------------------------------------------------------

    @Override
    public void emitFieldDocumentation(IVariableNode node)
    {
    }

    @Override
    public void emitField(IVariableNode node)
    {
        emitFieldDocumentation(node);

        IVariableDefinition definition = (IVariableDefinition) node
                .getDefinition();

        if (!(node instanceof ChainedVariableNode))
        {
            emitNamespaceIdentifier(node);
            emitModifiers(definition);
            emitMemberKeyword(node);
        }

        emitMemberName(node);
        emitType(node.getVariableTypeNode());
        emitAssignedValue(node.getAssignedValueNode());

        if (!(node instanceof ChainedVariableNode))
        {
            // check for chained variables
            int len = node.getChildCount();
            for (int i = 0; i < len; i++)
            {
                IASNode child = node.getChild(i);
                if (child instanceof ChainedVariableNode)
                {
                    write(",");
                    write(SPACE);
                    emitField((IVariableNode) child);
                }
            }
        }

        // the client such as IASBlockWalker is responsible for the 
        // semi-colon and newline handling
    }

    //--------------------------------------------------------------------------
    // 
    //--------------------------------------------------------------------------

    @Override
    public void emitMethodDocumentation(IFunctionNode node)
    {
    }

    @Override
    public void emitMethod(IFunctionNode node)
    {
        // see below, this is temp, I don't want a bunch of duplicated code
        // at them moment, subclasses can refine anyways, we are generalizing
        if (node instanceof IGetterNode)
        {
            emitGetAccessorDocumentation((IGetterNode) node);
        }
        else if (node instanceof ISetterNode)
        {
            emitSetAccessorDocumentation((ISetterNode) node);
        }
        else
        {
            emitMethodDocumentation(node);
        }

        FunctionNode fn = (FunctionNode) node;
        // XXX (mschmalle) parseFunctionBody() TEMP until I figure out the correct way to do this
        // will need to pass these problems back to the visitor
        // Figure out where this is getting parsed!
        fn.parseFunctionBody(new ArrayList<ICompilerProblem>());

        IFunctionDefinition definition = node.getDefinition();

        emitNamespaceIdentifier(node);
        emitModifiers(definition);
        emitMemberKeyword(node);

        // TODO (mschmalle) I'm cheating right here, I haven't "seen" the light
        // on how to properly and efficiently deal with accessors since they are SO alike
        // I don't want to lump them in with methods because implementations in the
        // future need to know the difference without loopholes
        if (node instanceof IAccessorNode)
        {
            emitAccessorKeyword(((IAccessorNode) node).getAccessorKeywordNode());
        }

        emitMemberName(node);
        emitParamters(node.getParameterNodes());
        emitType(node.getReturnTypeNode());
        if (node.getParent().getParent().getNodeID() == ASTNodeID.ClassID)
        {
            emitMethodScope(node.getScopedNode());
        }

        // the client such as IASBlockWalker is responsible for the 
        // semi-colon and newline handling
    }

    @Override
    public void emitGetAccessorDocumentation(IGetterNode node)
    {
    }

    @Override
    public void emitGetAccessor(IGetterNode node)
    {
        // just cheat for now, IGetterNode is a IFunctionNode
        emitMethod(node);
    }

    @Override
    public void emitSetAccessorDocumentation(ISetterNode node)
    {
    }

    @Override
    public void emitSetAccessor(ISetterNode node)
    {
        // just cheat for now, ISetterNode is a IFunctionNode
        emitMethod(node);
    }

    @Override
    public void emitFunctionObject(IExpressionNode node)
    {
        FunctionObjectNode f = (FunctionObjectNode) node;
        FunctionNode fnode = f.getFunctionNode();
        writeToken(IASKeywordConstants.FUNCTION);
        emitParamters(fnode.getParameterNodes());
        emitType(fnode.getTypeNode());
        emitFunctionScope(fnode.getScopedNode());
    }

    //--------------------------------------------------------------------------
    // 
    //--------------------------------------------------------------------------

    @Override
    public void emitNamespace(INamespaceNode node)
    {
        emitNamespaceIdentifier(node);
        writeToken(IASKeywordConstants.NAMESPACE);
        write(SPACE);
        emitMemberName(node);
        write(SPACE);
        write("=");
        write(SPACE);
        getWalker().walk(node.getNamespaceURINode());
    }

    //--------------------------------------------------------------------------
    // 
    //--------------------------------------------------------------------------

    protected void emitNamespaceIdentifier(IDefinitionNode node)
    {
        String namespace = node.getNamespace();
        if (namespace != null
                && !namespace.equals(IASKeywordConstants.INTERNAL))
        {
            write(namespace);
            write(SPACE);
        }
    }

    protected void emitModifiers(IDefinition definition)
    {
        ModifiersSet modifierSet = definition.getModifiers();
        if (modifierSet.hasModifiers())
        {
            for (ASModifier modifier : modifierSet.getAllModifiers())
            {
                write(modifier.toString());
                write(SPACE);
            }
        }
    }

    protected void emitMemberKeyword(IDefinitionNode node)
    {
        if (node instanceof IFunctionNode)
        {
            writeToken(IASKeywordConstants.FUNCTION);
            write(SPACE);
        }
        else if (node instanceof IVariableNode)
        {
            write(((IVariableNode) node).isConst() ? "const" : "var");
            write(SPACE);
        }
    }

    protected void emitMemberName(IDefinitionNode node)
    {
        getWalker().walk(node.getNameExpressionNode());
    }

    protected void emitDeclarationName(IDefinitionNode node)
    {
        getWalker().walk(node.getNameExpressionNode());
    }

    protected void emitParamters(IParameterNode[] nodes)
    {
        write("(");
        int len = nodes.length;
        for (int i = 0; i < len; i++)
        {
            IParameterNode node = nodes[i];
            // this will call emitParameter(node)
            getWalker().walk(node);
            if (i < len - 1)
                write(", ");
        }
        write(")");
    }

    @Override
    public void emitParameter(IParameterNode node)
    {
        getWalker().walk(node.getNameExpressionNode());
        write(":");
        getWalker().walk(node.getVariableTypeNode());
        IExpressionNode anode = node.getAssignedValueNode();
        if (anode != null)
        {
            write(" = ");
            getWalker().walk(anode);
        }
    }

    protected void emitType(IExpressionNode node)
    {
        // TODO (mschmalle) node.getVariableTypeNode() will return "*" if undefined, what to use?
        // or node.getReturnTypeNode()
        if (node != null)
        {
            write(":");
            getWalker().walk(node);
        }
    }

    protected void emitAssignedValue(IExpressionNode node)
    {
        if (node != null)
        {
            write(SPACE);
            write("=");
            write(SPACE);
            getWalker().walk(node);
        }
    }

    @Override
    public void emitFunctionBlockHeader(IFunctionNode node)
    {
        // nothing to do in AS
    }

    protected void emitMethodScope(IScopedNode node)
    {
        write(SPACE);
        getWalker().walk(node);
    }

    protected void emitAccessorKeyword(IKeywordNode node)
    {
        getWalker().walk(node);
        write(SPACE);
    }

    protected void emitFunctionScope(IScopedNode node)
    {
        // TODO (mschmalle) FunctionObjectNode; does this need specific treatment?
        emitMethodScope(node);
    }

    protected ITypeNode findTypeNode(IPackageNode node)
    {
        IScopedNode scope = node.getScopedNode();
        for (int i = 0; i < scope.getChildCount(); i++)
        {
            IASNode child = scope.getChild(i);
            if (child instanceof ITypeNode)
                return (ITypeNode) child;
        }
        return null;
    }

    protected static IFunctionNode getConstructor(IDefinitionNode[] members)
    {
        for (IDefinitionNode node : members)
        {
            if (node instanceof IFunctionNode)
            {
                IFunctionNode fnode = (IFunctionNode) node;
                if (fnode.isConstructor())
                    return fnode;
            }
        }
        return null;
    }

    //--------------------------------------------------------------------------
    // Operators
    //--------------------------------------------------------------------------

    @Override
    public void emitBinaryOperator(IBinaryOperatorNode node)
    {
        getWalker().walk(node.getLeftOperandNode());
        if (node.getNodeID() != ASTNodeID.Op_CommaID)
            write(SPACE);
        write(node.getOperator().getOperatorText());
        write(SPACE);
        getWalker().walk(node.getRightOperandNode());
    }

}
