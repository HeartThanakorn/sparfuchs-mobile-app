#!/bin/bash

# ===========================================
# SparFuchs AI - VPS Setup Script
# Run this on a fresh Hostinger VPS (Ubuntu 22.04+)
# ===========================================

set -e

echo "🦊 SparFuchs AI - VPS Setup Starting..."

# ===========================================
# 1. Update System
# ===========================================
echo "📦 Updating system packages..."
sudo apt update && sudo apt upgrade -y

# ===========================================
# 2. Install Docker
# ===========================================
echo "🐳 Installing Docker..."

# Remove old versions
sudo apt remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true

# Install prerequisites
sudo apt install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker GPG key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Add Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add current user to docker group
sudo usermod -aG docker $USER

echo "✅ Docker installed successfully"

# ===========================================
# 3. Create Directory Structure
# ===========================================
echo "📁 Creating directories..."

SPARFUCHS_DIR=~/sparfuchs
mkdir -p $SPARFUCHS_DIR

# ===========================================
# 4. Configure Firewall
# ===========================================
echo "🔒 Configuring firewall..."

sudo ufw allow OpenSSH
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw --force enable

echo "✅ Firewall configured"

# ===========================================
# 5. Final Instructions
# ===========================================
echo ""
echo "🎉 VPS setup complete!"
echo ""
echo "📋 Next steps:"
echo "1. Log out and back in for docker group to take effect"
echo "2. Copy docker-compose.yml and .env to $SPARFUCHS_DIR"
echo "3. Edit .env with your actual values"
echo "4. Run: cd $SPARFUCHS_DIR && docker compose up -d"
echo ""
echo "🔐 Generate encryption key:"
echo "   openssl rand -hex 32"
echo ""
echo "🔑 Generate Traefik auth:"
echo "   htpasswd -nB admin"
echo ""
