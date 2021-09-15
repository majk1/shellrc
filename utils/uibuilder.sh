#!/usr/bin/env bash

function uibuilder() {
	UIBVER="$1"
	shift
	VER="1.0.0-SNAPSHOT"

	GROUPID="org.example"
	ARTIFACTID="example-app"
	if [[ $1 =~ ":" ]]; then
		GROUPID="${1%%:*}"
		ARTIFACTID="${1#*:}"
	else
		GROUPID="$1"
		ARTIFACTID="$2"
		shift
	fi
	shift

	if [[ $ARTIFACTID =~ ":" ]]; then
		ARTIFACTWITHVERSION="${ARTIFACTID}"
		ARTIFACTID="${ARTIFACTWITHVERSION%:*}"
		VER="${ARTIFACTWITHVERSION#*:}"
	fi

	if [ ! -z "$1" ]; then
		VER="$1"
	fi

	mvn -q -B archetype:generate \
		-DarchetypeGroupId=io.devbench.uibuilder.archetypes \
		-DarchetypeArtifactId=uibuilder-quickstart-archetype \
		-DarchetypeVersion=$UIBVER \
		-DgroupId=$GROUPID \
		-DartifactId=$ARTIFACTID \
		-Dversion=$VER

	if [ $? -eq 0 ]; then
		echo ""
		echo "● UIBuilder project has been initialized ($GROUPID:$ARTIFACTID:$VER)"
		echo ""
	fi
}
