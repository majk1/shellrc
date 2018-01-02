
# docker

docker-env() {
	eval $(docker-machine env $1)
	echo "Docker environment: $DOCKER_MACHINE_NAME, host: $DOCKER_HOST"
}

docker-remove-abandoned-images() {
	docker rmi $(docker images | grep '^<none>' | awk '{print $3}')
}

docker-qcow2-usage() {
	find ~/Library/Containers/com.docker.docker/Data -type f -iname '*.qcow2' -exec du -sh {} \;
}

# $1 - registry url
# $2 - iamge name
# $3 - image digest
# $4 - username
docker-registry-mark-for-delete() {
	if [ $# -ne 4 ]; then
		echo "Usage: docker-registry-mark-for-delete <registry url> <image name> <image digest>"
		echo ""
		echo "       example:"
		echo "       docker-registry-mark-for-delete https://my-docker-reg.domain.tld my-docker-image-without-the-tag sha256:6de813fb93debd5..."
		echo ""
	else
		curl -v -k -u "$4" --silent -H "Accept: application/vnd.docker.distribution.manifest.v2+json" \
			-X DELETE $1/v2/$2/manifests/$3
		echo "Run in docker: bin/registry garbage-collect /etc/docker/registry/config.yml"
	fi
}
