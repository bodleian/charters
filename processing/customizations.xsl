<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:bod="http://www.bodleian.ox.ac.uk/bdlss"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="tei html xs bod"
    version="2.0">
    
    

    <!-- The stylesheet is a library. It doesn't validate and won't produce HTML on its own. It is called by 
         convert2HTML.xsl and previewManuscript.xsl. Any templates added below will override the templates 
         in msdesc2html.xsl in the consolidated-tei-schema repository, allowing customization of manuscript 
         display for each catalogue. -->



    <!-- For Medieval, notes are sometimes used between items to give context, so this overrides the 
         default in msdesc2html.xsl, which re-orders child elements of msItem for the sake of neatness. -->
    
    <xsl:template name="SubItems">        
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="listBibl/bibl[@facs]">
        <div class="{name()}">
            <xsl:variable name="facs-url">
                <xsl:choose>
                    <xsl:when test="starts-with(@facs, 'http')">
                        <xsl:value-of select="@facs" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat($website-url, '/images/ms/', substring(@facs, 1, 3), '/', @facs)" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <a href="{$facs-url}">
                <xsl:apply-templates/>
            </a>
        </div>
    </xsl:template>
    
    
    <!-- TODO: Move these templates to msdesc2html.xsl if applicable to all catalogues? -->
    
    <xsl:template match="msDesc/msIdentifier/altIdentifier[@type='former' and child::idno[not(@subtype)]]">
        <p>
            <xsl:text>Former shelfmark: </xsl:text>
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    
    <xsl:template match="title[@key]">
        <span>
            <xsl:attribute name="class">
                <xsl:if test="not(parent::msItem)">
                    <xsl:text>title </xsl:text>
                </xsl:if>
                <xsl:text>tei-title</xsl:text>
                <xsl:if test="not(@rend) and not(@type)">
                    <xsl:text> italic</xsl:text>
                </xsl:if>
            </xsl:attribute>
            <xsl:choose>
                <xsl:when test="not(@key='')">
                    <a>
                        <xsl:attribute name="href">
                            <xsl:value-of select="$website-url"/>
                            <xsl:text>/catalog/</xsl:text>
                            <xsl:value-of select="tokenize(@key, ' ')[1]"/>
                        </xsl:attribute>
                        <xsl:apply-templates/>
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </span>
        <xsl:if test="following-sibling::*[1][self::note and not(matches(., '^\s*[A-Z(,]')) and not(child::*[1][self::lb and string-length(normalize-space(preceding-sibling::text())) = 0])]">
            <xsl:text>, </xsl:text>
        </xsl:if>
    </xsl:template>
    
    
    
    <!-- This is Medieval notation, do not move this to msdesc2html.xsl -->
    
    <xsl:template match="lb">
        <xsl:text>|</xsl:text>
    </xsl:template>
    
    <!-- added for charters -->
    <xsl:template match="msItem/p/origDate">
        <xsl:apply-templates/>
    </xsl:template>
    
    <!-- seals -->
    <!-- may need refinement  -->
    <xsl:template match="authDesc">
            <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="seal">
        <div class="seal"><span class="seal">
            <b>
                <xsl:text>Seal:</xsl:text>
             </b>   
            <xsl:apply-templates/>
        </span></div>
    </xsl:template>
    
    <xsl:template match="seal/decoNote">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="seal/p">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="seal/legend">
        <xsl:text>Legend: ‘</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>’</xsl:text>
    </xsl:template>
    
    <xsl:template match="seal/idno">
        <xsl:text>(</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>)</xsl:text>
    </xsl:template>
    
    
    <xsl:template match="pb">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="surname">
        <xsl:apply-templates/>
    </xsl:template>
    
    <!-- This is an override of the template in msdesc2html.xsl, which outputs a div. Maybe the choice should be based on context? -->
    
    <xsl:template match="formula">
        <span class="formula">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    
    
    <!-- Display lemmata in italic -->
    
    <xsl:template match="incipit/quote | incipit/cit/quote | explicit/quote | explicit/cit/quote">
        <i>
            <xsl:apply-templates/>
        </i>
    </xsl:template>
    <xsl:template match="text()[ancestor::incipit/@type='lemma' or ancestor::explicit/@type='lemma']">
        <i>
            <xsl:copy/>
        </i>
    </xsl:template>
    
    
    
    <!-- Display links to abbreviations and conventions pages, and the most recent change 
         at the bottom of manuscript pages (just before Zotero links, if any) -->
    
    <xsl:template name="Footer">
        <div class="abbreviations">
            <xsl:processing-instruction name="ni"/>
            <h3>Abbreviations</h3>
            <p>View <a href="https://github.com/bodleian/charters/wiki/Abbreviations" target="_blank">list of abbreviations</a> and <a href="https://github.com/bodleian/charters/wiki/Conventions" target="_blank">editorial conventions</a>.</p>
            <xsl:processing-instruction name="ni"/>
        </div>
        <xsl:apply-templates select="/TEI/teiHeader/revisionDesc[change][1]"/>
    </xsl:template>
    
    <xsl:template match="revisionDesc[.//change]">
        <div class="revisionDesc">
            <xsl:processing-instruction name="ni"/>
            <h3>Last Substantive Revision</h3>
            <xsl:choose>
                <xsl:when test="some $change in .//change satisfies exists($change/@when)">
                    <xsl:for-each select=".//change[@when]">
                        <xsl:sort select="@when" order="descending"/>
                        <xsl:if test="position() eq 1">
                            <xsl:apply-templates select="."/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="(.//change)[1]"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:processing-instruction name="ni"/>
        </div>
    </xsl:template>
    
    <xsl:template match="change">
        <p class="change">
            <xsl:if test="@when">
                <xsl:value-of select="@when"/>
                <xsl:text>: </xsl:text>
            </xsl:if>
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    
    
    <xsl:template name="batch">
    <!-- Set up the collection of files to be converted. The path must be supplied in batch mode, and must be a full
             path because this stylesheet is normally imported by convert2HTML.xsl via a URL. -->
    <xsl:variable name="path">
        <xsl:choose>
            <xsl:when test="starts-with($collections-path, '/')">
                <!-- UNIX-like systems -->
                <xsl:value-of select="concat('file://', $collections-path, '/?select=', $files, ';on-error=warning;recurse=', $recurse)"/>
            </xsl:when>
            <xsl:when test="matches($collections-path, '[A-Z]:/')">
                <!-- Git Bash on Windows -->
                <xsl:value-of select="concat('file:///', $collections-path, '/?select=', $files, ';on-error=warning;recurse=', $recurse)"/>
            </xsl:when>
            <xsl:when test="matches($collections-path, '[A-Z]:\\')">
                <!-- Windows -->
                <xsl:value-of select="concat('file:///', replace($collections-path, '\\', '/'), '/?select=', $files, ';on-error=warning;recurse=', $recurse)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="bod:logging('error', 'A full path to the collections folder containing source TEI must be specified', .)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <!-- For each item in the collection -->
    <xsl:for-each select="collection($path)">
        
        <xsl:choose>
            <xsl:when test="string-length(/TEI/@xml:id/string()) eq 0">
                
                <!-- Cannot do anything if there is no @xml:id on the root TEI element -->
                <xsl:copy-of select="bod:logging('warn', 'Cannot process manuscript without @xml:id for root TEI element', /TEI, base-uri())"/>
                
            </xsl:when>
            <xsl:otherwise>
                
                <!-- Build HTML in a variable so it can be post-processed to strip out undesirable HTML code -->
                <xsl:variable name="outputdoc" as="element()">
                    <xsl:choose>
                        <xsl:when test="$output-full-html">
                            <html xmlns="http://www.w3.org/1999/xhtml">
                                <head>
                                    <title></title>
                                </head>
                                <body>
                                    <div class="content tei-body" id="{/TEI/@xml:id}">
                                        <xsl:call-template name="Header"/>
                                        <xsl:choose>
                                            <xsl:when test="/TEI/teiHeader/fileDesc/sourceDesc/msDesc">
                                                <xsl:apply-templates select="/TEI/teiHeader/fileDesc/sourceDesc/msDesc"/>
                                                <xsl:call-template name="Funding"/>
                                                <xsl:call-template name="AbbreviationsKey"/>
                                                <xsl:call-template name="Footer"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:apply-templates select="/TEI/text/body"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                     
                                        
                                    </div>
                                </body>
                            </html>
                        </xsl:when>
                        <xsl:otherwise>
                            <div>
                                <div class="content tei-body" id="{/TEI/@xml:id}">
                                    <xsl:call-template name="Header"/>
                                    <xsl:apply-templates select="/TEI/teiHeader/fileDesc/sourceDesc/msDesc"/>
                                    <xsl:call-template name="Funding"/>
                                    <xsl:call-template name="AbbreviationsKey"/>
                                    <xsl:call-template name="Footer"/>
                                </div>
                            </div>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                
                <!-- Create output HTML files -->
                <xsl:variable name="subfolders" select="tokenize(substring-after(base-uri(.), $collections-path), '/')[position() ne last()]"/>
                <xsl:variable name="outputpath" select="concat('./html/', string-join($subfolders, '/'), '/', /TEI/@xml:id/string(), '.html')"/>
                <xsl:result-document href="{$outputpath}" method="xhtml" encoding="UTF-8" indent="yes">
                    
                    <!-- Applying templates on the HTML already built, with a mode, to strip out undesirable HTML code -->
                    <xsl:apply-templates select="$outputdoc" mode="stripoutempty"/>
                    
                </xsl:result-document>
                
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:for-each>
    </xsl:template>
    
    
</xsl:stylesheet>

