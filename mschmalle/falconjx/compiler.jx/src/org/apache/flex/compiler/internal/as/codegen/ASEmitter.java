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
import org.apache.flex.compiler.definitions.IDefinition;
import org.apache.flex.compiler.definitions.IFunctionDefinition;
import org.apache.flex.compiler.definitions.IVariableDefinition;
import org.apache.flex.compiler.definitions.references.INamespaceReference;
import org.apache.flex.compiler.internal.tree.as.ChainedVariableNode;
import org.apache.flex.compiler.internal.tree.as.FunctionNode;
import org.apache.flex.compiler.internal.tree.as.FunctionObjectNode;
import org.apache.flex.compiler.problems.ICompilerProblem;
import org.apache.flex.compiler.tree.ASTNodeID;
import org.apache.flex.compiler.tree.as.IASNode;
import org.apache.flex.compiler.tree.as.IAccessorNode;
import org.apache.flex.compiler.tree.as.IDefinitionNode;
import org.apache.flex.compiler.tree.as.IExpressionNode;
import org.apache.flex.compiler.tree.as.IFunctionNode;
import org.apache.flex.compiler.tree.as.IGetterNode;
import org.apache.flex.compiler.tree.as.IKeywordNode;
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

            String indent = "";
            if (value.indexOf(NL) != -1)
            {
                // TODO (mschmalle) is StringBuilder faster?
                for (int i = 0; i < currentIndent; i++)
                    indent += INDENT_STRING;

                out.write(indent);
            }
        }
        catch (IOException e)
        {
            throw new RuntimeException(e);
        }
    }
    
    protected String getIndent(int numIndent)
    {
        String indent = "";
        for (int i = 0; i < numIndent; i++)
            indent += INDENT_STRING;
        return indent;
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
        write("package");

        String name = node.getQualifiedName();
        if (name != null && !name.equals(""))
        {
            write(" ");
            getWalker().walk(node.getNameExpressionNode());
        }

        write(" ");
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
            write("\n");
            getWalker().walk(tnode); // IClassNode | IInterfaceNode
        }
    }

    @Override
    public void emitPackageFooter(IPackageNode node)
    {
        indentPop();
        write("\n");
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
                    write(" ");
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
            emitNamespace2(node);
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
                    write(" ");
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

        emitNamespace2(node);
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
        write("function");
        emitParamters(fnode.getParameterNodes());
        emitType(fnode.getTypeNode());
        emitFunctionScope(fnode.getScopedNode());
    }

    //--------------------------------------------------------------------------
    // 
    //--------------------------------------------------------------------------

    protected void emitNamespace2(IDefinitionNode node)
    {
        String namespace = node.getNamespace();
        if (namespace != null && !namespace.equals("internal"))
        {
            write(namespace);
            write(" ");
        }
    }

    protected void emitNamespace(IDefinition definition)
    {
        // namespace (public, protected, private, foo_bar)
        // TODO (mschmalle) figure out what to do if there is an explicit internal
        // right now if it's internal, code not produced (implied)
        if (!definition.isInternal())
        {
            INamespaceReference reference = definition.getNamespaceReference();
            write(reference.getBaseName());
            write(" ");
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
                write(" ");
            }
        }
    }

    protected void emitMemberKeyword(IDefinitionNode node)
    {
        if (node instanceof IFunctionNode)
        {
            write("function");
            write(" ");
        }
        else if (node instanceof IVariableNode)
        {
            write(((IVariableNode) node).isConst() ? "const" : "var");
            write(" ");
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
            write(" ");
            write("=");
            write(" ");
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
        write(" ");
        getWalker().walk(node);
    }

    protected void emitAccessorKeyword(IKeywordNode node)
    {
        getWalker().walk(node);
        write(" ");
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

}
