#!/bin/bash

echo "🔄 Syncing N8N workflows to GitHub..."

# Create timestamp
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Export workflows from N8N development
echo "📥 Extracting from N8N Development..."
docker cp n8n-dev:/home/node/.n8n/workflows/. ./workflows/development/ 2>/dev/null || echo "No dev workflows found yet"

# Export workflows from N8N production  
echo "📥 Extracting from N8N Production..."
docker cp n8n-prod:/home/node/.n8n/workflows/. ./workflows/production/ 2>/dev/null || echo "No prod workflows found yet"

# Count workflows
DEV_COUNT=$(find workflows/development/ -name "*.json" -type f 2>/dev/null | wc -l)
PROD_COUNT=$(find workflows/production/ -name "*.json" -type f 2>/dev/null | wc -l)

echo "✅ Dev workflows: $DEV_COUNT"
echo "✅ Prod workflows: $PROD_COUNT"

# Git operations
git add workflows/
if git commit -m "sync: workflows backup $TIMESTAMP - Dev:$DEV_COUNT Prod:$PROD_COUNT"; then
    git push origin main
    echo "🚀 Successfully synced to GitHub!"
else
    echo "📝 No changes to commit"
fi