#!/bin/bash

echo "🚀 Deploying workflows from GitHub to N8N..."

# Pull latest changes
git pull origin main

# Deploy to development
echo "📤 Deploying to N8N Development..."
if [ -d "./workflows/development" ] && [ "$(ls -A ./workflows/development/*.json 2>/dev/null)" ]; then
    # Backup current dev workflows
    docker exec n8n-dev mkdir -p /tmp/backup_$(date +%Y%m%d_%H%M%S) 2>/dev/null
    docker cp n8n-dev:/home/node/.n8n/workflows/. /tmp/n8n-dev-backup-$(date +%Y%m%d_%H%M%S)/ 2>/dev/null
    
    # Deploy new workflows
    docker cp ./workflows/development/. n8n-dev:/home/node/.n8n/workflows/
    docker restart n8n-dev
    echo "✅ Development deployment completed!"
    
    # Wait for N8N to restart
    echo "⏳ Waiting for N8N dev to restart..."
    sleep 10
else
    echo "⚠️  No development workflows to deploy"
fi

# Ask about production deployment
if [ -d "./workflows/production" ] && [ "$(ls -A ./workflows/production/*.json 2>/dev/null)" ]; then
    read -p "Deploy to PRODUCTION? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Backup prod workflows
        docker exec n8n-prod mkdir -p /tmp/backup_$(date +%Y%m%d_%H%M%S) 2>/dev/null
        docker cp n8n-prod:/home/node/.n8n/workflows/. /tmp/n8n-prod-backup-$(date +%Y%m%d_%H%M%S)/ 2>/dev/null
        
        # Deploy to production
        docker cp ./workflows/production/. n8n-prod:/home/node/.n8n/workflows/
        docker restart n8n-prod
        echo "✅ Production deployment completed!"
        
        # Wait for N8N to restart
        echo "⏳ Waiting for N8N prod to restart..."
        sleep 10
    else
        echo "⏭️  Production deployment skipped"
    fi
fi

echo "🎉 Deployment process finished!"