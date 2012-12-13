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

package org.apache.flex.compiler.internal.visitor;

import java.io.IOException;
import java.util.Collection;

import org.apache.flex.compiler.definitions.IAccessorDefinition;
import org.apache.flex.compiler.definitions.IClassDefinition;
import org.apache.flex.compiler.definitions.IConstantDefinition;
import org.apache.flex.compiler.definitions.IFunctionDefinition;
import org.apache.flex.compiler.definitions.IInterfaceDefinition;
import org.apache.flex.compiler.definitions.INamespaceDefinition;
import org.apache.flex.compiler.definitions.IPackageDefinition;
import org.apache.flex.compiler.definitions.IVariableDefinition;
import org.apache.flex.compiler.internal.units.SWCCompilationUnit;
import org.apache.flex.compiler.projects.IASProject;
import org.apache.flex.compiler.units.ICompilationUnit;
import org.apache.flex.compiler.visitor.IASTVisitor;
import org.apache.flex.compiler.visitor.IASWalker;

/**
 * @author Michael Schmalle
 */
public class JSWalker implements IASWalker
{
    private IASTVisitor visitor;

    private IASProject project;

    public JSWalker()
    {
    }

    @Override
    public void walkProject(IASProject element) throws IOException
    {
        this.project = element;

        Collection<ICompilationUnit> units = project.getCompilationUnits();
        for (ICompilationUnit unit : units)
        {
            System.out.println(unit.getDefinitionPromises().toString());
            if (unit instanceof SWCCompilationUnit)
                continue;
            walkCompilationUnit(unit);
        }

        this.project = null;
    }

    @Override
    public void walkCompilationUnit(ICompilationUnit element) throws IOException
    {
        visitor.visitCompilationUnit(element);

    }

    @Override
    public void walkPackage(IPackageDefinition element)
    {
        // TODO Auto-generated method stub

    }

    @Override
    public void walkClass(IClassDefinition element)
    {
        // TODO Auto-generated method stub

    }

    @Override
    public void walkInterface(IInterfaceDefinition element)
    {
        // TODO Auto-generated method stub

    }

    @Override
    public void walkNamespace(INamespaceDefinition element)
    {
        // TODO Auto-generated method stub

    }

    @Override
    public void walkFunction(IFunctionDefinition element)
    {
        // TODO Auto-generated method stub

    }

    @Override
    public void walkAccessor(IAccessorDefinition definition)
    {
        // TODO Auto-generated method stub

    }

    @Override
    public void walkVariable(IVariableDefinition element)
    {
        // TODO Auto-generated method stub

    }

    @Override
    public void walkConstant(IConstantDefinition element)
    {
        // TODO Auto-generated method stub

    }

}
