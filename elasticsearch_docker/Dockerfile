FROM docker.elastic.co/elasticsearch/elasticsearch:8.17.4

USER root

# Thiết lập biến môi trường cần thiết
ENV ES_TMPDIR=/tmp
ENV ES_HOME=/usr/share/elasticsearch
ENV JAVA_HOME=/usr/share/elasticsearch/jdk

# Tạo thư mục tạm để cài plugin
RUN mkdir -p /tmp && chmod 777 /tmp

# Copy file plugin ZIP nội bộ
COPY analysis-icu-8.17.4.zip /tmp/

# Cài plugin từ file ZIP
RUN $ES_HOME/bin/elasticsearch-plugin install --batch file:///tmp/analysis-icu-8.17.4.zip

# Sửa quyền lại cho thư mục plugin để tránh lỗi permission denied
RUN chown -R elasticsearch:elasticsearch $ES_HOME/plugins

# Copy file cấu hình custom
COPY --chown=elasticsearch:elasticsearch ./es_config/stopword.txt $ES_HOME/config/stopword.txt
COPY --chown=elasticsearch:elasticsearch ./es_config/synonym.txt $ES_HOME/config/synonym.txt

USER elasticsearch
WORKDIR $ES_HOME
