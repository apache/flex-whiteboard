package org.apache.flex.js.internal.driver;

import static org.junit.Assert.assertNotNull;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import org.apache.flex.compiler.clients.MXMLJSC;
import org.apache.flex.compiler.internal.projects.FlexProject;
import org.apache.flex.compiler.internal.projects.FlexProjectConfigurator;
import org.apache.flex.compiler.internal.tree.as.FunctionNode;
import org.apache.flex.compiler.internal.units.SourceCompilationUnitFactory;
import org.apache.flex.compiler.internal.workspaces.Workspace;
import org.apache.flex.compiler.mxml.IMXMLNamespaceMapping;
import org.apache.flex.compiler.mxml.MXMLNamespaceMapping;
import org.apache.flex.compiler.problems.ICompilerProblem;
import org.apache.flex.compiler.tree.as.IASNode;
import org.apache.flex.compiler.tree.as.IBinaryOperatorNode;
import org.apache.flex.compiler.tree.as.IDynamicAccessNode;
import org.apache.flex.compiler.tree.as.IExpressionNode;
import org.apache.flex.compiler.tree.as.IFileNode;
import org.apache.flex.compiler.tree.as.IUnaryOperatorNode;
import org.apache.flex.compiler.units.ICompilationUnit;
import org.apache.flex.utils.FilenameNormalization;
import org.junit.Before;

public class TestBase
{
    protected void compileJS(String path)
    {
        // Construct a command line which simply loads the project's config file.
        String playerglobalHome = System.getenv("PLAYERGLOBAL_HOME");
        assertNotNull("Environment variable PLAYERGLOBAL_HOME is not set",
                playerglobalHome);

        String flexHome = System.getenv("FLEX_HOME");
        assertNotNull("Environment variable FLEX_HOME is not set", flexHome);

        String configFile = flexHome + "/frameworks/flex-config.xml";
        String[] args = new String[] { "-load-config=" + configFile,
                "+env.PLAYERGLOBAL_HOME=" + playerglobalHome,
                "+playerglobal.version=11.1",
                "-define=CONFIG::performanceInstrumentation,false", "" + path };

        MXMLJSC.main(args);
    }

    protected List<ICompilerProblem> errors;

    private static EnvProperties env = EnvProperties.initiate();

    protected static Workspace workspace = new Workspace();

    protected FlexProject project;

    @Before
    public void setUp()
    {
        assertNotNull("Environment variable FLEX_HOME is not set", env.SDK);
        assertNotNull("Environment variable PLAYERGLOBAL_HOME is not set",
                env.FPSDK);

        errors = new ArrayList<ICompilerProblem>();

        project = new FlexProject(workspace);
        FlexProjectConfigurator.configure(project);
    }

    protected IASNode findFirstDescendantOfType(IASNode node,
            Class<? extends IASNode> nodeType)
    {
        int n = node.getChildCount();
        for (int i = 0; i < n; i++)
        {
            IASNode child = node.getChild(i);
            if (child instanceof FunctionNode)
            {
                ((FunctionNode) child).parseFunctionBody(errors);
            }
            if (nodeType.isInstance(child))
                return child;

            IASNode found = findFirstDescendantOfType(child, nodeType);
            if (found != null)
                return found;
        }

        return null;
    }

    protected IFileNode getFileNode(String code)
    {
        String tempDir = FilenameNormalization.normalize("temp"); // ensure this exists

        File tempASFile = null;
        try
        {
            tempASFile = File.createTempFile(getClass().getSimpleName(), ".as",
                    new File(tempDir));
            tempASFile.deleteOnExit();

            BufferedWriter out = new BufferedWriter(new FileWriter(tempASFile));
            out.write(code);
            out.close();
        }
        catch (IOException e1)
        {
            e1.printStackTrace();
        }

        List<File> sourcePath = new ArrayList<File>();
        sourcePath.add(new File(tempDir));
        project.setSourcePath(sourcePath);

        // Compile the code against playerglobal.swc.
        List<File> libraries = new ArrayList<File>();
        libraries.add(new File(FilenameNormalization.normalize(env.FPSDK
                + "\\11.1\\playerglobal.swc")));
        libraries.add(new File(FilenameNormalization.normalize(env.SDK
                + "\\frameworks\\libs\\framework.swc")));
        libraries.add(new File(FilenameNormalization.normalize(env.SDK
                + "\\frameworks\\libs\\rpc.swc")));
        libraries.add(new File(FilenameNormalization.normalize(env.SDK
                + "\\frameworks\\libs\\spark.swc")));
        project.setLibraries(libraries);

        // Use the MXML 2009 manifest.
        List<IMXMLNamespaceMapping> namespaceMappings = new ArrayList<IMXMLNamespaceMapping>();
        IMXMLNamespaceMapping mxml2009 = new MXMLNamespaceMapping(
                "http://ns.adobe.com/mxml/2009", env.SDK
                        + "\\frameworks\\mxml-2009-manifest.xml");
        namespaceMappings.add(mxml2009);
        project.setNamespaceMappings(namespaceMappings);

        ICompilationUnit cu = null;
        String normalizedMainFileName = FilenameNormalization
                .normalize(tempASFile.getAbsolutePath());

        SourceCompilationUnitFactory compilationUnitFactory = project
                .getSourceCompilationUnitFactory();
        File normalizedMainFile = new File(normalizedMainFileName);
        if (compilationUnitFactory.canCreateCompilationUnit(normalizedMainFile))
        {
            Collection<ICompilationUnit> mainFileCompilationUnits = workspace
                    .getCompilationUnits(normalizedMainFileName, project);
            for (ICompilationUnit cu2 : mainFileCompilationUnits)
            {
                if (cu2 != null)
                    cu = cu2;
            }
        }

        // Build the AST.
        IFileNode fileNode = null;
        try
        {
            fileNode = (IFileNode) cu.getSyntaxTreeRequest().get().getAST();
        }
        catch (InterruptedException e)
        {
            e.printStackTrace();
        }

        return fileNode;
    }

    protected IASNode getNode(String code, Class<? extends IASNode> type)
    {
        String source = "package {public class A {function a():void {" + code
                + "}}";
        IFileNode node = getFileNode(source);
        if (type.isInstance(node))
            return node;
        IASNode child = (IASNode) findFirstDescendantOfType(node, type);
        return child;
    }

    protected IExpressionNode getExpressionNode(String code,
            Class<? extends IASNode> type)
    {
        String source = "package {public class A {function a():void {" + code
                + "}}";
        IFileNode node = getFileNode(source);
        IExpressionNode child = (IExpressionNode) findFirstDescendantOfType(
                node, type);
        return child;
    }

    protected IUnaryOperatorNode getUnaryNode(String code)
    {
        String source = "package {public class A {function a():void {" + code
                + "}}";
        IFileNode node = getFileNode(source);
        IUnaryOperatorNode child = (IUnaryOperatorNode) findFirstDescendantOfType(
                node, IUnaryOperatorNode.class);
        return child;
    }

    protected IBinaryOperatorNode getBinaryNode(String code)
    {
        String source = "package {public class A {function a():void {" + code
                + "}}";
        IFileNode node = getFileNode(source);
        IBinaryOperatorNode child = (IBinaryOperatorNode) findFirstDescendantOfType(
                node, IBinaryOperatorNode.class);
        return child;
    }

    protected IDynamicAccessNode getDynamicAccessNode(String code)
    {
        String source = "package {public class A {function a():void {" + code
                + "}}";
        IFileNode node = getFileNode(source);
        IDynamicAccessNode child = (IDynamicAccessNode) findFirstDescendantOfType(
                node, IDynamicAccessNode.class);
        return child;
    }
}
