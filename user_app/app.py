import asyncio
import logging
import serfio
import json
from pathlib import Path

CONFIG_PATH = '/config/app-config.json'
# CONFIG_PATH = './config.json'

cnf = None

def read_config(path):
    cnf_path = Path(path)
    if not cnf_path.is_file():
        return None

    return json.loads(cnf_path.read_text())


async def get_members(serf):
    response = await serf.members()
    return response

def handle_config_query():
    if cnf is None:
        return "No config found"

    return json.dumps(cnf)

def handle_config_reload_event():
    global cnf
    cnf = read_config(CONFIG_PATH)

async def get_events(serf: serfio.Serf):
    # cnt = 0
    async for event in serf.stream(
            # event_type="query:config"
            event_type="query,user"
    ):
        print(event)
        if event['Event'] == 'query':
            if event['Name'] == 'config':
                id = event['ID']
                resp = handle_config_query()
                await serf.respond(id, resp)
        elif event['Event'] == 'user':
            if event['Name'] == 'config-reload':
                handle_config_reload_event()

        # cnt += 1
        # if cnt > 2:
        #     break


async def main():
    serf = serfio.Serf(
        host="127.0.0.1",
        port=7373,
        # auth_key="blah-blah"
    )

    global cnf
    cnf = read_config(CONFIG_PATH)

    try:
        await serf.connect()
        await get_events(serf)

    finally:
        await serf.close()


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)

    asyncio.run(main())
