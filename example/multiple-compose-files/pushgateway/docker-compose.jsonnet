/*
pushgateway:
    image: prom/pushgateway:v1.2.0
    container_name: pushgateway
    restart: unless-stopped
    expose:
      - 9091
    networks:
      - monitor-net
    labels:
      org.label-schema.group: "monitoring"
*/