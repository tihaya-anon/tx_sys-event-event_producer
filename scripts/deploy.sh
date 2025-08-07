#!/bin/bash
SCRIPT_DIR=$(cd $(dirname $0); pwd)
cd $SCRIPT_DIR/..
# Deployment script for Event Producer application

# Exit on error
set -e

# Parse command line arguments
FORCE_REBUILD=false
NAMESPACE="event-pdcr"  # Default namespace

# Function to check if Docker image exists
check_and_build_image() {
    local force_rebuild=$1
    local image_name="event_pdcr"
    
    # Check if image exists
    eval $(minikube docker-env)
    if docker image inspect $image_name:latest >/dev/null 2>&1; then
        if [ "$force_rebuild" = "true" ]; then
            echo "Image $image_name exists, but force rebuild requested..."
            ./scripts/img.sh
        else
            echo "Image $image_name already exists, skipping build..."
        fi
    else
        echo "Image $image_name does not exist, building..."
        ./scripts/img.sh
    fi
}



usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  -b, --rebuild       Force rebuild of Docker image"
    echo "  -n, --namespace     Specify Kubernetes namespace (default: event-pdcr)"
    echo "  -f, --forward       Forward gRPC server port to local machine"
    echo "  -h, --help          Display this help message"
    exit 1
}

while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -b|--rebuild)
        FORCE_REBUILD=true
        shift
        ;;
        -n|--namespace)
        if [[ -z "$2" ]]; then
            echo "Error: --namespace requires a value"
            usage
        fi
        NAMESPACE="$2"
        shift 2
        ;;
        -f|--forward)
        FORWARD=true
        shift
        ;;
        -h|--help)
        usage
        ;;
        *)
        # Unknown option
        echo "Unknown option: $key"
        usage
        ;;
    esac
done

# Build the application Docker image if needed
check_and_build_image $FORCE_REBUILD

# Check if Kubernetes is accessible
check_kubernetes() {
    if kubectl cluster-info > /dev/null 2>&1; then
        echo "Kubernetes cluster is accessible."
        return 0
    else
        echo "ERROR: Kubernetes cluster is not accessible. Please ensure your cluster is running and properly configured."
        return 1
    fi
}

# Check if namespace exists and create it if it doesn't
ensure_namespace() {
    local namespace=$1
    if ! kubectl get namespace $namespace > /dev/null 2>&1; then
        echo "Namespace '$namespace' does not exist. Creating it..."
        kubectl create namespace $namespace
        echo "Namespace '$namespace' created successfully."
    else
        echo "Namespace '$namespace' already exists."
    fi
}

# Deploy to Kubernetes based on selected options
deploy_to_kubernetes() {
    if ! check_kubernetes; then
        echo "Skipping Kubernetes deployment steps."
        return 1
    fi
    
    # Ensure namespace exists
    ensure_namespace $NAMESPACE

    
    # Apply Kubernetes manifests
    echo "Applying gRPC server Kubernetes manifests in namespace $NAMESPACE..."
    kubectl apply -f ./k8s/deployment.yaml --namespace $NAMESPACE
    kubectl apply -f ./k8s/service.yaml --namespace $NAMESPACE
    
    echo "Waiting for gRPC server to be ready..."
    kubectl wait --for=condition=ready pod -l app=event-pdcr --timeout=300s --namespace $NAMESPACE
    
    echo "gRPC server deployment completed successfully!"
    echo "logs: "
    kubectl logs -l app=event-pdcr -n $NAMESPACE
    if [[ "$FORWARD" == "true" ]]; then
        kubectl port-forward svc/event-pdcr 50051:50051 -n $NAMESPACE
    else
        echo "You can access the gRPC server using the following command:"
        echo "  kubectl port-forward svc/event-pdcr 50051:50051 -n $NAMESPACE"
        echo "Then use a gRPC client to connect to localhost:50051"
    fi
    echo "Deployment process completed."
    return 0
}

# Execute the deployment
deploy_to_kubernetes
