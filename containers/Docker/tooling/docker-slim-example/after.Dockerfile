FROM python:3.11-slim
WORKDIR /app
COPY . .
RUN pip install -r requirements.txt --no-cache-dir
USER nobody
ENTRYPOINT ["python", "app.py"]
