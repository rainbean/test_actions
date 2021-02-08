$tag = git describe --tags --abbrev=0
$v4d = "$($tag.TrimStart("v")).0"


echo $v4d