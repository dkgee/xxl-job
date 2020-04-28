#!/bin/bash

VERSION=2.2.1

docker tag xxl-job-admin:${VERSION} registry.cn-beijing.aliyuncs.com/dkgee/cms-job:${VERSION}
docker push registry.cn-beijing.aliyuncs.com/dkgee/cms-job:${VERSION}

