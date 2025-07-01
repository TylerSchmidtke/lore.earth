#!/bin/bash

# Exit on any error
set -e

# Load environment variables from .env file if it exists
if [ -f ".env" ]; then
    print_info() { echo -e "\033[0;32m[INFO]\033[0m $1"; }
    print_info "Loading environment variables from .env file..."

    # Export variables from .env file
    set -a
    source .env
    set +a

    print_info "Environment variables loaded successfully"
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if required environment variables are set
check_env_vars() {
    local missing_vars=()

    if [ -z "$AWS_ACCESS_KEY_ID" ]; then
        missing_vars+=("AWS_ACCESS_KEY_ID")
    fi

    if [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
        missing_vars+=("AWS_SECRET_ACCESS_KEY")
    fi

    if [ -z "$AWS_REGION" ]; then
        missing_vars+=("AWS_REGION")
    fi

    if [ -z "$AWS_ENDPOINT_URL_S3" ]; then
        missing_vars+=("AWS_ENDPOINT_URL_S3")
    fi

    if [ -z "$BUCKET_NAME" ]; then
        missing_vars+=("BUCKET_NAME")
    fi

    if [ ${#missing_vars[@]} -ne 0 ]; then
        print_error "Missing required environment variables:"
        for var in "${missing_vars[@]}"; do
            echo "  - $var"
        done
        echo ""
        echo "Please set all required environment variables before running this script."
        echo "Example:"
        echo "  export AWS_ACCESS_KEY_ID=your_access_key"
        echo "  export AWS_SECRET_ACCESS_KEY=your_secret_key"
        echo "  export AWS_REGION=us-east-1"
        echo "  export AWS_ENDPOINT_URL_S3=https://s3.amazonaws.com"
        echo "  export BUCKET_NAME=your-bucket-name"
        exit 1
    fi
}

# Check if zola is installed
check_zola() {
    if ! command -v zola &> /dev/null; then
        print_error "Zola is not installed. Please install Zola first."
        print_info "Visit: https://www.getzola.org/documentation/getting-started/installation/"
        exit 1
    fi
}

# Check if aws cli is installed
check_aws_cli() {
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI is not installed. Please install AWS CLI first."
        print_info "Visit: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
        exit 1
    fi
}

# Build the site with Zola
build_site() {
    print_info "Building site with Zola..."

    if [ -d "public" ]; then
        print_info "Cleaning existing public directory..."
        rm -rf public
    fi

    zola build

    if [ $? -eq 0 ]; then
        print_info "Zola build completed successfully"
    else
        print_error "Zola build failed"
        exit 1
    fi
}

# Sync to S3
sync_to_s3() {
    print_info "Syncing to S3 bucket: $BUCKET_NAME"
    print_info "Using endpoint: $AWS_ENDPOINT_URL_S3"

    # Configure AWS CLI with environment variables
    export AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID"
    export AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY"
    export AWS_DEFAULT_REGION="$AWS_REGION"

    # Sync the public directory to S3
    aws s3 sync public/ "s3://$BUCKET_NAME/" \
        --endpoint-url "$AWS_ENDPOINT_URL_S3" \
        --delete \
        --exact-timestamps \
        --cache-control "public, max-age=31536000" \
        --exclude "*.html" \
        --exclude "*.xml" \
        --exclude "*.json"

    # Sync HTML, XML, and JSON files with different cache control
    aws s3 sync public/ "s3://$BUCKET_NAME/" \
        --endpoint-url "$AWS_ENDPOINT_URL_S3" \
        --delete \
        --exact-timestamps \
        --cache-control "public, max-age=0, must-revalidate" \
        --include "*.html" \
        --include "*.xml" \
        --include "*.json"

    if [ $? -eq 0 ]; then
        print_info "Successfully synced to S3!"
    else
        print_error "S3 sync failed"
        exit 1
    fi
}

# Set content types for common file extensions
set_content_types() {
    print_info "Setting content types for common file extensions..."

    # Set content type for CSS files
    aws s3 cp "s3://$BUCKET_NAME/" "s3://$BUCKET_NAME/" \
        --endpoint-url "$AWS_ENDPOINT_URL_S3" \
        --recursive \
        --exclude "*" \
        --include "*.css" \
        --metadata-directive REPLACE \
        --content-type "text/css" \
        --cache-control "public, max-age=31536000" > /dev/null 2>&1 || true

    # Set content type for JS files
    aws s3 cp "s3://$BUCKET_NAME/" "s3://$BUCKET_NAME/" \
        --endpoint-url "$AWS_ENDPOINT_URL_S3" \
        --recursive \
        --exclude "*" \
        --include "*.js" \
        --metadata-directive REPLACE \
        --content-type "application/javascript" \
        --cache-control "public, max-age=31536000" > /dev/null 2>&1 || true

    # Set content type for XML files (feeds)
    aws s3 cp "s3://$BUCKET_NAME/" "s3://$BUCKET_NAME/" \
        --endpoint-url "$AWS_ENDPOINT_URL_S3" \
        --recursive \
        --exclude "*" \
        --include "*.xml" \
        --metadata-directive REPLACE \
        --content-type "application/xml" \
        --cache-control "public, max-age=0, must-revalidate" > /dev/null 2>&1 || true
}

# Main execution
main() {
    print_info "Starting deployment process..."

    # Run all checks
    check_env_vars
    check_zola
    check_aws_cli

    # Build and deploy
    build_site
    sync_to_s3
    set_content_types

    print_info "Deployment completed successfully!"
    print_info "Your site should now be live at: https://lore.earth"
}

# Run the main function
main "$@"
