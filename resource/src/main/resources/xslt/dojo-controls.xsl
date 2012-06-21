<?xml version="1.0" encoding="UTF-8"?>
<!--
  ~ Copyright (c) 2012. betterFORM Project - http://www.betterform.de
  ~ Licensed under the terms of BSD License
  -->

<xsl:stylesheet version="2.0"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xforms="http://www.w3.org/2002/xforms"
                xmlns:bf="http://betterform.sourceforge.net/xforms"
                xmlns:bfn="http://betterform.sourceforge.net/xforms/functions"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                xmlns:xhtml="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="xhtml bf xforms xsl xsd"
                xpath-default-namespace="http://www.w3.org/1999/xhtml">

    <xsl:variable name="data-prefix" select="'d_'"/>
    <xsl:variable name="trigger-prefix" select="'t_'"/>
    <xsl:variable name="remove-upload-prefix" select="'ru_'"/>


    <!-- change this to your ShowAttachmentServlet -->

    <!-- This stylesheet contains a collection of templates which map XForms controls to HTML controls. -->


    <!-- ######################################################################################################## -->
    <!-- This stylesheet serves as a 'library' for HTML form controls. It contains only named templates and may   -->
    <!-- be re-used in different layout-stylesheets to create the naked controls.                                 -->
    <!-- ######################################################################################################## -->

    <xsl:template name="select1">
        <xsl:variable name="navindex" select="if (exists(@navindex)) then @navindex else '0'"/>
        <xsl:variable name="id" select="@id"/>
        <xsl:variable name="name" select="concat($data-prefix,$id)"/>
        <xsl:variable name="parent" select="."/>
        <xsl:variable name="incremental" select="if (exists(@incremental)) then @incremental else 'true'"/>
        <xsl:variable name="appearance" select="bfn:getAppearance(@appearance)"/>

        <xsl:variable name="size">
            <xsl:choose>
                <xsl:when test="@size"><xsl:value-of select="@size"/></xsl:when>
                <xsl:otherwise>5</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="datatype"><xsl:call-template name="getType"/></xsl:variable>

        <xsl:if test="exists(.//xforms:itemset)"><xsl:text>
</xsl:text>
        </xsl:if>
        
        <xsl:choose>
            <xsl:when test="$appearance='compact'">
                <select id="{concat($id,'-value')}"
                        name="{$name}"
                        size="{$size}"
                        dataType="{$datatype}"
                        controlType="select1List"
                        class="xfValue"
                        title=""
                        tabindex="{$navindex}"
                        schemaValue="{bf:data/@bf:schema-value}"
                        incremental="{$incremental}">
                    <xsl:call-template name="build-items">
                        <xsl:with-param name="parent" select="$parent"/>
                        <xsl:with-param name="appearance" select="$appearance"/>
                    </xsl:call-template>
                </select>
                <!-- handle itemset prototype -->
                <xsl:if test="not(ancestor::xforms:repeat)">
                    <xsl:for-each select="xforms:itemset/bf:data/xforms:item">
                        <xsl:call-template name="build-item-prototype">
                            <xsl:with-param name="item-id" select="@id"/>
                            <xsl:with-param name="itemset-id" select="../../@id"/>
                        </xsl:call-template>
                    </xsl:for-each>
                </xsl:if>

            </xsl:when>
            <xsl:when test="$appearance='full'">
                <span id="{$id}-value"
                      controlType="select1RadioButton"
                      class="xfValue"                      
                      incremental="{$incremental}">
                    <xsl:call-template name="build-radiobuttons">
                        <xsl:with-param name="id" select="$id"/>
                        <xsl:with-param name="name" select="$name"/>
                        <xsl:with-param name="parent" select="$parent"/>
                        <xsl:with-param name="navindex" select="$navindex"/>
                    </xsl:call-template>
                </span>
                    <!-- handle itemset prototype -->
                    <xsl:if test="not(ancestor::xforms:repeat)">
                        <xsl:for-each select="xforms:itemset/bf:data/xforms:item">
                            <xsl:call-template name="build-radiobutton-prototype">
                                <xsl:with-param name="item-id" select="@id"/>
                                <xsl:with-param name="itemset-id" select="../../@id"/>
                                <xsl:with-param name="name" select="$name"/>
                                <xsl:with-param name="parent" select="$parent"/>
                                <xsl:with-param name="navindex" select="$navindex"/>
                            </xsl:call-template>
                        </xsl:for-each>
                    </xsl:if>

                <!-- create hidden parameter for identification and deselection -->
            </xsl:when>
            <xsl:otherwise>
                <!-- No appearance or appearance='minimal'-->
                <xsl:choose>
                    <!-- Open Selection -->
                    <xsl:when test="@selection='open'">
                        <select id="{concat($id,'-value')}"
                                name="{$name}"
                                class="xfValue"
                                size="1"
                                dataType="{$datatype}"
                                controlType="select1ComboBoxOpen"
                                title=""
                                tabindex="{$navindex}"
                                schemaValue="{bf:data/@bf:schema-value}"
                                autocomplete="true"
                                incremental="{$incremental}">
                            <xsl:call-template name="build-items">
                                <xsl:with-param name="parent" select="$parent"/>
                                <xsl:with-param name="appearance" select="$appearance"/>
                            </xsl:call-template>
                        </select>
                    </xsl:when>
                    <!-- Standard Minimal Select -->
                    <xsl:otherwise>
                        <select id="{$id}-value"
                                name="{$name}"
                                class="xfValue"
                                dataType="{$datatype}"
                                controlType="select1ComboBox"
                                title=""
                                tabindex="{$navindex}"
                                schemaValue="{bf:data/@bf:schema-value}"
                                incremental="{$incremental}">
                            <xsl:call-template name="build-items">
                                <xsl:with-param name="parent" select="$parent"/>
                            </xsl:call-template>
                        </select>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template name="select">
        <xsl:variable name="navindex" select="if (exists(@navindex)) then @navindex else '0'"/>
        <xsl:variable name="id" select="@id"/>
        <xsl:variable name="selection" select="@selection"/>
        <xsl:variable name="name" select="concat($data-prefix,$id)"/>
        <xsl:variable name="parent" select="."/>
        <xsl:variable name="incremental" select="if (exists(@incremental)) then @incremental else 'true'"/>
        <xsl:variable name="schemaValue" select="bf:data/@bf:schema-value"/>
        <xsl:variable name="datatype"><xsl:call-template name="getType"/></xsl:variable>
        <xsl:variable name="appearance" select="bfn:getAppearance(@appearance)"/>
        <xsl:choose>
            <!-- only 'full' is supported as explicit case and renders a group of checkboxes. All other values
            of appearance will be matched and represented as a list control. -->
            <xsl:when test="$appearance='full'">
                <span id="{$parent/@id}-value"
                      name="{$name}"
                      class="xfValue bfCheckBoxGroup"
                      selection="{$selection}"
                      controlType="selectCheckBoxGroup"
                      dataType="{$datatype}"
                      title=""
                      schemaValue="{bf:data/@bf:schema-value}"
                      incremental="{$incremental}">
                    <xsl:for-each select="$parent/xforms:item|$parent/xforms:choices|$parent/xforms:itemset">
                        <xsl:call-template name="build-checkboxes-list">
                            <xsl:with-param name="name" select="$name"/>
                            <xsl:with-param name="parent" select="$parent"/>
                            <xsl:with-param name="navindex" select="$navindex"/>
                        </xsl:call-template>
                    </xsl:for-each>
                </span>
                <!-- handle itemset prototype -->
                <xsl:if test="not(ancestor::xforms:repeat)">
                    <xsl:for-each select="xforms:itemset/bf:data/xforms:item">
                        <xsl:call-template name="build-checkbox-prototype">
                            <xsl:with-param name="item-id" select="@id"/>
                            <xsl:with-param name="itemset-id" select="../../@id"/>
                            <xsl:with-param name="name" select="$name"/>
                            <xsl:with-param name="parent" select="$parent"/>
                        </xsl:call-template>
                    </xsl:for-each>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <select id="{concat($id,'-value')}"
                        name="{$name}"
                        size="{@size}"
                        multiple="true"
                        controlType="selectList"
                        dataType="{$datatype}"
                        class="xfValue"
                        title=""
                        tabindex="{$navindex}"
                        schemaValue="{bf:data/@bf:schema-value}"
                        selection="{$selection}"
                        incremental="{$incremental}">
                    <xsl:call-template name="build-items">
                        <xsl:with-param name="parent" select="$parent"/>
                        <xsl:with-param name="appearance" select="$appearance"/>
                    </xsl:call-template>
                </select>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="range">
        <xsl:variable name="datatype">
            <xsl:call-template name="getType"/>
        </xsl:variable>
<!--        <xsl:message select="concat('Datatype: ',$datatype)"/>-->
        <xsl:variable name="name" select="concat($data-prefix,@id)"/>

        <xsl:variable name="incremental" select="if (exists(@incremental)) then @incremental else 'false'"/>

        <xsl:variable name="incrementaldelay">
            <xsl:value-of select="if (exists(@bf:incremental-delay)) then @bf:incremental-delay else '0'"/>
        </xsl:variable>

<!--
        <xsl:if test="$incrementaldelay ne '0'">
            <xsl:message>
                <xsl:value-of select="concat(' incremental-delay: ', $incrementaldelay)"/>
            </xsl:message>
        </xsl:if>
-->
        <xsl:variable name="navindex" select="if (exists(@navindex)) then @navindex else '0'"/>
        <xsl:variable name="accesskey" select="if (exists(@accesskey)) then @accesskey else 'none'"/>

        <xsl:variable name="value" select="bf:data/text()"/>
        <xsl:variable name="start" select="@start"/>
        <xsl:variable name="end" select="@end"/>
        <xsl:variable name="step" select="@step"/>
        <xsl:variable name="appearance" select="@appearance"/>

        <span id="{concat(@id,'-value')}"
              class="xfValue"
              dataType="{$datatype}"
              controlType="{local-name()}"
              appearance="{$appearance}"
              name="{$name}"
              incremental="{$incremental}"
              tabindex="{$navindex}"
              start="{$start}"
              end="{$end}"
              delay="{$incrementaldelay}"
              step="{$step}"
              value="{$value}"
              title="">
            <xsl:if test="$accesskey != ' none'">
                <xsl:attribute name="accessKey">
                    <xsl:value-of select="$accesskey"/>
                </xsl:attribute>
            </xsl:if>
        </span>
    </xsl:template>


    <!-- build submit -->
    <!-- todo: align with trigger template -->
    <xsl:template name="submit">
        <xsl:param name="classes"/>
    </xsl:template>

    <!-- build trigger -->
    <xsl:template name="trigger">
        <xsl:param name="classes"/>
        <xsl:variable name="navindex" select="if (exists(@navindex)) then @navindex else '0'"/>
        <xsl:variable name="id" select="@id"/>
        <xsl:variable name="appearance" select="@appearance"/>
        <xsl:variable name="name" select="concat($data-prefix,$id)"/>
        <xsl:variable name="src" select="@src" />
        <xsl:variable name="control-classes">
            <xsl:call-template name="assemble-control-classes">
                <!--<xsl:with-param name="appearance" select="$appearance"/>-->
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="label">
            <xsl:call-template name="create-label">
                <xsl:with-param name="label-elements" select="xforms:label"/>
            </xsl:call-template>
        </xsl:variable>
        <span id="{$id}" class="{$control-classes}" dojoType="betterform.ui.Control">
        <!-- minimal appearance only supported in scripted mode -->
            <xsl:choose>
                <xsl:when test="$appearance='minimal'">
                        <span id="{$id}-value"
                              appearance="{@appearance}"
                              controlType="minimalTrigger"
                              name="{$name}"
                              class="xfValue {@class}"
                              title=""
                              navindex="{$navindex}"
                              accesskey="{@accesskey}"
                              label="{$label}"
                              source="{$src}">
                              <xsl:apply-templates select="@*[not(name()='class')][not(name()='id')][not(name()='appearance')][not(name()='src')]"/>
                        </span>
                </xsl:when>
                <xsl:when test="$appearance='bf:imageTrigger'">
                    <button id="{$id}-value"
                            appearance="{@appearance}"
                            controlType="trigger"
                            label="{$label}"
                            name="{$name}"
                            type="button"
                            class="xfValue"
                            title=""
                            navindex="{$navindex}"
                            accesskey="{@accesskey}"
                            source="{$src}">
                            <xsl:apply-templates select="@*[not(name()='class')][not(name()='id')][not(name()='appearance')][not(name()='src')]"/>
                        <span id="{$id}-label" class="buttonLabel">
                            <xsl:call-template name="create-label">
                                <xsl:with-param name="label-elements" select="xforms:label"/>
                            </xsl:call-template>
                        </span>
                    </button>
                </xsl:when>
                <xsl:when test="xforms:label//*[exists(@mediatype)][1]/@mediatype">
                    <xsl:variable name="label">
                        <xsl:call-template name="create-label">
                            <xsl:with-param name="label-elements" select="xforms:label"/>
                        </xsl:call-template>
         		    </xsl:variable>
                    <xsl:variable name="labelmediatype" select="xforms:label//*[exists(@mediatype)][1]/@mediatype"/>
                    <button id="{$id}-value"
                            appearance="{@appearance}"
                            controlType="trigger"
                            label="{$label}"
                            name="{$name}"
                            type="button"
                            class="xfValue"
                            title=""
                            navindex="{$navindex}"
                            accesskey="{@accesskey}"
                            labelmediatype="{$labelmediatype}">
                        <xsl:apply-templates select="xforms:label"/>
                    </button>
                </xsl:when>

                <xsl:otherwise>
                    <xsl:variable name="label">
                        <xsl:call-template name="create-label">
                            <xsl:with-param name="label-elements" select="xforms:label"/>
                        </xsl:call-template>
         		    </xsl:variable>
                    <xsl:variable name="source" select="if (contains(@mediatype, 'image/')) then $label else $src"/>
                    <button id="{$id}-value"
                            appearance="{@appearance}"
                            controlType="trigger"
                            label="{$label}"
                            name="{$name}"
                            type="button"
                            class="xfValue"
                            title=""
                            navindex="{$navindex}"
                            accesskey="{@accesskey}"
                            source="{$source}"/>
                </xsl:otherwise>
            </xsl:choose>
        </span>
    </xsl:template>



    <!-- ######################################################################################################## -->
    <!-- ########################################## HELPER TEMPLATES FOR SELECT, SELECT1 ######################## -->
    <!-- ######################################################################################################## -->

    <xsl:template name="build-items">
        <xsl:param name="parent"/>
        <xsl:param name="appearance"/>
        <xsl:if test="(local-name($parent) ='select1' and ($appearance = 'minimal') or not(exists($parent/@appearance)))">

            <xsl:variable name="aggregatedEmptyValue" >
                <xsl:for-each select="$parent//*[not(exists(ancestor::bf:data))]/xforms:value">
                    <xsl:if test=". =''">true</xsl:if>
                </xsl:for-each>
            </xsl:variable>
            <xsl:variable name="hasEmptyValue" as="xsd:boolean">
                <xsl:choose>
                    <xsl:when test="contains($aggregatedEmptyValue, 'true')"><xsl:value-of select="true()"/></xsl:when>
                    <xsl:otherwise><xsl:value-of select="false()"/></xsl:otherwise>
                </xsl:choose>
            </xsl:variable>

            <xsl:if test="not($hasEmptyValue)">
                <option value="" class="xfSelectorItem">
                    <xsl:if test="string-length($parent/bf:data/text()) = 0">
                        <xsl:attribute name="selected">selected</xsl:attribute>
                    </xsl:if>--SELECT--</option>
            </xsl:if>
        </xsl:if>
		<!-- add an empty item, because otherwise deselection is not possible -->
<!--
        <xsl:if test="$parent/bf:data/@bf:required='false'">
		<option value="">
			<xsl:if test="string-length($parent/bf:data/text()) = 0">
				<xsl:attribute name="selected">selected</xsl:attribute>
			</xsl:if>
		</option>
        </xsl:if>
-->
		<xsl:for-each select="$parent/xforms:itemset|$parent/xforms:item|$parent/xforms:choices">
			<xsl:call-template name="build-items-list">
                <xsl:with-param name="selectNode" select="$parent"/>
            </xsl:call-template>
		</xsl:for-each>
    </xsl:template>

    <xsl:template name="build-items-list">
        <xsl:param name="selectNode"  />
    	<xsl:choose>
    		<xsl:when test="local-name(.) = 'choices'">    		    
    		    <xsl:call-template name="build-items-choices">
                    <xsl:with-param name="selectNode" select="$selectNode"/>
                </xsl:call-template>
    		</xsl:when>
    		<xsl:when test="local-name(.) = 'itemset'">
    			<xsl:call-template name="build-items-itemset">
                    <xsl:with-param name="selectNode" select="$selectNode"/>
                </xsl:call-template>
    		</xsl:when>
    		<xsl:when test="local-name(.) = 'item'">
    			<xsl:call-template name="build-items-item"/>
    		</xsl:when>
    	</xsl:choose>
    </xsl:template>

	<xsl:template name="build-items-choices">
        <xsl:param name="selectNode"  />
        <xsl:variable name="label">
            <xsl:call-template name="create-label">
                <xsl:with-param name="label-elements" select="xforms:label"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$label != ''">
                <optgroup id="{@id}" label="{$label}" class="xfOptGroupLabel">
                    <xsl:for-each select="xforms:itemset|xforms:item|xforms:choices">
                        <xsl:call-template name="build-items-list">
                            <xsl:with-param name="selectNode" select="$selectNode"/>
                        </xsl:call-template>
                    </xsl:for-each>
                </optgroup>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="xforms:itemset|xforms:item|xforms:choices">
                    <xsl:call-template name="build-items-list">
                        <xsl:with-param name="selectNode" select="$selectNode"/>
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
	</xsl:template>

    <xsl:template name="build-items-itemset">
        <xsl:param name="selectNode"/>
        <xsl:variable name="bfNoOptGroup" as="xsd:boolean">
            <xsl:choose>
                <xsl:when test="contains($selectNode/@appearance, 'bfNoOptGroup')"><xsl:value-of select="true()"/></xsl:when>
                <xsl:otherwise><xsl:value-of select="false()"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$bfNoOptGroup">
                <xsl:for-each select="xforms:item">
                    <xsl:call-template name="build-items-item"/>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <optgroup id="{@id}" class="xfOptGroup" controlType="optGroup" label="{@label}">
                    <xsl:for-each select="xforms:item">
                        <xsl:call-template name="build-items-item"/>
                    </xsl:for-each>
                </optgroup>
            </xsl:otherwise>
        </xsl:choose>
	</xsl:template>

	<xsl:template name="build-items-item">
        <xsl:variable name="itemValue">
            <xsl:choose>
                <xsl:when test="exists(xforms:copy)"><xsl:value-of select="xforms:copy/@id"/></xsl:when>
                <xsl:otherwise><xsl:value-of select="xforms:value"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <option id="{@id}" value="{$itemValue}" title="" class="xfSelectorItem">
            <xsl:if test="@selected='true'">
                <xsl:attribute name="selected">selected</xsl:attribute>
            </xsl:if>
            <xsl:call-template name="create-label">
                <xsl:with-param name="label-elements" select="xforms:label"/>
            </xsl:call-template>
        </option>
    </xsl:template>

    <xsl:template name="build-item-prototype">
        <xsl:param name="item-id"/>
        <xsl:param name="itemset-id"/>

        <select id="{$itemset-id}-prototype" class="xfSelectorPrototype">
            <option id="{$item-id}-value" class="xfSelectorPrototype">
	           	<xsl:choose>
    	       		<xsl:when test="xforms:copy">
	    	   			<xsl:attribute name="value" select="xforms:copy/@id"/>
	              		<xsl:attribute name="title" select="''"/>
                        <!-- MERGETODO: check which is the right version -->
                        <!-- DropDownDate: -->
                        <!-- <xsl:attribute name="title" select="xforms:copy/@id"/> -->
    	          	</xsl:when>
        	      	<xsl:otherwise>
            	   		<xsl:attribute name="value" select="normalize-space(xforms:value)"/>
              			<xsl:attribute name="title" select="''"/>
                	</xsl:otherwise>
				</xsl:choose>
                <xsl:if test="@selected='true'">
                    <xsl:attribute name="selected">selected</xsl:attribute>
                </xsl:if>
                <xsl:call-template name="create-label">
                    <xsl:with-param name="label-elements" select="xforms:label"/>
                </xsl:call-template>
            </option>
        </select>
    </xsl:template>


    <xsl:template name="build-checkboxes-list">
    	<xsl:param name="name"/>
        <xsl:param name="parent"/>
        <xsl:param name="navindex"/>
    	<xsl:choose>
    		<xsl:when test="local-name(.) = 'choices'">
    			<xsl:call-template name="build-checkboxes-choices">
            		<xsl:with-param name="name" select="$name"/>
            		<xsl:with-param name="parent" select="$parent"/>
            		<xsl:with-param name="navindex" select="$navindex"/>
            	</xsl:call-template>
    		</xsl:when>
    		<xsl:when test="local-name(.) = 'itemset'">
    			<xsl:call-template name="build-checkboxes-itemset">
            		<xsl:with-param name="name" select="$name"/>
            		<xsl:with-param name="parent" select="$parent"/>
            		<xsl:with-param name="navindex" select="$navindex"/>
            	</xsl:call-template>
    		</xsl:when>
    		<xsl:when test="local-name(.) = 'item'">
    			<xsl:call-template name="build-checkboxes-item">
            		<xsl:with-param name="name" select="$name"/>
            		<xsl:with-param name="parent" select="$parent"/>
            		<xsl:with-param name="navindex" select="$navindex"/>
            	</xsl:call-template>
    		</xsl:when>
    	</xsl:choose>
    </xsl:template>


	<xsl:template name="build-checkboxes-choices">
		<xsl:param name="name"/>
        <xsl:param name="parent"/>
        <xsl:param name="navindex"/>

        <xsl:variable name="label">
            <xsl:call-template name="create-label">
                <xsl:with-param name="label-elements" select="xforms:label"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$label != ''">
                <span id="{@id}">
                    <span id="{@id}-label" class="xfOptGroupLabelFull"><xsl:value-of select="$label"/></span>
                    <xsl:for-each select="xforms:itemset|xforms:item|xforms:choices">
                        <xsl:call-template name="build-checkboxes-list">
                            <xsl:with-param name="name" select="$name"/>
                            <xsl:with-param name="parent" select="$parent"/>
                            <xsl:with-param name="navindex" select="$navindex"/>
                        </xsl:call-template>
                    </xsl:for-each>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="xforms:itemset|xforms:item|xforms:choices">
                    <xsl:call-template name="build-checkboxes-list">
                        <xsl:with-param name="name" select="$name"/>
                        <xsl:with-param name="parent" select="$parent"/>
                        <xsl:with-param name="navindex" select="$navindex"/>
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
	</xsl:template>

    <xsl:template name="build-checkboxes-itemset">
    	<xsl:param name="name"/>
        <xsl:param name="parent"/>
        <xsl:param name="navindex"/>
		<span id="{@id}" dojoType="betterform.ui.select.CheckBoxItemset" >
			<xsl:for-each select="xforms:item">
				<xsl:call-template name="build-checkboxes-item">
	           		<xsl:with-param name="name" select="$name"/>
	           		<xsl:with-param name="parent" select="$parent"/>
	           		<xsl:with-param name="navindex" select="$navindex"/>
				</xsl:call-template>
			</xsl:for-each>
		</span>
	</xsl:template>

	<xsl:template name="build-checkboxes-item">
    	<xsl:param name="name"/>
        <xsl:param name="parent"/>
        <xsl:param name="navindex"/>
        <span id="{@id}" class="xfSelectorItem">
            <input id="{@id}-value"
                   class="xfCheckBoxValue"
                   type="checkbox"
                   tabindex="0"
                   controlType="checkBoxEntry"
                   selectWidgetId="{$parent/@id}-value"
                   name="{$name}">
                   <!--dojotype="betterform.ui.select.CheckBox">-->
                <xsl:if test="@selected='true'">
                    <xsl:attribute name="checked">checked</xsl:attribute>
                </xsl:if>

                <xsl:choose>
        			<xsl:when test="xforms:copy">
           				<xsl:attribute name="value" select="xforms:copy/@id"/>
	            	</xsl:when>
    	        	<xsl:otherwise>
	    	    		<xsl:attribute name="value" select="xforms:value"/>
    	    		</xsl:otherwise>
        	    </xsl:choose>
                <xsl:attribute name="title"/>
                <xsl:text> </xsl:text>

            </input>

            <label id="{@id}-label" for="{@id}-value" class="xfCheckBoxLabel">
                <xsl:if test="$parent/bf:data/@bf:readonly='true'">
                    <xsl:attribute name="disabled">disabled</xsl:attribute>
                </xsl:if>
                <xsl:call-template name="create-label">
                    <xsl:with-param name="label-elements" select="xforms:label"/>
                </xsl:call-template>
            </label>
        </span>
	</xsl:template>

    <xsl:template name="build-checkbox-prototype">
        <xsl:param name="item-id"/>
        <xsl:param name="itemset-id"/>
        <xsl:param name="name"/>
        <xsl:param name="parent"/>

        <span id="{$itemset-id}-prototype" class="xfSelectorPrototype">
            <input id="{$item-id}-value" class="xfValue" type="checkbox" name="{$name}">
                <xsl:choose>
	       			<xsl:when test="xforms:copy">
		   				<xsl:attribute name="value"><xsl:value-of select="xforms:copy/@id"/></xsl:attribute>
	              	</xsl:when>
    	        	<xsl:otherwise>
      	 	    		<xsl:attribute name="value"><xsl:value-of select="xforms:value"/></xsl:attribute>
            		</xsl:otherwise>
           	    </xsl:choose>
                <xsl:attribute name="title"/>
                <xsl:if test="$parent/bf:data/@bf:readonly='true'">
                    <xsl:attribute name="disabled">disabled</xsl:attribute>
                </xsl:if>
                <xsl:if test="@selected='true'">
                    <xsl:attribute name="checked">checked</xsl:attribute>
                </xsl:if>
                <xsl:attribute name="onclick">setXFormsValue(this);</xsl:attribute>
                <xsl:attribute name="onkeydown">DWRUtil.onReturn(event, submitFunction);</xsl:attribute>
                <xsl:text> </xsl:text>
            </input>
            <span id="{@item-id}-label" class="xfLabel">
                <xsl:if test="$parent/bf:data/@bf:readonly='true'">
                    <xsl:attribute name="disabled">disabled</xsl:attribute>
                </xsl:if>
                <xsl:call-template name="create-label">
                    <xsl:with-param name="label-elements" select="xforms:label"/>
                </xsl:call-template>
            </span>
        </span>
    </xsl:template>

    <!-- overwrite/change this template, if you don't like the way labels are rendered for checkboxes -->
    <xsl:template name="build-radiobuttons">
        <xsl:param name="name"/>
        <xsl:param name="parent"/>
        <xsl:param name="id"/>
        <xsl:param name="navindex"/>
        <!-- handle items, choices and itemsets -->
        <xsl:for-each select="$parent/xforms:item|$parent/xforms:choices|$parent/xforms:itemset">
        	<xsl:call-template name="build-radiobuttons-list">
        		<xsl:with-param name="name" select="$name"/>
        		<xsl:with-param name="parent" select="$parent"/>
        		<xsl:with-param name="navindex" select="$navindex"/>

        	</xsl:call-template>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="build-radiobuttons-list">
    	<xsl:param name="name"/>
    	<xsl:param name="parent"/>
    	<xsl:param name="navindex"/>

        <!-- todo: refactor to handle xforms:choice / xforms:itemset by matching -->
        <xsl:choose>
    		<xsl:when test="local-name(.) = 'choices'">
    			<xsl:call-template name="build-radiobuttons-choices">
            		<xsl:with-param name="name" select="$name"/>
            		<xsl:with-param name="parent" select="$parent"/>
            		<xsl:with-param name="navindex" select="$navindex"/>
            	</xsl:call-template>
    		</xsl:when>
    		<xsl:when test="local-name(.) = 'itemset'">
    			<xsl:call-template name="build-radiobuttons-itemset">
            		<xsl:with-param name="name" select="$name"/>
            		<xsl:with-param name="parent" select="$parent"/>
            		<xsl:with-param name="navindex" select="$navindex"/>
            	</xsl:call-template>
    		</xsl:when>
    		<xsl:when test="local-name(.) = 'item'">
    			<xsl:call-template name="build-radiobuttons-item">
            		<xsl:with-param name="name" select="$name"/>
            		<xsl:with-param name="parent" select="$parent"/>
            		<xsl:with-param name="navindex" select="$navindex"/>
            	</xsl:call-template>
    		</xsl:when>
    	</xsl:choose>
    </xsl:template>

	<xsl:template name="build-radiobuttons-choices">
		<xsl:param name="name"/>
		<xsl:param name="parent"/>
		<xsl:param name="navindex"/>

        <xsl:variable name="label">
            <xsl:call-template name="create-label">
                <xsl:with-param name="label-elements" select="xforms:label"/>
            </xsl:call-template>

        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$label != ''">
                <span id="{@id}">
                    <span id="{@id}-label" class="xfOptGroupLabelFull"><xsl:value-of select="$label"/></span>
                    <xsl:for-each select="xforms:itemset|xforms:item|xforms:choices">
                        <xsl:call-template name="build-radiobuttons-list">
                            <xsl:with-param name="name" select="$name"/>
                            <xsl:with-param name="parent" select="$parent"/>
                            <xsl:with-param name="navindex" select="$navindex"/>
                        </xsl:call-template>
                    </xsl:for-each>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="xforms:itemset|xforms:item|xforms:choices">
                    <xsl:call-template name="build-radiobuttons-list">
                        <xsl:with-param name="name" select="$name"/>
                        <xsl:with-param name="parent" select="$parent"/>
                        <xsl:with-param name="navindex" select="$navindex"/>
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
	</xsl:template>

    <xsl:template name="build-radiobuttons-itemset">
    	<xsl:param name="name"/>
    	<xsl:param name="parent"/>
    	<xsl:param name="navindex"/>

		<span id="{@id}" dojoType="betterform.ui.select1.RadioItemset" class="xfRadioItemset">
			<xsl:for-each select="xforms:item">
				<xsl:call-template name="build-radiobuttons-item">
	           		<xsl:with-param name="name" select="$name"/>
	           		<xsl:with-param name="parent" select="$parent"/>
	           		<xsl:with-param name="navindex" select="$navindex"/>
				</xsl:call-template>
			</xsl:for-each>
		</span>
	</xsl:template>

	<xsl:template name="build-radiobuttons-item">
    	<xsl:param name="name"/>
    	<xsl:param name="parent"/>
        <xsl:param name="navindex"/>
        <xsl:variable name="parentId" select="$parent/@id"/>
        <xsl:variable name="label">
            <xsl:call-template name="create-label">
                <xsl:with-param name="label-elements" select="xforms:label"/>
            </xsl:call-template>
        </xsl:variable>
        <span id="{@id}"
              class="xfSelectorItem"
              controlType="radioButtonEntry">
            <input id="{@id}-value"
                   class="xfRadioValue"
                   dataType="radio"
                   controlType="radio"
                   parentId="{$parentId}"
                   name="{$name}"
                   selected="{@selected}"
                   >
                <xsl:if test="string-length($navindex) != 0">
                    <xsl:attribute name="tabindex">
                        <xsl:value-of select="$navindex"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:attribute name="value">
                    <xsl:choose>
                        <xsl:when test="xforms:copy"><xsl:value-of select="xforms:copy/@id"/></xsl:when>
                        <xsl:otherwise><xsl:value-of select="normalize-space(xforms:value)"/></xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:attribute name="title"/>
            </input>
            <label id="{@id}-label" for="{@id}-value" class="xfRadioLabel">
                <xsl:if test="$parent/bf:data/@bf:readonly='true'">
                    <xsl:attribute name="disabled">disabled</xsl:attribute>
                </xsl:if>
                <xsl:value-of select="$label"/>
            </label>
        </span>
	</xsl:template>

    <xsl:template name="build-radiobutton-prototype">
        <xsl:param name="item-id"/>
        <xsl:param name="itemset-id"/>
        <xsl:param name="name"/>
        <xsl:param name="parent"/>
        <xsl:param name="navindex"/>
        <span id="{$itemset-id}-prototype" class="xfSelectorPrototype">
            <input id="{$item-id}-value" class="xfValue" type="radio" name="{$name}">
                <xsl:if test="string-length($navindex) != 0">
                    <xsl:attribute name="tabindex">
                        <xsl:value-of select="$navindex"/>
                    </xsl:attribute>
                </xsl:if>


                <xsl:attribute name="value">
                    <xsl:choose>
                        <xsl:when test="xforms:copy"><xsl:value-of select="xforms:copy/@id"/></xsl:when>
                        <xsl:otherwise><xsl:value-of select="normalize-space(xforms:value)"/></xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:attribute name="title"/>


              <xsl:if test="$parent/bf:data/@bf:readonly='true'">
                    <xsl:attribute name="disabled">disabled</xsl:attribute>
                </xsl:if>
                <xsl:if test="@selected='true'">
                    <xsl:attribute name="checked">checked</xsl:attribute>
                </xsl:if>
                <xsl:attribute name="onclick">setXFormsValue(this);</xsl:attribute>
                <xsl:attribute name="onkeydown">DWRUtil.onReturn(event, submitFunction);</xsl:attribute>
            </input>
            <span id="{$item-id}-label" class="xfLabel">
                <xsl:if test="$parent/bf:data/@bf:readonly='true'">
                    <xsl:attribute name="disabled">disabled</xsl:attribute>
                </xsl:if>
                <!--<xsl:message>Fix this for internationalization</xsl:message>-->
                <xsl:apply-templates select="xforms:label" mode="prototype"/>
            </span>
        </span>
    </xsl:template>


    <xsl:function name="bfn:getAppearance" as="xsd:string?">
        <xsl:param name="arg" as="xsd:string?"/>
<!--
        <xsl:sequence select="concat(upper-case(substring($arg,1,1)),substring($arg,2))"/>
-->
        <xsl:choose>
            <xsl:when test="exists($arg) and contains($arg,'bfNoOptGroup')">
                <xsl:choose>
                    <xsl:when test="contains($arg,'minimal')">minimal</xsl:when>
                    <xsl:when test="contains($arg,'compact')">compact</xsl:when>
                    <xsl:when test="contains($arg,'full')">full</xsl:when>
                    <xsl:otherwise><xsl:value-of select="$arg"/></xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise><xsl:value-of select="$arg"/></xsl:otherwise>
        </xsl:choose>
    </xsl:function>
</xsl:stylesheet>
