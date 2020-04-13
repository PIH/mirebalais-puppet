#!/bin/bash

set -o xtrace

# Get package version number
app_version="$(node -e 'console.log(require("./package.json").version);')"
version="${app_version}.${bamboo_buildNumber}"

# Copy to build dir
parent_dir=/var/www/html/spa-repo/${bamboo.planRepository.name}/unstable/
ls "${parent_dir}"
target_dir="${parent_dir}/${version}/"
mkdir -p "${target_dir}"
cp -r dist/* "${target_dir}"

# Update latest/ symlink
rm -rf "${parent_dir}/latest/"
ln -s ${target_dir} ${parent_dir}/latest

# Update import maps
package_name="$(node -e 'console.log(require("./package.json").name);')"
new_url="https://bamboo.pih-emr.org:81/spa-repo/${bamboo.planRepository.name}/unstable/${version}/${bamboo.planRepository.name}.js"
for suffix in "ces" "zl"; do
    sed -i "s/\"${package_name}\": \".*\"/\"${package_name}\": \"${new_url}\"/" "/var/www/html/spa-repo/import-map/import-map-ci-${suffix}.json"
done
