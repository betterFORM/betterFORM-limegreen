package de.betterform.connector.smtp;

import de.betterform.xml.dom.DOMUtil;
import junit.framework.Test;
import junit.framework.TestSuite;
import junit.framework.TestCase;
import org.w3c.dom.Document;

import java.io.File;

/**
 * MessageBuilder Tester.
 *
 * @author Joern Turner
 * @version 1.0
 * @since <pre>08/08/2012</pre>
 */
public class MessageBuilderTest extends TestCase {
    private Document message;

    public MessageBuilderTest(String name) {
        super(name);
    }

    public void setUp() throws Exception {
        super.setUp();
        this.message = DOMUtil.parseInputStream(getClass().getResourceAsStream("mimemail.xml"),true,false);
        DOMUtil.prettyPrintDOM(this.message);
    }

    public void tearDown() throws Exception {
        super.tearDown();
    }

    /**
     * Method: send(String uri, Element mailMessage, String encoding, String mediatype)
     */
    public void testSend() throws Exception {
        MessageBuilder mb = new MessageBuilder();

        mb.send("mailto:joern.turner@betterform.de?server=smtp.mail.yahoo.com&sender=jturnay@yahoo.com&subject=new%20patient%20record&username=jturnay&password=ebtb!*42",
                this.message.getDocumentElement(),
                "UTF-8",
                "text/html");
//TODO: Test goes here... 
    }

    /**
     * Method: getPasswordAuthentication()
     */
    public void testGetPasswordAuthentication() throws Exception {
//TODO: Test goes here... 
    }


    public static Test suite() {
        return new TestSuite(MessageBuilderTest.class);
    }
} 
