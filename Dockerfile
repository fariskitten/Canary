FROM python:3.7.4
WORKDIR /sampleapp
ADD ./ /sampleapp
RUN pip install -r requirements.txt
EXPOSE 8080
CMD ["python", "app.py"]
