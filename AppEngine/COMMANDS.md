## Create a new App Engine
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

List the regions:
```
gcloud app regions list
```

## Enable App Engine Service
Initialize App Engine and specify your region
```
gcloud app create --region=europe-west
```

Enable gcloud services:
```
gcloud services enable cloudbuild.googleapis.com
```


## Deploy the app
Deploy the app to App Engine
```
gcloud app deploy
```

Visit the app by opening:
```
gcloud app browse
```