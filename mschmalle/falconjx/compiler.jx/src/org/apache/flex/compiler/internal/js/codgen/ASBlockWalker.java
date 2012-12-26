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

import java.util.ArrayList;
import java.util.List;
import java.util.Stack;

import org.apache.flex.compiler.as.IASEmitter;
import org.apache.flex.compiler.common.ASModifier;
import org.apache.flex.compiler.definitions.IClassDefinition;
import org.apache.flex.compiler.definitions.IInterfaceDefinition;
import org.apache.flex.compiler.definitions.ITypeDefinition;
import org.apache.flex.compiler.internal.semantics.SemanticUtils;
import org.apache.flex.compiler.internal.tree.as.BaseLiteralContainerNode;
import org.apache.flex.compiler.internal.tree.as.ContainerNode;
import org.apache.flex.compiler.internal.tree.as.FunctionCallNode;
import org.apache.flex.compiler.internal.tree.as.FunctionObjectNode;
import org.apache.flex.compiler.internal.tree.as.LabeledStatementNode;
import org.apache.flex.compiler.internal.tree.as.NamespaceAccessExpressionNode;
import org.apache.flex.compiler.internal.tree.as.VariableExpressionNode;
import org.apache.flex.compiler.problems.ICompilerProblem;
import org.apache.flex.compiler.projects.IASProject;
import org.apache.flex.compiler.tree.ASTNodeID;
import org.apache.flex.compiler.tree.as.IASNode;
import org.apache.flex.compiler.tree.as.IBinaryOperatorNode;
import org.apache.flex.compiler.tree.as.IBlockNode;
import org.apache.flex.compiler.tree.as.ICatchNode;
import org.apache.flex.compiler.tree.as.IClassNode;
import org.apache.flex.compiler.tree.as.IConditionalNode;
import org.apache.flex.compiler.tree.as.IContainerNode;
import org.apache.flex.compiler.tree.as.IContainerNode.ContainerType;
import org.apache.flex.compiler.tree.as.IDefaultXMLNamespaceNode;
import org.apache.flex.compiler.tree.as.IDefinitionNode;
import org.apache.flex.compiler.tree.as.IDynamicAccessNode;
import org.apache.flex.compiler.tree.as.IEmbedNode;
import org.apache.flex.compiler.tree.as.IExpressionNode;
import org.apache.flex.compiler.tree.as.IFileNode;
import org.apache.flex.compiler.tree.as.IForLoopNode;
import org.apache.flex.compiler.tree.as.IForLoopNode.ForLoopKind;
import org.apache.flex.compiler.tree.as.IFunctionCallNode;
import org.apache.flex.compiler.tree.as.IFunctionNode;
import org.apache.flex.compiler.tree.as.IGetterNode;
import org.apache.flex.compiler.tree.as.IIdentifierNode;
import org.apache.flex.compiler.tree.as.IIfNode;
import org.apache.flex.compiler.tree.as.IInterfaceNode;
import org.apache.flex.compiler.tree.as.IIterationFlowNode;
import org.apache.flex.compiler.tree.as.IKeywordNode;
import org.apache.flex.compiler.tree.as.ILanguageIdentifierNode;
import org.apache.flex.compiler.tree.as.ILiteralNode;
import org.apache.flex.compiler.tree.as.ILiteralNode.LiteralType;
import org.apache.flex.compiler.tree.as.IMemberAccessExpressionNode;
import org.apache.flex.compiler.tree.as.INamespaceNode;
import org.apache.flex.compiler.tree.as.INumericLiteralNode;
import org.apache.flex.compiler.tree.as.IObjectLiteralValuePairNode;
import org.apache.flex.compiler.tree.as.IPackageNode;
import org.apache.flex.compiler.tree.as.IParameterNode;
import org.apache.flex.compiler.tree.as.IReturnNode;
import org.apache.flex.compiler.tree.as.IScopedNode;
import org.apache.flex.compiler.tree.as.ISetterNode;
import org.apache.flex.compiler.tree.as.IStatementNode;
import org.apache.flex.compiler.tree.as.ISwitchNode;
import org.apache.flex.compiler.tree.as.ITerminalNode;
import org.apache.flex.compiler.tree.as.ITernaryOperatorNode;
import org.apache.flex.compiler.tree.as.IThrowNode;
import org.apache.flex.compiler.tree.as.ITryNode;
import org.apache.flex.compiler.tree.as.ITypeNode;
import org.apache.flex.compiler.tree.as.ITypedExpressionNode;
import org.apache.flex.compiler.tree.as.IUnaryOperatorNode;
import org.apache.flex.compiler.tree.as.IVariableNode;
import org.apache.flex.compiler.tree.as.IWhileLoopNode;
import org.apache.flex.compiler.tree.as.IWhileLoopNode.WhileLoopKind;
import org.apache.flex.compiler.tree.as.IWithNode;
import org.apache.flex.compiler.tree.metadata.IMetaTagNode;
import org.apache.flex.compiler.tree.metadata.IMetaTagsNode;
import org.apache.flex.compiler.units.ICompilationUnit;
import org.apache.flex.compiler.visitor.IASBlockVisitor;
import org.apache.flex.compiler.visitor.IASBlockWalker;
import org.apache.flex.compiler.visitor.IASNodeStrategy;

/**
 * A base implementation of the {@link IASBlockVisitor} that will walk the
 * {@link ICompilationUnit}s AST {@link IASNode} hierarchy.
 * 
 * @author Michael Schmalle
 */
public class ASBlockWalker implements IASBlockVisitor, IASBlockWalker
{
    /**
     * The context stack of the visitor.
     * <p>
     * The context can only contain what is beneath them, CLASS contains
     * FUNCTION.
     */
    // TODO (mschmalle) definitely having second thoughts about TraverseContext
    // now that I'm understanding the AST a bit more, this is just garbage overhead
    public enum TraverseContext
    {
        ROOT,
        FILE,
        PACKAGE,
        TYPE,
        CONSTRUCTOR,
        FIELD,
        METHOD,
        BLOCK,
        FOR,
        FUNCTION,
        SUPER_ARGUMENTS
    }

    private IASEmitter emitter;

    private final List<ICompilerProblem> errors;

    List<ICompilerProblem> getErrors()
    {
        return errors;
    }

    //----------------------------------
    // context
    //----------------------------------

    private Stack<TraverseContext> contexts = new Stack<ASBlockWalker.TraverseContext>();

    public void pushContext(TraverseContext value)
    {
        contexts.push(value);
    }

    public void popContext(TraverseContext lastContext)
    {
        TraverseContext popped = contexts.pop();
        if (lastContext != popped)
            throw new RuntimeException("Popped context not the same");
    }

    private boolean inContext(TraverseContext context)
    {
        return contexts.peek() == context;
    }

    //----------------------------------
    // strategy
    //----------------------------------

    private IASNodeStrategy strategy;

    public IASNodeStrategy getStrategy()
    {
        return strategy;
    }

    public void setStrategy(IASNodeStrategy value)
    {
        strategy = value;
    }

    //----------------------------------
    // project
    //----------------------------------

    private IASProject project;

    public IASProject getProject()
    {
        return project;
    }

    //----------------------------------
    // currentType
    //----------------------------------

    private ITypeDefinition typeDefinition;

    public ITypeDefinition getCurrentType()
    {
        return typeDefinition;
    }

    public IClassDefinition getCurrentClass()
    {
        return (IClassDefinition) typeDefinition;
    }

    public IInterfaceDefinition getCurrentInterface()
    {
        return (IInterfaceDefinition) typeDefinition;
    }

    //----------------------------------
    // currentConstructor
    //----------------------------------

    private IFunctionNode currentConstructor;

    public IFunctionNode getCurrentConstructor()
    {
        return currentConstructor;
    }

    public ASBlockWalker(List<ICompilerProblem> errors, IASProject project,
            IASEmitter emitter)
    {
        this.errors = errors;
        this.project = project;
        this.emitter = emitter;
        emitter.setWalker(this);
        pushContext(TraverseContext.ROOT);
    }

    @Override
    public void visitCompilationUnit(ICompilationUnit unit)
    {
        debug("visitCompilationUnit()");

        IFileNode node = null;
        try
        {
            node = (IFileNode) unit.getSyntaxTreeRequest().get().getAST();
        }
        catch (InterruptedException e)
        {
            throw new RuntimeException(e);
        }

        walk(node);
    }

    @Override
    public void visitFile(IFileNode node)
    {
        debug("visitFile()");
        pushContext(TraverseContext.FILE);
        walk(node.getChild(0)); // IPackageNode
        popContext(TraverseContext.FILE);
    }

    @Override
    public void visitPackage(IPackageNode node)
    {
        debug("visitPackage()");

        emitter.emitPackageHeader(node);
        emitter.emitPackageHeaderContents(node);
        emitter.emitPackageContents(node);
        emitter.emitPackageFooter(node);
    }

    @Override
    public void visitClass(IClassNode node)
    {
        typeDefinition = node.getDefinition();

        debug("visitClass()");

        emitter.write(node.getNamespace());
        emitter.write(" ");

        if (node.hasModifier(ASModifier.FINAL))
        {
            emitter.write("final");
            emitter.write(" ");
        }
        emitter.write("class");
        emitter.write(" ");
        walk(node.getNameExpressionNode());
        emitter.write(" ");

        IExpressionNode bnode = node.getBaseClassExpressionNode();
        if (bnode != null)
        {
            emitter.write("extends");
            emitter.write(" ");
            walk(bnode);
            emitter.write(" ");
        }

        IExpressionNode[] inodes = node.getImplementedInterfaceNodes();
        final int ilen = inodes.length;
        if (ilen != 0)
        {
            emitter.write("implements");
            emitter.write(" ");
            for (int i = 0; i < ilen; i++)
            {
                walk(inodes[i]);
                if (i < ilen - 1)
                {
                    emitter.write(",");
                    emitter.write(" ");
                }
            }
            emitter.write(" ");
        }

        emitter.write("{");

        // fields, methods, namespaces
        final IDefinitionNode[] members = node.getAllMemberNodes();
        if (members.length > 0)
        {
            emitter.indentPush();
            emitter.write("\n");

            // there is always an implicit constructor if not explicit
            currentConstructor = getConstructor(members);
            if (currentConstructor == null)
            {
                // TODO (mschmalle) handle null constructor
            }

            // TODO (mschmalle) Check to see if the node order is the order of member parsed
            final int len = members.length;
            int i = 0;
            for (IDefinitionNode mnode : members)
            {
                walk(mnode);
                if (mnode.getNodeID() == ASTNodeID.VariableID)
                {
                    emitter.write(";");
                    if (i < len - 1)
                        emitter.write("\n");
                }
                else if (mnode.getNodeID() == ASTNodeID.FunctionID)
                {
                    if (i < len - 1)
                        emitter.write("\n");
                }
                else if (mnode.getNodeID() == ASTNodeID.GetterID
                        || mnode.getNodeID() == ASTNodeID.SetterID)
                {
                    if (i < len - 1)
                        emitter.write("\n");
                }
                i++;
            }

            emitter.indentPop();
        }

        emitter.write("\n");
        emitter.write("}");

        typeDefinition = null;
        currentConstructor = null;
    }

    @Override
    public void visitInterface(IInterfaceNode node)
    {
        debug("visitInterface()");
        typeDefinition = node.getDefinition();

        emitter.write(node.getNamespace());
        emitter.write(" ");

        emitter.write("interface");
        emitter.write(" ");
        walk(node.getNameExpressionNode());
        emitter.write(" ");

        IExpressionNode[] inodes = node.getExtendedInterfaceNodes();
        final int ilen = inodes.length;
        if (ilen != 0)
        {
            emitter.write("extends");
            emitter.write(" ");
            for (int i = 0; i < ilen; i++)
            {
                walk(inodes[i]);
                if (i < ilen - 1)
                {
                    emitter.write(",");
                    emitter.write(" ");
                }
            }
            emitter.write(" ");
        }

        emitter.write("{");

        final IDefinitionNode[] members = node.getAllMemberDefinitionNodes();
        if (members.length > 0)
        {
            emitter.indentPush();
            emitter.write("\n");

            // TODO (mschmalle) Check to see if the node order is the order of member parsed
            final int len = members.length;
            int i = 0;
            for (IDefinitionNode mnode : members)
            {
                walk(mnode);
                emitter.write(";");
                if (i < len - 1)
                    emitter.write("\n");
                i++;
            }

            emitter.indentPop();
        }

        emitter.write("\n");
        emitter.write("}");

        typeDefinition = null;
    }

    public void visitConstructor(IFunctionNode node)
    {
        // TODO (mschmalle) what to do about missing constructor node?
        if (node == null)
            return;
        debug("visitConstructor()");
        walk(node);
    }

    @Override
    public void visitVariable(IVariableNode node)
    {
        debug("visitVariable()");

        if (SemanticUtils.isMemberDefinition(node.getDefinition()))
        {
            emitter.emitField(node);
        }
        else
        {
            emitter.emitVarDeclaration(node);
        }
    }

    @Override
    public void visitFunction(IFunctionNode node)
    {
        // XXX (mschmalle) visitFunction() refactor, this is a mess
        debug("visitFunction()");

        if (SemanticUtils.isMemberDefinition(node.getDefinition()))
        {
            emitter.emitMethod(node);
            return; // TEMP
        }
        else if (node.getParent().getParent().getNodeID() == ASTNodeID.InterfaceID)
        {
            emitter.emitMethod(node);
            return; // TEMP
        }
    }

    @Override
    public void visitParameter(IParameterNode node)
    {
        debug("visitParameter()");
        emitter.emitParameter(node);
    }

    @Override
    public void visitGetter(IGetterNode node)
    {
        debug("visitGetter()");
        visitFunction(node);
    }

    @Override
    public void visitSetter(ISetterNode node)
    {
        debug("visitSetter()");
        visitFunction(node);
    }

    @Override
    public void visitNamespace(INamespaceNode node)
    {
        debug("visitNamespace()");
        // TODO (mschmalle) visitNamespace()
    }

    @Override
    public void visitFunctionCall(IFunctionCallNode node)
    {
        debug("visitFunctionCall()");
        if (node.isNewExpression())
        {
            emitter.write("new");
            emitter.write(" ");
        }

        walk(node.getNameNode());

        if (((FunctionCallNode) node).isSuperExpression())
        {
            pushContext(TraverseContext.SUPER_ARGUMENTS);
        }

        emitter.write("(");
        walkArguments(node.getArgumentNodes());
        emitter.write(")");

        if (((FunctionCallNode) node).isSuperExpression())
        {
            popContext(TraverseContext.SUPER_ARGUMENTS);
        }
    }

    private void walkArguments(IExpressionNode[] nodes)
    {
        if (inContext(TraverseContext.SUPER_ARGUMENTS))
        {
            //emitter.write("this");
            //if (nodes.length > 0)
            //    emitter.write(", ");
        }

        int len = nodes.length;
        for (int i = 0; i < len; i++)
        {
            IExpressionNode node = nodes[i];
            walk(node);
            if (i < len - 1)
                emitter.write(", ");
        }
    }

    @Override
    public void visitBlock(IBlockNode node)
    {
        debug("visitBlock()");
        if (node.getParent().getNodeID() == ASTNodeID.FunctionID)
        {
            emitter.emitFunctionBlockHeader((IFunctionNode) node.getParent());
        }
        
        final int len = node.getChildCount();
        for (int i = 0; i < len; i++)
        {
            walk(node.getChild(i));
            // XXX (mschmalle) this should be in the after handler?
            if (node.getParent().getNodeID() != ASTNodeID.LabledStatementID
                    && !(node.getChild(i) instanceof IStatementNode))
            {
                emitter.write(";");
            }
            if (i < len - 1)
                emitter.write("\n");
        }
    }

    @Override
    public void visitContainer(IContainerNode node)
    {
        debug("visitContainer()");
        emitter.write(toPrefix(node.getContainerType()));
        for (int i = 0; i < node.getChildCount(); i++)
            walk(node.getChild(i));
        emitter.write(toPostfix(node.getContainerType()));
    }

    @Override
    public void visitIf(IIfNode node)
    {
        debug("visitIf()");
        IConditionalNode conditional = (IConditionalNode) node.getChild(0);

        IContainerNode xnode = (IContainerNode) conditional
                .getStatementContentsNode();

        emitter.write("if");
        emitter.write(" ");
        emitter.write("(");
        walk(conditional.getChild(0)); // conditional expression
        emitter.write(")");
        if (!isImplicit(xnode))
            emitter.write(" ");

        walk(conditional.getChild(1)); // BlockNode
        IConditionalNode[] nodes = node.getElseIfNodes();
        if (nodes.length > 0)
        {
            for (int i = 0; i < nodes.length; i++)
            {
                IConditionalNode enode = (IConditionalNode) nodes[i];
                IContainerNode snode = (IContainerNode) enode
                        .getStatementContentsNode();

                final boolean isImplicit = isImplicit(snode);
                if (isImplicit)
                    emitter.write("\n");
                else
                    emitter.write(" ");

                emitter.write("else if");
                emitter.write(" ");
                emitter.write("(");
                walk(enode.getChild(0));
                emitter.write(")");
                if (!isImplicit)
                    emitter.write(" ");

                walk(enode.getChild(1)); // ConditionalNode
            }
        }

        ITerminalNode elseNode = node.getElseNode();
        if (elseNode != null)
        {
            IContainerNode cnode = (IContainerNode) elseNode.getChild(0);
            // if an implicit if, add a newline with no space
            final boolean isImplicit = isImplicit(cnode);
            if (isImplicit)
                emitter.write("\n");
            else
                emitter.write(" ");
            emitter.write("else");
            if (!isImplicit)
                emitter.write(" ");

            walk(elseNode); // TerminalNode
        }
    }

    @Override
    public void visitForLoop(IForLoopNode node)
    {
        debug("visitForLoop(" + node.getKind() + ")");
        if (node.getKind() == ForLoopKind.FOR)
            visitFor(node);
        else if (node.getKind() == ForLoopKind.FOR_EACH)
            visitForEach(node);
    }

    protected void visitForEach(IForLoopNode node)
    {
        debug("visitForEach()");
        IContainerNode xnode = (IContainerNode) node.getChild(1);
        pushContext(TraverseContext.FOR);
        emitter.write("for");
        emitter.write(" ");
        emitter.write("each");
        emitter.write(" ");
        emitter.write("(");

        IContainerNode cnode = node.getConditionalsContainerNode();
        visitForInBody(cnode);

        emitter.write(")");
        if (!isImplicit(xnode))
            emitter.write(" ");

        popContext(TraverseContext.FOR);
        walk(node.getStatementContentsNode());
    }

    protected void visitFor(IForLoopNode node)
    {
        debug("visitFor()");
        IContainerNode xnode = (IContainerNode) node.getChild(1);
        pushContext(TraverseContext.FOR);
        emitter.write("for");
        emitter.write(" ");
        emitter.write("(");

        IContainerNode cnode = node.getConditionalsContainerNode();
        final IASNode node0 = cnode.getChild(0);
        if (node0.getNodeID() == ASTNodeID.Op_InID)
        {
            visitForInBody(cnode);
        }
        else
        {
            visitForBody(cnode);
        }

        emitter.write(")");
        if (!isImplicit(xnode))
            emitter.write(" ");
        popContext(TraverseContext.FOR);
        walk(node.getStatementContentsNode());
    }

    protected void visitForInBody(IContainerNode node)
    {
        walk(node.getChild(0));
    }

    protected void visitForBody(IContainerNode node)
    {
        final IASNode node0 = node.getChild(0);
        final IASNode node1 = node.getChild(1);
        final IASNode node2 = node.getChild(2);

        // initializer
        if (node0 != null)
        {
            walk(node0);
            emitter.write(";");
            if (node1.getNodeID() != ASTNodeID.NilID)
                emitter.write(" ");
        }
        // condition or target
        if (node1 != null)
        {
            walk(node1);
            emitter.write(";");
            if (node2.getNodeID() != ASTNodeID.NilID)
                emitter.write(" ");
        }
        // iterator
        if (node2 != null)
        {
            walk(node2);
        }
    }

    @Override
    public void visitIterationFlow(IIterationFlowNode node)
    {
        debug("visitIterationFlow()");
        emitter.write(node.getKind().toString().toLowerCase());
        IIdentifierNode lnode = node.getLabelNode();
        if (lnode != null)
        {
            emitter.write(" ");
            walk(lnode);
        }
    }

    @Override
    public void visitSwitch(ISwitchNode node)
    {
        debug("visitSwitch()");
        emitter.write("swtich");
        emitter.write(" ");
        emitter.write("(");
        walk(node.getChild(0));
        emitter.write(")");
        emitter.write(" {");
        emitter.indentPush();
        emitter.write("\n");

        IConditionalNode[] cnodes = getCaseNodes(node);
        ITerminalNode dnode = getDefaultNode(node);

        for (int i = 0; i < cnodes.length; i++)
        {
            IConditionalNode casen = cnodes[i];
            IContainerNode cnode = (IContainerNode) casen.getChild(1);
            emitter.write("case");
            emitter.write(" ");
            walk(casen.getConditionalExpressionNode());
            emitter.write(":");
            if (!isImplicit(cnode))
                emitter.write(" ");
            walk(casen.getStatementContentsNode());
            if (i == cnodes.length - 1 && dnode == null)
            {
                emitter.indentPop();
                emitter.write("\n");
            }
            else
                emitter.write("\n");
        }
        if (dnode != null)
        {
            IContainerNode cnode = (IContainerNode) dnode.getChild(0);
            emitter.write("default");
            emitter.write(":");
            if (!isImplicit(cnode))
                emitter.write(" ");
            walk(dnode);
            emitter.indentPop();
            emitter.write("\n");
        }
        emitter.write("}");
    }

    @Override
    public void visitWhileLoop(IWhileLoopNode node)
    {
        debug("visitWhileLoopNode()");
        if (node.getKind() == WhileLoopKind.WHILE)
        {
            IContainerNode cnode = (IContainerNode) node.getChild(1);
            emitter.write("while");
            emitter.write(" ");
            emitter.write("(");
            walk(node.getConditionalExpressionNode());
            emitter.write(")");
            if (!isImplicit(cnode))
                emitter.write(" ");
            walk(node.getStatementContentsNode());
        }
        else if (node.getKind() == WhileLoopKind.DO)
        {
            IContainerNode cnode = (IContainerNode) node.getChild(0);
            emitter.write("do");
            if (!isImplicit(cnode))
                emitter.write(" ");
            walk(node.getStatementContentsNode());
            if (!isImplicit(cnode))
                emitter.write(" ");
            else
                emitter.write("\n"); // TODO (mschmalle) there is something wrong here, block should NL
            emitter.write("while");
            emitter.write(" ");
            emitter.write("(");
            walk(node.getConditionalExpressionNode());
            emitter.write(");");
        }
    }

    @Override
    public void visitWith(IWithNode node)
    {
        IContainerNode cnode = (IContainerNode) node.getChild(1);
        emitter.write("with");
        emitter.write(" ");
        emitter.write("(");
        walk(node.getTargetNode());
        emitter.write(")");
        if (!isImplicit(cnode))
            emitter.write(" ");
        walk(node.getStatementContentsNode());
    }

    @Override
    public void visitThrow(IThrowNode node)
    {
        emitter.write("throw");
        emitter.write(" ");
        walk(node.getThrownExpressionNode());
    }

    @Override
    public void visitTry(ITryNode node)
    {
        debug("visitTry()");
        emitter.write("try");
        emitter.write(" ");
        walk(node.getStatementContentsNode());
        for (int i = 0; i < node.getCatchNodeCount(); i++)
        {
            walk(node.getCatchNode(i));
        }
        ITerminalNode fnode = node.getFinallyNode();
        if (fnode != null)
        {
            emitter.write(" ");
            emitter.write("finally");
            emitter.write(" ");
            walk(fnode);
        }
    }

    @Override
    public void visitCatch(ICatchNode node)
    {
        debug("visitCatch()");
        emitter.write(" ");
        emitter.write("catch");
        emitter.write(" ");
        emitter.write("(");
        walk(node.getCatchParameterNode());
        emitter.write(")");
        emitter.write(" ");
        walk(node.getStatementContentsNode());
    }

    @Override
    public void visitIdentifier(IIdentifierNode node)
    {
        debug("visitIdentifier(" + node.getName() + ")");
        String name = node.getName();
        emitter.write(name);
    }

    @Override
    public void visitNumericLiteral(INumericLiteralNode node)
    {
        debug("visitNumericLiteral(" + node.getNumericValue() + ")");
        emitter.write(node.getNumericValue().toString());
    }

    @Override
    public void visitDefaultXMLNamespace(IDefaultXMLNamespaceNode node)
    {
        debug("visitDefaultXMLNamespace()");
        walk(node.getKeywordNode()); // default xml namespace
        walk(node.getExpressionNode()); // "http://ns.whatever.com"
    }

    @Override
    public void visitKeyword(IKeywordNode node)
    {
        debug("visitKeyword(" + node.getNodeID().getParaphrase() + ")");
        emitter.write(node.getNodeID().getParaphrase());
    }

    @Override
    public void visitLiteral(ILiteralNode node)
    {
        debug("visitLiteral(" + node.getValue() + ")");
        // TODO (mschmalle) visitLiteral()
        if (node.getLiteralType() == LiteralType.NUMBER
                || node.getLiteralType() == LiteralType.BOOLEAN
                || node.getLiteralType() == LiteralType.NULL
                || node.getLiteralType() == LiteralType.NUMBER
                || node.getLiteralType() == LiteralType.REGEXP
                || node.getLiteralType() == LiteralType.STRING
                || node.getLiteralType() == LiteralType.VOID)
        {
            emitter.write(node.getValue(true));
        }
        else if (node.getLiteralType() == LiteralType.ARRAY
                || node.getLiteralType() == LiteralType.OBJECT)
        {
            BaseLiteralContainerNode anode = (BaseLiteralContainerNode) node;
            ContainerNode cnode = anode.getContentsNode();
            visitLiteralContainer(cnode);
        }
    }

    public void visitLiteralContainer(IContainerNode node)
    {
        emitter.write(toPrefix(node.getContainerType()));
        final int len = node.getChildCount();
        for (int i = 0; i < len; i++)
        {
            IASNode child = node.getChild(i);
            walk(child);
            if (i < len - 1)
                emitter.write(",");
        }
        emitter.write(toPostfix(node.getContainerType()));
    }

    @Override
    public void visitMemberAccessExpression(IMemberAccessExpressionNode node)
    {
        debug("visitMemberAccessExpression()");
        walk(node.getLeftOperandNode());
        emitter.write(node.getOperator().getOperatorText());
        walk(node.getRightOperandNode());
    }

    @Override
    public void visitNamespaceAccessExpression(
            NamespaceAccessExpressionNode node)
    {
        debug("visitNamespaceAccessExpression()");
        walk(node.getLeftOperandNode());
        emitter.write(node.getOperator().getOperatorText());
        walk(node.getRightOperandNode());
    }

    @Override
    public void visitDynamicAccess(IDynamicAccessNode node)
    {
        debug("visitDynamicAccess()");
        walk(node.getLeftOperandNode());
        emitter.write("[");
        walk(node.getRightOperandNode());
        emitter.write("]");
    }

    @Override
    public void visitTypedExpression(ITypedExpressionNode node)
    {
        debug("visitITypedExpression()");
        walk(node.getCollectionNode());
        emitter.write(".<");
        walk(node.getTypeNode());
        emitter.write(">");
    }

    @Override
    public void visitBinaryOperator(IBinaryOperatorNode node)
    {
        debug("visitBinaryOperator(" + node.getOperator().getOperatorText()
                + ")");
        walk(node.getLeftOperandNode());
        if (node.getNodeID() != ASTNodeID.Op_CommaID)
            emitter.write(" ");
        emitter.write(node.getOperator().getOperatorText());
        emitter.write(" ");
        walk(node.getRightOperandNode());
    }

    @Override
    public void visitUnaryOperator(IUnaryOperatorNode node)
    {
        debug("visitUnaryOperator()");
        if (node.getNodeID() == ASTNodeID.Op_PreIncrID
                || node.getNodeID() == ASTNodeID.Op_PreDecrID
                || node.getNodeID() == ASTNodeID.Op_BitwiseNotID
                || node.getNodeID() == ASTNodeID.Op_LogicalNotID)
        {
            emitter.write(node.getOperator().getOperatorText());
            walk(node.getOperandNode());
        }

        else if (node.getNodeID() == ASTNodeID.Op_PostIncrID
                || node.getNodeID() == ASTNodeID.Op_PostDecrID)
        {
            walk(node.getOperandNode());
            emitter.write(node.getOperator().getOperatorText());
        }
        else if (node.getNodeID() == ASTNodeID.Op_DeleteID
                || node.getNodeID() == ASTNodeID.Op_VoidID)
        {
            emitter.write(node.getOperator().getOperatorText());
            emitter.write(" ");
            walk(node.getOperandNode());
        }
        else if (node.getNodeID() == ASTNodeID.Op_TypeOfID)
        {
            emitter.write(node.getOperator().getOperatorText());
            emitter.write("(");
            walk(node.getOperandNode());
            emitter.write(")");
        }
    }

    @Override
    public void visitConditional(IConditionalNode node)
    {
        debug("visitConditional()");
        emitter.write("(");
        walk(node.getConditionalExpressionNode());
        emitter.write(")");
        walk(node.getStatementContentsNode());
    }

    @Override
    public void visitTerminal(ITerminalNode node)
    {
        debug("visitTerminal(" + node.getKind() + ")");
        walk(node.getStatementContentsNode());
    }

    @Override
    public void visitExpression(IExpressionNode node)
    {
        debug("visitExpression()");
        // TODO (mschmalle) I think these placements are temp, I am sure a visit method
        // should exist for FunctionObjectNode, there is no interface for it right now
        if (node instanceof VariableExpressionNode)
        {
            VariableExpressionNode v = (VariableExpressionNode) node;
            walk(v.getTargetVariable());
        }
        else if (node instanceof FunctionObjectNode)
        {
            emitter.emitFunctionObject(node);
        }
    }

    @Override
    public void visitMetaTags(IMetaTagsNode node)
    {
        debug("visitMetaTags()");
        IMetaTagNode[] tags = node.getAllTags();
        for (IMetaTagNode tag : tags)
        {
            walk(tag);
        }
    }

    @Override
    public void visitMetaTag(IMetaTagNode node)
    {
        debug("visitMetaTag(" + node.getTagName() + ")");
        // TODO (mschmalle) visitMetaTag()    
    }

    @Override
    public void visitEmbed(IEmbedNode node)
    {
        debug("visitEmbed(" + node.getAttributes()[0].getValue() + ")");
    }

    @Override
    public void visitReturn(IReturnNode node)
    {
        debug("visitReturn()");
        emitter.write("return");
        IExpressionNode rnode = node.getReturnValueNode();
        if (rnode != null && rnode.getNodeID() != ASTNodeID.NilID)
        {
            emitter.write(" ");
            walk(rnode);
        }
    }

    @Override
    public void visitTernaryOperator(ITernaryOperatorNode node)
    {
        debug("visitTernaryOperator()");
        walk(node.getConditionalNode());
        emitter.write(" ");
        emitter.write("?");
        emitter.write(" ");
        walk(node.getLeftOperandNode());
        emitter.write(" ");
        emitter.write(":");
        emitter.write(" ");
        walk(node.getRightOperandNode());
    }

    @Override
    public void visitLabeledStatement(LabeledStatementNode node)
    {
        debug("visitLabeledStatement()");
        emitter.write(node.getLabel());
        emitter.write(" ");
        emitter.write(":");
        emitter.write(" ");
        walk(node.getLabeledStatement());
    }

    @Override
    public void visitIObjectLiteralValuePair(IObjectLiteralValuePairNode node)
    {
        debug("visitIObjectLiteralValuePair()");
        walk(node.getNameNode());
        emitter.write(":");
        walk(node.getValueNode());
    }

    @Override
    public void visitLanguageIdentifierNode(ILanguageIdentifierNode node)
    {
        if (node.getKind() == ILanguageIdentifierNode.LanguageIdentifierKind.ANY_TYPE)
        {
            emitter.write("*");
        }
        else if (node.getKind() == ILanguageIdentifierNode.LanguageIdentifierKind.REST)
        {
            emitter.write("...");
        }
        else if (node.getKind() == ILanguageIdentifierNode.LanguageIdentifierKind.SUPER)
        {
            emitter.write("super");
        }
        else if (node.getKind() == ILanguageIdentifierNode.LanguageIdentifierKind.THIS)
        {
            emitter.write("this");
        }
        else if (node.getKind() == ILanguageIdentifierNode.LanguageIdentifierKind.VOID)
        {
            emitter.write("void");
        }
    }

    //--------------------------------------------------------------------------
    // 
    //--------------------------------------------------------------------------

    protected IFunctionNode getConstructor(IDefinitionNode[] members)
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

    protected void debug(String message)
    {
        System.out.println(message);
    }

    private String toPrefix(ContainerType type)
    {
        if (type == ContainerType.BRACES)
            return "{";
        else if (type == ContainerType.BRACKETS)
            return "[";
        else if (type == ContainerType.IMPLICIT)
            return "";
        else if (type == ContainerType.PARENTHESIS)
            return "(";
        return null;
    }

    private String toPostfix(ContainerType type)
    {
        if (type == ContainerType.BRACES)
            return "}";
        else if (type == ContainerType.BRACKETS)
            return "]";
        else if (type == ContainerType.IMPLICIT)
            return "";
        else if (type == ContainerType.PARENTHESIS)
            return ")";
        return null;
    }

    //--------------------------------------------------------------------------
    //  
    //--------------------------------------------------------------------------

    ITypeNode findTypeNode(IPackageNode node)
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

    public void walk(IASNode node)
    {
        getStrategy().handle(node);
    }

    private static final boolean isImplicit(IContainerNode node)
    {
        return node.getContainerType() == ContainerType.IMPLICIT
                || node.getContainerType() == ContainerType.SYNTHESIZED;
    }

    // there seems to be a bug in the ISwitchNode.getCaseNodes(), need to file a bug
    public IConditionalNode[] getCaseNodes(ISwitchNode node)
    {
        IBlockNode block = (IBlockNode) node.getChild(1);
        int childCount = block.getChildCount();
        ArrayList<IConditionalNode> retVal = new ArrayList<IConditionalNode>(
                childCount);

        for (int i = 0; i < childCount; i++)
        {
            IASNode child = block.getChild(i);
            if (child instanceof IConditionalNode)
                retVal.add((IConditionalNode) child);
        }

        return retVal.toArray(new IConditionalNode[0]);
    }

    // there seems to be a bug in the ISwitchNode.getDefaultNode(), need to file a bug
    public ITerminalNode getDefaultNode(ISwitchNode node)
    {
        IBlockNode block = (IBlockNode) node.getChild(1);
        int childCount = block.getChildCount();
        for (int i = childCount - 1; i >= 0; i--)
        {
            IASNode child = block.getChild(i);
            if (child instanceof ITerminalNode)
                return (ITerminalNode) child;
        }

        return null;
    }
}
