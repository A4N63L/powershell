FROM ubuntu:24.04

# netcat-openbsd está en main; evitar índices de repositorios innecesarios.
RUN sed -i 's/^Components: .*/Components: main/' /etc/apt/sources.list.d/ubuntu.sources \
    && apt-get update \
    && apt-get install -y --no-install-recommends netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

# COPY conserva el permiso ejecutable del script registrado en Git.
COPY comprobar_puerto.sh /usr/local/bin/comprobar_puerto.sh

ENTRYPOINT ["/usr/local/bin/comprobar_puerto.sh"]
