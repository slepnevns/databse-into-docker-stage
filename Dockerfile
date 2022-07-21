FROM alpine:3.15 AS base

WORKDIR /tmp


FROM base AS postgresql_example

ARG POSTGRES_USER=dev
ARG POSTGRES_PASSWORD=dev
ARG POSTGRES_DB=dev

# Some cross dependent processes like Symfony web server or
# postgresql should be run in one common Docker layer
# or separated by ampersand. 
RUN set -eux; \
    # Install Postgresql, configure server and database. \
    apk add postgresql; \
    (addgroup -S postgres && adduser -S postgres -G postgres || true); \
    mkdir -p /var/lib/postgresql/data; \
    mkdir -p /run/postgresql/; \
    chown -R postgres:postgres /run/postgresql/; \
    chmod -R 777 /var/lib/postgresql/data; \
    chown -R postgres:postgres /var/lib/postgresql/data; \
    su - postgres -c "initdb /var/lib/postgresql/data"; \
    echo "host all  all    0.0.0.0/0  md5" >> /var/lib/postgresql/data/pg_hba.conf; \
    # Run Postgres \
    su - postgres -c "pg_ctl start -D /var/lib/postgresql/data -l /var/lib/postgresql/log.log"; \
    # Configure Test database \
    su - postgres -c "psql --command \"CREATE DATABASE $POSTGRES_DB;\""; \
    su - postgres -c "psql --command \"CREATE USER $POSTGRES_USER WITH ENCRYPTED PASSWORD '"$POSTGRES_PASSWORD"';\""; \
    su - postgres -c "psql --command \"GRANT ALL PRIVILEGES ON DATABASE $POSTGRES_DB TO $POSTGRES_USER;\"";