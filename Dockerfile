# Use AWS Lambda Python 3.11 runtime image as the base
FROM public.ecr.aws/lambda/python:3.11

ARG VAR1
ARG VAR2

# Install AWS CLI inside the container
RUN yum install -y unzip && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install

# Set the working directory for the Lambda layer
WORKDIR /opt

# Copy requirements.txt into the container
COPY requirements.txt .

# Install the dependencies into 'python/' directory (required by Lambda layers)
RUN pip3 install -r requirements.txt -t python/

# Zip the installed packages to create the layer
RUN zip -r9 /opt/layer.zip python

# Set environment variables for AWS credentials (assumed to be passed during runtime)
ENV AWS_ACCESS_KEY_ID=$VAR1
ENV AWS_SECRET_ACCESS_KEY=$VAR2
ENV AWS_DEFAULT_REGION=eu-west-1

# Upload the zip file as a Lambda layer using AWS CLI and output the layer ARN
CMD ["sh", "-c", "aws lambda publish-layer-version --layer-name my-python-layer --zip-file fileb:///opt/layer.zip --compatible-runtimes python3.11 --description 'Python 3.11 Layer' --query 'LayerVersionArn' --output text"]
