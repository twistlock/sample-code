import os
import json
from sanic import Sanic
from bson.json_util import dumps
# from sanic.response import json
from sanic_openapi import swagger_blueprint
from sanic import response
from pymongo import MongoClient
from datetime import datetime

mongo_host=os.environ.get('MONGO_HOST')
print("Connecting to mongo db on " + mongo_host)
client = MongoClient(mongo_host)
demodb = client["api-demo"]
dealers = demodb["dealers"]
cars = demodb["cars"]

app = Sanic(name='cardealer')
app.blueprint(swagger_blueprint)

def toDictionary(args):
    car_dict = {}
    for i in args:
        car_dict[i[0]]=i[1]
    return car_dict

def logEvent(eventType, messages):
    d = datetime.now().strftime("[%Y-%m-%d %H:%M:%S +0000] ")
    for message in messages:
        print( d + " " + eventType + " " + message )

@app.get("/car")
async def get_car(request):
    listOfCars = []
    oneFound=True

    args = request.query_args
    if len(args) > 0:
        car_dict = toDictionary(args)
        foundcars = cars.find(car_dict)
        if foundcars.count() > 0:
            listOfCars = list(foundcars)
        else:
            oneFound=False
    else:
        foundcars = cars.find_one()
    listOfCars = foundcars

    if oneFound:
        cars_json = dumps(listOfCars,indent=None)
        return response.json(cars_json, headers={'X-Served-By': 'Prisma Cloud'}, status=200)

    return response.json(
        {'Result': 'car NOT found'},
        headers={'X-Served-By': 'Prisma Cloud'},
        status=404)

@app.post("/car")
async def add_new_car(request):
    newcar = request.json
    cars.insert_one(newcar)
    d = datetime.now().strftime("[%Y-%m-%d %H:%M:%S +0000] [DB] [CREATE]")
    print( d + " ***** " + newcar['make'] + " " + newcar['model'] + " created ****"  )

    return response.json(
        {'Result': 'car successfully created'},
        headers={'X-Served-By': 'Prisma Cloud'},
        status=201)

@app.get("/dealer")
async def get_dealer(request):
    listOfDealers = []
    oneFound=True

    args = request.query_args
    if len(args) > 0:
        dealer_dict = toDictionary(args)
        founddealers = dealers.find(dealer_dict)
        if founddealers.count() > 0:
            listOfDealers = list(founddealers)
        else:
            oneFound=False
    else:
        founddealers = dealers.find_one()
        listOfDealers = founddealers

    if oneFound:
        dealer_json = dumps(listOfDealers,indent=None)
        return response.json(
            dealer_json,
            headers={'X-Served-By': 'Prisma Cloud'},
            status=200)

    return response.json(
        {'Result': 'Dealership NOT found'},
        headers={'X-Served-By': 'Prisma Cloud'},
        status=404)

@app.post("/dealer")
async def add_new_dealer(request):
    newdealer = request.json
    dealers.insert_one(newdealer)
    d = datetime.now().strftime("[%Y-%m-%d %H:%M:%S +0000] [DB] [CREATE]")
    print( d + " ***** " + newdealer['_id'] + " " + newdealer['city'] + " created ****"  )

    return response.json(
        {"Result": "Dealership " + newdealer['_id'] + " successfully created"},
        headers={'X-Served-By': 'Prisma Cloud'},
        status=201
    )



@app.get("/inventory")
async def get_inventory(request):
    listOfDealers = []
    oneFound=True

    args = request.query_args
    if len(args) > 0:
        dealer_dict = toDictionary(args)
        founddealers = dealers.find(dealer_dict)
        if founddealers.count() > 0:
            listOfDealers = list(founddealers)
        else:
            oneFound=False
    else:
        founddealers = dealers.find()
        listOfDealers = founddealers

    if oneFound:
        foundCars = []
        messages = []
        for dealer in listOfDealers:
            foundCars = list(cars.find({ "dealership": dealer.get("_id") }))
            messages.append("***** " + dealer['_id'] + " in " + dealer['city'] + " inventoried ****")
            messages.append("  +++ " + dealer['_id'] + " has " + str(len(foundCars)) + " cars" )
            logEvent( "[DB] [INVENTORY]", messages)

        cars_json = json.dumps(foundCars)
        return response.json(
            cars_json,
            headers={'X-Served-By': 'Prisma Cloud'},
            status=200)
    return response.json(
        {'Result': 'No dealership found'},
        headers={'X-Served-By': 'Prisma Cloud'},
        status=404)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
