#!/usr/bin/env bash

# Download release zip file from https://github.com/keycloak/keycloak/tags
# copy this file to the root

set -x

cwd=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
version=11.0.3

mvnbuild(){
  cd $cwd/federation/ldap
  # mvn clean install
  mvn install
}

copy(){
  cp $cwd/federation/ldap/target/keycloak-ldap-federation-${version}.jar \
    $cwd/../keycloak-ldap/scripts/assets
}

dockerbuild(){
  cd $cwd
  (cat << EOS
FROM jboss/keycloak:$version

COPY ./federation/ldap/target/keycloak-ldap-federation-${version}.jar /opt/jboss/keycloak/modules/system/layers/keycloak/org/keycloak/keycloak-ldap-federation/main/keycloak-ldap-federation-11.0.3.jar

ENTRYPOINT []

CMD ["/opt/jboss/tools/docker-entrypoint.sh", "-b", "0.0.0.0"]
EOS
  ) > Dockerfile

  docker build \
    -f Dockerfile \
    -t my/keycloak:${version} \
    .
}

mvnbuild
# copy
dockerbuild
