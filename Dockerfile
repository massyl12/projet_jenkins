ARG version="latest"
FROM nginx:${version}

LABEL maintainer="Massyl B"

# Installer git et nettoyer
RUN apt-get update && \
    apt-get install -y git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Supprimer les fichiers par défaut et cloner le site
RUN rm -rf /usr/share/nginx/html/* && \
    git clone https://github.com/diranetafen/static-website-example.git /usr/share/nginx/html/

EXPOSE 80

ENTRYPOINT [ "/usr/sbin/nginx", "-g", "daemon off;" ]
