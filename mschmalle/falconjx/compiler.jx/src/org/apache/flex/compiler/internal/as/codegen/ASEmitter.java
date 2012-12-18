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

import org.apache.flex.as.IASEmitter;
import org.apache.flex.compiler.common.ASModifier;
import org.apache.flex.compiler.common.ModifiersSet;
import org.apache.flex.compiler.definitions.IDefinition;
import org.apache.flex.compiler.definitions.IFunctionDefinition;
import org.apache.flex.compiler.definitions.IVariableDefinition;
import org.apache.flex.compiler.definitions.references.INamespaceReference;
import org.apache.flex.compiler.internal.tree.as.FunctionNode;
import org.apache.flex.compiler.problems.ICompilerProblem;
import org.apache.flex.compiler.tree.as.IAccessorNode;
import org.apache.flex.compiler.tree.as.IDefinitionNode;
import org.apache.flex.compiler.tree.as.IExpressionNode;
import org.apache.flex.compiler.tree.as.IFunctionNode;
import org.apache.flex.compiler.tree.as.IGetterNode;
import org.apache.flex.compiler.tree.as.IKeywordNode;
import org.apache.flex.compiler.tree.as.IParameterNode;
import org.apache.flex.compiler.tree.as.IScopedNode;
import org.apache.flex.compiler.tree.as.ISetterNode;
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

    private int currentIndent = 0;

    private IASBlockWalker visitor;

    public IASBlockWalker getVisitor()
    {
        return visitor;
    }

    public void setVisitor(IASBlockWalker value)
    {
        visitor = value;
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

        emitNamespace(definition);
        emitModifiers(definition);
        emitMemberKeyword(node);
        emitMemberName(node);
        emitType(node.getVariableTypeNode());
        emitAssignedValue(node.getAssignedValueNode());
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
        emitMethodDocumentation(node);

        FunctionNode fn = (FunctionNode) node;
        // XXX (mschmalle) parseFunctionBody() TEMP until I figure out the correct way to do this
        // will need to pass these problems back to the visitor
        fn.parseFunctionBody(new ArrayList<ICompilerProblem>());

        IFunctionDefinition definition = node.getDefinition();

        emitNamespace(definition);
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
        emitMethodScope(node.getScopedNode());
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
        getVisitor().walk(node.getNameExpressionNode());
    }

    protected void emitParamters(IParameterNode[] nodes)
    {
        write("(");
        int len = nodes.length;
        for (int i = 0; i < len; i++)
        {
            IParameterNode node = nodes[i];
            getVisitor().walk(node);
            if (i < len - 1)
                write(", ");
        }
        write(")");
    }

    protected void emitType(IExpressionNode node)
    {
        // TODO (mschmalle) node.getVariableTypeNode() will return "*" if undefined, what to use?
        // or node.getReturnTypeNode()
        if (node != null)
        {
            write(":");
            getVisitor().walk(node);
        }
    }

    protected void emitAssignedValue(IExpressionNode node)
    {
        if (node != null)
        {
            write(" ");
            write("=");
            write(" ");
            getVisitor().walk(node);
        }
    }

    protected void emitMethodScope(IScopedNode node)
    {
        write(" ");
        getVisitor().walk(node);
    }

    protected void emitAccessorKeyword(IKeywordNode node)
    {
        getVisitor().walk(node);
        write(" ");
    }
}
