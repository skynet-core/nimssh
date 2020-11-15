## Packet
## ======
## SSH2 tcp packet implementation

import async, strutils, sequtils
from asyncnet import AsyncSocket,recvLine

iterator pairs*(it: seq[auto]): auto =
  var i = 0
  for x in it:
    yield (key: i, val: x)
    inc i


type
  Version* = object
    major: int
    minor: int

method repr*(self: Version): string {.base.}=
  result = $self.major & "." & $self.minor
  
type
  Info* = object
    ver: Version
    software: string
    comment: string

method repr*(self: Info): string {.base.} =
  result = "SSH-" & (repr self.ver) &
    "-" & self.software & " " & self.comment

proc readInfo*(socket: AsyncSocket): Future[Info] {.async.} =
  ## readInfo reads firs line form socket and parse it into Info object
  let greeting = await socket.recvLine(maxLength=1024)
  var comment: string
  for i, v in pairs(greeting.split(" ")):
    if i == 1:
      comment = v

  let parts = greeting.split("-")
  let majMin = parts[1].split(".").map(parseInt)
  let ver = Version(major:majMin[0],minor: majMin[1])
  result = Info(ver:ver,software:parts[2],comment: comment)


type
  Packet* = object
    ## Packet implemets ssh2 packet structure
    length:        uint32     ## length contains total length of the packet
    paddingLength: uint8      ## padding is a random padding size
    payload:       seq[uint8] ## packet payload data
    padding:       seq[uint8] ## padding random padding bytes
    mac:           seq[uint8] ## MAC (message authenticaton code)


method `length=`(self:var Packet,length:uint32): void =
  self.length = length
  
method length(self:var Packet): uint32 =
  result = self.length


proc readPacket(socket: AsyncSocket): Future[Packet] {.async.} = 
    result = Packet()
    var buff = newSeq[uint8](5)
    let n = await socket.recvInto(addr buff,5)
    if n < 5:
      raise newException(IOError, "read error: recv 5 bytes got " & $n & "bytes")
    # here we need to use endianes
    var l = cast[uint32](buff[0..^2]) # convert first 4 bytes to uint32
    var lbe = l
    swapEndian32(addr lbe, addr l)
    result.length = lbe
    result.paddingLength = buff[4]
    buff = newSeq[uint8](result.length)
    # now we can read payload data 