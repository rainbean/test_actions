### download pre-built openslide
echo "Download openslide ..."
mkdir -p convert
curl -L -s https://storage.googleapis.com/build.aixmed.com/convert/openslide-0.4.1.tar.xz | tar Jxf - -C convert/

### Build project
echo "Build decart ..."
tag=`git describe --tags --abbrev=0`

go build -tags cli -o decart \
         -ldflags "-X 'decart/internal/cloud.credentials=$DECART_SERVICE_ACCOUNT' \
                   -X 'decart/internal/config.Version=$tag'"

go build -tags gui -o decartw \
         -ldflags "-X 'decart/internal/cloud.credentials=$DECART_SERVICE_ACCOUNT' \
                   -X 'decart/internal/config.Version=$tag'"

### pack
echo "Pack decart ..."
target="decart-linux-$tag.tar.xz"
export XZ_DEFAULTS="-T 0"
tar Jcf $target decart decartw convert assets

### Let Github Action know artifact path 
echo "::set-output name=artifact::$target"

### upload to artifacts repository
# if command -v gsutil &> /dev/null
# then
#     gsutil cp $target gs://build.aixmed.com/decart/
# fi
