$tag = git describe --tags --abbrev=0
echo "tag is $tag again"

$v4d = "$($tag.TrimStart("v")).0"
echo "v4d is $v4d"