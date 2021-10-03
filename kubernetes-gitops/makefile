username=chudinanton
tag=v0.0.1

build: build_adservice build_cartservice build_checkoutservice build_currencyservice build_emailservice build_frontend build_loadgenerator build_paymentservice build_productcatalogservice build_recommendationservice build_shippingservice 

build_adservice:
	export USER_NAME=$(username) && cd microservices-demo/src/adservice && docker build -t $(username)/adservice:$(tag) .

build_cartservice:
	export USER_NAME=$(username) && cd microservices-demo/src/cartservice/src && docker build -t $(username)/cartservice:$(tag) .

build_checkoutservice:
	export USER_NAME=$(username) && cd microservices-demo/src/checkoutservice && docker build -t $(username)/checkoutservice:$(tag) .

build_currencyservice:
	export USER_NAME=$(username) && cd microservices-demo/src/currencyservice && docker build -t $(username)/currencyservice:$(tag) .

build_emailservice:
	export USER_NAME=$(username) && cd microservices-demo/src/emailservice && docker build -t $(username)/emailservice:$(tag) .

build_frontend:
	export USER_NAME=$(username) && cd microservices-demo/src/frontend && docker build -t $(username)/frontend:$(tag) .

build_loadgenerator:
	export USER_NAME=$(username) && cd microservices-demo/src/loadgenerator && docker build -t $(username)/loadgenerator:$(tag) .

build_paymentservice:
	export USER_NAME=$(username) && cd microservices-demo/src/paymentservice && docker build -t $(username)/paymentservice:$(tag) .

build_productcatalogservice:
	export USER_NAME=$(username) && cd microservices-demo/src/productcatalogservice && docker build -t $(username)/productcatalogservice:$(tag) .

build_recommendationservice:
	export USER_NAME=$(username) && cd microservices-demo/src/recommendationservice && docker build -t $(username)/recommendationservice:$(tag) .

build_shippingservice:
	export USER_NAME=$(username) && cd microservices-demo/src/shippingservice && docker build -t $(username)/shippingservice:$(tag) .

release: release_adservice release_cartservice release_checkoutservice release_currencyservice release_emailservice release_frontend release_loadgenerator release_paymentservice release_productcatalogservice release_recommendationservice release_shippingservice

release_adservice:
	docker push $(username)/adservice:$(tag)

release_cartservice:
	docker push $(username)/cartservice:$(tag)

release_checkoutservice:
	docker push $(username)/checkoutservice:$(tag)

release_currencyservice:
	docker push $(username)/currencyservice:$(tag)

release_emailservice:
	docker push $(username)/emailservice:$(tag)

release_frontend:
	docker push $(username)/frontend:$(tag)

release_loadgenerator:
	docker push $(username)/loadgenerator:$(tag)

release_paymentservice:
	docker push $(username)/paymentservice:$(tag)

release_productcatalogservice:
	docker push $(username)/productcatalogservice:$(tag)

release_recommendationservice:
	docker push $(username)/recommendationservice:$(tag)

release_shippingservice:
	docker push $(username)/shippingservice:$(tag)

.PHONY: build release