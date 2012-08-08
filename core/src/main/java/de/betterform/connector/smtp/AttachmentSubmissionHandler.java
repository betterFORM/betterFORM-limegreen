/*
 * Copyright (c) 2012. betterFORM Project - http://www.betterform.de
 * Licensed under the terms of BSD License
 */

package de.betterform.connector.smtp;


import de.betterform.connector.AbstractConnector;
import de.betterform.connector.SubmissionHandler;
import de.betterform.xml.dom.DOMUtil;
import de.betterform.xml.xforms.exception.XFormsException;
import de.betterform.xml.xforms.model.submission.Submission;
import org.w3c.dom.Element;
import org.w3c.dom.Node;

import java.util.Map;

/**
 * The SMTP submission driver serializes and submits instance data over SMTP (internet mail).
 * <p/>
 * Currently, the driver only supports the <code>post</code> submission method and the replace mode <code>none</code>.

 * <p/>
 * The driver requires the additional information about the SMTP server to use, the mail subject, and the sender. This
 * information has to be provided in the query part of the submission's <code>resource</code> URI. If you want the driver
 * to authenticate a user with the SMTP server, just provide a <code>username</code> and a <code>password</code>.
 * Support for other mail header fields like <code>cc</code> may be added later.
 * <p/>
 * Be careful when writing the submission's <code>action</code> URI: First, the contents of the query part have to be
 * URL-encoded, then you have to replace all <code>&amp;</code>'s with their corresponding XML entity
 * <code>&amp;amp;</code> in order to keep the XML well-formed.
 * <p/>
 * Here is an illustrating example:
 * <pre>
 * &lt;xforms:submission id='smtp' xforms:action='mailto:nn@nowhere.no?server=smtp.nowhere.no&amp;amp;sender=xforms@nowhere.no&amp;amp;subject=instance%20data'
 * /&gt;
 * </pre>
 * The same example enforcing authentication:
 * <pre>
 * &lt;xforms:submission id='smtp-auth' xforms:action='mailto:nn@nowhere.no?server=smtp.nowhere.no&amp;amp;sender=xforms@nowhere.no&amp;amp;subject=instance%20data&amp;amp;username=xforms&amp;amp;password=shhh'
 * /&gt;
 * </pre>
 * Since mail accounts are personal data, there is no example form demonstrating SMTP submission.
 *
 *
 * <p/><p/>
 * This SubmissionHandler requires an instance with a structure like below. Please note that this instance
 * uses the namespace 'http://betterform.de/mailmessage'.<p/>
 * <pre>
 * &lt;mailmessage xmlns="http://betterform.de/mailmessage"&gt;
 *       &lt;body&gt;The message of this mail&lt;/body&gt;
 *       &lt;attachments&gt;
 *           &lt;attachment name="PatientAddress.html"&gt;
 *               &lt;content/&gt;
 *           &lt;/attachment&gt;
 * </pre>
 * <p/>
 *
 * When using the above format this handler will create a single attachment for every attachment element found. The
 * value of @name will be used as a filename for the attachment.
 * <p/>
 *
 * @author Joern turner
 */


public class AttachmentSubmissionHandler extends AbstractConnector implements SubmissionHandler {
    private final MessageBuilder messageBuilder = new MessageBuilder();

    /**
     * Serializes and submits the given instance data over the <code>mailto</code> protocol.
     *
     * @param submission the submission issuing the request.
     * @param instance   the instance data to be serialized and submitted.
     * @return <code>null</code>.
     * @throws de.betterform.xml.xforms.exception.XFormsException if any error occurred during submission.
     */
    public Map submit(Submission submission, Node instance) throws XFormsException {

        if (!submission.getReplace().equals("none")) {
            throw new XFormsException("submission mode '" + submission.getReplace() + "' at: " + DOMUtil.getCanonicalPath(submission.getElement()) + " not supported");
        }

        try {
            String mediatype = "application/xml";
            if (submission.getMediatype() != null) {
                mediatype = submission.getMediatype();
            }

            String encoding = getDefaultEncoding();
            if (submission.getEncoding() != null) {
                encoding = submission.getEncoding();
            }

            Element mailMessage = (Element) DOMUtil.getFirstChildByTagName(instance, "mailmessage");
            if(mailMessage == null){
                throw new XFormsException("This handler only supports instances with a fixed structure that uses the 'http://betterform.de/mailmessage' namespace. Please see API Docs for details.");
            }

            /*
             * Some extension mechanism here could be handy
             */
            String method = submission.getMethod();
            if (!method.equals("post")){
                throw new XFormsException("unsupported submission method - this handler only support 'POST' requests");
            }

            messageBuilder.send(getURI(), mailMessage, encoding, mediatype);
        } catch (Exception e) {
            throw new XFormsException(e);
        }

        return null;
    }
}

//end of class
