proxy_py README
===============

proxy_py is a program which collects proxies, saves them in
a database and makes periodically checks.
It has a server for getting proxies with nice API(see below).

Where is the documentation?
***************************

It's here -> https://proxy-py.readthedocs.io

How to support this project?
****************************

You can donate here -> https://www.patreon.com/join/2313433

Thank you :)

How to build?
*************

1 Clone this repository

.. code-block:: bash

    git clone https://github.com/DevAlone/proxy_py.git

2 Install requirements

.. code-block:: bash

    cd proxy_py
    pip3 install -r requirements.txt

3 Create settings file

.. code-block:: bash

    cp config_examples/settings.py proxy_py/settings.py

4 Install postgresql and change database configuration in settings.py file

5 (Optional) Configure alembic

6 Run your application

.. code-block:: bash
    python3 main.py

7 Enjoy!

I'm too lazy. Can I just use it?
********************************

Yep, here is a prepared docker image

1 Install docker. If you're using ubuntu:

.. code-block:: bash

    sudo apt install docker.io

2 Create a container

.. code-block:: bash

    docker create -p 55555:55555 --name proxy_py proxypy/proxy_py:v2.1

3 Run

.. code-block::

    docker start proxy_py

It will give you a server on address localhost:55555

To see running containers use

.. code-block:: bash

    docker ps

To stop proxy_py use

.. code-block:: bash

    docker stop proxy_py

How to get proxies?
*******************

proxy_py has a server, based on aiohttp, which is listening 127.0.0.1:55555
(you can change it in the settings file) and provides proxies.
To get proxies you should send the following json request
on address `http://127.0.0.1:55555/api/v1/`
(or other domain if behind reverse proxy):

.. code-block:: json

    {
        "model": "proxy",
        "method": "get",
        "order_by": "response_time, uptime"
    }

Note: order_by makes the result sorted
by one or more fields(separated by comma).
You can skip it.
The required fields are `model` and `method`.

It's gonna return you the json response like this:

.. code-block:: json

    {
        "count": 1,
        "data": [{
                "address": "http://127.0.0.1:8080",
                "auth_data": "",
                "bad_proxy": false,
                "domain": "127.0.0.1",
                "last_check_time": 1509466165,
                "number_of_bad_checks": 0,
                "port": 8080,
                "protocol": "http",
                "response_time": 461691,
                "uptime": 1509460949
            }
        ],
        "has_more": false,
        "status": "ok",
        "status_code": 200
    }

Note: All fields except *protocol*, *domain*, *port*, *auth_data*,
*checking_period* and *address* CAN be null

Or error if something went wrong:

.. code-block:: json

    {
        "error_message": "You should specify \"model\"",
        "status": "error",
        "status_code": 400
    }

Note: status_code is also duplicated in HTTP status code

Example using curl:

.. code-block:: bash

    curl -X POST http://127.0.0.1:55555/api/v1/ -H "Content-Type: application/json" --data '{"model": "proxy", "method": "get"}'

Example using httpie:

.. code-block:: bash

    http POST http://127.0.0.1:55555/api/v1/ model=proxy method=get

Example using python's *requests* library:

.. code-block:: python

    import requests
    import json


    def get_proxies():
        result = []
        json_data = {
            "model": "proxy",
            "method": "get",
        }
        url = "http://127.0.0.1:55555/api/v1/"

        response = requests.post(url, json=json_data)
        if response.status_code == 200:
            response = json.loads(response.text)
            for proxy in response["data"]:
                result.append(proxy["address"])
        else:
            # check error here
            pass

        return result

Example using aiohttp library:

.. code-block:: python

    import aiohttp


    async def get_proxies():
        result = []
        json_data = {
            "model": "proxy",
            "method": "get",
        }

        url = "http://127.0.0.1:55555/api/v1/"

        async with aiohttp.ClientSession() as session:
            async with session.post(url, json=json_data) as response:
                if response.status == 200:
                    response = json.loads(await response.text())
                    for proxy in response["data"]:
                        result.append(proxy["address"])
                else:
                    # check error here
                    pass

        return result

How to interact with API?
*************************

Read more about API here -> https://github.com/DevAlone/proxy_py/tree/master/docs/API.md

How to contribute?
******************

Just fork, do your changes(implement new collector, fix a bug
or whatever you want) and create pull request.

Here are some useful guides:

`How to create a collector <https://proxy-py.readthedocs.io/en/latest/guides/how_to_create_collector.html>`_

How to test it?
***************

If you've made changes to the code and want to check that you didn't break
anything, just run

.. code-block:: bash

    py.test

inside virtual environment in proxy_py project directory.

How to deploy on production using supervisor, nginx and postgresql in 9 steps?
******************************************************************************

1 Install supervisor, nginx and postgresql

.. code-block:: bash

    root@server:~$ apt install supervisor nginx postgresql

2 Clone this repository

.. code-block:: bash

    user@server:~/$ git clone https://github.com/DevAlone/proxy_py.git

3 Create virtual environment and install requirements on it

.. code-block:: bash

    user@server:~/proxy_py$ python3 -m venv env
    user@server:~/proxy_py$ pip3 install -r requirements.txt

4 Copy settings.py example:

.. code-block:: bash

    proxy_py@server:~/proxy_py$ cp config_examples/settings.py ./

5 create unprivileged user in postgresql database
and change database authentication data in settings.py

.. code-block:: bash

    proxy_py@server:~/proxy_py$ vim proxy_py/settings.py

.. code-block:: python

    DATABASE_CONNECTION_KWARGS = {
        'database': 'YOUR_POSTGRES_DATABASE',
        'user': 'YOUR_POSTGRES_USER',
        'password': 'YOUR_POSTGRES_PASSWORD',
        # number of simultaneous connections
        # 'max_connections': 20,
    }

6 Copy supervisor config example and change it for your case

.. code-block:: bash

    cp /home/proxy_py/proxy_py/config_examples/proxy_py.supervisor.conf /etc/supervisor/conf.d/proxy_py.conf
    vim /etc/supervisor/conf.d/proxy_py.conf

7 Copy nginx config example, enable it and change if you need

.. code-block:: bash

    cp /home/proxy_py/proxy_py/config_examples/proxy_py.nginx.conf /etc/nginx/sites-available/proxy_py
    ln -s /etc/nginx/sites-available/proxy_py /etc/nginx/sites-enabled/
    vim /etc/nginx/sites-available/proxy_py

8 Restart supervisor and Nginx

.. code-block:: bash

    supervisorctl reread
    supervisorctl update
    /etc/init.d/nginx configtest
    /etc/init.d/nginx restart

9 Enjoy using it on your server!

What is it depend on?
*********************

See *requirements.txt*
