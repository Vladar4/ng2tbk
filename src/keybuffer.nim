import
  nimgame2 / [
    input,
    types,
  ],
  data


type
  KeyKind* = enum
    keyNone
    keyA_down
    keyA_up
    keyB_down
    keyB_up

  Command* = enum
    cmdNone
    cmdA
    cmdB

  KeyBuffer* = object
    fA_down, fB_down: bool
    fA_downTime, fB_downTime: float
    stack*: seq[Command]
    holdingA*, holdingB*: bool


const
  Interval = Framerate * 1.5


proc flush*(buffer: var KeyBuffer) =
  buffer.fA_down = false
  buffer.fB_down = false
  buffer.fA_downTime = 0.0
  buffer.fB_downTime = 0.0
  buffer.stack = @[]
  buffer.holdingA = false
  buffer.holdingB = false


proc add(buffer: var KeyBuffer, elapsed: float) =
  if buffer.fA_down:
    buffer.fA_downTime += elapsed
    if buffer.fA_downTime > Interval:
      buffer.holdingA = true

  if buffer.fB_down:
    buffer.fB_downTime += elapsed
    if buffer.fB_downTime > Interval:
      buffer.holdingB = true


proc add(buffer: var KeyBuffer, key: KeyKind) =
  case key:
  of keyA_down:
    buffer.fA_down = true
    buffer.fA_downTime = 0.0
    buffer.holdingA = false
  of keyB_down:
    buffer.fB_down = true
    buffer.fB_downTime = 0.0
    buffer.holdingB = false
  of keyA_up:
    buffer.fA_down = false
    if buffer.fA_downTime <= Interval:
      buffer.stack.add cmdA
    buffer.holdingA = false
  of keyB_up:
    buffer.fB_down = false
    if buffer.fB_downTime <= Interval:
      buffer.stack.add cmdB
    buffer.holdingB = false
  else:
    discard


proc next*(buffer: var KeyBuffer): Command =
  result = cmdNone
  if buffer.stack.len > 0:
    result = buffer.stack[0]
    buffer.stack = buffer.stack[1..^1]


proc update*(buffer: var KeyBuffer, controls: ControlScheme, elapsed: float) =
  buffer.add elapsed
  if controls.a.pressed:
    buffer.add keyA_down
  if controls.a.released:
    buffer.add keyA_up
  if controls.b.pressed:
    buffer.add keyB_down
  if controls.b.released:
    buffer.add keyB_up

