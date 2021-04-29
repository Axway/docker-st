## SecureTransport on K8S with PostgreSQL

### Steps to deploy a sample ST backend using PostgreSQL as a database
1) Clone or download the postgreExample folder. 
2) Create the "securetransport" namespace:
```
kubectl create namespace securetransport
```
3) From the base folder (postgreExample), enter the runtime/secrets directory
4) Populate the st.license (Feature license) and filedrive.license (Core license) with valid licensing data
5) Create the st-server-secret:
```
kubectl create secret generic st-server-secret -n securetransport --from-file=./db.conf --from-file=./STGlobalConfig.properties  --from-file=./STStartScriptsConfig --from-file=./taeh --from-file=./st.license --from-file=./filedrive.license
```
6) Return to the base folder and enter the db directory
7) Create the database secret, used to populate the required tablespaces and also create our user:
```
kubectl create secret generic postgres-secret -n securetransport --from-file=./initDirs.sh --from-file=./initSetup.sql
```
8) From the base folder enter the haproxy directory and create the haproxy secret:
```
kubectl create secret generic haproxy-secret -n securetransport --from-file=./haproxy.cfg
```
9) Return to the base directory and replace the container image placeholder with an image of SecureTransport in the st-kubernetes.yml.
10) By this point we are all set and ready to go. All that's left is to run:
```
kubectl create -f st-kubernetes.yml
```
11) After a while the SecureTransport Admin UI should be up and running on port <**31520**> 
of the kubernetes worker, alongside a single SSH listener on port <**31524**>. 
All the external ports can be configured via the haproxy-service at the top of the st-kubernetes.yml, 
whereas the configuration for the SSH listener can be found inside the STGlobalConfig.properties