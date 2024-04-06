# Pre Reqs
Docker 
K8S (tested on 1.27)
# Deploy
Working with your K8S cluster,
2. From chart/templates directory run `kubectl apply -f .` 
3. You should see the cronJob created, trigger with `kubectl create job --from=cronjob/tsunami-scan-cronjob JOB_NAME`

# Test Locally
From the root of this repo, run:
`docker run --network=host -d -v <LOCAL_PATH_TO_IP_LIST>:/usr/tsunami/ip_list.txt -e SLACK_WEBHOOK_URL=<SLACK_ADDRESS> gojacob93/tests:tsunami-gloat-2.0.2`