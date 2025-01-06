## Setup Cloud Run
Navigate to the root of the project
```
cd path/to/project-root
```

List projects to get ID
```
gcloud projects list
```

Specify the Google Cloud project where you want to deploy:
```
gcloud config set project [PROJECT_ID]
```

## Enable required APIs
Enable the required APIs
```
gcloud services enable cloudbuild.googleapis.com run.googleapis.com containerregistry.googleapis.com
```

## Authenticate Docker with Google Cloud

Run the following command to configure Docker to use Google Cloud credentials:
```
gcloud auth configure-docker
```

## Test the Docker Image locally
Build the Docker image: `docker build -t app .`

Run the Docker image and test locally by opening localhost:8080 : `docker run -p 8080:8080 app`

## Tag the Docker Image to GCR
Tag the Docker image to the Google Container Registry format: (here the tag is cloudrun-app)
```
docker build -t gcr.io/[PROJECT-ID]/cloudrun-app:v1 .
```

## Push the Docker Image
Push the Docker image to the Google Container Registry (GCR)
```
docker push gcr.io/[PROJECT-ID]/cloudrun-app:v1
```

Deploy the image to Cloud Run
```
gcloud run deploy app --image gcr.io/[PROJECT-ID]/app --platform managed --region europe-west1
```
