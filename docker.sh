
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
