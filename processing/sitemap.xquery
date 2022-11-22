declare namespace tei="http://www.tei-c.org/ns/1.0";

<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
    {
        for $ms in collection('../tei-qa/?select=*.xml;recurse=yes')
            let $msid := $ms//tei:TEI/@xml:id/data()
            return <url>
                <loc>{ concat("https://charters.bodleian.ox.ac.uk/catalog/", $msid) }</loc>
            </url>
    }
</urlset>
