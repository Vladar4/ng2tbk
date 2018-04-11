import
  nimgame2 / [
    assets,
    audio,
    entity,
    input,
    texturegraphic,
    types,
  ],
  data, keybuffer


type
  ControlKind* = enum
    ckNone
    ckPlayer1
    ckPlayer2
    ckAI

  WalkingKind* = enum
    wNone
    wForward
    wBackward

  Character* = ref object of Entity
    control*: ControlKind
    walking*: WalkingKind
    keyBuffer*: KeyBuffer


proc init*(character: Character, graphic: TextureGraphic) =
  character.initEntity()
  character.tags.add "character"
  character.graphic = graphic
  character.initSprite((180, 120))
  discard character.addAnimation(
    "forward", toSeq(0..7), Framerate)
  discard character.addAnimation(
    "backward", toSeq(7..0), Framerate)
  discard character.addAnimation(
    "low_block_1", toSeq(8..11), Framerate)
  discard character.addAnimation(
    "low_block_2", toSeq(12..15), Framerate)
  discard character.addAnimation(
    "low_attack_1", @[8,8,9,9,10,10] & toSeq(16..19), Framerate / 2)
  discard character.addAnimation(
    "low_attack_2", toSeq(20..23), Framerate)

  # collider
  let c = newGroupCollider character
  character.collider = c
  c.list.add newBoxCollider(
    character, (CharacterOffset, 60), (CharacterOffset, 120))

  character.keyBuffer = @[]

#[
proc colliderOffset(character: Entity, x: float) =
  let c = GroupCollider(character.collider)
  for i in c.list:
    i.pos.x = x
]#

proc newCharacter*(graphic: TextureGraphic): Character =
  new result
  result.init graphic


proc characterAnimEnd(character: Entity, index: int) =
  if index == character.animationIndex("forward"):
    character.pos.x += CharacterOffset
  elif index == character.animationIndex("backward"):
    discard
  elif index == character.animationIndex("low_block_1"):
    character.play("low_block_2", 1, callback = characterAnimEnd)
  elif index == character.animationIndex("low_attack_1"):
    character.play("low_attack_2", 1, callback = characterAnimEnd)

  if not character.sprite.playing:
    character.play("forward", 0)


method update*(character: Character, elapsed: float) =
  character.updateEntity elapsed

  var cmd = next character.keyBuffer
  while cmd != c_idle:
    case cmd:
    of c_forward_start:
      character.walking = wForward
      character.play("forward", 1, callback = characterAnimEnd)
    of c_forward_stop:
      character.walking = wNone
    of c_backward_start:
      character.walking = wBackward
      character.pos.x -= CharacterOffset
      character.play("backward", 1, callback = characterAnimEnd)
    of c_backward_stop:
      character.walking = wNone
    of c_low_block:
      character.walking = wNone
      character.play("low_block_1", 1, callback = characterAnimEnd)
    of c_low_attack:
      character.walking = wNone
      character.play("low_attack_1", 1, callback = characterAnimEnd)
    else:
      discard
    cmd = next character.keyBuffer

  if not character.sprite.playing:
    if character.walking == wForward:
      character.play("forward", 1, callback = characterAnimEnd)
    elif character.walking == wBackward:
      character.pos.x -= CharacterOffset
      character.play("backward", 1, callback = characterAnimEnd)


  case character.control:
  of ckNone: discard
  of ckPlayer1:
    character.keyBuffer.update(player1key, elapsed)
  of ckPlayer2:
    #TODO
    discard
  of ckAI:
    #TODO
    discard



method onCollide*(character: Character, target: Entity) =
  #TODO
  discard

