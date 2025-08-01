# 1. Base image
FROM python:3.9-alpine3.13

# 2. Maintainer
LABEL maintainer="boint99"

# 3. Config Python
ENV PYTHONUNBUFFERED=1

# 4. Copy files
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app

# 5. Set working dir
WORKDIR /app

# 6. Expose port
EXPOSE 8000

# 7. Install dependencies
ARG DEV=false

RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    apk add --update --no-cache postgresql-client && \
    apk add --update --no-cache --virtual .tmp-build-deps \
        build-base postgresql-dev musl-dev && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ "$DEV" = "True" ]; then \
        /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    rm -rf /tmp && \
    apk del .tmp-build-deps && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user

# 8. Add Python to PATH
ENV PATH="/py/bin:$PATH"

# 9. Set non-root user
USER django-user
