package org.apache.flex.js.internal.driver;

import static org.hamcrest.core.Is.is;
import static org.junit.Assert.assertThat;

import java.io.StringWriter;
import java.io.Writer;

import org.apache.flex.compiler.clients.IBackend;
import org.apache.flex.compiler.internal.driver.JSBackend;
import org.apache.flex.compiler.internal.js.codgen.JSFilterWriter;
import org.apache.flex.js.IASBlockVisitor;
import org.junit.After;

public class TestWalkerBase extends TestBase
{
    protected IASBlockVisitor visitor;

    private Writer out;

    private IBackend backend;

    private JSFilterWriter writer;

    protected String mCode;

    @Override
    public void setUp()
    {
        super.setUp();

        backend = new JSBackend();
        out = new StringWriter();
        writer = new JSFilterWriter(out);
        visitor = backend.createWalker(project, errors, writer);
    }

    @After
    public void tearDown()
    {
        backend = null;
        out = null;
        writer = null;
        visitor = null;
    }

    protected void assertOut(String code)
    {
        mCode = out.toString();
        assertThat(out.toString(), is(code));
    }
}
