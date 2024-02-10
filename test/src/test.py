#!/usr/bin/python3

from ic import Identity, Agent, Client
from ic.candid import encode, decode, Types

with open("/home/snidebt/Documents/bittoko.pem", "rb") as pem:
    agent = Agent(Identity.from_pem(pem.read()), Client("https://icp-api.io"))

def main():
    return agent.update_raw("szvnk-kqaaa-aaaap-abyla-cai", "hello", encode([{'type': Types.Text, 'value': "world"}]))

if __name__ == "__main__":
    print( main() )
