for file in `find workspace/eads -type f -name *.EAD.xml`
do
 myark=`xpath -q -e '//eadid/@url' $file | grep -Po '(?<=url="http://arks.princ$
 eadid=`xpath -q -e '//eadid/text()' $file`
 string1="http://arks.princeton.edu/nd/noidu_001?bind+set+"
 string2="+location+http://findingaids.princeton.edu/collections/"
 url="$string1$myark$string2$eadid"
 curl -sLS -w "%{response_code} %{num_redirects} %{url_effective}\\n" $url -o /$
done
