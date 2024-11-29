#echo "deploy event handler"
read payload
echo $SERF_SELF_NAME $payload >> deploy.log
