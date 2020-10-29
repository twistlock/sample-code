FROM sanicframework/sanic:LTS
RUN pip install sanic-openapi

COPY car-server.py /srv

EXPOSE 8888

ENTRYPOINT ["python3", "/srv/car-server.py"]


