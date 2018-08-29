docker:
	@docker build --no-cache -t alextanhongpin/go-modules .

start:
	@docker run -d -p 8080:8080 alextanhongpin/go-modules