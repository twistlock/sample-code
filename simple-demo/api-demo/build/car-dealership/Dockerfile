FROM sanicframework/sanic:LTS
LABEL maintainer="MBarker"
LABEL tier="api"
LABEL application="car-dealership"
LABEL appVersion==="1.0"
LABEL baseImage="sanicframework/sanic:LTS"
LABEL patch="2.1."

RUN pip install sanic-openapi
RUN pip install pymongo
COPY car-dealership.py /srv

EXPOSE 80 

ENTRYPOINT ["python3","-u","/srv/car-dealership.py"]


