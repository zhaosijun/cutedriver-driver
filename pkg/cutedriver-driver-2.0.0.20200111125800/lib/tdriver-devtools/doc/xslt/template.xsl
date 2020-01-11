<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:str="http://exslt.org/strings" 
  xmlns:exsl="http://exslt.org/common" 
  extension-element-prefixes="exsl str">
  
    <xsl:preserve-space elements="*"/>
    <xsl:output method="html"/>

    <xsl:template match="/">
        <html>
            <head>
                <style  TYPE="text/css">

      body
      {
         padding: 10px;
         border: #e7e7e7 1px solid;
         background: #ffffff;
         color: black;
         font-size: 13px;
         cursor: default;
         #text-shadow: #909090 1px 1px 1px;
      }
      
      h2
      {
         text-shadow: #909090 1px 1px 2px;
      }
      
      div.feature_title
      {

        padding: 8px;

        background: #404040;

        border-top: 1px solid #484848;
        border-left: 1px solid #484848;

        border-bottom: 1px solid #2a2a2a;
        border-right: 1px solid #2a2a2a;

        -moz-box-shadow: 1px 1px 4px #010101;
        -webkit-box-shadow: 1px 1px 4px #010101;
 
      }

      span.feature_title_text, a.feature_name_link
      {
        text-decoration: none;
        font-size: 20px; 
        color: #FFFFFF;
        text-shadow: #101010 2px 2px 3px;
        font-weight: bold;
      }
  
      span.feature_title_text:hover
      { 



      }

      div.feature_section_title
      {

        font-family: arial;
        font-size: 13px;
        font-weight: bold;
        color: #000000;
        #text-shadow: #A0A0A0 1px 1px 0px;

      }
      
      div.feature_description, div.feature_call_sequence, div.scenario_description, div.feature_deprecated_version
      {

        padding: 2px;
        font-family: 'Times New Roman', Times, serif;
        font-size: 13px;
        font-weight: normal; 
        
      }
      
      div.feature_info
      {

        font-family: 'Times New Roman', Times, serif;
        font-weight: normal; 
      
      }
      
      div.feature_description, div.scenario_description, div.feature_deprecated_version
      {
        font-style: normal; // normal more readable than italic;
      }
      
      div.feature_call_sequence
      {
            
      }

      table.default
      {
      
        margin-top: 2px;
      
        width: 100%;
              
        text-align: left;
      
        <!-- cellspacing -->
        border-spacing: 1px;
            
        border: 1px solid #c1c1c1;
        border-top: 1px solid #e1e1e1;
        border-left: 1px solid #e1e1e1;
      
      }

      tr.header, tr.header_custom
      {      
        #background: #96E066;
        font-weight: bold;
      }
      
      tr.header_custom
      {
      
        #background: #f0a646;
      
      }

      td.header_custom{

        background: #f0a646;

        border-top: 1px solid #707070;
        border-left: 1px solid #707070;

        background: #606260;

        border-bottom: 1px solid #595959;
        border-right: 1px solid #595959;

      }

      <!-- table-style: cellpadding -->
      td
      {
      
        padding: 6px;
        font-family: arial;
        font-size: 11px;      
      
      }

      td.header
      {

        font-size: 11px;      
        border-top: 1px solid #a0a0a0;
        border-left: 1px solid #a0a0a0;

        background: #909290;

        border-bottom: 1px solid #797979;
        border-right: 1px solid #797979;


      }

      td.tablebg_even
      {
        background: #ededed;
        border-top: 1px solid #f5f5f5;
        border-left: 1px solid #f5f5f5;
        border-bottom: 1px solid #d6d6d6;
        border-right: 1px solid #d6d6d6;
      }

      td.tablebg_odd
      {
        background: #dedede;
        border-top: 1px solid #e6e6e6;
        border-left: 1px solid #e6e6e6;
        border-bottom: 1px solid #c7c7c7;
        border-right: 1px solid #c7c7c7;
      }

      td.warning, div.warning, span.warning, td.tablebg_warning, pre.failed, pre.skipped
      {

        background: #a11010;
        color: #ffff00;
        text-shadow: #666600 1px 1px 4px;

      }

      td.tablebg_warning, td.warning, pre.failed, pre.skipped
      {

        border-top: 1px solid #a91818;
        border-left: 1px solid #a91818;

        border-bottom: 1px solid #8a0000;
        border-right: 1px solid #8a0000;

      }

      td.tablebg_disabled
      {

        background: #d5d5d5;

        background-image:url('images/bg_disabled.png');
        background-repeat: repeat;

        border-top: 1px solid #cdcdcd;
        border-left: 1px solid #cdcdcd;
        border-bottom: 1px solid #aeaeae;
        border-right: 1px solid #aeaeae;

      }

      div.warning
      {
        color: #ffff00;
        text-shadow: #666600 1px 1px 4px;

        font-family: arial;
        font-size: 11px;      
        padding: 6px;
      
      }

      span.optional_argument
      {
        #font-style: italic;
        color: #777777;
      }

      pre
      {
      
        font-family: monospace;
        font-size: 11px;

        white-space: pre-wrap;       
        word-wrap: break-word;
        break-word: break-all;
      
      }

      pre.passed, pre.failed, pre.skipped, pre.block
      {
      
        margin: 5px 2px 9px 2px;
        padding: 10px 10px 10px 8px;
            
      }

      pre.passed, pre.block
      {

        background: #f1f1f1;

        border-top: 1px solid #f9f9f9;
        border-left: 1px solid #f9f9f9;

        border-bottom: 1px solid #dadada;
        border-right: 1px solid #dadada;

        color: black;
      }

      pre.failed, pre.skipped
      {

        //color: black;

      }
      span.hover_text
      {
      
        cursor: help; //pointer;
        border-bottom: 1px dotted #b1b1b1;
      
      }

      span.hover_text:hover
      {
      
        cursor: help; //pointer;
        border-bottom: 1px dotted #515151;
      
      }
      
      span.toc_title
      {
      
        font-size: 24px;
        font-weight: bold;
        #text-shadow: #909090 1px 1px 1px;
		text-align: center;
      
      }
      
      div.toc
      {
      
        padding: 5px;
        width: 65%;
        word-spacing: normal;
      }

      span.toc_block
      {
      
        padding: 7px;
		
      }
      
      a.toc_item
      {
      
        font-size: 20px;
        text-decoration: none;
        color: #313131;
        text-align: center;
		
      }
      
      a.toc_item2
      {
      
        font-size: 11px;
        text-decoration: none;
        color: #313131;
		
      }

      a.toc_item:hover
      {
      
        border-bottom: 1px dotted #515151;

      }
      
      a.toc_item2:hover
      {
      
        border-bottom: 1px dotted #515151;

      }

      
      a.jump_to
      {
      
        font-size: 11px;
        text-decoration: none;
        color: #313131;

      }

      a.jump_to:hover
      {
      
        border-bottom: 1px dotted #515151;

      }

      a.link
      {
      
        text-decoration: none;

        color: #d15131;

        color: #a06060;

        color: #605555;

        #text-shadow: #ff8f6f 1px 1px 4px;

        #text-shadow: #b0a0a0 1px 1px 4px;

        border-bottom: 1px dotted #515151;
        font-weight: bold;

      }

      a.link:hover
      {
      
        border-bottom: 1px dotted #000000;
        color: #000000;

      }


      img
      {
      
        border: 0px;
      
      }

      tr.header, tr.header_custom, div.feature_title, table.default, td.header, td.header_custom, td.tablebg_even, td.tablebg_odd, td.tablebg_warning, td.warning, div.warning, td.tablebg_disabled, pre.passed, pre.failed, pre.skipped, pre.block
      {

        -moz-border-radius: 5px 5px 5px 5px;

        -webkit-border-radius: 9px;
        -webkit-border-top-left-radius: 9px;
        -webkit-border-bottom-right-radius: 9px;


      }
      
                </style>
            </head>
            <body>

                <a name="top">
                    <center>
                        <h1>Testability Driver API Documentation</h1>
                    </center>
                </a>
    
                <xsl:apply-templates/>

            </body>
        </html>
    </xsl:template>

    <xsl:template match="documentation">
<!-- table of contents -->
  <br />
  
  

    <xsl:for-each select="feature/@name">

      <xsl:sort select="." />

      <!---

        file:///home/jussi/git/2010-10-07/driver/lib/output/example.xml#QT;TestObject;activate

      -->

      <xsl:variable name="name"><xsl:value-of select="../@name"/></xsl:variable>
      <xsl:variable name="module"><xsl:value-of select="../behaviour/@module"/></xsl:variable>
      <xsl:variable name="module_name"><xsl:value-of select="../behaviour/@name"/></xsl:variable>

      <xsl:for-each select="str:split(.,';')">
        <span class="toc_block"><a href="#{ $module_name }:{ $name }" class="toc_item2" title="{ $module_name } ({ $module })"><xsl:value-of select="." /></a><xsl:text> </xsl:text></span>
      </xsl:for-each>

      <xsl:text> </xsl:text>
    
    </xsl:for-each>
    

  <br />

  <!-- content -->
  
  <!-- table of contents -->
        <center>
            <span class="toc_title">Table of contents:</span>
            <br />
  
            <div class="toc">
                <table class="default">
                <tr class="header">
                    <td class="header">Method</td>
                    <td class="header">Description</td>
                </tr>
                    <xsl:for-each select="feature/@name">
    
                        <xsl:sort select="." />

      <!---

        file:///home/jussi/git/2010-10-07/driver/lib/output/example.xml#QT;TestObject;activate

      -->

                        <xsl:variable name="name">
                            <xsl:value-of select="../@name"/>
                        </xsl:variable>
                        <xsl:variable name="module">
                            <xsl:value-of select="../behaviour/@module"/>
                        </xsl:variable>
                        <xsl:variable name="module_name">
                            <xsl:value-of select="../behaviour/@name"/>
                        </xsl:variable>
                        <xsl:variable name="feature_description">
						<xsl:call-template name="formatted_content">
                            <xsl:with-param name="text" select="../description/text()" />
						</xsl:call-template> 
                        </xsl:variable>

                        <tr>
                            <td class="tablebg_even" valign="top">
                                <xsl:for-each select="str:split(.,';')">                                    
                                        <span class="toc_block">
                                            <a href="#{ $module_name }:{ $name }" class="toc_item" title="{ $module_name } ({ $module })">
                                                <xsl:value-of select="." />
                                            </a>
                                            <xsl:text> </xsl:text>
                                        </span>                                    
                                </xsl:for-each>
                            </td>
                            <td class="tablebg_even" valign="top">
							
                              <xsl:value-of select="$feature_description" />
							 
                            </td>
                        </tr>
                        <xsl:text> </xsl:text>
    
                    </xsl:for-each>
                </table>
            </div>
        </center>
        <hr />

  <!-- content -->

        <xsl:for-each select="feature">
            <xsl:sort select="@name" />
            <xsl:call-template name="feature">
            </xsl:call-template>
  
        </xsl:for-each>

    </xsl:template>

    <xsl:template name="feature_name">

  <!-- implements following features, e.g. method name, attribute reader, attribute writer or both when attribute accessor -->

 <!-- #{ $module }.{ $name }-->

        <a name="{ ./behaviour/@name }:{ @name }"></a>
        <div class="feature_title">
            <a href="#{ ./behaviour/@name }:{ @name }" class="feature_name_link">
                <xsl:for-each select="str:split(@name,';')">
                    <span class="feature_title_text">
                        <xsl:value-of select="."/>
                    </span>
                    <xsl:if test="position()!=last()">
                        <xsl:text>, </xsl:text>
                    </xsl:if>
                </xsl:for-each>
            </a>
        </div>

        <br />

    </xsl:template>

    <xsl:template name="call_sequence">

        <div class="feature_section_title">Call sequence:</div>

        <div class="feature_call_sequence">
    <!-- method: call example using parameters -->
            <xsl:if test="@type='method'">
    
<!-- contains($type/@name,' ') -->

<!--

    <xsl:choose>
      <xsl:when test="string-length($tmp_full_tag)=0">
        <xsl:value-of select="substring-after(substring-before($text, ']'), '[')" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$tmp_full_tag" />
      </xsl:otherwise>
    </xsl:choose>


-->

    <!-- determine whether add dot between the object and method; e.g. object.method or object[]-->

                <xsl:choose>
                    <xsl:when test="contains(@name, '[')">
                        <xsl:text>object</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>object.</xsl:text>
                        <xsl:value-of select="@name" />
                    </xsl:otherwise>
                </xsl:choose>

                <xsl:choose>

                    <xsl:when test="arguments/@count>0 and count(arguments/argument)&lt;arguments/@count">
                        <xsl:text>( </xsl:text>
                        <xsl:call-template name="span_warning">
                            <xsl:with-param name="text">Incomplete arguments documentation</xsl:with-param>
                        </xsl:call-template>
                        <xsl:text> )</xsl:text>        
                    </xsl:when>

                    <xsl:when test="count(arguments/argument)=0"></xsl:when>
        
                    <xsl:when test="count(arguments/argument)>0">

          <!-- do not show parenthesis if first argument is type of block -->
                        <xsl:if test="arguments/argument[1]/@type!='block'">

                            <xsl:choose>
                                <xsl:when test="contains(@name, '[')">
                                    <xsl:text>[ </xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>( </xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>

            <!--<xsl:text>( </xsl:text>-->

              <!-- collect arguments for example -->
                            <xsl:for-each select="arguments/argument">

                                <xsl:if test="@type='normal' or @type='multi'">

                                    <xsl:choose>

                                        <xsl:when test="@optional='true'">

                                            <span class="optional_argument" title="Optional argument">

                                                <xsl:if test="@type='multi'">
                                                    <xsl:text></xsl:text>        
                                                </xsl:if>

                                                <xsl:text></xsl:text>
                                                <span class="hover_text">
                                                    <xsl:value-of select="@name"/>
                                                    <xsl:if test="@type='multi'">
                                                        <xsl:text>, ..., ...</xsl:text>        
                                                    </xsl:if>
                                                </span>

                                                <xsl:text></xsl:text>

                                            </span>

                                        </xsl:when>

                                        <xsl:otherwise>
                                            <span title="Mandatory argument" class="hover_text">
                                                <xsl:value-of select="@name"/>
                                            </span>
                                        </xsl:otherwise>

                                    </xsl:choose>

                  <!-- separate arguments with comma if next argument defintion is not type of block --> 
                                    <xsl:if test="position()!=last() and (string(following-sibling::argument/@type)!='block' and string(following-sibling::argument/@type)!='block_argument')">
                                        <xsl:text>, </xsl:text>
                                    </xsl:if>
                  
                                </xsl:if>
                
                            </xsl:for-each>
            <!--<xsl:text> ) </xsl:text>-->

                            <xsl:choose>
                                <xsl:when test="contains(@name, ']')">
                                    <xsl:text> ] </xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text> ) </xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>


                        </xsl:if>
          
          <!-- collect arguments for example -->
                        <xsl:for-each select="arguments/argument">

                            <xsl:if test="./@type='block'">
                
                                <xsl:text>{ </xsl:text>

                                <xsl:for-each select="../../arguments/argument[@type='block_argument']">

                                    <xsl:choose>
                                        <xsl:when test="position()=1">
                                            <xsl:text>| </xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:text>, </xsl:text>                          
                                        </xsl:otherwise>
                                    </xsl:choose>

                                    <span title="Code block argument, mandatory or optional" class="hover_text">
                                        <xsl:value-of select="str:split(@name,'#')[2]"/>
                                    </span>

                                    <xsl:if test="position()=last()">
                                        <xsl:text> | </xsl:text>                        
                                    </xsl:if> 

                                </xsl:for-each>
                                    
                                <span class="hover_text" title="Code block, mandatory or optional">
                                    <xsl:value-of select="@name"/>
                                </span>
                                <xsl:text> }</xsl:text>
                
                            </xsl:if>
                
                        </xsl:for-each>

                    </xsl:when>
                  
                </xsl:choose>

      <!-- describe block usage --> 
                <xsl:if test="count(arguments/block)>0">
                    <xsl:text>{ dsadsa</xsl:text>
        <!-- TODO: block arguments -->
                    <xsl:value-of select="arguments/block/@name" />
                    <xsl:text> }</xsl:text>
                </xsl:if>
                <br />
            </xsl:if>

    <!-- attr_reader/attr_accessor: call example -->
            <xsl:if test="@type='reader' or @type='accessor'">
                <xsl:text>return_value = object.</xsl:text>
                <xsl:value-of select="str:split(@name,';')[1]" />
                <br />
            </xsl:if>

    <!-- attr_writer/attr_accessor: call example -->
            <xsl:if test="@type='writer' or @type='accessor'">
    
      <!-- TODO: argument name from arguments array -->
                <xsl:text>object.</xsl:text>
                <xsl:value-of select="str:split(@name,';')[1]" />
                <xsl:text> = ( </xsl:text>

                <xsl:choose>
      
                    <xsl:when test="count(arguments/argument)=0">
                        <span title="Mandatory value" class="hover_text">
                            <xsl:text>new_value</xsl:text>
                        </span>
                    </xsl:when>
        
                    <xsl:otherwise>
                        <span title="Mandatory value" class="hover_text">
                            <xsl:value-of select="arguments/argument[1]/@name" />
                        </span>
                    </xsl:otherwise>

                </xsl:choose>

                <xsl:text> )</xsl:text>
                <br />
            </xsl:if>

        </div>

        <br />

    </xsl:template>

<!-- template to capitalize string -->
    <xsl:template name="capitalize">

        <xsl:param name="text" />
  
        <xsl:value-of select="concat(translate(substring($text,1,1), 'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ'), substring($text,2))"/>

    </xsl:template>

    <xsl:template name="target_details">
  
        <div class="feature_section_title">Feature and target details:</div>
        <table class="default">
            <tr class="header">
                <td class="header">Type</td>
                <td class="header">Target object</td>
                <td class="header">SUT type</td>
                <td class="header">SUT version</td>
                <td class="header">SUT input type</td>
                <td class="header">Behaviour module and name</td>
                <td class="header">Required plugin</td>
            </tr>
            <tr>
    
      <!-- feature type -->
                <td class="tablebg_even" valign="top">
        <!-- capitalize text() -->
                    <xsl:call-template name="capitalize">
                        <xsl:with-param name="text" select="@type" />
                    </xsl:call-template>    
                </td>
      
      <!-- target object -->
                <xsl:choose>
                    <xsl:when test="string-length(@object_type)>0">
                        <td class="tablebg_even" valign="top">
                            <xsl:for-each select="str:split(@object_type,';')">
                                <xsl:choose>
                                    <xsl:when test="text()='*'">
                                        <xsl:text>Any test object</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="text()='sut'">
                                        <xsl:text>SUT object</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="text()" />
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:if test="position()!=last()">
                                    <xsl:text>,</xsl:text> 
                                </xsl:if>
                                <br />
                            </xsl:for-each>
                        </td>
                    </xsl:when>
                    <xsl:otherwise>
                        <td class="tablebg_warning" valign="top">
                            <xsl:call-template name="div_warning">
                                <xsl:with-param name="text">Not defined</xsl:with-param>
                            </xsl:call-template>
                        </td>
                    </xsl:otherwise>
                </xsl:choose>

                  

      <!-- target sut -->
                <xsl:choose>
                    <xsl:when test="string-length(@sut_type)>0">
                        <td class="tablebg_even" valign="top">
                            <xsl:for-each select="str:split(@sut_type,';')">
                                <xsl:choose>
                                    <xsl:when test="text()='*'">
                                        <xsl:text>Any SUT type</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                  <!-- capitalize text() -->
                                        <xsl:call-template name="capitalize">
                                            <xsl:with-param name="text" select="text()" />
                                        </xsl:call-template>    
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:if test="position()!=last()">
                                    <xsl:text>,</xsl:text> 
                                </xsl:if>
                                <br />
                            </xsl:for-each>                
                        </td>
                    </xsl:when>
                    <xsl:otherwise>
                        <td class="tablebg_warning" valign="top">
                            <xsl:call-template name="div_warning">
                                <xsl:with-param name="text">Not defined</xsl:with-param>
                            </xsl:call-template>
                        </td>
                    </xsl:otherwise>
                </xsl:choose>

      <!-- sut version -->
                <xsl:choose>      
                    <xsl:when test="string-length(@sut_version)>0">
                        <td class="tablebg_even" valign="top">
                            <xsl:for-each select="str:split(@sut_version,';')">

                                <xsl:choose>
                                    <xsl:when test="text()='*'">
                                        <xsl:text>All</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                  <!-- capitalize text() -->
                                        <xsl:call-template name="capitalize">
                                            <xsl:with-param name="text" select="text()" />
                                        </xsl:call-template>    
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:if test="position()!=last()">
                                    <xsl:text>,</xsl:text> 
                                </xsl:if>
                                <br />
                            </xsl:for-each> 
                        </td>
                    </xsl:when>
                    <xsl:otherwise>
                        <td class="tablebg_warning" valign="top">
                            <xsl:call-template name="div_warning">
                                <xsl:with-param name="text">Not defined</xsl:with-param>
                            </xsl:call-template>
                        </td>
                    </xsl:otherwise>
                </xsl:choose>

      <!-- input type -->
                <xsl:choose>
                    <xsl:when test="string-length(@input_type)=0">
                        <td class="tablebg_warning" valign="top">
                            <xsl:call-template name="div_warning">
                                <xsl:with-param name="text">Not defined</xsl:with-param>
                            </xsl:call-template>
                        </td> 
                    </xsl:when>
                    <xsl:otherwise>
                        <td class="tablebg_even" valign="top">
                            <xsl:for-each select="str:split(@input_type,';')">
                                <xsl:choose>
                                    <xsl:when test="text()='*'">
                                        <xsl:text>All</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                  <!-- capitalize text() -->
                                        <xsl:call-template name="capitalize">
                                            <xsl:with-param name="text" select="text()" />
                                        </xsl:call-template>    
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:if test="position()!=last()">
                                    <xsl:text>,</xsl:text> 
                                </xsl:if>
                                <br />
                            </xsl:for-each> 
                        </td>
                    </xsl:otherwise>
                </xsl:choose>

      <!-- behaviour module -->
                <xsl:choose>
                    <xsl:when test="string-length(behaviour/@module)>0">

                        <xsl:choose>
                            <xsl:when test="string-length(behaviour/@name)>0">

                                <td class="tablebg_even" valign="top">
                                    <xsl:value-of select="behaviour/@module" />
                                    <xsl:text> (</xsl:text>
                                    <xsl:value-of select="behaviour/@name" />
                                    <xsl:text>)</xsl:text>
                                </td>

                            </xsl:when>
                            <xsl:otherwise>

                                <td class="tablebg_warning" valign="top">
                                    <xsl:call-template name="div_warning">
                                        <xsl:with-param name="text">
                                            <xsl:value-of select="behaviour/@module" />
                                            <xsl:text> (Behaviour name not defined)</xsl:text>
                                        </xsl:with-param>
                                    </xsl:call-template>
                                </td>

                            </xsl:otherwise>
                        </xsl:choose>

                    </xsl:when>
                    <xsl:otherwise>
                        <td class="tablebg_warning" valign="top">
                            <xsl:call-template name="div_warning">
                                <xsl:with-param name="text">Not defined</xsl:with-param>
                            </xsl:call-template>
                        </td>
                    </xsl:otherwise>
                </xsl:choose>

      <!-- required plugin -->
                <xsl:choose>
                    <xsl:when test="string-length(@required_plugin)=0">
                        <td class="tablebg_warning" valign="top">
                            <xsl:call-template name="div_warning">
                                <xsl:with-param name="text">Not defined</xsl:with-param>
                            </xsl:call-template>
                        </td>
                    </xsl:when>
                    <xsl:when test="@required_plugin!='*'">
                        <td class="tablebg_even" valign="top">
                            <xsl:value-of select="@required_plugin" />
                        </td>
                    </xsl:when>
                    <xsl:otherwise>
                        <td class="tablebg_disabled" valign="top"></td>
                    </xsl:otherwise>
                </xsl:choose>

            </tr>

        </table>
        <br />

    </xsl:template>

    <xsl:template name="feature">

        <div id="{ ./behaviour/@name }.@name">

            <xsl:call-template name="feature_name" />

            <xsl:if test="count(deprecated)>0">

                <xsl:call-template name="deprecated" />

            </xsl:if>
    
            <xsl:call-template name="description" />

            <xsl:if test="count(deprecated)>0">

                <xsl:call-template name="target_details" />

            </xsl:if>

            <xsl:if test="count(deprecated)=0">

                <xsl:call-template name="call_sequence" />

                <xsl:call-template name="target_details" />

                <xsl:call-template name="arguments" />

                <xsl:call-template name="returns">
                    <xsl:with-param name="type" select="returns/type" />
                    <xsl:with-param name="feature_type" select="@type" />
                </xsl:call-template>

                <xsl:call-template name="exceptions">
                    <xsl:with-param name="type" select="exceptions/type" />
                    <xsl:with-param name="feature_type" select="@type" />
                </xsl:call-template>

                <xsl:if test="count(tables/table)>0">    
        <!-- custom tables -->
                    <xsl:call-template name="tables" />
                </xsl:if>

                <xsl:call-template name="tests">
                    <xsl:with-param name="tests" select="tests" />
                </xsl:call-template>

            </xsl:if>
      
            <xsl:call-template name="info" />
    
            <xsl:if test="position()!=last()-1">
      <!-- feature separator? -->
            </xsl:if>
          
            <a href="#top" class="jump_to">Jump to top of page</a>
            <br />
            <br />

        </div>
          
    </xsl:template>

    <xsl:template name="exceptions">

        <xsl:param name="type" />
        <xsl:param name="feature_type" />

        <xsl:if test="count($type)>0">
  
    <!-- exceptions -->
            <div class="feature_section_title">Exceptions:</div>

            <table class="default">
                <tr class="header">
                    <td class="header">Type</td>
                    <td class="header">Description</td>
                </tr>

                <xsl:for-each select="$type">

                    <xsl:choose>
      
                        <xsl:when test="(number(position()-1) mod 2)=0">
                            <xsl:call-template name="exception_type">
                                <xsl:with-param name="type" select="." />
                                <xsl:with-param name="class">tablebg_even</xsl:with-param>                        
                            </xsl:call-template>
                        </xsl:when>
        
                        <xsl:otherwise>
                            <xsl:call-template name="exception_type">
                                <xsl:with-param name="type" select="." />
                                <xsl:with-param name="class">tablebg_odd</xsl:with-param>                        
                            </xsl:call-template>
                        </xsl:otherwise>
      
                    </xsl:choose>
      
                </xsl:for-each>

            </table>
            <br />

        </xsl:if>

    </xsl:template>

    <xsl:template name="exception_type">

        <xsl:param name="type" />
        <xsl:param name="class" />

        <tr valign="top" class="{ $class }">
            <td class="{ $class }">
                <xsl:value-of select="$type/@name"/>
            </td>


            <xsl:choose>



                <xsl:when test="string-length($type/description)=0">

                    <xsl:call-template name="col_warning" >
                        <xsl:with-param name="text">Exception description not defined</xsl:with-param>
                    </xsl:call-template>       

                </xsl:when>

                <xsl:otherwise>
                    <td class="{ $class }">
                        <xsl:for-each select="str:split($type/description,'\n')">
                            <xsl:value-of select="text()" />
                            <br />
                        </xsl:for-each>
                    </td>
                </xsl:otherwise>

            </xsl:choose>
<!--

    <td class="{ $class }"><xsl:for-each select="str:split($type/description,'\n')"><xsl:value-of select="text()" /><br /></xsl:for-each></td>
-->



        </tr>

    </xsl:template>

    <xsl:template name="argument_details">

        <xsl:param name="argument_name" />
        <xsl:param name="type" />
        <xsl:param name="default" />
        <xsl:param name="class" />

        <xsl:choose>

            <xsl:when test="count(type)>0">
    
                <xsl:variable name="argument_types" select="count(type)" />

                <xsl:for-each select="type">

                    <tr valign="top" class="{ $class }">
        
                        <xsl:if test="position()=1">

                            <xsl:choose>

                                <xsl:when test="string(../@type)='block_argument'">
                                    <td rowspan="{ $argument_types }" class="{ $class }">
                                        <span title="Code block argument, mandatory or optional" class="hover_text">
                                            <xsl:value-of select="str:split($argument_name,'#')[2]" />
                                        </span>
                                    </td>
                                </xsl:when>

                                <xsl:when test="string(../@type)='block'">
                                    <td rowspan="{ $argument_types }" class="{ $class }">
                                        <span title="Code block, mandatory or optional" class="hover_text">
                                            <xsl:value-of select="$argument_name" />
                                        </span>
                                    </td>
                                </xsl:when>

                                <xsl:when test="string(../@optional)='true'">            
                                    <td rowspan="{$argument_types}" class="{ $class }">
                                        <span class="optional_argument" title="Optional argument">
                                            <span class="hover_text">
                                                <xsl:value-of select="$argument_name" />
                                            </span>
                                        </span>
                                    </td>            
                                </xsl:when>


                                <xsl:otherwise>
                                    <td rowspan="{ $argument_types }" class="{ $class }">
                                        <span title="Mandatory argument" class="hover_text">
                                            <xsl:value-of select="$argument_name" />
                                        </span>
                                    </td>
                                </xsl:otherwise>

                            </xsl:choose>

                        </xsl:if>
          
          <!-- verify that argument variable type is defined -->
                        <xsl:choose>      
                            <xsl:when test="string-length(@name)>0">
                                <td class="{ $class }">
                                    <xsl:value-of select="@name"/>
                                </td>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="col_warning" >
                                    <xsl:with-param name="text">Not defined</xsl:with-param>
                                </xsl:call-template>       
                            </xsl:otherwise>
                        </xsl:choose>

          <!-- verify that argument description is defined -->
                        <xsl:choose>
                            <xsl:when test="string-length(description/text())>0">
                                <td class="{ $class }">
                                    <xsl:call-template name="formatted_content">
                                        <xsl:with-param name="text" select="description/text()"/>
                                    </xsl:call-template>
                                </td>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="col_warning" >
                                    <xsl:with-param name="text">Not defined</xsl:with-param>
                                </xsl:call-template>       
                            </xsl:otherwise>
                        </xsl:choose>

          <!-- verify that argument example is defined -->
                        <xsl:choose>

                            <xsl:when test="@type='block_argument'">
                                <td class="{ $class }">
                                    <xsl:value-of select="example/text()"/>
                                </td>
                            </xsl:when>

                            <xsl:when test="string(example/text())='-'">
              <!-- <td class="tablebg_disabled" rowspan="{ $argument_types }"><xsl:value-of select="$default"/></td> -->
                                <td class="tablebg_disabled">
                                    <xsl:value-of select="example/text()"/>
                                </td>
                            </xsl:when>

                            <xsl:when test="string-length(example/text())>0">
                                <td class="{ $class }">
                                    <xsl:value-of select="example/text()"/>
                                </td>
                            </xsl:when>

                            <xsl:otherwise>
                                <xsl:call-template name="col_warning" >
                                    <xsl:with-param name="text">Not defined</xsl:with-param>
                                </xsl:call-template>       
                            </xsl:otherwise>

                        </xsl:choose>
         
          <!-- default value -->
                        <xsl:if test="position()=1">

                            <xsl:choose>
            
                                <xsl:when test="string-length($default)=0">
                                    <td class="tablebg_disabled" rowspan="{ $argument_types }">
                                        <xsl:value-of select="$default"/>
                                    </td>
                                </xsl:when>
              
                                <xsl:otherwise>
                                    <td class="{ $class }" rowspan="{ $argument_types }">
                                        <xsl:value-of select="$default"/>
                                    </td>          
                                </xsl:otherwise>
            
                            </xsl:choose>
            
                        </xsl:if>

                    </tr>  

                </xsl:for-each>

            </xsl:when>

            <xsl:otherwise>

                <tr>
                    <td class="{ $class }">
                        <xsl:value-of select="$argument_name" />
                    </td>

                    <xsl:call-template name="col_warning">
                        <xsl:with-param name="colspan">3</xsl:with-param>
                        <xsl:with-param name="text">Not defined; description, example  cannot be shown due to variable type is not defined. Please verify also that argument name is defined properly</xsl:with-param>
                    </xsl:call-template>

                    <xsl:choose>
        
                        <xsl:when test="string-length($default)=0">
                            <td class="tablebg_disabled">
                                <xsl:value-of select="$default"/>
                            </td>
                        </xsl:when>
          
                        <xsl:otherwise>
                            <td class="{ $class }">
                                <xsl:value-of select="$default"/>
                            </td>          
                        </xsl:otherwise>
        
                    </xsl:choose>


                </tr>

            </xsl:otherwise>

        </xsl:choose>

    </xsl:template>

    <xsl:template name="arguments">

        <xsl:if test="@type='writer' or @type='accessor' or (@type='method' and number(arguments/@count)>0)">

            <div class="feature_section_title">Arguments:</div>

            <table class="default">
                <tr class="header">
                    <td class="header">Name</td>
                    <td class="header">Type</td>
                    <td class="header">Description</td>
                    <td class="header">Example</td>
                    <td class="header">Default</td>
                </tr>

                <xsl:for-each select="arguments/argument">

                    <xsl:choose>
      
        <!-- table stripes: position even -->
                        <xsl:when test="((number(position())-1) mod 2)=0">
                            <xsl:call-template name="argument_details">
                                <xsl:with-param name="argument_name" select="@name" />
                                <xsl:with-param name="type" select="type" />
                                <xsl:with-param name="class">tablebg_even</xsl:with-param>
                                <xsl:with-param name="default" select="@default" />
                            </xsl:call-template>
                        </xsl:when>
        
        <!-- table stripes: position odd -->
                        <xsl:otherwise>
                            <xsl:call-template name="argument_details">
                                <xsl:with-param name="argument_name" select="@name" />
                                <xsl:with-param name="type" select="type" />
                                <xsl:with-param name="class">tablebg_odd</xsl:with-param>
                                <xsl:with-param name="default" select="@default" />
                            </xsl:call-template>        
                        </xsl:otherwise>
      
                    </xsl:choose>
      
                </xsl:for-each>
    
    <!-- show error message if argument is not described -->
                <xsl:if test="@type='method' and (arguments/@described&lt;arguments/@count)">
                    <xsl:call-template name="row_warning" >
                        <xsl:with-param name="colspan">5</xsl:with-param>
                        <xsl:with-param name="text">Incomplete documentation: 
                            <xsl:value-of select="arguments/@described" /> of 
                            <xsl:value-of select="arguments/@count" /> arguments documented. Please note that block is also counted as one argument.
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:if>

    <!-- show error message if argument is not described -->
                <xsl:if test="(@type='accessor' or @type='writer') and arguments/@described=0">
                    <xsl:call-template name="row_warning" >
                        <xsl:with-param name="colspan">5</xsl:with-param>
                        <xsl:with-param name="text">Attribute writer or accessor input value needs to be documented.</xsl:with-param>
                    </xsl:call-template>
                </xsl:if>

            </table>
            <br />

        </xsl:if>

    </xsl:template>

    <xsl:template name="returns_type">

        <xsl:param name="type" />
        <xsl:param name="class" />

        <tr valign="top" class="{ $class }">

    <!-- verify that return value type is defined -->
            <xsl:choose>      

                <xsl:when test="string-length($type/@name)>0 and contains($type/@name,' ')">
                    <xsl:call-template name="col_warning" >
                        <xsl:with-param name="text">Return value variable type cannot be multiple words with whitespaces</xsl:with-param>
                    </xsl:call-template>       
                </xsl:when>

                <xsl:when test="string-length($type/@name)>0">
                    <td class="{ $class }">
                        <xsl:value-of select="$type/@name"/>
                    </td>
                </xsl:when>

                <xsl:otherwise>
                    <xsl:call-template name="col_warning" >
                        <xsl:with-param name="text">Return value variable type not defined</xsl:with-param>
                    </xsl:call-template>       
                </xsl:otherwise>
            </xsl:choose>

    <!-- verify that argument description is defined -->
            <xsl:choose>

                <xsl:when test="string($type/description/text())='-'">
                    <td class="tablebg_disabled" />
                </xsl:when>

                <xsl:when test="string-length($type/description/text())>0">
                    <td class="{ $class }">
                        <xsl:call-template name="formatted_content">
                            <xsl:with-param name="text" select="$type/description/text()"/>
                        </xsl:call-template>
                    </td>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="col_warning" >
                        <xsl:with-param name="text">Return value description not defined</xsl:with-param>
                    </xsl:call-template>       
                </xsl:otherwise>
            </xsl:choose>
            
    <!-- verify that return value example is defined -->
            <xsl:choose>      

                <xsl:when test="string($type/example/text())='-'">
                    <td class="tablebg_disabled" />
                </xsl:when>

                <xsl:when test="string-length($type/example/text())>0">
                    <td class="{ $class }">
                        <xsl:value-of select="$type/example/text()"/>
                    </td>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="col_warning" >
                        <xsl:with-param name="text">Return value example not defined</xsl:with-param>
                    </xsl:call-template>       
                </xsl:otherwise>
            </xsl:choose>
        </tr>

    </xsl:template>

    <xsl:template name="row_warning">
        <xsl:param name="text" />
        <xsl:param name="colspan" />
        <tr>
            <td colspan="{ $colspan }" class="warning">[!!] 
                <xsl:value-of select="$text" />
            </td>
        </tr>
    </xsl:template>

    <xsl:template name="col_warning">

        <xsl:param name="text" />
        <xsl:param name="colspan" />

        <xsl:choose>

            <xsl:when test="number($colspan)>0">
                <td class="warning" colspan="{ $colspan }">[!!] 
                    <xsl:value-of select="$text" />
                </td>
            </xsl:when>

            <xsl:otherwise>
                <td class="warning">[!!] 
                    <xsl:value-of select="$text" />
                </td>
            </xsl:otherwise>

        </xsl:choose>

    </xsl:template>

    <xsl:template name="div_warning">
        <xsl:param name="text" />
        <div class="warning">[!!] 
            <xsl:value-of select="$text" />
        </div>  
    </xsl:template>

    <xsl:template name="span_warning">
        <xsl:param name="text" />
        <span class="warning">[!!] 
            <xsl:value-of select="$text" />
        </span>  
    </xsl:template>

    <xsl:template name="returns">

        <xsl:param name="type" />
        <xsl:param name="feature_type" />

  <!-- show return value types table if feature type is method, reader or accessor -->
  <!--<xsl:if test="@type='reader' or @type='accessor' or @type='method'"> -->

        <xsl:if test="@type='reader' or @type='accessor' or @type='method'">

    <!-- return values -->
            <div class="feature_section_title">Returns:</div>
            <table class="default">
                <tr class="header">
                    <td class="header">Type</td>
                    <td class="header">Description</td>
                    <td class="header">Example</td>
                </tr>

    <!-- show error message if no return values defined -->
                <xsl:if test="(( count($type)=0 ) or ( count( arguments )=0 ) ) and ((@type='method') or (@type='accessor') or (@type='reader'))">
                    <xsl:call-template name="row_warning">
                        <xsl:with-param name="text">No return value type(s) defined for method, attribute reader or attribute accessor</xsl:with-param>
                        <xsl:with-param name="colspan">3</xsl:with-param>
                    </xsl:call-template>
                </xsl:if>
    
                <xsl:if test="count($type)>0">

                    <xsl:for-each select="$type">
        
                        <xsl:choose>
        
                            <xsl:when test="(number(position()-1) mod 2)=0">
                                <xsl:call-template name="returns_type" >
                                    <xsl:with-param name="type" select="." />
                                    <xsl:with-param name="class">tablebg_even</xsl:with-param>                        
                                </xsl:call-template>
                            </xsl:when>
          
                            <xsl:otherwise>
                                <xsl:call-template name="returns_type" >
                                    <xsl:with-param name="type" select="." />
                                    <xsl:with-param name="class">tablebg_odd</xsl:with-param>                        
                                </xsl:call-template>
                            </xsl:otherwise>
        
                        </xsl:choose>
        
                    </xsl:for-each>

                </xsl:if>

            </table>
            <br />

        </xsl:if>

    </xsl:template>

    <xsl:template name="tables">

        <xsl:for-each select="tables/table">
  
            <div class="feature_section_title">
                <a name="{ @name }">
                    <xsl:value-of select="title/text()" />:
                </a>
            </div>

            <xsl:if test="string-length(description/text())>0">
                <div class="feature_description">
                    <xsl:call-template name="formatted_content">
                        <xsl:with-param name="text" select="description/text()"/> 
                    </xsl:call-template>
                    <br />
                </div>
            </xsl:if>
    
            <table class="default">
      <!-- header -->
                <tr class="header_custom">
                    <xsl:for-each select="header/item">
                        <td class="header_custom">
                            <xsl:value-of select="."/>
                        </td>
                    </xsl:for-each>
                </tr>
          
      <!-- rows -->
                <xsl:for-each select="row">
                    <xsl:choose>
                        <xsl:when test="(number(position()-1) mod 2)=0">
                            <tr>
                                <xsl:for-each select="item">
                                    <td class="tablebg_even">
                                        <xsl:call-template name="formatted_content">
                                            <xsl:with-param name="text" select="."/> 
                                        </xsl:call-template>
                                        <br />

                                    </td>
                                </xsl:for-each>
                            </tr>
                        </xsl:when>
                        <xsl:otherwise>
                            <tr>
                                <xsl:for-each select="item">
                                    <td class="tablebg_odd">
                                        <xsl:call-template name="formatted_content">
                                            <xsl:with-param name="text" select="."/> 
                                        </xsl:call-template>
                                        <br />
                                    </td>
                                </xsl:for-each>
                            </tr>
                        </xsl:otherwise>        
                    </xsl:choose>
                </xsl:for-each>
            </table>    
            <br />
    
        </xsl:for-each>
  
    </xsl:template>

    <xsl:template name="description">

        <div class="feature_section_title">Description:</div>

        <xsl:if test="string-length(description/text())>0">
    <!-- display feature description (split lines with '\n') -->

            <div class="feature_description">
                <xsl:call-template name="formatted_content">
                    <xsl:with-param name="text" select="description/text()"/> 
                </xsl:call-template>
                <br />
            </div>
    
        </xsl:if>

        <xsl:if test="string-length(description/text())=0">
            <xsl:call-template name="div_warning">
                <xsl:with-param name="text">Description not defined</xsl:with-param>
            </xsl:call-template>
        </xsl:if>
        <br />

    </xsl:template>

    <xsl:template name="deprecated">

        <div class="feature_section_title">Deprecated in version:</div>

        <div class="feature_deprecated_version">
            <xsl:value-of select="deprecated/@version"/> 
        </div>
        <br />

    </xsl:template>

    <xsl:template name="tests">

        <xsl:param name="tests" />

  <!-- examples -->
        <div class="feature_section_title">Examples:</div>

        <xsl:for-each select="$tests/scenario">

    <!-- description (splitted with '\n') -->
            <div class="scenario_description">
                <xsl:for-each select="str:split(description,'\n')">
                    <xsl:value-of select="text()" />
                    <br />
                </xsl:for-each>
            </div>

            <xsl:value-of select="@name"/>

            <pre class="{@status}">
      <!-- show status only if other than 'passed' -->
                <xsl:if test="string(@status)!='passed'" >
                    <xsl:text># [!!] scenario </xsl:text>
                    <xsl:value-of select="@status" />
                    <br />
                </xsl:if>

                <xsl:for-each select="str:split(example,'\n')">
                    <xsl:value-of select="text()" />
                    <br />
                </xsl:for-each>
            </pre>

        </xsl:for-each>
  
        <xsl:if test="count($tests/scenario)=0">
            <xsl:call-template name="div_warning">
                <xsl:with-param name="text">No examples/test scenarios available</xsl:with-param>
            </xsl:call-template>
        </xsl:if>

        <hr />
        <br />
        <br />
        <br />
        <br />
        <br />
        <br />
        <hr />
    </xsl:template>

    <xsl:template name="info">

        <xsl:if test="string-length(info/text())>0">
     <!-- display feature description (split lines with '\n') -->
            <div class="feature_info">
                <xsl:call-template name="formatted_content">
                    <xsl:with-param name="text" select="info/text()"/>
                </xsl:call-template>
            </div>
            <br />
        </xsl:if>

    </xsl:template>

    <xsl:template name="formatted_content">

        <xsl:param name="text"/>

        <xsl:variable name="text_with_linefeeds">
            <xsl:call-template name="split_lines">
                <xsl:with-param name="text" select="$text" />
            </xsl:call-template>  
        </xsl:variable>

        <xsl:call-template name="process_tags">

            <xsl:with-param name="text" select="$text_with_linefeeds" />

        </xsl:call-template>
     
    </xsl:template>

    <xsl:template name="split_lines">

        <xsl:param name="text"/>

  <!-- content before \n -->
        <xsl:variable name="before_linefeed" select="substring-before($text, '\')"/>

  <!-- content after \n -->
        <xsl:variable name="after_linefeed" select="substring-after($text, '\')"/>

        <xsl:choose>
            <xsl:when test="substring(substring-after($text,'\'),1,1)='n'">
                <xsl:value-of select="$before_linefeed" />
                <xsl:text>[br]</xsl:text>
                <xsl:call-template name="split_lines">
                    <xsl:with-param name="text" select="substring($text,string-length($before_linefeed)+3,string-length($text))" />
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$text" />
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <xsl:template name="replace">

        <xsl:param name="text"/>

        <xsl:param name="string" />

        <xsl:param name="with" />

        <xsl:variable name="remaining_text" select="$text"/>

  <!-- content before $string -->
        <xsl:variable name="content_before_string" select="substring-before($text, $string)"/>

  <!-- content after $string -->
        <xsl:variable name="content_after_string" select="substring-after($text, $string)" />

        <xsl:choose>
  
            <xsl:when test="contains($text, $string)">
   
      <!-- $string found from $text, show leading content before $string -->
                <xsl:value-of disable-output-escaping="yes" select="$content_before_string" />
                <xsl:value-of disable-output-escaping="yes" select="$with" />

                <xsl:choose>
      
                    <xsl:when test="contains($content_after_string, $string)">

          <!-- $content_after_string contains $string, call replace template recursively -->        
                        <xsl:call-template name="replace">
          
                            <xsl:with-param name="text" select="$content_after_string" />
                            <xsl:with-param name="string" select="$string" />
                            <xsl:with-param name="with" select="$with" />
          
                        </xsl:call-template>
        
                    </xsl:when>
        
                    <xsl:otherwise>

          <!-- $content_after_string doesnt contain $string, return $content_after_string as is -->
                        <xsl:value-of disable-output-escaping="yes" select="$content_after_string" />

                    </xsl:otherwise>
              
                </xsl:choose>

            </xsl:when>

            <xsl:otherwise>

      <!-- $string not found from $text, return $text as is -->
                <xsl:value-of select="$text" />
    
            </xsl:otherwise>
  
        </xsl:choose>

    </xsl:template>

<!-- template#process_tags -->
    <xsl:template name="process_tags">

        <xsl:param name="text"/>

        <xsl:variable name="remainingContent" select="$text"/>

  <!-- content before tag start character -->
        <xsl:variable name="content_before_tag" select="substring-before($text, '[')"/>

  <!-- content after start tag -->
  <!-- content after start tag: content[/example_tag]continues-->
  <!--<xsl:variable name="content_after_tag" select="substring-after(substring-after($text, '['), ']')"/>
-->

  <!-- start tag: [example_tag="abcdef"] -->
        <xsl:variable name="content_after_tag">
            <xsl:variable name="tmp_content_after_tag" select="substring-after(substring-after($text, '['), '&quot;]')"/>
            <xsl:choose>
                <xsl:when test="string-length($tmp_content_after_tag)=0">
                    <xsl:value-of select="substring-after(substring-after($text, '['), ']')" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$tmp_content_after_tag" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>


  <!-- start tag: [example_tag="abcdef"] -->
<!--  <xsl:variable name="tmp_full_tag" select="substring-after(substring-before($text, '&quot;]'), '[')"/>
-->

  <!-- check if full tag contains string value -->

<!--

    
        <xsl:if test="string-length($tag_content)=0">

          <xsl:call-template name="process_tags">              
            <xsl:with-param name="text" select="$content_after_start_tag" />
          </xsl:call-template>
        
        </xsl:if>

-->

        <xsl:variable name="full_tag">
    <!-- start tag: [example_tag="abcdef"] -->
            <xsl:variable name="tmp_full_tag" select="substring-after(substring-before($text, '&quot;]'), '[')"/>
            <xsl:choose>
                <xsl:when test="string-length($tmp_full_tag)=0">
                    <xsl:value-of select="substring-after(substring-before($text, ']'), '[')" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$tmp_full_tag" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

  <!-- tag: example_tag -->
        <xsl:variable name="tag" select="str:split(substring-after(substring-before($text, ']'), '['), '=')[1]"/>

  <!-- content between tags: content-->
        <xsl:variable name="tag_content" select="substring-before($content_after_tag, concat('[/', $tag, ']'))"/>

  <!-- content after start tag: content[/example_tag]continues -->
        <xsl:variable name="content_after_start_tag" select="substring-after($text, concat('[',$tag,']'))"/>

  <!-- content after end tag: continues-->
        <xsl:variable name="content_after_end_tag" select="substring-after($content_after_tag, concat('[/', $tag, ']'))"/>

  <!-- show leading text before tag... -->
        <xsl:value-of select="$content_before_tag" />

        <xsl:choose>
  
            <xsl:when test="string-length($tag)>0">
 
                <xsl:call-template name="process_tag" >
                    <xsl:with-param name="tag" select="$tag" />
                    <xsl:with-param name="full_tag" select="$full_tag" />
                    <xsl:with-param name="content" select="$tag_content" />
                    <xsl:with-param name="content_after" select="$content_after_end_tag" />
                </xsl:call-template>
    
                <xsl:if test="string-length($tag_content)=0">

                    <xsl:call-template name="process_tags">              
                        <xsl:with-param name="text" select="$content_after_start_tag" />
                    </xsl:call-template>
        
                </xsl:if>
      
            </xsl:when>
  
            <xsl:otherwise>

                <xsl:value-of select="$text" />

            </xsl:otherwise>
  
        </xsl:choose>

    </xsl:template>

    <xsl:template name="process_tag" >

        <xsl:param name="tag" />
        <xsl:param name="full_tag" />
  
  
        <xsl:param name="content" />
        <xsl:param name="content_after" />

        <xsl:variable name="parameter">
    <!-- remove quotations from parameter value -->
            <xsl:call-template name="replace">
                <xsl:with-param name="text" select="str:split($full_tag,'=')[2]" />
                <xsl:with-param name="string">"</xsl:with-param>
                <xsl:with-param name="with" ></xsl:with-param>
            </xsl:call-template>
        </xsl:variable>

  <!--
  <br /><b>tag:</b> <xsl:value-of select="$tag" />
  <br /><b>content:</b> <xsl:value-of select="$content" />
  <br /><b>content_after:</b> <xsl:value-of select="$content_after" />
  -->

        <xsl:choose>
            <xsl:when test="$tag='b'">

                <b>
                    <xsl:call-template name="process_tags" >
                        <xsl:with-param name="text" select="$content" />
                    </xsl:call-template>
                </b>

                <xsl:call-template name="process_tags" >
                    <xsl:with-param name="text" select="$content_after" />
                </xsl:call-template>

            </xsl:when>

            <xsl:when test="$tag='u'">
                <u>
                    <xsl:call-template name="process_tags" >
                        <xsl:with-param name="text" select="$content" />
                    </xsl:call-template>
                </u>
                <xsl:call-template name="process_tags" >
                    <xsl:with-param name="text" select="$content_after" />
                </xsl:call-template>

            </xsl:when>

            <xsl:when test="$tag='i'">
                <i>
                    <xsl:call-template name="process_tags" >
                        <xsl:with-param name="text" select="$content" />
                    </xsl:call-template>
                </i>
                <xsl:call-template name="process_tags" >
                    <xsl:with-param name="text" select="$content_after" />
                </xsl:call-template>

            </xsl:when>

            <xsl:when test="$tag='code'">

                <pre class="block">
                    <xsl:value-of select="$content" />
                </pre>

                <xsl:call-template name="process_tags" >
                    <xsl:with-param name="text" select="$content_after" />
                </xsl:call-template>

            </xsl:when>

            <xsl:when test="$tag='img'">

                <xsl:choose>
      
                    <xsl:when test="string-length($parameter)>0">
          <!-- found title text for image -->
                        <img src="{ $parameter }" title="{ $content }" />
                    </xsl:when>
        
                    <xsl:otherwise>
          <!-- no title text for image -->
                        <img src="{ $content }" title="" />
                    </xsl:otherwise>
      
                </xsl:choose>

                <xsl:call-template name="process_tags" >
                    <xsl:with-param name="text" select="$content_after" />
                </xsl:call-template>

            </xsl:when>

            <xsl:when test="$tag='link'">
      
                <xsl:choose>
      
                    <xsl:when test="string-length($parameter)>0">
                        <a href="{ $parameter }" class="link" title="{ $content }">          
                            <xsl:call-template name="process_tags" >
                                <xsl:with-param name="text" select="$content" />
                            </xsl:call-template>          
                        </a>
                    </xsl:when>
        
                    <xsl:otherwise>
                        <a href="{ $content }" class="link" title="">
                            <xsl:call-template name="process_tags" >
                                <xsl:with-param name="text" select="$content" />
                            </xsl:call-template>          
                        </a>
                    </xsl:otherwise>
      
                </xsl:choose>
            
                <xsl:call-template name="process_tags" >
                    <xsl:with-param name="text" select="$content_after" />
                </xsl:call-template>

            </xsl:when>


            <xsl:when test="$tag='name'">
      
                <xsl:choose>
      
                    <xsl:when test="string-length($parameter)>0">
                        <a name="{ $parameter }" title="">          
                            <xsl:call-template name="process_tags" >
                                <xsl:with-param name="text" select="$content" />
                            </xsl:call-template>          
                        </a>
                    </xsl:when>
        
                    <xsl:otherwise>
                        <a name="{ $content }" title="">
                            <xsl:call-template name="process_tags" >
                                <xsl:with-param name="text" select="$content" />
                            </xsl:call-template>          
                        </a>
                    </xsl:otherwise>
      
                </xsl:choose>
            
                <xsl:call-template name="process_tags" >
                    <xsl:with-param name="text" select="$content_after" />
                </xsl:call-template>

            </xsl:when>



            <xsl:when test="$tag='br'">
                <br />
            </xsl:when>

            <xsl:otherwise>

                <xsl:choose>

                    <xsl:when test="string-length($content)>0">
                        <xsl:text>[</xsl:text>
                        <xsl:value-of select="$full_tag" />
                        <xsl:text>]</xsl:text>

                        <xsl:call-template name="process_tags" >
                            <xsl:with-param name="text" select="$content" />
                        </xsl:call-template>

                        <xsl:text>[/</xsl:text>
                        <xsl:value-of select="$tag" />
                        <xsl:text>]</xsl:text>
                    </xsl:when>

                    <xsl:otherwise>
                        <xsl:text>[</xsl:text>
                        <xsl:value-of select="$full_tag" />
                        <xsl:text>]</xsl:text>
                    </xsl:otherwise>
      
                </xsl:choose>

                <xsl:call-template name="process_tags" >
                    <xsl:with-param name="text" select="$content_after" />
                </xsl:call-template>
    
            </xsl:otherwise>

        </xsl:choose>

    </xsl:template>

</xsl:stylesheet>
