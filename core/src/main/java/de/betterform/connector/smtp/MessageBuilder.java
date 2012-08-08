/*
 * Copyright (c) 2012. betterFORM Project - http://www.betterform.de
 * Licensed under the terms of BSD License
 */

package de.betterform.connector.smtp;

import de.betterform.xml.dom.DOMUtil;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import javax.mail.*;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeBodyPart;
import javax.mail.internet.MimeMessage;
import javax.mail.internet.MimeMultipart;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import java.io.ByteArrayOutputStream;
import java.io.OutputStream;
import java.io.StringWriter;
import java.net.URL;
import java.net.URLDecoder;
import java.util.Date;
import java.util.Properties;
import java.util.StringTokenizer;

public class MessageBuilder {
    /**
     * The logger.
     */
    static final Log LOGGER = LogFactory.getLog(AttachmentSubmissionHandler.class);
    public static final String BETTERFORM_MAIL = "http://betterform.de/mailmessage";

    public MessageBuilder() {
    }

    void send(String uri, Element mailMessage, String encoding, String mediatype) throws Exception {
        URL url = new URL(uri);
        String recipient = url.getPath();

        String server = null;
        String port = null;
        String sender = null;
        String subject = null;
        String username = null;
        String password = null;

        StringTokenizer headers = new StringTokenizer(url.getQuery(), "&");

        while (headers.hasMoreTokens()) {
            String token = headers.nextToken();

            if (token.startsWith("server=")) {
                server = URLDecoder.decode(token.substring("server=".length()), "UTF-8");

                continue;
            }

            if (token.startsWith("port=")) {
                port = URLDecoder.decode(token.substring("port=".length()), "UTF-8");

                continue;
            }

            if (token.startsWith("sender=")) {
                sender = URLDecoder.decode(token.substring("sender=".length()), "UTF-8");

                continue;
            }

            if (token.startsWith("subject=")) {
                subject = URLDecoder.decode(token.substring("subject=".length()), "UTF-8");

                continue;
            }

            if (token.startsWith("username=")) {
                username = URLDecoder.decode(token.substring("username=".length()), "UTF-8");

                continue;
            }

            if (token.startsWith("password=")) {
                password = URLDecoder.decode(token.substring("password=".length()), "UTF-8");

                continue;
            }
        }

        if (LOGGER.isDebugEnabled()) {
            LOGGER.debug("smtp server '" + server + "'");

            if (username != null) {
                LOGGER.debug("smtp-auth username '" + username + "'");
            }

            LOGGER.debug("mail sender '" + sender + "'");
            LOGGER.debug("subject line '" + subject + "'");
        }

        Properties properties = System.getProperties();
        properties.put("mail.debug", String.valueOf(LOGGER.isDebugEnabled()));
        properties.put("mail.smtp.from", sender);
        properties.put("mail.smtp.host", server);

        if (port != null) {
            properties.put("mail.smtp.port", port);
        }

        if (username != null) {
            properties.put("mail.smtp.auth", String.valueOf(true));
            properties.put("mail.smtp.user", username);
        }

        Session session = Session.getInstance(properties, new SMTPAuthenticator(username, password));
        MimeMessage message = new MimeMessage(session);
        message.setRecipient(MimeMessage.RecipientType.TO, new InternetAddress(recipient));
        message.setSubject(subject);
        message.setSentDate(new Date());

        //set message part
        BodyPart messageBodyPart = new MimeBodyPart();
        Node messageBody = DOMUtil.getFirstChildByTagName(mailMessage, "body");
        messageBodyPart.setText(DOMUtil.getTextNodeAsString(messageBody));

        Multipart multipart = new MimeMultipart();
        multipart.addBodyPart(messageBodyPart);

        //create attachments
        NodeList nl = mailMessage.getElementsByTagName("attachment");
        int len = nl.getLength();
        Element e,child=null;
        MimeBodyPart mbp=null;
        for (int i = 0; i < len; i++) {
            e = (Element) nl.item(i);
            child=DOMUtil.getFirstChildElement(e);

            mbp = new MimeBodyPart();
            mbp.setContent(serializeToString(child), "text/html");
            mbp.setFileName(e.getAttribute("name"));
            multipart.addBodyPart(mbp);
        }

        // Put parts in message
        message.setContent(multipart);
        Transport.send(message);
    }

    private class SMTPAuthenticator extends Authenticator {
        private PasswordAuthentication authentication = null;

        /**
         * Creates a new SMTPAuthenticator object.
         *
         * @param user     user name
         * @param password password
         */
        SMTPAuthenticator(String user, String password) {
            this.authentication = new PasswordAuthentication(user, password);
        }

        /**
         * __UNDOCUMENTED__
         *
         * @return __UNDOCUMENTED__
         */
        protected PasswordAuthentication getPasswordAuthentication() {
            return this.authentication;
        }
    }

    private String serializeToString(org.w3c.dom.Node node){
        try
        {
            DOMSource domSource = new DOMSource(node);
            StringWriter writer = new StringWriter();
            StreamResult result = new StreamResult(writer);
            TransformerFactory tf = TransformerFactory.newInstance();
            Transformer transformer = tf.newTransformer();
            transformer.setOutputProperty(OutputKeys.INDENT, "no");
            transformer.setOutputProperty(OutputKeys.METHOD, "html");
            transformer.setOutputProperty(OutputKeys.OMIT_XML_DECLARATION, "yes");
            transformer.transform(domSource, result);
            writer.flush();
            return writer.toString();
        }
        catch(TransformerException ex)
        {
            ex.printStackTrace();
            return null;
        }
    }

}