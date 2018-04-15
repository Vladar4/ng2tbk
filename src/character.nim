import
  strutils,
  nimgame2 / [
    assets,
    audio,
    entity,
    input,
    texturegraphic,
    types,
    utils,
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
    health*, maxHealth*: int
    hitCooldown*: float
    getCharacters*: proc(): seq[Entity]
    panning: array[2, Panning]
    killed*: bool


const
  DefaultHealth* = 10
  HitCooldown = Framerate * 6
  ColliderLowAttack = [(115.0, 55.0), (166.0, 62.0)]
  ColliderLowAttackMirrored = [(13.0, 62.0), (64.0, 55.0)]
  ColliderHighAttack = [(106.0, 44.0), (162.0, 25.0)]
  ColliderHighAttackMirrored = [(17.0, 25.0), (73.0, 44.0)]


proc init*(character: Character, graphic: TextureGraphic, mirrored = false,
    player1 = false, player2 = false) =
  character.initEntity()
  character.tags.add "character"
  if player1:
    character.tags.add "player"
    character.tags.add "player1"
    character.control = ckPlayer1
  elif player2:
    character.tags.add "player"
    character.tags.add "player2"
    character.control = ckPlayer2
  else:
    character.control = ckAI

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
    "low_block_1", toSeq(17..19), Framerate)
  discard character.addAnimation(
    "low_block_2", toSeq(20..23), Framerate)
  discard character.addAnimation(
    "low_attack_1", @[16,17,17,17,18,18,18] & toSeq(24..27), Framerate / 2)
  discard character.addAnimation(
    "low_attack_2", toSeq(28..31), Framerate)
  discard character.addAnimation(
    "high_block_1", toSeq(33..35), Framerate)
  discard character.addAnimation(
    "high_block_2", toSeq(36..39), Framerate)
  discard character.addAnimation(
    "high_attack_1", @[32,33,33,33,34,34,34] & toSeq(40..43), Framerate / 2)
  discard character.addAnimation(
    "high_attack_2", toSeq(44..47), Framerate)
  discard character.addAnimation(
    "low_dodge", toSeq(48..55), Framerate)
  discard character.addAnimation(
    "high_dodge", toSeq(56..63), Framerate)
  discard character.addAnimation(
    "death", toSeq(64..71), Framerate)
  discard character.addAnimation(
    "dead", [71], Framerate)

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

  character.health = DefaultHealth
  character.maxHealth = DefaultHealth

  character.getCharacters = proc(): seq[Entity] = @[]

  if mirrored:
    character.panning[0] = 127
    character.panning[1] = 255
  else:
    character.panning[0] = 255
    character.panning[1] = 127


proc hitCollider(character: Entity, highAttack = false) =
  let c = GroupCollider(character.collider)
  if highAttack:
    c.list.add Character(character).cHighAttack
    c.tags.add "high_attack"
  else:
    c.list.add Character(character).cLowAttack
    c.tags.add "low_attack"


proc resetHitCollider*(character: Entity) =
  let c = GroupCollider(character.collider)
  while c.list.len > 1:
    c.list.del 1
  while c.tags.len > 0:
    c.tags.del 0


proc newCharacter*(graphic: TextureGraphic, mirrored = false,
    player1=false, player2=false): Character =
  new result
  init result, graphic, mirrored, player1, player2


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
    discard
  # HIGH BLOCK
  elif index == character.animationIndex("high_block_1"):
    character.play("high_block_2", 1, callback = characterAnimEnd)
  # HIGH ATTACK
  elif index == character.animationIndex("high_attack_1"):
    character.play("high_attack_2", 1, callback = characterAnimEnd)
    character.hitCollider(true)
  elif index == character.animationIndex("high_attack_2"):
    discard

  if not (index == character.animationIndex("low_attack_1") or
          index == character.animationIndex("high_attack_1")):
    character.resetHitCollider()

  if Character(character).killed:
    character.play("dead", -1)
    return

  if not character.sprite.playing:
    character.play("idle", 0)


proc walk(character: Character, back = false) =
  let offset =  if back:
                  if character.mirrored: (CharacterOffset.float, 0.0)
                  else: (-CharacterOffset.float, 0.0)
                else:
                  if character.mirrored: (-CharacterOffset.float, 0.0)
                  else: (CharacterOffset.float, 0.0)
  let newPos =  character.pos.x +
                GroupCollider(character.collider).list[0].pos.x +
                offset[0]
  if  (newPos < 0.0) or (newPos > float GameDim.w):
    return
  # Backward
  if back:
    if character.willCollide(
        character.pos + offset, 0, 1, character.getCharacters()) or
       character.isColliding(character.getCharacters()):
      return
    character.walking = wBackward
    character.pos += offset
    character.play("backward", 1, callback = characterAnimEnd)
  # Forward
  else:
    if character.willCollide(
        character.pos + offset, 0, 1, character.getCharacters()) or
       character.isColliding(character.getCharacters()):
      return
    #TODO
    # quick hack for a double-movement case (for no)
    for c in character.getCharacters():
      if character == Character(c):
        continue
      if offset[0] > 0.0:
        if character.pos + offset >= c.pos:
          return
      else:
        if character.pos + offset <= c.pos:
          return

    character.walking = wForward
    character.play("forward", 1, callback = characterAnimEnd)


proc dodge(character: Character, highDodge = false) =
  let offset =  if character.mirrored: (CharacterOffset.float, 0.0)
                else: (-CharacterOffset.float, 0.0)
  let newPos =  character.pos.x +
                GroupCollider(character.collider).list[0].pos.x +
                offset[0]
  if  (newPos < 0.0) or (newPos > float GameDim.w):
    return
  if character.willCollide(
      character.pos + offset, 0, 1, character.getCharacters()):
    return
  character.pos += offset
  if highDodge:
    character.play("high_dodge", 1, callback = characterAnimEnd)
  else:
    character.play("low_dodge", 1, callback = characterAnimEnd)


proc aiTarget(character: Character): Character =
  result = nil
  for c in character.getCharacters():
    if character == Character(c):
      continue
    return Character(c)


proc aiCommand(character: Character): Command =
  if character.currentAnimationName == "idle":
    let
      target = character.aiTarget()
      dist = character.pos.distance target.pos
    if target.killed: # job is done
      return
    if dist > CharacterOffset: # too far
      if randBool(0.85):
        character.walking = wForward
      else:
        character.walking = wBackward
    else: # close enough
      let cmds = [
        c_low_block,  # 0
        c_low_attack, # 1
        c_high_block, # 2
        c_high_attack,# 3
        c_low_dodge,  # 4
        c_high_dodge] # 5
      return cmds[randWeighted([4, 2, 4, 2, 1, 1])]


method update*(character: Character, elapsed: float) =
  character.updateEntity elapsed

  if character.killed:
    return

  var cmd = if character.control in {ckPlayer1, ckPlayer2}:
    next character.keyBuffer
  elif character.control == ckAI:
    aiCommand character
  else:
    c_idle

  case cmd:
  of c_forward_start:
    if character.walking != wForward:
      character.walk()
  of c_forward_stop:
    character.walking = wNone
  of c_backward_start:
    if character.walking != wBackward:
      character.walk(true)
  of c_backward_stop:
    character.walking = wNone
  of c_low_block:
    if not (character.sprite.playing and character.sprite.currentAnimation > 2):
      character.walking = wNone
      character.play("low_block_1", 1, callback = characterAnimEnd)
  of c_low_attack:
    if not (character.sprite.playing and character.sprite.currentAnimation > 2):
      character.walking = wNone
      character.play("low_attack_1", 1, callback = characterAnimEnd)
      sfxData["swing_low"].play().setPanning(
        character.panning[0], character.panning[1])
  of c_high_block:
    if not (character.sprite.playing and character.sprite.currentAnimation > 2):
      character.walking = wNone
      character.play("high_block_1", 1, callback = characterAnimEnd)
  of c_high_attack:
    if not (character.sprite.playing and character.sprite.currentAnimation > 2):
      character.walking = wNone
      character.play("high_attack_1", 1, callback = characterAnimEnd)
      sfxData["swing_high"].play().setPanning(
        character.panning[0], character.panning[1])
  of c_low_dodge:
    if not (character.sprite.playing and character.sprite.currentAnimation > 2):
      character.walking = wNone
      character.dodge()
      sfxData["dodge"].play().setPanning(
        character.panning[0], character.panning[1])
  of c_high_dodge:
    if not (character.sprite.playing and character.sprite.currentAnimation > 2):
      character.walking = wNone
      character.dodge(true)
      sfxData["dodge"].play().setPanning(
        character.panning[0], character.panning[1])
  else:
    discard

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
  of ckAI:
    discard

  if character.hitCooldown > 0:
    character.hitCooldown -= elapsed


proc kill*(character: Character) =
  character.killed = true
  character.play("death", 1, callback = characterAnimEnd)
  sfxData["death"].play().setPanning(
    character.panning[0], character.panning[1])


method onCollide*(character: Character, target: Entity) =
  if character.killed:
    return
  let tag = character.tags[^1]
  if character.hitCooldown <= 0:

    if "low_attack" in target.collider.tags:
      character.hitCooldown = HitCooldown
      if "low_block" in character.currentAnimationName:
        when not defined(release): echo "low attack blocked by ", tag
        else: discard
        sfxData["parry_low"].play().setPanning(
          character.panning[0], character.panning[1])
      elif "high_dodge" in character.currentAnimationName:
        when not defined(release): echo "low attack dodged by ", tag
        else: discard
      else:
        when not defined(release): echo "low attack to ", tag
        sfxData["hit_low"].play().setPanning(
          character.panning[0], character.panning[1])
        dec character.health
        if character.health < 1:
          kill character

    elif "high_attack" in target.collider.tags:
      character.hitCooldown = HitCooldown
      if "high_block" in character.currentAnimationName:
        when not defined(release): echo "high attack blocked by ", tag
        else: discard
        sfxData["parry_high"].play().setPanning(
          character.panning[0], character.panning[1])
      elif "low_dodge" in character.currentAnimationName:
        when not defined(release): echo "high attack dodged by ", tag
        else: discard
      else:
        when not defined(release): echo "high attack to ", tag
        sfxData["hit_high"].play().setPanning(
          character.panning[0], character.panning[1])
        dec character.health
        if character.health < 1:
          kill character

