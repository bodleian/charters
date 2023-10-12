import module namespace bod = "http://www.bodleian.ox.ac.uk/bdlss" at "lib/msdesc2solr.xquery";
declare namespace map="http://www.w3.org/2005/xpath-functions/map";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare option saxon:output "indent=yes";

declare variable $collections := collection('../tei-qa/?select=*.xml;recurse=no');
declare variable $allinstances :=
for $instance in collection('../tei-qa?select=*.xml;recurse=yes')//tei:msDesc//tei:collection
let $roottei := $instance/ancestor::tei:TEI
let $shelfmark := ($roottei/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:idno[@type = "shelfmark"])[1]/text()
let $datesoforigin := distinct-values($roottei//tei:origDate/normalize-space())
let $placesoforigin := distinct-values($roottei//tei:origPlace/normalize-space())
return
    <instance>
        {
            for $key in tokenize(normalize-space($instance/@key), ' ')
            return
                <key>{$key}</key>
        }
        <name>{normalize-space($instance/string())}</name>
        <link>{
                concat(
                '/catalog/',
                $roottei/@xml:id/data(),
                '|',
                normalize-space($shelfmark),
                if ($roottei//tei:sourceDesc//tei:surrogates/tei:bibl[@type = ('digital-fascimile', 'digital-facsimile') and @subtype = 'full']) then
                    ' (Digital facsimile online)'
                else
                    if ($roottei//tei:sourceDesc//tei:surrogates/tei:bibl[@type = ('digital-fascimile', 'digital-facsimile') and @subtype = 'partial']) then
                        ' (Selected pages online)'
                    else
                        ''
                , '|',
                if ($roottei//tei:msPart) then
                    'Composite manuscript'
                else
                    string-join(($datesoforigin, $placesoforigin), '; ')
                )
            }</link>
        
        {
            if (not($instance/self::tei:placeName or $instance/self::tei:orgName)) then
                <type>{local-name($instance)}</type>
            else
                ()
        }
        <shelfmark>{$shelfmark}</shelfmark>
    </instance>;

<add>
    {
        comment {concat(' Indexing started at ', current-dateTime(), ' using files in ', substring-before(substring-after(base-uri($collections[1]), 'file:'), 'collections/'), ' ')}
    }
    {
        let $colids := $collections/tei:TEI/@xml:id/data()
        return
            if (count($colids) ne count(distinct-values($colids))) then
                let $duplicateids := distinct-values(for $colid in $colids
                return
                    if (count($colids[. eq $colid]) gt 1) then
                        $colid
                    else
                        '')
                return
                    bod:logging('error', 'There are multiple collections with the same xml:id in their root TEI elements', $duplicateids)
            
            else
                for $collection in $collections
   
                let $colid := $collection/tei:TEI/@xml:id/string()
                    order by $colid
                return
                    if (string-length($colid) ne 0) then
                        let $mainshelfmark := ($collection/tei:TEI/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@type = 'msID'])[1]
                        let $subfolders := string-join(tokenize(substring-after(base-uri($collection), 'tei-qa/'), '/')[position() lt last()], '/')
                        let $htmlfilename := concat($colid, '.html')
                        let $htmldoc := doc(concat('html/', $subfolders, '/', $htmlfilename))
                        let $instances := $allinstances[key = $colid]

                        (:
                    Guide to Solr field naming conventions:
                        ch_ = charter index field
                        sl = seal index field
                        _i = integer field
                        _b = boolean field
                        _s = string field (tokenized)
                        _t = text field (not tokenized)
                        _?m = multiple field (typically facets)
                        *ni = not indexed (except _tni fields which are copied to the fulltext index)
                :)
                        return
                            <doc>
                                <field
                                    name="type">collection</field>
                                <field
                                    name="pk">{$colid}</field>
                                <field
                                    name="id">{$colid}</field>
                                {bod:one2one($mainshelfmark, 'title', 'error')}
                                {bod:one2one($collection//tei:publicationStmt/tei:idno[@type = 'collection'], 'ms_collection_s')}
                                <field
                                    name="filename_s">{substring-after(base-uri($collection), 'tei-qa/')}</field>
                                


                                {bod:indexHTML($htmldoc, 'ms_textcontent_tni')}
                                {bod:displayHTML($htmldoc, 'display')}
                               {
                                    (: Links to manuscripts  :)
                                    for $link in distinct-values($instances/link/text())
                                        order by normalize-space(translate(tokenize($link, '\|')[2], ".","")) collation "http://www.w3.org/2013/collation/UCA?numeric=yes;fallback=yes"
                                    return
                                        <field
                                            name="link_manuscripts_smni">{$link}</field>
                                        
                                }
                            
                            </doc>
                    
                    else
                        bod:logging('warn', 'Cannot process manuscript without @xml:id for root TEI element', base-uri($collection))
    }
</add>
