```bash
minikube start
# Przełączanie na środowisko Minikube
eval $(minikube docker-env)

docker build -t mikroserwis-a:latest ./mikroserwis-a
docker build -t mikroserwis-b:latest ./mikroserwis-b

kubectl apply -f ./kubernetes

# Przekierowanie portu (blokuje terminal)
kubectl port-forward service/mikroserwis-a-service 8888:3000
# Sprawdzenie działania
curl http://localhost:8888

# Sprawdzenie logów
kubectl logs -l app=mikroserwis-a
kubectl logs -l app=mikroserwis-b

# Usuwanie stworzonych podów i obrazów w Minikube
minikube delete
```
