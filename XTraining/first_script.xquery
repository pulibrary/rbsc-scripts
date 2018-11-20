xquery version "1.0";
declare namespace ead = "urn:isbn:1-931666-22-9";
declare default element namespace "urn:isbn:1-931666-22-9";
declare copy-namespaces no-preserve, inherit;


declare variable $COLL as document-node()+ := collection("file:///C:/Users/heberlei/Documents/SVN%20Working%20Copies/trunk/eads?recurse=yes;select=*.xml");

distinct-values($COLL//@unit)

