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

package org.apache.flex.compiler.internal.js.codegen;

import java.io.FilterWriter;

import org.apache.flex.compiler.internal.as.codegen.ASEmitter;
import org.apache.flex.compiler.internal.tree.as.ChainedVariableNode;
import org.apache.flex.compiler.internal.tree.as.FunctionNode;
import org.apache.flex.compiler.internal.tree.as.FunctionObjectNode;
import org.apache.flex.compiler.js.codegen.IJSEmitter;
import org.apache.flex.compiler.tree.as.IASNode;
import org.apache.flex.compiler.tree.as.IExpressionNode;
import org.apache.flex.compiler.tree.as.IFunctionNode;
import org.apache.flex.compiler.tree.as.IVariableNode;

/**
 * @author Michael Schmalle
 */
public class JSEmitter extends ASEmitter implements IJSEmitter
{

    public JSEmitter(FilterWriter out)
    {
        super(out);
    }

    public void emitConstructor(IFunctionNode node)
    {
        // for now, we just call back, this is to allow custom handling
        // straight from the emitter
        getWalker().visitConstructor(node);
    }

    @Override
    public void emitFunctionObject(IExpressionNode node)
    {
        FunctionObjectNode f = (FunctionObjectNode) node;
        
        FunctionNode fnode = f.getFunctionNode();
        
        write("function");
        
        emitParamters(fnode.getParameterNodes());
       
        emitFunctionScope(fnode.getScopedNode());
    }

    @Override
    public void emitVarDeclaration(IVariableNode node)
    {
        if (!(node instanceof ChainedVariableNode))
        {
            emitMemberKeyword(node);
        }

        emitDeclarationName(node);
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
    }
}
