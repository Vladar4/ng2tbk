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
    mirrored: bool
    control*: ControlKind
    walking*: WalkingKind
    keyBuffer*: KeyBuffer
    cLowAttack, cHighAttack: LineCollider


const
  ColliderLowAttack = [(115.0, 55.0), (166.0, 62.0)]
  ColliderLowAttackMirrored = [(13.0, 62.0), (64.0, 55.0)]
  ColliderHighAttack = [(106.0, 44.0), (152.0, 20.0)]
  ColliderHighAttackMirrored = [(27.0, 20.0), (73.0, 44.0)]


proc init*(character: Character, graphic: TextureGraphic, mirrored = false) =
  character.initEntity()
  character.tags.add "character"
  character.graphic = graphic

  character.mirrored = mirrored
  if mirrored:
    character.flip = Flip.horizontal

  character.initSprite((180, 120))
  discard character.addAnimation(
    "idle", toSeq(0..7), Framerate)
  discard character.addAnimation(
    "forward", toSeq(8..15), Framerate)
  discard character.addAnimation(
    "backward", toSeq(15..8), Framerate)
  discard character.addAnimation(
    "low_block_1", toSeq(16..19), Framerate)
  discard character.addAnimation(
    "low_block_2", toSeq(20..23), Framerate)
  discard character.addAnimation(
    "low_attack_1", @[16,16,17,17,18,18] & toSeq(24..27), Framerate / 2)
  discard character.addAnimation(
    "low_attack_2", toSeq(28..31), Framerate)
  discard character.addAnimation(
    "high_block_1", toSeq(32..35), Framerate)
  discard character.addAnimation(
    "high_block_2", toSeq(36..39), Framerate)
  discard character.addAnimation(
    "high_attack_1", @[32,32,33,33,34,34] & toSeq(40..43), Framerate / 2)
  discard character.addAnimation(
    "high_attack_2", toSeq(44..47), Framerate)

  # collider
  let c = newGroupCollider character
  character.collider = c
  if mirrored:
    c.list.add newBoxCollider(
      character, (CharacterOffset * 2, 60), (CharacterOffset, 120))
  else:
    c.list.add newBoxCollider(
      character, (CharacterOffset, 60), (CharacterOffset, 120))

  # attack colliders
  if mirrored:
    character.cLowAttack = newLineCollider(
      character, ColliderLowAttackMirrored[0], ColliderLowAttackMirrored[1])
    character.cHighAttack = newLineCollider(
      character, ColliderHighAttackMirrored[0], ColliderHighAttackMirrored[1])
  else:
    character.cLowAttack = newLineCollider(
      character, ColliderLowAttack[0], ColliderLowAttack[1])
    character.cHighAttack = newLineCollider(
      character, ColliderHighAttack[0], ColliderHighAttack[1])

  character.keyBuffer = @[]


proc hitCollider(character: Entity, highAttack = false) =
  let c = GroupCollider(character.collider)
  if highAttack:
    c.list.add Character(character).cHighAttack
  else:
    c.list.add Character(character).cLowAttack


proc resetHitCollider(character: Entity) =
  let c = GroupCollider(character.collider)
  if c.list.len > 1:
    c.list.del 1


proc newCharacter*(graphic: TextureGraphic, mirrored = false): Character =
  new result
  result.init(graphic, mirrored)


proc characterAnimEnd(character: Entity, index: int) =
  if index == character.animationIndex("forward"):
    if Character(character).mirrored:
      character.pos.x -= CharacterOffset
    else:
      character.pos.x += CharacterOffset
  elif index == character.animationIndex("backward"):
    discard
  # LOW BLOCK
  elif index == character.animationIndex("low_block_1"):
    character.play("low_block_2", 1, callback = characterAnimEnd)
  # LOW ATTACK
  elif index == character.animationIndex("low_attack_1"):
    character.play("low_attack_2", 1, callback = characterAnimEnd)
    character.hitCollider()
  elif index == character.animationIndex("low_attack_2"):
    character.resetHitCollider()
  # HIGH BLOCK
  elif index == character.animationIndex("high_block_1"):
    character.play("high_block_2", 1, callback = characterAnimEnd)
  # HIGH ATTACK
  elif index == character.animationIndex("high_attack_1"):
    character.play("high_attack_2", 1, callback = characterAnimEnd)
    character.hitCollider(true)
  elif index == character.animationIndex("high_attack_2"):
    character.resetHitCollider()

  if not character.sprite.playing:
    character.play("idle", 0)


proc walk(character: Character, back = false) =
  # Backward
  if back:
    if character.mirrored:
      character.walking = wBackward
      character.pos.x += CharacterOffset
      character.play("backward", 1, callback = characterAnimEnd)
    else:
      character.walking = wBackward
      character.pos.x -= CharacterOffset
      character.play("backward", 1, callback = characterAnimEnd)
  # Forward
  else:
    character.walking = wForward
    character.play("forward", 1, callback = characterAnimEnd)


method update*(character: Character, elapsed: float) =
  character.updateEntity elapsed

  var cmd = next character.keyBuffer
  while cmd != c_idle:
    case cmd:
    of c_forward_start:
      character.walk()
    of c_forward_stop:
      character.walking = wNone
    of c_backward_start:
      character.walk(true)
    of c_backward_stop:
      character.walking = wNone
    of c_low_block:
      character.walking = wNone
      character.play("low_block_1", 1, callback = characterAnimEnd)
    of c_low_attack:
      character.walking = wNone
      character.play("low_attack_1", 1, callback = characterAnimEnd)
    of c_high_block:
      character.walking = wNone
      character.play("high_block_1", 1, callback = characterAnimEnd)
    of c_high_attack:
      character.walking = wNone
      character.play("high_attack_1", 1, callback = characterAnimEnd)
    else:
      discard
    cmd = next character.keyBuffer

  if not character.sprite.playing:
    if character.walking == wForward:
      character.walk()
    elif character.walking == wBackward:
      character.walk(true)
    else:
      character.play("idle", 1, callback = characterAnimEnd)


  case character.control:
  of ckNone: discard
  of ckPlayer1:
    character.keyBuffer.update(player1key, elapsed)
  of ckPlayer2:
    character.keyBuffer.update(player2key, elapsed)
    discard
  of ckAI:
    #TODO
    discard


method onCollide*(character: Character, target: Entity) =
  #TODO
  discard

