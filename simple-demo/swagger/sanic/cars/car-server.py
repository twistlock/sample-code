from sanic import Sanic
from sanic.response import json
from sanic_openapi import swagger_blueprint
from sanic import response

app = Sanic(name='car app')
app.blueprint(swagger_blueprint)

@app.get("/car")
async def get_car(request):
	return json({
		"make": {"name": "Mazda"},
		"model": "Miata MX-5",
		"year": 2019
	})

@app.get("/garage")
async def get_garage(request):
	return json({
		"spaces": 2,
		"available": 1,
		"cars": [{
			"make": {"name": "Mazda"},
			"model": "Miata MX-5",
			"year": 2019,
		}]
	})


@app.post("/car")
async def add_new_car(request):
	req_data = request.json
	return response.json(req_data)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8888)


