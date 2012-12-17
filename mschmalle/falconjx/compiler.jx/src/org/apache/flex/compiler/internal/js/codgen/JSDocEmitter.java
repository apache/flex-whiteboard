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

import org.apache.flex.compiler.definitions.IClassDefinition;
import org.apache.flex.compiler.definitions.ITypeDefinition;
import org.apache.flex.compiler.js.IJSDocEmitter;
import org.apache.flex.compiler.tree.as.IASNode;
import org.apache.flex.compiler.tree.as.IClassNode;
import org.apache.flex.compiler.tree.as.IFunctionNode;
import org.apache.flex.compiler.tree.as.IPackageNode;
import org.apache.flex.compiler.tree.as.IParameterNode;
import org.apache.flex.compiler.tree.as.IVariableNode;

public class JSDocEmitter implements IJSDocEmitter
{

    private JSEmitter emitter;

    public JSDocEmitter(JSEmitter emitter)
    {
        this.emitter = emitter;
    }

    @Override
    public void emitConst(IVariableNode node)
    {
        // TODO Auto-generated method stub

    }

    @Override
    public void emitConstructor(IFunctionNode node)
    {
        emitter.write(" * @constructor\n");
    }

    @Override
    public void emitDefine(IVariableNode node)
    {
        // TODO Auto-generated method stub

    }

    @Override
    public void emitDeprecated(IASNode node)
    {
        // TODO Auto-generated method stub

    }

    @Override
    public void emitEnum(IClassNode node)
    {
        // TODO Auto-generated method stub

    }

    @Override
    public void emitExtends(IClassDefinition superDefinition)
    {
        emitter.write(" * @extends {" + superDefinition.getQualifiedName()
                + "}\n");
    }

    @Override
    public void emitImplements(IClassNode node)
    {
        // TODO Auto-generated method stub

    }

    @Override
    public void emitInheritDoc(IClassNode node)
    {
        // TODO Auto-generated method stub

    }

    @Override
    public void emitLicense(IClassNode node)
    {
        // TODO Auto-generated method stub

    }

    @Override
    public void emitOverride(IFunctionNode node)
    {
        // TODO Auto-generated method stub

    }

    @Override
    public void emitParam(IParameterNode node)
    {
        emitter.write(" * @param {" + node.getVariableType() + "} "
                + node.getName() + "\n");
    }

    @Override
    public void emitPrivate(IASNode node)
    {
        // TODO Auto-generated method stub

    }

    @Override
    public void emitProtected(IASNode node)
    {
        // TODO Auto-generated method stub

    }

    @Override
    public void emitReturn(IFunctionNode node)
    {
        // TODO convert js types
        String rtype = node.getReturnType();
        if (rtype != null)
            emitter.write(" * @return {" + rtype + "}\n");
    }

    @Override
    public void emitThis(ITypeDefinition type)
    {
        emitter.write(" * @this {" + type.getQualifiedName() + "}\n");
    }

    @Override
    public void emitType(IASNode node)
    {
        //String type = SemanticUtils.getTypeOfStem(node, emitter.getProject());
        String type = ((IVariableNode) node).getVariableType(); // XXX need to map to js types
        emitter.write(" * @type {" + type + "}\n");
    }

    @Override
    public void emitTypedef(IASNode node)
    {
        // TODO Auto-generated method stub

    }

    //--------------------------------------------------------------------------

    public void emmitPackageHeader(IPackageNode node)
    {
        begin();
        emitter.write(" * " + JSSharedData.getTimeStampString());
        end();
    }

    public void begin()
    {
        emitter.write("/**\n");
    }

    public void end()
    {
        emitter.write(" */\n");
    }

}
