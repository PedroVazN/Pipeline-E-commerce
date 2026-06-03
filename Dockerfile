FROM nginx:1.27-alpine

# Rótulo exibido no rodapé (Fase 1 / balanceador / Auto Scaling)
ARG INSTANCE_LABEL=web-srv-01
ENV INSTANCE_LABEL=${INSTANCE_LABEL}

COPY index.html /usr/share/nginx/html/index.html
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 80
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
