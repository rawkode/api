AWS_REGION="us-east-1"
AWS_PROFILE="default"
DOCKER_LOGIN=$(shell aws ecr get-login --region=$(AWS_REGION) --profile=$(AWS_PROFILE))
ecr-login:
	@echo Getting an ECR Login Token
	$(DOCKER_LOGIN)

build-container:
	docker build -t helpmeabstract/api .

tag-container: ecr-login build-container
	@echo Tagging current container state in ECR
	docker tag helpmeabstract/api:latest 976623053519.dkr.ecr.us-east-1.amazonaws.com/helpmeabstract/api:latest

deploy-container: ecr-login tag-container
	@echo Pushing container to ECR
	docker push 976623053519.dkr.ecr.us-east-1.amazonaws.com/helpmeabstract/api:latest

deploy-staging: deploy-container
	@echo Deploying to staging
	php scripts/ecs_deploy.php $(AWS_PROFILE) $(AWS_REGION) helpmeabstract-staging helpmeabstract-api
