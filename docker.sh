
# docker

docker-env() {
    target_docker_env="$1"
    if [ -z "$target_docker_env" ]; then
        target_docker_env=default
    fi
    
    if [ "$target_docker_env" == "--clear" -o "$target_docker_env" == "-c" ]; then
        echo "Clearing docker environment"
        unset DOCKER_MACHINE_NAME
        unset DOCKER_CERT_PATH
        unset DOCKER_TLS_VERIFY
        unset DOCKER_HOST
    else
	    eval $(docker-machine env ${target_docker_env})
	    echo "Docker environment: $DOCKER_MACHINE_NAME, host: $DOCKER_HOST"
	fi
}

docker-remove-abandoned-images() {
	docker rmi $(docker images | grep '^<none>' | awk '{print $3}')
}

if [ "$(uname)" = "Darwin" ]; then
	docker-storage-usage() {
		find ~/Library/Containers/com.docker.docker/Data -type f -iname '*.qcow2' -exec du -sh {} \;
		find ~/Library/Containers/com.docker.docker/Data -type f -iname 'Docker.raw' -exec du -sh {} \;
	}
fi

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

docker-stats() {
    docker stats --format="table {{.Name}}\t{{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}\t{{.NetIO}}\t{{.BlockIO}}\t{{.PIDs}}" "$@"
}
