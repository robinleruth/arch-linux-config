#!/bin/bash

set -e
# set -x

read root_directory

for i in domain infrastructure infrastructure/db interface interface/controllers domain/model domain/services
do
    mkdir -p $root_directory/app/$i
    touch $root_directory/app/$i/__init__.py
done
mkdir -p $root_directory/test
touch $root_directory/test/__init__.py
touch $root_directory/app/__init__.py
cat > $root_directory/app/infrastructure/config.py  << EOL
import os

assert 'APP_ENV' in os.environ, 'MAKE SURE TO SET AN ENVIRONMENT'
basedir = os.path.abspath(os.path.dirname(__file__))
basedir = os.path.split(basedir)[0]


class Config:
    PORT = 8080
    SECRET_KEY = os.environ.get('SECRET', 'secret')
    SQL_URI = 'sqlite:///app.db'
    SCOPES = {
        "me": "Read information about the current user.",
        "event": "Has the opportunity to send event"
    }
    CLIENT_ID = 'service'
    BASEDIR = basedir
    LOG_FOLDER = os.path.join(BASEDIR, 'logs')
    LOG_FILENAME = 'app.log'
    LOG_FILE_PATH = os.path.join(LOG_FOLDER, LOG_FILENAME)
    LOGGER_NAME = 'logger'
    REDIS_HOST = 'localhost'
    REDIS_PORT = '6379'


class DockerConfig(Config):
    PORT = 8080
    DB_NAME = os.environ.get('DB_NAME', 'database')
    DB_PWD = os.environ.get('DB_PWD', 'password')
    DB_USER = os.environ.get('DB_USER', 'user')
    SQL_URI = f'postgresql+psycopg2://{DB_USER}:{DB_PWD}@database/{DB_NAME}'
    REDIS_HOST = 'redis'


class TestConfig(Config):
    SQL_URI = 'sqlite:///test.db'


env = os.environ['APP_ENV'].upper()
if env == 'TEST':
    app_config = TestConfig
elif env == 'PRD':
    app_config = DockerConfig
else:
    app_config = Config

print(app_config)
EOL

cat > $root_directory/app.py << EOL
import uvicorn

from app.infrastructure.config import app_config
from app.interface import api

if __name__ == '__main__':
    uvicorn.run(api, port=app_config.PORT, host='0.0.0.0')
EOL

cat > $root_directory/Dockerfile << EOL
FROM python:3.7-alpine

RUN apk add --no-cache gcc musl-dev make build-base libffi-dev openssl-dev postgresql-dev
RUN apk add build-base libtool automake

RUN adduser -D service

WORKDIR /home/service

COPY requirements.txt requirements.txt

RUN python -m venv venv
RUN venv/bin/python -m pip install --upgrade pip
RUN venv/bin/pip install wheel
COPY dist dist
RUN venv/bin/pip install dist/*.whl
RUN venv/bin/pip install -r requirements.txt

COPY app app
COPY tests tests
COPY app.py run_app.sh ./

RUN chmod +x run_app.sh

RUN chown -R service:service ./
USER service
EXPOSE 8080

ENTRYPOINT ["./run_app.sh"]
EOL
cat > $root_directory/run_app.sh << EOL
#!/bin/bash

export APP_ENV=prd
source venv/bin/activate

echo "Launch API"
python app.py
EOL
chmod +x $root_directory/run_app.sh
cat > $root_directory/app/infrastructure/log.py  << EOL
import os
import logging

from logging.handlers import RotatingFileHandler
from logging import StreamHandler

from app.infrastructure.config import app_config


def create_logger():
    _logger = logging.getLogger(app_config.LOGGER_NAME)
    _logger.setLevel(logging.INFO)
    os.makedirs(app_config.LOG_FOLDER, exist_ok=True)
    fh = RotatingFileHandler(app_config.LOG_FILE_PATH, maxBytes=10240, backupCount=10)
    fmt = '%(asctime)s - %(name)s - %(levelname)s - %(message)s [in %(pathname)s : %(lineno)d ]'
    formatter = logging.Formatter(fmt)
    fh.setFormatter(formatter)
    _logger.addHandler(fh)
    st = StreamHandler()
    st.setFormatter(formatter)
    _logger.addHandler(st)
    return _logger


logger = create_logger()
EOL

cat > $root_directory/app/infrastructure/db/__init__.py  << EOL
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from sqlalchemy.orm import scoped_session

from app.infrastructure.config import app_config


Base = declarative_base()

# pool_pre_ping=True as argument if needed
engine = create_engine(app_config.SQL_URI)
Session = scoped_session(sessionmaker(bind=engine,
                                      autocommit=False,
                                      autoflush=True))

# from .log import Log
Base.metadata.create_all(engine)
EOL

cat > $root_directory/app/infrastructure/db/db_session.py  << EOL
from contextlib import contextmanager

from app.infrastructure.db import Session


@contextmanager
def transaction_context():
    session = Session()
    session.expire_on_commit = False
    try:
        yield session
        session.commit()
    except:
        raise
    finally:
        Session.remove()
EOL

cat > $root_directory/app/interface/__init__.py  << EOL
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

api = FastAPI(title='API',
              description='',
              version='0.1')

# from .controllers import controller

# api.include_router(controller.router,
                   # prefix='/api/v1/controller',
                   # tags=['controller'])

api.add_middleware(
    CORSMiddleware,
    allow_origins=['*'],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
EOL
