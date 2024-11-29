FROM python:3.11.10-bullseye

RUN pip install --upgrade pip

COPY ./requirements.311.txt /tmp/dist/requirements.txt

RUN pip install --no-cache-dir --compile \
    --index-url https://pypi.org/simple \
    --upgrade -r /tmp/dist/requirements.txt

RUN rm -rf /tmp/dist

COPY ./app.py /app.py

ENTRYPOINT ["python3.11", "/app.py"]
