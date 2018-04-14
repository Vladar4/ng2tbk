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

  Key* = object
    kind*: KeyKind
    pause*: float # valid only if kind == keyNone

  KeyBuffer* = seq[Key]

  Command* = enum
    c_idle
    c_forward_start
    c_forward_stop
    c_backward_start
    c_backward_stop
    c_low_block
    c_low_attack
    c_high_block
    c_high_attack
    c_low_dodge
    c_high_dodge


const
  Interval = Framerate * 1.5
  PatternForwardStart   = [keyA_down]
  PatternForwardStop    = [keyA_up]
  PatternBackwardStart  = [keyB_down]
  PatternBackwardStop   = [keyB_up]
  PatternLowBlock       = [keyA_down, keyA_up]
  PatternHighBlock      = [keyB_down, keyB_up]
  PatternLowAttack      = [keyA_down, keyA_up, keyA_down, keyA_up]
  PatternHighAttack     = [keyB_down, keyB_up, keyB_down, keyB_up]
  PatternLowDodge       = [
    @[keyA_down, keyA_up, keyB_down],
    @[keyA_down, keyB_down]]
  PatternHighDodge      = [
    @[keyB_down, keyB_up, keyA_down],
    @[keyB_down, keyA_down]]


proc add(buffer: var KeyBuffer, elapsed: float) =
  if buffer.len > 0:
    if buffer[^1].kind == keyNone:
      buffer[^1].pause += elapsed
      return
  buffer.add Key(kind: keyNone, pause: elapsed)


proc add(buffer: var KeyBuffer, key: KeyKind) =
  buffer.add Key(kind: key)


proc keys*(buffer: KeyBuffer): seq[KeyKind] =
  result = @[]
  for key in buffer:
    result.add key.kind


proc match(keys, pattern: openarray[KeyKind]): bool =
  if keys.len < pattern.len:
    return false
  for i in 0..pattern.high:
    if keys[i] != pattern[i]:
      return false
  return true


proc next*(buffer: var KeyBuffer): Command =
  result = c_idle
  var
    first = 0
    stack: seq[KeyKind] = @[]

  if buffer.len < 1: return

  for i in 0..buffer.high:
    case buffer[i].kind:
    of keyNone:
      if buffer[i].pause > Interval: # long pause
        if stack.len > 0:
          first = i + 1
          break
        else:
          continue
    else:
      stack.add buffer[i].kind
      if stack.len > 3:
        first = i + 1
        break

  buffer = buffer[first..^1]
  if stack.len > 0 and first > 0: # pattern matching
    for pattern in PatternHighDodge:
      if stack.match pattern: return c_high_dodge
    for pattern in PatternLowDodge:
      if stack.match pattern: return c_low_dodge
    if stack.match PatternHighAttack: return c_high_attack
    if stack.match PatternHighBlock: return c_high_block
    if stack.match PatternLowAttack: return c_low_attack
    if stack.match PatternLowBlock: return c_low_block
    if stack.match PatternForwardStop: return c_forward_stop
    if stack.match PatternForwardStart: return c_forward_start
    if stack.match PatternBackwardStop: return c_forward_stop
    if stack.match PatternBackwardStart: return c_backward_start


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

