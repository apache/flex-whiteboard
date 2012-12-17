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

import org.apache.flex.as.IASEmitter;
import org.apache.flex.compiler.common.ASModifier;
import org.apache.flex.compiler.common.ModifiersSet;
import org.apache.flex.compiler.definitions.IVariableDefinition;
import org.apache.flex.compiler.definitions.references.INamespaceReference;
import org.apache.flex.compiler.tree.as.IExpressionNode;
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
    public void emitField(IVariableNode node)
    {
        emitDocumentation(node);
        
        IVariableDefinition definition = (IVariableDefinition) node
                .getDefinition();
        
        // namespace (public, protected, private, foo_bar)
        // TODO (mschmalle) figure out what to do if there is an explicit internal
        // right now if it's internal, code not produced (implied)
        if (!definition.isInternal())
        {
            INamespaceReference reference = definition.getNamespaceReference();
            write(reference.getBaseName());
            write(" ");
        }
        
        // madofiers (static)
        ModifiersSet modifierSet = definition.getModifiers();
        if (modifierSet.hasModifiers())
        {
            for (ASModifier modifier : modifierSet.getAllModifiers())
            {
                write(modifier.toString());
                write(" ");
            }
        }
        
        // keyword
        write(node.isConst() ? "const" : "var");
        write(" ");
        // name
        getVisitor().walk(node.getNameExpressionNode());
        
        // type
        IExpressionNode tnode = node.getVariableTypeNode();
        // TODO (mschmalle) node.getVariableTypeNode() will return "*" if undefined, what to use?
        if (tnode != null)
        {
            write(":");
            getVisitor().walk(tnode);
        }
        
        // assigned value
        IExpressionNode vnode = node.getAssignedValueNode();
        if (vnode != null)
        {
            write(" ");
            write("=");
            write(" ");
            getVisitor().walk(vnode);
        }
        // the client such as IASBlockWalker is responsible for the 
        // semi-colon and newline handling
    }

    public void emitDocumentation(IVariableNode node)
    {
    }
}
