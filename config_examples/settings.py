from ._settings import *

DEBUG = False

DATABASE_CONNECTION_KWARGS['database'] = 'proxy_py'
DATABASE_CONNECTION_KWARGS['user'] = 'proxy_py'
DATABASE_CONNECTION_KWARGS['password'] = 'proxy_py'

PROXY_PROVIDER_SERVER_ADDRESS = {
    'HOST': '0.0.0.0',
    'PORT': 55555,
}
