# Dataform Sample

```sh
terraform init
terraform plan -var-file="local.tfvars"
```

```sh
# GIT_COMMIT_SHA
# PROJECT_ID
# REPOSITORY
curl -X POST -H 'Content-Type: application/json' -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -d '{"gitCommitish":"${COMMIT_SHA}"}' \
  "https://dataform.googleapis.com/v1beta1/projects/${PROJECT_ID}/locations/us-central1/repositories/${REPOSITORY}/compilationResults"
#{
#  "name": "projects/<PROJECT_ID>/locations/us-central1/repositories/<REPOSITORY>/compilationResults/<ID>",
#  "gitCommitish": "<GIT_COMMIT_SHA>",
#  "codeCompilationConfig": {
#    "defaultDatabase": "<PROJECT_ID>",
#    "defaultSchema": "<REPOSITORY>_mart",
#    "assertionSchema": "<REPOSITORY>_assertions",
#    "vars": {
#      "rawSchema": "<REPOSITORY>_raw"
#    },
#    "defaultLocation": "US"
#  },
#  "dataformCoreVersion": "2.0.1",
#  "resolvedGitCommitSha": "<GIT_COMMIT_SHA>"
#}
```

