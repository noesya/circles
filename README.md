# README

Application Rails générée avec [noesya/rails-templates](https://github.com/noesya/rails-templates), créé par l'équipe [noesya](https://www.noesya.coop).

## Configuration

Il faut encoder la clé pour le SSO en base64.
Pour cela, la mettre dans un fichier (par exemple nommé `certificat.crt`), enlever tous les sauts de ligne, et appeler 
```bash
cat certificat.crt | base64
````

Idem pour les credentials json permettant d'accéder aux APIs Google.

```bash
cat ./config/creds.json | base64
```
