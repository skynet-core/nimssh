## Client 
## ======
## contains ssh2 client's implementation and misc function

from packet import readInfo
import asyncnet, asyncdispatch, net, system


type Password* = string
  ## type alias represents user's password

type Identity* = string
  ## type alias represents user's identity

type
  Credentials* = object
    ## Credentials type used in Client
    user: string
    password: Password
    identity: Identity

type
  Client* = object
    ## Client type defintion
    host: string
    port: uint16
    credentials: Credentials


method `host=`*(self: var Client, host: string): void {.base.} =
  ## host setter
  self.host = host

method host*(self: Client): string {.base.} =
  ## returns client's host
  result = self.host


proc newClient*(host: string,
    port: uint16 = 22): Client =
  ## *newClient* is a constructor proc for ``SSH2 Client`` object
  ##
  ## takes hostname, port and user credentials to connect with remote host
  result = Client(host: host, port: port)

proc newClient*(host: string,
    port: uint16 = 22,
    credentials: Credentials): Client =
  ## *newClient* is a constructor proc for ``SSH2 Client`` object
  ##
  ## takes hostname, port and user credentials to connect with remote host
  result = Client(host: host, port: port, credentials: credentials)


proc connect*(client: Client): Future[void] {.async.} =
  ## *connect* instantiate connection with remote host
  var socket = await asyncnet.dial(
    address = client.host,
   port = Port(
      client.port), protocol = IPPROTO_TCP, buffered = false)
  
  # TODO: connect
  # TODO: read packets
  # TODO: write packets

  return

proc newCredentials(user: string, password: Password): Credentials =
  ## newCredentials builds credentials with `username` and `password`
  result = Credentials(user: user, password: password)

proc newCredentials(user: string, identity: Identity): Credentials =
  ## newCredentials builds credentials with `username` and `identity`
  result = Credentials(user: user, identity: identity)

proc newCredentials(user: string, password: Password,
    identity: Identity): Credentials =
  ## newCredentials builds credentials with `username`, `password` and `identity`
  result = Credentials(user: user, password: password, identity: identity)
