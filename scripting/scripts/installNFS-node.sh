
# Prompt for NODE_IP if not provided
if [ -z "$NODE_IP" ]; then
  read -p "Please enter the NODE_IP: " NODE_IP
fi

# Prompt for SERVER_IP if not provided
if [ -z "$SERVER_IP" ]; then
  read -p "Please enter the SERVER_IP: " SERVER_IP
fi

# Validate if both NODE_IP and SERVER_IP are provided
if [ -z "$NODE_IP" ] || [ -z "$SERVER_IP" ]; then
  echo "Error: Both NODE_IP and SERVER_IP are required."
  exit 1
fi

cho "Running Script on compute node $NODE_IP with server IP $SERVER_IP..."
ssh $NODE_IP "bash -s" < ~/scripts/node/installNFS.sh "$SERVER_IP"
