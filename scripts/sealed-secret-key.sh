function sealed_secret_key_encrypt() {
  env=""
  case "$1" in
    "dev" )
      env="dev"
      ;;
    "stg" )
      env="staging"
      ;;
    "prd" )
      env="prd"
      ;;
    * )
      echo "The environment is not exist."
      exit 1
      ;;
  esac

  if [ $env = "" ]; then
    echo "Please input an environment name as argument."
    exit 1
  fi

  echo "encrypt $env"
#  command gcloud config set project gitops-sample-$env
#  command gcloud kms encrypt --location=global --keyring=api --key=sealed-secret --plaintext-file=sealed-secrets-key-$env.yaml --ciphertext-file=sealed-secrets-key-$env.yaml.enc --project=gitops-sample-$env
}

function sealed_secret_key_decrypt() {
  env=""
  case "$1" in
    "dev" )
      env="dev"
      ;;
    "stg" )
      env="staging"
      ;;
    "prd" )
      env="prd"
      ;;
    * )
      echo "The environment is not exist."
      exit 1
      ;;
  esac

  if [ $env = "" ]; then
    echo "Please input an environment name as argument."
    exit 1
  fi

  echo "decrypt $env"
#  command gcloud config set project gitops-sample-$env
#  command gcloud kms decrypt --location=global --keyring=api --key=sealed-secret --ciphertext-file=sealed-secrets-key-$env.yaml.enc --plaintext-file=sealed-secrets-key-$env.yaml --project=gitops-sample-$env
}
