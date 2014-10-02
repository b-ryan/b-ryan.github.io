The content of buckryan.com

# Developing

pip install -r requirements.txt
./develop.sh

# Deploy to S3

aws s3 sync output BUCKET
