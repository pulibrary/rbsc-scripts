for file in `find workspace/eads -type f -name *.EAD.xml`
do
 path=`xpath -q -e '//eadid/@url' $file | grep -Po '(?<=url=")[^"]*'`
 echo $path
 curl -sLS -w "%{response_code} %{num_redirects} %{url_effective}\\n" $path -o $
done

