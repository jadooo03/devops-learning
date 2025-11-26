FROM python:3.14-slim
WORKDIR /app
COPY . .
RUN pip install flask
CMD ["python","app.py"]