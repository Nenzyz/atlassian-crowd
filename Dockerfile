FROM java:8

# Setup useful environment variables
ENV CROWD_HOME     /var/atlassian/crowd
ENV CROWD_INSTALL  /opt/atlassian/crowd
ENV CROWD_VERSION  2.9.1

# Install Atlassian Confluence and hepler tools and setup initial home
# directory structure.
RUN set -x \
    && apt-get update --quiet \
    && apt-get install --quiet --yes --no-install-recommends libtcnative-1 xmlstarlet \
    && apt-get clean \
    && mkdir -p                "${CROWD_HOME}" \
    && mkdir -p                "${CROWD_INSTALL}" \
    && mkdir -p                "${CROWD_INSTALL}/conf" \
    && chmod -R 700            "${CROWD_INSTALL}/conf" \
    && chown -R daemon:daemon  "${CROWD_INSTALL}/conf" \
    && curl -Ls                "https://www.atlassian.com/software/crowd/downloads/binary/atlassian-crowd-${CROWD_VERSION}.tar.gz" | tar -xz --directory "${CROWD_INSTALL}" --strip-components=1 --no-same-owner \
    # && curl -Ls                "https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.38.tar.gz" | tar -xz --directory "${CROWD_INSTALL}/crowd/WEB-INF/lib" --strip-components=1 --no-same-owner "mysql-connector-java-5.1.38/mysql-connector-java-5.1.38-bin.jar" \
    && chmod -R 700            "${CROWD_HOME}" \
    && chmod -R 700            "${CROWD_INSTALL}" \
    && chown -R daemon:daemon  "${CROWD_HOME}" \
    && chown -R daemon:daemon  "${CROWD_INSTALL}" \
    # && chmod -R 700            "${CROWD_INSTALL}/temp" \
    # && chmod -R 700            "${CROWD_INSTALL}/logs" \
    # && chmod -R 700            "${CROWD_INSTALL}/work" \
    # && chown -R daemon:daemon  "${CROWD_INSTALL}/temp" \
    # && chown -R daemon:daemon  "${CROWD_INSTALL}/logs" \
    # && chown -R daemon:daemon  "${CROWD_INSTALL}/work" \
    && echo -e                 "\ncrowd.home=$CROWD_HOME" >> "${CROWD_INSTALL}/crowd-webapp/WEB-INF/classes/crowd-init.properties" \
    # && xmlstarlet              ed --inplace \
    #     --delete               "Server/@debug" \
    #     --delete               "Server/Service/Connector/@debug" \
    #     --delete               "Server/Service/Connector/@useURIValidationHack" \
    #     --delete               "Server/Service/Connector/@minProcessors" \
    #     --delete               "Server/Service/Connector/@maxProcessors" \
    #     --delete               "Server/Service/Engine/@debug" \
    #     --delete               "Server/Service/Engine/Host/@debug" \
    #     --delete               "Server/Service/Engine/Host/Context/@debug" \
    #                            "${CROWD_INSTALL}/conf/server.xml" \
    && touch -d "@0"           "${CROWD_INSTALL}/conf/server.xml"

# Use the default unprivileged account. This could be considered bad practice
# on systems where multiple processes end up being executed by 'daemon' but
# here we only ever run one process anyway.
USER daemon:daemon

# Expose default HTTP connector port.
EXPOSE 8095

# Set volume mount points for installation and home directory. Changes to the
# home directory needs to be persisted as well as parts of the installation
# directory due to eg. logs.
VOLUME ["/var/atlassian/crowd", "/opt/atlassian/crowd/logs"]

# Set the default working directory as the Confluence home directory.
WORKDIR /var/atlassian/crowd

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

# Run Atlassian Confluence as a foreground process by default.
CMD ["/opt/atlassian/crowd/apache-tomcat/bin/catalina.sh", "run"]



