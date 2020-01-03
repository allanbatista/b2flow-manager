# B2flow Manager


```
B2FLOW__DAG__CONFIG={"name":"x-dag","config":{"example":"1"},"team":"x-team","project":"x-project","jobs":[{"name":"job_name1","depends":[],"full_name":"x-team_x-project_x-dag_job_name1","version":1577984308,"engine":{"flavor":"high-memory-2","type":"DockerEngine"},"image":"allanbatista/b2flow-image-test"},{"name":"job_name2","depends":[],"full_name":"x-team_x-project_x-dag_job_name2","version":1577984308,"engine":{"type":"DockerEngine"},"image":"allanbatista/b2flow-image-test"},{"name":"job_name3","depends":["job_name1"],"full_name":"x-team_x-project_x-dag_job_name3","version":1577984308,"engine":{"type":"DockerEngine"},"image":"allanbatista/b2flow-image-test"},{"name":"job_name4","depends":["job_name2"],"full_name":"x-team_x-project_x-dag_job_name4","version":1577984308,"engine":{"type":"DockerEngine"},"image":"allanbatista/b2flow-image-test"},{"name":"job_name5","depends":["job_name3","job_name4"],"full_name":"x-team_x-project_x-dag_job_name5","version":1577984308,"engine":{"type":"DockerEngine"},"image":"allanbatista/b2flow-image-test"}]}
B2FLOW__KUBERNETES__URI=https://kubernetes.endpoint
B2FLOW__KUBERNETES__USERNAME=admin
B2FLOW__KUBERNETES__PASSWORD=xxxx
```